program TestCommonBehavior;

{$IFDEF FPC}
{$MODE OBJFPC}{$H+}
{$MODESWITCH ADVANCEDRECORDS}
{$CODEPAGE UTF8}
{$ELSE}
{$APPTYPE CONSOLE}
{$ENDIF}
{$SCOPEDENUMS ON}

uses
{$IFDEF FPC}
  h5u.Grid.Compat,
  SysUtils, Math, Rtti, Classes, DateUtils,
{$ENDIF}
{$IFNDEF FPC}
  System.SysUtils,
{$ENDIF}
  h5u.Grid.Values,
{$IFNDEF FPC}
  System.Math,
{$ENDIF}
  h5u.Grid.Layout,
  h5u.Grid.RowMetrics,
{$IFNDEF FPC}
  System.Rtti,
{$ENDIF}
  h5u.Grid.AdjacentGroups,
  h5u.Grid.Data.Core,
  h5u.Grid.Data.Memory,
  h5u.Grid.View,
{$IFNDEF FPC}
  System.Classes,
{$ENDIF}
{$IFNDEF FPC}
  System.DateUtils,
{$ENDIF}
{$IFNDEF FPC}
  System.UITypes,
{$ENDIF}
  h5u.Grid.Types,
  h5u.Grid.Selection,
  h5u.Grid.Navigation,
  h5u.Grid.Columns,
  h5u.Grid.Options,
  h5u.Grid.Resizing;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

procedure TestColumnWidths;
var
  C, CopyColumns: Th5uGridColumns;
  H, CopyHeader: Th5uHeaderLayout;
  A, B, D, Outside: Th5uGridColumn;
  G, Nested: Th5uHeaderLayoutCell;
  I, Total: Integer;
begin
  C := Th5uGridColumns.Create(nil);
  H := Th5uHeaderLayout.Create(nil);
  CopyColumns := Th5uGridColumns.Create(nil);
  CopyHeader := Th5uHeaderLayout.Create(nil);
  try
    A := C.Add; A.Id := 'fixed'; A.Width := 100;
    B := C.Add; B.Id := 'quarter'; B.WidthInPercent := 25;
    D := C.Add; D.Id := 'rest'; D.WidthInPercent := 75;
    h5uResolveColumnWidths(C, H, 1, 503);
    Check((A.LayoutWidth = 100) and (B.LayoutWidth = 100) and (D.LayoutWidth = 300), 'fixed width and spacing before percentages');
    Check((B.Width = 100) and (D.Width = 100), 'layout must preserve configured pixels');
    B.MinWidth := 150;
    h5uResolveColumnWidths(C, H, 1, 503);
    Check((B.LayoutWidth = 150) and (D.LayoutWidth = 250), 'minimum redistributes remaining width');
    B.MinWidth := 24;
    D.MaxWidth := 200;
    h5uResolveColumnWidths(C, H, 1, 503);
    Check((B.LayoutWidth = 200) and (D.LayoutWidth = 200), 'maximum redistributes remaining width');
    D.MaxWidth := 1000;
    h5uResolveColumnWidths(C, H, 1, 503, 703, 0);
    Check((B.LayoutWidth = 150) and (D.LayoutWidth = 450), 'grid minimum applies to total column content');
    h5uResolveColumnWidths(C, H, 1, 503, 0, 403);
    Check((B.LayoutWidth = 75) and (D.LayoutWidth = 225), 'grid maximum applies to total column content');
    h5uResolveColumnWidths(C, H, 1, 80);
    Check((A.LayoutWidth = 100) and (B.LayoutWidth = 24) and (D.LayoutWidth = 24), 'overconstrained content preserves pixels and minima');
    B.AutoWidth := True;
    B.SetMeasuredWidth(180);
    h5uResolveColumnWidths(C, H, 1, 503);
    Check((B.LayoutWidth = 180) and (D.LayoutWidth = 220), 'AutoWidth precedes percent and reserves measured content');
    B.Visible := False;
    h5uResolveColumnWidths(C, H, 1, 503);
    Check(D.LayoutWidth = 401, 'hidden columns consume neither width nor spacing');
    B.Visible := True;
    B.AutoWidth := False;
    A.FixedKind := Th5uFixedKind.Left;
    D.FixedKind := Th5uFixedKind.Right;
    h5uResolveColumnWidths(C, H, 1, 504);
    Check(B.LayoutWidth + D.LayoutWidth = 401, 'rounding conserves pixels including pinned columns');
    A.FixedKind := Th5uFixedKind.None;
    D.FixedKind := Th5uFixedKind.None;
    h5uTryResizeColumn(C, B, B.LayoutWidth, 10);
    Check((B.WidthInPercent = 0) and not B.AutoWidth, 'manual resizing selects pixel mode');
    B.WidthInPercent := 30;
    D.WidthInPercent := 70;
    H.Enabled := True;
    G := H.Cells.Add;
    G.ColumnSpan := 3;
    G.Width := 400;
    Outside := C.Add; Outside.WidthInPercent := 100;
    h5uResolveColumnWidths(C, H, 0, 1000);
    Check((B.LayoutWidth = 90) and (D.LayoutWidth = 210) and (Outside.LayoutWidth = 600), 'parent group budget and independent view remainder');
    Nested := H.Cells.Add;
    Nested.LayoutRow := 1; Nested.LayoutColumn := 1; Nested.ColumnSpan := 2;
    Nested.WidthInPercent := 100;
    h5uResolveColumnWidths(C, H, 0, 1000);
    Check((B.LayoutWidth = 90) and (D.LayoutWidth = 210), 'nested group uses allocated parent remainder');
    G.MinWidth := 500;
    h5uResolveColumnWidths(C, H, 0, 1000);
    Check((B.LayoutWidth = 120) and (D.LayoutWidth = 280) and (Outside.LayoutWidth = 500), 'group minimum');
    G.MinWidth := 0;
    G.Width := 0;
    G.WidthInPercent := 50;
    Outside.WidthInPercent := 50;
    h5uResolveColumnWidths(C, H, 0, 1000);
    Check(A.LayoutWidth + B.LayoutWidth + D.LayoutWidth = 500, 'percent group reserves its share in the view');
    CopyColumns.Assign(C);
    CopyHeader.Assign(H);
    Check((CopyColumns[1].WidthInPercent = 30) and (CopyHeader.Cells[0].WidthInPercent = 50), 'Assign retains column and group sizing');
    h5uResolveColumnWidths(CopyColumns, CopyHeader, 0, 1000);
    Check(CopyColumns[2].LayoutWidth = D.LayoutWidth, 'copied layout resolves identically');
    H.Enabled := False;
    for I := 1 to 4 do
    begin
      h5uResolveColumnWidths(C, H, 1, 651.75);
      Total := 0;
      for A in C.VisibleColumns do Inc(Total, A.LayoutWidth + 1);
      Check(Total = 651, 'fractional viewport and repeated layout retain exact integer total');
    end;
    B.WidthInPercent := 1E-300;
    h5uResolveColumnWidths(C, H, 1, 651);
    Check(B.LayoutWidth = B.MinWidth, 'tiny percentage cannot overflow the allocator');
    C[0].Visible := False;
    D.Visible := False;
    Outside.Visible := False;
    B.MinWidth := 0;
    B.WidthInPercent := 100;
    h5uResolveColumnWidths(C, H, 0, 0);
    Check(B.LayoutWidth = 0, 'zero column minimum remains supported');
    Writeln('PASS: auto, percent, fixed, hidden and pinned widths, grid limits, nested groups, rounding, Assign and manual resize');
  finally
    CopyHeader.Free;
    CopyColumns.Free;
    H.Free;
    C.Free;
  end;
end;

procedure TestResizeBoundaries;
var
  LColumns: Th5uGridColumns;
  LOptions: Th5uCustomizationOptions;
  LItems: {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uResizeCandidate>;
  LRemoved: Th5uGridColumn;
begin
  LColumns := Th5uGridColumns.Create(nil);
  LOptions := Th5uCustomizationOptions.Create;
  try
    SetLength(LItems, 2);
    LItems[0].Column := LColumns.Add;
    LItems[0].VisibleIndex := 0;
    LItems[0].Right := 100;
    LItems[0].ViewLeft := 0;
    LItems[0].ViewRight := 300;
    LItems[1].Column := LColumns.Add;
    LItems[1].VisibleIndex := 1;
    LItems[1].Right := 200;
    LItems[1].ViewLeft := 0;
    LItems[1].ViewRight := 300;
    LOptions.ColumnResizeHitZoneLeft := 8;
    LOptions.ColumnResizeHitZoneRight := 2;
    LOptions.LastColumnResizeHitZoneLeft := 20;
    LOptions.TouchColumnResizeHitZoneLeft := 14;
    LOptions.TouchColumnResizeHitZoneRight := 9;
    LOptions.TouchLastColumnResizeHitZoneLeft := -1;
    Check(h5uColumnResizeAt(LOptions, LItems, 1, 92, 5, False, nil) = LItems[0].Column, 'inclusive left edge');
    Check(h5uColumnResizeAt(LOptions, LItems, 1, 91.9, 5, False, nil) = nil, 'outside left edge');
    Check(h5uColumnResizeAt(LOptions, LItems, 1, 102, 5, False, nil) = LItems[0].Column, 'inclusive right edge');
    Check(h5uColumnResizeAt(LOptions, LItems, 1, 102.1, 5, False, nil) = nil, 'outside right edge');
    Check(h5uColumnResizeAt(LOptions, LItems, 1, 180, 5, False, nil) = LItems[1].Column, 'last-column override');
    Check(h5uColumnResizeAt(LOptions, LItems, 2, 180, 5, False, nil) = nil, 'viewport last is not model last');
    Check(h5uColumnResizeAt(LOptions, LItems, 1, 186, 5, True, nil) = LItems[1].Column, 'touch default inheritance');
    Check(h5uColumnResizeAt(LOptions, LItems, 1, 185.9, 5, True, nil) = nil, 'touch inherited boundary');
    LItems[1].ViewRight := 195;
    Check(h5uColumnResizeAt(LOptions, LItems, 1, 194, 5, False, nil) = nil, 'clipped edge');
    LRemoved := LColumns.Add;
    LRemoved.Free;
    Check(not h5uTryResizeColumn(LColumns, LRemoved, 100, 10), 'removed resize source');
    LItems[0].Column.CanResize := False;
    Check(not h5uTryResizeColumn(LColumns, LItems[0].Column, 100, 10), 'disabled resize source');
    Writeln('PASS: common asymmetric resize, touch inheritance, clipping and removed sources');
  finally
    LOptions.Free;
    LColumns.Free;
  end;
end;

type
  TNavigationData = class
    function RowKey(ARow: Int64): Th5uRowKey;
    function Extent(ARow: Int64): Double;
    procedure Prepare(AFirst, ACount: Int64);
    function Text(AColumn: Th5uGridColumn; ARow: Int64; ADisplay: Boolean): string;
  end;

function TNavigationData.RowKey(ARow: Int64): Th5uRowKey;
begin
  Result := Th5uRowKey.FromInt64(ARow + 100);
end;

function TNavigationData.Extent(ARow: Int64): Double;
begin
  Result := 20;
end;

procedure TNavigationData.Prepare(AFirst, ACount: Int64);
begin
  Check((AFirst >= 0) and (ACount = 1), 'search preparation range');
end;

function TNavigationData.Text(AColumn: Th5uGridColumn; ARow: Int64; ADisplay: Boolean): string;
begin
  case ARow of
    0: Result := 'Alpha';
    1: Result := 'Beta';
    2: Result := 'Alpine';
    else Result := '';
  end;
end;

procedure TestNavigation;
var
  LData: TNavigationData;
  LColumns: Th5uGridColumns;
  LSelection: Th5uGridSelection;
  LNav, LOther: Th5uGridNavigation;
  LAction: Th5uNavigationAction;
  LCell: Th5uCellAddress;
  LRange: Th5uCellRange;
  LRow: Int64;
  LColumn: Integer;
begin
  LData := TNavigationData.Create;
  LColumns := Th5uGridColumns.Create(nil);
  LSelection := Th5uGridSelection.Create;
  try
    LColumns.Add.Id := 'a';
    LColumns.Add.Id := 'b';
    LNav := Default(Th5uGridNavigation);
    LOther := Default(Th5uGridNavigation);
    Check(LNav.Navigate(LColumns, LSelection, 10, {$IFDEF FPC}@{$ENDIF}LData.RowKey, {$IFDEF FPC}@{$ENDIF}LData.Extent, 45, vkF2, [],
      LAction), 'F2 not handled');
    Check((LAction.Kind = Th5uNavigationActionKind.Focus) and LAction.EditAfterFocus
      and not LAction.AutomaticEdit, 'F2 initial focus and manual edit');
    Check(h5uPlanCellFocus(LColumns, LSelection, 10, {$IFDEF FPC}@{$ENDIF}LData.RowKey, 0, 0, False, LCell, LRange), 'focus plan');
    LSelection.SetFocus(LCell, True);
    LNav.Navigate(LColumns, LSelection, 10, {$IFDEF FPC}@{$ENDIF}LData.RowKey, {$IFDEF FPC}@{$ENDIF}LData.Extent, 45, vkNext, [ssShift,
      ssCtrl], LAction);
    Check((LAction.Cell.RowIndex = 3) and LAction.Extend and LAction.Add, 'page navigation and additive extension');
    LNav.SelectHeaderRange(LColumns, LSelection, 10, {$IFDEF FPC}@{$ENDIF}LData.RowKey, Th5uSelectionKind.Columns, -1, 0, []);
    LNav.Navigate(LColumns, LSelection, 10, {$IFDEF FPC}@{$ENDIF}LData.RowKey, {$IFDEF FPC}@{$ENDIF}LData.Extent, 45, vkRight, [ssShift], LAction);
    Check((LAction.Kind = Th5uNavigationActionKind.Header) and (LAction.Cell.ColumnIndex = 1), 'header navigation action');
    Check(not LOther.HeaderSelectionActive, 'navigation state shared between grids');
    LNav.Cancel(LSelection);
    Check(not LNav.HeaderSelectionActive, 'cancel did not reset header selection');
    Check(LNav.SearchCharacter(LColumns, LSelection, 3, {$IFDEF FPC}@{$ENDIF}LData.Prepare, {$IFDEF FPC}@{$ENDIF}LData.Text, 'a', 100, LRow,
      LColumn) and (LRow = 2), 'new search must start after focused row');
    h5uPlanCellFocus(LColumns, LSelection, 3, {$IFDEF FPC}@{$ENDIF}LData.RowKey, LRow, LColumn, False, LCell, LRange);
    LSelection.SetFocus(LCell, True);
    Check(LNav.SearchCharacter(LColumns, LSelection, 3, {$IFDEF FPC}@{$ENDIF}LData.Prepare, {$IFDEF FPC}@{$ENDIF}LData.Text, 'l',
      100 + 200 / MSecsPerDay, LRow, LColumn) and (LRow = 2) and (LNav.SearchText = 'al'), 'continued search must include focused row');
    Check(LNav.SearchCharacter(LColumns, LSelection, 3, {$IFDEF FPC}@{$ENDIF}LData.Prepare, {$IFDEF FPC}@{$ENDIF}LData.Text, 'b',
      100 + 1500 / MSecsPerDay, LRow, LColumn) and (LRow = 1) and (LNav.SearchText = 'b'), 'search timeout and wrap');
    Writeln('PASS: common navigation, page distance, header extension, independent state and search timeout');
  finally
    LSelection.Free;
    LColumns.Free;
    LData.Free;
  end;
end;

type
  TViewData = class
    Controller: Th5uMemoryController;
    Events: Integer;
    function GetController: Th5uCustomDataController;
    procedure GroupChanged(Sender: TObject; const AContext: Th5uAdjacentGroupStateChangedContext);
  end;

function TViewData.GetController: Th5uCustomDataController;
begin
  Result := Controller;
end;

procedure TViewData.GroupChanged(Sender: TObject; const AContext: Th5uAdjacentGroupStateChangedContext);
begin
  Check((Sender = Self) and (AContext.Grid = Self) and (AContext.DataController = Controller), 'group event owner/context');
  Inc(Events);
end;

procedure TestIndependentViews;
var
  LData: TViewData;
  LColumns: Th5uGridColumns;
  LTree: Th5uTreeOptions;
  LGroups: Th5uAdjacentGroupFoldingOptions;
  LView, LOther: Th5uGridView;
  LInfo: Th5uAdjacentGroupRowInfo;
  LChanges: {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uAdjacentGroupRowInfo>;
  LLevel, LClosed: Integer;
begin
  LData := TViewData.Create;
  LData.Controller := Th5uMemoryController.Create(nil);
  LColumns := Th5uGridColumns.Create(nil);
  LTree := Th5uTreeOptions.Create;
  LGroups := Th5uAdjacentGroupFoldingOptions.Create;
  LView := nil;
  LOther := nil;
  try
    LData.Controller.AppendValues(['group', 'level'], [TValue.{$IFDEF FPC}specialize {$ENDIF}From<string>('A'),
      TValue.{$IFDEF FPC}specialize {$ENDIF}From<Integer>(0)]);
    LData.Controller.AppendValues(['group', 'level'], [TValue.{$IFDEF FPC}specialize {$ENDIF}From<string>('A'),
      TValue.{$IFDEF FPC}specialize {$ENDIF}From<Integer>(1)]);
    LData.Controller.AppendValues(['group', 'level'], [TValue.{$IFDEF FPC}specialize {$ENDIF}From<string>('B'),
      TValue.{$IFDEF FPC}specialize {$ENDIF}From<Integer>(0)]);
    LData.Controller.AppendValues(['group', 'level'], [TValue.{$IFDEF FPC}specialize {$ENDIF}From<string>('B'),
      TValue.{$IFDEF FPC}specialize {$ENDIF}From<Integer>(1)]);
    LData.Controller.AppendValues(['group', 'level'], [TValue.{$IFDEF FPC}specialize {$ENDIF}From<string>('A'),
      TValue.{$IFDEF FPC}specialize {$ENDIF}From<Integer>(0)]);
    LGroups.Enabled := True;
    LGroups.IdColumnId := 'group';
    LGroups.InitialState := Th5uAdjacentGroupInitialState.Expanded;
    LTree.Enabled := True;
    LTree.LevelColumnId := 'level';
    LView := Th5uGridView.Create(LData, LColumns, LTree, LGroups, {$IFDEF FPC}@{$ENDIF}LData.GetController);
    LOther := Th5uGridView.Create(LData, LColumns, LTree, LGroups, {$IFDEF FPC}@{$ENDIF}LData.GetController);
    LView.OnAdjacentGroupStateChanged := {$IFDEF FPC}@{$ENDIF}LData.GroupChanged;
    Check((LView.GetViewRowCount = 5) and (LOther.GetViewRowCount = 5), 'initial view count');
    Check(LView.ChangeAdjacentGroup(0, False, True, LInfo), 'collapse first run');
    LView.DoAdjacentGroupStateChanged(LInfo);
    Check((LData.Events = 1) and (LView.GetViewRowCount = 4) and (LOther.GetViewRowCount = 5), 'per-view folding and event');
    Check((LView.GetViewSourceRowIndex(1) = 2) and (LView.GetViewRowKey(1) = LData.Controller.GetRowKey(2)), 'collapsed row/source mapping');
    Check(LView.GetViewValue(1, 'group').AsString = 'B', 'view value mapping');
    Check(LView.CanEditViewValue(1, 'level'), 'view edit permission');
    LView.SetViewValue(1, 'level', TValue.{$IFDEF FPC}specialize {$ENDIF}From<Integer>(0));
    Check(LView.GetTreeBranchEndInfo(2, LView.GetViewRowKey(2), LLevel, LClosed) and (LLevel = 1) and (LClosed
      = 1), 'tree branch closes at next visible row');
    Check(not LView.IsViewRowAvailable(4), 'folded look-ahead passed end');
    LChanges := LView.ChangeAllAdjacentGroups(True);
    Check((Length(LChanges) = 1) and (LView.GetViewRowCount = 3), 'collapse only remaining foldable run');
    LChanges := LView.ChangeAllAdjacentGroups(False);
    Check((Length(LChanges) = 2) and (LView.GetViewRowCount = 5), 'expand independent repeated IDs');
    LData.Controller.Clear;
    LView.InvalidateAdjacentGroupMap(True);
    Check(LView.GetViewRowCount = 0, 'empty data after invalidation');
    Writeln('PASS: common independent views, repeated group IDs, row mapping, tree closure and event owner');
  finally
    LOther.Free;
    LView.Free;
    LGroups.Free;
    LTree.Free;
    LColumns.Free;
    LData.Controller.Free;
    LData.Free;
  end;
end;

type
  TMetricData = class
    Measures: Integer;
    Forced: Boolean;
    ForceHeight: Double;
    Cache: Boolean;
    ExtentValue: Double;
    Prepared: Int64;
    function Measure(ARow: Int64; AColumn: Th5uGridColumn): Double;
    procedure Adjust(ARow: Int64; const AKey: Th5uRowKey; AEstimated: Boolean; var AHeight: Double; var ACacheResult: Boolean);
    function Extent(ARow: Int64; AAllowMeasure: Boolean): Double;
    procedure Prepare(AFirst, ACount: Int64);
  end;

function TMetricData.Measure(ARow: Int64; AColumn: Th5uGridColumn): Double;
begin
  Inc(Measures);
  Result := StrToInt(AColumn.Caption);
end;

procedure TMetricData.Adjust(ARow: Int64; const AKey: Th5uRowKey; AEstimated: Boolean; var AHeight: Double; var ACacheResult: Boolean);
begin
  if Forced then AHeight := ForceHeight;
  ACacheResult := Cache;
end;

function TMetricData.Extent(ARow: Int64; AAllowMeasure: Boolean): Double;
begin
  Result := ExtentValue;
end;

procedure TMetricData.Prepare(AFirst, ACount: Int64);
begin
  Prepared := ACount;
end;

procedure TestRowMetrics;
const
  LargeCount: Int64 = 9007199254740993;
var
  LData: TMetricData;
  LColumns: Th5uGridColumns;
  LOptions: Th5uRowHeightOptions;
  LMetrics: Th5uGridRowMetrics;
  LTotal: Th5uTotalRowHeight;
  LKey: Th5uRowKey;
  LBefore, LTop: Integer;
  LFloatTop: Double;
begin
  LData := TMetricData.Create;
  LColumns := Th5uGridColumns.Create(nil);
  LOptions := Th5uRowHeightOptions.Create;
  LMetrics := Th5uGridRowMetrics.Create;
  try
    LData.Cache := True;
    LColumns.Add.Caption := '40';
    LColumns[0].AutoHeight := True;
    LColumns.Add.Caption := '80';
    LColumns.Add.Caption := '100';
    LColumns[2].Visible := False;
    LOptions.Mode := Th5uRowHeightMode.Automatic;
    LOptions.MinHeight := 1;
    LOptions.MaxHeight := 100;
    LOptions.EstimatedHeight := 17;
    LKey := Th5uRowKey.FromString('metric-row');
    Check(LMetrics.GetHeight(LOptions, LColumns, 0, LKey, True, {$IFDEF FPC}@{$ENDIF}LData.Measure, {$IFDEF FPC}@{$ENDIF}LData.Adjust) = 40,
      'explicit height contributors');
    LBefore := LData.Measures;
    Check(LMetrics.GetHeight(LOptions, LColumns, 3, LKey, True, {$IFDEF FPC}@{$ENDIF}LData.Measure, {$IFDEF FPC}@{$ENDIF}LData.Adjust) = 40,
      'cache follows row key');
    Check(LData.Measures = LBefore, 'height cache not reused');
    LOptions.MeasureScope := Th5uAutoHeightMeasureScope.AllVisibleColumns;
    LMetrics.Clear;
    Check(LMetrics.GetHeight(LOptions, LColumns, 0, LKey, True, {$IFDEF FPC}@{$ENDIF}LData.Measure, {$IFDEF FPC}@{$ENDIF}LData.Adjust) = 80,
      'all visible contributors and hidden exclusion');
    LMetrics.Remove(LKey.ToString);
    LData.Cache := False;
    LData.Forced := True;
    LData.ForceHeight := 0;
    Check(LMetrics.GetHeight(LOptions, LColumns, 0, LKey, True, {$IFDEF FPC}@{$ENDIF}LData.Measure, {$IFDEF FPC}@{$ENDIF}LData.Adjust) = 1,
      'event minimum height');
    LData.ForceHeight := 12.5;
    Check(LMetrics.GetHeight(LOptions, LColumns, 0, LKey, True, {$IFDEF FPC}@{$ENDIF}LData.Measure,
      {$IFDEF FPC}@{$ENDIF}LData.Adjust) = 12.5, 'fractional event height and cache opt-out');
    LData.Forced := False;
    Check(LMetrics.GetHeight(LOptions, LColumns, 0, LKey, False, {$IFDEF FPC}@{$ENDIF}LData.Measure, {$IFDEF FPC}@{$ENDIF}LData.Adjust) = 17,
      'estimated height');
    LData.ExtentValue := 10.25;
    LTotal := h5uTotalRowHeight(LOptions, 3001, 0, True, {$IFDEF FPC}@{$ENDIF}LData.Prepare, {$IFDEF FPC}@{$ENDIF}LData.Extent);
    Check((LData.Prepared = 3001) and SameValue(LTotal.AsFloat, 3001 * 10.25), 'shared exact measurement threshold and fractional sum');
    LTotal := h5uTotalRowHeight(LOptions, h5uExactRowHeightLimit + 1, 0, True, {$IFDEF FPC}@{$ENDIF}LData.Prepare, {$IFDEF FPC}@{$ENDIF}LData.Extent);
    Check(LTotal.Whole = (h5uExactRowHeightLimit + 1) * LOptions.EstimatedHeight, 'large automatic-height estimate');
    LOptions.Mode := Th5uRowHeightMode.Fixed;
    LTotal := h5uTotalRowHeight(LOptions, LargeCount, 0, False, {$IFDEF FPC}@{$ENDIF}LData.Prepare, {$IFDEF FPC}@{$ENDIF}LData.Extent);
    Check(LTotal.Whole = LargeCount * LOptions.FixedHeight, 'Int64 total lost precision above 2^53');
    LData.ExtentValue := 20;
    Check((h5uFindFirstVisibleRow(5, Int64(40), 100, {$IFDEF FPC}@{$ENDIF}LData.Extent, LTop) = 2) and (LTop = 100), 'integer row boundary');
    LData.ExtentValue := 20.25;
    Check((h5uFindFirstVisibleRow(5, 40.75, 100.0, {$IFDEF FPC}@{$ENDIF}LData.Extent, LFloatTop) = 2) and SameValue(LFloatTop, 99.75),
      'fractional row offset');
    Check((h5uFindFirstVisibleRow(5, -1.0, 100.0, {$IFDEF FPC}@{$ENDIF}LData.Extent, LFloatTop) = 0) and (LFloatTop = 100), 'negative offset clamp');
    Writeln('PASS: common row metrics, measurement scope, cache, override minimum, fractions and large Int64 totals');
  finally
    LMetrics.Free;
    LOptions.Free;
    LColumns.Free;
    LData.Free;
  end;
end;

procedure TestColumnLayout;
var
  LColumns: Th5uGridColumns;
  LLayout: {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uColumnLayoutInfo>;
  LLeft, LRight: Double;
begin
  LColumns := Th5uGridColumns.Create(nil);
  try
    LColumns.Add.Width := 50;
    LColumns[0].FixedKind := Th5uFixedKind.Left;
    LColumns[0].RightSpacing := 3;
    LColumns.Add.Width := 100;
    LColumns.Add.Width := 40;
    LColumns[2].FixedKind := Th5uFixedKind.Right;
    LColumns[2].RightSpacing := 0;
    LLayout := h5uBuildColumnLayout(LColumns, 1, 0, 200, 10, 20, True);
    Check((LLayout[0].Left = 10) and (LLayout[1].Left = 43) and (LLayout[2].Left = 160), 'fixed/scrollable column positions');
    LLeft := 0; LRight := 200;
    h5uColumnViewport(LColumns, LColumns[1], 1, 10, LLeft, LRight);
    Check((LLeft = 63) and (LRight = 160), 'scrollable viewport between fixed columns');
    LLayout := h5uBuildColumnLayout(LColumns, 1, 0, 200, 10, 20.25, True);
    Check(LLayout[1].Left = 42.75, 'fractional horizontal offset');
    LLayout := h5uBuildColumnLayout(LColumns, 1, 16777217, 16777417, 10, 20, True);
    Check(LLayout[0].Left = 16777227, 'integer layout must not narrow to Single');
    Check(h5uRevealOffset(50, 40, 20, 100) = 40, 'reveal before viewport');
    Check(h5uRevealOffset(50, 140, 20, 100) = 60, 'reveal after viewport');
    Writeln('PASS: common column layout, fixed boundaries, custom spacing, fractional coordinates and pixel precision');
  finally
    LColumns.Free;
  end;
end;

procedure TestValueConversion;
var
  LType: Th5uColumnDataType;
  LValue: TValue;
  LFailed: Boolean;
begin
  Check(h5uParseEditorValue(Th5uColumnDataType.Integer, '9223372036854775807').AsInt64 = High(Int64), 'Int64 parsing');
  Check(SameValue(h5uParseEditorValue(Th5uColumnDataType.Float, FloatToStr(1.5)).AsExtended, 1.5), 'locale float parsing');
  Check(h5uParseEditorValue(Th5uColumnDataType.Currency, CurrToStr(12.25)).{$IFDEF FPC}specialize {$ENDIF}AsType<Currency> = 12.25,
    'currency parsing');
  Check(h5uParseEditorValue(Th5uColumnDataType.Text, ' abc ').AsString = ' abc ', 'text whitespace preservation');
  for LType
    in [Th5uColumnDataType.Integer, Th5uColumnDataType.Float, Th5uColumnDataType.Currency, Th5uColumnDataType.Date, Th5uColumnDataType.DateTime,
    Th5uColumnDataType.Time] do
  begin
    LFailed := False;
    try
      LValue := h5uParseEditorValue(LType, 'invalid-input');
    except
      on E: EConvertError do
      begin
        LFailed := True;
        Check(Pos('"invalid-input"', E.Message) > 0, 'conversion error must include rejected text');
      end;
    end;
    Check(LFailed, 'invalid input was accepted');
  end;
  Writeln('PASS: common value conversion, locale, Int64 bounds and consistent rejected-input errors');
end;

begin
  try
    TestResizeBoundaries;
    TestNavigation;
    TestIndependentViews;
    TestRowMetrics;
    TestColumnLayout;
    TestColumnWidths;
    TestValueConversion;
  except
    on E: Exception do
    begin
      Writeln(E.ClassName + ': ' + E.Message);
      ExitCode := 1;
    end;
  end;
end.
