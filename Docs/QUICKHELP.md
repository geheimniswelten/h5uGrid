# h5u.Grid – Kurzhilfe für Entwickler

## 1. Benötigte Units

VCL:

```pascal
uses
  h5u.Grid.Types,
  h5u.Grid.Columns,
  h5u.Grid.Data.DataSet,
  Vcl.h5u.Grid;
```

Mit `Vcl` in den Delphi Unit Scope Names kann die letzte Unit verkürzt als `h5u.Grid` verwendet werden.

FMX:

```pascal
uses
  h5u.Grid.Types,
  h5u.Grid.Columns,
  h5u.Grid.Data.DataSet,
  FMX.h5u.Grid;
```

Mit `FMX` als Unit Scope Name ebenfalls kurz als `h5u.Grid`.

## 2. DataSet verbinden

Auf dem Formular:

```text
Th5uSampleClientDataSet
TDataSource
Th5uDataSetController
Th5uVclGrid oder Th5uFmxGrid
```

Verknüpfung:

```pascal
DataSource1.DataSet := SampleClientDataSet1;
DataSetController1.DataSource := DataSource1;
Grid1.DataController := DataSetController1;
```

Automatische Columns können im Demoformular erzeugt beziehungsweise bei Bedarf explizit angelegt werden. Für stabile Layouts immer eine feste `Column.Id` vergeben.

## 3. Column anlegen

Sinngemäß:

```pascal
with Grid1.Columns.Add do
begin
  Id := 'description';
  FieldName := 'DESCRIPTION';
  Caption := 'Beschreibung';
  Width := 280;
  Text.WordWrap := True;
  Text.AutoHeight := True;
  Text.MaxHeight := 100;
end;
```

Bildspalte:

```pascal
with Grid1.Columns.Add do
begin
  Id := 'picture';
  FieldName := 'PICTURE';
  Caption := 'Bild';
  EditorKind := Th5uColumnEditorKind.Image;
  Width := 90;
end;
```

Die exakten Deklarationen dieses Teststands stehen in [`API-EXTRACT.md`](API-EXTRACT.md).

## 4. Objektliste

```pascal
ObjectController1.ItemClass := TCustomer;
ObjectController1.AddObject(ACustomer);
Grid1.DataController := ObjectController1;
```

Die `FieldName`-/Binding-Angabe einer Column entspricht dem RTTI-Propertynamen. Verschachtelte Propertypfade können vom Controller vorbereitet und gecacht werden.

Der Cache kann für direkte, günstige Getter abgeschaltet werden:

```pascal
ObjectController1.Cache.Mode := Th5uDataCacheMode.None;
```

## 5. Virtuelle Live-Daten

Die Quelle stellt Werte über Events bereit:

```pascal
procedure TForm1.VirtualGetRowCount(
  Sender: TObject;
  var ACount: Int64);
begin
  ACount := FRows.Count;
end;

procedure TForm1.VirtualGetValue(
  Sender: TObject;
  const ARowKey: Th5uRowKey;
  const AColumnId: string;
  var AValue: TValue);
begin
  // Wert aus eigener Quelle liefern
end;
```

Nach Liveänderungen nicht zwingend alles neu laden. Je nach Änderung kann der Controller eine Row, mehrere Cells oder die gesamte Abbildung invalidieren. Die Demo `VirtualLive` zeigt den laufenden Append-/Update-Pfad.

## 6. Factory pro Grid

Globalen Standard nur dann verwenden, wenn wirklich alle Grids betroffen sein sollen. Für lokale Anpassungen:

```pascal
Grid1.FactoryScope.RegisterOverride(
  h5uClassIdGridDataCell,
  TMyDataCell
);
```

Kontextabhängige Regel:

```pascal
Grid1.FactoryScope.RegisterRule(
  h5uClassIdGridDataCell,
  TMyPriorityCell,
  function(const AContext: Th5uFactoryContext): Boolean
  begin
    Result :=
      Assigned(AContext.Column) and
      SameText(AContext.Column.Id, 'priority');
  end
);
```

Die Factory-Ereignisse erhalten stets `AContext.Grid`. Damit kann auch eine Shared Factory pro Grid unterscheiden.

Wichtige Hooks:

```text
Get...Class / OnGetClass
OnCreateInstance
OnConfigureInstance
OnBindInstance
OnUnbindInstance
```

`OnConfigureInstance` ist für einmalige Defaults gedacht. Werte der jeweils gebundenen Row/Cell gehören in `OnBindInstance`.

## 7. Variable Zeilenhöhe

```pascal
DescriptionColumn.Text.WordWrap := True;
DescriptionColumn.Text.AutoHeight := True;
DescriptionColumn.Text.MaxHeight := 120;
```

Nach externer Änderung:

```pascal
Grid1.InvalidateRowHeight(ARowKey);
```

Event:

```pascal
procedure TForm1.GridGetRowHeight(
  Sender: TObject;
  const AContext: Th5uGetRowHeightContext;
  var AHeight: Single;
  var ACacheResult: Boolean);
begin
  if AContext.RowKey = FExpandedRow then
    AHeight := 140;
end;
```

`AHeight` enthält den automatisch gemessenen Vorschlag.

## 8. Scrollmodus

```pascal
Grid1.Scrolling.VerticalMode := Th5uVerticalScrollMode.Pixel;
```

Alternativen:

```text
Pixel
WholeRows
PixelSnap
```

Bei sehr hohen Rows bleibt innerhalb der Row Pixelbewegung möglich.

## 9. Thumb-Hint

Vertikalen Inhalt aus einer Column beziehen:

```pascal
Grid1.ScrollHints.Vertical.ColumnId := 'name';
```

Horizontal:

```pascal
NameColumn.ScrollHintText := 'Kunde';
```

Vorschlag ändern:

```pascal
procedure TForm1.GridGetThumbHint(
  Sender: TObject;
  const AContext: Th5uThumbHintContext;
  var AText: string;
  var AVisible: Boolean);
begin
  if AContext.Axis = Th5uScrollAxis.Vertical then
    AText := Format('%s – Zeile %d', [
      AText,
      AContext.ViewRowIndex + 1
    ]);
end;
```

## 10. Selektion

Aktivierbare Arten:

```pascal
Grid1.Selection.AllowedKinds := [
  Th5uSelectionKind.Rows,
  Th5uSelectionKind.Columns,
  Th5uSelectionKind.CellRanges
];
```

Mischbetrieb:

```pascal
Grid1.Selection.CombinationMode :=
  Th5uSelectionCombinationMode.Mixed;
Grid1.Selection.MultiRange := True;
```

Bedienung:

```text
Row Indicator / Zeilenbereich   ganze Row
Column Header                   ganze Column
Datenbereich ziehen             Zellbereich
Shift                           Bereich erweitern
Ctrl                            Bereich ergänzen oder entfernen
```

## 11. Column verschieben oder ausblenden

```pascal
Grid1.Customization.AllowColumnMoving := True;
Grid1.Customization.AllowColumnHiding := True;

AmountColumn.Visible := False;
AmountColumn.VisibleIndex := 2;
```

Die Column bleibt als logisches Objekt erhalten und kann weiterhin Filter-, StyleKey- oder Thumb-Hint-Quelle sein.

## 12. Periodische Row-Styles

Jede fünfte Zeile:

```pascal
with Grid1.RowAppearance.Patterns.Add do
begin
  RepeatEvery := 5;
  FirstPosition := 5;
  MatchCount := 1;
  StyleName := 'EveryFifthRow';
end;
```

Odd/Even kann als vordefinierte Zweierrhythmik betrachtet werden.

## 13. RowStyle aus einer Column

```pascal
Grid1.RowAppearance.StyleKey.ColumnId := 'priority';
Grid1.RowAppearance.StyleKey.Mappings.AddInteger(0, 'NormalRow');
Grid1.RowAppearance.StyleKey.Mappings.AddInteger(1, 'InfoRow');
Grid1.RowAppearance.StyleKey.Mappings.AddInteger(2, 'WarningRow');
Grid1.RowAppearance.StyleKey.Mappings.AddInteger(3, 'ErrorRow');
```

Die StyleKey-Column darf unsichtbar sein.

## 14. Cache und Paging

```pascal
DataSetController1.Cache.Mode := Th5uDataCacheMode.Paged;
DataSetController1.Cache.PageSize := 100;
DataSetController1.Cache.MaxCachedPages := 8;

Grid1.Pagination.Mode := Th5uPaginationMode.NumberedPages;
Grid1.Pagination.PageSize := 50;
Grid1.Pagination.PageIndex := 0;
```

Cache-Seiten sind interne Ladeeinheiten. Sichtbare Pagination ist eine UI-/Queryentscheidung; beides darf unabhängig konfiguriert werden.

## 15. Bildwerte

Akzeptiert werden im Prototyp insbesondere:

- `TBlobField`
- `TBytes`
- Stream-basierte Binärwerte des Controllers

Der Plattformrenderer dekodiert das Bild erst für sichtbare Zellen. Der echte `TImage`-Editor wird nur für die aktive Bearbeitung erzeugt.

## 16. Aktualisierung nach Datenänderungen

Je genauer die Benachrichtigung, desto weniger Arbeit:

```text
nur Cell geändert       Cell/Row invalidieren
Row geändert            Row-Snapshot und RowHeight invalidieren
Row eingefügt           Mapping und Scrollmetriken aktualisieren
Query geändert          neue Generation und betroffene Pages verwerfen
kompletter Reset        Controller.Refresh
```

## 17. Diagnose

Bei unerwartetem Verhalten zuerst prüfen:

1. Besitzt jede Column eine eindeutige `Id`?
2. Liefert der Controller stabile RowKeys?
3. Wurde nach externer Änderung eine Benachrichtigung ausgelöst?
4. Ist die StyleKey-/Thumb-Hint-Column trotz Unsichtbarkeit verfügbar?
5. Wird ein Factoryobjekt in `OnBindInstance` vollständig auf den neuen Kontext eingestellt?
6. Ist der passende VCL- beziehungsweise FMX-Unit-Scope aktiv?
