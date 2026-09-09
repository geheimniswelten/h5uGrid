unit h5u.Grid.Layout;

interface

{$SCOPEDENUMS ON}

uses
  System.Classes,
  System.Math,
  h5u.Grid.AdjacentGroups,
  h5u.Grid.Columns,
  h5u.Grid.Options,
  h5u.Grid.Types,
  h5u.Grid.View;

type
  Th5uColumnLayoutInfo = record
    Column: Th5uGridColumn;
    VisibleIndex: Integer;
    Left, Right: Double;
    Visible: Boolean;
  end;

  Th5uRowSeparatorInfo = record
    Kind: Th5uElementKind;
    Height: Double;
    StyleName: string;
    TreeLevel, ClosedTreeLevels: Integer;
  end;

  Th5uRowSpacingMethod = function(ARow: Int64; const AKey: Th5uRowKey): Double of object;

function h5uColumnRightSpacing(AColumn: Th5uGridColumn; ADefault: Integer): Integer;
function h5uBuildColumnLayout(AColumns: Th5uGridColumns; ADefaultSpacing: Integer;
  AViewLeft, AViewRight, AIndicatorExtent, AHorizontalOffset: Double; AViewHasHeight: Boolean): TArray<Th5uColumnLayoutInfo>;
procedure h5uColumnViewport(AColumns: Th5uGridColumns; AColumn: Th5uGridColumn; ADefaultSpacing: Integer;
  AIndicatorExtent: Double; var ALeft, ARight: Double);
function h5uHeaderHeight(ALayout: Th5uHeaderLayout; AShowHeader: Boolean; ARowHeight, ASpacing: Double): Double;
function h5uRevealOffset(AOffset, AStart, ASize, AViewportSize: Double): Double;
function h5uRowSeparator(AView: Th5uGridView; ATree: Th5uTreeOptions; AGroups: Th5uAdjacentGroupFoldingOptions;
  ARow: Int64; const AKey: Th5uRowKey; AGetSpacing: Th5uRowSpacingMethod): Th5uRowSeparatorInfo;

implementation

function h5uColumnRightSpacing(AColumn: Th5uGridColumn; ADefault: Integer): Integer;
begin
  if Assigned(AColumn) and (AColumn.RightSpacing >= 0) then
    Result := AColumn.RightSpacing
  else
    Result := ADefault;
end;

function h5uBuildColumnLayout(AColumns: Th5uGridColumns; ADefaultSpacing: Integer;
  AViewLeft, AViewRight, AIndicatorExtent, AHorizontalOffset: Double; AViewHasHeight: Boolean): TArray<Th5uColumnLayoutInfo>;
var
  LColumns: TArray<Th5uGridColumn>;
  LDataLeft, LLeft, LRight, LNormal, LStart: Double;
  LSpacing, I: Integer;
begin
  LColumns := AColumns.VisibleColumns;
  SetLength(Result, Length(LColumns));
  LDataLeft := AViewLeft + AIndicatorExtent;
  LLeft := LDataLeft;
  LRight := AViewRight;
  for I := 0 to High(LColumns) do
    if LColumns[I].FixedKind = Th5uFixedKind.Left then
      LLeft := LLeft + LColumns[I].Width + h5uColumnRightSpacing(LColumns[I], ADefaultSpacing);
  for I := High(LColumns) downto 0 do
    if LColumns[I].FixedKind = Th5uFixedKind.Right then
      LRight := LRight - LColumns[I].Width - h5uColumnRightSpacing(LColumns[I], ADefaultSpacing);
  LNormal := LLeft - AHorizontalOffset;
  LLeft := LDataLeft;
  for I := 0 to High(LColumns) do
  begin
    LSpacing := h5uColumnRightSpacing(LColumns[I], ADefaultSpacing);
    case LColumns[I].FixedKind of
      Th5uFixedKind.Left:
        begin
          LStart := LLeft;
          LLeft := LLeft + LColumns[I].Width + LSpacing;
        end;
      Th5uFixedKind.Right:
        begin
          LStart := LRight;
          LRight := LRight + LColumns[I].Width + LSpacing;
        end;
      else
        begin
          LStart := LNormal;
          LNormal := LNormal + LColumns[I].Width + LSpacing;
        end;
    end;
    Result[I].Column := LColumns[I];
    Result[I].VisibleIndex := I;
    Result[I].Left := LStart;
    Result[I].Right := LStart + LColumns[I].Width;
    Result[I].Visible := AViewHasHeight and (LStart < AViewRight) and (Result[I].Right + LSpacing > AViewLeft);
  end;
end;

procedure h5uColumnViewport(AColumns: Th5uGridColumns; AColumn: Th5uGridColumn; ADefaultSpacing: Integer;
  AIndicatorExtent: Double; var ALeft, ARight: Double);
var
  LColumn: Th5uGridColumn;
begin
  ALeft := ALeft + AIndicatorExtent;
  if AColumn.FixedKind = Th5uFixedKind.None then
    for LColumn in AColumns.VisibleColumns do
      case LColumn.FixedKind of
        Th5uFixedKind.Left:
          ALeft := ALeft + LColumn.Width + h5uColumnRightSpacing(LColumn, ADefaultSpacing);
        Th5uFixedKind.Right:
          ARight := ARight - LColumn.Width - h5uColumnRightSpacing(LColumn, ADefaultSpacing);
      end;
  ALeft := Min(ALeft, ARight);
end;

function h5uHeaderHeight(ALayout: Th5uHeaderLayout; AShowHeader: Boolean; ARowHeight, ASpacing: Double): Double;
var
  LRows: Integer;
begin
  if not AShowHeader then
    Exit(0);
  LRows := 1;
  if ALayout.Enabled and (ALayout.Cells.Count > 0) then
    LRows := Max(1, ALayout.RowCount);
  Result := LRows * (ARowHeight + ASpacing);
end;

function h5uRevealOffset(AOffset, AStart, ASize, AViewportSize: Double): Double;
begin
  Result := AOffset;
  if AStart < AOffset then
    Result := AStart
  else if AStart + ASize > AOffset + AViewportSize then
    Result := Max(0.0, AStart + ASize - AViewportSize);
end;

function h5uRowSeparator(AView: Th5uGridView; ATree: Th5uTreeOptions; AGroups: Th5uAdjacentGroupFoldingOptions;
  ARow: Int64; const AKey: Th5uRowKey; AGetSpacing: Th5uRowSpacingMethod): Th5uRowSeparatorInfo;
var
  LGroup: Th5uAdjacentGroupRowInfo;
begin
  Result := Default(Th5uRowSeparatorInfo);
  Result.Kind := Th5uElementKind.RowSpacing;
  Result.TreeLevel := -1;
  // Both bands replace ordinary spacing; the adjacent-group band takes precedence.
  if AGroups.Enabled and AView.GetAdjacentGroupEndBandInfo(ARow, LGroup) then
  begin
    Result.Kind := Th5uElementKind.AdjacentGroupEndBand;
    Result.Height := AGroups.EndBand.Height;
    Result.StyleName := AGroups.EndBand.StyleName;
  end
  else if ATree.Enabled and ATree.BranchEndBand.Enabled
    and AView.GetTreeBranchEndInfo(ARow, AKey, Result.TreeLevel, Result.ClosedTreeLevels) then
  begin
    Result.Kind := Th5uElementKind.TreeBranchEndBand;
    Result.Height := ATree.BranchEndBand.Height;
    Result.StyleName := ATree.BranchEndBand.StyleName;
  end
  else
    Result.Height := AGetSpacing(ARow, AKey);
end;

end.
