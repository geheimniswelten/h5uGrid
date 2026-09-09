# h5u.Grid – Demoanwendungen

## VCL ClientDataset

Pfad:

```text
Demos\Vcl\ClientDataset
```

Zweck:

- `Th5uSampleClientDataset` mit selbst erzeugtem Schema und Daten
- Anzeige bereits im Designer
- keine externe Datenbank und keine `.cds`-Datei
- Text, Memo, Integer, Currency, Boolean, DateTime und BLOB-Bild
- schaltbare automatische RowHeight
- schaltbares mehrzeiliges Headerlayout
- periodische Hervorhebung jeder fünften Zeile
- wertabhängiger Style über `PRIORITY`
- Cache und Pagination
- Dark-Theme
- Bildspalte
- lokale Factory-Regel für eine spezielle Zelle
- Column verschieben
- schaltbare 1-Pixel-Trennflächen einschließlich Außenrand
- Grid-Defaultfarbe und eigene Farben einzelner Columns
- eigener rechter Abstand der Beschreibungs-Column
- `TREE_LEVEL`-Musterdaten und schaltbare Tree-Abschlussleiste, die das normale Row-Spacing am Astende ersetzt
- unsichtbare `FOLD_GROUP`-Column für aufeinanderfolgende gleiche IDs
- wiederkehrende ID `1` in zwei getrennten Läufen, um unabhängige Faltzustände zu demonstrieren
- schaltbares Adjacent-Group-Folding mit Plus-/Minus-Symbol
- Abschlussleistenmodus `Nie`, `Nur eingeklappt`, `Nur ausgeklappt` oder `Immer`
- Schaltfläche zum gemeinsamen Ein- und Ausklappen aller faltbaren Läufe

Dies ist die wichtigste Referenzdemo des Prototyps.

## VCL ObjectList

Pfad:

```text
Demos\Vcl\ObjectList
```

Zweck:

- Laufzeitobjekte mit RTTI-Properties
- direkte Werte ohne Datenbank
- optionaler Value-Cache
- Timer ändert Objekte laufend
- Gridaktualisierung ohne Neuaufbau der gesamten Anwendung

## VCL VirtualLive

Pfad:

```text
Demos\Vcl\VirtualLive
```

Zweck:

- Datenanzahl, RowKeys und Werte ausschließlich über Events
- laufendes Anhängen neuer Datensätze
- Änderung bereits sichtbarer Datensätze
- optionales Paging und Cacheverhalten
- Beispiel für Monitoring, Queue, Log und Backend-Streaming

## FMX ClientDataset

Pfad:

```text
Demos\FMX\ClientDataset
```

Zweck:

- gleicher Dataset-Core mit FMX-Renderer
- selbst erzeugte Designer-Daten
- zentrale Optionen für AutoHeight, Theme, Cache und Paging
- Text-, Boolean- und Bilddarstellung
- schaltbare 1-Pixel-Trennflächen und Column-Farben
- eigener rechter Column-Abstand als Layoutbeispiel
- derselbe `TREE_LEVEL`-/Tree-Abschlussleisten-Test wie unter VCL
- derselbe `FOLD_GROUP`-Test mit unabhängigen, aufeinanderfolgenden Läufen
- dieselben vier Sichtbarkeitsmodi der Adjacent-Group-Abschlussleiste

## FMX ObjectList

Pfad:

```text
Demos\FMX\ObjectList
```

Zweck:

- RTTI-Objektliste
- laufende Änderungen
- Test der gemeinsamen Controller-API unter FMX

## FMX VirtualLive

Pfad:

```text
Demos\FMX\VirtualLive
```

Zweck:

- eventbasierte Livequelle
- Append-/Update-Verhalten
- Test von Scrolling und Cache bei sich ändernder Datenmenge

## Maus und Touch

Alle sechs Demos setzen `Grid.Customization.ColumnMovingGesture := Th5uColumnMovingGesture.Drag`.
Einfaches Ziehen am Spaltenkopf verschiebt die Spalte. Ctrl-Klick markiert einzelne Spalten;
Shift-Klick erweitert die Header-Auswahl. Die Komponente selbst verwendet weiterhin
`AltDrag` als Standard; bei dieser Einstellung markiert normales Ziehen einen Spaltenbereich.

Am rechten Rand eines Spaltenkopfs zeigt `crHSplit` die Größenänderung an. Der Bereich
erstreckt sich vier Koordinateneinheiten zu beiden Seiten des Rands. In FMX beträgt die
Touch-Trefferzone zwölf Einheiten je Seite. Beide Seiten sind über
`Customization.ColumnResizeHitZoneLeft/Right` und
`Customization.TouchColumnResizeHitZoneLeft/Right` getrennt einstellbar.
Für die letzte eingeblendete Spalte überschreiben `LastColumnResizeHitZoneLeft`
und `TouchLastColumnResizeHitZoneLeft` den linken Abstand; Standard `-1` übernimmt den normalen Wert. Touch-Ziehen am Header verschiebt ohne Alt;
Wischen im Datenbereich scrollt. Die fixierte ID bleibt dabei stehen; andere Spalten
wandern dahinter, ohne ihre gespeicherte Breite zu ändern. Beschriftungen behalten
ihre Breite und werden am Rand abgeschnitten.

Die beiden ClientDataset-Demos zeigen ein schaltbares zweizeiliges Headerlayout.
Die ID steht separat fest über beide Zeilen. Die Gruppen „Stammdaten“, „Mengen und
Bewertung“ und „Status / Medien“ lassen sich mitsamt Unterheadern und Datenspalten
verschieben. Unterheader lassen sich innerhalb ihrer Gruppe umordnen. Gruppen bleiben
zusammenhängend und überschreiten keine fixierten Bereiche. Verdeckte Kind-Spaltengrenzen
sind im oberen Gruppenheader keine Resize-Treffer; dort zählt der sichtbare Gruppenrand.

In VCL und FMX bleibt beim Ziehen der Ausgangsheader markiert. Eine Beschriftung folgt der
Maus bzw. dem Finger, und eine senkrechte Linie zeigt die gültige Einfügeposition.
Erst beim Loslassen wird die Reihenfolge geändert. Bei einem markierten Block zeigt
die Beschriftung zusätzlich die Anzahl weiterer Spalten an. Ungültige Ziele haben
keine Einfügelinie; Escape oder Capture-Verlust entfernt die Rückmeldung.
In FMX aktualisieren native Pan-Ereignisse von Maus und Touch die am Header begonnene
Aktion, ohne gleichzeitig zu scrollen. VCL aktualisiert auch während Capture den
sichtbaren Drag-/Resize-Cursor und stellt ihn beim Abschluss wieder her.

In den Dataset-Demos schaltet „1 px Trennlinien“ die allgemeinen Linien. Der explizite
8-Pixel-Spaltentrenner zwischen Beschreibung und Menge bleibt sichtbar, ebenso die
aktivierten breiteren Zeilentrenner.

## Empfohlene Testreihenfolge

1. VCL ClientDataset bauen und starten.
2. RowHeight, Trennlinien, Tree-Abschlussleiste, Column-Farben, Dark Mode, Bildspalte und Paging einzeln schalten.
3. `Folgegruppen falten` aktivieren und die beiden getrennten Läufe mit ID `1` unabhängig öffnen und schließen.
4. Alle vier Abschlussleistenmodi prüfen. Die Leiste muss das normale Row-Spacing ersetzen und darf nicht zusätzlich erscheinen.
5. Columns per Maus verschieben, skalieren und ausblenden. Die ausgeblendete `FOLD_GROUP`-Column muss weiterhin funktionieren.
6. Row-, Column- und Zellbereichselektion prüfen.
7. ObjectList-Demo mit Cache an/aus vergleichen.
8. VirtualLive-Demo während laufender Inserts scrollen.
9. Anschließend dieselben Datenpfade in FMX vergleichen.

## Designer-Test

Nach Installation der Design-Packages:

1. Neues VCL- oder FMX-Formular erstellen.
2. `Th5uSampleClientDataset` aus `h5u Data` ablegen.
3. `TDataSource` und `Th5uDatasetController` verbinden.
4. `Th5uVclGrid` beziehungsweise `Th5uFmxGrid` aus `h5u Grid` ablegen.
5. Controller zuordnen.
6. Columns erzeugen beziehungsweise die Demoform als Vorlage öffnen.

`Th5uSampleClientDataset` aktiviert sich mit Beispieldaten. Ändern von `SampleRowCount` oder `IncludeImages` erzeugt die Daten erneut.
