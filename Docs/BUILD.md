# h5u.Grid – Build und Installation

## Voraussetzungen

- Embarcadero Delphi mit VCL und/oder FireMonkey
- DataSnap/DBClient für `TClientDataSet` (`dsnap`)
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

Die Komponente `Th5uSampleClientDataSet` erzeugt ihr Schema und ihre Musterdatensätze selbst. Die ClientDataSet-Demos benötigen daher weder eine Datenbank noch eine externe `.cds`-Datei.

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
