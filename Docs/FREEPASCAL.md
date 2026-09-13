# FreePascal / Lazarus: Common-Kern und LCL

Alle Units in `Source/Common` unterstützen FreePascal 3.2.2 mit
`{$MODE OBJFPC}{$H+}`. Für Records mit Methoden wird zusätzlich
`{$MODESWITCH ADVANCEDRECORDS}` gesetzt; die Quelldateien sind UTF-8.
Delphi verwendet weiterhin seinen bisherigen Compilerzweig.

## Lazarus-Packages

In Lazarus `Packages/h5uGridCoreLazarus.lpk` öffnen und **Kompilieren** wählen.
Das Runtime-Paket enthält den Common-Kern und `h5u.Grid.SampleData` und benötigt
die mit Lazarus/FPC gelieferte FCL. Es registriert keine visuellen Komponenten.
Die Delphi-Paketdatei bleibt `Packages/h5uGridCore.dpk`.

Für die visuelle Komponente `Packages/h5uGridLcl.lpk` öffnen und kompilieren.
Das Paket enthält `Lcl.h5u.Grid`, `Lcl.h5u.Grid.Editors`,
`Lcl.h5u.Grid.Styles` und `Lcl.h5u.Grid.Compat` aus `Source/LCL`.
Es benötigt das Common-Runtime-Paket,
die LCL und das mit Lazarus gelieferte Runtime-Paket `DateTimeCtrls`.

Für den Formulardesigner die Pakete in dieser Reihenfolge öffnen und bauen:

1. `Packages/h5uGridCoreLazarus.lpk`
2. `Packages/h5uGridLcl.lpk`
3. `Packages/h5uGridCoreLazarusDesign.lpk`
4. `Packages/h5uGridLclDesign.lpk`

Anschließend `h5uGridLclDesign` über **Verwenden → Installieren** installieren
und Lazarus neu bauen lassen. Die Design-Pakete verwenden `IDEIntf` und
registrieren die Common-Komponenten auf der Seite `h5u` sowie `Th5uLclGrid`
auf `h5u Grid`. `h5u.Grid.SampleData` gehört zum Runtime-Paket, sodass
Anwendungen und Demos keine Design-Pakete benötigen.

Compiler-Ausgaben liegen getrennt nach Paket unter
`_dcu/<OS>_<CPU>_Lazarus`; LCL- und Design-Pakete verwenden zusätzlich
ein Unterverzeichnis für das Widgetset. Dadurch werden die gemeinsamen Units
nicht in mehreren Paket-Ausgabeverzeichnissen neu kompiliert.

Alternativ mit installiertem Lazarus:

```sh
lazbuild Packages/h5uGridCoreLazarus.lpk
lazbuild Packages/h5uGridLcl.lpk
lazbuild Packages/h5uGridCoreLazarusDesign.lpk
lazbuild Packages/h5uGridLclDesign.lpk
```

Ohne Lazarus kann der Paketeinstieg aus dem Repository-Verzeichnis mit einer
vollständig konfigurierten FPC-Installation kompiliert werden:

```sh
mkdir -p Build/FPC/units
fpc -Mobjfpc -Sh -FuSource/Common -FUBuild/FPC/units Packages/h5uGridCoreLazarus.pas
```

Unter PowerShell den Ausgabeordner mit
`New-Item -ItemType Directory -Force Build/FPC/units` erstellen.

## Verwendung unter ObjFPC

```pascal
{$MODE OBJFPC}{$H+}
{$CODEPAGE UTF8}

uses
  Rtti, h5u.Grid.Compat, h5u.Grid.Data.Memory;

var
  Controller: Th5uMemoryController;
begin
  Controller := Th5uMemoryController.Create(nil);
  try
    Controller.AppendValues(['Name', 'Anzahl'], [
      TValue.specialize From<string>('Grüße 東京'),
      TValue.specialize From<Integer>(3)]);
    WriteLn(Controller.GetDisplayText(0, 'Name'));
  finally
    Controller.Free;
  end;
end.
```

- Generics werden mit `specialize` verwendet, generische Record-Methoden etwa
  mit `TValue.specialize From<Integer>(3)` oder
  `Value.specialize AsType<TBytes>`.
- Ereignisse erhalten in ObjFPC eine Methodenadresse, zum Beispiel
  `Controller.OnGetValue := @Events.GetValue`.
- `Th5uObjectListController` greift unter FPC auf **published**-Properties zu.
  Dafür eignen sich z. B. von `TPersistent` abgeleitete Klassen. FPC 3.2.2
  stellt Delphis erweiterte RTTI für beliebige `public`-Properties nicht bereit.
  Verschachtelte Objektpfade, UnicodeString-/WideString- und skalare
  Variant-Properties werden unterstützt.
- `Th5uClassRulePredicate` ist unter FPC eine normale Funktion ohne Closure.
  Registrieren mit `@MeineRegel`; zusätzliche Zustände stehen über den
  Factory-Kontext zur Verfügung. Für Methoden mit Objektzustand gibt es
  außerdem `OnGetClass`. `Th5uEditorPreparePaint` ist unter FPC ein
  `procedure ... of object`.
- Strings im Common-Kern folgen der UTF-8-Konvention von Lazarus.
  `h5uValueAsText` behandelt UTF-8 sowie Unicode-TValue-Inhalte; Datenbanktexte
  verwenden unter FPC `TField.AsUTF8String`. Globale RTL-Codepage-Einstellungen
  werden nicht verändert.
- Die LCL-Tastatursuche übernimmt vollständige UTF-8-Zeichen. Der Common-Kern
  vergleicht unter FPC Unicode-Präfixe ohne Beachtung der Groß-/Kleinschreibung;
  mehrbyteige Zeichen werden nicht in einzelne Suchschritte aufgeteilt.
- FPC 3.2.2 unterstützt `TValue.From<Variant>` nicht zur Laufzeit.
  `h5uValueFromVariant` konvertiert skalare Variants in unterstützte TValue-Typen;
  `Null` und `Unassigned` werden zu `TValue.Empty`. Variant-Arrays werden mit
  einer Ausnahme abgewiesen. Für BLOBs `TBytes` verwenden.
- `Th5uSampleClientDataset` basiert unter FPC auf `TBufDataset`, unter Delphi
  auf `TClientDataset`. Die Klasse behält ihren Namen und die SampleData-API;
  zusätzliche DataSnap-spezifische APIs gehören nicht zur FPC-Variante.

## Umfang

Portiert sind Common-Klassen für Daten, Spalten, Layout, Navigation, Auswahl,
Gruppierung, Factory und Editor-Abstraktionen. Der Kern benötigt kein Widgetset.
`h5u.Grid.Compat` stellt dafür kleine Farb-, Schriftstil-, Maus- und Tastaturtypen
bereit. Der Adapter in `Source/LCL` ordnet native LCL-Typen an dieser Grenze zu
und registriert seine Editoren für `Th5uEditorPlatform.LCL`.

Die LCL-Fassade heißt `Th5uLclGrid` aus `Lcl.h5u.Grid`. Die entsprechenden
Editor- und Style-Klassen tragen ebenfalls das Präfix `Th5uLcl`.
VCL und FMX behalten ihre eigenen Units und Delphi-Packages. In `Source/Design`
ist die Common-Registrierung compilerabhängig; die visuelle Registrierung
liegt je Framework in `Vcl.h5u.Grid.Design`, `Fmx.h5u.Grid.Design` oder
`Lcl.h5u.Grid.Design`. Delphi-Splashscreen-APIs werden nur unter Delphi verwendet.

Die drei Lazarus-Demos liegen unter `Demos/LCL/ClientDataset`,
`Demos/LCL/ObjectList` und `Demos/LCL/VirtualLive`. Die jeweilige `.lpi`-Datei
in Lazarus öffnen oder mit `lazbuild` kompilieren. Details und Unterschiede
zum Delphi-Objektmodell stehen in [DEMOS.md](DEMOS.md).

## Tests

```powershell
.\Build\test-fpc.ps1 -Fpc 'C:\lazarus\fpc\3.2.2\bin\x86_64-win64\fpc.exe'
```

Der Launcher baut `TestCommonBehavior.dpr` und `TestFpcCompatibility.pas` mit
Range-/Overflow-Prüfung und Heaptracing. Er prüft Rückgabecodes und
Speicherlecks; Protokolle liegen unter `Build/FPC/<CPU>-<OS>`.
`-CompilerOptions` nimmt bei Bedarf zusätzliche Compilerpfade/-optionen auf.

Die Tests laufen ohne Fenster. Sie prüfen unter anderem Spaltenbreiten,
Navigation, unabhängige Views, Gruppierung, große Zeilenzahlen, Zeilenhöhen,
Wertkonvertierung, UTF-8, RTTI-Schreibzugriffe, Cache-Invalidierung,
Dataset-Positionierung, BLOBs, SampleData und virtuelle Ereignisse.

Die LCL-Packages, Demos und Testprogramme lassen sich gemeinsam bauen:

```powershell
.\Build\build-lazarus.ps1 -LazBuild 'C:\lazarus\lazbuild.exe' -IncludeTests
.\Build\test-lcl.ps1 -LazBuild 'C:\lazarus\lazbuild.exe' -SkipBuild -SkipVisual
```

`-Compiler` wählt bei Bedarf eine bestimmte FPC-Installation.
Der Ressourcentest lädt die drei `.lfm`-Formulare ohne sichtbare Fenster und
prüft Daten, Einstellungen, Bearbeitung und Freigabe. Ohne `-SkipVisual`
startet zusätzlich der Bedienungstest nach einem Desktop-Countdown;
`-NoticeSeconds 5` verkürzt den Vorlauf, `-Screenshot <Pfad.png>` speichert
die Testansicht. Details stehen in [BUILD.md](BUILD.md).

Geprüft mit Lazarus 4.8 und Free Pascal 3.2.2 unter Windows x64
(`win32`-Widgetset): alle vier Packages, die drei Demos und der Test der
Formularressourcen. Die beiden Common-Testprogramme bestehen mit
Range-/Overflow-Prüfung und ohne gemeldete Heap-Lecks. Die gemeinsamen
Verhaltensregressionen bestehen außerdem mit Delphi DCC32 37.0.

Grundlagen: [ObjFPC-Records](https://docs.freepascal.org/docs-html/current/ref/refse61.html),
[Generics](https://www.freepascal.org/docs-html/ref/refse57.html),
[FPC-3.2.2-RTTI-Implementierung](https://github.com/fpc/FPCSource/blob/release_3_2_2/packages/rtl-objpas/src/inc/rtti.pp).

Der native LCL-Bedienungstest wurde ebenfalls erfolgreich ausgeführt: F2,
Übernehmen/Abbrechen, Unicode-Suche, Integer-Eingabe, Datum/Uhrzeit einschließlich
NULL-Checkbox und Kalender-Popup, Navigation, Spaltenänderungen und Zeichnen aller
Paletten. Andere Betriebssysteme und Widgetsets wurden nicht ausgeführt.
