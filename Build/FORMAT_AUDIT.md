# Pascal-Formatprüfung

Stand: 7. September 2026.

- Codezeilen: maximal **150 Zeichen** einschließlich Einrückung.
- Properties und Routinen-/Methodensignaturen: bis **180 Zeichen** einzeilig.
- Operatoren am Anfang der Folgezeile.
- `else` im `case` auf derselben Einrückungsebene wie die Fallwerte.
- Vorhandene Umbrüche in Ausdrücken und Aufrufen anhand der neuen Grenze neu bewertet.
- 40 aktive Pascal-Dateien geprüft; **0 Formatbefunde**.
- Tokens und Kommentar-/Zeichenketteninhalte bleiben erhalten; vorhandene BOM und CRLF bleiben erhalten.

```powershell
python Build\format_pascal.py --check
python Build\test_pascal_format.py
```
