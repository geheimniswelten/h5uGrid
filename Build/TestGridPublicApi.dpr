program TestGridPublicApi;

{$APPTYPE CONSOLE}
{$SCOPEDENUMS ON}

uses
  System.SysUtils, System.Classes,
  {$IFDEF TEST_FMX}
  Fmx.Forms, Fmx.h5u.Grid;
  {$ELSE}
  Vcl.Forms, Vcl.h5u.Grid;
  {$ENDIF}

var
  Grid, Copy: ThiiGrid;
  Column: ThiiGridColumn;
  Sizing: ThiiColumnSizingOptions;
  Header: ThiiGridHeaderOptions;
  Selection: ThiiGridSelection;
  RowKey: ThiiRowKey;
  CellEvent: ThiiCellEvent;
  HeightEvent: ThiiGetRowHeightEvent;
  Stream: TMemoryStream;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

begin
  try
    Application.Initialize;
    RegisterClass(ThiiGrid);
    Grid := ThiiGrid.Create(nil);
    Copy := nil;
    Stream := TMemoryStream.Create;
    try
      Check(Grid is ThiiCustomGrid, 'Public grid ancestry');
      Check(Grid.ClassName = 'ThiiGrid', 'Framework-independent component class name');
      Sizing := Grid.ColumnSizing;
      Sizing.FitMode := ThiiColumnFitMode.AllColumns;
      Header := Grid.Header;
      Header.Visible := True;
      Selection := Grid.Selection;
      Selection.AllowedKinds := [ThiiSelectionKind.Rows];
      RowKey := ThiiRowKey.FromInt64(42);
      Check(RowKey.ToString = '42', 'Row key alias');
      CellEvent := nil;
      HeightEvent := nil;
      Grid.OnCellClick := CellEvent;
      Grid.OnGetRowHeight := HeightEvent;
      Column := Grid.Columns.Add;
      Column.Id := 'value';
      Column.DataType := ThiiColumnDataType.Integer;
      Column.Width := 123;
      Check(Column.ClassName = 'ThiiGridColumn', 'Canonical column class through alias');
      Stream.WriteComponent(Grid);
      Stream.Position := 0;
      Copy := ThiiGrid(Stream.ReadComponent(nil));
      Check(Copy.ClassName = 'ThiiGrid', 'New grid class resolves when streamed');
      Check((Copy.Columns.Count = 1) and (Copy.Columns[0].Width = 123), 'Column collection round trip');
      Check(Copy.ColumnSizing.FitMode = ThiiColumnFitMode.AllColumns, 'Options and scoped enum round trip');
      Writeln('PASS: single framework grid unit, public aliases, class identity and streaming');
    finally
      Copy.Free;
      Stream.Free;
      Grid.Free;
    end;
  except
    on E: Exception do
    begin
      Writeln(E.ClassName + ': ' + E.Message);
      Halt(1);
    end;
  end;
end.
