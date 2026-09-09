program TestCommonBehavior;

{$APPTYPE CONSOLE}
{$SCOPEDENUMS ON}

uses
  System.SysUtils,
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

begin
  try
    TestResizeBoundaries;
    TestNavigation;
  except
    on E: Exception do
    begin
      Writeln(E.ClassName + ': ' + E.Message);
      ExitCode := 1;
    end;
  end;
end.
