# h5u.Grid – VCL-/FMX-Grid-Prototyp

`h5u.Grid` ist ein quelloffener Teststand für ein erweiterbares Delphi-Grid mit gemeinsamem Daten-/Controllerkern und getrennten VCL-/FMX-Präsentationen.

Das Paket dient dazu, Architektur, API, Design-Time-Verhalten und die wichtigsten Interaktionspfade früh in einer realen Delphi-Umgebung zu erproben. Es ist ausdrücklich ein **Prototyp 0.1.4** und noch keine vollständige Grid-Suite.

## Enthaltene Testschwerpunkte

- gemeinsame Daten- und Spaltenklassen für VCL und FMX,
- getrennte DataController für `TDataSource`, RTTI-Objektlisten, Memory-Daten und Event-/VirtualSource,
- `Th5uSampleClientDataSet` mit selbst erzeugtem Schema und Designer-Musterdaten,
- per Gridinstanz isolierter Factory-/Registry-Scope,
- `GetClass`-, `OnGetClass`-, `OnCreateInstance`- und `OnConfigureInstance`-Erweiterungspunkte,
- mehrzeilige Header mit `RowSpan` und `ColumnSpan`,
- variable Zeilenhöhen einschließlich Text-AutoHeight und begrenzter Maximalhöhe,
- pixelweises, zeilenweises und einrastendes Scrollmodell,
- vertikale und horizontale Thumb-Hints,
- Zeilen-, Spalten- und Mehrbereichs-Zellselektion,
- periodische Zeilenstyles und Style-Auswahl über eine Daten-Column,
- Text-, Boolean- und Bild/BLOB-Darstellung; aktive Editoren werden als echte Controls erzeugt,
- Spalten verschieben, ausblenden, fixieren und in ihrer Breite verändern,
- konfigurierbare Controller-Caches und Pagination-Grundlagen,
- native VCL-/FMX-Style-Anbindung, eingebaute Classic-/Modern-/Dark-Paletten und CustomDraw-Hooks,
- standardmäßig 1 Pixel breite hellgraue Trennflächen zwischen Rows und Columns sowie am äußeren Inhaltsrand,
- deaktivierbare Abstände (`0`), vererbbarer Column-Abstand (`RightSpacing = -1`) und eigene Grid-/Column-Farben,
- Tree-Abschlussleiste nach dem letzten sichtbaren Child: größere Höhe und eigener Style ersetzen dort das normale Row-Spacing.
- Adjacent-Group-Folding für direkt aufeinanderfolgende gleiche IDs: unabhängige Läufe, Plus-/Minus-Symbol, unveränderte Quellreihenfolge und Abschlussleiste wahlweise nie, nur eingeklappt, nur ausgeklappt oder immer.
- Delphi-Quellen mit 180-Zeichen-Grenze; Properties und Methodensignaturen bleiben bis zu dieser Grenze einzeilig.

Die VCL-Ausgabe bildet im ersten Stand den umfassenderen Referenzpfad. Die FMX-Ausgabe verwendet denselben Core und dieselben Controller, besitzt aber noch nicht bei allen Komfortfunktionen vollständige Parität. Die genaue Abdeckung steht in der [Funktionsmatrix](Docs/FEATURE-MATRIX.md).

## Verzeichnisstruktur

```text
Source/
  Common/              gemeinsamer Core und DataController
  Vcl/                 VCL-Control, Painter, Styles und Editoren
  FMX/                 FMX-Control, Painter, Styles und Editoren
  Design/              Komponentenregistrierung

Packages/              Runtime- und Design-Time-DPKs
Demos/
  VCL/
    ClientDataSet/
    ObjectList/
    VirtualLive/
  FMX/
    ClientDataSet/
    ObjectList/
    VirtualLive/

Docs/                   Konzept, Kurzhilfe, Build- und Demo-Hilfe
Build/                  Buildskript, Deklarationsformatter und statische Audits
```

## Demos

Es liegen sechs eigenständige Anwendungen bei:

| Plattform | Demo | Zweck |
|---|---|---|
| VCL | ClientDataSet | Designer-Daten, viele zuschaltbare Layout-/Funktionsbeispiele |
| VCL | ObjectList | RTTI-Objektliste, optionaler Cache, Liveänderungen |
| VCL | VirtualLive | Daten vollständig aus Events, laufende Updates, Paging/Cache |
| FMX | ClientDataSet | gemeinsamer DataSet-Core im FMX-Control |
| FMX | ObjectList | gemeinsame Objektlisten-Anbindung unter FMX |
| FMX | VirtualLive | Event-/VirtualSource unter FMX |

Die ClientDataSet-Demos benötigen keine Datenbank und keine externe `.cds`-Datei. `Th5uSampleClientDataSet` legt Felder und Datensätze beim Laden selbst an; nach Installation des Design-Packages können dadurch bereits im Formulardesigner Inhalte erscheinen. Das Feld `TREE_LEVEL` enthält eine kleine, vorab sortierte Beispielhierarchie für die Tree-Abschlussleiste. Das ausgeblendete Feld `FOLD_GROUP` enthält zusammenhängende gleiche IDs; dieselbe ID erscheint später erneut, damit unabhängige Faltzustände direkt getestet werden können.

Weitere Hinweise: [Demoübersicht](Docs/DEMOS.md).

## Erste Schritte

1. Die Runtime-Packages in der dokumentierten Reihenfolge bauen.
2. Für Designer-Unterstützung die passenden Design-Time-Packages bauen und installieren.
3. Eine der sechs Demo-DPRs öffnen.
4. Zunächst die VCL-ClientDataSet-Demo als umfassendsten Referenzfall testen.

Build-Reihenfolge und Skriptparameter: [BUILD.md](Docs/BUILD.md).

## Dokumentation

- [Architektur und Konzept](Docs/CONCEPT.md)
- [Kurzhilfe für Entwickler](Docs/QUICKHELP.md)
- [Demoübersicht](Docs/DEMOS.md)
- [Funktionsmatrix und Grenzen des Prototyps](Docs/FEATURE-MATRIX.md)
- [automatisch erzeugter API-Auszug](Docs/API-EXTRACT.md)
- [Formatierungsrichtlinie für Delphi-Quellen](Docs/CODING-STYLE.md)
- [aktueller Prüfstatus](Build/BUILD_STATUS.md)
- [Pascal-Format-Audit](Build/FORMAT_AUDIT.md)
- [reproduzierbarer Release-Audit](Build/RELEASE_AUDIT.md)

## Namenskonvention

Die Marke bleibt in Delphi-Bezeichnern kleingeschrieben:

```pascal
Th5uVclGrid
Th5uDataSetController
Ih5uDataController
Eh5uFactoryError
```

Gemeinsame Units:

```pascal
h5u.Grid.Types
h5u.Grid.Columns
h5u.Grid.Data.Core
```

Plattformunits:

```pascal
Vcl.h5u.Grid
Fmx.h5u.Grid
```

Mit passenden Delphi Unit Scope Names kann Anwendungscode für die jeweilige Plattform einfach `h5u.Grid` in `uses` aufnehmen.

## Factory-Regel

Austauschbare Frameworkobjekte werden nicht direkt als feste konkrete Klasse erzeugt. Die Auflösung erfolgt über stabile String-IDs und eine Factory-Kaskade. Jeder Gridinstanz steht ein eigener `FactoryScope` zur Verfügung. Factory-Ereignisse erhalten den vollständigen Kontext, unter anderem Grid, View, DataController, Column, RowKey und Elementart.

Dadurch können mehrere Gridinstanzen gleichzeitig unterschiedliche Cells, Header, Fixed Cells, Editoren, Caches oder Renderer verwenden, ohne globale Seiteneffekte zu erzeugen.

## Prüfstatus

Der Quellstand wurde mit statischen Struktur-, Namespace-, Projektpfad-, DFM/FMX-, Event-, Namens- und Factory-Policy-Prüfungen sowie einem semantischen Test der Tree-Abschlusslogik auditiert. Die konsolidierten Ergebnisse stehen unter `Build`.

Im Erstellungscontainer war **kein Embarcadero-Delphi-Compiler** vorhanden. Das Paket enthält deshalb keine BPL/DCU/EXE-Dateien und behauptet keinen erfolgreichen DCC-Build. Der maßgebliche nächste Schritt ist der Build mit der konkret eingesetzten Delphi-Version; dabei können insbesondere versionsabhängige VCL-/FMX- und DesignIDE-Details sichtbar werden.

## Noch nicht als vollständige Produktmodule enthalten

Unter anderem sind die folgenden Bereiche im Konzept berücksichtigt, im ersten Teststand aber nicht vollständig umgesetzt:

- vollständiger Filtereditor und Backend-Filterübersetzung,
- mehrstufige Gruppierung mit allen Aggregaten,
- TreeView-, VerticalGrid-, Card- und Pivot-Views,
- komplexe Master-/Detail-SubViews,
- produktionsreifer XLSX/PDF-Export und Druck,
- vollständige Accessibility-Implementierung,
- vollständige FMX-Funktionsparität,
- umfassende Performance- und Plattformtests mit sehr großen realen Datenbeständen.

Die vorhandenen Klassen und Demos sollen zuerst die Kernentscheidungen validieren, bevor diese Module darauf aufgebaut werden.
