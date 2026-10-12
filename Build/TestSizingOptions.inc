uses
  System.Classes, System.SysUtils, System.Rtti, System.Types, System.Math,
  System.UITypes, System.UIConsts,
  h5u.Grid.Columns, h5u.Grid.Types, h5u.Grid.Options, h5u.Grid.Sizing,
  h5u.Grid.Editors, h5u.Grid.Data.Virtual, h5u.FormDesigner.Properties,
  {$IFDEF TEST_FMX}
  FMX.Forms, FMX.Graphics, FMX.Controls, FMX.Types,
  Fmx.h5u.Grid, Fmx.h5u.FormDesigner;
  {$ELSE}
  Vcl.Forms, Vcl.Graphics, Vcl.Controls,
  Vcl.h5u.Grid, Vcl.h5u.FormDesigner;
  {$ENDIF}

type
  {$IFDEF TEST_FMX}
  TTestGrid = Th5uFmxGrid;
  TPropertyView = Th5uFmxPropertyEditor;
  TPaintControl = TControl;
  THeightContext = Th5uFmxGetRowHeightContext;
  THeight = Single;
  {$ELSE}
  TTestGrid = Th5uVclGrid;
  TPropertyView = Th5uVclPropertyEditor;
  TPaintControl = TWinControl;
  THeightContext = Th5uGetRowHeightContext;
  THeight = Integer;
  {$ENDIF}

  TMeasureSource = class
    HeightCalls, MeasureCalls, ValueCalls: Integer;
    Count: Int64;
    procedure RowCount(Sender: TObject; var ACount: Int64);
    procedure RowKey(Sender: TObject; ARow: Int64; var AKey: Th5uRowKey);
    procedure Value(Sender: TObject; ARow: Int64; const AField: string; var AValue: TValue);
    procedure Measure(Sender: TObject; const AContext: Th5uEditorContext; var AWidth: Single);
    procedure Height(Sender: TObject; const AContext: THeightContext;
      var AHeight: THeight; var ACacheResult: Boolean);
  end;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
  Writeln('PASS: ' + AMessage);
end;

procedure CheckNear(AExpected, AActual, ATolerance: Double; const AMessage: string);
begin
  Check(Abs(AExpected - AActual) <= ATolerance,
    AMessage + ' (expected ' + FloatToStr(AExpected) + ', actual ' + FloatToStr(AActual) + ')');
end;

procedure PaintOffscreen(AControl: TPaintControl);
var
  LBitmap: TBitmap;
begin
  {$IFDEF TEST_FMX}
  LBitmap := AControl.MakeScreenshot;
  {$ELSE}
  LBitmap := TBitmap.Create;
  LBitmap.SetSize(AControl.Width, AControl.Height);
  {$ENDIF}
  try
    {$IFNDEF TEST_FMX}
    AControl.PaintTo(LBitmap.Canvas.Handle, 0, 0);
    {$ENDIF}
    if (LBitmap.Width = 0) or (LBitmap.Height = 0) then
      raise Exception.Create('No offscreen frame');
  finally
    LBitmap.Free;
  end;
end;

function NewGrid(AForm: TForm): TTestGrid;
begin
  Result := TTestGrid.Create(AForm);
  Result.Parent := AForm;
  Result.Width := 640;
  Result.Height := 320;
  Result.ScrollHints.Enabled := False;
end;

function WriteGridText(AGrid: TTestGrid; AAncestor: TTestGrid = nil): string;
var
  LBinary: TMemoryStream;
  LText: TStringStream;
begin
  LBinary := TMemoryStream.Create;
  LText := TStringStream.Create;
  try
    LBinary.WriteDescendent(AGrid, AAncestor);
    LBinary.Position := 0;
    ObjectBinaryToText(LBinary, LText);
    Result := LText.DataString;
  finally
    LText.Free;
    LBinary.Free;
  end;
end;

function ReadGridText(AForm: TForm; const AText: string): TTestGrid;
var
  LBinary: TMemoryStream;
  LText: TStringStream;
begin
  Result := NewGrid(AForm);
  LBinary := TMemoryStream.Create;
  LText := TStringStream.Create(AText);
  try
    ObjectTextToBinary(LText, LBinary);
    LBinary.Position := 0;
    LBinary.ReadComponent(Result);
  finally
    LText.Free;
    LBinary.Free;
  end;
end;

procedure TestInheritedOptionDefaults;
var
  LForm: TForm;
  LAncestor, LChild: TTestGrid;
  LText: string;
begin
  LForm := TForm.CreateNew(nil);
  try
    LAncestor := NewGrid(LForm);
    LChild := NewGrid(LForm);
    LAncestor.Name := 'AncestorGrid';
    LChild.Name := 'ChildGrid';
    LAncestor.Header.RowHeight := 45;
    LChild.Header.RowHeight := 26;
    LAncestor.RowIndicator.Width := 60;
    LChild.RowIndicator.Width := 34;
    LAncestor.ColumnSizing.DefaultWidth := 200;
    LChild.ColumnSizing.DefaultWidth := 0;
    LAncestor.ColumnSizing.DefaultMaxWidth := 400;
    LChild.ColumnSizing.DefaultMaxWidth := 0;
    LAncestor.ColumnSizing.DefaultMinWidth := 12.5;
    LChild.ColumnSizing.DefaultMinWidth := 0;
    LAncestor.Spacing.RowSpacing := 1.25;
    LChild.Spacing.RowSpacing := 0;
    LAncestor.Spacing.DefaultColumnRightSpacing := 1.5;
    LChild.Spacing.DefaultColumnRightSpacing := 0;
    Th5uGridEditorItem(LAncestor.Editors.Add).DefaultMinWidth := 11.5;
    Th5uGridEditorItem(LChild.Editors.Add).DefaultMinWidth := 0;
    LText := WriteGridText(LChild, LAncestor);
    Check(Pos('Header.RowHeight = 26', LText) > 0, 'inherited header can reset to its default height');
    Check(Pos('RowIndicator.Width = 34', LText) > 0, 'inherited indicator can reset to its default width');
    Check(Pos('ColumnSizing.DefaultWidth = 0', LText) > 0, 'inherited column sizing can restore Default width');
    Check(Pos('ColumnSizing.DefaultMaxWidth = 0', LText) > 0, 'inherited column sizing can restore Default maximum');
    Check(Pos('ColumnSizing.DefaultMinWidth = 0', LText) > 0, 'inherited column sizing can restore Default minimum');
    Check(Pos('Spacing.RowSpacing = 0', LText) > 0, 'inherited row spacing can reset to zero');
    Check(Pos('Spacing.DefaultColumnRightSpacing = 0', LText) > 0, 'inherited column spacing can reset to zero');
    Check(Pos('DefaultMinWidth = 0', Copy(LText, Pos('Editors = <', LText), MaxInt)) > 0,
      'inherited editor minimum can reset to zero');
  finally
    LForm.Free;
  end;
end;

procedure TestGroupedOptionsAndStreaming;
var
  LForm: TForm;
  LGrid, LLoaded: TTestGrid;
  LModel: Th5uPropertyEditor;
  LColumn: Th5uGridColumn;
  LText, LName: string;
begin
  LForm := TForm.CreateNew(nil);
  LModel := Th5uPropertyEditor.Create(nil);
  try
    LGrid := NewGrid(LForm);
    LGrid.Name := 'ModernGrid';
    LGrid.Header.Visible := False;
    LGrid.Header.RowHeight := 41;
    LGrid.RowIndicator.Visible := False;
    LGrid.RowIndicator.Width := 52;
    LGrid.Editing.AllowEditing := False;
    LGrid.Editing.ImmediateEdit := True;
    LGrid.ColumnSizing.AutoWidthRowLimit := 777;
    LGrid.ColumnSizing.MinContentWidth := 80;
    LGrid.ColumnSizing.MaxContentWidth := 2000;
    LGrid.Appearance.Theme := Th5uGridTheme.Dark;
    LGrid.Appearance.DefaultCellColor := TColorRec.White;
    LGrid.Appearance.RowSpacingColor := TColorRec.Red;
    LGrid.Appearance.ColumnSpacingColor := TColorRec.Blue;
    LGrid.Appearance.ContentPaddingColor := TColorRec.Green;
    Check(not LGrid.ShowHeader and (LGrid.HeaderRowHeight = 41), 'legacy header aliases read grouped values');
    Check(not LGrid.ShowRowIndicator and (LGrid.RowIndicatorWidth = 52), 'legacy indicator aliases read grouped values');
    Check(not LGrid.AllowEditing and LGrid.ImmediateEdit, 'legacy editing aliases read grouped values');
    Check((LGrid.AutoWidthRowLimit = 777) and (LGrid.MinWidth = 80) and (LGrid.MaxWidth = 2000),
      'legacy sizing aliases read grouped values');
    LGrid.RowIndicatorWidth := 54;
    LGrid.HeaderRowHeight := 43;
    LGrid.AutoWidthRowLimit := 779;
    LGrid.Spacing.RowSpacingColor := TColorRec.Yellow;
    Check((LGrid.RowIndicator.Width = 54) and (LGrid.Header.RowHeight = 43)
      and (LGrid.ColumnSizing.AutoWidthRowLimit = 779), 'legacy setters forward to grouped options');
    Check(LGrid.Appearance.RowSpacingColor = TColorRec.Yellow, 'legacy spacing color alias forwards to Appearance');

    LModel.DataObject := LGrid;
    for LName in ['ColumnSizing', 'Header', 'RowIndicator', 'Editing', 'Appearance'] do
      Check(Assigned(LModel.FindProperty(LName)), 'published property model contains ' + LName);
    for LName in ['AutoWidthRowLimit', 'HeaderLayout', 'HeaderRowHeight', 'RowIndicatorWidth',
      'ShowHeader', 'ShowRowIndicator', 'AllowEditing', 'ImmediateEdit', 'Theme', 'MinWidth', 'MaxWidth'] do
      Check(not Assigned(LModel.FindProperty(LName)), 'published property model omits legacy alias ' + LName);

    LColumn := LGrid.Columns.Add;
    LColumn.Id := 'DefaultColumn';
    LColumn.Width := 0;
    LColumn := LGrid.Columns.Add;
    LColumn.Id := 'FractionColumn';
    LColumn.Width := -25.5;
    LColumn.MaxWidth := -200;
    LGrid.Header.Layout.RowCount := 2;
    LGrid.Header.Layout.Cells.Add.ColumnSpan := 2;
    LText := WriteGridText(LGrid);
    Check(Pos('SizingVersion = 1', LText) > 0, 'modern stream carries the sizing version');
    Check(Pos('Header.RowHeight', LText) > 0, 'modern stream stores grouped header path');
    Check(Pos('Appearance.RowSpacingColor', LText) > 0, 'modern stream stores grouped appearance path');
    Check((Pos('  HeaderRowHeight =', LText) = 0)
      and (Pos('  AutoWidthRowLimit =', LText) = 0)
      and (Pos('  HeaderLayout.', LText) = 0)
      and (Pos('  Spacing.RowSpacingColor', LText) = 0), 'legacy paths are not written alongside canonical paths');
    LGrid.Name := '';
    LLoaded := ReadGridText(LForm, LText);
    Check((LLoaded.Columns[0].Width = 0) and (LLoaded.Columns[0].MaxWidth = 0),
      'modern default width and maximum remain Default after roundtrip');
    Check((LLoaded.Columns[1].Width = -25.5) and (LLoaded.Columns[1].MaxWidth = -200),
      'fractional percent width and 200 percent maximum roundtrip');
    Check((LLoaded.Header.RowHeight = 43) and (LLoaded.Header.Layout.Cells.Count = 1),
      'grouped header layout and height roundtrip');
    Check((LLoaded.Appearance.RowSpacingColor = TColorRec.Yellow)
      and (LLoaded.Appearance.Theme = Th5uGridTheme.Dark), 'appearance colors and theme roundtrip');

    LText := 'object LegacyGrid: ' + TTestGrid.ClassName + sLineBreak
      + '  ShowHeader = False' + sLineBreak
      + '  HeaderRowHeight = 45' + sLineBreak
      + '  ShowRowIndicator = False' + sLineBreak
      + '  RowIndicatorWidth = 56' + sLineBreak
      + '  AllowEditing = False' + sLineBreak
      + '  ImmediateEdit = True' + sLineBreak
      + '  AutoWidthRowLimit = 901' + sLineBreak
      + '  MinWidth = 80' + sLineBreak
      + '  MaxWidth = 4000' + sLineBreak
      + '  Theme = Dark' + sLineBreak
      + '  Spacing.RowSpacingColor = clGreen' + sLineBreak
      + '  Spacing.ColumnSpacingColor = 123' + sLineBreak
      + '  Spacing.ContentPaddingColor = 456' + sLineBreak
      + '  Columns = <' + sLineBreak
      + '    item Id = ''OldDefault'' end' + sLineBreak
      + '    item Id = ''OldPercent'' WidthInPercent = 25.5 end>' + sLineBreak
      + '  HeaderLayout.Enabled = True' + sLineBreak
      + '  HeaderLayout.RowCount = 2' + sLineBreak
      + '  HeaderLayout.Cells = <' + sLineBreak
      + '    item Caption = ''Old group'' ColumnSpan = 2 WidthInPercent = 100 end>' + sLineBreak
      + 'end';
    LLoaded := ReadGridText(LForm, LText);
    Check(not LLoaded.Header.Visible and (LLoaded.Header.RowHeight = 45), 'old flat header properties load');
    Check(not LLoaded.RowIndicator.Visible and (LLoaded.RowIndicator.Width = 56), 'old flat indicator properties load');
    Check(not LLoaded.Editing.AllowEditing and LLoaded.Editing.ImmediateEdit, 'old flat editing properties load');
    Check((LLoaded.ColumnSizing.AutoWidthRowLimit = 901)
      and (LLoaded.ColumnSizing.MinContentWidth = 80)
      and (LLoaded.ColumnSizing.MaxContentWidth = 4000), 'old flat sizing properties load');
    Check((LLoaded.Appearance.RowSpacingColor = TColorRec.Green)
      and (LLoaded.Appearance.ColumnSpacingColor = 123)
      and (LLoaded.Appearance.ContentPaddingColor = 456), 'old spacing colors load by name and numeric value');
    Check((LLoaded.Columns[0].Width = 100) and (LLoaded.Columns[0].MaxWidth = 1000),
      'omitted old width and maximum retain historical defaults');
    CheckNear(-25.5, LLoaded.Columns[1].Width, 0.001, 'old WidthInPercent converts to the unified width');
    Check(LLoaded.Header.Layout.Enabled and (LLoaded.Header.Layout.Cells.Count = 1)
      and (LLoaded.Header.Layout.Cells[0].Width = -100), 'old nested HeaderLayout and percent width load');
  finally
    LModel.Free;
    LForm.Free;
  end;
end;

procedure TestPropertyEditorWidths;
var
  LForm: TForm;
  LView: TPropertyView;
  LModel: Th5uPropertyEditor;
  LColumn: Th5uGridColumn;
  LItem: Th5uPropertyItem;
  LCombo: TStringList;
  LTotal: Single;
begin
  LForm := TForm.CreateNew(nil);
  LModel := Th5uPropertyEditor.Create(nil);
  LCombo := TStringList.Create;
  try
    LView := TPropertyView.Create(LForm);
    LView.Parent := LForm;
    LView.Height := 300;
    Check((LView.Width = 350) and (LView.Columns[0].Width = -60)
      and (LView.Columns[1].Width = -40), 'property editor starts at 350 pixels with 60/40 specifications');
    PaintOffscreen(LView);
    LTotal := LView.Columns[0].LayoutWidth + LView.Columns[1].LayoutWidth;
    CheckNear(0.6, LView.Columns[0].LayoutWidth / LTotal, 0.005, 'property editor lays out 60/40 at initial width');
    LView.Width := 800;
    PaintOffscreen(LView);
    LTotal := LView.Columns[0].LayoutWidth + LView.Columns[1].LayoutWidth;
    CheckNear(0.6, LView.Columns[0].LayoutWidth / LTotal, 0.005, 'property editor keeps 60/40 after resize');
    LColumn := LView.Columns[0];
    LModel.DataObject := LColumn;
    LItem := LModel.FindProperty('Width');
    Check(Assigned(LItem), 'width is available through extended RTTI');
    LItem.DisplayValue := 'Default';
    Check((LColumn.Width = 0) and (LItem.DisplayValue = 'Default'), 'width editor parses and displays Default');
    LItem.DisplayValue := '25 %';
    Check((LColumn.Width = -25) and (LItem.DisplayValue = '25 %'), 'width editor parses and displays percentages');
    LItem.DisplayValue := '200 %';
    Check(LColumn.Width = -200, 'width editor accepts percentages above 100');
    LItem.DisplayValue := '175';
    Check((LColumn.Width = 175) and (LItem.DisplayValue = '175'), 'width editor accepts pixel values');
    LItem.DisplayValue := FloatToStr(175.25);
    Check(LColumn.Width = 175.25, 'width editor preserves fractional Single values through RTTI');
    LItem.DisplayValue := 'Unlimited';
    Check((LColumn.Width = h5uUnlimitedWidth) and (LItem.DisplayValue = 'Unlimited'),
      'width editor preserves the exactly representable Single Unlimited value');
    LModel.GetComboList(LItem, LCombo);
    Check(LCombo.IndexOf('Default') >= 0, 'width editor offers Default in its combo list');
  finally
    LCombo.Free;
    LModel.Free;
    LForm.Free;
  end;
end;

procedure TestSingleGeometryStreaming;
var
  LForm: TForm;
  LGrid, LLoaded: TTestGrid;
  LColumn: Th5uGridColumn;
  LEditor: Th5uGridEditorItem;
  LText: string;
begin
  Check(SizeOf(Th5uWidth) = SizeOf(Single), 'shared width specifications use Single storage');
  LForm := TForm.CreateNew(nil);
  try
    LGrid := NewGrid(LForm);
    LGrid.Name := 'SingleGeometryGrid';
    LGrid.ColumnSizing.DefaultWidth := 123.25;
    LGrid.ColumnSizing.DefaultMinWidth := 12.5;
    LGrid.ColumnSizing.DefaultMaxWidth := 500.75;
    LGrid.RowHeight.FixedHeight := 24.25;
    LGrid.RowHeight.MinHeight := 12.5;
    LGrid.RowHeight.MaxHeight := 160.75;
    LGrid.RowHeight.EstimatedHeight := 28.5;
    LGrid.Spacing.RowSpacing := 1.25;
    LGrid.Spacing.DefaultColumnRightSpacing := 1.5;
    LColumn := LGrid.Columns.Add;
    LColumn.Id := 'Fraction';
    LColumn.Width := 101.25;
    LColumn.MinWidth := 10.5;
    LColumn.MaxWidth := 400.75;
    LColumn.RightSpacing := 1.75;
    LEditor := Th5uGridEditorItem(LGrid.Editors.Add);
    LEditor.EditorName := 'FractionEditor';
    LEditor.DefaultWidth := 99.25;
    LEditor.DefaultMinWidth := 11.5;
    LEditor.DefaultMaxWidth := 450.75;
    LText := WriteGridText(LGrid);
    LGrid.Name := '';
    LLoaded := ReadGridText(LForm, LText);
    Check((LLoaded.ColumnSizing.DefaultWidth = 123.25)
      and (LLoaded.ColumnSizing.DefaultMinWidth = 12.5)
      and (LLoaded.ColumnSizing.DefaultMaxWidth = 500.75), 'fractional column defaults survive native streaming');
    Check((LLoaded.RowHeight.FixedHeight = 24.25) and (LLoaded.RowHeight.MinHeight = 12.5)
      and (LLoaded.RowHeight.MaxHeight = 160.75) and (LLoaded.RowHeight.EstimatedHeight = 28.5),
      'fractional height options survive native streaming');
    Check((LLoaded.Spacing.RowSpacing = 1.25) and (LLoaded.Spacing.DefaultColumnRightSpacing = 1.5),
      'fractional spacing survives native streaming');
    LColumn := LLoaded.Columns[0];
    Check((LColumn.Width = 101.25) and (LColumn.MinWidth = 10.5)
      and (LColumn.MaxWidth = 400.75) and (LColumn.RightSpacing = 1.75),
      'fractional column dimensions survive native streaming');
    LEditor := LLoaded.Editors.Find('FractionEditor');
    Check(Assigned(LEditor) and (LEditor.DefaultWidth = 99.25)
      and (LEditor.DefaultMinWidth = 11.5) and (LEditor.DefaultMaxWidth = 450.75),
      'fractional editor defaults survive native streaming');
  finally
    LForm.Free;
  end;
end;

procedure TMeasureSource.RowCount(Sender: TObject; var ACount: Int64);
begin
  ACount := Count;
end;

procedure TMeasureSource.RowKey(Sender: TObject; ARow: Int64; var AKey: Th5uRowKey);
begin
  AKey := Th5uRowKey.FromInt64(ARow + 1);
end;

procedure TMeasureSource.Value(Sender: TObject; ARow: Int64; const AField: string; var AValue: TValue);
begin
  Inc(ValueCalls);
  if ARow = 0 then
    AValue := TValue.From<string>(StringOfChar('W', 10000))
  else
    AValue := TValue.From<string>('Row ' + IntToStr(ARow));
end;

procedure TMeasureSource.Measure(Sender: TObject; const AContext: Th5uEditorContext; var AWidth: Single);
begin
  Inc(MeasureCalls);
end;

procedure TMeasureSource.Height(Sender: TObject; const AContext: THeightContext;
  var AHeight: THeight; var ACacheResult: Boolean);
begin
  Inc(HeightCalls);
  AHeight := 24;
  ACacheResult := True;
end;

procedure TestMeasurementAndAppearance;
var
  LForm: TForm;
  LGrid: TTestGrid;
  LSource: TMeasureSource;
  LController: Th5uVirtualController;
  LColumn: Th5uGridColumn;
  LEditor: Th5uGridEditorItem;
  LWidth: Single;
begin
  LForm := TForm.CreateNew(nil);
  LSource := TMeasureSource.Create;
  LSource.Count := 100000;
  try
    LGrid := NewGrid(LForm);
    LGrid.RowHeight.Mode := Th5uRowHeightMode.Automatic;
    LGrid.OnGetRowHeight := LSource.Height;
    LGrid.ColumnSizing.AutoWidthRowLimit := 0;
    LColumn := LGrid.Columns.Add;
    LColumn.Id := 'Text';
    LColumn.FieldName := 'Text';
    LColumn.DataType := Th5uColumnDataType.Text;
    LColumn.AutoHeight := True;
    LColumn.AutoWidth := True;
    LColumn.Editor := 'MeasuredText';
    LEditor := LGrid.Editors.AddVariant('MeasuredText', 'TextEditor');
    LEditor.OnMeasureWidth := LSource.Measure;
    LController := Th5uVirtualController.Create(LForm);
    LController.OnGetRowCount := LSource.RowCount;
    LController.OnGetRowKey := LSource.RowKey;
    LController.OnGetValue := LSource.Value;
    LGrid.DataController := LController;
    LSource.MeasureCalls := 0;
    LSource.ValueCalls := 0;
    LWidth := LGrid.MeasureColumnWidth(LColumn);
    Check(LWidth = 3000, 'default text maximum stops extreme text at 3000 pixels');
    Check((LSource.MeasureCalls = 1) and (LSource.ValueCalls < 10),
      '100000-row width scan stops after its first maximum-width value');
    LColumn.MaxWidth := 125;
    LSource.MeasureCalls := 0;
    LWidth := LGrid.MeasureColumnWidth(LColumn);
    Check((LWidth = 125) and (LSource.MeasureCalls = 1), 'explicit pixel cap stops measurement immediately');
    LSource.MeasureCalls := 0;
    PaintOffscreen(LGrid);
    Check((LColumn.MeasuredWidth = 125) and (LSource.MeasureCalls < 10),
      'automatic sizing uses the same bounded measurement');
    PaintOffscreen(LGrid);
    LSource.HeightCalls := 0;
    LSource.MeasureCalls := 0;
    LGrid.Appearance.DefaultCellColor := TColorRec.White;
    LGrid.Appearance.RowSpacingColor := TColorRec.Red;
    LGrid.Appearance.ColumnSpacingColor := TColorRec.Blue;
    LGrid.Appearance.ContentPaddingColor := TColorRec.Green;
    PaintOffscreen(LGrid);
    Check((LSource.HeightCalls = 0) and (LSource.MeasureCalls = 0),
      'appearance colors repaint without remeasuring heights or automatic widths');
    LGrid.Spacing.RowSpacingColor := TColorRec.Yellow;
    PaintOffscreen(LGrid);
    Check((LSource.HeightCalls = 0) and (LSource.MeasureCalls = 0),
      'legacy color alias also preserves geometry caches');
    LColumn.MaxWidth := 0;
    LEditor.DefaultMaxWidth := 200;
    PaintOffscreen(LGrid);
    Check(LColumn.MeasuredWidth = 200, 'automatic measurement observes the editor template maximum');
    LEditor.DefaultMaxWidth := 80;
    LSource.MeasureCalls := 0;
    PaintOffscreen(LGrid);
    Check((LColumn.MeasuredWidth = 80) and (LSource.MeasureCalls > 0),
      'changing editor template defaults invalidates cached automatic width');
    LGrid.ColumnSizing.DefaultMaxWidth := 50;
    LColumn.Visible := False;
    LWidth := LGrid.MeasureColumnWidth(LColumn);
    Check(LWidth = 50, 'explicit measurement of a hidden column resolves current grid defaults');
  finally
    LForm.Free;
    LSource.Free;
  end;
end;

procedure TestWidthDistribution;
var
  LForm: TForm;
  LGrid: TTestGrid;
  LCheck, LText: Th5uGridColumn;
  LGroup: Th5uHeaderLayoutCell;
  LBefore, LMonitorWidth: Double;
begin
  LForm := TForm.CreateNew(nil);
  try
    LGrid := NewGrid(LForm);
    LGrid.Spacing.SetAllSeparators(0);
    LGrid.RowIndicator.Visible := False;
    LGrid.Header.Visible := False;
    LGrid.Width := 600;
    LGrid.ColumnSizing.FitMode := Th5uColumnFitMode.AllColumns;
    LCheck := LGrid.Columns.Add;
    LCheck.Id := 'Check';
    LCheck.DataType := Th5uColumnDataType.Boolean;
    LText := LGrid.Columns.Add;
    LText.Id := 'Text';
    LText.DataType := Th5uColumnDataType.Text;
    LText.Width := 200;
    PaintOffscreen(LGrid);
    Check((LCheck.LayoutWidth = 28) and (LCheck.ResolvedMinWidth = 28)
      and (LCheck.ResolvedMaxWidth = 28), 'checkbox defaults remain fixed pixel constraints during fitting');
    LGrid.DefaultEditors.CheckBox := 'TextEditor';
    PaintOffscreen(LGrid);
    Check((LCheck.ResolvedMaxWidth = 3000) and (LCheck.ResolvedWidth = 100),
      'boolean data rendered by a text editor uses text sizing defaults');
    LGrid.DefaultEditors.CheckBox := 'CheckBoxEditor';
    PaintOffscreen(LGrid);
    LBefore := LText.LayoutWidth;
    LGrid.Width := 900;
    PaintOffscreen(LGrid);
    Check((LCheck.LayoutWidth = 28) and (LText.LayoutWidth > LBefore + 290),
      'larger viewport grows the text column while retaining checkbox width');
    LText.MaxWidth := 500;
    PaintOffscreen(LGrid);
    Check(LText.LayoutWidth = 500,
      'pixel maximum is not scaled to fill unused space (actual ' + FloatToStr(LText.LayoutWidth) + ')');
    LText.MaxWidth := 0;
    LText.MinWidth := 120;
    LGrid.Width := 80;
    PaintOffscreen(LGrid);
    Check((LCheck.LayoutWidth = 28) and (LText.LayoutWidth = 120),
      'pixel minima remain intact when viewport cannot contain them');

    LGrid.Width := 600;
    LCheck.DataType := Th5uColumnDataType.Text;
    LCheck.Width := 100;
    LText.Width := -50;
    LText.MinWidth := 0;
    PaintOffscreen(LGrid);
    CheckNear(3, LText.LayoutWidth / LCheck.LayoutWidth, 0.03,
      'all-column fitting combines pixels and percent-derived starting widths');
    LCheck.Width := -20;
    LText.Width := -20;
    PaintOffscreen(LGrid);
    CheckNear(LCheck.LayoutWidth, LText.LayoutWidth, 1, 'two visible 20 percent columns share the full width equally');
    LText.Visible := False;
    PaintOffscreen(LGrid);
    Check(LCheck.LayoutWidth >= 590, 'hidden columns do not consume proportional space');
    Check(LText.Width = -20, 'hiding preserves the desired width for later display');
    LText.Visible := True;

    LCheck.Width := -50;
    LCheck.MaxWidth := -25;
    LText.Width := -50;
    LGrid.Header.Layout.Enabled := True;
    LGrid.Header.Layout.RowCount := 2;
    LGroup := LGrid.Header.Layout.Cells.Add;
    LGroup.ColumnSpan := 2;
    LGroup.Width := -50;
    LGroup.MaxWidth := -50;
    PaintOffscreen(LGrid);
    CheckNear(75, LCheck.LayoutWidth, 1, 'nested percent maximum resolves against the parent group width');
    CheckNear(225, LText.LayoutWidth, 1, 'nested flexible sibling receives the remaining group width');
    LGrid.Width := 800;
    PaintOffscreen(LGrid);
    CheckNear(100, LCheck.LayoutWidth, 1, 'nested percent maximum recalculates after viewport resize');
    CheckNear(300, LText.LayoutWidth, 1, 'resized group distributes remaining space');

    LGrid.Header.Layout.Enabled := False;
    LGrid.ColumnSizing.FitMode := Th5uColumnFitMode.None;
    LGrid.ColumnSizing.MaxWidthSource := Th5uMaxWidthSource.Monitor;
    LCheck.MaxWidth := 0;
    LText.MaxWidth := 0;
    PaintOffscreen(LGrid);
    {$IFDEF TEST_FMX}
    LMonitorWidth := Screen.DisplayFromForm(LForm).Workarea.Width;
    {$ELSE}
    LMonitorWidth := Screen.MonitorFromWindow(LGrid.Handle).WorkareaRect.Width;
    {$ENDIF}
    CheckNear(LMonitorWidth, LText.ResolvedMaxWidth, 1, 'monitor maximum resolves to the current monitor work area');
  finally
    LForm.Free;
  end;
end;

begin
  try
    Application.Initialize;
    RegisterColorIntegerConsts;
    RegisterClass(TTestGrid);
    TestInheritedOptionDefaults;
    TestGroupedOptionsAndStreaming;
    TestPropertyEditorWidths;
    TestSingleGeometryStreaming;
    TestMeasurementAndAppearance;
    TestWidthDistribution;
    Writeln('PASS: sizing, grouped options, streaming, runtime property editor and measurement bounds');
  except
    on E: Exception do
    begin
      Writeln(E.ClassName + ': ' + E.Message);
      ExitCode := 1;
    end;
  end;
end.
