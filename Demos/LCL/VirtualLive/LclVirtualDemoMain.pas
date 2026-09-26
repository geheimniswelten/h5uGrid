unit LclVirtualDemoMain;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

{$SCOPEDENUMS ON}

uses
  Classes,
  Generics.Collections,
  Rtti,
  Math,
  SysUtils,
  Controls,
  ExtCtrls,
  Forms,
  StdCtrls,
  h5u.Grid.Data.Core,
  h5u.Grid.Data.Virtual,
  h5u.Grid.Types,
  Lcl.h5u.Grid;

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

  TLclVirtualDemoForm = class(TForm)
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
    Grid: Th5uLclGrid;
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
    FRows: specialize TObjectList<TLiveRow>;
    FNextId: Int64;
    procedure AppendLiveRow;
    procedure ApplyOptions;
  end;

var
  LclVirtualDemoForm: TLclVirtualDemoForm;

implementation

{$R *.lfm}

uses
  h5u.Grid.Compat;

procedure TLclVirtualDemoForm.AppendButtonClick(Sender: TObject);
begin
  AppendLiveRow;
end;

procedure TLclVirtualDemoForm.AppendLiveRow;
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
    LRow.MessageText := 'Längerer Live-Text für AutoHeight: Der Wert stammt direkt ' + 'aus dem OnGetValue-Ereignis und existiert nicht als '
      + 'Grid-Datensatzobjekt.'
  else
    LRow.MessageText := Format('Live-Ereignis Nummer %d wurde empfangen.', [FNextId]);

  LIndex := FRows.Count;
  FRows.Add(LRow);
  VirtualController.NotifyRowsInserted(LIndex, 1);
  StatusLabel.Caption := Format('%d Live-Datensätze; letzte ID %d', [FRows.Count, FNextId]);
end;

procedure TLclVirtualDemoForm.ApplyOptions;
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

procedure TLclVirtualDemoForm.ClearButtonClick(Sender: TObject);
begin
  FRows.Clear;
  VirtualController.NotifyReset;
  StatusLabel.Caption := 'Keine Live-Datensätze';
end;

procedure TLclVirtualDemoForm.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  FRows := specialize TObjectList<TLiveRow>.Create(True);
  for I := 1 to 60 do
    AppendLiveRow;
  ApplyOptions;
end;

procedure TLclVirtualDemoForm.FormDestroy(Sender: TObject);
begin
  if Assigned(LiveTimer) then
    LiveTimer.Enabled := False;
  if Assigned(Grid) then
    Grid.DataController := nil;
  FreeAndNil(FRows);
end;

procedure TLclVirtualDemoForm.LiveTimerTimer(Sender: TObject);
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

procedure TLclVirtualDemoForm.NextPageButtonClick(Sender: TObject);
var
  LPageCount: Integer;
begin
  if VirtualController.Pagination.Mode <> Th5uPaginationMode.NumberedPages then
    Exit;

  LPageCount := (FRows.Count + VirtualController.Pagination.PageSize - 1) div VirtualController.Pagination.PageSize;

  VirtualController.Pagination.PageIndex := (VirtualController.Pagination.PageIndex + 1) mod Math.Max(1, LPageCount);
end;

procedure TLclVirtualDemoForm.OptionClick(Sender: TObject);
begin
  ApplyOptions;
end;

procedure TLclVirtualDemoForm.VirtualControllerGetRowCount(Sender: TObject; var ARowCount: Int64);
begin
  // Streaming/Loaded may request data before FormCreate initializes FRows.
  ARowCount := 0;
  if Assigned(FRows) then
    ARowCount := FRows.Count;
end;

procedure TLclVirtualDemoForm.VirtualControllerGetRowKey(Sender: TObject; ASourceRowIndex: Int64; var ARowKey: Th5uRowKey);
begin
  if not Assigned(FRows) then
    Exit;
  if (ASourceRowIndex >= 0) and (ASourceRowIndex < FRows.Count) then
    ARowKey := Th5uRowKey.FromInt64(FRows[ASourceRowIndex].Id);
end;

procedure TLclVirtualDemoForm.VirtualControllerGetValue(Sender: TObject; ASourceRowIndex: Int64; const AFieldName: string; var AValue: TValue);
var
  LRow: TLiveRow;
begin
  if not Assigned(FRows) then
    Exit;
  if (ASourceRowIndex < 0) or (ASourceRowIndex >= FRows.Count) then
    Exit;

  LRow := FRows[ASourceRowIndex];
  if SameText(AFieldName, 'ID') then
    AValue := TValue.specialize From<Int64>(LRow.Id)
  else if SameText(AFieldName, 'TIMESTAMP') then
    AValue := TValue.specialize From<TDateTime>(LRow.Timestamp)
  else if SameText(AFieldName, 'SOURCE') then
    AValue := TValue.specialize From<string>(LRow.Source)
  else if SameText(AFieldName, 'MESSAGE') then
    AValue := TValue.specialize From<string>(LRow.MessageText)
  else if SameText(AFieldName, 'SEVERITY') then
    AValue := TValue.specialize From<Integer>(LRow.Severity)
  else if SameText(AFieldName, 'ACK') then
    AValue := TValue.specialize From<Boolean>(LRow.Acknowledged);
end;

procedure TLclVirtualDemoForm.VirtualControllerPrepareRange(Sender: TObject; AFirstSourceRow, ACount: Int64; AQueryGeneration: Int64);
begin
  if not Assigned(FRows) or not Assigned(StatusLabel) then
    Exit;
  StatusLabel.Caption := Format('Viewport-Anfrage: %d..%d, QueryGeneration %d, Gesamt %d', [AFirstSourceRow, AFirstSourceRow + ACount
    - 1, AQueryGeneration, FRows.Count]);
end;

procedure TLclVirtualDemoForm.VirtualControllerSetValue(Sender: TObject; ASourceRowIndex: Int64; const AFieldName: string; const AValue: TValue; var AHandled: Boolean);
var
  LRow: TLiveRow;
begin
  AHandled := False;
  if not Assigned(FRows) then
    Exit;
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
    LRow.MessageText := h5uValueAsText(AValue);
    AHandled := True;
  end;
end;

end.
