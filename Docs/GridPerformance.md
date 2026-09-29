# Scrollen, Zeilenhöhen und Laufzeitmessungen

VCL und FMX bieten am Grid die öffentliche Eigenschaft `Performance`.
Sie misst die abgeschlossenen synchronen Arbeitsschritte mit `TStopwatch`:

| Wert | Erfasster Abschnitt |
| --- | --- |
| `Paint` | Gesamter Paint-Aufruf einschließlich darin ausgeführtem Layout und Anwendungs-Callbacks |
| `Layout` | Aktualisierung von Spaltenbreiten, Scrollbars und Gesamthöhe |
| `ColumnLayout` | Berechnung der sichtbaren Spaltenpositionen |
| `HeightMeasurement` | Tatsächliche Messung eines Zellinhalts für die automatische Zeilenhöhe; Cache-Treffer zählen nicht |
| `DataUpdate` | Verarbeitung einer Änderungsmeldung des Controllers im Grid |

Jeder Wert ist ein `Th5uGridTiming` mit `Count`, `LastMilliseconds`,
`TotalMilliseconds` und `MaxMilliseconds`. Die Zeitmessung ist standardmäßig
aktiv; `Grid.Performance.Enabled := False` schaltet sie ab.
`Grid.Performance.Reset` setzt alle Zähler und Zeiten zurück.

Die Abschnitte sind verschachtelt: `Paint` enthält beispielsweise seine
Layout- und Höhenmessungen. Die Zeiten dürfen daher nicht addiert werden.
Erfasst wird verstrichene Zeit innerhalb der Methoden, einschließlich
aufgerufener Getter und Ereignisse. Die Wartezeit bis zum nächsten Paint,
GPU-Ausführung und tatsächliche Bildschirmausgabe sind nicht enthalten.

## Verwendung in der MegaDemo

Vor einem Versuch die Messwerte zurücksetzen. Die Erstellungsdauer bleibt
eine eigene Messung um die Einfügeschleife, mit oder ohne Controller-Batch:
`TStopwatch` steht in `System.Diagnostics`.

```pascal
Grid.Performance.Reset;
Started := TStopwatch.StartNew;
ObjectController.BeginUpdate;
try
  for I := 1 to Count do
    AddPerson;
finally
  ObjectController.EndUpdate;
end;
CreationMilliseconds := Started.Elapsed.TotalMilliseconds;
```

Nach den tatsächlichen Paint-Aufrufen lassen sich deren Messwerte etwa
in einem Auswertungstimer ablesen. Der Timer misst selbst keine Dauer:

```pascal
Timing := Grid.Performance.Paint;
PaintLabel.Text := Format('Letztes Zeichnen: %.3f ms; Maximum: %.3f ms; Aufrufe: %d',
  [Timing.LastMilliseconds, Timing.MaxMilliseconds, Timing.Count]);
```

Das funktioniert auch nach dem Scrollen und benötigt kein `OnIdle`.
Unmittelbar nach `Repaint` muss noch kein neuer Paint abgeschlossen sein.
Auch innerhalb von `OnAfterDraw` ist der aktuelle Paint-Aufruf noch nicht
beendet; dort steht noch die Messung des vorherigen Aufrufs.

## Höhen-Cache und Scrollposition

Die erste sichtbare Zeile wird über einen Index der bekannten Zeilenhöhen
ermittelt. Für große Listen wird mit einer gemeinsamen geschätzten Höhe
und den Abweichungen bereits besuchter Zeilen gearbeitet. Eine Suche
bei Zeile 2.900.000 läuft damit nicht mehr durch die vorherigen Zeilen.
Für noch unbesuchte Zeilen wird weder eine Höhe gemessen noch ein eigener
Cache-Eintrag angelegt. Kleine Listen bis 5.000 Zeilen behalten die exakte
Gesamthöhenberechnung.

Eine Schätzung gilt nicht als abgeschlossene Messung. Beim ersten Zeichnen
wird die tatsächliche Höhe ermittelt und unter dem stabilen RowKey gespeichert.
Erneutes Zeichnen und Zurückscrollen verwenden diese Höhe weiter.

- Eine bekannte einzelne Zeilenänderung invalidiert deren Höhe. Bei aktiver
  Baum-/Gruppenstruktur wird konservativ vollständig invalidiert, weil sich
  auch Zuordnung oder Trennbänder ändern können.
- Ein Reset, eine strukturelle Datenänderung oder ein Seitenwechsel verwirft
  die bisherigen Zuordnungen.
- Änderungen der endgültigen Spaltenbreiten, der Schrift oder der relevanten
  Layoutoptionen erfordern neue Messungen. Die vorläufigen Spaltenbreiten
  während der Scrollbar-Berechnung löschen den Cache nicht mehr.
- Eigene externe Änderungen ohne Controller-Meldung müssen weiterhin über
  eine Änderungsmeldung oder `InvalidateAllRowHeights` bekannt gemacht werden.
- `OnGetRowHeight` kann das Speichern mit `ACacheResult=False` abschalten.
  Kleine Listen lesen solche Höhen für die exakte Gesamthöhe erneut ein.
  Ein dynamisches `OnGetRowSpacing` wird ebenfalls erneut ausgewertet,
  ohne dabei bereits gemessene Inhaltshöhen zu verwerfen.

Die Gesamthöhe sehr großer, noch nicht vollständig besuchter Listen bleibt
eine Schätzung und wird anhand gemessener Zeilen korrigiert.

## Prüfung

`Build/test-grid-performance.ps1` prüft VCL und FMX mit drei Millionen
virtuellen und 30.000 Objektzeilen. Die Tests zeichnen ausschließlich in
Bitmaps; Formulare werden nicht angezeigt und keine Nachrichtenschleife
gestartet. Geprüft werden begrenzte Datenzugriffe bei tiefem Scrollen,
Wiederverwendung der Höhen, gezielte Invalidierung, Breitenänderungen und
die öffentlichen Zeitmesswerte. Die gemeinsamen Tests prüfen zusätzlich
den Höhenindex mit exakten, gebrochenen und großen Int64-Positionen.
