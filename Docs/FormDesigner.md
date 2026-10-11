# Property-Editor und Strukturansicht

Die gemeinsamen Modelle arbeiten ohne VCL oder FMX. Die visuellen Adapter
verwenden das vorhandene hiiGrid und dessen ObjectList-Controller.

| Aufgabe | Gemeinsame Klasse | VCL / FMX |
| --- | --- | --- |
| Eigenschaften eines Objekts | `ThiiPropertyModel` | `ThiiPropertyEditor` je Framework |
| Cache und Grid-Anbindung | `ThiiPropertyListController` | gemeinsamer ObjectList-Controller |
| Komponentenstruktur | `ThiiStructureModel` | `ThiiStructureView` je Framework |
| Einzelner registrierter Werteditor | `ThiiValueEditor` | gemeinsame Registrierung |

Die Modelle stehen in `h5u.PropertyEditor` und `h5u.FormDesigner`.
Der PropertyEditor ist eine eigenständige Runtime-Komponente aus
`Vcl.h5u.PropertyEditor` beziehungsweise `Fmx.h5u.PropertyEditor`.
Diese Units bieten die öffentlichen Typen des gemeinsamen Property-Modells
als Aliase an. Eine Framework-Unit genügt daher für die normale Verwendung.
Die Strukturansicht bleibt in `Vcl.h5u.FormDesigner` beziehungsweise
`Fmx.h5u.FormDesigner`; sie hängt nicht vom PropertyEditor ab.
Die Registrierung beider Komponenten bleibt im bestehenden DesignTime-Package. `ThiiEventEditor`, `ThiiComponentPalette` und
`ThiiFormDesigner` bleiben Erweiterungspunkte ohne Designer-Oberfläche.

## Eigenschaften auswählen

```pascal
uses Vcl.h5u.PropertyEditor;

Inspector := ThiiPropertyEditor.Create(Self);
Inspector.Parent := Self;
Inspector.Align := alClient;
Inspector.PropertyEditor.LimitClass := TControl;
Inspector.PropertyEditor.PublishedProperties := True;
Inspector.PropertyEditor.PublicProperties := True;
Inspector.DataObject := Button1;
```

Für FMX entsprechend `ThiiPropertyEditor` und `TAlignLayout.Client`
verwenden. `ObjectListController` ist ein `ThiiPropertyListController` und besitzt
das Modell `PropertyEditor`; `Grid` ist das Grid selbst.
`PropertyEditor` ist als `published`-Subkomponente verfügbar; dessen
RTTI-Auswahl, Masken, Sortierung und Ereignisse lassen sich im IDE-Inspector
konfigurieren und im Formular speichern.

- `PublishedProperties` ist anfangs aktiv und umfasst Ereignis-Properties.
  `PublicProperties`, `PublicFields` und `PrivateFields` sind einzeln
  zuschaltbar und anfangs deaktiviert.
- `LimitClass` ist einschließlich gemeint: Bei `TControl` werden dessen
  deklarierte Mitglieder und die der abgeleiteten Klassen aufgenommen.
  `nil` erlaubt die gesamte Vererbungskette; eine nicht passende Klasse
  ergibt eine leere Liste.
- `ThiiPropertySortOrder.psoName` sortiert alphabetisch. `ThiiPropertySortOrder.psoDeclaration` gruppiert von der
  Basisklasse zu den Nachfahren und erhält die RTTI-Deklarationsreihenfolge.
  Delphi liefert Felder und Properties getrennt; innerhalb jeder Klasse
  stehen deshalb zunächst die Felder, danach die Properties.
- Gleichnamige Properties werden durch die Deklaration der am weitesten
  abgeleiteten Klasse ersetzt. Gleichnamige private Felder bleiben als
  getrennte Speicherstellen erhalten; `FindProperty(Name, DeklarierendeKlasse)`
  wählt sie gezielt, `FindProperty(Name)` bevorzugt die abgeleitete Klasse.
  Innerhalb einer Klasse folgen manuelle
  Definitionen den echten Mitgliedern und können sie gezielt ersetzen.

Die Ermittlung verwendet ausschließlich `TRttiContext.GetType(ClassType)`
und dessen `GetProperties`/`GetFields` beziehungsweise
`GetPropertiesInDeclOrder`/`GetFieldsInDeclOrder`. Es kann nur die vom
Compiler erzeugte RTTI gelesen werden. Für eigene
Klassen mit privaten Feldern beispielsweise vor der Klassendeklaration:

```pascal
{$RTTI EXPLICIT METHODS([])
  PROPERTIES([vcPublic, vcPublished]) FIELDS([vcPublic, vcPrivate])}
```

## Masken und Schreibschutz

`ClassMask`, `NameMask` und `TypeMask` werden gemeinsam angewendet.
Die Auswertung verwendet unter Delphi `System.Masks.MatchesMask` bzw.
`TMask`: `*` und `?` sowie Zeichenmengen wie `[abc]`, Bereiche wie `[a-z]`
und deren Negation `[!0-9]` folgen den RTL-Dateimaskenregeln. Der Punkt
ist ein gewöhnlicher Namespace-Trenner, beispielsweise in
`Vcl.*.T[C-F]*`. Der Vergleich ignoriert Groß-/Kleinschreibung. Eine leere
Maske schränkt nicht ein. `ClassMask` prüft die Klasse des untersuchten
Objekts und deren Vorfahren mit kurzem oder qualifiziertem Namen. So passt
eine Regel für `TButton` auch auf dessen geerbte `Caption`-Property.
Typmasken akzeptieren kurze und qualifizierte Namen; `TypeName` enthält
unter Delphi den qualifizierten RTTI-Namen, soweit der Typ ihn bereitstellt.
Ungültige Masken, etwa ein nicht geschlossenes `[a-z`, geben die
RTL-Ausnahme `EMaskException` an den Aufrufer weiter. Beim Setzen einer
Maske wird zuerst validiert; die bisherige Einstellung bleibt im Fehlerfall
erhalten. Dasselbe gilt für `StructureView.FilterText`.

```pascal
Inspector.PropertyEditor.NameMask := '*Color';
Inspector.PropertyEditor.TypeMask := '*TColor';

Rule := Inspector.PropertyEditor.Filters.Add;
Rule.ClassMask := '*TComponent';
Rule.NameMask := 'Name';
Rule.ReadOnly := True;
```

`Filters` enthält zusätzliche Regeln mit denselben drei Masken sowie
`ReadOnly` und `Hidden`. Passende Regeln wirken additiv. Verborgene
Mitglieder bleiben mit `Hidden=True` in `Items`/`PropertyList`; der Adapter
übernimmt nur sichtbare Zeilen. Schreibschutz und Hidden werden auch beim
tatsächlichen Schreiben geprüft, einschließlich des RTTI-Zugriffs über
`DisplayValue` im ObjectList-Controller.

## Werte, Cache und manuelle Properties

Jeder `ThiiPropertyItem` enthält seine eigene `Instance: Pointer`, die
zugehörige `RttiProperty` oder `RttiField` und einen `TValue`-Cache.
Dadurch können verschiedene Instanzen mit gleichnamigen Mitgliedern in
derselben Liste stehen. RTTI-Zugriffe, Filter und Editor-Registrierung
verwenden jeweils die Instanz der Zeile.

`GetValue`/`SetValue` arbeiten mit `TValue`, `GetText`/`SetText` mit der
Editor-Darstellung. Der Controller liefert für das Feld `Value` den
gecachten `TValue` direkt, für `DisplayValue` den formatierten Text.
Nach dem Schreiben werden die Werte erneut gelesen, damit normalisierende
Setter und Änderungen an abhängigen Properties im Cache erscheinen.

`Refresh` liest die Werte über RTTI beziehungsweise die GetValue-Hooks
neu und vergleicht sie mit dem Cache. Nur geänderte Werte oder Lesefehler
erzeugen eine Meldung für die betreffende Zeile. Der Controller klammert
den gesamten Durchlauf in `BeginUpdate`/`EndUpdate`, sodass das Grid die
einzelnen Zeilenmeldungen gesammelt verarbeitet. Ein unveränderter
Durchlauf erzeugt keine Grid-Änderungsmeldung.

`Invalidate` markiert gelesene Werte für einen erneuten Zugriff, ohne
Änderungsereignis. Freie Werte ohne RTTI bleiben im Cache gespeichert.
`Reload` baut die Metadatenliste neu auf; zuvor erhaltene Item-Referenzen
sind danach ungültig. Nach Änderungen außerhalb des Editors `Refresh`
aufrufen. Fehler werden über `ReadError` und `DisplayValue` angezeigt;
direkte Wertzugriffe geben Lesefehler als Ausnahme weiter.

Die Liste lässt sich in `OnLoaded` oder später ergänzen:

```pascal
Context := TRttiContext.Create;
try
  Model.AddProperty(Button2,
    Context.GetType(Button2.ClassType).GetProperty('Caption'));
  Model.AddField(MyObject,
    Context.GetType(MyObject.ClassType).GetField('PublicField'));
  Model.AddManualProperty(Button2, 'Kommentar', TValue.From<string>(''));
finally
  Context.Free;
end;
```

Auch manuell ergänzte Einträge mit RTTI lesen und schreiben ihren Wert
über den gespeicherten Deskriptor. Einträge ohne RTTI verwenden den Cache
und die Ereignisse `ObjectListController.OnGetValue`/`OnSetValue`.
Bei eigener Behandlung `Handled := True` setzen. Ohne Ereignisbehandlung
bleibt ein freier Eintrag ein einfacher Wertspeicher. Die bestehenden
Modell-Hooks werden zuerst aufgerufen und können die Behandlung übernehmen.

`FindProperty(Instance, Name)` unterscheidet gleichnamige Mitglieder
verschiedener Objekte. Die Listeneinträge besitzen stabile IDs; nach
eigenem Umsortieren von `Items` mit `NotifyItemsChanged` die Anbindung
aktualisieren. Der eigene `Instance`-Zeiger bleibt beim Umsortieren erhalten.
Direkt ergänzte Zeilen müssen nach einem `Reload` erneut eingefügt werden,
beispielsweise in `OnLoaded`.

Für wiederkehrende manuelle Definitionen steht weiterhin die nach
Klasse und Propertyname aufgebaute Sammlung zur Verfügung:

```pascal
Model := Inspector.PropertyEditor;
Model.ManualProperties.BeginUpdate;
try
  Manual := Model.ManualProperties.Add;
  Manual.TargetClass := TControl;
  Manual.PropertyName := 'Kommentar';
  Manual.ValueTypeInfo := TypeInfo(string);
  Manual.DefaultValue := TValue.From<string>('');
finally
  Model.ManualProperties.EndUpdate;
end;
Model.SetValue(Model.FindProperty('Kommentar'), TValue.From<string>('Prüfen'));
```

Manuelle Werte sind nach Objekt und Definition getrennt. Sie bleiben beim
Objektwechsel, bei `Reload` und `Refresh` erhalten; der Default gilt für noch
nicht gespeicherte Werte. `TargetClass=nil` gilt für beliebige Objektklassen.
Änderungen an Name, Zielklasse oder Typ einer manuellen Definition verwerfen
deren bisherige Cache-Einträge.
Die Modelle besitzen weder das untersuchte Objekt noch Komponenten der
Struktur. Komponenten werden über `FreeNotification` beobachtet. Vor dem
Freigeben gewöhnlicher `TObject`-/`TPersistent`-Instanzen
`Model.ForgetObject(Instanz)` aufrufen.

`OnLoaded` läuft nach dem Aufbau der Property-Liste. `OnGetValue` und
`OnSetValue` können manuelle und echte Mitglieder behandeln. Bei eigener
Behandlung `Handled := True` setzen, sonst folgt der normale RTTI-/Cache-Zugriff.
Die virtuellen Methoden `DoLoaded`, `DoGetValue` und `DoSetValue` bieten
dieselben Erweiterungspunkte für abgeleitete Modelle.

## Eigene Gruppen und angezeigte Namen

`ThiiPropertyItem.Caption` bestimmt den angezeigten Namen und beginnt mit
`Name`. `GroupName` ist frei wählbar und zunächst leer. Die technische
Identität (`Name`, `Instance`, `RttiProperty`/`RttiField`) bleibt unabhängig
von beiden Angaben. So können Properties des Grids in einer Gruppe
`Options` und ausgewählte Properties seiner Unterobjekte daneben in
`Customization`, `DefaultEditors` oder `RowHeight` stehen.

Die Liste lässt sich in `OnLoaded` vollständig selbst aufbauen:

```pascal
procedure TMyForm.PropertiesLoaded(Sender: TObject);
var
  Model: ThiiPropertyModel;
  Context: TRttiContext;

  procedure AddGroup(AObject: TObject; const AGroup: string;
    const ANames: array of string);
  var
    RttiType: TRttiType;
    PropertyName: string;
    Item: ThiiPropertyItem;
  begin
    RttiType := Context.GetType(AObject.ClassType);
    for PropertyName in ANames do
    begin
      Item := Model.AddProperty(Pointer(AObject), RttiType.GetProperty(PropertyName));
      Item.GroupName := AGroup;
    end;
  end;

begin
  Model := ThiiPropertyModel(Sender);
  Model.Items.Clear;
  Context := TRttiContext.Create;
  try
    AddGroup(Grid.Editing, 'Editing', ['AllowEditing', 'ImmediateEdit']);
    AddGroup(Grid.Header, 'Header', ['Visible', 'RowHeight']);
    AddGroup(Grid.ColumnSizing, 'ColumnSizing', ['FitMode', 'DefaultWidth', 'DefaultMaxWidth', 'AutoWidthRowLimit']);
    AddGroup(Grid.Appearance, 'Appearance', ['Theme', 'DefaultCellColor', 'RowSpacingColor']);
    AddGroup(Grid.Customization, 'Customization', ['AllowColumnMoving', 'AllowColumnHiding']);
    AddGroup(Grid.DefaultEditors, 'DefaultEditors', ['Edit', 'Integer', 'Float']);
    AddGroup(Grid.RowHeight, 'RowHeight', ['Mode', 'EstimatedHeight', 'MinHeight']);
    Model.FindProperty(Pointer(Grid.Editing), 'AllowEditing').Caption := 'Bearbeiten erlauben';
  finally
    Context.Free;
  end;
end;
```

Für eine automatische Gruppe stattdessen über
`Context.GetType(AObject.ClassType).GetProperties` oder
`GetPropertiesInDeclOrder` laufen und die gewünschten lesbaren Mitglieder
mit `AddProperty` übernehmen. Dasselbe ist mit Feldern und `AddField`
möglich. Freie Cache-Properties können genau dieselben Gruppen verwenden.

Die VCL-/FMX-Adapter fügen vor jedem zusammenhängenden Abschnitt mit
nicht leerem `GroupName` eine Überschrift ein. Diese sind
`Th5uPropertyGroupRow`-Objekte im `ObjectListController`; im Modell
`Items` stehen weiterhin ausschließlich die eigentlichen Properties.
Alle Gruppen liegen auf derselben Ebene. Gleichnamige, später erneut
auftretende Abschnitte bleiben getrennt und die eigene Reihenfolge erhalten.
Zeilen mit leerem `GroupName` bleiben ungruppiert. Verborgene Properties
erzeugen keine leeren Gruppen.

Das vorhandene `AdjacentGroupFolding` des Grids übernimmt das Auf- und
Zuklappen. Überschriften besitzen eigene negative IDs, sind nicht editierbar
und behalten ihren Faltzustand beim Neuaufbau, solange Gruppenname und
Vorkommensnummer gleich bleiben. `ShowGroups=False` blendet die Überschriften
aus; `ShowGroups=True` ist der Standard. `ResetAdjacentGroupStates` setzt
gespeicherte Faltzustände zurück.

Nach späteren Änderungen an `Caption`, `GroupName` oder Reihenfolge einmal
`Model.NotifyItemsChanged` aufrufen. In `OnLoaded` erfolgt die Anbindung
automatisch nach dem Ereignis. Werteänderungen laufen unverändert über
den `TValue`-Cache und `Refresh`.

## Werteditoren registrieren

Die VCL-/FMX-PropertyEditor-Komponenten starten mit einer Breite von 350.
Die Spalten verwenden `Width=-60` für Bezeichnungen und `Width=-40` für Werte
sowie `ColumnSizing.FitMode=AllColumns`. Damit bleibt die Aufteilung bei einer
Größenänderung auf 60/40 der verfügbaren Spaltenfläche.

Für `ThiiWidth` ist bereits ein Werteditor registriert. Er zeigt negative
Vorgaben als positive Prozentangaben und 0 als `Default`; dieselben Texte
können eingegeben werden. Die bisherigen flachen Grid-Aliase sind mit
`ThiiLegacyOptionAttribute` markiert und werden beim automatischen Aufbau
ausgelassen. Manuell über `AddProperty` bleiben sie verfügbar.

Von `ThiiValueEditor` ableiten und `GetValue`, `SetValue` sowie
`GetComboList(AList: TStrings)` nach Bedarf überschreiben. Über die
geschützte Property `Item` stehen Name, Typ, Modell und Wert bereit.
Die Standardimplementierung behandelt skalare Werte, Enums und Sets;
Enums einschließlich Boolean liefern bereits eine Auswahlliste.
Für die Auswahl vorhandener Komponenten oder Ereignismethoden einen
passenden Editor registrieren. Ereignisse können gelesen und mit leerem
Text zurückgesetzt werden; beliebige Methodennamen werden nicht automatisch
in ausführbare Methoden aufgelöst.

```pascal
Registration := h5uRegisterPropertyEditor(
  TypeInfo(string), TMyComponent, 'ModeName', TMyModeEditor);
// Vor dem Entladen des Moduls mit TMyModeEditor:
h5uUnregisterPropertyEditor(Registration);
```

`nil` beim Typ oder bei der Klasse sowie ein leerer Propertyname sind
allgemeine Registrierungen. Vorrang haben ein konkreter Propertyname,
danach die nächstgelegene Objektklasse, dann der konkrete Typ. Bei gleichem
Rang gewinnt die zuletzt registrierte Klasse. Die Registrierung wird bei
jedem Zugriff neu aufgelöst. Die UI fragt `GetComboList` beim Öffnen des
Werteditors ab.

## Strukturansicht

```pascal
Structure := ThiiStructureView.Create(Self);
Structure.Parent := Self;
Structure.Align := alLeft;
Structure.Width := 280;
Structure.RootComponent := Panel1;
Structure.OnLoaded := StructureLoaded;
Structure.Reload;
```

Der Adapter enthält `FilterEdit` und `Grid`; `StructureView` liefert das
besessene Modell. `ResolveByParent` berücksichtigt visuelle Kinder,
`ResolveByOwner` zusätzlich besessene Komponenten. Beide sind anfangs aktiv.
Der gemeinsame Kern kennt die Owner-Struktur; die visuelle Parent-Auflösung
ergänzen die VCL-/FMX-Modelle durch `CollectChildren`.

`AllItems` enthält alle Modellzeilen, `ComponentList` die gefilterten Zeilen
in Baumreihenfolge. Die Listen sind vom Aufrufer als schreibgeschützt zu
behandeln. Jede Zeile enthält `Component`, `Parent`, `ID`, `ParentID`,
`Level`, `Name`, `ComponentClassName` und `ImageIndex`.
`FindComponent` und `FindItemByID` erlauben den direkten Zugriff.

In `OnLoaded` lassen sich zusätzliche Beziehungen ergänzen, etwa eine
DataSource unter einem Controller und deren DataSet darunter:

```pascal
procedure TMyForm.StructureLoaded(Sender: TObject);
var
  Model: ThiiStructureModel;
  ParentItem, SourceItem: ThiiStructureItem;
begin
  Model := ThiiStructureModel(Sender);
  ParentItem := Model.FindComponent(MyController);
  if (ParentItem <> nil) and (MyController.DataSource <> nil) then
  begin
    SourceItem := Model.AddComponent(MyController.DataSource, ParentItem);
    Model.AddComponent(MyController.DataSource.DataSet, SourceItem);
  end;
end;
```

`AddComponent` unterdrückt Duplikate anhand der Komponentenidentität und
verhindert damit auch Zyklen. Die erste gefundene Parent-Beziehung bleibt
erhalten. `AIncludeChildren=True` nimmt beim erstmaligen Einfügen außerdem
die auflösbaren Kinder auf. Für eine erneute vollständige Auflösung
`Reload` verwenden. Bereits existierende Einträge werden nicht umgehängt.

Der Filter sucht in Komponentenname und Klassenname. Text ohne `*`, `?`
oder `[` wird als Teiltext gesucht; Dateimasken wirken wie bei den Property-Masken.
Vorfahren gefundener Komponenten bleiben sichtbar. `SelectedComponent`
und `OnSelect` verbinden die Struktur mit der Objektauswahl des Inspectors.
Bei einer noch unvollständigen Maske während der Eingabe im `FilterEdit`
bleibt die letzte gültige Liste stehen. Der Adapter stellt die Fehlermeldung
über `FilterError` und den Hint des Eingabefelds bereit. Programmgesteuertes
Setzen von `FilterText` meldet ungültige Masken weiterhin als Ausnahme.

Die Darstellung verwendet die vorhandenen Tree-Bänder des Grids und
eingerückte Namen. Eigenständiges Auf-/Zuklappen der Strukturknoten ist
derzeit nicht implementiert.

## Prüfung und Plattformumfang

```powershell
.\Build\test-form-designer.ps1 -Platform Win32
.\Build\test-form-designer.ps1 -Platform Win64
.\Build\test-form-designer-ui.ps1 -DelphiBin $DelphiBin -Platform Win32
.\Build\test-form-designer-ui.ps1 -DelphiBin $DelphiBin -Platform Win64
```

Für `$DelphiBin` den `bin`-Ordner der Delphi-Installation einsetzen. Beim Common-Test ohne Compiler im `PATH` zusätzlich `-DelphiBin` angeben. Die Tests öffnen
keine Fenster und prüfen RTTI-Auswahl, Events, Masken, Sortierung, Grenzen,
Cache, Hooks, manuelle Werte, Registry, Schreibschutz und Komponentenlebensdauer
sowie Strukturzyklen, Ergänzungen und Filter-Vorfahren. Zusätzliche Fälle
prüfen gemischte Instanzen, RTTI-Deskriptoren, stabile IDs nach dem Umsortieren,
freie Cache-Werte, Controller-Hooks und gebündelte Änderungsmeldungen.
Die Gruppenprüfungen decken eigene OnLoaded-Listen, freie Beschriftungen,
mehrere Instanzen, Faltzustände und korrekte Werteditoren hinter
eingeklappten Gruppen ab.
Die Adaptertests erzeugen unsichtbare Controls ohne Fensteranzeige oder
Nachrichtenschleife und prüfen auch Komponenten-Streaming.

Mit Delphi 37 bestehen 14 gemeinsame Testgruppen je Plattform und je 61
Adapterprüfungen pro Framework und Plattform (244 insgesamt). Alle sechs
Runtime-/Design-Pakete bauen unter Win32 und Win64.

VCL und FMX werden unterstützt. Die gemeinsamen FormDesigner-Units bleiben
für FPC/LCL vorerst leer; es gibt keinen Ersatzweg über die alte TypeInfo.
Die Implementierung folgt erst nach Prüfung der künftigen erweiterten RTTI
von FPC.
