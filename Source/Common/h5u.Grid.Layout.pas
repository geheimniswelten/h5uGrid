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
  h5u.Grid.Sizing,
  h5u.Grid.Types,
  h5u.Grid.View;

type
  Th5uColumnLayoutInfo = record
    Column: Th5uGridColumn;
    VisibleIndex: Integer;
    Left, Right: Single;
    Visible: Boolean;
  end;

  Th5uRowSeparatorInfo = record
    Kind: Th5uElementKind;
    Height: Single;
    StyleName: string;
    TreeLevel, ClosedTreeLevels: Integer;
  end;

  Th5uRowSpacingMethod = function(ARow: Int64; const AKey: Th5uRowKey): Single of object;

// The content budget excludes the row indicator and includes column spacing.
// The fitting mode controls whether percentages or all desired widths are relative weights.
function h5uResolveColumnWidths(AColumns: Th5uGridColumns; AHeader: Th5uHeaderLayout; ADefaultSpacing: Single; AAvailableWidth: Single; AMinWidth: Single = 0;
  AMaxWidth: Single = 0; AFitMode: Th5uColumnFitMode = Th5uColumnFitMode.PercentColumns): Boolean;
function h5uColumnRightSpacing(AColumn: Th5uGridColumn; ADefault: Single): Single;
function h5uBuildColumnLayout(AColumns: Th5uGridColumns; ADefaultSpacing: Single; AViewLeft, AViewRight, AIndicatorExtent, AHorizontalOffset: Single;
  AViewHasHeight: Boolean): {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uColumnLayoutInfo>;
procedure h5uColumnViewport(AColumns: Th5uGridColumns; AColumn: Th5uGridColumn; ADefaultSpacing: Single; AIndicatorExtent: Single; var ALeft, ARight: Single);
function h5uHeaderHeight(ALayout: Th5uHeaderLayout; AShowHeader: Boolean; ARowHeight, ASpacing: Single): Single;
function h5uRevealOffset(AOffset, AStart, ASize, AViewportSize: Double): Double;
function h5uRowSeparator(AView: Th5uGridView; ATree: Th5uTreeOptions; AGroups: Th5uAdjacentGroupFoldingOptions; ARow: Int64; const AKey: Th5uRowKey;
  AGetSpacing: Th5uRowSpacingMethod): Th5uRowSeparatorInfo;

implementation

type
  Th5uWidthNode = record
    Column: Th5uGridColumn;
    Header: Th5uHeaderLayoutCell;
    Parent, First, Last, Row: Integer;
    Spacing: Single;
    Children: {$IFDEF FPC}specialize {$ENDIF}TList<Integer>;
    Weight, Minimum, Maximum, IntrinsicMaximum, Preferred, Width: Single;
    AtMaximum: Boolean;
  end;

function h5uResolveColumnWidths(AColumns: Th5uGridColumns; AHeader: Th5uHeaderLayout; ADefaultSpacing: Single; AAvailableWidth: Single; AMinWidth: Single;
  AMaxWidth: Single; AFitMode: Th5uColumnFitMode): Boolean;
var
  LColumns: {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uGridColumn>;
  LNodes: {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uWidthNode>;
  I, J, K, N, LGroups, LParent, LFirst, LLast: Integer;
  LWidth, LBudget: Single;

  function NodeCapacityAt(AIndex: Integer; AReferenceWidth: Single): Single;
  var
    LMaximum, LPreferred: Single;
  begin
    with LNodes[AIndex] do
    begin
      if Assigned(Column) then
      begin
        LMaximum := Max(Minimum, h5uResolveWidth(Column.MaxWidthSpecification, AReferenceWidth));
        if Weight > 0 then
          Exit(LMaximum);
        if Column.AutoWidth then
          LPreferred := Column.MeasuredWidth
        else
          LPreferred := h5uResolveWidth(Column.WidthSpecification, AReferenceWidth);
      end
      else
      begin
        LMaximum := IntrinsicMaximum;
        if Header.MaxWidth <> 0 then
          LMaximum := Min(LMaximum, h5uResolveWidth(Header.MaxWidth, AReferenceWidth));
        LMaximum := Max(Minimum, LMaximum);
        if Weight > 0 then
          Exit(LMaximum);
        if Header.Width <> 0 then
          LPreferred := h5uResolveWidth(Header.Width, AReferenceWidth)
        else
          LPreferred := IntrinsicMaximum;
      end;
      Result := EnsureRange(LPreferred, Minimum, LMaximum);
    end;
  end;

  function IntrinsicGroupMaximum(AIndex: Integer): Single;
  var
    K, LPass: Integer;
    LLow, LHigh, LMiddle, LCapacity: Single;
    LRelative: Boolean;
  begin
    LRelative := False;
    LCapacity := -LNodes[AIndex].Spacing;
    for K in LNodes[AIndex].Children do
    begin
      if Assigned(LNodes[K].Column) then
        LRelative := LRelative or (LNodes[K].Column.MaxWidthSpecification < 0)
      else
        LRelative := LRelative or (LNodes[K].Header.MaxWidth < 0);
      LCapacity := LCapacity + NodeCapacityAt(K, 0) + LNodes[K].Spacing;
    end;
    if not LRelative then
      Exit(LCapacity);
    LLow := 0;
    LHigh := h5uUnlimitedWidth;
    // Child percentage limits use the group's eventual width. Their sum divided
    // by that width is nonincreasing, so the feasible upper bound can be bisected.
    // Child groups already have their intrinsic bound: no recursive search here.
    for LPass := 1 to 192 do
    begin
      LMiddle := LLow + (LHigh - LLow) / 2;
      if (LMiddle = LLow) or (LMiddle = LHigh) then
        Break;
      LCapacity := -LNodes[AIndex].Spacing;
      for K in LNodes[AIndex].Children do
        LCapacity := LCapacity + NodeCapacityAt(K, LMiddle) + LNodes[K].Spacing;
      if LCapacity >= LMiddle then
        LLow := LMiddle
      else
        LHigh := LMiddle;
    end;
    Result := LLow;
  end;

  procedure MeasureNode(AIndex: Integer; AReferenceWidth: Single);
  var
    K: Integer;
    LMin, LMax, LNatural, LChildReference, LSpecification: Single;
  begin
    if Assigned(LNodes[AIndex].Column) then
    begin
      with LNodes[AIndex] do
      begin
        Column.SetWidthReference(AReferenceWidth);
        Minimum := Column.ResolvedMinWidth;
        Maximum := Column.ResolvedMaxWidth;
        LSpecification := Column.WidthSpecification;
        Preferred := Column.ResolvedWidth;
        Weight := 0;
        if Column.AutoWidth then
          Preferred := Column.ConstrainWidth(Column.MeasuredWidth);
        case AFitMode of
          Th5uColumnFitMode.PercentColumns:
            if not Column.AutoWidth and (LSpecification < 0) then
              Weight := -LSpecification;
          Th5uColumnFitMode.AllColumns:
            if Column.AutoWidth then
              Weight := Preferred
            else
              Weight := h5uResolveWidth(LSpecification, AReferenceWidth);
        end;
        if Maximum = 0 then
          Weight := 0;
      end;
      Exit;
    end;
    LMin := 0;
    LMax := 0;
    LNatural := 0;
    LChildReference := AReferenceWidth;
    if Assigned(LNodes[AIndex].Header) and (LNodes[AIndex].Header.Width <> 0) then
      LChildReference := h5uResolveWidth(LNodes[AIndex].Header.Width, AReferenceWidth);
    for K in LNodes[AIndex].Children do
    begin
      MeasureNode(K, LChildReference);
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
      if AFitMode = Th5uColumnFitMode.None then
        IntrinsicMaximum := Max(Minimum, LMax - Spacing)
      else
        IntrinsicMaximum := Max(Minimum, IntrinsicGroupMaximum(AIndex));
      Maximum := IntrinsicMaximum;
      Preferred := Max(0.0, LNatural - Spacing);
      Weight := 0;
      if Assigned(Header) then
      begin
        // Impossible group limits cannot override fixed widths or child limits.
        Minimum := Max(Minimum, Min(Maximum, Single(Header.MinWidth)));
        if Header.MaxWidth <> 0 then
          Maximum := Max(Minimum, Min(Maximum, h5uResolveWidth(Header.MaxWidth, AReferenceWidth)));
        if Header.Width <> 0 then
          Preferred := h5uResolveWidth(Header.Width, AReferenceWidth);
        case AFitMode of
          Th5uColumnFitMode.PercentColumns:
            begin
              Weight := Header.WidthInPercent;
              if Header.Width = 0 then
                for K in Children do
                  Weight := Weight + LNodes[K].Weight;
            end;
          Th5uColumnFitMode.AllColumns:
            Weight := Preferred;
        end;
      end;
      Preferred := EnsureRange(Preferred, Minimum, Maximum);
      if Maximum = 0 then
        Weight := 0;
    end;
  end;

  procedure AllocateNode(AIndex: Integer; AWidth: Single);
  var
    K, LPass, LActive: Integer;
    LRemaining, LMinimum, LMaximum, LMaxWeight, LLow, LHigh, LScale, LSum: Single;
    LResidual, LBefore: Single;
    LFrozeColumn: Boolean;

    function WidthAtScale(AChild: Integer; AScale: Single): Single;
    begin
      Result := EnsureRange(AScale * (LNodes[AChild].Weight / LMaxWeight),
        LNodes[AChild].Minimum, LNodes[AChild].Maximum);
    end;

  begin
    LNodes[AIndex].Width := AWidth;
    if Assigned(LNodes[AIndex].Column) then
      Exit;
    for K in LNodes[AIndex].Children do
      MeasureNode(K, AWidth);
    LRemaining := AWidth + LNodes[AIndex].Spacing;
    LMinimum := 0;
    LMaximum := 0;
    LActive := 0;
    for K in LNodes[AIndex].Children do
    begin
      LNodes[K].AtMaximum := False;
      LRemaining := LRemaining - LNodes[K].Spacing;
      if LNodes[K].Weight > 0 then
      begin
        LMinimum := LMinimum + LNodes[K].Minimum;
        LMaximum := LMaximum + LNodes[K].Maximum;
        Inc(LActive);
      end
      else
      begin
        LNodes[K].Width := LNodes[K].Preferred;
        LRemaining := LRemaining - LNodes[K].Width;
      end;
    end;
    LRemaining := EnsureRange(LRemaining, LMinimum, LMaximum);
    if (LRemaining <= LMinimum) or (LRemaining >= LMaximum) then
    begin
      for K in LNodes[AIndex].Children do
        if LNodes[K].Weight > 0 then
          if LRemaining <= LMinimum then
            LNodes[K].Width := LNodes[K].Minimum
          else
            LNodes[K].Width := LNodes[K].Maximum;
      LActive := 0;
    end;
    while LActive > 0 do
    begin
      LMaxWeight := 0;
      for K in LNodes[AIndex].Children do
        if (LNodes[K].Weight > 0) and not LNodes[K].AtMaximum then
          LMaxWeight := Max(LMaxWeight, LNodes[K].Weight);
      LSum := 0;
      for K in LNodes[AIndex].Children do
        if (LNodes[K].Weight > 0) and not LNodes[K].AtMaximum then
          LSum := LSum + WidthAtScale(K, LRemaining);
      LFrozeColumn := False;
      if LSum < LRemaining then
      begin
        // Normalizing against the largest remaining weight avoids overflowing
        // scale factors. Saturated columns can be removed before renormalizing.
        for K in LNodes[AIndex].Children do
          if (LNodes[K].Weight > 0) and not LNodes[K].AtMaximum
            and (WidthAtScale(K, LRemaining) >= LNodes[K].Maximum)
          then
          begin
            LNodes[K].Width := LNodes[K].Maximum;
            LNodes[K].AtMaximum := True;
            Dec(LActive);
            LFrozeColumn := True;
          end;
        if LFrozeColumn then
        begin
          LRemaining := AWidth + LNodes[AIndex].Spacing;
          for K in LNodes[AIndex].Children do
          begin
            LRemaining := LRemaining - LNodes[K].Spacing;
            if (LNodes[K].Weight = 0) or LNodes[K].AtMaximum then
              LRemaining := LRemaining - LNodes[K].Width;
          end;
          LRemaining := Max(0.0, LRemaining);
          Continue;
        end;
      end;
      LLow := 0;
      LHigh := LRemaining;
      for LPass := 1 to 192 do
      begin
        LScale := LLow + (LHigh - LLow) / 2;
        if (LScale = LLow) or (LScale = LHigh) then
          Break;
        LSum := 0;
        for K in LNodes[AIndex].Children do
          if (LNodes[K].Weight > 0) and not LNodes[K].AtMaximum then
            LSum := LSum + WidthAtScale(K, LScale);
        if LSum < LRemaining then
          LLow := LScale
        else
          LHigh := LScale;
      end;
      LResidual := LRemaining;
      for K in LNodes[AIndex].Children do
        if (LNodes[K].Weight > 0) and not LNodes[K].AtMaximum then
        begin
          LNodes[K].Width := WidthAtScale(K, LHigh);
          LResidual := LResidual - LNodes[K].Width;
        end;
      // Correct the last floating-point remainder without quantizing logical
      // widths. Native adapters round cumulative drawing boundaries as needed.
      for LPass := 0 to 1 do
        for K in LNodes[AIndex].Children do
          if (LNodes[K].Weight > 0) and not LNodes[K].AtMaximum and (LResidual <> 0)
            and ((LPass = 1) or ((LNodes[K].Width > LNodes[K].Minimum)
              and (LNodes[K].Width < LNodes[K].Maximum)))
          then
          begin
            LBefore := LNodes[K].Width;
            LNodes[K].Width := EnsureRange(LBefore + LResidual, LNodes[K].Minimum, LNodes[K].Maximum);
            LResidual := LResidual - (LNodes[K].Width - LBefore);
          end;
      Break;
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
    LBudget := EnsureRange(AAvailableWidth, 0.0, h5uUnlimitedWidth);
    if AMaxWidth > 0 then
      LBudget := Min(LBudget, AMaxWidth);
    LBudget := Max(LBudget, AMinWidth);
    MeasureNode(0, LBudget);
    AllocateNode(0, LBudget);
    for I := LGroups + 1 to N - 1 do
    begin
      LWidth := LNodes[I].Width;
      Result := Result or (LNodes[I].Column.LayoutWidth <> LWidth);
      LNodes[I].Column.SetLayoutWidth(LWidth);
    end;
  finally
    for I := 0 to High(LNodes) do
      LNodes[I].Children.Free;
  end;
end;

function h5uColumnRightSpacing(AColumn: Th5uGridColumn; ADefault: Single): Single;
begin
  if Assigned(AColumn) and (AColumn.RightSpacing >= 0) then
    Result := AColumn.RightSpacing
  else
    Result := ADefault;
end;

function h5uBuildColumnLayout(AColumns: Th5uGridColumns; ADefaultSpacing: Single; AViewLeft, AViewRight, AIndicatorExtent, AHorizontalOffset: Single;
  AViewHasHeight: Boolean): {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uColumnLayoutInfo>;
var
  LColumns: {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uGridColumn>;
  LDataLeft, LLeft, LRight, LNormal, LStart: Single;
  LSpacing: Single;
  I: Integer;
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

procedure h5uColumnViewport(AColumns: Th5uGridColumns; AColumn: Th5uGridColumn; ADefaultSpacing: Single; AIndicatorExtent: Single; var ALeft, ARight: Single);
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

function h5uHeaderHeight(ALayout: Th5uHeaderLayout; AShowHeader: Boolean; ARowHeight, ASpacing: Single): Single;
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

