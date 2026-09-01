unit Main;

interface

{$SCOPEDENUMS ON}

uses
  System.Classes,
  System.Generics.Collections,
  System.Rtti,
  System.SysUtils,
  FMX.Controls,
  FMX.Forms,
  FMX.StdCtrls,
  FMX.Types,
  h5u.Grid.Data.Virtual,
  h5u.Grid.Types,
  FMX.h5u.Grid;

type
  TLiveRow = class
  public
    Id: Int64;
    Timestamp: TDateTime;
    Source: string;
    MessageText: string;
    Severity: Integer;
    Acknowledged: Boolean;
  end;

  TMainForm = class(TForm)
    ToolBar: TToolBar;
    PauseCheck: TCheckBox;
    CacheCheck: TCheckBox;
    DarkCheck: TCheckBox;
    AppendButton: TButton;
    ClearButton: TButton;
    Grid: Th5uFmxGrid;
    VirtualController: Th5uVirtualController;
    LiveTimer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure OptionChange(Sender: TObject);
    procedure AppendButtonClick(Sender: TObject);
    procedure ClearButtonClick(Sender: TObject);
    procedure LiveTimerTimer(Sender: TObject);
    procedure VirtualGetRowCount(Sender: TObject; var ARowCount: Int64);
    procedure VirtualGetRowKey(Sender: TObject; ASourceRowIndex: Int64; var ARowKey: Th5uRowKey);
    procedure VirtualGetValue(Sender: TObject; ASourceRowIndex: Int64; const AFieldName: string; var AValue: TValue);
    procedure VirtualSetValue(Sender: TObject; ASourceRowIndex: Int64; const AFieldName: string; const AValue: TValue; var AHandled: Boolean);
  private
    FRows: TObjectList<TLiveRow>;
    FNextId: Int64;
    procedure AppendRow;
    procedure ApplyOptions;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

procedure TMainForm.AppendButtonClick(Sender: TObject);
begin
  AppendRow;
end;

procedure TMainForm.AppendRow;
const
  CSources: array[0..3] of string = (
    'ERP', 'Worker', 'Import', 'Interface'
  );
var
  LRow: TLiveRow;
  LIndex: Int64;
begin
  Inc(FNextId);
  LRow := TLiveRow.Create;
  LRow.Id := FNextId;
  LRow.Timestamp := Now;
  LRow.Source := CSources[FNextId mod Length(CSources)];
  LRow.Severity := FNextId mod 4;
  LRow.Acknowledged := False;
  if (FNextId mod 7) = 0 then
    LRow.MessageText :=
      'Längerer Eventtext aus OnGetValue. Der Grid-Viewport ' +
      'materialisiert nur die sichtbaren Zeilen und Zellen.'
  else
    LRow.MessageText := Format('FMX Live-Ereignis %d', [FNextId]);
  LIndex := FRows.Count;
  FRows.Add(LRow);
  VirtualController.NotifyRowsInserted(LIndex, 1);
end;

procedure TMainForm.ApplyOptions;
begin
  LiveTimer.Enabled := not PauseCheck.IsChecked;
  if CacheCheck.IsChecked then
    VirtualController.Cache.Mode := Th5uCacheMode.Viewport
  else
    VirtualController.Cache.Mode := Th5uCacheMode.None;
  if DarkCheck.IsChecked then
    Grid.Theme := Th5uGridTheme.Dark
  else
    Grid.Theme := Th5uGridTheme.ApplicationStyle;
end;

procedure TMainForm.ClearButtonClick(Sender: TObject);
begin
  FRows.Clear;
  VirtualController.NotifyReset;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  FRows := TObjectList<TLiveRow>.Create(True);
  for I := 1 to 60 do
    AppendRow;
  ApplyOptions;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FRows.Free;
end;

procedure TMainForm.LiveTimerTimer(Sender: TObject);
var
  LIndex: Integer;
begin
  if (FRows.Count = 0) or ((FNextId mod 3) = 0) then
    AppendRow
  else
  begin
    LIndex := Random(FRows.Count);
    FRows[LIndex].Severity := (FRows[LIndex].Severity + 1) mod 4;
    FRows[LIndex].Timestamp := Now;
    FRows[LIndex].MessageText :=
      FRows[LIndex].MessageText + ' *';
    VirtualController.NotifyRowChanged(LIndex);
  end;
end;

procedure TMainForm.OptionChange(Sender: TObject);
begin
  ApplyOptions;
end;

procedure TMainForm.VirtualGetRowCount(Sender: TObject; var ARowCount: Int64);
begin
  ARowCount := FRows.Count;
end;

procedure TMainForm.VirtualGetRowKey(Sender: TObject; ASourceRowIndex: Int64; var ARowKey: Th5uRowKey);
begin
  if (ASourceRowIndex >= 0) and
     (ASourceRowIndex < FRows.Count) then
    ARowKey := Th5uRowKey.FromInt64(FRows[ASourceRowIndex].Id);
end;

procedure TMainForm.VirtualGetValue(Sender: TObject; ASourceRowIndex: Int64; const AFieldName: string; var AValue: TValue);
var
  LRow: TLiveRow;
begin
  if (ASourceRowIndex < 0) or
     (ASourceRowIndex >= FRows.Count) then
    Exit;
  LRow := FRows[ASourceRowIndex];

  if SameText(AFieldName, 'ID') then
    AValue := TValue.From<Int64>(LRow.Id)
  else if SameText(AFieldName, 'TIMESTAMP') then
    AValue := TValue.From<TDateTime>(LRow.Timestamp)
  else if SameText(AFieldName, 'SOURCE') then
    AValue := TValue.From<string>(LRow.Source)
  else if SameText(AFieldName, 'MESSAGE') then
    AValue := TValue.From<string>(LRow.MessageText)
  else if SameText(AFieldName, 'SEVERITY') then
    AValue := TValue.From<Integer>(LRow.Severity)
  else if SameText(AFieldName, 'ACK') then
    AValue := TValue.From<Boolean>(LRow.Acknowledged);
end;

procedure TMainForm.VirtualSetValue(Sender: TObject; ASourceRowIndex: Int64; const AFieldName: string; const AValue: TValue; var AHandled: Boolean);
begin
  AHandled := False;
  if (ASourceRowIndex < 0) or
     (ASourceRowIndex >= FRows.Count) then
    Exit;

  if SameText(AFieldName, 'ACK') then
  begin
    FRows[ASourceRowIndex].Acknowledged := AValue.AsBoolean;
    AHandled := True;
  end
  else if SameText(AFieldName, 'MESSAGE') then
  begin
    FRows[ASourceRowIndex].MessageText := AValue.ToString;
    AHandled := True;
  end;
end;

end.
