# Editoren und Editor-Cache

Die gemeinsame Verwaltung liegt in `h5u.Grid.Editors`. Native Controls und Zeichenoperationen liegen in `Vcl.h5u.Grid.Editors` beziehungsweise `Fmx.h5u.Grid.Editors`.

## Auswahl

`Grid.GetCellEditor(Column, ViewRowIndex)` liefert die ausgewählte, wiederverwendbare Editor-Instanz. Diese Abfrage erstellt noch kein natives Control. Die Auswahl gilt für Darstellung und Bearbeitung.

Die erste nicht leere Angabe gewinnt:

1. `Column.OnGetCellEditor`
2. Wert der über `Column.CellEditorColumnId` angegebenen Spalte
3. `Column.OnGetRowEditor`
4. Wert der über `Column.RowEditorColumnId` angegebenen Spalte
5. `Column.Editor`
6. `Grid.DefaultEditors`, unter Berücksichtigung des bisherigen `Column.EditorKind`

Die beiden Ereignisse haben dieselbe Signatur:

```pascal
procedure GetEditor(Sender: TObject; AColumn: Th5uGridColumn;
  ARowIndex: Int64; var AEditorName: string);
```

`ARowIndex` ist der Index in der Grid-Sicht, einschließlich der bestehenden Gruppen-/Baumabbildung. Die Editor-Spalten werden über ihre `Id` gefunden; ihr nicht formatierter Zellwert enthält den Editor-Namen. Diese Wertabfrage löst keine weitere Editor-Auswahl aus.

Ein leerer Name setzt die Suche fort. `None` schaltet die Bearbeitung aus; der Zellwert wird weiterhin dargestellt. Unbekannte Editor-Namen und nicht vorhandene Editor-Spalten lösen einen Fehler aus. Die vorhandenen Fokus-, Schreibschutz- und Validierungsregeln bleiben wirksam.

## Standardzuordnung

| Property unter `Grid.DefaultEditors` | Registrierter Name |
|---|---|
| `Edit` | `TextEditor` |
| `Integer` | `IntegerEditor` |
| `Float` | `FloatEditor` |
| `Currency` | `CurrencyEditor` |
| `Date` | `DateEditor` |
| `Time` | `TimeEditor` |
| `DateTime` | `DateTimeEditor` |
| `CheckBox` | `CheckBoxEditor` |
| `Image` | `ImageEditor` |

Text und Zahlen verwenden Text-Controls. Der TextEditor berücksichtigt den Datentyp der bearbeiteten Spalte. IntegerEditor, FloatEditor und CurrencyEditor konvertieren in ihren eigenen Werttyp; dadurch können sie auch dynamisch in einer gemeinsamen Spalte gewählt werden. Datum/Zeit verwenden die jeweiligen nativen Picker. Die Checkbox wird gezeichnet und benötigt kein eigenes Control. Der Bildeditor verwendet weiterhin den VCL-Dialog beziehungsweise die FMX-Bildoberfläche.

## Cache und Versionen

Der Cache gehört zum einzelnen Grid; Controls werden nicht zwischen Grids geteilt.

| Herkunft des Namens | Cache-Schlüssel |
|---|---|
| Standard, `Column.Editor`, Wert einer Editor-Spalte | `EditorName` |
| `OnGetCellEditor` oder `OnGetRowEditor` liefert einen Namen | `EditorName` + `Column.Id` |

Namen werden ohne Beachtung der Groß-/Kleinschreibung verglichen. Bei Auswahl über ein Ereignis ist eine nicht leere `Column.Id` erforderlich. Verschiedene Zeilen derselben Spalte teilen sich bei gleichem Namen dieselbe Instanz. Namen und ColumnIDs werden intern eindeutig getrennt kodiert.

Beim Start der Bearbeitung übernimmt die Instanz den aktuellen Zellkontext. Erst dann wird `BuildEditor` aufgerufen. Nach Commit oder Cancel wird das Control verborgen. Beim nächsten Einsatz werden Kontext, Wert, Text und Bounds neu gesetzt. Zeichenoperationen erhalten ihren eigenen Kontext und überschreiben nicht den Kontext einer laufenden Bearbeitung.

`EditorVersion` kennzeichnet geänderte Einstellungen. Nach Änderungen an Ereignissen oder eigener Konfiguration sollte die Version erhöht werden. `ControlClass` und `EditorType` erhöhen sie selbstständig. Eine laufende Bearbeitung bleibt bestehen; beim nächsten Einsatz wird das Control neu gebaut. Varianten aus Collection-Vorlagen übernehmen deren neue Version ebenfalls erst außerhalb einer laufenden Bearbeitung.

`Grid.ClearEditorCache` verwirft eine laufende Bearbeitung und gibt die zwischengespeicherten Instanzen beziehungsweise die Controls der konfigurierten CustomEditoren frei. Die Collection-Einstellungen bleiben erhalten. Der Destruktor des Grids gibt den gesamten Cache frei.

## Collection und Varianten

`Grid.Editors` ist eine veröffentlichte Collection. Ihre Einträge werden über DFM/FMX gespeichert. `EditorName` benennt eine lokale Variante; ein lokaler Eintrag hat Vorrang vor einer gleichnamigen globalen Registrierung.

```pascal
var
  E: Th5uVclCustomEditor; // FMX: Th5uFmxCustomEditor
begin
  E := Grid.Editors.AddVariant('Lieferdatum', 'DateEditor');
  Grid.Columns.FindById('delivery').Editor := E.EditorName;

  E := Grid.Editors.Add;
  E.EditorName := 'Kurztext';
  E.ControlClass := TEdit;
  E.OnBuildEditor := BuildShortText;
  Grid.DefaultEditors.Edit := E.EditorName;
end;
```

`AddVariant(Name, EditorType)` verwendet die Implementierung eines registrierten Editors und übernimmt dessen anfänglichen Modus und Klickverhalten. `EditorType` wird gespeichert; nach dem Laden bleibt beispielsweise ein DateEditor ein DateEditor. Ein leeres `EditorType` bezeichnet einen CustomEditor.

`ControlClass` ist die native, öffentliche Klassen-Property mit `TControl` als Basis. `ControlClassName` speichert ihren Namen. Eigene Control-Klassen müssen dafür mit Delphis `RegisterClass` registriert sein. Standardeditoren erwarten einen zu ihrer Implementierung passenden Control-Typ.

## CustomEditor

`Th5uVclCustomEditor` und `Th5uFmxCustomEditor` stellen folgende Erweiterungen bereit:

- `BuildEditor` / `OnBuildEditor`: einmal je Control-Version. Das Ereignis erhält zunächst `nil` und kann ein Control erzeugen. Bleibt es `nil`, wird die konfigurierte oder voreingestellte Klasse verwendet. Das erzeugte Control geht in die Verantwortung des Editor-Items über.
- `GetText`, `SetText`, `GetValue`, `SetValue` sowie `OnGetText`, `OnSetText`, `OnGetValue`, `OnSetValue`.
- `Show`, `Hide`, `Cancel`, `Committed` und die Ereignisse `OnShow`, `OnHide`, `OnCancel`, `OnCommit`.
- `OnEnter`, `OnExit`, `OnChange`, `OnKeyDown`, `OnMouseDown`, `OnMouseMove`, `OnMouseUp`.
- `DrawDisplay` / `OnDrawDisplay` und `DrawEditor` / `OnDrawEditor`. Der Handler setzt `AHandled := True`, wenn er selbst gezeichnet hat.
- `RequestCommit`, `RequestCancel`, `Change`, `Focus`, `BringToFront`, `ReleaseEditor` für eigene Implementierungen.

```pascal
procedure TMainForm.BuildShortText(Sender: TObject; var AControl: TControl);
var
  E: TEdit;
begin
  E := TEdit.Create(Th5uGridEditorItem(Sender).Context.Grid);
  E.MaxLength := 40;
  AControl := E;
end;
```

Die Verwaltung setzt Parent, Bounds, Sichtbarkeit und die Verbindung zum Grid. Sie leitet native Ereignisse an die Item-Ereignisse weiter. Für eigene Änderungen sollte deshalb das Ereignis am Item verwendet werden. In VCL werden Fenster-Ereignisse nur bei `TWinControl` angeschlossen; Textzugriff funktioniert auch mit einem nicht fensterbasierten `TControl`. Geschütztes `OnChange` von `TCustomEdit` und veröffentlichte `TNotifyEvent`-Properties anderer Controls werden unterstützt.

`Mode = Th5uEditorMode.Text` erlaubt automatisches Bearbeiten bei entsprechend eingestelltem Grid. `Mode = Graphic` erzeugt ohne explizite Control-Klasse kein Control. Ein solcher Editor kann vollständig über Zeichen-, Maus- und Tastaturereignisse arbeiten. `ActivateOnClick` erlaubt Aktivierung durch einen einfachen Klick; beim Standard-CheckboxEditor ist es eingeschaltet. `HitTest` lässt sich für eigene Trefferflächen überschreiben. Enter und Escape werden an Commit/Cancel weitergeleitet.

Der Zeichenkontext enthält Grid, Spalte, sichtbaren Zeilenindex, RowKey, Bounds, Zellwert, Text, nativen Canvas, native Farben und gegebenenfalls das bereits pro Zelle gecachte Bild. `PreparePaint` bindet die bestehenden Stilereignisse ein. Eigene gemeinsame Zeichenereignisse müssen den Canvas passend zu VCL/FMX behandeln.

Bei einer Textbearbeitung mit vorhandenem `OnSetValue` an Grid oder Spalte erhält die bisherige Konvertierung weiterhin den Text. Andernfalls wird `GetValue` verwendet. Ein explizites `OnGetValue` am Editor kann die Standardkonvertierung ersetzen. Validierungsfehler lassen die Bearbeitung korrigierbar geöffnet.

## Eigene Klassen registrieren

```pascal
h5uRegisterEditor(Th5uEditorPlatform.VCL, 'MeinEditor', TMeinVclEditor);
h5uRegisterEditor(Th5uEditorPlatform.FMX, 'MeinEditor', TMeinFmxEditor);
```

Eigene Klassen können von einem nativen Standardeditor oder CustomEditor ableiten. `ReadText`, `WriteText`, `ReadValue`, `WriteValue`, `State`, `BuildEditor`, Darstellung und Lebenszyklus sind überschreibbar. `State`/`Modified` können bei komplexen Werten angepasst werden; `Change` meldet eine Änderung an die Verwaltung.

Die globalen Registrierungen sind nach Framework getrennt. Registrierung und Abmeldung erfolgen im UI-Thread. `h5uUnregisterEditor` entfernt eine Registrierung; bestehende Grids sollten vor einer Änderung der Registrierungen ihren Cache leeren.

## Designer und Prüfung

Im Designmodus wird keine Bearbeitung begonnen und kein Editor-Control gebaut. Der VCL-ThumbHint wird ebenfalls erst beim tatsächlichen Anzeigen erzeugt. Interne VCL-Controls werden beim Schreiben des Grids nicht als untergeordnete Design-Controls gespeichert; FMX verwendet weiterhin `Stored = False`.

Die gemeinsamen VCL-/FMX-Regressionstests in `Build/TestGridEditing.inc` prüfen neben den bisherigen Bedienabläufen die Namensauflösung, Cache-Schlüssel, Versionen, Collection-Streaming, Custom-Control-Zugriff, grafische Bearbeitung und Lebenszyklus-Ereignisse. Die Testprogramme unterstützen `--named-editors` für die gezielte Ausführung dieser neuen Prüfungen.
