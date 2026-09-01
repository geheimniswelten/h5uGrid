# h5u.Grid – Konzept und Architektur

## 1. Ziel

`h5u.Grid` trennt Datenzugriff, Viewzustand, Layout, Rendering und Editoren. Dasselbe Controller- und Spaltenmodell soll sowohl von VCL als auch FMX verwendet werden können, ohne die Plattformunterschiede bei Controls, Styles, Canvas, DPI, Fokus und Eingabe zu verstecken.

```text
Datenquelle
   │
   ▼
Th5uCustomDataController
   │
   ├── DataSet
   ├── Objektliste
   ├── Memory
   └── Virtual/Events
   │
   ▼
Grid-/View-Session
   │
   ├── Cache und Paging
   ├── sichtbare RowKeys
   ├── Selektion
   └── Query-/Versionszustand
   │
   ▼
gemeinsames Spalten-, Header- und Optionsmodell
   │
   ├──────────────┐
   ▼              ▼
VCL-Renderer   FMX-Renderer
```

## 2. Gemeinsamer Core und Plattformfassaden

Gemeinsame Units beginnen mit:

```pascal
h5u.Grid.Types
h5u.Grid.Factory
h5u.Grid.Columns
h5u.Grid.Selection
h5u.Grid.Options
h5u.Grid.Data.*
```

Die visuellen Fassaden heißen:

```pascal
Vcl.h5u.Grid
FMX.h5u.Grid
```

VCL und FMX teilen bewusst keine visuelle Basisklasse. `Th5uVclGrid` basiert auf einem VCL-Control; `Th5uFmxGrid` auf einem FMX-Styled-Control. Beide delegieren ihre Daten- und Factorylogik an denselben Core.

## 3. DataController

Das Grid kennt keine konkrete Datenquelle. Es arbeitet über `Th5uCustomDataController`.

Der Controller stellt mindestens bereit:

- Anzahl und stabile Identität der Zeilen
- Lesen und Schreiben typisierter Zellwerte
- Editierbarkeit
- Benachrichtigungen bei Änderungen
- optionale Vorbereitungs-/Fetch-Aufrufe für sichtbare Bereiche
- eine Capability-Beschreibung

### 3.1 DataSet-Controller

`Th5uDataSetController` verbindet eine `TDataSource`.

Bei aktivem Cache zeichnet das Grid aus Controller-Snapshots. Damit muss ein Paint-Durchlauf nicht für jede Zelle den aktuellen Datensatz des `TDataSet` umpositionieren. Editieroperationen werden an das DataSet zurückgeschrieben und der betroffene Snapshot anschließend invalidiert.

### 3.2 Objektlisten-Controller

`Th5uObjectListController` verwendet vorbereitete RTTI-Accessoren für Property-Pfade. Der Value-Cache kann abgeschaltet werden, wenn Propertyzugriffe günstig sind, oder für sichtbare beziehungsweise paginierte Bereiche aktiviert werden.

### 3.3 Virtual-/Live-Controller

`Th5uVirtualController` fragt Anzahl, RowKey, Wert und Schreiboperationen über Events ab. Daten können aus einem beliebigen Backend, einer Queue oder einem laufenden Prozess stammen.

Liveänderungen werden nicht durch komplettes Neuladen erzwungen. Die Quelle kann Zeilen- und Zelländerungen gezielt melden. Query-Generationen verhindern, dass verspätete Antworten einer älteren Ansicht in die aktuelle Ansicht gelangen.

### 3.4 Memory-Controller

`Th5uMemoryController` stellt einen kleinen eigenen tabellarischen Speicher bereit. Er eignet sich für Tests, temporäre Tabellen und als Referenzcontroller.

## 4. Factory und Registry pro Gridinstanz

Jede Gridinstanz besitzt einen eigenen `FactoryScope`. Dadurch können zwei Grids auf derselben Form gleichzeitig unterschiedliche Klassen verwenden.

```pascal
OrdersGrid.FactoryScope.RegisterOverride(
  h5uClassIdGridDataCell,
  TOrdersDataCell
);

LogGrid.FactoryScope.RegisterOverride(
  h5uClassIdGridDataCell,
  TLogDataCell
);
```

Eine optionale `Th5uClassFactory` kann gemeinsam verwendet werden. Lokale Regeln des Grids haben gegenüber globaleren Vorgaben Vorrang.

### 4.1 Factory-Kontext

Jeder Aufruf erhält einen Kontext mit unter anderem:

- konkretem Grid
- View und Level
- DataController und Session
- Column und Headerzelle
- RowKey sowie sichtbarem und Quellindex
- Wert und RowStyleKey
- Elementart
- Fixed-/Header-/Selection-/Focus-Flags
- `LayoutRow`, `LayoutColumn`, `RowSpan`, `ColumnSpan`
- Erstellungsgrund

Somit kann auch eine gemeinsam verwendete Factory anhand von `AContext.Grid` unterscheiden.

### 4.2 Erstellungspipeline

```text
ClassId bestimmen
    ↓
lokale und übergeordnete Registry auflösen
    ↓
virtuelle Get...Class-Methode
    ↓
OnGetClass
    ↓
OnCreateInstance
    ↓
Standard-Activator
    ↓
OnConfigureInstance
    ↓
OnBindInstance bei sichtbarer Verwendung
    ↓
OnUnbindInstance und Rückgabe an den Pool
```

Austauschbare Frameworkobjekte werden nicht direkt mit einer fest codierten konkreten Klasse erzeugt.

## 5. Visuelle Virtualisierung

Es gibt zwei Objektgruppen.

### Logische Objekte

Diese bleiben unabhängig vom Viewport bestehen:

- Columns
- Headerlayoutzellen
- Views und Levels
- Styles und Optionen
- DataController

### Sichtbare Objekte

Diese existieren nur für den sichtbaren Bereich plus Overscan:

- sichtbare Rows
- sichtbare Columns
- Data Cells
- Header-, Fixed- und Footerzellen
- aktive Editoren

Standardzellen sind leichte Painter-/Presenterobjekte und keine eigenen `TControl`-Instanzen. Echte VCL-/FMX-Controls werden nur für den aktiven Editor und ausdrücklich eingebettete Controls erzeugt.

## 6. Columns und Celltypen

Eine Column enthält stabile ID, Binding-/Fieldname, Caption, Größe, Sichtbarkeit, Position, Fixed-Region, Formatter und Editorart.

Text, Boolean, Zahl, Datum und Bild sind im Prototyp vertreten. Die Architektur trennt Column, Zellpräsentation und Editor, damit derselbe fachliche Celltyp in Table-, Tree-, Vertical- oder Card-Views wiederverwendet werden kann.

Bildwerte werden im gemeinsamen Core als Bytes beziehungsweise Stream behandelt. VCL und FMX dekodieren daraus ihre jeweilige Bildklasse. Große Werte können erst bei Sichtbarkeit geladen und als Thumbnail gecacht werden.

## 7. Headerlayout

`Th5uHeaderLayout` beschreibt mehrzeilige Headerzellen über:

```text
LayoutRow
LayoutColumn
RowSpan
ColumnSpan
ColumnId oder Gruppe
```

Beispiel:

```text
┌──────────── Auftrag ─────────────┬── Status ──┐
│ Nummer          │ Termin         │             │
```

Der gleiche Layoutansatz ist für mehrzeilige Datensatzblöcke und Datengruppenköpfe vorgesehen.

## 8. Variable RowHeight

Eine Textzelle kann Word-Wrap und `AutoHeight` aktivieren. Die höchste beitragende Zelle bestimmt zunächst den Vorschlag für die logische Zeile. Anschließend erhält `OnGetRowHeight` diesen Wert als `var`-Parameter.

```text
View-Minimum
    ↓
gemessener Zellbedarf
    ↓
Column-/Text-Maximum
    ↓
OnGetRowHeight
    ↓
RowMetrics-Cache
```

Der Cache wird unter anderem bei Wert-, Breiten-, Font-, DPI-, Style- und Themeänderungen invalidiert.

## 9. Scrolling

Vertikal und horizontal stehen konzeptionell drei Modi bereit:

- `Pixel`: frei und pixelgenau
- `WholeRows` beziehungsweise `WholeColumns`: an Elementgrenzen
- `PixelSnap`: während der Bewegung frei, anschließend Einrasten

Bei einer Zeile, die höher als der Viewport ist, muss auch im Ganzzeilenmodus innerhalb der Zeile pixelweise navigiert werden können.

Variable Höhen werden über einen Row-Metrics-Index abgebildet. Noch nicht gemessene Zeilen verwenden eine Schätzhöhe; beim Nachmessen bleibt die sichtbare Anchor-Row stabil.

## 10. Thumb-Hints

Beim Ziehen des Scrollbar-Thumbs kann neben dem Thumb ein Hint erscheinen.

Horizontal:

- `Column.ScrollHintText`
- alternativ Headerpfad, Caption oder Column-ID

Vertikal:

- Inhalt einer konfigurierten Column
- alternativ RowKey oder Positionsangabe

`OnGetThumbHint` erhält den vorgeschlagenen Text als `var`-Parameter. Bei virtuellen Daten darf der Hint die UI nicht blockieren; er verwendet zunächst Cache-/Fallbackinformationen und kann später aktualisiert werden.

## 11. Selektion

Das Modell trennt:

- Fokuszelle
- Anchor
- selektierte ganze Rows
- selektierte ganze Columns
- mehrere rechteckige Zellbereiche

Zeilen werden anhand stabiler RowKeys, Columns anhand stabiler IDs gespeichert. „Alle Zeilen“ wird bei sehr großen Quellen symbolisch dargestellt und nicht als Millionen einzelner Keys materialisiert.

## 12. Styles und CustomDraw

Die Darstellung wird in dieser Reihenfolge aufgelöst:

```text
Anwendungsstyle oder Built-in-Theme
    ↓
Grid-/Viewstyle
    ↓
Column- beziehungsweise Headerstyle
    ↓
periodische Zeilenregel
    ↓
wertabhängiger RowStyle
    ↓
bedingte Darstellung
    ↓
Appearance-Event
    ↓
Selected/Focused/Error-Overlay
    ↓
CustomDraw
```

Mitgeliefert werden:

- `Classic2000`
- `Modern`
- `Dark`

Der native VCL-/FMX-Style liefert Grundfarben und Control-Erscheinung. Semantische Gridrollen ergänzen fehlende Grid-spezifische Zustände. CustomDraw kann vor oder nach der Standardzeichnung eingreifen oder sie vollständig ersetzen.

## 13. Periodische und wertabhängige Zeilenstyles

Odd/Even ist nur ein Spezialfall einer periodischen Regel. Konfigurierbar sind beispielsweise:

- jede dritte Zeile
- jede fünfte Zeile
- mehrere Treffer innerhalb eines Blocks
- Neustart pro Gruppe oder Seite

Zusätzlich kann eine Boolean-/Integer-Column als `StyleKeyColumnId` dienen. Ein Mapping ordnet deren Werte benannten Styles zu. Die Column darf unsichtbar sein und wird vom Controller trotzdem als Datenabhängigkeit behandelt.

## 14. Cache und Pagination

Cache und sichtbare Pagination sind voneinander getrennt.

Cachemodi:

- kein Cache
- Viewport
- Seiten
- vollständig
- adaptiv

Pagination:

- kontinuierliches virtuelles Scrollen
- nummerierte Seiten
- Cursor-Paging

Ein kontinuierlich scrollendes Grid darf intern trotzdem seitenweise laden. Selektion, Summen und Gruppierung müssen jeweils ihren Gültigkeitsbereich ausweisen.

## 15. Erweiterungsziel

Die aktuelle Implementierung konzentriert sich auf den vertikalen Testpfad. Der Core ist so angelegt, dass später ohne Bruch ergänzt werden können:

- vollständige Sortier- und Filter-Engine
- Gruppierung und Group-Footer
- TreeTableView
- VerticalGridView
- CardView
- Master/Detail-SubViews
- Aggregate und Backend-Summaries
- LiveBindings-Adapter
- Export, Druck und Accessibility-Ausbau
