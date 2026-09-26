unit h5u.Grid.Layout;

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
    Generics.Collections,
  {$ELSE}
    System.Classes,
    System.Math,
    System.Generics.Collections,
  {$ENDIF}
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

// The content budget excludes the row indicator and includes column spacing.
// Percentages are relative weights in the view or nearest enclosing header group.
function h5uResolveColumnWidths(AColumns: Th5uGridColumns; AHeader: Th5uHeaderLayout; ADefaultSpacing: Integer; AAvailableWidth: Double; AMinWidth: Integer = 0;
  AMaxWidth: Integer = 0): Boolean;
function h5uColumnRightSpacing(AColumn: Th5uGridColumn; ADefault: Integer): Integer;
function h5uBuildColumnLayout(AColumns: Th5uGridColumns; ADefaultSpacing: Integer; AViewLeft, AViewRight, AIndicatorExtent, AHorizontalOffset: Double;
  AViewHasHeight: Boolean): {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uColumnLayoutInfo>;
procedure h5uColumnViewport(AColumns: Th5uGridColumns; AColumn: Th5uGridColumn; ADefaultSpacing: Integer; AIndicatorExtent: Double; var ALeft, ARight: Double);
function h5uHeaderHeight(ALayout: Th5uHeaderLayout; AShowHeader: Boolean; ARowHeight, ASpacing: Double): Double;
function h5uRevealOffset(AOffset, AStart, ASize, AViewportSize: Double): Double;
function h5uRowSeparator(AView: Th5uGridView; ATree: Th5uTreeOptions; AGroups: Th5uAdjacentGroupFoldingOptions; ARow: Int64; const AKey: Th5uRowKey;
  AGetSpacing: Th5uRowSpacingMethod): Th5uRowSeparatorInfo;

implementation

type
  Th5uWidthNode = record
    Column: Th5uGridColumn;
    Header: Th5uHeaderLayoutCell;
    Parent, First, Last, Row, Spacing: Integer;
    Children: {$IFDEF FPC}specialize {$ENDIF}TList<Integer>;
    Weight, Minimum, Maximum, Preferred, Width, Fraction: Double;
  end;

function h5uResolveColumnWidths(AColumns: Th5uGridColumns; AHeader: Th5uHeaderLayout; ADefaultSpacing: Integer; AAvailableWidth: Double; AMinWidth: Integer;
  AMaxWidth: Integer): Boolean;
var
  LColumns: {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uGridColumn>;
  LNodes: {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uWidthNode>;
  I, J, K, N, LGroups, LParent, LFirst, LLast, LWidth: Integer;
  LBudget: Double;

  procedure MeasureNode(AIndex: Integer);
  var
    K: Integer;
    LMin, LMax, LNatural: Double;
  begin
    if Assigned(LNodes[AIndex].Column) then
    begin
      with LNodes[AIndex] do
      begin
        Minimum := Column.MinWidth;
        Maximum := Column.MaxWidth;
        if Maximum = 0 then
          Maximum := MaxInt div 4;
        Preferred := Column.ConstrainWidth(Column.Width);
        if Column.AutoWidth then
          Preferred := Column.ConstrainWidth(Column.MeasuredWidth);
        // AutoWidth takes precedence. Measured columns are fixed for distribution.
        if not Column.AutoWidth then
          Weight := Column.WidthInPercent;
      end;
      Exit;
    end;
    LMin := 0;
    LMax := 0;
    LNatural := 0;
    for K in LNodes[AIndex].Children do
    begin
      MeasureNode(K);
      if LNodes[K].Weight > 0 then
      begin
        LMin := LMin + LNodes[K].Minimum + LNodes[K].Spacing;
        LMax := LMax + LNodes[K].Maximum + LNodes[K].Spacing;
      end
      else
      begin
        LMin := LMin + LNodes[K].Preferred + LNodes[K].Spacing;
        LMax := LMax + LNodes[K].Preferred + LNodes[K].Spacing;
      end;
      LNatural := LNatural + LNodes[K].Preferred + LNodes[K].Spacing;
    end;
    with LNodes[AIndex] do
    begin
      if Children.Count = 0 then
      begin
        Minimum := 0;
        Maximum := 0;
        Preferred := 0;
        Spacing := 0;
        Exit;
      end;
      Minimum := Max(0.0, LMin - Spacing);
      Maximum := Max(Minimum, LMax - Spacing);
      Preferred := Max(0.0, LNatural - Spacing);
      if Assigned(Header) then
      begin
        // Impossible group limits cannot override fixed widths or child limits.
        Minimum := Max(Minimum, Min(Maximum, Double(Header.MinWidth)));
        if Header.MaxWidth > 0 then
          Maximum := Max(Minimum, Min(Maximum, Double(Header.MaxWidth)));
        if Header.Width > 0 then
          Preferred := Header.Width;
        Weight := Header.WidthInPercent;
        if (Weight = 0) and (Header.Width = 0) then
          for K in Children do
            Weight := Weight + LNodes[K].Weight;
      end;
      Preferred := EnsureRange(Preferred, Minimum, Maximum);
      if Maximum = 0 then
        Weight := 0;
    end;
  end;

  procedure AllocateNode(AIndex: Integer; AWidth: Double);
  var
    K, LPass, LBest: Integer;
    LRemaining, LMin, LMax, LLow, LHigh, LScale, LSum, LWeight, LFraction: Double;

    function WidthAtScale(AChild: Integer; ALogScale: Double): Double;
    var
      LLog: Double;
    begin
      LLog := ALogScale + Ln(LNodes[AChild].Weight);
      if LLog <= Ln(Max(1E-300, LNodes[AChild].Minimum)) then
        Exit(LNodes[AChild].Minimum);
      if LLog >= Ln(LNodes[AChild].Maximum) then
        Exit(LNodes[AChild].Maximum);
      Result := Exp(LLog);
    end;

  begin
    LNodes[AIndex].Width := AWidth;
    if Assigned(LNodes[AIndex].Column) then
      Exit;
    LRemaining := AWidth + LNodes[AIndex].Spacing;
    LMin := 0;
    LMax := 0;
    LWeight := 0;
    for K in LNodes[AIndex].Children do
    begin
      LRemaining := LRemaining - LNodes[K].Spacing;
      if LNodes[K].Weight > 0 then
      begin
        LMin := LMin + LNodes[K].Minimum;
        LMax := LMax + LNodes[K].Maximum;
        LWeight := LWeight + LNodes[K].Weight;
      end
      else
      begin
        LNodes[K].Width := LNodes[K].Preferred;
        LRemaining := LRemaining - LNodes[K].Width;
      end;
    end;
    if LWeight > 0 then
    begin
      LRemaining := EnsureRange(LRemaining, LMin, LMax);
      LLow := 0;
      LHigh := 0;
      for K in LNodes[AIndex].Children do
        if LNodes[K].Weight > 0 then
        begin
          LLow := Min(LLow, Ln(Max(1E-300, LNodes[K].Minimum)) - Ln(LNodes[K].Weight) - 1);
          LHigh := Max(LHigh, Ln(LNodes[K].Maximum) - Ln(LNodes[K].Weight) + 1);
        end;
      // Monotone bounded water filling: clamped columns release their share.
      for LPass := 1 to 100 do
      begin
        LScale := LLow + (LHigh - LLow) / 2;
        LSum := 0;
        for K in LNodes[AIndex].Children do
          if LNodes[K].Weight > 0 then
            LSum := LSum + WidthAtScale(K, LScale);
        if LSum < LRemaining then
          LLow := LScale
        else
          LHigh := LScale;
      end;
      LSum := 0;
      for K in LNodes[AIndex].Children do
        if LNodes[K].Weight > 0 then
        begin
          LScale := WidthAtScale(K, LHigh);
          LNodes[K].Width := Floor(LScale + 0.0000001);
          LNodes[K].Fraction := LScale - LNodes[K].Width;
          LSum := LSum + LNodes[K].Width;
        end;
      // Largest remainders, stable in visible order. Never lose viewport pixels.
      for LPass := 1 to Round(LRemaining - LSum) do
      begin
        LBest := -1;
        LFraction := -2;
        for K in LNodes[AIndex].Children do
          if (LNodes[K].Weight > 0) and (LNodes[K].Width < LNodes[K].Maximum) and (LNodes[K].Fraction > LFraction) then
          begin
            LBest := K;
            LFraction := LNodes[K].Fraction;
          end;
        if LBest < 0 then
          Break;
        LNodes[LBest].Width := LNodes[LBest].Width + 1;
        LNodes[LBest].Fraction := -2;
      end;
    end;
    for K in LNodes[AIndex].Children do
      AllocateNode(K, LNodes[K].Width);
  end;

begin
  Result := False;
  LColumns := AColumns.VisibleColumns;
  LGroups := 0;
  if Assigned(AHeader) and AHeader.Enabled then
    LGroups := AHeader.Cells.Count;
  SetLength(LNodes, 1 + LGroups + Length(LColumns));
  N := 1;
  LNodes[0].Row := -1;
  LNodes[0].First := 0;
  LNodes[0].Last := High(LColumns);
  try
    if Assigned(AHeader) and AHeader.Enabled then
      for I := 0 to AHeader.Cells.Count - 1 do
        if (AHeader.Cells[I].ColumnId = '') and AHeader.ColumnRange(AHeader.Cells[I], LColumns, LFirst, LLast) then
        begin
          LNodes[N].Header := AHeader.Cells[I];
          LNodes[N].First := LFirst;
          LNodes[N].Last := LLast;
          LNodes[N].Row := AHeader.Cells[I].LayoutRow;
          LNodes[N].Spacing := h5uColumnRightSpacing(LColumns[LLast], ADefaultSpacing);
          Inc(N);
        end;
    LGroups := N - 1;
    for I := 0 to High(LColumns) do
    begin
      LNodes[N].Column := LColumns[I];
      LNodes[N].First := I;
      LNodes[N].Last := I;
      LNodes[N].Row := MaxInt;
      LNodes[N].Spacing := h5uColumnRightSpacing(LColumns[I], ADefaultSpacing);
      Inc(N);
    end;
    for I := 0 to N - 1 do
      LNodes[I].Children := {$IFDEF FPC}specialize {$ENDIF}TList<Integer>.Create;
    for I := 1 to N - 1 do
    begin
      LParent := 0;
      for J := 1 to LGroups do
        if (LNodes[J].Row < LNodes[I].Row) and (LNodes[J].First <= LNodes[I].First)
          and (LNodes[J].Last >= LNodes[I].Last) and (LNodes[J].Row > LNodes[LParent].Row)
        then
          LParent := J;
      LNodes[I].Parent := LParent;
      LNodes[LParent].Children.Add(I);
    end;
    for I := 0 to N - 1 do
      for J := 1 to LNodes[I].Children.Count - 1 do
      begin
        K := J;
        while (K > 0) and (LNodes[LNodes[I].Children[K - 1]].First > LNodes[LNodes[I].Children[K]].First) do
        begin
          LNodes[I].Children.Exchange(K - 1, K);
          Dec(K);
        end;
      end;
    MeasureNode(0);
    LBudget := Max(0.0, Floor(AAvailableWidth));
    if AMaxWidth > 0 then
      LBudget := Min(LBudget, AMaxWidth);
    LBudget := Max(LBudget, AMinWidth);
    AllocateNode(0, LBudget);
    for I := LGroups + 1 to N - 1 do
    begin
      LWidth := Round(LNodes[I].Width);
      Result := Result or (LNodes[I].Column.LayoutWidth <> LWidth);
      LNodes[I].Column.SetLayoutWidth(LWidth);
    end;
  finally
    for I := 0 to High(LNodes) do
      LNodes[I].Children.Free;
  end;
end;

function h5uColumnRightSpacing(AColumn: Th5uGridColumn; ADefault: Integer): Integer;
begin
  if Assigned(AColumn) and (AColumn.RightSpacing >= 0) then
    Result := AColumn.RightSpacing
  else
    Result := ADefault;
end;

function h5uBuildColumnLayout(AColumns: Th5uGridColumns; ADefaultSpacing: Integer; AViewLeft, AViewRight, AIndicatorExtent, AHorizontalOffset: Double;
  AViewHasHeight: Boolean): {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uColumnLayoutInfo>;
var
  LColumns: {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uGridColumn>;
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
      LLeft := LLeft + LColumns[I].LayoutWidth + h5uColumnRightSpacing(LColumns[I], ADefaultSpacing);
  for I := High(LColumns) downto 0 do
    if LColumns[I].FixedKind = Th5uFixedKind.Right then
      LRight := LRight - LColumns[I].LayoutWidth - h5uColumnRightSpacing(LColumns[I], ADefaultSpacing);
  LNormal := LLeft - AHorizontalOffset;
  LLeft := LDataLeft;
  for I := 0 to High(LColumns) do
  begin
    LSpacing := h5uColumnRightSpacing(LColumns[I], ADefaultSpacing);
    case LColumns[I].FixedKind of
      Th5uFixedKind.Left:
        begin
          LStart := LLeft;
          LLeft := LLeft + LColumns[I].LayoutWidth + LSpacing;
        end;
      Th5uFixedKind.Right:
        begin
          LStart := LRight;
          LRight := LRight + LColumns[I].LayoutWidth + LSpacing;
        end;
      else
        begin
          LStart := LNormal;
          LNormal := LNormal + LColumns[I].LayoutWidth + LSpacing;
        end;
    end;
    Result[I].Column := LColumns[I];
    Result[I].VisibleIndex := I;
    Result[I].Left := LStart;
    Result[I].Right := LStart + LColumns[I].LayoutWidth;
    Result[I].Visible := AViewHasHeight and (LStart < AViewRight) and (Result[I].Right + LSpacing > AViewLeft);
  end;
end;

procedure h5uColumnViewport(AColumns: Th5uGridColumns; AColumn: Th5uGridColumn; ADefaultSpacing: Integer; AIndicatorExtent: Double; var ALeft, ARight: Double);
var
  LColumn: Th5uGridColumn;
begin
  ALeft := ALeft + AIndicatorExtent;
  if AColumn.FixedKind = Th5uFixedKind.None then
    for LColumn in AColumns.VisibleColumns do
      case LColumn.FixedKind of
        Th5uFixedKind.Left:
          ALeft := ALeft + LColumn.LayoutWidth + h5uColumnRightSpacing(LColumn, ADefaultSpacing);
        Th5uFixedKind.Right:
          ARight := ARight - LColumn.LayoutWidth - h5uColumnRightSpacing(LColumn, ADefaultSpacing);
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

function h5uRowSeparator(AView: Th5uGridView; ATree: Th5uTreeOptions; AGroups: Th5uAdjacentGroupFoldingOptions; ARow: Int64;
  const AKey: Th5uRowKey; AGetSpacing: Th5uRowSpacingMethod): Th5uRowSeparatorInfo;
var
  LGroup: Th5uAdjacentGroupRowInfo;
begin
  Result := Default(Th5uRowSeparatorInfo);
  Result.Kind := Th5uElementKind.RowSpacing;
  Result.TreeLevel := -1;
  // Both bands replace ordinary spacing. The adjacent-group band takes precedence.
  if AGroups.Enabled and AView.GetAdjacentGroupEndBandInfo(ARow, LGroup) then
  begin
    Result.Kind := Th5uElementKind.AdjacentGroupEndBand;
    Result.Height := AGroups.EndBand.Height;
    Result.StyleName := AGroups.EndBand.StyleName;
  end
  else
  if ATree.Enabled and ATree.BranchEndBand.Enabled and AView.GetTreeBranchEndInfo(ARow, AKey, Result.TreeLevel, Result.ClosedTreeLevels) then
  begin
    Result.Kind := Th5uElementKind.TreeBranchEndBand;
    Result.Height := ATree.BranchEndBand.Height;
    Result.StyleName := ATree.BranchEndBand.StyleName;
  end
  else
    Result.Height := AGetSpacing(ARow, AKey);
end;

end.

