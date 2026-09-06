unit Main;

interface

{$SCOPEDENUMS ON}

uses
  System.Classes,
  System.Generics.Collections,
  System.Rtti,
  System.SysUtils,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.StdCtrls,
  h5u.Grid.Data.Virtual,
  h5u.Grid.Types,
  Vcl.h5u.Grid;

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
    TopPanel: TPanel;
    PauseCheck: TCheckBox;
    CacheCheck: TCheckBox;
    PagedCheck: TCheckBox;
    DarkCheck: TCheckBox;
    AppendButton: TButton;
    ClearButton: TButton;
    NextPageButton: TButton;
    StatusLabel: TLabel;
    LiveTimer: TTimer;
    VirtualController: Th5uVirtualController;
    Grid: Th5uVclGrid;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure LiveTimerTimer(Sender: TObject);
    procedure AppendButtonClick(Sender: TObject);
    procedure ClearButtonClick(Sender: TObject);
    procedure OptionClick(Sender: TObject);
    procedure NextPageButtonClick(Sender: TObject);
    procedure VirtualControllerGetRowCount(Sender: TObject; var ARowCount: Int64);
    procedure VirtualControllerGetRowKey(Sender: TObject; ASourceRowIndex: Int64; var ARowKey: Th5uRowKey);
    procedure VirtualControllerGetValue(Sender: TObject; ASourceRowIndex: Int64; const AFieldName: string; var AValue: TValue);
    procedure VirtualControllerSetValue(Sender: TObject; ASourceRowIndex: Int64; const AFieldName: string; const AValue: TValue; var AHandled: Boolean);
    procedure VirtualControllerPrepareRange(Sender: TObject; AFirstSourceRow, ACount: Int64; AQueryGeneration: Int64);
  private
    FRows: TObjectList<TLiveRow>;
    FNextId: Int64;
    procedure AppendLiveRow;
    procedure ApplyOptions;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.AppendButtonClick(Sender: TObject);
begin
  AppendLiveRow;
end;

procedure TMainForm.AppendLiveRow;
const
  CSources: array[0..4] of string = ('Scheduler', 'Import', 'ERP', 'Worker', 'Interface');
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
  if (FNextId mod 8) = 0 then
    LRow.MessageText :=
      'Längerer Live-Text für AutoHeight: Der Wert stammt direkt ' +
      'aus dem OnGetValue-Ereignis und existiert nicht als ' +
      'Grid-Datensatzobjekt.'
  else
    LRow.MessageText := Format('Live-Ereignis Nummer %d wurde empfangen.', [FNextId]);

  LIndex := FRows.Count;
  FRows.Add(LRow);
  VirtualController.NotifyRowsInserted(LIndex, 1);
  StatusLabel.Caption := Format('%d Live-Datensätze; letzte ID %d', [FRows.Count, FNextId]);
end;

procedure TMainForm.ApplyOptions;
begin
  LiveTimer.Enabled := not PauseCheck.Checked;

  if CacheCheck.Checked then
    VirtualController.Cache.Mode := Th5uCacheMode.Viewport
  else
    VirtualController.Cache.Mode := Th5uCacheMode.None;

  if PagedCheck.Checked then
  begin
    VirtualController.Pagination.Mode := Th5uPaginationMode.NumberedPages;
    VirtualController.Pagination.PageSize := 20;
  end
  else
  begin
    VirtualController.Pagination.Mode := Th5uPaginationMode.Continuous;
    VirtualController.Pagination.PageIndex := 0;
  end;

  if DarkCheck.Checked then
    Grid.Theme := Th5uGridTheme.Dark
  else
    Grid.Theme := Th5uGridTheme.ApplicationStyle;
end;

procedure TMainForm.ClearButtonClick(Sender: TObject);
begin
  FRows.Clear;
  VirtualController.NotifyReset;
  StatusLabel.Caption := 'Keine Live-Datensätze';
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  FRows := TObjectList<TLiveRow>.Create(True);
  for I := 1 to 60 do
    AppendLiveRow;
  ApplyOptions;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FRows.Free;
end;

procedure TMainForm.LiveTimerTimer(Sender: TObject);
var
  LIndex: Integer;
  LRow: TLiveRow;
begin
  if (FRows.Count = 0) or ((FNextId mod 3) = 0) then
    AppendLiveRow
  else
  begin
    LIndex := Random(FRows.Count);
    LRow := FRows[LIndex];
    LRow.Severity := (LRow.Severity + 1) mod 4;
    LRow.Timestamp := Now;
    LRow.MessageText := LRow.MessageText + ' *';
    VirtualController.NotifyRowChanged(LIndex);
  end;
end;

procedure TMainForm.NextPageButtonClick(Sender: TObject);
var
  LPageCount: Integer;
begin
  if VirtualController.Pagination.Mode <> Th5uPaginationMode.NumberedPages then
    Exit;

  LPageCount := (FRows.Count + VirtualController.Pagination.PageSize - 1) div VirtualController.Pagination.PageSize;

  VirtualController.Pagination.PageIndex := (VirtualController.Pagination.PageIndex + 1) mod System.Math.Max(1, LPageCount);
end;

procedure TMainForm.OptionClick(Sender: TObject);
begin
  ApplyOptions;
end;

procedure TMainForm.VirtualControllerGetRowCount(Sender: TObject; var ARowCount: Int64);
begin
  ARowCount := FRows.Count;
end;

procedure TMainForm.VirtualControllerGetRowKey(Sender: TObject; ASourceRowIndex: Int64; var ARowKey: Th5uRowKey);
begin
  if (ASourceRowIndex >= 0) and (ASourceRowIndex < FRows.Count) then
    ARowKey := Th5uRowKey.FromInt64(FRows[ASourceRowIndex].Id);
end;

procedure TMainForm.VirtualControllerGetValue(Sender: TObject; ASourceRowIndex: Int64; const AFieldName: string; var AValue: TValue);
var
  LRow: TLiveRow;
begin
  if (ASourceRowIndex < 0) or (ASourceRowIndex >= FRows.Count) then
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

procedure TMainForm.VirtualControllerPrepareRange(Sender: TObject; AFirstSourceRow, ACount: Int64; AQueryGeneration: Int64);
begin
  StatusLabel.Caption := Format('Viewport-Anfrage: %d..%d, QueryGeneration %d, Gesamt %d',
    [AFirstSourceRow, AFirstSourceRow + ACount - 1, AQueryGeneration, FRows.Count]
  );
end;

procedure TMainForm.VirtualControllerSetValue(Sender: TObject; ASourceRowIndex: Int64; const AFieldName: string; const AValue: TValue; var AHandled: Boolean);
var
  LRow: TLiveRow;
begin
  AHandled := False;
  if (ASourceRowIndex < 0) or (ASourceRowIndex >= FRows.Count) then
    Exit;
  LRow := FRows[ASourceRowIndex];

  if SameText(AFieldName, 'ACK') then
  begin
    LRow.Acknowledged := AValue.AsBoolean;
    AHandled := True;
  end
  else if SameText(AFieldName, 'MESSAGE') then
  begin
    LRow.MessageText := AValue.ToString;
    AHandled := True;
  end;
end;

end.
