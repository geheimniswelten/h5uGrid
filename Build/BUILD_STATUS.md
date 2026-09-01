# Build- und Prüfstatus

**Stand:** 1. September 2026  
**Prototypversion:** 0.1.0

## Umfang

- Pascal-Units unter `Source`: **20**
- eigenständige Demo-Projekte: **6**
- Plattformen im Quellpaket: **VCL und FMX**
- Datenpfade: **TDataSource/TClientDataSet, RTTI-Objektliste, Event-/VirtualSource und Memory-Controller**

## Durchgeführte Prüfungen

- Pascal-Syntaxbaum der Runtime-/Design-Units: **bestanden**
- Statischer Projekt- und Quellaudit: **bestanden**
- DFM/FMX- und Eventverdrahtung: **6 Befund(e)**
- h5u-Schreibweise: **bestanden**
- Unit-/Plattform-Namensräume: **bestanden**
- Platzhalter/TODO in Source: **bestanden**
- Direkte Erzeugung austauschbarer Visual-/Strategieklassen: **18 Befund(e)**
- Package- und Demo-Dateipfade: **bestanden**
- ClientDataSet-Demos ohne externe Daten-/Datenbankdatei: **bestanden**
- sechs erwartete Demo-Kombinationen VCL/FMX × ClientDataSet/ObjectList/VirtualLive: **bestanden**

## Delphi-Kompilierung

Im Prüfcontainer ist **kein Embarcadero-Delphi-Compiler** vorhanden. Deshalb enthält das Paket keine kompilierten BPL/DCU/EXE-Dateien und dieser Bericht behauptet keinen erfolgreichen DCC-Build.

Der Quellstand wurde statisch geprüft; der maßgebliche nächste Test ist der Build mit der konkret eingesetzten Delphi-Version. Besonders VCL-/FMX-API-Details können zwischen Releases abweichen.

## Einordnung des Prototyps

- Die **VCL-Implementierung ist der vollständigere Referenzpfad**.
- Die **FMX-Implementierung verwendet denselben Core und dieselben Controller**, besitzt im ersten Teststand aber noch nicht bei allen Komfortfunktionen vollständige Parität.
- Sortier-, Filter-, Gruppierungs-, Tree-, Footer-, SubView-, VerticalGrid-, Export- und Druckmodule sind architektonisch vorbereitet beziehungsweise dokumentiert, aber **nicht sämtlich als fertige Produktfunktionen implementiert**.
- Die ausgelieferten Factory-, Controller-, Spalten-, Selektions-, Layout-, Style- und Virtualisierungsgrundlagen sind der Gegenstand dieses Testpakets.

## Reproduzierbare Prüfungen

```text
Build\run-static-audit.cmd
Build\build-delphi.ps1 -DelphiBin "C:\Program Files (x86)\Embarcadero\Studio\<Version>\bin"
```

Einzelberichte befinden sich ebenfalls im Verzeichnis `Build`.
