# h5u.Grid – Formatierungsrichtlinie

## Maximale Zeilenlänge

Für Delphi-Quellen gilt eine maximale Zeilenlänge von **180 Zeichen**, einschließlich Einrückung.

Die Grenze ist bewusst großzügig gewählt. Insbesondere folgende Deklarationen bleiben vollständig in einer Zeile, solange sie einschließlich Einrückung höchstens 180 Zeichen lang sind:

- Property-Deklarationen,
- Methoden- und Funktionsdeklarationen,
- Methodenköpfe in der `implementation`-Sektion,
- prozedurale Eventtypen,
- einfache Felddeklarationen.

Beispiel:

```pascal
property PreserveStateOnDataChange: Boolean read FPreserveStateOnDataChange write SetPreserveStateOnDataChange default True;
```

Auch ein Methodenkopf wird erst umgebrochen, wenn die komplette Signatur die Grenze überschreitet:

```pascal
procedure Th5uVclGrid.SetAdjacentGroupCollapsed(AViewRowIndex: Int64; ACollapsed: Boolean);
```

## Umbruch längerer Signaturen

Überschreitet eine Signatur 180 Zeichen, erfolgt der Umbruch an Parametergrenzen. Auf einer Fortsetzungszeile bleiben der letzte Parameter, die schließende Klammer, der Rückgabetyp und Direktiven nach Möglichkeit zusammen.

```pascal
procedure Th5uVclGrid.DrawSpacingRect(const ABounds: TRect; AElementKind: Th5uElementKind; AColumn: Th5uGridColumn; AViewRowIndex: Int64; const ARowKey: Th5uRowKey;
  AColor: TColor; const AStyleName: string; ATreeLevel: Integer; AClosedTreeLevels: Integer);
```

Ausführbare Anweisungen werden vom mitgelieferten Formatter bewusst nicht automatisch umgebaut. Dadurch bleibt die Formatierung komplexer Ausdrücke, Fallunterscheidungen und fluent APIs eine bewusste Entwicklerentscheidung.

## Einrückung und Schreibweise

- Zwei Leerzeichen je Einrückungsebene.
- Keine Tabulatoren in Pascal-Quellen.
- Die kanonische Markenschreibweise bleibt `h5u`, beispielsweise `Th5uVclGrid`, `Ih5uDataController` und `Eh5uFactoryError`.
- Gemeinsame Units beginnen mit `h5u.`; Plattformfassaden heißen `Vcl.h5u...` beziehungsweise `Fmx.h5u...`.

## Mitgelieferter Formatter

Der konservative Formatter arbeitet ausschließlich auf den oben genannten Deklarationsblöcken:

```powershell
python Build\format_pascal.py
```

Nur prüfen, ohne Dateien zu verändern:

```powershell
python Build\format_pascal.py --check
```

Eine abweichende Grenze kann für Tests angegeben werden:

```powershell
python Build\format_pascal.py --check --max-line-length 180
```

Der Release-Audit ruft den Check automatisch auf. Die Datei `.editorconfig` dokumentiert dieselbe Grenze für unterstützende Editoren und IDE-Erweiterungen.
