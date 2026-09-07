# Changelog

## Unveröffentlicht – 2026-09-07

- SampleClientDataset: verfrühten LogChanges-Zugriff auf geschlossene Datenmenge entfernt; Neuerzeugung während des Komponenten-Streamings bis Loaded verschoben. Regressionstest für Konstruktion und Design-/Laufzeit-Streaming ergänzt.

- `else` im `case` auf die Ebene der Fallwerte eingerückt; Formatter und vorhandene Quellen angepasst.

- Quellformat auf 150 Zeichen begrenzt; Properties und Methodensignaturen bleiben bis 180 Zeichen einzeilig.
- Bereits umgebrochene Ausdrücke und Aufrufe werden anhand der 150-Zeichen-Grenze neu verteilt.
- Umgebrochene Ausdrücke beginnen auf Folgezeilen mit dem Operator.
- Formatter und Audits prüfen beide Grenzen, Operatorposition und die Erhaltung von Tokens und Zeichenketten.

- Farbproperties verwenden direkt `System.UITypes.TColor` und den VCL-Standard-Farbeditor.
- Eigener Farbtyp, eigene Default-/None-Konstanten und RGB-/ARGB-Hilfsfunktionen entfernt.
- VCL-Farben werden direkt weitergereicht; die FMX-Grenze konvertiert BGR/ARGB korrekt.
- Demo-Farbwerte in Quellcode und DFM/FMX auf BGR umgerechnet; bestehende Farbtöne bleiben erhalten.

## 0.1.4 – 2026-09-02

### Delphi-Quellformatierung

- maximale Zeilenlänge für Pascal-Quellen auf 180 Zeichen festgelegt,
- Property-Deklarationen bleiben bis zu dieser Grenze einzeilig,
- Methoden- und Funktionssignaturen werden in Deklaration und `implementation` erst bei Überschreitung der Grenze umgebrochen,
- prozedurale Eventtypen und einfache geteilte Felddeklarationen wurden entsprechend zusammengeführt,
- längere Signaturen werden an Parametergrenzen kompakt fortgesetzt,
- `.editorconfig` dokumentiert Einrückung, Encoding und Zeilenlänge,
- `Build/format_pascal.py` formatiert die betroffenen Deklarationsblöcke konservativ und unterstützt einen reinen Prüfmodus,
- Release- und statischer Audit prüfen die 180-Zeichen-Grenze und vorzeitig umgebrochene Deklarationen.

## 0.1.3 – 2026-09-01

### Adjacent-Group-Folding

- `Grid.AdjacentGroupFolding` fasst ausschließlich direkt aufeinanderfolgende Rows mit gleichem ID-Wert zu unabhängig faltbaren Läufen zusammen,
- Sortierung, Controller-Reihenfolge und RowKeys bleiben unverändert; nur die sichtbare View-Abbildung blendet beim Einklappen alle Rows außer der ersten aus,
- dieselbe ID kann später erneut vorkommen und erzeugt anhand des ersten RowKeys einen eigenen Faltzustand,
- die ID kann aus einer sichtbaren oder unsichtbaren Column kommen oder über `OnGetAdjacentGroupId` geliefert werden,
- ein über den lokalen Grid-Factory-Scope erzeugtes Plus-/Minus-Symbol erscheint vor der ersten Row jedes faltbaren Laufs,
- Einzelzeilen sind nicht faltbar und erhalten weder Symbol noch Abschlussleiste,
- `EndBand.Visibility` unterstützt `Never`, `CollapsedOnly`, `ExpandedOnly` und `Always`,
- die Abschlussleiste ersetzt das normale `RowSpacing`; ihre Höhe wird nicht addiert und `Height = 0` unterdrückt an dieser Grenze auch den normalen Abstand,
- Abschlussleiste und Falt-Symbol besitzen eigene Factory-IDs, Elementarten, Styles und vollständige Kontextinformationen,
- VCL und FMX stellen Methoden zum einzelnen beziehungsweise gemeinsamen Ein-/Ausklappen bereit,
- die ClientDataset-Demos enthalten die unsichtbare Spalte `FOLD_GROUP`, getrennte Wiederholungen derselben ID sowie Schalter für Funktion und Abschlussleistenmodus,
- ein compilerunabhängiger Semantiktest fixiert Laufbildung, unabhängige Wiederholungen, Sichtbarkeitsabbildung und alle vier Abschlussleistenmodi.

## 0.1.2 – 2026-09-01

### Tree-Abschlussleiste

- `Grid.Tree.LevelColumnId` liest die Ebene einer vorab in Preorder-Reihenfolge gelieferten Tree-Zeile,
- `Grid.Tree.BranchEndBand` kennzeichnet das Ende eines Child-Astes, wenn die nächste sichtbare Zeile auf eine niedrigere Ebene wechselt,
- `BranchEndBand.Height` ersetzt an dieser Stelle das normale `RowSpacing`; beide Werte werden nicht addiert,
- `BranchEndBand.Color` und `StyleName` erlauben eine abweichende Darstellung; der integrierte semantische Style heißt `TreeBranchEnd`,
- `IncludeEndOfData` steuert den Abschluss des letzten Astes am Datenende,
- der Look-ahead berücksichtigt nummerierte Seitengrenzen und behandelt ein Seitenende nicht als Datenende,
- `OnGetTreeLevel` und `OnGetTreeBranchEnd` erlauben alternative Datenmodelle und Sonderregeln,
- Factory- und CustomDraw-Kontext enthalten `TreeLevel`, `ClosedTreeLevels` und `Th5uElementKind.TreeBranchEndBand`,
- Separatoren und Tree-Abschlussleisten werden als gepoolte sichtbare Elemente über den lokalen Grid-Factory-Scope materialisiert,
- VCL- und FMX-ClientDataset-Demos enthalten `TREE_LEVEL`-Musterdaten und einen zuschaltbaren Test,
- veraltete Property-/Feldnamen in den ClientDataset-Demoformularen wurden bereinigt.

## 0.1.1 – 2026-09-01

### Trennflächen, Abstände und Farben

- standardmäßig 1 Pixel breite hellgraue Trennflächen zwischen Datenzeilen, Header und Columns,
- standardmäßig 1 Pixel breite hellgraue Außenabstände oben, links, rechts und unten,
- `0` deaktiviert den jeweiligen Abstand vollständig,
- `Grid.Spacing.DefaultColumnRightSpacing` als Grid-Default,
- `Column.RightSpacing = -1` erbt den Grid-Default; `0` deaktiviert den Abstand der einzelnen Column,
- `Grid.OnGetRowSpacing` erhält den vorgeschlagenen Zeilenabstand als `var`-Parameter,
- eigenständige Farben für Row-, Column- und Außenabstände,
- `Grid.Appearance.DefaultCellColor` und `Column.Color`,
- plattformneutrale ARGB-Farbwerte mit `h5uColorDefault`, `h5uColorNone`, `h5uColorLightGray` und `h5uColorFromRgb`,
- VCL- und FMX-Layout, Scrolling, HitTest und CustomDraw berücksichtigen die neuen Abstände,
- ClientDataset-Demos enthalten Schalter für Trennlinien und eigene Column-Farben.
- korrigierte Demo-DPR-Pfade im PowerShell-Buildskript.

## 0.1.0 – 2026-09-01

Erster testbarer Quellprototyp von `h5u.Grid`.

### Enthalten

- gemeinsamer Controller-, Spalten-, Options-, Selection- und Factory-Core,
- VCL-Referenzgrid und FMX-Basisgrid,
- per Gridinstanz isolierte Factory-/Registry-Scopes,
- Dataset-, Objektlisten-, VirtualSource- und Memory-Controller,
- selbstbefüllendes `Th5uSampleClientDataset` für Design-Time-Demos,
- variable Zeilenhöhen und Text-AutoHeight,
- mehrzeilige Headerlayouts,
- Zeilen-, Spalten- und Zellbereichsselektion,
- Scrollmodi und Thumb-Hints,
- Bild-/BLOB-Testpfad,
- Style-/CustomDraw-Grundlagen,
- konfigurierbare Cache- und Pagination-Grundlagen,
- sechs Demo-Projekte für VCL und FMX,
- Konzept, Entwickler-Kurzhilfe, Demo-, Build- und Funktionsdokumentation,
- reproduzierbare statische Audits und PowerShell-Buildskript.

### Bekannte Grenzen

- kein DCC-Build im Erstellungscontainer,
- VCL ist funktional weiter als FMX,
- fortgeschrittene Gruppierungs-, Tree-, VerticalGrid-, Pivot-, Export-, Druck- und Accessibility-Module sind noch nicht vollständig implementiert.
