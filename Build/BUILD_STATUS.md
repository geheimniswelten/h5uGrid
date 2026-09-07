# Build- und Prüfstatus

**Stand:** 2. September 2026  
**Prototypversion:** 0.1.4

## Umfang

- gemeinsamer Delphi-Core sowie getrennte VCL-/FMX-Renderer,
- sechs Demo-Projekte,
- Datenpfade für `TDataSource`/`TClientDataset`, RTTI-Objektlisten, Memory-Daten und Event-/VirtualSource,
- Spacing-, Separator- und Farb-API in VCL und FMX,
- Tree-Ast-Abschlussleiste mit Level-Column-/Event-Erkennung, eigenem Style und per Grid austauschbarer Factory-Zelle,
- Adjacent-Group-Folding für unmittelbar aufeinanderfolgende gleiche IDs mit unabhängigen Wiederholungen,
- Plus-/Minus-Faltzeichen und alternative Abschlussleiste mit den Modi `Never`, `CollapsedOnly`, `ExpandedOnly` und `Always`,
- Pascal-Quellformat: Code maximal 150 Zeichen, Properties/Signaturen maximal 180 Zeichen.

## Quellformatierung

Property-Deklarationen, prozedurale Eventtypen sowie Methoden- und Funktionssignaturen bleiben einzeilig, solange sie einschließlich Einrückung höchstens 180 Zeichen lang sind. Längere Signaturen werden an Parametergrenzen fortgesetzt.

Der mitgelieferte Formatter verändert ausschließlich diese Deklarationsblöcke:

```text
python Build\format_pascal.py
python Build\format_pascal.py --check
```

Die ursprünglichen und formatierten Pascal-Quellen wurden zusätzlich lexikalisch verglichen. Außerhalb von Whitespace gab es keine Tokenänderung.

## Durchgeführte Prüfungen

- Dateistruktur, Unit- und Dateinamen,
- Package- und DPR-Quellpfade,
- PowerShell-Buildskript referenziert alle enthaltenen Packages und Demo-DPRs,
- DFM-/FMX-Ressourcen und Eventhandler,
- h5u-Namenskonventionen und Plattformtrennung,
- Pascal-Zeilenbreiten 150/180 und Operatoren am Anfang der Folgezeile,
- fünf fokussierte Semantiktests für Property-, Eventtyp- und Methodensignaturformatierung,
- Factory-IDs, Optionen, Kontexte und öffentliche API des Adjacent-Group-Foldings,
- lokale Factory-Erzeugung von Faltzeichen und Abschlussleiste in VCL und FMX,
- sichtbare View-zu-Controller-Abbildung ohne Änderung der Quellreihenfolge,
- Zustandsanker aus erstem RowKey des jeweiligen zusammenhängenden Laufs,
- ausgeblendete `FOLD_GROUP`-Column und getrennte Wiederholungen derselben ID in beiden ClientDataset-Demos,
- Ersatz statt Addition von `RowSpacing` durch Tree- und Adjacent-Group-Abschlussleisten,
- semantischer Tree-Test mit 12 Fällen,
- semantischer Adjacent-Group-Test mit 16 Fällen einschließlich aller vier Abschlussleistenmodi,
- Deklarations-/Implementierungskonsistenz der geänderten Core-, Options-, VCL- und FMX-Klassen.

Die aktuellen maschinellen Ergebnisse stehen in `STATIC_AUDIT.md` und `RELEASE_AUDIT.md`.

## Delphi-Kompilierung

Im Prüfcontainer ist **kein Embarcadero-Delphi-Compiler** vorhanden. Deshalb enthält das Paket keine kompilierten BPL/DCU/EXE-Dateien und dieser Bericht behauptet keinen erfolgreichen DCC-Build.

Die statischen Prüfungen ersetzen insbesondere keine Prüfung versionsabhängiger VCL-, FMX- und `designide`-APIs mit der konkret eingesetzten Delphi-Version.

## Einordnung des Prototyps

- Die VCL-Implementierung bleibt der vollständigere Referenzpfad.
- FMX verwendet denselben Core und dieselben Controller; einzelne Komfortfunktionen besitzen noch keine vollständige Parität.
- Adjacent-Group-Folding ist als eigenständige sichtbare Laufabbildung umgesetzt. Es ersetzt keine vollständige normale Gruppierungsengine.
- Der aktuelle Laufindex wird aus der geladenen Controller-Ansicht beziehungsweise der aktuellen nummerierten Seite aufgebaut. Für sehr große Remotequellen ist später eine servergestützte Laufmetadaten-Schnittstelle sinnvoll.
- Sortier-, Filter-, vollständige Gruppierungs-, vollständige TreeView-, Footer-, SubView-, VerticalGrid-, Export- und Druckmodule bleiben weitere Ausbaustufen.

## Reproduzierbare Prüfungen

```text
python Build\format_pascal.py --check
python Build\source_audit.py
python Build\test_tree_branch_end.py
python Build\test_adjacent_group_folding.py
python Build\release_audit.py
Build\build-delphi.ps1 -DelphiBin "C:\Program Files (x86)\Embarcadero\Studio\<Version>\bin"
```
