program TestDatasetReadNotifications;

{$APPTYPE CONSOLE}
{$SCOPEDENUMS ON}

uses
  System.Classes,
  System.Rtti,
  System.SysUtils,
  Data.DB,
  Datasnap.DBClient,
  MidasLib,
  h5u.Grid.Data.Core,
  h5u.Grid.Data.Dataset,
  h5u.Grid.Types;

type
  EReadFailure = class(Exception);

  TTestStringField = class(TStringField)
  protected
    function GetAsString: string; override;
  public
    FailNextRead: Boolean;
    ReadCount: Integer;
  end;

  TFixture = class
  private
    procedure Changed(Sender: TObject; const AChange: Th5uDataChange);
    procedure SourceChanged(Sender: TObject; Field: TField);
  public
    Data: TClientDataSet;
    Source: TDataSource;
    Controller: Th5uDatasetController;
    Link: Th5uDataControllerLink;
    TextField: TTestStringField;
    ChangeCount: Integer;
    ReadOnChange: Boolean;
    FailSourceChange: Boolean;
    constructor Create(AMode: Th5uCacheMode);
    destructor Destroy; override;
  end;

function TTestStringField.GetAsString: string;
begin
  Inc(ReadCount);
  if FailNextRead then
  begin
    FailNextRead := False;
    raise EReadFailure.Create('Injected field read failure');
  end;
  Result := inherited;
end;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

constructor TFixture.Create(AMode: Th5uCacheMode);
var
  LID: TIntegerField;
  LIndex: Integer;
begin
  inherited Create;
  Data := TClientDataSet.Create(nil);
  LID := TIntegerField.Create(Data);
  LID.FieldName := 'ID';
  LID.DataSet := Data;
  TextField := TTestStringField.Create(Data);
  TextField.FieldName := 'TEXT';
  TextField.Size := 80;
  TextField.DataSet := Data;
  Data.CreateDataSet;
  for LIndex := 1 to 40 do
    Data.AppendRecord([LIndex, 'Row ' + IntToStr(LIndex)]);
  Data.RecNo := 7;
  Source := TDataSource.Create(nil);
  Source.DataSet := Data;
  Source.OnDataChange := SourceChanged;
  Controller := Th5uDatasetController.Create(nil);
  Controller.KeyFieldName := 'ID';
  Controller.Cache.Mode := AMode;
  Controller.DataSource := Source;
  Link := Th5uDataControllerLink.Create;
  Link.OnChanged := Changed;
  Link.Controller := Controller;
  ChangeCount := 0;
  TextField.ReadCount := 0;
end;

destructor TFixture.Destroy;
begin
  Link.Free;
  Controller.Free;
  Source.Free;
  Data.Free;
  inherited;
end;

procedure TFixture.Changed(Sender: TObject; const AChange: Th5uDataChange);
begin
  Inc(ChangeCount);
  // Fail deterministically instead of overflowing the stack on the old code.
  if ReadOnChange then
  begin
    Check(ChangeCount <= 16, 'Recursive change notifications during a consumer read');
    Controller.GetValue(20, 'TEXT');
  end;
end;

procedure TFixture.SourceChanged(Sender: TObject; Field: TField);
begin
  if FailSourceChange then
  begin
    FailSourceChange := False;
    raise EReadFailure.Create('Injected EnableControls notification failure');
  end;
end;

procedure TestReads(AMode: Th5uCacheMode);
var
  LTest: TFixture;
  LIndex: Integer;
  LReads: Integer;
begin
  LTest := TFixture.Create(AMode);
  try
    LTest.Controller.PrepareRange(0, 40);
    for LIndex := 0 to 39 do
    begin
      Check(LTest.Controller.GetValue(LIndex, 'TEXT').AsString = 'Row ' + IntToStr(LIndex + 1), 'Wrong row value');
      Check(LTest.Controller.GetDisplayText(LIndex, 'ID') = IntToStr(LIndex + 1), 'Wrong display text');
      if AMode <> Th5uCacheMode.None then
        Check(LTest.Controller.GetRowKey(LIndex).ToString = IntToStr(LIndex + 1), 'Wrong row key');
    end;
    Check(LTest.ChangeCount = 0, 'Read-only access emitted ' + IntToStr(LTest.ChangeCount) + ' data changes');
    Check(LTest.Data.RecNo = 7, 'Read moved the original dataset cursor');
    Check(not LTest.Data.ControlsDisabled, 'Read left dataset controls disabled');
    LReads := LTest.TextField.ReadCount;
    LTest.Controller.GetValue(20, 'TEXT');
    if AMode <> Th5uCacheMode.None then
      Check(LTest.TextField.ReadCount = LReads, 'Read invalidated populated snapshot cache');

    LTest.Data.DisableControls;
    try
      LTest.Controller.GetValue(35, 'TEXT');
      Check(LTest.Data.ControlsDisabled, 'Read unbalanced caller DisableControls');
    finally
      LTest.Data.EnableControls;
    end;
  finally
    LTest.Free;
  end;
end;

procedure TestRealChanges(AMode: Th5uCacheMode);
var
  LTest: TFixture;
begin
  LTest := TFixture.Create(AMode);
  try
    // An actual dataset notification must still reach a consumer that reads data.
    LTest.ReadOnChange := True;
    LTest.Data.RecNo := 21;
    Check(LTest.ChangeCount > 0, 'External navigation notification lost');
    LTest.ChangeCount := 0;
    LTest.ReadOnChange := False;
    LTest.Data.Edit;
    LTest.TextField.AsString := 'Updated';
    LTest.Data.Post;
    Check(LTest.ChangeCount > 0, 'External edit notification lost');
    LTest.ChangeCount := 0;
    Check(LTest.Controller.GetValue(20, 'TEXT').AsString = 'Updated', 'Stale snapshot after external edit');
    Check(LTest.ChangeCount = 0, 'Reading an edited row emitted changes');

    LTest.Controller.SetValue(20, 'TEXT', TValue.From<string>('Controller edit'));
    Check(LTest.ChangeCount > 0, 'Controller edit notification lost');
    LTest.ChangeCount := 0;
    Check(LTest.Controller.GetValue(20, 'TEXT').AsString = 'Controller edit', 'Stale snapshot after controller edit');
    Check(LTest.ChangeCount = 0, 'Reading a controller edit emitted changes');
    LTest.Data.Close;
    Check(LTest.ChangeCount > 0, 'Dataset close notification lost');
    Check(LTest.Controller.GetRowCount = 0, 'Closed dataset still has rows');
  finally
    LTest.Free;
  end;
end;

procedure TestReadFailure(AMode: Th5uCacheMode; AFailEnableControls: Boolean);
var
  LTest: TFixture;
  LFailed: Boolean;
begin
  LTest := TFixture.Create(AMode);
  try
    LTest.TextField.FailNextRead := not AFailEnableControls;
    LTest.FailSourceChange := AFailEnableControls;
    LFailed := False;
    try
      LTest.Controller.GetValue(20, 'TEXT');
    except
      on E: EReadFailure do
        LFailed := True;
    end;
    Check(LFailed, 'Expected injected exception');
    Check(LTest.Data.RecNo = 7, 'Exception path failed to restore cursor');
    Check(not LTest.Data.ControlsDisabled, 'Exception path left controls disabled');
    Check(LTest.ChangeCount = 0, 'Failed read emitted changes');
    Check(LTest.Controller.GetValue(20, 'TEXT').AsString = 'Row 21', 'Read did not recover after exception');
    LTest.Data.RecNo := 22;
    Check(LTest.ChangeCount > 0, 'Exception path left notifications suppressed');
  finally
    LTest.Free;
  end;
end;

var
  LMode: Th5uCacheMode;
  LFailures: Integer;
begin
  LFailures := 0;
  for LMode := Low(Th5uCacheMode) to High(Th5uCacheMode) do
  begin
    try
      TestReads(LMode);
      TestRealChanges(LMode);
      TestReadFailure(LMode, False);
      TestReadFailure(LMode, True);
      Writeln('PASS: cache mode ', Ord(LMode), ' - reads, changes, field and EnableControls exceptions');
    except
      on E: Exception do
      begin
        Inc(LFailures);
        Writeln('FAIL: cache mode ', Ord(LMode), ': ', E.ClassName, ': ', E.Message);
      end;
    end;
  end;
  if LFailures > 0 then
    ExitCode := 1;
end.
