program TestVclFractionalSpacing;

{$APPTYPE CONSOLE}
{$SCOPEDENUMS ON}

uses
  System.Classes, System.SysUtils, System.Rtti, System.Types, System.Math,
  Vcl.Forms, Vcl.Controls, Vcl.Graphics, Vcl.StdCtrls,
  h5u.Grid.Types, h5u.Grid.Sizing, h5u.Grid.Columns,
  h5u.Grid.Data.Virtual, Vcl.h5u.Grid;

type
  TSource = class
    procedure Count(Sender: TObject; var ACount: Int64);
    procedure Value(Sender: TObject; ARow: Int64; const AField: string; var AValue: TValue);
  end;

  TColumnBounds = record
    Left, Right, SpacingRight, ClipLeft, ClipRight: Integer;
  end;

procedure TSource.Count(Sender: TObject; var ACount: Int64);
begin
  ACount := 2;
end;

procedure TSource.Value(Sender: TObject; ARow: Int64; const AField: string; var AValue: TValue);
begin
  AValue := TValue.Empty;
end;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

procedure ScrollTo(AGrid: ThiiGrid; APosition: Integer);
var
  I: Integer;
  Bar: TScrollBar;
begin
  for I := 0 to AGrid.ComponentCount - 1 do
    if AGrid.Components[I] is TScrollBar then
    begin
      Bar := TScrollBar(AGrid.Components[I]);
      if Bar.Kind = sbHorizontal then
      begin
        Check(Bar.Visible, 'Horizontal scrollbar unavailable');
        Bar.Position := APosition;
        Bar.OnScroll(Bar, scPosition, APosition);
        Check(AGrid.HorizontalOffset = APosition, 'Horizontal scroll offset was not applied');
        Exit;
      end;
    end;
  raise Exception.Create('Missing horizontal scrollbar');
end;

procedure TestSpacing(ASpacing: Single; AScenario: Integer);
const
  ColumnCount = 4;
  ColumnWidth = 100;
  ViewLeft = 1;
  BodyY = 34;
  HeaderY = 10;
var
  Form: TForm;
  Grid: ThiiGrid;
  Source: TSource;
  Controller: ThiiVirtualController;
  Bitmap: TBitmap;
  Header: ThiiHeaderLayoutCell;
  Bounds: array[0..ColumnCount - 1] of TColumnBounds;
  I, X, FirstRight, IndicatorRight, ViewRight: Integer;
  CellLeft, CellRight: Integer;
  DataLeft, NextLeft, RightStart, LogicalRight, LogicalSpacingRight: Single;
  HeaderSpacing, BodySpacing, ExpectedCell: Boolean;
  Hit: ThiiHitTestInfo;
  Name: string;
begin
  Name := Format('spacing %s, scenario %d', [FloatToStr(ASpacing), AScenario]);
  Form := TForm.CreateNew(nil);
  Source := TSource.Create;
  Bitmap := TBitmap.Create;
  try
    Controller := ThiiVirtualController.Create(Form);
    Controller.OnGetRowCount := Source.Count;
    Controller.OnGetValue := Source.Value;
    Grid := ThiiGrid.Create(Form);
    Grid.Parent := Form;
    if AScenario = 3 then
      Grid.SetBounds(0, 0, 320, 160)
    else
      Grid.SetBounds(0, 0, 540, 160);
    Grid.ScrollHints.Enabled := False;
    Grid.Header.RowHeight := 24;
    Grid.RowHeight.Mode := ThiiRowHeightMode.Fixed;
    Grid.RowHeight.FixedHeight := 24;
    Grid.RowIndicator.Visible := AScenario = 1;
    Grid.RowIndicator.Width := 34;
    Grid.Spacing.Left := 0;
    Grid.Spacing.Right := 0;
    Grid.Spacing.Top := 0;
    Grid.Spacing.Bottom := 0;
    Grid.Spacing.RowSpacing := 0;
    Grid.Spacing.DefaultColumnRightSpacing := ASpacing;
    Check(Grid.GridLines, Name + ': fractional column spacing must enable GridLines');
    Grid.GridLines := False;
    Check((Grid.Spacing.DefaultColumnRightSpacing = 0) and not Grid.GridLines, Name + ': GridLines must clear the fractional default spacing');
    Grid.Spacing.DefaultColumnRightSpacing := ASpacing;
    Grid.Spacing.Left := ViewLeft;
    Grid.Appearance.ColumnSpacingColor := clFuchsia;
    Grid.Appearance.DefaultCellColor := clWhite;
    Grid.ColumnSizing.FitMode := ThiiColumnFitMode.None;
    for I := 0 to ColumnCount - 1 do
    begin
      Grid.Columns.Add.Id := 'Column' + IntToStr(I);
      Grid.Columns[I].FieldName := Grid.Columns[I].Id;
      Grid.Columns[I].Width := ColumnWidth;
    end;
    if AScenario = 2 then
    begin
      Grid.Header.Layout.Enabled := True;
      for I := 0 to 1 do
      begin
        Header := Grid.Header.Layout.Cells.Add;
        Header.LayoutColumn := I * 2;
        Header.ColumnSpan := 2;
      end;
    end;
    if AScenario = 3 then
    begin
      Grid.Columns[0].FixedKind := ThiiFixedKind.Left;
      Grid.Columns[3].FixedKind := ThiiFixedKind.Right;
    end;
    Grid.DataController := Controller;
    Bitmap.SetSize(Grid.Width, Grid.Height);
    // Render only into a bitmap. No Show, focus, mouse or keyboard input.
    Grid.PaintTo(Bitmap.Canvas.Handle, 0, 0);
    if AScenario = 3 then
    begin
      ScrollTo(Grid, 23);
      Grid.PaintTo(Bitmap.Canvas.Handle, 0, 0);
    end;

    ViewRight := Grid.ClientWidth;
    DataLeft := ViewLeft;
    IndicatorRight := ViewLeft;
    if AScenario = 1 then
    begin
      IndicatorRight := ViewLeft + 34;
      DataLeft := ViewLeft + 34 + ASpacing;
    end;
    FirstRight := Round(DataLeft);
    NextLeft := DataLeft;
    RightStart := ViewRight;
    if AScenario = 3 then
      RightStart := ViewRight - ColumnWidth - ASpacing;
    for I := 0 to ColumnCount - 1 do
    begin
      if (AScenario = 3) and (I = 3) then
        NextLeft := RightStart;
      Bounds[I].Left := Round(NextLeft);
      LogicalRight := NextLeft + ColumnWidth;
      LogicalSpacingRight := NextLeft + ColumnWidth + ASpacing;
      Bounds[I].Right := Round(LogicalRight);
      Bounds[I].SpacingRight := Round(LogicalSpacingRight);
      Bounds[I].ClipLeft := Round(DataLeft);
      Bounds[I].ClipRight := ViewRight;
      if (AScenario = 3) and (I in [1, 2]) then
      begin
        Bounds[I].ClipLeft := Round(DataLeft + ColumnWidth + ASpacing);
        Bounds[I].ClipRight := Round(RightStart);
      end;
      NextLeft := LogicalSpacingRight;
      if (AScenario = 3) and (I = 0) then
        NextLeft := NextLeft - 23;
    end;

    for X := ViewLeft to ViewRight - 1 do
    begin
      BodySpacing := (X >= IndicatorRight) and (X < FirstRight);
      HeaderSpacing := BodySpacing;
      ExpectedCell := False;
      for I := 0 to ColumnCount - 1 do
      begin
        CellLeft := Max(Bounds[I].Left, Bounds[I].ClipLeft);
        CellRight := Min(Bounds[I].Right, Bounds[I].ClipRight);
        if (X >= CellLeft) and (X < CellRight) then
        begin
          ExpectedCell := True;
          Hit := Grid.HitTest(X, BodyY);
          Check((Hit.Kind = ThiiHitKind.DataCell) and (Hit.Column = Grid.Columns[I]), Name + ': wrong hit column at ' + IntToStr(X));
          Check((Hit.Bounds.Left = CellLeft) and (Hit.Bounds.Right = CellRight), Name + ': hit bounds differ from the native cell edges');
        end;
        if (X >= Max(Bounds[I].Right, Bounds[I].ClipLeft)) and (X < Min(Bounds[I].SpacingRight, Bounds[I].ClipRight)) then
        begin
          BodySpacing := True;
          if (AScenario <> 2) or Odd(I) then
            HeaderSpacing := True;
        end;
      end;
      Check((ColorToRGB(Bitmap.Canvas.Pixels[X, BodyY]) = ColorToRGB(clFuchsia)) = BodySpacing,
        Name + ': body separator pixel differs at ' + IntToStr(X));
      Check((ColorToRGB(Bitmap.Canvas.Pixels[X, HeaderY]) = ColorToRGB(clFuchsia)) = HeaderSpacing,
        Name + ': header separator pixel differs at ' + IntToStr(X));
      if not ExpectedCell and (X >= FirstRight) then
        Check(Grid.HitTest(X, BodyY).Kind = ThiiHitKind.None, Name + ': separator or empty area was hittable at ' + IntToStr(X));
    end;
    Check(not Form.Visible, 'Test form became visible');
    Writeln('PASS: native edges, separator pixels and hit testing for ' + Name);
  finally
    Bitmap.Free;
    Form.Free;
    Source.Free;
  end;
end;

var
  Scenario: Integer;
begin
  try
    Application.Initialize;
    for Scenario := 0 to 3 do
    begin
      TestSpacing(0.5, Scenario);
      TestSpacing(1.25, Scenario);
    end;
  except
    on E: Exception do
    begin
      Writeln(E.ClassName + ': ' + E.Message);
      Halt(1);
    end;
  end;
end.
