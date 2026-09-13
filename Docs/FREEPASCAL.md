# FreePascal / Lazarus: Common-Kern

Alle Units in `Source/Common` unterstützen FreePascal 3.2.2 mit
`{$MODE OBJFPC}{$H+}`. Für Records mit Methoden wird zusätzlich
`{$MODESWITCH ADVANCEDRECORDS}` gesetzt; die Quelldateien sind UTF-8.
Delphi verwendet weiterhin seinen bisherigen Compilerzweig.

## Lazarus-Paket

In Lazarus `Packages/h5uGridCoreLazarus.lpk` öffnen und **Kompilieren** wählen.
Das Runtime-Paket enthält den Common-Kern und `h5u.Grid.SampleData` und benötigt
die mit Lazarus/FPC gelieferte FCL. Es registriert keine visuellen Komponenten.
Die Delphi-Paketdatei bleibt `Packages/h5uGridCoreLazarus.dpk`.

Alternativ mit installiertem Lazarus:

```sh
lazbuild Packages/h5uGridCoreLazarus.lpk
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
bereit. Ein künftiger LCL-Adapter muss native LCL-Typen an dieser Grenze zuordnen.
Für dessen Editorregistrierung existiert `Th5uEditorPlatform.LCL`.

Die visuellen Implementierungen in `Source/VCL`, `Source/FMX` und die
Delphi-Designpakete werden durch dieses Runtime-Paket nicht zu LCL-Controls.

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

Grundlagen: [ObjFPC-Records](https://docs.freepascal.org/docs-html/current/ref/refse61.html),
[Generics](https://www.freepascal.org/docs-html/ref/refse57.html),
[FPC-3.2.2-RTTI-Implementierung](https://github.com/fpc/FPCSource/blob/release_3_2_2/packages/rtl-objpas/src/inc/rtti.pp).
