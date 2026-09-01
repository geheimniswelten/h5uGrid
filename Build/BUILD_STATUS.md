# Build- und Prüfstatus

**Stand:** 1. September 2026  
**Prototypversion:** 0.1.1

## Umfang

- gemeinsamer Delphi-Core sowie getrennte VCL-/FMX-Renderer,
- sechs Demo-Projekte,
- Datenpfade für `TDataSource`/`TClientDataSet`, RTTI-Objektlisten, Memory-Daten und Event-/VirtualSource,
- neue Spacing-, Separator- und Farb-API in VCL und FMX.

## Durchgeführte Prüfungen

- Dateistruktur, Unit- und Dateinamen,
- Package- und DPR-Quellpfade,
- PowerShell-Buildskript referenziert alle enthaltenen Packages und Demo-DPRs,
- DFM-/FMX-Ressourcen und Eventhandler,
- h5u-Namenskonventionen und Plattformtrennung,
- Vorhandensein der neuen Spacing-/Farb-Signaturen,
- Standardwerte `1 px` und `h5uColorLightGray`,
- `RightSpacing = -1` als Vererbung und `0` als Deaktivierung,
- Demo-Verdrahtung für Trennflächen und Column-Farben,
- Deklarations-/Implementierungskonsistenz der geänderten Core-, Column-, VCL- und FMX-Klassen.

Die aktuellen maschinellen Ergebnisse stehen in `STATIC_AUDIT.md` und `RELEASE_AUDIT.md`.

## Delphi-Kompilierung

Im Prüfcontainer ist **kein Embarcadero-Delphi-Compiler** vorhanden. Deshalb enthält das Paket keine kompilierten BPL/DCU/EXE-Dateien und dieser Bericht behauptet keinen erfolgreichen DCC-Build.

Die statischen Prüfungen ersetzen insbesondere keine Prüfung versionsabhängiger VCL-, FMX- und `designide`-APIs mit der konkret eingesetzten Delphi-Version.

## Einordnung des Prototyps

- Die VCL-Implementierung bleibt der vollständigere Referenzpfad.
- FMX verwendet denselben Core und dieselben Controller; einzelne Komfortfunktionen besitzen noch keine vollständige Parität.
- Sortier-, Filter-, Gruppierungs-, Tree-, Footer-, SubView-, VerticalGrid-, Export- und Druckmodule sind weiterhin Ausbaustufen und keine vollständig fertigen Produktmodule.

## Reproduzierbare Prüfungen

```text
python Build\source_audit.py
python Build\release_audit.py
Build\build-delphi.ps1 -DelphiBin "C:\Program Files (x86)\Embarcadero\Studio\<Version>\bin"
```
