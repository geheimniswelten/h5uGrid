program TestSampleData;

{$APPTYPE CONSOLE}

uses
  System.Classes,
  System.SysUtils,
  Data.DB,
  MidasLib,
  h5u.Grid.SampleData;

type
  TComponentAccess = class(TComponent);

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

procedure TestConstructor;
var
  LData: Th5uSampleClientDataset;
begin
  LData := Th5uSampleClientDataset.Create(nil);
  try
    Check(LData.Active, 'New sample dataset must be active');
    Check(LData.RecordCount = 25, 'Default sample row count');
    Check(not LData.LogChanges, 'Sample changes must not be logged');
    LData.SampleRowCount := 40;
    Check(LData.RecordCount = 40, 'Changing sample row count must rebuild data');
    LData.Close;
    LData.EnsureSampleData;
    Check(LData.Active and (LData.RecordCount = 40), 'Reopen sample data');
  finally
    LData.Free;
  end;
end;

procedure TestStreaming(ADesigning: Boolean; AAutoCreate: Boolean = True; AIncludeImages: Boolean = True);
const
  CFormText = 'object Root: TComponent' + sLineBreak + '  object SampleData: Th5uSampleClientDataset' + sLineBreak + '    IncludeImages = True'
    + sLineBreak + '    AutoCreateSampleData = True' + sLineBreak + '    SampleRowCount = 40' + sLineBreak + '  end' + sLineBreak + 'end';
var
  LRoot: TComponent;
  LText: TStringStream;
  LBinary: TMemoryStream;
  LData: Th5uSampleClientDataset;
  LFormText: string;
begin
  LRoot := TComponent.Create(nil);
  try
    TComponentAccess(LRoot).SetDesigning(ADesigning);
    LFormText := CFormText;
    if not AAutoCreate then
      LFormText := StringReplace(LFormText, 'AutoCreateSampleData = True', 'AutoCreateSampleData = False', []);
    if not AIncludeImages then
      LFormText := StringReplace(LFormText, 'IncludeImages = True', 'IncludeImages = False', []);
    LText := TStringStream.Create(LFormText);
    try
      LBinary := TMemoryStream.Create;
      try
        ObjectTextToBinary(LText, LBinary);
        LBinary.Position := 0;
        LBinary.ReadComponent(LRoot);
      finally
        LBinary.Free;
      end;
    finally
      LText.Free;
    end;
    LData := LRoot.FindComponent('SampleData') as Th5uSampleClientDataset;
    Check(Assigned(LData), 'Streamed sample component missing');
    Check((csDesigning in LData.ComponentState) = ADesigning, 'Design mode propagation');
    Check(LData.Active = AAutoCreate, 'Streamed automatic creation setting');
    if not AAutoCreate then
      Exit;
    Check(LData.RecordCount = 40, 'Streamed demo row count');
    Check(not LData.LogChanges, 'Streamed dataset must not log sample changes');
    Check(LData.FieldByName('ID').AsInteger = 1, 'First demo record');
    Check(LData.FieldByName('PICTURE').IsNull <> AIncludeImages, 'Streamed image setting');
  finally
    LRoot.Free;
  end;
end;

begin
  try
    RegisterClass(Th5uSampleClientDataset);
    TestConstructor;
    TestStreaming(False);
    TestStreaming(True);
    TestStreaming(True, False);
    TestStreaming(True, True, False);
    Writeln('PASS: construction, runtime streaming and design-mode streaming');
  except
    on E: Exception do
    begin
      Writeln(E.ClassName, ': ', E.Message);
      ExitCode := 1;
    end;
  end;
end.
