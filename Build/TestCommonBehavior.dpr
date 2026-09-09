program TestCommonBehavior;

{$APPTYPE CONSOLE}
{$SCOPEDENUMS ON}

uses
  System.SysUtils,
  System.Math,
  h5u.Grid.Layout,
  h5u.Grid.RowMetrics,
  System.Rtti,
  h5u.Grid.AdjacentGroups,
  h5u.Grid.Data.Core,
  h5u.Grid.Data.Memory,
  h5u.Grid.View,
  System.Classes,
  System.DateUtils,
  System.UITypes,
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

procedure TestResizeBoundaries;
var
  LColumns: Th5uGridColumns;
  LOptions: Th5uCustomizationOptions;
  LItems: TArray<Th5uResizeCandidate>;
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
    Check(LNav.Navigate(LColumns, LSelection, 10, LData.RowKey, LData.Extent, 45, vkF2, [], LAction), 'F2 not handled');
    Check((LAction.Kind = Th5uNavigationActionKind.Focus) and LAction.EditAfterFocus and not LAction.AutomaticEdit, 'F2 initial focus and manual edit');
    Check(h5uPlanCellFocus(LColumns, LSelection, 10, LData.RowKey, 0, 0, False, LCell, LRange), 'focus plan');
    LSelection.SetFocus(LCell, True);
    LNav.Navigate(LColumns, LSelection, 10, LData.RowKey, LData.Extent, 45, vkNext, [ssShift, ssCtrl], LAction);
    Check((LAction.Cell.RowIndex = 3) and LAction.Extend and LAction.Add, 'page navigation and additive extension');
    LNav.SelectHeaderRange(LColumns, LSelection, 10, LData.RowKey, Th5uSelectionKind.Columns, -1, 0, []);
    LNav.Navigate(LColumns, LSelection, 10, LData.RowKey, LData.Extent, 45, vkRight, [ssShift], LAction);
    Check((LAction.Kind = Th5uNavigationActionKind.Header) and (LAction.Cell.ColumnIndex = 1), 'header navigation action');
    Check(not LOther.HeaderSelectionActive, 'navigation state shared between grids');
    LNav.Cancel(LSelection);
    Check(not LNav.HeaderSelectionActive, 'cancel did not reset header selection');
    Check(LNav.SearchCharacter(LColumns, LSelection, 3, LData.Prepare, LData.Text, 'a', 100, LRow, LColumn) and (LRow = 2), 'new search must start after focused row');
    h5uPlanCellFocus(LColumns, LSelection, 3, LData.RowKey, LRow, LColumn, False, LCell, LRange);
    LSelection.SetFocus(LCell, True);
    Check(LNav.SearchCharacter(LColumns, LSelection, 3, LData.Prepare, LData.Text, 'l', 100 + 200 / MSecsPerDay, LRow, LColumn)
      and (LRow = 2) and (LNav.SearchText = 'al'), 'continued search must include focused row');
    Check(LNav.SearchCharacter(LColumns, LSelection, 3, LData.Prepare, LData.Text, 'b', 100 + 1500 / MSecsPerDay, LRow, LColumn)
      and (LRow = 1) and (LNav.SearchText = 'b'), 'search timeout and wrap');
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
  LChanges: TArray<Th5uAdjacentGroupRowInfo>;
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
    LData.Controller.AppendValues(['group', 'level'], [TValue.From<string>('A'), TValue.From<Integer>(0)]);
    LData.Controller.AppendValues(['group', 'level'], [TValue.From<string>('A'), TValue.From<Integer>(1)]);
    LData.Controller.AppendValues(['group', 'level'], [TValue.From<string>('B'), TValue.From<Integer>(0)]);
    LData.Controller.AppendValues(['group', 'level'], [TValue.From<string>('B'), TValue.From<Integer>(1)]);
    LData.Controller.AppendValues(['group', 'level'], [TValue.From<string>('A'), TValue.From<Integer>(0)]);
    LGroups.Enabled := True;
    LGroups.IdColumnId := 'group';
    LGroups.InitialState := Th5uAdjacentGroupInitialState.Expanded;
    LTree.Enabled := True;
    LTree.LevelColumnId := 'level';
    LView := Th5uGridView.Create(LData, LColumns, LTree, LGroups, LData.GetController);
    LOther := Th5uGridView.Create(LData, LColumns, LTree, LGroups, LData.GetController);
    LView.OnAdjacentGroupStateChanged := LData.GroupChanged;
    Check((LView.GetViewRowCount = 5) and (LOther.GetViewRowCount = 5), 'initial view count');
    Check(LView.ChangeAdjacentGroup(0, False, True, LInfo), 'collapse first run');
    LView.DoAdjacentGroupStateChanged(LInfo);
    Check((LData.Events = 1) and (LView.GetViewRowCount = 4) and (LOther.GetViewRowCount = 5), 'per-view folding and event');
    Check((LView.GetViewSourceRowIndex(1) = 2) and (LView.GetViewRowKey(1) = LData.Controller.GetRowKey(2)), 'collapsed row/source mapping');
    Check(LView.GetViewValue(1, 'group').AsString = 'B', 'view value mapping');
    Check(LView.CanEditViewValue(1, 'level'), 'view edit permission');
    LView.SetViewValue(1, 'level', TValue.From<Integer>(0));
    Check(LView.GetTreeBranchEndInfo(2, LView.GetViewRowKey(2), LLevel, LClosed)
      and (LLevel = 1) and (LClosed = 1), 'tree branch closes at next visible row');
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
    Check(LMetrics.GetHeight(LOptions, LColumns, 0, LKey, True, LData.Measure, LData.Adjust) = 40, 'explicit height contributors');
    LBefore := LData.Measures;
    Check(LMetrics.GetHeight(LOptions, LColumns, 3, LKey, True, LData.Measure, LData.Adjust) = 40, 'cache follows row key');
    Check(LData.Measures = LBefore, 'height cache not reused');
    LOptions.MeasureScope := Th5uAutoHeightMeasureScope.AllVisibleColumns;
    LMetrics.Clear;
    Check(LMetrics.GetHeight(LOptions, LColumns, 0, LKey, True, LData.Measure, LData.Adjust) = 80, 'all visible contributors and hidden exclusion');
    LMetrics.Remove(LKey.ToString);
    LData.Cache := False;
    LData.Forced := True;
    LData.ForceHeight := 0;
    Check(LMetrics.GetHeight(LOptions, LColumns, 0, LKey, True, LData.Measure, LData.Adjust) = 1, 'event minimum height');
    LData.ForceHeight := 12.5;
    Check(LMetrics.GetHeight(LOptions, LColumns, 0, LKey, True, LData.Measure, LData.Adjust) = 12.5, 'fractional event height and cache opt-out');
    LData.Forced := False;
    Check(LMetrics.GetHeight(LOptions, LColumns, 0, LKey, False, LData.Measure, LData.Adjust) = 17, 'estimated height');
    LData.ExtentValue := 10.25;
    LTotal := h5uTotalRowHeight(LOptions, 3001, 0, True, LData.Prepare, LData.Extent);
    Check((LData.Prepared = 3001) and SameValue(LTotal.AsFloat, 3001 * 10.25), 'shared exact measurement threshold and fractional sum');
    LTotal := h5uTotalRowHeight(LOptions, h5uExactRowHeightLimit + 1, 0, True, LData.Prepare, LData.Extent);
    Check(LTotal.Whole = (h5uExactRowHeightLimit + 1) * LOptions.EstimatedHeight, 'large automatic-height estimate');
    LOptions.Mode := Th5uRowHeightMode.Fixed;
    LTotal := h5uTotalRowHeight(LOptions, LargeCount, 0, False, LData.Prepare, LData.Extent);
    Check(LTotal.Whole = LargeCount * LOptions.FixedHeight, 'Int64 total lost precision above 2^53');
    LData.ExtentValue := 20;
    Check((h5uFindFirstVisibleRow(5, Int64(40), 100, LData.Extent, LTop) = 2) and (LTop = 100), 'integer row boundary');
    LData.ExtentValue := 20.25;
    Check((h5uFindFirstVisibleRow(5, 40.75, 100.0, LData.Extent, LFloatTop) = 2) and SameValue(LFloatTop, 99.75), 'fractional row offset');
    Check((h5uFindFirstVisibleRow(5, -1.0, 100.0, LData.Extent, LFloatTop) = 0) and (LFloatTop = 100), 'negative offset clamp');
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
  LLayout: TArray<Th5uColumnLayoutInfo>;
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

begin
  try
    TestResizeBoundaries;
    TestNavigation;
    TestIndependentViews;
    TestRowMetrics;
    TestColumnLayout;
  except
    on E: Exception do
    begin
      Writeln(E.ClassName + ': ' + E.Message);
      ExitCode := 1;
    end;
  end;
end.
