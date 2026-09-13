unit h5u.Grid.Navigation;

{$IFDEF FPC}
  {$MODE OBJFPC}{$H+}
  {$MODESWITCH ADVANCEDRECORDS}
  {$CODEPAGE UTF8}
{$ENDIF}

interface

{$SCOPEDENUMS ON}

uses
  {$IFDEF FPC}
    h5u.Grid.Compat,
    Classes,
    DateUtils,
    Generics.Collections,
    Math,
    SysUtils,
  {$ELSE}
    System.Classes,
    System.DateUtils,
    System.Generics.Collections,
    System.Math,
    System.SysUtils,
    System.UITypes,
  {$ENDIF}
  h5u.Grid.Columns,
  h5u.Grid.Selection,
  h5u.Grid.Types;

type
  Th5uNavigationGetRowKey = function(ARow: Int64): Th5uRowKey of object;
  Th5uNavigationRowExtent = function(ARow: Int64): Double of object;
  Th5uNavigationPrepareRange = procedure(AFirst, ACount: Int64) of object;
  Th5uNavigationGetText = function(AColumn: Th5uGridColumn; ARow: Int64; ADisplay: Boolean): string of object;
  Th5uNavigationTryFocus = function(const ACell: Th5uCellAddress; AUpdateAnchor: Boolean): Boolean of object;

  Th5uNavigationActionKind = (None, Focus, Edit, Header);
  Th5uNavigationAction = record
    Kind: Th5uNavigationActionKind;
    Cell: Th5uCellAddress;
    Extend, Add, AutomaticEdit, EditAfterFocus: Boolean;
  end;

  // This state belongs to one grid view, independently of its shared data controller.
  Th5uGridNavigation = record
    HeaderSelectionActive: Boolean;
    HeaderSelectionKind: Th5uSelectionKind;
    HeaderAnchor, HeaderFocus: Th5uCellAddress;
    SearchText: string;
    SearchTime: TDateTime;
    procedure Cancel(ASelection: Th5uGridSelection);
    procedure SelectHeaderRange(AColumns: Th5uGridColumns; ASelection: Th5uGridSelection; ARowCount: Int64; AGetRowKey: Th5uNavigationGetRowKey; AKind: Th5uSelectionKind;
      ARow: Int64; AColumn: Integer; AShift: TShiftState);
    function Navigate(AColumns: Th5uGridColumns; ASelection: Th5uGridSelection; ARowCount: Int64; AGetRowKey: Th5uNavigationGetRowKey; ARowExtent: Th5uNavigationRowExtent;
      APageHeight: Double; AKey: Word; AShift: TShiftState; out AAction: Th5uNavigationAction): Boolean;
    function SearchCharacter(AColumns: Th5uGridColumns; ASelection: Th5uGridSelection; ARowCount: Int64; APrepareRange: Th5uNavigationPrepareRange; AGetText: Th5uNavigationGetText;
      AChar: Char; ANow: TDateTime; out ARow: Int64; out AColumn: Integer): Boolean;
  end;

function h5uPlanCellFocus(AColumns: Th5uGridColumns; ASelection: Th5uGridSelection; ARowCount: Int64; AGetRowKey: Th5uNavigationGetRowKey; ARow: Int64; AColumn: Integer;
  AExtend: Boolean; out ACell: Th5uCellAddress; out ARange: Th5uCellRange): Boolean;
procedure h5uSelectRightClick(ASelection: Th5uGridSelection; const ACell: Th5uCellAddress; ACanSelect: Boolean; ATryFocus: Th5uNavigationTryFocus);
procedure h5uNotifyFocusChange(AGrid: TObject; AColumns: Th5uGridColumns; const AOld, ANew: Th5uCellAddress; AExit, AEnter: Th5uCellEvent; AChanged: TNotifyEvent);

implementation

procedure Th5uGridNavigation.Cancel(ASelection: Th5uGridSelection);
begin
  SearchText := '';
  HeaderSelectionActive := False;
  ASelection.ClearExtendedSelection;
end;

procedure Th5uGridNavigation.SelectHeaderRange(AColumns: Th5uGridColumns; ASelection: Th5uGridSelection; ARowCount: Int64;
  AGetRowKey: Th5uNavigationGetRowKey; AKind: Th5uSelectionKind; ARow: Int64; AColumn: Integer; AShift: TShiftState);
var
  LColumns: {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uGridColumn>;
  LKeys: {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uRowKey>;
  LIds: {$IFDEF FPC}specialize {$ENDIF}TList<string>;
  LRow, LFirstRow, LLastRow: Int64;
  I, LAnchorColumn: Integer;
  LExtend: Boolean;
begin
  if not (AKind in ASelection.AllowedKinds) then
    Exit;
  LColumns := AColumns.VisibleColumns;
  if AKind = Th5uSelectionKind.Rows then
  begin
    if (ARow < 0) or (ARow >= ARowCount) then
      Exit;
  end
  else if (AColumn < 0) or (AColumn >= Length(LColumns)) then
    Exit
  else if not LColumns[AColumn].CanSelect then
    Exit;

  LExtend := (ssShift in AShift) and HeaderSelectionActive and (HeaderSelectionKind = AKind);
  if not LExtend then
    HeaderAnchor := Th5uCellAddress.Empty;
  HeaderSelectionActive := True;
  HeaderSelectionKind := AKind;
  HeaderFocus := Th5uCellAddress.Empty;
  if AKind = Th5uSelectionKind.Rows then
  begin
    HeaderFocus.RowIndex := ARow;
    HeaderFocus.RowKey := AGetRowKey(ARow);
    // A removed/replaced row must not leave an anchor pointing at another row.
    if (HeaderAnchor.RowIndex < 0) or (HeaderAnchor.RowIndex >= ARowCount) then
      HeaderAnchor := HeaderFocus
    else if AGetRowKey(HeaderAnchor.RowIndex) <> HeaderAnchor.RowKey then
      HeaderAnchor := HeaderFocus;
    if (ssCtrl in AShift) and not (ssShift in AShift) then
      ASelection.ToggleRow(HeaderFocus.RowKey)
    else
    begin
      LFirstRow := Min(HeaderAnchor.RowIndex, ARow);
      LLastRow := Max(HeaderAnchor.RowIndex, ARow);
      SetLength(LKeys, LLastRow - LFirstRow + 1);
      {$IFDEF FPC_old}
        // FOR with Int64?
        LRow := LFirstRow;
        while LRow <= LLastRow do
        begin
          LKeys[LRow - LFirstRow] := AGetRowKey(LRow);
          Inc(LRow);
        end;
      {$ELSE}
        for LRow := LFirstRow to LLastRow do
          LKeys[LRow - LFirstRow] := AGetRowKey(LRow);
      {$ENDIF}
      ASelection.SelectRows(LKeys, ssCtrl in AShift, LExtend);
    end;
  end
  else
  begin
    HeaderFocus.ColumnIndex := AColumn;
    HeaderFocus.ColumnId := LColumns[AColumn].Id;
    LAnchorColumn := -1;
    for I := 0 to High(LColumns) do
      if LColumns[I].Id = HeaderAnchor.ColumnId then
        LAnchorColumn := I;
    if LAnchorColumn < 0 then
    begin
      HeaderAnchor := HeaderFocus;
      LAnchorColumn := AColumn;
    end;
    if (ssCtrl in AShift) and not (ssShift in AShift) then
      ASelection.ToggleColumn(HeaderFocus.ColumnId)
    else
    begin
      LIds := {$IFDEF FPC}specialize {$ENDIF}TList<string>.Create;
      try
        for I := Min(LAnchorColumn, AColumn) to Max(LAnchorColumn, AColumn) do
          if LColumns[I].CanSelect then
            LIds.Add(LColumns[I].Id);
        ASelection.SelectColumns(LIds.ToArray, ssCtrl in AShift, LExtend);
      finally
        LIds.Free;
      end;
    end;
  end;
end;

function Th5uGridNavigation.Navigate(AColumns: Th5uGridColumns; ASelection: Th5uGridSelection; ARowCount: Int64; AGetRowKey: Th5uNavigationGetRowKey;
  ARowExtent: Th5uNavigationRowExtent; APageHeight: Double; AKey: Word; AShift: TShiftState; out AAction: Th5uNavigationAction): Boolean;
var
  LCell: Th5uCellAddress;
  LColumns: {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uGridColumn>;
  LRow, LCount: Int64;
  LColumn: Integer;
  LDistance: Double;
begin
  AAction := Default(Th5uNavigationAction);
  Result := False;
  if ssAlt in AShift then
    Exit;
  if not (AKey in [vkLeft, vkRight, vkUp, vkDown, vkPrior, vkNext, vkHome, vkEnd, vkF2]) then
    Exit;
  Result := True;
  SearchText := '';
  LCount := ARowCount;
  LColumns := AColumns.VisibleColumns;
  if (LCount = 0) or (Length(LColumns) = 0) then
    Exit;
  LCell := ASelection.FocusedCell;
  if HeaderSelectionActive and (ssShift in AShift) and (AKey <> vkF2) then
  begin
    if not LCell.IsValid then
    begin
      LCell.RowIndex := 0;
      LCell.ColumnIndex := 0;
    end;
    if HeaderSelectionKind = Th5uSelectionKind.Rows then
      LCell.RowIndex := HeaderFocus.RowIndex
    else
      LCell.ColumnIndex := HeaderFocus.ColumnIndex;
    LCell.RowIndex := EnsureRange(LCell.RowIndex, Int64(0), LCount - 1);
    LCell.ColumnIndex := EnsureRange(LCell.ColumnIndex, 0, High(LColumns));
    LCell.RowKey := AGetRowKey(LCell.RowIndex);
    LCell.ColumnId := LColumns[LCell.ColumnIndex].Id;
  end;
  if not LCell.IsValid then
  begin
    AAction.Kind := Th5uNavigationActionKind.Focus;
    AAction.AutomaticEdit := AKey <> vkF2;
    AAction.EditAfterFocus := AKey = vkF2;
    Exit;
  end;
  LRow := EnsureRange(LCell.RowIndex, Int64(0), LCount - 1);
  LColumn := EnsureRange(LCell.ColumnIndex, 0, High(LColumns));
  case AKey of
    vkLeft:  Dec(LColumn);
    vkRight: Inc(LColumn);
    vkUp:    Dec(LRow);
    vkDown:  Inc(LRow);
    vkHome:
    begin
      LColumn := 0;
      if ssCtrl in AShift then
        LRow := 0;
    end;
    vkEnd:
    begin
      LColumn := High(LColumns);
      if ssCtrl in AShift then
        LRow := LCount - 1;
    end;
    vkPrior, vkNext:
    begin
      LDistance := 0;
      repeat
        LDistance := LDistance + ARowExtent(LRow);
        if AKey = vkPrior then
          Dec(LRow)
        else
          Inc(LRow);
      until (LRow <= 0) or (LRow >= LCount - 1) or (LDistance >= APageHeight);
    end;
    vkF2:
    begin
      AAction.Kind := Th5uNavigationActionKind.Edit;
      Exit;
    end;
  end;
  if HeaderSelectionActive and (ssShift in AShift) then
  begin
    LCell.RowIndex := EnsureRange(LRow, Int64(0), LCount - 1);
    LCell.ColumnIndex := EnsureRange(LColumn, 0, High(LColumns));
    LCell.RowKey := AGetRowKey(LCell.RowIndex);
    LCell.ColumnId := LColumns[LCell.ColumnIndex].Id;
    AAction.Kind := Th5uNavigationActionKind.Header;
    AAction.Cell := LCell;
  end
  else
  begin
    AAction.Kind := Th5uNavigationActionKind.Focus;
    AAction.Cell.RowIndex := LRow;
    AAction.Cell.ColumnIndex := LColumn;
    AAction.Extend := ssShift in AShift;
    AAction.Add := (ssCtrl in AShift) and (ssShift in AShift);
    AAction.AutomaticEdit := True;
  end;
end;

function Th5uGridNavigation.SearchCharacter(AColumns: Th5uGridColumns; ASelection: Th5uGridSelection; ARowCount: Int64; APrepareRange: Th5uNavigationPrepareRange;
  AGetText: Th5uNavigationGetText; AChar: Char; ANow: TDateTime; out ARow: Int64; out AColumn: Integer): Boolean;
var
  LColumns: {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uGridColumn>;
  LCell: Th5uCellAddress;
  LCount, LRow, LStart, I: Int64;
  LColumn: Integer;
  LText: string;
  LContinue: Boolean;
begin
  Result := False;
  ARow := -1;
  AColumn := -1;
  if AChar < #32 then
    Exit;
  LCount := ARowCount;
  LColumns := AColumns.VisibleColumns;
  if (LCount = 0) or (Length(LColumns) = 0) then
    Exit;
  LCell := ASelection.FocusedCell;
  LColumn := EnsureRange(LCell.ColumnIndex, 0, High(LColumns));
  LContinue := (SearchText <> '') and ((ANow - SearchTime) * MSecsPerDay < 1000);
  if not LContinue then
    SearchText := '';
  SearchText := SearchText + AChar;
  SearchTime := ANow;
  LStart := Max(Int64(0), LCell.RowIndex);
  if LCell.IsValid and not LContinue then
    LStart := (LStart + 1) mod LCount;
  {$IFDEF FPC_old}
  // FOR with Int64
  I := 0;
  while I < LCount do
  {$ELSE}
  for I := 0 to LCount - 1 do
  {$ENDIF}
  begin
    LRow := (LStart + I) mod LCount;
    APrepareRange(LRow, 1);
    LText := AGetText(LColumns[LColumn], LRow, True);
    if SameText(Copy(LText, 1, Length(SearchText)), SearchText) then
    begin
      ARow := LRow;
      AColumn := LColumn;
      Result := True;
      Exit;
    end;
    {$IFDEF FPC_old}
    Inc(I);
    {$ENDIF}
  end;
end;

function h5uPlanCellFocus(AColumns: Th5uGridColumns; ASelection: Th5uGridSelection; ARowCount: Int64; AGetRowKey: Th5uNavigationGetRowKey;
  ARow: Int64; AColumn: Integer; AExtend: Boolean; out ACell: Th5uCellAddress; out ARange: Th5uCellRange): Boolean;
var
  LColumns: {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uGridColumn>;
begin
  Result := False;
  if (ARowCount = 0) then
    Exit;
  LColumns := AColumns.VisibleColumns;
  if Length(LColumns) = 0 then
    Exit;
  ACell.RowIndex := EnsureRange(ARow, Int64(0), ARowCount - 1);
  ACell.ColumnIndex := EnsureRange(AColumn, 0, High(LColumns));
  ACell.RowKey := AGetRowKey(ACell.RowIndex);
  ACell.ColumnId := LColumns[ACell.ColumnIndex].Id;
  if AExtend and ASelection.AnchorCell.IsValid then
    ARange := Th5uCellRange.Create(ASelection.AnchorCell.RowIndex, ACell.RowIndex, ASelection.AnchorCell.ColumnIndex, ACell.ColumnIndex)
  else
    ARange := Th5uCellRange.Create(ACell.RowIndex, ACell.RowIndex, ACell.ColumnIndex, ACell.ColumnIndex);
  Result := True;
end;

procedure h5uSelectRightClick(ASelection: Th5uGridSelection; const ACell: Th5uCellAddress; ACanSelect: Boolean; ATryFocus: Th5uNavigationTryFocus);
var
  LSelected: Boolean;
begin
  if not ASelection.RightClickSelect then
    Exit;
  LSelected := ASelection.IsCellSelected(ACell.RowIndex, ACell.ColumnIndex)
    or ASelection.IsRowSelected(ACell.RowKey) or ASelection.IsColumnSelected(ACell.ColumnId);
  if not ATryFocus(ACell, not LSelected) then
    Exit;
  if not LSelected and ACanSelect then
    ASelection.AddCellRange(Th5uCellRange.Create(ACell.RowIndex, ACell.RowIndex, ACell.ColumnIndex, ACell.ColumnIndex));
end;

procedure h5uNotifyFocusChange(AGrid: TObject; AColumns: Th5uGridColumns; const AOld, ANew: Th5uCellAddress; AExit, AEnter: Th5uCellEvent; AChanged: TNotifyEvent);
var
  LColumn: Th5uGridColumn;
begin
  if (AOld.RowIndex <> ANew.RowIndex) or (AOld.ColumnId <> ANew.ColumnId) or (AOld.RowKey <> ANew.RowKey) then
  begin
    if AOld.IsValid then
    begin
      LColumn := AColumns.FindById(AOld.ColumnId);
      if Assigned(LColumn) and Assigned(LColumn.OnCellExit) then
        LColumn.OnCellExit(LColumn, LColumn, AOld.RowIndex);
      if Assigned(AExit) then
        AExit(AGrid, LColumn, AOld.RowIndex);
    end;
    if ANew.IsValid then
    begin
      LColumn := AColumns.FindById(ANew.ColumnId);
      if Assigned(LColumn) and Assigned(LColumn.OnCellEnter) then
        LColumn.OnCellEnter(LColumn, LColumn, ANew.RowIndex);
      if Assigned(AEnter) then
        AEnter(AGrid, LColumn, ANew.RowIndex);
    end;
  end;
  if Assigned(AChanged) then
    AChanged(AGrid);
end;

end.
