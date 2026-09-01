# h5u.Grid – Demoanwendungen

## VCL ClientDataSet

Pfad:

```text
Demos\Vcl\ClientDataSet
```

Zweck:

- `Th5uSampleClientDataSet` mit selbst erzeugtem Schema und Daten
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

## FMX ClientDataSet

Pfad:

```text
Demos\FMX\ClientDataSet
```

Zweck:

- gleicher DataSet-Core mit FMX-Renderer
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

## Empfohlene Testreihenfolge

1. VCL ClientDataSet bauen und starten.
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
2. `Th5uSampleClientDataSet` aus `h5u Data` ablegen.
3. `TDataSource` und `Th5uDataSetController` verbinden.
4. `Th5uVclGrid` beziehungsweise `Th5uFmxGrid` aus `h5u Grid` ablegen.
5. Controller zuordnen.
6. Columns erzeugen beziehungsweise die Demoform als Vorlage öffnen.

`Th5uSampleClientDataSet` aktiviert sich mit Beispieldaten. Ändern von `SampleRowCount` oder `IncludeImages` erzeugt die Daten erneut.
