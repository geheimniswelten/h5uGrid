# Spaltenbreiten in VCL und FMX

Beide Grids verwenden dieselbe Breitenberechnung. VCL arbeitet in Pixeln, FMX
wie bisher in logischen Einheiten. Die tatsächlich verwendete ganzzahlige Breite
steht in `Column.LayoutWidth`; `Column.Width` bleibt der gespeicherte Pixelwert.

## Breitenmodi

| Einstellung | Verhalten |
| --- | --- |
| `AutoWidth = False`, `WidthInPercent = 0` | Feste Breite aus `Width`. |
| `AutoWidth = True` | Breite anhand der formatierten Zellinhalte und des jeweiligen Editors. |
| `AutoWidth = False`, `WidthInPercent > 0` | Anteil an der verbleibenden Breite des Views bzw. des nächsten übergeordneten Gruppenheaders. |

`AutoWidth` hat Vorrang vor `WidthInPercent`. `MinWidth` und `MaxWidth` an der
Spalte gelten für alle drei Modi. `MaxWidth = 0` bedeutet unbegrenzt.
Die bisherigen Standardwerte bleiben erhalten: `Width = 100`, `MinWidth = 24`,
`MaxWidth = 1000`, `AutoWidth = False`, `WidthInPercent = 0`.

Prozentwerte von 0 bis 100 sind zulässig; positive Werte werden pro Ebene als
relative Anteile normalisiert. 25/75 und 20/60 ergeben daher dieselbe Aufteilung.
Zuerst werden feste und automatisch gemessene Breiten sowie alle Spaltenabstände
abgezogen. Erreicht eine flexible Spalte eine Grenze, wird der Rest unter den
anderen flexiblen Spalten verteilt. Rundungsreste werden deterministisch verteilt.
Ausgeblendete Spalten benötigen weder Breite noch Abstand. Fixierte Spalten links
und rechts sind Teil desselben Inhaltsbudgets.

Beispiel: 503 Einheiten Inhaltsbreite, drei Spalten mit je 1 Einheit Abstand,
erste Spalte fest 100, danach 25/75 Prozent: Die Breiten sind 100, 100 und 300.
Ein Minimum von 150 für die zweite Spalte ergibt 100, 150 und 250.

## Gesamtbreite am Grid

`Grid.MinWidth` und `Grid.MaxWidth` begrenzen das Breitenbudget des gesamten
sichtbaren Spalteninhalts einschließlich der Spaltenabstände. Sie verändern
**nicht** `Grid.Width` bzw. die Größe der Komponente. Beide Werte sind anfangs 0
(keine Grenze). Zeilenindikator, Außenabstände und Scrollbars zählen nicht zum
Spalteninhalt; sie werden bereits von der verfügbaren Viewbreite abgezogen.

```pascal
Grid.MinWidth := 600;
Grid.MaxWidth := 1200;
Grid.Columns[0].Width := 120;
Grid.Columns[1].WidthInPercent := 40;
Grid.Columns[2].WidthInPercent := 60;
```

Das Grid kann durch `MinWidth` horizontal scrollbar werden, obwohl seine
Komponente kleiner ist. `MaxWidth` kann rechts freien Platz lassen. Die Größe
einer Komponente begrenzt man weiterhin mit ihren nativen Layout-Eigenschaften.

Feste Pixelbreiten und die Grenzen der einzelnen Spalten haben bei unmöglichen
Vorgaben Vorrang: 800 feste Einheiten passen nicht in `Grid.MaxWidth = 600`.
In diesem Fall bleibt der Inhalt scrollbar. Umgekehrt erzeugt `MinWidth` keine
zusätzliche Spaltenbreite, wenn es keine dehnbaren Prozent-Spalten gibt oder
alle bereits ihr Maximum erreicht haben. Das gleiche Prinzip gilt für Gruppen.

## Gruppenheader

Gruppen sind `HeaderLayout.Cells` ohne `ColumnId`. Die Zugehörigkeit folgt dem
bestehenden mehrzeiligen Headerlayout, einschließlich der Bindung von
Blattheadern über `ColumnId`. Prozent-Spalten werden innerhalb ihres nächsten
umschließenden Gruppenheaders verteilt; Spalten ohne Gruppe beziehen sich auf
den View. Das gilt rekursiv für verschachtelte Gruppen.

Gruppenheader besitzen ebenfalls `Width`, `WidthInPercent`, `MinWidth` und
`MaxWidth` (jeweils Standard 0):

- `Width > 0` gibt der Gruppe eine feste Breite.
- `WidthInPercent > 0` beteiligt die Gruppe prozentual am Platz ihres Elternheaders bzw. des Views.
- Sind beide 0, ergibt sich die natürliche Breite aus den Kindern. Enthält die Gruppe Prozent-Kinder, übernimmt sie deren summiertes Gewicht auf ihrer Elternebene.
- Die Gruppenbreite enthält innere Spaltenabstände; der Abstand rechts hinter der Gruppe zählt zusätzlich.
- Die Gruppengrenzen werden mit den erreichbaren Grenzen der Kindspalten geschnitten.

Eine Gruppe mit `Width = 400`, einer festen Kindspalte mit 100 und zwei
Prozent-Kindern mit 30/70 erhält bei Abstand 0 die Kindbreiten 100/90/210.
Außerhalb liegende Prozent-Spalten teilen den verbleibenden Viewplatz.

## Zellinhalte messen

```pascal
Column.AutoWidth := True;
Grid.AutoWidthRowLimit := 1000; // Standard: erste 1000 Zeilen des aktuellen Daten-Views
Grid.AutoWidthRowLimit := 0;    // alle Zeilen, bei großen Datenquellen entsprechend teuer

// Nur berechnen, ohne Width oder den aktiven Editor zu ändern:
NeededWidth := Grid.MeasureColumnWidth(Column);
NeededWidth := Grid.MeasureColumnWidth(Column, 100, 200);

// Einmal messen und danach als feste Pixelbreite übernehmen:
Grid.AutoSizeColumn(Column);
```

Die Messung verwendet formatierte Anzeigewerte und die Editorauflösung pro Zelle.
Text wird ungekürzt einschließlich Innenabstand gemessen; Checkboxen verwenden
ihre Glyphenbreite, Bilder ihre natürliche Breite plus Innenabstand. Headertexte
sind kein Teil dieser Zellinhaltsmessung. Die Ergebnisse respektieren die
Spaltengrenzen. Bereits offene Editoren und ungespeicherte Eingaben bleiben bei
`MeasureColumnWidth` unverändert.

Automatische Messwerte werden zwischengespeichert und bei Daten-, Spalten-,
Schrift- und relevanten Layoutänderungen neu berechnet. Virtuelle Quellen werden
in kleinen Bereichen vorbereitet; noch nicht verfügbare Zeilen werden übersprungen
und nach einer Datenbenachrichtigung erneut berücksichtigt. Änderungen an eigenen
Darstellungsfunktionen, Editorvorlagen oder direkt beschreibbaren Formatfeldern
meldet man über `Grid.InvalidateColumnWidths`.

Eigene Editoren können `MeasureContentWidth(const AContext: Th5uEditorContext)`
überschreiben oder `OnMeasureWidth` verwenden. `MeasureWidth` ruft zuerst die
Messfunktion und danach den Callback auf. Die Breite enthält den Innenabstand,
aber keinen Spaltenabstand. Der Kontext liefert Grid, Spalte, Zeile, Anzeigetext,
Wert und einen plattformnativen Canvas. Ein negativer Rückgabewert verwendet die
Textmessung als Fallback. Für individuell gezeichnete Inhalte bzw. abweichende
Schriften ist `OnMeasureWidth` der passende Erweiterungspunkt.

Manuelles Ziehen einer Spaltenkante und `AutoSizeColumn` wechseln die betroffene
Spalte in den Pixelmodus (`AutoWidth = False`, `WidthInPercent = 0`). Die
berechneten Layoutbreiten werden nicht in DFM/FMX gespeichert; Konfiguration,
Gruppenbreiten und Grenzen unterstützen Streaming und `Assign`.

## Tests

`Build/TestCommonBehavior.dpr` prüft Verteilung, Grenzen, Gruppierung, Rundung,
ausgeblendete/fixierte Spalten und `Assign`. `Build/TestGridEditing.inc` prüft die
native Messung, Datenänderungen, Editorzustand, Scrollbars sowie DFM/FMX-Streaming
für VCL und FMX. Der Parameter `--column-widths` führt nur diese nativen
Breitentests aus. Bei visuellen Starts gilt der Countdown aus `AGENTS.md`.
