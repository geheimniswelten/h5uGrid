uses
  System.Classes, System.SysUtils, System.Rtti, System.Types, System.Math, System.UITypes,
  h5u.Grid.Columns, h5u.Grid.Types, h5u.Grid.Data.Virtual, h5u.Grid.Data.Objects,
  {$IFDEF TEST_FMX}
  FMX.Forms, FMX.Graphics, FMX.StdCtrls, FMX.Types, FMX.Controls, Fmx.h5u.Grid;
  {$ELSE}
  Vcl.Forms, Vcl.Graphics, Vcl.StdCtrls, Vcl.Controls, Vcl.h5u.Grid;
  {$ENDIF}

type
  {$IFDEF TEST_FMX}
  TTestGrid = Th5uFmxGrid;
  THeightContext = Th5uFmxGetRowHeightContext;
  THeight = Single;
  {$ELSE}
  TTestGrid = Th5uVclGrid;
  THeightContext = Th5uGetRowHeightContext;
  THeight = Integer;
  {$ENDIF}

  TRow = class(TPersistent)
  private
    FText: string;
  published
    property Text: string read FText write FText;
  end;

  TSource = class
    HeightCalls, KeyCalls, ValueCalls: Integer;
    ChangedRow: Int64;
    Count: Int64;
    CacheHeight: Boolean;
    ForcedHeight, RowSpacing: Integer;
    procedure RowCount(Sender: TObject; var ACount: Int64);
    procedure RowKey(Sender: TObject; ARow: Int64; var AKey: Th5uRowKey);
    procedure Value(Sender: TObject; ARow: Int64; const AField: string; var AValue: TValue);
    procedure Height(Sender: TObject; const AContext: THeightContext;
      var AHeight: THeight; var ACacheResult: Boolean);
    procedure Spacing(Sender: TObject; const AContext: THeightContext;
      var ASpacing: THeight);
  end;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
  Writeln('PASS: ' + AMessage);
end;

procedure TSource.RowCount(Sender: TObject; var ACount: Int64);
begin
  ACount := Count;
end;

procedure TSource.RowKey(Sender: TObject; ARow: Int64; var AKey: Th5uRowKey);
begin
  Inc(KeyCalls);
  AKey := Th5uRowKey.FromInt64(ARow + 1);
end;

procedure TSource.Value(Sender: TObject; ARow: Int64; const AField: string; var AValue: TValue);
begin
  Inc(ValueCalls);
  AValue := TValue.From<string>('Row ' + IntToStr(ARow) + ' wrapping text for automatic height');
end;

procedure TSource.Height(Sender: TObject; const AContext: THeightContext;
  var AHeight: THeight; var ACacheResult: Boolean);
begin
  Inc(HeightCalls);
  AHeight := 24 + (AContext.ViewRowIndex mod 3) * 12;
  if AContext.ViewRowIndex = ChangedRow then
    AHeight := AHeight + 20;
  if ForcedHeight > 0 then
    AHeight := ForcedHeight;
  ACacheResult := CacheHeight;
end;

procedure TSource.Spacing(Sender: TObject; const AContext: THeightContext;
  var ASpacing: THeight);
begin
  ASpacing := RowSpacing;
end;

function VerticalBar(AGrid: TTestGrid): TScrollBar;
var
  I: Integer;
begin
  for I := 0 to AGrid.ComponentCount - 1 do
    if AGrid.Components[I] is TScrollBar then
    begin
      Result := TScrollBar(AGrid.Components[I]);
      {$IFDEF TEST_FMX}
      if Result.Orientation = TOrientation.Vertical then
      {$ELSE}
      if Result.Kind = sbVertical then
      {$ENDIF}
        Exit;
    end;
  raise Exception.Create('Missing vertical scrollbar');
end;

procedure ScrollTo(AGrid: TTestGrid; AFraction: Double);
var
  Bar: TScrollBar;
  {$IFNDEF TEST_FMX}
  Position: Integer;
  {$ENDIF}
begin
  Bar := VerticalBar(AGrid);
  {$IFDEF TEST_FMX}
  Bar.Value := Max(0.0, Bar.Max - Bar.ViewportSize) * AFraction;
  {$ELSE}
  Position := Round(Max(0, Bar.Max - Bar.PageSize + 1) * AFraction);
  Bar.Position := Position;
  Bar.OnScroll(Bar, scPosition, Position);
  {$ENDIF}
end;

procedure PaintOffscreen(AGrid: TTestGrid);
var
  Bitmap: TBitmap;
begin
  {$IFDEF TEST_FMX}
  Bitmap := AGrid.MakeScreenshot;
  {$ELSE}
  Bitmap := TBitmap.Create;
  Bitmap.SetSize(AGrid.Width, AGrid.Height);
  {$ENDIF}
  try
    {$IFNDEF TEST_FMX}
    AGrid.PaintTo(Bitmap.Canvas.Handle, 0, 0);
    {$ENDIF}
    Check((Bitmap.Width > 0) and (Bitmap.Height > 0), 'offscreen frame available');
  finally
    Bitmap.Free;
  end;
end;

procedure TestScrolling;
var
  Form: TForm;
  Grid: TTestGrid;
  Source: TSource;
  Controller: Th5uVirtualController;
  Objects: Th5uObjectListController;
  Column: Th5uGridColumn;
  Row: TRow;
  I: Integer;
  Before: Int64;
begin
  Form := TForm.CreateNew(nil);
  Source := TSource.Create;
  Source.ChangedRow := -1;
  Source.Count := 3000000;
  Source.CacheHeight := True;
  try
    Grid := TTestGrid.Create(Form);
    Grid.Parent := Form;
    Grid.Width := 640;
    Grid.Height := 360;
    Grid.ScrollHints.Enabled := False;
    Grid.RowHeight.Mode := Th5uRowHeightMode.Automatic;
    Grid.OnGetRowHeight := Source.Height;
    Column := Grid.Columns.Add;
    Column.Id := 'Text';
    Column.FieldName := 'Text';
    Column.WidthInPercent := 100;
    Column.WordWrap := True;
    Column.AutoHeight := True;
    Controller := Th5uVirtualController.Create(Form);
    Controller.OnGetRowCount := Source.RowCount;
    Controller.OnGetRowKey := Source.RowKey;
    Controller.OnGetValue := Source.Value;
    Grid.DataController := Controller;
    Grid.Performance.Reset;
    PaintOffscreen(Grid);
    Check(Grid.Performance.Paint.Count > 0, 'public paint measurement records completed frames');
    Check(Grid.Performance.Layout.Count > 0, 'public layout measurement records layout work');
    Check(Grid.Performance.HeightMeasurement.Count > 0, 'public height measurement records cache misses');
    Source.HeightCalls := 0;
    PaintOffscreen(Grid);
    Check(Source.HeightCalls = 0, 'unchanged repaint reuses row heights despite scrollbar width negotiation');
    Source.KeyCalls := 0;
    Source.ValueCalls := 0;
    ScrollTo(Grid, 0.95);
    PaintOffscreen(Grid);
    Check((Source.KeyCalls < 2000) and (Source.ValueCalls < 2000),
      'three-million-row deep scroll visits only a bounded visible range');
    Source.HeightCalls := 0;
    PaintOffscreen(Grid);
    Check(Source.HeightCalls = 0, 'deep rows retain measured heights on the next frame');
    ScrollTo(Grid, 0);
    Source.HeightCalls := 0;
    PaintOffscreen(Grid);
    Check(Source.HeightCalls = 0, 'returning to previously drawn rows reuses their heights');
    Source.ChangedRow := 0;
    Source.HeightCalls := 0;
    Controller.NotifyRowChanged(0, 'Text');
    PaintOffscreen(Grid);
    Check(Source.HeightCalls = 1, 'single-row update invalidates only the affected measured height');
    Check(Grid.Performance.DataUpdate.Count > 0, 'public data update measurement includes notifications');
    Grid.Width := 500;
    Source.HeightCalls := 0;
    PaintOffscreen(Grid);
    Check(Source.HeightCalls > 0, 'committed column width change invalidates automatic heights');
    Before := Grid.Performance.Paint.Count;
    Grid.Performance.Enabled := False;
    PaintOffscreen(Grid);
    Check(Grid.Performance.Paint.Count = Before, 'disabled timing leaves counters unchanged');
    Grid.Performance.Enabled := True;
    Grid.Performance.Reset;
    Check((Grid.Performance.Paint.Count = 0) and (Grid.Performance.Layout.TotalMilliseconds = 0),
      'performance reset clears counts and durations');

    Grid.DataController := nil;
    Objects := Th5uObjectListController.Create(Form);
    Objects.OwnsObjects := True;
    Objects.BeginUpdate;
    try
      for I := 1 to 30000 do
      begin
        Row := TRow.Create;
        Row.Text := 'Object ' + IntToStr(I);
        Objects.Add(Row);
      end;
    finally
      Objects.EndUpdate;
    end;
    Grid.DataController := Objects;
    Source.HeightCalls := 0;
    ScrollTo(Grid, 0.95);
    PaintOffscreen(Grid);
    Check(Source.HeightCalls < 100, 'object controller deep scroll measures only visible rows');
    Source.HeightCalls := 0;
    PaintOffscreen(Grid);
    Check(Source.HeightCalls = 0, 'object controller repaint reuses heights');

    Grid.DataController := nil;
    Source.Count := 8;
    Source.CacheHeight := False;
    Source.ForcedHeight := 100;
    Grid.DataController := Controller;
    PaintOffscreen(Grid);
    Before := Round(VerticalBar(Grid).Max);
    Source.ForcedHeight := 200;
    PaintOffscreen(Grid);
    Check(Round(VerticalBar(Grid).Max) = Before + 800,
      'uncached dynamic heights update the scrollbar in the same frame');

    Source.CacheHeight := True;
    Source.RowSpacing := 1;
    Grid.OnGetRowSpacing := Source.Spacing;
    PaintOffscreen(Grid);
    Before := Round(VerticalBar(Grid).Max);
    Source.HeightCalls := 0;
    Source.RowSpacing := 41;
    PaintOffscreen(Grid);
    Check(Round(VerticalBar(Grid).Max) = Before + 320,
      'dynamic spacing updates the exact total including offscreen rows');
    Check(Source.HeightCalls = 0, 'dynamic spacing retains cached content heights');
    Writeln('PASS: scrolling, cache invalidation and public performance counters');
  finally
    Form.Free;
    Source.Free;
  end;
end;

begin
  try
    Application.Initialize;
    TestScrolling;
  except
    on E: Exception do
    begin
      Writeln(E.ClassName + ': ' + E.Message);
      ExitCode := 1;
    end;
  end;
end.
