program TestFmxTouchPrecision;

{$APPTYPE CONSOLE}
{$SCOPEDENUMS ON}

uses
  System.Classes, System.SysUtils, System.Rtti, System.Types, System.Math,
  System.UITypes,
  FMX.Forms, FMX.Controls, FMX.Graphics, FMX.StdCtrls, FMX.Types,
  h5u.Grid.Types, h5u.Grid.Sizing, h5u.Grid.Editors,
  h5u.Grid.Data.Virtual, Fmx.h5u.Grid;

type
  TTestGrid = class(ThiiGrid)
  public
    procedure Pan(const APoint: TPointF; AFlags: TInteractiveGestureFlags);
  end;

  TSource = class
    procedure Count(Sender: TObject; var ACount: Int64);
    procedure Value(Sender: TObject; ARow: Int64; const AField: string; var AValue: TValue);
    procedure Measure(Sender: TObject; const AContext: ThiiEditorContext; var AWidth: Single);
  end;

procedure TTestGrid.Pan(const APoint: TPointF; AFlags: TInteractiveGestureFlags);
var
  Event: TGestureEventInfo;
  Handled: Boolean;
begin
  Event := Default(TGestureEventInfo);
  Event.GestureID := igiPan;
  Event.Flags := AFlags;
  Event.Location := LocalToAbsolute(APoint);
  Handled := False;
  DoGesture(Event, Handled);
  if not Handled then
    raise Exception.Create('Pan was not handled');
end;

procedure TSource.Count(Sender: TObject; var ACount: Int64);
begin
  ACount := 3000000;
end;

procedure TSource.Value(Sender: TObject; ARow: Int64; const AField: string; var AValue: TValue);
begin
  AValue := TValue.From<string>('Fractional width');
end;

procedure TSource.Measure(Sender: TObject; const AContext: ThiiEditorContext; var AWidth: Single);
begin
  AWidth := 30.25;
end;

procedure CheckNear(AExpected, AActual: Double; const AMessage: string);
begin
  if Abs(AActual - AExpected) > 0.0001 then
    raise Exception.Create(AMessage + ': expected ' + FloatToStr(AExpected) + ', actual ' + FloatToStr(AActual));
  Writeln('PASS: ' + AMessage);
end;

function VerticalBar(AGrid: TTestGrid): TScrollBar;
var
  I: Integer;
begin
  for I := 0 to AGrid.ComponentCount - 1 do
    if AGrid.Components[I] is TScrollBar then
    begin
      Result := TScrollBar(AGrid.Components[I]);
      if Result.Orientation = TOrientation.Vertical then
        Exit;
    end;
  raise Exception.Create('No vertical scrollbar');
end;

procedure TestPrecision;
var
  Form: TForm;
  Grid: TTestGrid;
  Source: TSource;
  Controller: ThiiVirtualController;
  Bitmap: TBitmap;
  Bar: TScrollBar;
  Start: Double;
begin
  Form := TForm.CreateNew(nil);
  Source := TSource.Create;
  try
    Controller := ThiiVirtualController.Create(Form);
    Controller.OnGetRowCount := Source.Count;
    Controller.OnGetValue := Source.Value;
    Grid := TTestGrid.Create(Form);
    Grid.Parent := Form;
    Grid.SetBounds(0, 0, 640, 320);
    Grid.ScrollHints.Enabled := False;
    Grid.RowIndicator.Visible := False;
    Grid.RowHeight.Mode := ThiiRowHeightMode.Fixed;
    Grid.RowHeight.FixedHeight := 32.75;
    Grid.Spacing.RowSpacing := 0.25;
    Grid.ColumnSizing.FitMode := ThiiColumnFitMode.None;
    Grid.ColumnSizing.AutoWidthRowLimit := 1;
    Grid.Editors.AddVariant('Fractional', 'TextEditor').OnMeasureWidth := Source.Measure;
    Grid.Columns.Add.Id := 'Value';
    Grid.Columns[0].FieldName := 'Value';
    Grid.Columns[0].Editor := 'Fractional';
    Grid.Columns[0].AutoWidth := True;
    Grid.DataController := Controller;
    // Offscreen rendering only. The form is never shown and no control gets focus.
    Bitmap := Grid.MakeScreenshot;
    Bitmap.Free;
    CheckNear(30.25, Grid.MeasureColumnWidth(Grid.Columns[0], 0, 1), 'fractional column measurement');
    CheckNear(30.25, Grid.Columns[0].LayoutWidth, 'fractional column layout');
    Bar := VerticalBar(Grid);
    CheckNear(99000000, Bar.Max, 'fractional row extents accumulated as a large total');
    Start := 67000001.25;
    Bar.Value := Start;
    Grid.Pan(PointF(100, 100), [TInteractiveGestureFlag.gfBegin]);
    Grid.Pan(PointF(100, 90.25), []);
    CheckNear(Start + 9.75, Bar.Value, 'touch preserves a large offset and a fractional delta');
    Grid.Pan(PointF(100, 90.25), [TInteractiveGestureFlag.gfEnd]);
    Start := Bar.Value;
    Grid.Pan(PointF(100, 100), [TInteractiveGestureFlag.gfBegin]);
    Grid.Pan(PointF(100, 90.5), [TInteractiveGestureFlag.gfEnd]);
    CheckNear(Start + 9.5, Bar.Value, 'a new touch gesture preserves the previous exact offset');
  finally
    Form.Free;
    Source.Free;
  end;
end;

begin
  try
    Application.Initialize;
    TestPrecision;
  except
    on E: Exception do
    begin
      Writeln(E.ClassName + ': ' + E.Message);
      Halt(1);
    end;
  end;
end.
