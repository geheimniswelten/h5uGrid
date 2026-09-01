# h5u.Grid – Funktionsmatrix des Prototyps

Legende:

- **Ja**: im Teststand implementiert
- **Basis**: wesentlicher Pfad vorhanden, noch nicht vollständig ausgebaut
- **Modell**: Core-/Konfigurationsmodell vorhanden, Renderer oder UI noch nicht vollständig
- **Geplant**: für eine folgende Ausbaustufe vorgesehen

| Funktion | Core | VCL | FMX | Statushinweis |
|---|---:|---:|---:|---|
| DataSource/DataSet | Ja | Ja | Ja | Snapshot-/Cachepfad vorhanden |
| Objektliste/RTTI | Ja | Ja | Ja | optionaler Value-Cache |
| VirtualSource/Events | Ja | Ja | Ja | synchroner Demo-Fetch und Live-Notify |
| Memory-Controller | Ja | Ja | Ja | Basisspeicher |
| LiveBindings-Controller | Geplant | – | – | separater Adapter folgt |
| Factory-Scope pro Grid | Ja | Ja | Ja | lokales Override und Kontext |
| Shared Factory | Ja | Ja | Ja | Grid im Eventkontext |
| GetClass/Create/Configure | Ja | Ja | Ja | Erweiterungspipeline |
| sichtbare Zellobjekte/Pools | – | Ja | Ja | leichte Presenter |
| native Style-Anbindung | – | Ja | Basis | VCL umfangreicher; FMX semantische Palette plus Styled Controls |
| Classic2000/Modern/Dark | – | Ja | Ja | Built-in-Themes |
| CustomDraw | – | Ja | Basis | VCL Referenzpfad vollständiger |
| 1-px-Trennflächen als Default | Ja | Ja | Ja | hellgrau; Größe `0` deaktiviert |
| Außenabstände am Grid-Inhalt | Ja | Ja | Ja | oben/links/rechts/unten getrennt |
| Column-Abstand rechts | Ja | Ja | Ja | `-1` erbt Grid-Default |
| Row-Abstand per Event | Ja | Ja | Ja | vorgeschlagener Wert als `var`-Parameter |
| Separator-CustomDraw | Ja | Ja | Ja | Row/Column/ContentPadding |
| Grid-/Column-Zellfarben | Ja | Ja | Ja | plattformneutrale ARGB-Werte |
| Textzelle | Ja | Ja | Ja | Word-Wrap |
| Boolean-Editor | Ja | Ja | Ja | aktives Control nur beim Editieren |
| Bild/BLOB/TBytes | Ja | Ja | Ja | sichtbare Dekodierung, Editorbasis |
| automatische RowHeight | Ja | Ja | Ja | MaxHeight und Event |
| unterschiedliche RowHeight | Ja | Ja | Ja | RowMetrics-Cache |
| Pixel-Scrolling | Ja | Ja | Ja | Standard |
| WholeRows/PixelSnap | Ja | Basis | Basis | Randfälle weiter testen |
| Thumb-Hint horizontal | Ja | Ja | Ja | Column-Text |
| Thumb-Hint vertikal | Ja | Ja | Ja | Wert aus Column/Event |
| ganze Row selektieren | Ja | Ja | Ja | RowKey-basiert |
| ganze Column selektieren | Ja | Ja | Ja | ID-basiert |
| mehrere Zellbereiche | Ja | Ja | Basis | VCL umfangreicher |
| Fixed Columns | Ja | Ja | Ja | links/rechts im Modell |
| Column Resize | Ja | Ja | Basis | |
| Column Move | Ja | Ja | Basis | |
| Column Hide/Chooser | Ja | Basis | Basis | Kontextmenü/Programmatik; vollständiger Chooser folgt |
| mehrzeiliger Header | Ja | Ja | Modell/Basis | `RowSpan`/`ColumnSpan` |
| mehrzeiliges RecordLayout | Modell | Geplant | Geplant | |
| periodische RowStyles | Ja | Ja | Ja | n-te Zeile |
| RowStyle über Value-Column | Ja | Ja | Ja | Boolean/Integer-Key |
| Cachemodi | Ja | Ja | Ja | None/Viewport/Paged/All/Adaptive |
| nummerierte Pagination | Ja | Ja | Ja | Demo-Schalter |
| Cursor-Paging | Modell | Geplant | Geplant | |
| Sortierung | Modell/Geplant | Geplant | Geplant | |
| FilterPanel/Filterzeile | Modell/Geplant | Geplant | Geplant | |
| Gruppierung/GroupFooter | Modell/Geplant | Geplant | Geplant | |
| TreeTableView | Geplant | Geplant | Geplant | |
| VerticalGridView | Geplant | Geplant | Geplant | |
| CardView | Geplant | Geplant | Geplant | |
| SubViews/Master-Detail | Geplant | Geplant | Geplant | |
| Summen/Footer | Geplant | Geplant | Geplant | |
| XLSX/PDF/Print | Geplant | Geplant | Geplant | Zusatzmodule |
| Accessibility | Architektur | Basis | Basis | Produktionsausbau erforderlich |

## Wichtigste Grenzen des ersten Teststands

1. Der Lieferstand wurde nicht mit DCC32/DCC64 in der Erstellungsumgebung kompiliert.
2. FMX ist der Portabilitätsnachweis, nicht in allen Details gleich weit wie VCL.
3. Sortierung, FilterPanel, Gruppierung, TreeView, VerticalGrid und Footer-Summaries sind noch keine vollständigen Laufzeitmodule.
4. Asynchroner VirtualSource-Fetch, Cancel-Tokens und echte Server-Cursor sind im Konzept vorgesehen, in den Demos aber bewusst synchron gehalten.
5. Persistenz von Benutzerlayouts ist als ID-basiertes Format konzipiert, im Teststand jedoch noch nicht als vollständiger Layout-Migrationsdienst umgesetzt.
6. Bildbearbeitung deckt Laden, Anzeigen und Rückschreiben ab; Zuschneiden, Drehen und Re-Encoding gehören in ein späteres Editor-Zusatzmodul.
7. Vor produktivem Einsatz sind Belastungstests mit sehr großen Quellen, High-DPI, verschiedenen Styles, IME, Screenreadern und den konkret unterstützten Delphi-Versionen erforderlich.
