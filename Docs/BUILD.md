# h5u.Grid – Build und Installation

## Voraussetzungen

- Embarcadero Delphi mit VCL und/oder FireMonkey
- DataSnap/DBClient für `TClientDataset` (`dsnap`)
- für die Design-Time-Packages zusätzlich `designide`
- Python 3 nur für die mitgelieferten statischen Audits

Der Quellstand verwendet moderne Delphi-Sprachmittel wie Generics, RTTI, anonyme Methoden und Unit Scope Names. Da im Erstellungscontainer kein Embarcadero-Compiler vorhanden war, ist der erste DCC-Build mit der konkret eingesetzten Delphi-Version ausdrücklich Teil des Tests.

## Package-Reihenfolge

Runtime:

1. `Packages\h5uGridCoreR.dpk`
2. `Packages\h5uGridVclR.dpk`
3. `Packages\h5uGridFmxR.dpk`

Design-Time, ausschließlich in der IDE installieren:

1. `Packages\h5uGridCoreD.dpk`
2. `Packages\h5uGridVclD.dpk`
3. `Packages\h5uGridFmxD.dpk`

Für eine reine VCL-Installation sind die FMX-Packages nicht erforderlich; umgekehrt gilt dasselbe.

## Build über PowerShell

Das Skript importiert optional `rsvars.bat` in den aktuellen PowerShell-Prozess. Dadurch bleiben die von Embarcadero gesetzten Umgebungsvariablen auch für die nachfolgenden DCC-Aufrufe verfügbar.

```powershell
Set-Location <Pfad-zum-Paket>

.\Build\build-delphi.ps1 `
  -RsVars 'C:\Program Files (x86)\Embarcadero\Studio\<Version>\bin\rsvars.bat' `
  -Platform Win32 `
  -Configuration Debug `
  -Clean
```

Alternativ kann das Bin-Verzeichnis direkt angegeben werden:

```powershell
.\Build\build-delphi.ps1 `
  -DelphiBin 'C:\Program Files (x86)\Embarcadero\Studio\<Version>\bin' `
  -Platform Win32
```

Nützliche Schalter:

```text
-SkipRuntimePackages
-SkipDesignPackages
-SkipDemos
-Clean
-Platform Win32|Win64
-Configuration Debug|Release
-OutputRoot <Verzeichnis>
```

Design-Time-Packages werden bei `Win64` bewusst übersprungen. Sie werden für die Delphi-IDE als Win32-Packages gebaut.

## Manuell in der IDE

1. Runtime-Packages in der oben genannten Reihenfolge öffnen und bauen.
2. Gewünschte Design-Time-Packages bauen und über **Install** registrieren.
3. Die Demo-DPRs öffnen und bauen.
4. Für den Formulardesigner zuerst das passende VCL- beziehungsweise FMX-Design-Package installieren.

Die Komponente `Th5uSampleClientDataset` erzeugt ihr Schema und ihre Musterdatensätze selbst. Die ClientDataset-Demos benötigen daher weder eine Datenbank noch eine externe `.cds`-Datei.

## Lazarus / Free Pascal

Die Lazarus-Variante verwendet den vorhandenen Common-Kern und den LCL-Adapter
in `Source/LCL`. Benötigt werden Free Pascal 3.2.2 und Lazarus mit LCL,
FCL und `DateTimeCtrls`; für die Installation im Designer zusätzlich `IDEIntf`.

Pakete in dieser Reihenfolge kompilieren:

```sh
lazbuild Packages/h5uGridCoreLazarus.lpk
lazbuild Packages/h5uGridCoreLazarusDesign.lpk
lazbuild Packages/h5uGridLcl.lpk
lazbuild Packages/h5uGridLclDesign.lpk
```

Zum Installieren in Lazarus `Packages/h5uGridLclDesign.lpk` öffnen und
**Verwenden → Installieren** wählen. Das Core-Design-Paket wird als
Abhängigkeit mit installiert. Laufzeitprojekte benötigen ausschließlich
`h5uGridLcl` mit seinen Runtime-Abhängigkeiten. Die `.lpi`-Projekte unter
`Demos/LCL` enthalten diese Abhängigkeit bereits.

Die Paket-Ausgaben sind unter `_dcu/<OS>_<CPU>_Lazarus` nach Paket und bei
LCL-Paketen zusätzlich nach Widgetset getrennt. Weitere Hinweise zu ObjFPC,
UTF-8 und den Common-Tests stehen in [FREEPASCAL.md](FREEPASCAL.md).

Der PowerShell-Launcher baut die Pakete und alle drei Demos mit einer eigenen
Lazarus-Konfiguration unter `Build/LCL/config`:

```powershell
.\Build\build-lazarus.ps1 -LazBuild 'C:\lazarus\lazbuild.exe'
```

Bei Bedarf `-Compiler` für den Pfad zu `fpc.exe`, `-PrimaryConfigPath` für
die Build-Konfiguration oder `-WidgetSet` für das Ziel-Widgetset angeben.
`-SkipDesignPackages` beziehungsweise `-SkipDemos` begrenzt den Build;
`-IncludeTests` baut außerdem die LCL-Testprogramme.

Unter Windows baut `test-lcl.ps1` zusätzlich die Tests und führt zuerst den
Test der Formularressourcen ohne sichtbare Fenster aus. Vor dem visuellen
Bedienungstest zeigt der Launcher den Desktop-Countdown:

```powershell
.\Build\test-lcl.ps1 -LazBuild 'C:\lazarus\lazbuild.exe'
# Nur Formularressourcen und Daten prüfen:
.\Build\test-lcl.ps1 -LazBuild 'C:\lazarus\lazbuild.exe' -SkipVisual
```

Die Programme liegen unter `Build/LCL/bin/<CPU>-<OS>/<Widgetset>`.
Für bereits gebaute Tests `-SkipBuild` verwenden. `-NoticeSeconds 5` verkürzt
den Countdown; `-Screenshot <Pfad.png>` speichert die visuelle Testansicht.

## Quellformatierung

Für Delphi-Quellen gelten maximal 150 Zeichen pro Zeile. Property-Deklarationen, prozedurale Eventtypen sowie Methoden- und Funktionssignaturen bleiben bis 180 Zeichen einzeilig. Operatoren stehen bei umgebrochenen Ausdrücken am Anfang der Folgezeile.

Formatierung anwenden:

```powershell
python Build\format_pascal.py
```

Nur prüfen:

```powershell
python Build\format_pascal.py --check
```

Der Formatter verändert nur Whitespace und prüft, dass Pascal-Tokens, Zeichenketten und Kommentare erhalten bleiben. Die vollständige Regel steht in [CODING-STYLE.md](CODING-STYLE.md).

## Statischer Audit

Unter Windows:

```cmd
Build\run-static-audit.cmd
```

Direkt mit Python:

```powershell
python Build\format_pascal.py --check
python Build\source_audit.py
python Build\release_audit.py
```

Die Berichte werden im Verzeichnis `Build` erzeugt. Diese Prüfungen ersetzen keinen Delphi-Build.

## Unit Scope Names

Gemeinsame Units werden vollständig referenziert:

```pascal
uses
  h5u.Grid.Types,
  h5u.Grid.Columns,
  h5u.Grid.Data.Core;
```

Für die Plattformfassade kann bei passenden Unit Scope Names der verkürzte Name verwendet werden:

```pascal
uses
  h5u.Grid;
```

In einem VCL-Projekt wird daraus `Vcl.h5u.Grid`, in einem FMX-Projekt `Fmx.h5u.Grid`. Ohne passend gesetzten Scope wird die Unit explizit angegeben:

```pascal
uses
  Vcl.h5u.Grid;
```

oder:

```pascal
uses
  Fmx.h5u.Grid;
```

## Erwartete erste Prüfpunkte

Beim Build mit einer konkreten Delphi-Version sind insbesondere zu prüfen:

- verfügbare VCL-/FMX-Canvas- und Style-APIs,
- RTTI-Unterschiede zwischen Releases,
- DesignIDE-Package-Namen,
- FMX-Metrik- und Eingabe-APIs,
- Package-Suffixe und IDE-spezifische Ausgabepfade.

Versionsspezifische Compilerdiagnosen sollten mit Dateiname, Zeilennummer und Delphi-Version dokumentiert werden.

## Hinweis vor visuellen Tests

`test-editing.ps1`, `test-virtual-loading.ps1` und der visuelle Teil von
`test-dataset-loading.ps1` zeigen unmittelbar vor jedem Testprogramm einen
**10-Sekunden-Countdown**. Mit `-NoticeSeconds 5` lässt sich der Vorlauf auf
5 Sekunden verkürzen.

Der Hinweis steht zentriert im Arbeitsbereich des Monitors mit dem Mauszeiger,
bleibt im Vordergrund und übernimmt keinen Tastaturfokus. Die Vorlaufzeit zählt
ab dem sichtbaren Anzeigen. Schließt der Hinweis vorzeitig oder schlägt er fehl,
wird das Testprogramm nicht gestartet. Visuelle Testprogramme nacheinander ausführen.

Für einen manuellen Start:

```powershell
. .\Build\visual-test-notice.ps1
Show-GridVisualTestNotice -TestName 'GridVclClientDatasetDemo'
# Anschließend das gewünschte Testprogramm starten.
```

Reine Compiler-, Common-, Ressourcen- und andere Tests ohne Fenster benötigen
keinen Hinweis. Der Hinweis verwendet Windows Forms in einem separaten
Windows-PowerShell-Prozess mit STA; seine Konsole bleibt verborgen.
