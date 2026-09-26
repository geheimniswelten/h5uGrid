unit h5u.Grid.Moving;

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
    Math,
    SysUtils,
  {$ELSE}
    System.Classes,
    System.Math,
    System.SysUtils,
  {$ENDIF}
  h5u.Grid.Columns,
  h5u.Grid.Options,
  h5u.Grid.Selection,
  h5u.Grid.Types;

// Plans contain model identities only. Capture, hit testing and painting stay in the control.
type
  Th5uMoveGetRowKey = function(ARow: Int64): Th5uRowKey of object;
  Th5uMoveGetSourceRow = function(ARow: Int64): Int64 of object;

  Th5uColumnMovePlan = record
    Columns: {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uGridColumn>;
    HeaderCell: Th5uHeaderLayoutCell;
    Caption: string;
  end;

  Th5uRowMovePlan = record
    RowKeys: {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uRowKey>;
    FirstRowIndex: Int64;
  end;

function h5uCanMoveColumn(AColumns: Th5uGridColumns; AAllowByDefault: Boolean; AColumn: Th5uGridColumn): Boolean;
function h5uMoveGestureAllowed(AEnabled, AAltDrag: Boolean; AShift: TShiftState; ATouchWithoutAlt: Boolean = False): Boolean;
function h5uPlanColumnMove(AColumns: Th5uGridColumns; AHeaderLayout: Th5uHeaderLayout; ASelection: Th5uGridSelection; ACustomization: Th5uCustomizationOptions;
  AColumnIndex: Integer; AHeaderCell: Th5uHeaderLayoutCell; out APlan: Th5uColumnMovePlan): Boolean;
function h5uColumnMoveTarget(AColumns: Th5uGridColumns; AHeaderLayout: Th5uHeaderLayout; ACustomization: Th5uCustomizationOptions;
  const AMovingColumns: {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uGridColumn>; AMovingHeader: Th5uHeaderLayoutCell; ATargetColumn: Th5uGridColumn;
  ATargetIndex: Integer; ATargetHeader: Th5uHeaderLayoutCell; out ANewIndex: Integer; out AInsertAfter: Boolean): Boolean;
function h5uPlanRowMove(ASelection: Th5uGridSelection; ARowIndex, ARowCount: Int64; AGetRowKey: Th5uMoveGetRowKey; out APlan: Th5uRowMovePlan): Boolean;
function h5uRowMoveTarget(ARowCount, ATargetRowIndex: Int64; const ATargetRowKey: Th5uRowKey; AGetRowKey: Th5uMoveGetRowKey; AGetSourceRow: Th5uMoveGetSourceRow;
  var AContext: Th5uRowsMovedContext): Boolean;

implementation

function h5uCanMoveColumn(AColumns: Th5uGridColumns; AAllowByDefault: Boolean; AColumn: Th5uGridColumn): Boolean;
var
  I: Integer;
begin
  Result := False;
  // The source column may have been removed while the mouse was captured.
  for I := 0 to AColumns.Count - 1 do
    if AColumns[I] = AColumn then
    begin
      case AColumn.MovePermission of
        Th5uColumnMovePermission.Default: Result := AAllowByDefault;
        Th5uColumnMovePermission.Allow: Result := True;
        Th5uColumnMovePermission.Deny: Result := False;
      end;
      Exit;
    end;
end;

function h5uMoveGestureAllowed(AEnabled, AAltDrag: Boolean; AShift: TShiftState; ATouchWithoutAlt: Boolean = False): Boolean;
begin
  Result := AEnabled and (AShift * [ssCtrl, ssShift] = []) and (ATouchWithoutAlt or (AAltDrag = (ssAlt in AShift)));
end;

function h5uPlanColumnMove(AColumns: Th5uGridColumns; AHeaderLayout: Th5uHeaderLayout; ASelection: Th5uGridSelection; ACustomization: Th5uCustomizationOptions;
  AColumnIndex: Integer; AHeaderCell: Th5uHeaderLayoutCell; out APlan: Th5uColumnMovePlan): Boolean;
var
  LColumns: {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uGridColumn>;
  LFirst, LLast, I: Integer;
begin
  APlan := Default(Th5uColumnMovePlan);
  Result := False;
  LColumns := AColumns.VisibleColumns;
  if (AColumnIndex < 0) or (AColumnIndex >= Length(LColumns)) then
    Exit;
  LFirst := AColumnIndex;
  LLast := LFirst;
  if Assigned(AHeaderCell) and (AHeaderCell.ColumnSpan > 1) then
  begin
    if not AHeaderLayout.ColumnRange(AHeaderCell, LColumns, LFirst, LLast) then
      Exit;
  end
  else
  if ASelection.IsColumnSelected(LColumns[LFirst].Id) then
  begin
    while (LFirst > 0) and ASelection.IsColumnSelected(LColumns[LFirst - 1].Id) do
      Dec(LFirst);
    while (LLast < High(LColumns)) and ASelection.IsColumnSelected(LColumns[LLast + 1].Id) do
      Inc(LLast);
    // Include the entire selected block or do not start at all (also for hidden selections).
    if LLast - LFirst + 1 <> ASelection.SelectedColumnCount then
      Exit;
  end;
  for I := LFirst to LLast do
    if not h5uCanMoveColumn(AColumns, ACustomization.AllowColumnMoving, LColumns[I]) or (LColumns[I].FixedKind <> LColumns[LFirst].FixedKind) then
      Exit;
  if Assigned(AHeaderCell) then
    for I := 0 to AColumns.Count - 1 do
      if AHeaderLayout.MovesWithColumns(AColumns[I], LColumns, LFirst, LLast - LFirst + 1)
        and (not h5uCanMoveColumn(AColumns, ACustomization.AllowColumnMoving, AColumns[I]) or (AColumns[I].FixedKind <> LColumns[LFirst].FixedKind))
      then
        Exit;
  APlan.HeaderCell := AHeaderCell;
  APlan.Columns := Copy(LColumns, LFirst, LLast - LFirst + 1);
  APlan.Caption := LColumns[LFirst].Caption;
  if LLast > LFirst then
    APlan.Caption := APlan.Caption + Format(' (+%d)', [LLast - LFirst]);
  if Assigned(AHeaderCell) and (AHeaderCell.ColumnSpan > 1) then
    APlan.Caption := AHeaderCell.Caption;
  Result := True;
end;

function h5uColumnMoveTarget(AColumns: Th5uGridColumns; AHeaderLayout: Th5uHeaderLayout; ACustomization: Th5uCustomizationOptions;
  const AMovingColumns: {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uGridColumn>; AMovingHeader: Th5uHeaderLayoutCell; ATargetColumn: Th5uGridColumn;
  ATargetIndex: Integer; ATargetHeader: Th5uHeaderLayoutCell; out ANewIndex: Integer; out AInsertAfter: Boolean): Boolean;
var
  LColumns: {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uGridColumn>;
  LFirst, LTargetFirst, LTargetLast, I: Integer;
begin
  Result := False;
  ANewIndex := -1;
  AInsertAfter := False;
  if (Length(AMovingColumns) = 0) or not Assigned(ATargetColumn) then
    Exit;
  if Assigned(AMovingHeader) and (not AHeaderLayout.Enabled or not AHeaderLayout.ContainsCell(AMovingHeader)) then
    Exit;
  LColumns := AColumns.VisibleColumns;
  LFirst := -1;
  for I := 0 to High(LColumns) do
    if LColumns[I] = AMovingColumns[0] then
      LFirst := I;
  if (LFirst < 0) or (LFirst + Length(AMovingColumns) > Length(LColumns)) then
    Exit;
  for I := 0 to High(AMovingColumns) do
  begin
    if LColumns[LFirst + I] <> AMovingColumns[I] then
      Exit;
    if not h5uCanMoveColumn(AColumns, ACustomization.AllowColumnMoving, AMovingColumns[I]) then
      Exit;
    if AMovingColumns[I].FixedKind <> ATargetColumn.FixedKind then
      Exit;
  end;
  if Assigned(AMovingHeader) then
    for I := 0 to AColumns.Count - 1 do
      if AHeaderLayout.MovesWithColumns(AColumns[I], LColumns, LFirst, Length(AMovingColumns))
        and (not h5uCanMoveColumn(AColumns, ACustomization.AllowColumnMoving, AColumns[I]) or (AColumns[I].FixedKind <> LColumns[LFirst].FixedKind))
      then
        Exit;
  LTargetFirst := ATargetIndex;
  LTargetLast := LTargetFirst;
  if Assigned(AMovingHeader) then
  begin
    if not Assigned(ATargetHeader) then
      Exit;
    if AMovingHeader.ColumnSpan > 1 then
    begin
      if ATargetHeader.LayoutRow <> AMovingHeader.LayoutRow then
        Exit;
    end
    else
    if (ATargetHeader.ColumnSpan > 1) or (ATargetHeader.LayoutRow >= AMovingHeader.LayoutRow + Max(1, AMovingHeader.RowSpan))
      or (AMovingHeader.LayoutRow >= ATargetHeader.LayoutRow + Max(1, ATargetHeader.RowSpan))
    then
      Exit;
    if not AHeaderLayout.ColumnRange(ATargetHeader, LColumns, LTargetFirst, LTargetLast) then
      Exit;
  end;
  if (LTargetFirst < LFirst + Length(AMovingColumns)) and (LTargetLast >= LFirst) then
    Exit;
  ANewIndex := LTargetFirst;
  if LTargetFirst > LFirst then
  begin
    ANewIndex := LTargetLast + 1 - Length(AMovingColumns);
    AInsertAfter := True;
  end;
  if AHeaderLayout.Enabled and not AHeaderLayout.CanMoveColumns(LColumns, LFirst, Length(AMovingColumns), ANewIndex) then
    Exit;
  Result := True;
end;

function h5uPlanRowMove(ASelection: Th5uGridSelection; ARowIndex, ARowCount: Int64; AGetRowKey: Th5uMoveGetRowKey; out APlan: Th5uRowMovePlan): Boolean;
var
  LFirst, LLast, LCount, LSelectedCount: Int64;
  I: Integer;
begin
  APlan := Default(Th5uRowMovePlan);
  Result := False;
  LCount := ARowCount;
  if (ARowIndex < 0) or (ARowIndex >= LCount) then
    Exit;
  LFirst := ARowIndex;
  LLast := LFirst;
  if ASelection.IsRowSelected(AGetRowKey(LFirst)) then
  begin
    LSelectedCount := ASelection.SelectedRowCount(LCount);
    if (LSelectedCount >= LCount) or (LSelectedCount <= 0) then
      Exit;
    // Visit only the selected neighbours. Virtual grids must not scan every row.
    while (LFirst > 0) and ASelection.IsRowSelected(AGetRowKey(LFirst - 1)) do
      Dec(LFirst);
    while (LLast < LCount - 1) and ASelection.IsRowSelected(AGetRowKey(LLast + 1)) do
      Inc(LLast);
    if LLast - LFirst + 1 <> LSelectedCount then
      Exit;
  end;
  if LLast - LFirst >= MaxInt then
    Exit;
  SetLength(APlan.RowKeys, LLast - LFirst + 1);
  for I := 0 to High(APlan.RowKeys) do
  begin
    APlan.RowKeys[I] := AGetRowKey(LFirst + I);
    if APlan.RowKeys[I].IsEmpty then
    begin
      APlan.RowKeys := nil;
      Exit;
    end;
  end;
  APlan.FirstRowIndex := LFirst;
  Result := True;
end;

function h5uRowMoveTarget(ARowCount, ATargetRowIndex: Int64; const ATargetRowKey: Th5uRowKey;
  AGetRowKey: Th5uMoveGetRowKey; AGetSourceRow: Th5uMoveGetSourceRow; var AContext: Th5uRowsMovedContext): Boolean;
var
  I: Integer;
begin
  Result := False;
  if (Length(AContext.RowKeys) = 0) or (ATargetRowIndex < 0) or (ATargetRowIndex >= ARowCount) then
    Exit;
  if (AContext.FirstRowIndex < 0) or (AContext.FirstRowIndex + Length(AContext.RowKeys) > ARowCount) then
    Exit;
  if (ATargetRowIndex >= AContext.FirstRowIndex) and (ATargetRowIndex < AContext.FirstRowIndex + Length(AContext.RowKeys)) then
    Exit;
  SetLength(AContext.SourceRowIndexes, Length(AContext.RowKeys));
  for I := 0 to High(AContext.RowKeys) do
  begin
    // A live sort/filter or removed row invalidates the original drag range.
    if AGetRowKey(AContext.FirstRowIndex + I) <> AContext.RowKeys[I] then
      Exit;
    AContext.SourceRowIndexes[I] := AGetSourceRow(AContext.FirstRowIndex + I);
  end;
  AContext.TargetRowIndex := ATargetRowIndex;
  AContext.TargetRowKey := ATargetRowKey;
  AContext.TargetSourceRowIndex := AGetSourceRow(ATargetRowIndex);
  AContext.InsertAfter := ATargetRowIndex > AContext.FirstRowIndex;
  AContext.NewFirstRowIndex := ATargetRowIndex;
  if AContext.InsertAfter then
    Dec(AContext.NewFirstRowIndex, Length(AContext.RowKeys) - 1);
  Result := True;
end;

end.

