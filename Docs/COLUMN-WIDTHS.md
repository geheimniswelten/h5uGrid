# Spaltenbreiten und Optionsgruppen in VCL und FMX

Beide Grids verwenden dieselbe Berechnung. Breitenvorgaben verwenden `Th5uWidth`
aus `h5u.Grid.Sizing`, einen eigenen Single-Typ:

| Wert | Bedeutung | Anzeige im PropertyEditor |
| --- | --- | --- |
| `120` | Feste Ausgangsbreite | `120` |
| `0` | Vorgabe übernehmen | `Default` |
| `-25.5` | Prozentuale Ausgangsbreite | `25,5 %` bei deutschem Zahlenformat |
| `-200` | 200 Prozent | `200 %` |

VCL verwendet Pixel, FMX logische Einheiten. `Column.Width` behält die Vorgabe;
`Column.LayoutWidth` liefert das berechnete logische Ergebnis als `Single`. VCL
und LCL runden die fertigen Zellgrenzen auf ganze Pixel; FMX behält Bruchteile.
`Visible=False` blendet die Spalte unter Beibehaltung der Vorgabe aus.

Delphi-IDE und h5u-PropertyEditor verwenden dieselbe Textkonvertierung. Zulässig
sind `Default`, Zahlen, Prozentangaben und optional `px`. Nachkommastellen und
Prozentwerte über 100 sind erlaubt. `Unlimited` bezeichnet die technisch begrenzte
Obergrenze `h5uUnlimitedWidth`.

## Verteilung

`Grid.ColumnSizing.FitMode` steuert die Anpassung:

| Modus | Verhalten |
| --- | --- |
| `None` | Pixel bleiben fest. Prozente beziehen sich unmittelbar auf die verfügbare View- oder Gruppenbreite; 200 Prozent können Überlauf erzeugen. |
| `PercentColumns` | Pixel- und automatisch gemessene Breiten werden reserviert. Prozentspalten teilen den Rest nach ihren Gewichten. Dieser Standard erhält das bisherige Verhalten. |
| `AllColumns` | Pixel-, Prozent- und automatisch gemessene Breiten sind Ausgangsgrößen für die proportionale Anpassung aller sichtbaren Spalten. |

Bei normalisierter Verteilung ergibt `20 % / 20 %` dieselbe Aufteilung wie
`50 % / 50 %`. Im Modus `AllColumns` ergibt `100 px / 200 px` ein Verhältnis
von 1:2. Gemischte Angaben werden zuerst auf derselben Bezugsebene in
Ausgangsbreiten umgerechnet und dann gemeinsam verteilt.

Abstände werden vorher abgezogen. Ausgeblendete Spalten benötigen weder Breite
noch Abstand; links/rechts fixierte Spalten gehören zum selben Budget.
Rundungsreste werden deterministisch verteilt.

## Defaults und Grenzen

Bei `Column.Width=0` gilt: `ColumnSizing.DefaultWidth`, dann die
`DefaultWidth` der statisch zugeordneten Editorvorlage, dann der passende
Editor-/Typstandard. Jede Ebene mit Wert 0 wird übersprungen. Die Auflösung
benötigt keine Datenzeilen und keine zeilenabhängigen Editorereignisse.

Checkboxen erhalten standardmäßig Breite, Minimum und Maximum 28. Die allgemeine
Textvorgabe ist Breite 100, Minimum 24, Maximum 3000. Editorvorlagen besitzen
`DefaultWidth`, `DefaultMinWidth` und `DefaultMaxWidth`; die entsprechenden
Gridvorgaben können sie überschreiben. Explizite Spaltenwerte haben Vorrang.

`Column.MinWidth` bleibt eine absolute Grenze in logischen Einheiten. Ausdrücklich gesetzte
0 bedeutet kein Minimum; eine unberührte Mindestbreite übernimmt den
Editor-/Typstandard. `Column.MaxWidth` unterstützt Pixel und Prozent wie `Width`;
0 übernimmt die Default-Obergrenze. Prozentuale Maxima werden gegen die verfügbare
View- oder Gruppenbreite aufgelöst.

**Minima und aufgelöste Maxima werden niemals mitskaliert.** Spalten an einer
Grenze werden aus der weiteren Verteilung genommen. Der Rest verteilt sich auf
die verbleibenden flexiblen Spalten. Reicht der Platz für die Minima nicht,
entsteht horizontaler Überlauf. Erreichen alle Spalten ihr Maximum, bleibt Platz frei.

```pascal
Grid.ColumnSizing.FitMode := Th5uColumnFitMode.AllColumns;
Grid.ColumnSizing.DefaultMaxWidth := 3000;
CheckColumn.MinWidth := 28;
CheckColumn.MaxWidth := 28;
TextColumn.Width := -100;
TextColumn.MinWidth := 80;
TextColumn.MaxWidth := -200;
```

`ColumnSizing.MaxWidthSource := Th5uMaxWidthSource.Monitor` verwendet die nutzbare
Monitorbreite als allgemeine Default-Obergrenze. Explizite Spalten-, Grid- und
Editor-Maxima haben Vorrang. Die Checkbox-Vorgabe bleibt schmal. Ein geänderter
Bezugsbereich wird beim nächsten Layout berücksichtigt.

`ColumnSizing.MinContentWidth` und `MaxContentWidth` begrenzen das gesamte
Spaltenbudget einschließlich innerer Abstände. 0 setzt hier keine zusätzliche
Grenze. Sie ändern nicht die Größe der Grid-Komponente; dafür gelten `Grid.Width`
und die nativen `Constraints`.

## Automatisches Ausmessen

```pascal
Column.AutoWidth := True;
Grid.ColumnSizing.AutoWidthRowLimit := 1000;
NeededWidth := Grid.MeasureColumnWidth(Column);
NeededWidth := Grid.MeasureColumnWidth(Column, 100, 200);
Grid.AutoSizeColumn(Column);
```

Gemessen werden formatierte Zellwerte mit den tatsächlichen Zelleditoren und
deren Innenabständen. Headertexte gehören nicht zur Zellinhaltsmessung.
`AutoWidthRowLimit=0` erlaubt alle Zeilen. Sobald die Obergrenze einer Spalte
erreicht ist, endet ihre Messung. Andere Spalten werden unabhängig weitergemessen.
Sind Minimum und Maximum identisch, ist bereits vor dem Datenzugriff Schluss.

Messwerte werden gecacht. Daten-, Schrift-, relevante Layout- und
Editorvorgabenänderungen machen sie ungültig; die Spalte kann bei einer erneuten
Messung auch wieder schrumpfen. Editorvorlagen und `DefaultEditors` benachrichtigen
das Grid bei Änderungen. Änderungen eigener Darstellungsfunktionen meldet man
über `Grid.InvalidateColumnWidths`. Die Messung aktiviert keinen Editor und
verändert keine laufende Texteingabe.

Ändert eine neue Breitenvorgabe während der Bearbeitung die Zellposition oder
-größe, folgt das Eingabefeld beim nächsten Zeichnen der Zelle. Die laufende
Eingabe bleibt dabei erhalten.

Eigene Editoren können `MeasureContentWidth` oder `OnMeasureWidth` verwenden.
Ein negativer Messwert verwendet die Textmessung als Fallback. Virtuelle Quellen
werden in kleinen Bereichen vorbereitet.

Manuelles Ziehen und `AutoSizeColumn` setzen positive Pixelvorgaben und
deaktivieren `AutoWidth`. Bei `AllColumns` bleibt auch diese Pixelvorgabe eine
Ausgangsgröße für die gemeinsame Anpassung.

## Gruppenheader

Das mehrzeilige Layout liegt unter `Grid.Header.Layout`. Seine `Cells` ohne
`ColumnId` sind Gruppen. Blattheader bleiben über `ColumnId` mit den Spalten
verbunden, auch beim Verschieben und Ausblenden.

Gruppen unterstützen `Width`, `MinWidth` und `MaxWidth`. `Width=0` bedeutet
natürliche Breite aus den Kindern; `MaxWidth=0` setzt bei Gruppen keine eigene
Obergrenze. Prozentwerte der Kinder beziehen sich auf die nächste umschließende
Gruppe. Gruppenbreiten enthalten innere Abstände; ihre Grenzen werden mit den
erreichbaren Grenzen der Kinder kombiniert.

## Aufgeräumte Optionsgruppen

| Gruppe | Einstellungen |
| --- | --- |
| `ColumnSizing` | Defaultbreiten, Anpassungsmodus, Messlimit, Spaltenbudget |
| `Header` | `Visible`, `RowHeight`, `Layout` |
| `RowIndicator` | `Visible`, `Width` |
| `Editing` | `AllowEditing`, `ImmediateEdit` |
| `Appearance` | `Theme`, `DefaultCellColor`, `RowSpacingColor`, `ColumnSpacingColor`, `ContentPaddingColor` |
| `Spacing` | Außen-, Zeilen- und Spaltenabstände |
| `RowHeight` | Bestehende Höhenvorgaben und Messoptionen |

Reine Farbänderungen in `Appearance` fordern nur neues Zeichnen an; Breiten- und
Höhenmesswerte bleiben erhalten. Ein Themewechsel invalidiert Messwerte, weil er
layoutrelevante Darstellung verändern kann.

VCL-/FMX-PropertyEditor-Komponenten starten mit Breite 350 und einer Aufteilung
von 60 Prozent für Bezeichnungen und 40 Prozent für Werte. Scrollbar und Abstände
werden bei der verfügbaren Spaltenfläche berücksichtigt.

## Kompatibilität

Geometrische Einzelwerte und gemeinsame Messschnittstellen verwenden `Single`.
Das betrifft auch `OnMeasureWidth` (`var AWidth: Single`) sowie die Rückgabewerte
von `MeasureContentWidth` und `MeasureWidth`. Eigene Editor-Ableitungen und
Ereignishandler müssen diese Signaturen übernehmen. Die FMX-Methode
`MeasureColumnWidth` liefert ebenfalls `Single`; VCL und LCL liefern `Integer`.

Großräumige Höhenberechnungen und vertikale Scrolloffsets behalten `Double`
beziehungsweise `Int64`. Einzelhöhen, Abstände und ihre gemeinsamen Optionen
verwenden `Single`. VCL und LCL wenden dieselbe Pixelrundung beim Zeichnen und
bei der Gesamthöhenberechnung an. Eine nachträgliche Skalierung der Min-/Max-Grenzen
findet dadurch nicht statt.

`Unlimited` verwendet jetzt den exakt als `Single` darstellbaren Wert 536870912.
Der vorherige Wert 536870911 wird beim Laden auf denselben neuen Wert abgebildet.

Die bisherigen direkten Grid-Eigenschaften bleiben als weiterleitende Aliase
verfügbar, etwa `ShowHeader`, `HeaderRowHeight`, `HeaderLayout`, `RowIndicatorWidth`,
`AllowEditing`, `Theme` und `AutoWidthRowLimit`. IDE und automatischer
h5u-PropertyEditor zeigen die neuen Gruppen. Manuelles Einfügen eines Alias in
die Propertyliste bleibt möglich.

Alte DFM/FMX-Dateien einschließlich Farben unter `Spacing` bleiben lesbar.
Neue Dateien speichern die kanonischen Gruppen und die interne Kennung
`SizingVersion`. Damit werden ausgelassene alte Spaltenvorgaben von 100/1000
beim Laden erhalten; ein altes ausdrückliches `MaxWidth=0` wird zu `Unlimited`.
Moderne Vorgaben von 0 bleiben Default, auch beim Zurücksetzen geerbter Vorgaben.

`WidthInPercent` bleibt als öffentliche Kompatibilitätseigenschaft und als Leser
alter Formulardaten erhalten. Im Objektinspektor wird nur noch `Width` angeboten.
Ein Prozentwert wird direkt als negatives `Width` gespeichert.

## Prüfungen

`Build/test-common.ps1` prüft Verteilung, Bruchteile, Grenzen, Gruppen, Defaults,
Textkonvertierung und vererbtes Streaming. `Build/test-sizing-options.ps1` prüft
beide Adapter ohne sichtbare Fenster: Optionsmigration, PropertyEditor-Aufteilung,
Messabbruch, Editorvorgaben, Farbänderungen ohne erneute Messung, Monitorgrenzen
und native DFM/FMX-Roundtrips. `Build/test-grid-performance.ps1` prüft weiterhin
das Scrollen großer Listen. `Build/test-editor-bounds.ps1` prüft das Anpassen
vorhandener Eingabefelder unter Erhalt ihrer Eingabe, ohne sie zu aktivieren.
`Build/test-geometry-precision.ps1` prüft gebrochene FMX-Messwerte, die Genauigkeit
beim Touchscrollen großer Listen sowie die konsistente VCL-Pixelrundung von
Spalten, Trennflächen und HitTests. Auch diese Prüfungen öffnen keine Fenster.
