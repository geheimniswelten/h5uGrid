# Pascal-Format-Audit

**Stand:** 2. September 2026  
**Version:** 0.1.4

- Maximale erlaubte Zeilenlänge: **180 Zeichen**
- Geprüfte Pascal-Projektdateien: **39**
- Geprüfte Pascal-Zeilen: **16628**
- Tatsächlich längste Zeile: **180 Zeichen** (`Source/Vcl/Vcl.h5u.Grid.pas:2269`)
- Zeilen über der Grenze: **0**
- Tabulatorzeichen: **0**
- Vorzeitig umgebrochene formatierbare Deklarationen: **0**
- Fokussierte Formatter-Semantiktests: **5/5 bestanden**

## Umformatierung

Gegenüber 0.1.3 wurden **789** Property-, Eventtyp-, Feld- oder Methodendeklarationsblöcke kompakter formatiert. Signaturen bleiben nun bis zur Grenze von 180 Zeichen einzeilig und werden darüber an Parametergrenzen fortgesetzt.

Der Tokenstrom aller **39** Pascal-Projektdateien wurde gegen 0.1.3 verglichen. Abgesehen von Whitespace blieb er unverändert.

## Reproduzierbarer Check

```text
python Build\format_pascal.py --check
python Build\test_pascal_format.py
```

> Der Format-Audit bestätigt Quellformat und lexikalische Gleichheit, ersetzt aber keinen Build mit dem Embarcadero-Delphi-Compiler.
