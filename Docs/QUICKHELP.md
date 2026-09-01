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
  WordWrap := True;
  AutoHeight := True;
  MaxAutoHeight := 100;
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
ObjectController1.OwnsObjects := True;
ObjectController1.KeyPropertyName := 'Id';
ObjectController1.Add(ACustomer);
Grid1.DataController := ObjectController1;
```

Eine separate `ItemClass`-Angabe ist nicht nötig: Der Controller wertet die Laufzeitklasse des jeweiligen Objekts über RTTI aus. Die `FieldName`-Angabe einer Column entspricht dem RTTI-Propertynamen; auch verschachtelte Pfade wie `Address.City` werden unterstützt und ihre Accessoren gecacht.

Der Cache kann für direkte, günstige Getter abgeschaltet werden:

```pascal
ObjectController1.Cache.Mode := Th5uCacheMode.None;
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

procedure TForm1.VirtualGetRowKey(
  Sender: TObject;
  ASourceRowIndex: Int64;
  var ARowKey: Th5uRowKey);
begin
  ARowKey := Th5uRowKey.FromInt64(FRows[ASourceRowIndex].Id);
end;

procedure TForm1.VirtualGetValue(
  Sender: TObject;
  ASourceRowIndex: Int64;
  const AFieldName: string;
  var AValue: TValue);
begin
  // Wert anhand von ASourceRowIndex und AFieldName liefern
end;
```

Nach Liveänderungen nicht zwingend alles neu laden. Je nach Änderung kann der Controller eine Row, mehrere Cells oder die gesamte Abbildung invalidieren. Die Demo `VirtualLive` zeigt den laufenden Append-/Update-Pfad.

## 6. Factory pro Grid

Globalen Standard nur dann verwenden, wenn wirklich alle Grids betroffen sein sollen. Für lokale Anpassungen:

```pascal
Grid1.FactoryScope.RegisterClass(
  h5uClassIdGridDataCell,
  Th5uVclVisualCell,
  TMyDataCell,
  100
);
```

Für FMX wird als erwartete Basisklasse `Th5uFmxVisualCell` angegeben. Eine kontextabhängige Registrierung verwendet denselben Aufruf mit Prädikat:

```pascal
Grid1.FactoryScope.RegisterClass(
  h5uClassIdGridDataCell,
  Th5uVclVisualCell,
  TMyPriorityCell,
  200,
  function(const AContext: Th5uFactoryContext): Boolean
  begin
    Result :=
      (AContext.Grid = Grid1) and
      (AContext.Column is Th5uGridColumn) and
      SameText(
        Th5uGridColumn(AContext.Column).Id,
        'priority'
      );
  end
);
```

Die Factory-Ereignisse erhalten stets `AContext.Grid`. Damit kann auch eine Shared Factory pro Grid unterscheiden.

Wichtige Hooks am jeweiligen `FactoryScope`:

```text
Get...Class / FactoryScope.OnGetClass
FactoryScope.OnCreateInstance
FactoryScope.OnConfigureInstance
FactoryScope.OnBindInstance
FactoryScope.OnUnbindInstance
```

`OnConfigureInstance` ist für einmalige Defaults gedacht. Werte der jeweils gebundenen Row/Cell gehören in `FactoryScope.OnBindInstance`; `OnUnbindInstance` räumt einen wiederverwendeten Presenter vor der Rückgabe an den Pool auf.

## 7. Trennflächen, Abstände und Farben

Standardmäßig sind alle Grid-Trennflächen ein Pixel breit und hellgrau:

```pascal
Grid1.Spacing.Left := 1;
Grid1.Spacing.Top := 1;
Grid1.Spacing.Right := 1;
Grid1.Spacing.Bottom := 1;
Grid1.Spacing.RowSpacing := 1;
Grid1.Spacing.DefaultColumnRightSpacing := 1;

// Komfortschalter: alle gridweiten Breiten gemeinsam auf 1 oder 0 setzen
Grid1.GridLines := True;

// Dasselbe direkt mit einer frei wählbaren gemeinsamen Breite:
Grid1.Spacing.SetAllSeparators(1);
```

Ein einzelner Wert `0` deaktiviert den betreffenden Abstand. `GridLines := False` setzt die vier Außenabstände, `RowSpacing` und `DefaultColumnRightSpacing` gemeinsam auf `0`; ausdrücklich gesetzte `Column.RightSpacing`-Werte bleiben unabhängig. Für Columns gilt:

```pascal
NameColumn.RightSpacing := -1; // Grid-Default
AmountColumn.RightSpacing := 0; // deaktiviert
DescriptionColumn.RightSpacing := 8;
```

Farben:

```pascal
Grid1.Spacing.RowSpacingColor := h5uColorLightGray;
Grid1.Spacing.ColumnSpacingColor := h5uColorLightGray;
Grid1.Spacing.ContentPaddingColor := h5uColorLightGray;

Grid1.Appearance.DefaultCellColor :=
  h5uColorFromRgb(253, 253, 253);
AmountColumn.Color := h5uColorFromRgb(255, 244, 216);
AmountColumn.Color := h5uColorDefault; // wieder erben
```

Zeilenabhängiger Abstand:

```pascal
procedure TForm1.GridGetRowSpacing(
  Sender: TObject;
  const AContext: Th5uGetRowHeightContext;
  var ASpacing: Integer);
begin
  if (AContext.ViewRowIndex + 1) mod 5 = 0 then
    ASpacing := 6;
end;
```

Für VCL verwendet das Event `Integer`, für FMX den entsprechenden `Single`-Kontext. CustomDraw erkennt Separatoren über `RowSpacing`, `ColumnSpacing` und `ContentPadding`.

## 8. Variable Zeilenhöhe

```pascal
DescriptionColumn.WordWrap := True;
DescriptionColumn.AutoHeight := True;
DescriptionColumn.MaxAutoHeight := 120;
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
  var AHeight: Integer;
  var ACacheResult: Boolean);
begin
  if AContext.RowKey = FExpandedRow then
    AHeight := 140;
end;
```

`AHeight` enthält den automatisch gemessenen Vorschlag.

## 9. Scrollmodus

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

## 10. Thumb-Hint

Vertikalen Inhalt aus einer Column beziehen:

```pascal
Grid1.ScrollHints.VerticalColumnId := 'name';
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

## 11. Selektion

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

## 12. Column verschieben oder ausblenden

```pascal
Grid1.Customization.AllowColumnMoving := True;
Grid1.Customization.AllowColumnHiding := True;

AmountColumn.Visible := False;
AmountColumn.VisibleIndex := 2;
```

Die Column bleibt als logisches Objekt erhalten und kann weiterhin Filter-, StyleKey- oder Thumb-Hint-Quelle sein.

## 13. Periodische Row-Styles

Jede fünfte Zeile:

```pascal
Grid1.RowStyles.StripePeriod := 5;
Grid1.RowStyles.StripeOffset := 5;
Grid1.RowStyles.StripeStyleName := 'Stripe';
```

Odd/Even kann als vordefinierte Zweierrhythmik betrachtet werden.

## 14. RowStyle aus einer Column

```pascal
Grid1.RowStyles.StyleKeyColumnId := 'priority';
with Grid1.RowStyles.Mappings.Add do
begin
  Value := 0;
  StyleName := 'Even';
end;
with Grid1.RowStyles.Mappings.Add do
begin
  Value := 2;
  StyleName := 'Warning';
end;
with Grid1.RowStyles.Mappings.Add do
begin
  Value := 3;
  StyleName := 'Error';
end;
```

Die StyleKey-Column darf unsichtbar sein.

## 15. Cache und Paging

```pascal
DataSetController1.Cache.Mode := Th5uCacheMode.Paged;
DataSetController1.Cache.PageSize := 100;
DataSetController1.Cache.MaxCachedPages := 8;

DataSetController1.Pagination.Mode :=
  Th5uPaginationMode.NumberedPages;
DataSetController1.Pagination.PageSize := 50;
DataSetController1.Pagination.PageIndex := 0;
```

Cache-Seiten sind interne Ladeeinheiten. Sichtbare Pagination ist eine UI-/Queryentscheidung; beides darf unabhängig konfiguriert werden.

## 16. Bildwerte

Akzeptiert werden im Prototyp insbesondere:

- `TBlobField`
- `TBytes`
- Stream-basierte Binärwerte des Controllers

Der Plattformrenderer dekodiert das Bild erst für sichtbare Zellen. Der echte `TImage`-Editor wird nur für die aktive Bearbeitung erzeugt.

## 17. Aktualisierung nach Datenänderungen

Je genauer die Benachrichtigung, desto weniger Arbeit:

```text
nur Cell geändert       Cell/Row invalidieren
Row geändert            Row-Snapshot und RowHeight invalidieren
Row eingefügt           Mapping und Scrollmetriken aktualisieren
Query geändert          neue Generation und betroffene Pages verwerfen
kompletter Reset        Controller.Refresh
```

## 18. Diagnose

Bei unerwartetem Verhalten zuerst prüfen:

1. Besitzt jede Column eine eindeutige `Id`?
2. Liefert der Controller stabile RowKeys?
3. Wurde nach externer Änderung eine Benachrichtigung ausgelöst?
4. Ist die StyleKey-/Thumb-Hint-Column trotz Unsichtbarkeit verfügbar?
5. Wird ein Factoryobjekt in `FactoryScope.OnBindInstance` vollständig auf den neuen Kontext eingestellt?
6. Ist der passende VCL- beziehungsweise FMX-Unit-Scope aktiv?
