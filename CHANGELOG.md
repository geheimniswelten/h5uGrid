# Changelog

## Unveröffentlicht – 2026-09-09

- VCL/FMX: Gruppenheader werden auf der angeklickten Ebene erkannt und mit sämtlichen Unterheadern/Datenspalten verschoben. Quellmarkierung, Gruppenbeschriftung und Einfügelinie verwenden dieselbe Headerzelle; verdeckte Kind-Spaltengrenzen lösen oben kein Resize aus.
- FMX: mehrzeiliges HeaderLayout einschließlich Gruppen, Zeilenspannen, Styles und fixierten Bereichen wird gezeichnet. Beide Dataset-Demos zeigen dasselbe schaltbare Layout; die feststehende ID steht separat über beide Zeilen.
- Header mit `ColumnId` folgen ihrer Datenspalte; Gruppen behalten ihre zugehörigen Spalten auch beim Aus-/Einblenden. Gruppen bleiben zusammenhängend, fixierte Bereiche und MovePermission werden eingehalten. Maus-, Touch-, Pan-, Pixel- und Abbruchtests decken beide Oberflächen ab.

- VCL: Spaltenverschiebe-Markierung und Einfügelinie beginnen bei mehrzeiligen Headern an der jeweiligen unteren Headerzelle. Übergeordnete Gruppenheader bleiben frei; Zeilenspannen und Abstände werden berücksichtigt. Pixeltests prüfen die Dataset-Demo sowie ein dreizeiliges Layout.
- VCL: beim Spaltenverschieben dieselbe sichtbare Rückmeldung wie in FMX: Quellmarkierung, mitlaufende Beschriftung und Einfügelinie. Unterstützt markierte Blöcke, Themes, DPI-Skalierung und Touch-Abstand; ungültige Ziele erhalten keine Einfügelinie.
- VCL: sichtbarer Windows-Cursor wird während Maus-Capture aktualisiert. Drag-/Resize-Cursor und Rücksetzung funktionieren auch ohne weiteres `WM_SETCURSOR`; ein globaler `Screen.Cursor` behält Vorrang. Regressionstests prüfen die Windows-Cursorhandles sowie die gezeichnete Rückmeldung und deren Bereinigung.

- VCL: Maus-Capture wird nach Verarbeitung von `MouseUp` freigegeben. Die automatische VCL-Freigabe vor `MouseUp` hatte Spalten-/Zeilenverschiebungen und ausstehende Auswahl-/Editieraktionen vorzeitig abgebrochen. Regressionstests durchlaufen nun auch Windows-Mausnachrichten einschließlich Capture-Verlust und Escape.

- FMX: Maus-Pan-Ereignisse unterbrechen keine am Header begonnene Spaltenverschiebung mehr.
- FMX: sichtbare Quellmarkierung, mitlaufende Beschriftung und Einfügelinie beim Verschieben mit Maus oder Touch; Rückmeldung auch bei nativen Pan-Ereignissen und Bereinigung bei Abbruch.
- FMX: horizontales Scrollen erhält die Text-/Bildbreite auch an fixierten Spalten und Viewport-Rändern. Inhalte werden abgeschnitten, statt im sichtbaren Teil neu umbrochen oder zentriert zu werden. Sichtbare Checkbox-Treffer bleiben erhalten.
- Regressionstests für Maus-/Touch-Pan, Rückmeldung vor dem Loslassen, ungültige Ziele, Escape/Capture-Verlust und Datenbereich-Wischen mit unveränderten Spaltenbreiten.
- Dataset-Demos: „Nächste Seite“ ist nur bei aktivierter Pagination bedienbar.

- Dataset-Demos: „1 px Trennlinien“ erhält den expliziten 8-Pixel-Abstand nach Beschreibung.
- Alle sechs Demos verschieben Spalten mit normalem Ziehen am Header (`Customization.ColumnMovingGesture = Drag`).
- `Selection.RightClickSelect` (Standard `False`) für VCL/FMX: Rechtsklick fokussiert die angeklickte Zelle; eine bereits durch Zellen, Zeilen oder Spalten abgedeckte Auswahl bleibt erhalten. Sonst wird nur die angeklickte Zelle ausgewählt. Leerer Hintergrund ändert die Zellselektion nicht.
- Spaltenbreiten lassen sich in VCL und FMX an beiden Seiten des sichtbaren Header-Rands ändern; `crHSplit` zeigt den Bereich an. Capture-Verlust, Escape, Breitenlimits, gelöschte Spalten und Cursor-Rücksetzung werden berücksichtigt.
- FMX-Touch: größere Resize-Trefferzone, Header-Verschieben ohne Alt und Vorrang vor gleichzeitig gemeldeten Pan-Gesten. Der Datenbereich bleibt per Touch scrollbar; Android und iOS werden berücksichtigt.
- Die Trefferzone am Spaltenrand ist für Maus und Touch nach links/rechts getrennt über vier `Customization.*ColumnResizeHitZone*`-Properties einstellbar (Standard 4/4 und 12/12).
- Eigener linker Trefferabstand am rechten Rand der letzten eingeblendeten Spalte: `LastColumnResizeHitZoneLeft` und `TouchLastColumnResizeHitZoneLeft`, jeweils `-1` für den normalen linken Wert.
- Regressionstests für Rechtsklick, Streaming/Assign, Resize, Touch-Header, asymmetrische Trefferzonen, letzte/ausgeblendete/fixierte Spalten und Demo-Einstellungen ergänzt.

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
