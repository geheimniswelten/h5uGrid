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
Fmx.h5u.Grid
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
OrdersGrid.FactoryScope.RegisterClass(
  h5uClassIdGridDataCell,
  Th5uVclVisualCell,
  TOrdersDataCell,
  100
);

LogGrid.FactoryScope.RegisterClass(
  h5uClassIdGridDataCell,
  Th5uVclVisualCell,
  TLogDataCell,
  100
);
```

Unter FMX wird entsprechend `Th5uFmxVisualCell` als erwartete Basisklasse verwendet. Der optionale fünfte Parameter ist ein Prädikat über `Th5uFactoryContext` und erlaubt Regeln für einzelne Grids, Views, Columns, Rows oder Elementarten.

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
FactoryScope.OnBindInstance bei sichtbarer Verwendung
    ↓
FactoryScope.OnUnbindInstance und Rückgabe an den Pool
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

## 8. Trennflächen, Abstände und Farben

Abstände sind Teil der Layoutgeometrie. Sie werden nicht als zustandsabhängiger Style behandelt, weil ein Wechsel zwischen `Selected`, `Hot` oder `Focused` das Layout nicht verändern darf.

Die Grid-Defaults sind:

```pascal
Grid.Spacing.Left := 1;
Grid.Spacing.Top := 1;
Grid.Spacing.Right := 1;
Grid.Spacing.Bottom := 1;
Grid.Spacing.RowSpacing := 1;
Grid.Spacing.DefaultColumnRightSpacing := 1;

Grid.Spacing.RowSpacingColor := TColorRec.Lightgray;
Grid.Spacing.ColumnSpacingColor := TColorRec.Lightgray;
Grid.Spacing.ContentPaddingColor := TColorRec.Lightgray;
```

Damit entstehen standardmäßig ein Pixel breite hellgraue Trennflächen:

- zwischen Datenzeilen,
- zwischen Header und Datenbereich,
- rechts neben jeder Column,
- rechts neben dem Row Indicator,
- am oberen, linken, rechten und unteren Rand des Grid-Inhalts.

Ein Wert von `0` entfernt den betreffenden Abstand vollständig. Jede Column kann den rechten Abstand überschreiben:

```pascal
Column.RightSpacing := -1; // Grid-Default erben
Column.RightSpacing := 0;  // für diese Column deaktivieren
Column.RightSpacing := 8;  // acht Pixel nach rechts
```

Die Zellbreite und der Abstand bleiben getrennte Größen. Scrollbereich, Fixed Columns, Headerlayout, HitTest, Selektion und Editorpositionen verwenden stets die effektive Layoutbreite aus `Column.Width + RightSpacing`.

Der Zeilenabstand kann pro Datensatz angepasst werden. `OnGetRowSpacing` erhält den bereits berechneten Default als `var`-Parameter:

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

Die normale Zellfarbe kann auf Grid- und Column-Ebene gesetzt werden:

```pascal
Grid.Appearance.DefaultCellColor := $00FDFDFD;
AmountColumn.Color := $00D8F4FF;
NameColumn.Color := TColorRec.SysDefault;
```

`TColorRec.SysDefault` bedeutet Vererbung aus Row-/Grid-/Theme-Darstellung. Selection-, Fokus- und Fehlerdarstellung behalten Vorrang vor einer festen Column-Farbe.

Für besondere Separator-Darstellungen existieren eigene CustomDraw-Elementarten:

```pascal
Th5uElementKind.RowSpacing
Th5uElementKind.ColumnSpacing
Th5uElementKind.ContentPadding
```

Der aktive Skin darf als Fallback die Farbe liefern, wenn eine Separatorfarbe auf `TColorRec.SysDefault` gesetzt wird. Die Größe der Abstände bleibt jedoch eine statische Layoutproperty und ändert sich nicht mit einem Zellzustand.

## 9. Variable RowHeight

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

## 10. Scrolling

Vertikal und horizontal stehen konzeptionell drei Modi bereit:

- `Pixel`: frei und pixelgenau
- `WholeRows` beziehungsweise `WholeColumns`: an Elementgrenzen
- `PixelSnap`: während der Bewegung frei, anschließend Einrasten

Bei einer Zeile, die höher als der Viewport ist, muss auch im Ganzzeilenmodus innerhalb der Zeile pixelweise navigiert werden können.

Variable Höhen werden über einen Row-Metrics-Index abgebildet. Noch nicht gemessene Zeilen verwenden eine Schätzhöhe; beim Nachmessen bleibt die sichtbare Anchor-Row stabil.

## 11. Thumb-Hints

Beim Ziehen des Scrollbar-Thumbs kann neben dem Thumb ein Hint erscheinen.

Horizontal:

- `Column.ScrollHintText`
- alternativ Headerpfad, Caption oder Column-ID

Vertikal:

- Inhalt einer konfigurierten Column
- alternativ RowKey oder Positionsangabe

`OnGetThumbHint` erhält den vorgeschlagenen Text als `var`-Parameter. Bei virtuellen Daten darf der Hint die UI nicht blockieren; er verwendet zunächst Cache-/Fallbackinformationen und kann später aktualisiert werden.

## 12. Selektion

Das Modell trennt:

- Fokuszelle
- Anchor
- selektierte ganze Rows
- selektierte ganze Columns
- mehrere rechteckige Zellbereiche

Zeilen werden anhand stabiler RowKeys, Columns anhand stabiler IDs gespeichert. „Alle Zeilen“ wird bei sehr großen Quellen symbolisch dargestellt und nicht als Millionen einzelner Keys materialisiert.

## 13. Styles und CustomDraw

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

## 14. Periodische und wertabhängige Zeilenstyles

Odd/Even ist nur ein Spezialfall einer periodischen Regel. Konfigurierbar sind beispielsweise:

- jede dritte Zeile
- jede fünfte Zeile
- mehrere Treffer innerhalb eines Blocks
- Neustart pro Gruppe oder Seite

Zusätzlich kann eine Boolean-/Integer-Column als `StyleKeyColumnId` dienen. Ein Mapping ordnet deren Werte benannten Styles zu. Die Column darf unsichtbar sein und wird vom Controller trotzdem als Datenabhängigkeit behandelt.

## 15. Abschluss eines Tree-Astes

Der erste Tree-Testpfad arbeitet mit einer flachen, bereits in Preorder-Reihenfolge gelieferten Datenmenge. `Tree.LevelColumnId` benennt eine Integer-Column oder direkt ein Controllerfeld mit der sichtbaren Verschachtelungsebene. Das vollständige Parent-/Child-Modell, Ein-/Ausklappen und Lazy Loading sind davon getrennte spätere View-Funktionen.

Für jede Zeile vergleicht der Renderer die aktuelle Ebene mit der nächsten logischen Zeile der Datenmenge. Bei nummerierter Pagination erfolgt der Look-ahead über die aktuelle Seitengrenze hinweg, damit ein Seitenende nicht fälschlich als Ast- oder Datenende behandelt wird. Sinkt die Ebene, endet mindestens ein Child-Ast. `ClosedTreeLevels` enthält die Anzahl der dabei verlassenen Ebenen. Am Ende der Datenmenge kann `IncludeEndOfData` denselben Abschluss erzeugen. Root-Zeilen der Ebene `0` werden nicht allein aufgrund des Datenendes als Child-Abschluss behandelt.

Die Abschlussleiste ist ein alternatives Separator-Element:

```text
normal:        RowHeight + RowSpacing
Astende:       RowHeight + BranchEndBand.Height
```

`RowSpacing` und `BranchEndBand.Height` werden niemals addiert. Für erkannte Astenden wird deshalb auch `OnGetRowSpacing` nicht zusätzlich ausgewertet. Das ist sowohl für die Zeichnung als auch für Scrollbereich, HitTest, sichtbare Zeilenberechnung und Row-Metrics verbindlich.

Die Darstellung wird in dieser Reihenfolge aufgelöst:

1. explizite `BranchEndBand.Color`,
2. semantischer `StyleName` wie `TreeBranchEnd`,
3. normale Row-Separatorfarbe,
4. plattformspezifisches CustomDraw.

Die Leiste erhält eine eigene Factory-ID (`h5u.grid.spacing.tree-branch-end`) und `Th5uElementKind.TreeBranchEndBand`. Sie wird – wie die übrigen Separatoren – als leichtgewichtiges, gepooltes sichtbares Element über den lokalen Factory-Scope materialisiert. Dadurch kann sie pro Gridinstanz durch eine eigene `Th5uVclVisualCell`-/`Th5uFmxVisualCell`-Nachfahrin oder durch CustomDraw anders dargestellt werden. Der Kontext transportiert Grid, Controller, RowKey, Source-/View-Index, Tree-Level und Anzahl geschlossener Ebenen. `OnGetTreeLevel` und `OnGetTreeBranchEnd` entkoppeln die Erkennung von einer bestimmten Controllerimplementierung.

## 16. Adjacent-Group-Folding

`AdjacentGroupFolding` ist bewusst von der normalen Gruppierung und vom fachlichen Tree getrennt. Es verändert weder die Sortierung noch die Reihenfolge des DataControllers. Stattdessen wird aus der aktuellen Controller-Ansicht eine sichtbare Indexabbildung erzeugt:

```text
Controller-Zeilen:  A A A B C C A A A D
Läufe:              └─1─┘ 2 └3┘ └─4─┘ 5
```

Nur **direkt aufeinanderfolgende** gleiche ID-Werte gehören zu demselben Lauf. Tritt `A` später erneut auf, entsteht ein neuer, unabhängig faltbarer Lauf. Der Zustand wird deshalb nicht unter der ID allein, sondern unter dem ersten stabilen RowKey des Laufs und seiner Vergleichs-ID gespeichert.

Die ID kommt aus einer sichtbaren oder unsichtbaren Column:

```pascal
Grid.AdjacentGroupFolding.Enabled := True;
Grid.AdjacentGroupFolding.IdColumnId := 'fold_group';
```

Alternativ liefert `OnGetAdjacentGroupId` den Wert. `CaseSensitive` steuert Stringvergleiche, `GroupEmptyValues` das Zusammenfassen leerer Werte. Ein Lauf mit nur einer Zeile ist keine faltbare Gruppe und erhält weder Faltzeichen noch Abschlussleiste.

Im ausgeklappten Zustand bleiben alle Controller-Zeilen sichtbar. Beim Einklappen bleibt die erste Zeile als Repräsentant erhalten; nur die nachfolgenden Zeilen desselben Laufs werden aus der View-Abbildung ausgeblendet. RowKeys, Quellindizes und Datenwerte bleiben unverändert. Das Plus-/Minus-Zeichen wird als gepooltes sichtbares Element über den lokalen Factory-Scope des konkreten Grids erzeugt.

### Abschlussleiste

Der Abschluss eines Laufs kann deutlicher als die normale Zeilentrennung dargestellt werden:

```pascal
Grid.AdjacentGroupFolding.EndBand.Height := 7;
Grid.AdjacentGroupFolding.EndBand.StyleName := 'AdjacentGroupEnd';
Grid.AdjacentGroupFolding.EndBand.Visibility :=
  Th5uAdjacentGroupEndBandVisibility.Always;
```

`Visibility` besitzt vier Betriebsarten:

- `Never`: keine Abschlussleiste,
- `CollapsedOnly`: nur im eingeklappten Zustand,
- `ExpandedOnly`: nur im ausgeklappten Zustand,
- `Always`: in beiden Zuständen.

Die Abschlussleiste ist eine **Alternative** zum normalen Row-Spacing:

```text
ohne Abschlussleiste:  RowHeight + RowSpacing
mit Abschlussleiste:   RowHeight + EndBand.Height
```

Sie wird niemals zusätzlich addiert. `Height = 0` unterdrückt an dieser Grenze daher auch den normalen Zeilenabstand. Treffen ein Adjacent-Group-Ende und ein Tree-Astende auf dieselbe Grenze, hat die explizite Adjacent-Group-Abschlussleiste Vorrang.

Für Faltzeichen und Abschlussleiste existieren eigene Factory-IDs und Elementarten:

```pascal
h5uClassIdGridAdjacentGroupFoldGlyph
h5uClassIdGridAdjacentGroupEndBand

Th5uElementKind.AdjacentGroupFoldGlyph
Th5uElementKind.AdjacentGroupEndBand
```

Der Factory-/CustomDraw-Kontext enthält unter anderem Gruppenindex, Gruppen-ID, Anchor-RowKey, Zeilenzahl, Faltzustand sowie Kennzeichen für erste und letzte sichtbare Zeile. Damit können verschiedene Gridinstanzen dieselbe Datenquelle nutzen und trotzdem unterschiedliche Faltzeichen, Styles oder Endleisten darstellen.

Der Prototyp baut die Laufabbildung über die aktuelle Controller-Ansicht beziehungsweise die aktuelle nummerierte Seite auf. Für sehr große Remotequellen ist eine spätere servergestützte Laufmetadaten-Schnittstelle sinnvoll, damit nicht die gesamte Ergebnismenge allein zur Laufbestimmung geladen werden muss.

## 17. Cache und Pagination

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

## 18. Erweiterungsziel

Die aktuelle Implementierung konzentriert sich auf den vertikalen Testpfad. Der Core ist so angelegt, dass später ohne Bruch ergänzt werden können:

- vollständige Sortier- und Filter-Engine
- vollständige normale Gruppierung und Group-Footer
- TreeTableView
- VerticalGridView
- CardView
- Master/Detail-SubViews
- Aggregate und Backend-Summaries
- LiveBindings-Adapter
- Export, Druck und Accessibility-Ausbau

## 19. Quellformat und Wartbarkeit

Der h5u-Quellstil begrenzt Pascal-Code auf 150 Zeichen pro Zeile. Properties und Methodensignaturen einschließlich Implementationsköpfen bleiben bis 180 Zeichen einzeilig; darüber wird an Parameter- oder Property-Klauselgrenzen umgebrochen. Operatoren stehen bei umgebrochenen Ausdrücken am Anfang der Folgezeile.

Ein konservativer Formatter und der Release-Audit prüfen diese Regel reproduzierbar. Ausführbare Anweisungen werden nicht automatisch umgebaut, damit semantisch gruppierte Ausdrücke und bewusst gestaltete Kontrollflüsse erhalten bleiben.

## Farbtyp und Migration

Alle gemeinsamen Farbproperties und `Th5uResolvedAppearance` verwenden direkt
`System.UITypes.TColor`. Damit erkennt der VCL-Formdesigner den Standard-Farbeditor.
`clDefault` und `clNone` aus `Vcl.Graphics` entsprechen `TColorRec.SysDefault`
und `TColorRec.SysNone` aus `System.UITypes`; die gemeinsamen Units benötigen keine VCL.
Explizite Farben sind `$00BBGGRR`, beispielsweise Rot `$000000FF` und Blau `$00FF0000`.
Die FMX-Zeichenfläche verwendet weiterhin `TAlphaColor` (`$AARRGGBB`); nur an dieser
Grenze werden die Farbkanäle umgeordnet. `clNone` wird dort transparent, normale
`TColor`-Werte werden deckend gezeichnet. Windows-Systemfarben werden unter Windows
über `GetSysColor` aufgelöst. Für andere FMX-Plattformen explizite RGB-Farben verwenden.

Die bisherigen eigenen Farbtypen, Sentinel-Konstanten und RGB-/ARGB-Hilfsfunktionen
entfallen. Bereits gespeicherte Grid-Farbwerte im alten ARGB-Format müssen nach BGR
umgerechnet werden; ebenso werden die alten Werte -1/-2 durch die Standardwerte
für Default/None ersetzt. Die mitgelieferten DFM-/FMX-Demos sind bereits umgestellt.
Die früher mögliche Alpha-Komponente gehört nicht zum neuen TColor-Vertrag.
