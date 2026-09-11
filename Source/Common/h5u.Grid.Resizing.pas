unit h5u.Grid.Resizing;

interface

uses
  System.Classes,
  System.Math,
  h5u.Grid.Columns,
  h5u.Grid.Options;

type
  Th5uResizeCandidate = record
    Column: Th5uGridColumn;
    VisibleIndex: Integer;
    Right, ViewLeft, ViewRight: Double;
  end;

  Th5uResizeHeaderEdgeTest = function(AX, AY: Double): Boolean of object;

function h5uColumnResizeAt(AOptions: Th5uCustomizationOptions; const ACandidates: TArray<Th5uResizeCandidate>; ALastVisibleIndex: Integer; X, Y: Double; ATouch: Boolean;
  AHeaderEdge: Th5uResizeHeaderEdgeTest): Th5uGridColumn;
function h5uTryResizeColumn(AColumns: Th5uGridColumns; AColumn: Th5uGridColumn; AOriginalWidth, ADelta: Integer): Boolean;

implementation

function h5uColumnResizeAt(AOptions: Th5uCustomizationOptions; const ACandidates: TArray<Th5uResizeCandidate>; ALastVisibleIndex: Integer; X, Y: Double; ATouch: Boolean;
  AHeaderEdge: Th5uResizeHeaderEdgeTest): Th5uGridColumn;
var
  LInfo: Th5uResizeCandidate;
  LLeft, LRight, LLastLeft, LEffectiveLeft, LDelta, LDistance, LBest: Double;
begin
  Result := nil;
  if not AOptions.AllowColumnResizing then
    Exit;
  if ATouch then
  begin
    LLeft := AOptions.TouchColumnResizeHitZoneLeft;
    LRight := AOptions.TouchColumnResizeHitZoneRight;
    LLastLeft := AOptions.TouchLastColumnResizeHitZoneLeft;
  end
  else
  begin
    LLeft := AOptions.ColumnResizeHitZoneLeft;
    LRight := AOptions.ColumnResizeHitZoneRight;
    LLastLeft := AOptions.LastColumnResizeHitZoneLeft;
  end;
  LBest := Max(LLeft, LRight);
  for LInfo in ACandidates do
  begin
    if not Assigned(LInfo.Column) or not LInfo.Column.CanResize then
      Continue;
    LEffectiveLeft := LLeft;
    // The final visible model column can be outside the scrolled viewport.
    if (LInfo.VisibleIndex = ALastVisibleIndex) and (LLastLeft >= 0) then
      LEffectiveLeft := LLastLeft;
    LDelta := X - LInfo.Right;
    if (LDelta < -LEffectiveLeft) or (LDelta > LRight) then
      Continue;
    if Assigned(AHeaderEdge) and not AHeaderEdge(LInfo.Right, Y) then
      Continue;
    LDistance := Abs(LDelta);
    if Assigned(Result) and (LDistance >= LBest) then
      Continue;
    // Clipping must not turn a viewport edge into a resize boundary.
    if (LInfo.Right <= LInfo.ViewLeft) or (LInfo.Right > LInfo.ViewRight) then
      Continue;
    Result := LInfo.Column;
    LBest := LDistance;
  end;
end;

function h5uTryResizeColumn(AColumns: Th5uGridColumns; AColumn: Th5uGridColumn; AOriginalWidth, ADelta: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  // Compare identities before reading a column that may have been removed during a drag.
  for I := 0 to AColumns.Count - 1 do
    if AColumns[I] = AColumn then
    begin
      if AColumn.Visible and AColumn.CanResize then
      begin
        AColumns.BeginUpdate;
        try
          AColumn.AutoWidth := False;
          AColumn.WidthInPercent := 0;
          AColumn.Width := AOriginalWidth + ADelta;
        finally
          AColumns.EndUpdate;
        end;
        Result := True;
      end;
      Exit;
    end;
end;

end.
