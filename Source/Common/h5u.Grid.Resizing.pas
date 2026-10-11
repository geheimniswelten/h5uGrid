unit h5u.Grid.Resizing;

{$IFDEF FPC}
  {$MODE OBJFPC}{$H+}
  {$MODESWITCH ADVANCEDRECORDS}
  {$CODEPAGE UTF8}
{$ENDIF}

interface

uses
  {$IFDEF FPC}
    h5u.Grid.Compat,
    Classes,
    Math,
  {$ELSE}
    System.Classes,
    System.Math,
  {$ENDIF}
  h5u.Grid.Columns,
  h5u.Grid.Options;

type
  Th5uResizeCandidate = record
    Column: ThiiGridColumn;
    VisibleIndex: Integer;
    Right, ViewLeft, ViewRight: Single;
  end;

  Th5uResizeHeaderEdgeTest = function(AX, AY: Single): Boolean of object;

function h5uColumnResizeAt(AOptions: ThiiCustomizationOptions; const ACandidates: {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uResizeCandidate>;
  ALastVisibleIndex: Integer; X, Y: Single; ATouch: Boolean; AHeaderEdge: Th5uResizeHeaderEdgeTest): ThiiGridColumn;
function h5uTryResizeColumn(AColumns: ThiiGridColumns; AColumn: ThiiGridColumn; AOriginalWidth, ADelta: Single): Boolean;

implementation

function h5uColumnResizeAt(AOptions: ThiiCustomizationOptions; const ACandidates: {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uResizeCandidate>;
  ALastVisibleIndex: Integer; X, Y: Single; ATouch: Boolean; AHeaderEdge: Th5uResizeHeaderEdgeTest): ThiiGridColumn;
var
  LInfo: Th5uResizeCandidate;
  LLeft, LRight, LLastLeft, LEffectiveLeft, LDelta, LDistance, LBest: Single;
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

function h5uTryResizeColumn(AColumns: ThiiGridColumns; AColumn: ThiiGridColumn; AOriginalWidth, ADelta: Single): Boolean;
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
          AColumn.Width := AColumn.ConstrainWidth(AOriginalWidth + ADelta);
        finally
          AColumns.EndUpdate;
        end;
        Result := True;
      end;
      Exit;
    end;
end;

end.

