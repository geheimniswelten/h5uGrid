# h5u.Grid – Formatierungsrichtlinie

## Zeilenbreite

Für Delphi-/Pascal-Quellen gilt eine maximale Zeilenlänge von **150 Zeichen**,
einschließlich Einrückung.

**Property-Deklarationen und Routinen-/Methodensignaturen dürfen bis zu 180 Zeichen
lang sein und werden innerhalb dieser Grenze nicht umgebrochen.** Die Ausnahme
gilt für Deklarationen, Implementationsköpfe, Konstruktoren, Destruktoren,
Operator-Methoden und prozedurale Eventtypen. Normale Felddeklarationen und
ausführbare Anweisungen unterliegen der 150-Zeichen-Grenze.

```pascal
property PreserveStateOnDataChange: Boolean read FPreserveStateOnDataChange write SetPreserveStateOnDataChange default True;
```

Erst über 180 Zeichen werden Signaturen an Parametergrenzen und Properties vor
`read`, `write`, `stored`, `default` usw. fortgesetzt. Auch diese Deklarationszeilen
dürfen höchstens 180 Zeichen enthalten. Rückgabetyp, Abschlussklammer und Direktiven
bleiben nach Möglichkeit beim letzten Parameter.

## Operatoren auf Folgezeilen

Bei notwendigen Umbrüchen steht der Operator **am Anfang der Folgezeile**.
Das gilt insbesondere für `and`, `or`, `xor`, `+`, `-`, `*`, `/`, `div`, `mod`,
`shl`, `shr`, `in`, `is`, `as` und Vergleichsoperatoren. Zusammengehörige Folgen
wie `and not`, `not in` oder `is not` bleiben zusammen. Die folgenden
Beispiele veranschaulichen die Position mit verkürzten Ausdrücken.

```pascal
if Assigned(Dataset)
  and Dataset.Active
  and not Dataset.IsEmpty then
  ReadCurrentRow;

Result := FirstValue
  + SecondValue
  - Correction;

if Th5uScrollHintTrigger.ThumbTracking
  in FScrolling.Hint.Triggers then
  ShowThumbHint;
```

Der Zuweisungstrenner `:=` und das `=` einer Typ-/Konstantendeklaration sind keine
binären Ausdrucksoperatoren und dürfen vor einem Zeilenumbruch stehen.

## ELSE im CASE

Das `else` eines `case` steht auf derselben Einrückungsebene wie die Fallwerte,
also eine Ebene innerhalb von `case` und `end`. Die Anweisungen im Standardzweig
werden relativ dazu eine weitere Ebene eingerückt. Ein `else`, das zu einem
`if` gehört, folgt weiterhin der Einrückung dieses `if`.

```pascal
case Value of
  1:
    HandleFirst;
  else
    HandleDefault;
end;
```

Der Formatter berücksichtigt dabei auch verschachtelte `case`- und `if`-Anweisungen.

## Einrückung und Schreibweise

- Zwei Leerzeichen je Einrückungsebene; keine Tabulatoren.
- Vorhandene CRLF-Zeilenenden und die Kodierung einschließlich BOM bleiben erhalten.
- Die Markenschreibweise ist `h5u`, beispielsweise `Th5uVclGrid` und `Ih5uDataController`.
- Gemeinsame Units beginnen mit `h5u.`, Plattformfassaden mit `Vcl.h5u...` bzw. `Fmx.h5u...`.

## Formatter und Prüfung

```powershell
python Build\format_pascal.py
python Build\format_pascal.py --check
python Build\test_pascal_format.py
```

Der Formatter formatiert Deklarationen, bricht lange Codezeilen an Token-Grenzen
um und stellt Operatoren auf Folgezeilen voran. Vorhandene Umbrüche in
Ausdrücken, Bedingungen und Aufrufen werden ebenfalls neu bewertet: Was in
150 Zeichen passt, wird zusammengezogen; längere Ausdrücke werden neu verteilt.
Blockgrenzen, Kommentar-/Direktivengrenzen, Leerzeilen sowie strukturierte
Unit- und Aufzählungslisten bleiben erhalten. Ein unveränderter zweiter Lauf
erzeugt keine weiteren Änderungen. Pascal-Tokens, Zeichenketteninhalte,
Kommentare und Compiler-Direktiven werden beim Schreiben auf Erhaltung geprüft.
Operatoren werden nicht über Compiler-Direktiven hinweg verschoben.

Einzelne unteilbare Zeichenketten, Kommentare oder Bezeichner über der zulässigen
Breite werden nicht inhaltlich verändert. Die Prüfung meldet solche Stellen zur
manuellen Bearbeitung und liefert einen Fehlerstatus.

Die aktiven `.pas`, `.dpr`, `.dpk` und `.inc` werden rekursiv berücksichtigt.
Git-Metadaten, `__history`, `__recovery` und Build-Ausgaben sind ausgeschlossen.

Beide Grenzen sind getrennt konfigurierbar:

```powershell
python Build\format_pascal.py --check --max-line-length 150 --max-declaration-length 180
```

`.editorconfig` setzt die allgemeine 150-Zeichen-Grenze. Die syntaktische Ausnahme
für Properties/Signaturen und die Operatorposition prüft der Formatter; EditorConfig
kann diese Unterscheidung allein nicht ausdrücken. Statischer Audit und Release-Audit
verwenden dieselben Grenzen und dieselbe Operatorregel.
