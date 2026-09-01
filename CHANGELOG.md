# Changelog

## 0.1.1 – 2026-09-01

### Trennflächen, Abstände und Farben

- standardmäßig 1 Pixel breite hellgraue Trennflächen zwischen Datenzeilen, Header und Columns,
- standardmäßig 1 Pixel breite hellgraue Außenabstände oben, links, rechts und unten,
- `0` deaktiviert den jeweiligen Abstand vollständig,
- `Grid.Spacing.DefaultColumnRightSpacing` als Grid-Default,
- `Column.RightSpacing = -1` erbt den Grid-Default; `0` deaktiviert den Abstand der einzelnen Column,
- `Grid.OnGetRowSpacing` erhält den vorgeschlagenen Zeilenabstand als `var`-Parameter,
- eigenständige Farben für Row-, Column- und Außenabstände,
- `Grid.Appearance.DefaultCellColor` und `Column.Color`,
- plattformneutrale ARGB-Farbwerte mit `h5uColorDefault`, `h5uColorNone`, `h5uColorLightGray` und `h5uColorFromRgb`,
- VCL- und FMX-Layout, Scrolling, HitTest und CustomDraw berücksichtigen die neuen Abstände,
- ClientDataSet-Demos enthalten Schalter für Trennlinien und eigene Column-Farben.
- korrigierte Demo-DPR-Pfade im PowerShell-Buildskript.

## 0.1.0 – 2026-09-01

Erster testbarer Quellprototyp von `h5u.Grid`.

### Enthalten

- gemeinsamer Controller-, Spalten-, Options-, Selection- und Factory-Core,
- VCL-Referenzgrid und FMX-Basisgrid,
- per Gridinstanz isolierte Factory-/Registry-Scopes,
- DataSet-, Objektlisten-, VirtualSource- und Memory-Controller,
- selbstbefüllendes `Th5uSampleClientDataSet` für Design-Time-Demos,
- variable Zeilenhöhen und Text-AutoHeight,
- mehrzeilige Headerlayouts,
- Zeilen-, Spalten- und Zellbereichsselektion,
- Scrollmodi und Thumb-Hints,
- Bild-/BLOB-Testpfad,
- Style-/CustomDraw-Grundlagen,
- konfigurierbare Cache- und Pagination-Grundlagen,
- sechs Demo-Projekte für VCL und FMX,
- Konzept, Entwickler-Kurzhilfe, Demo-, Build- und Funktionsdokumentation,
- reproduzierbare statische Audits und PowerShell-Buildskript.

### Bekannte Grenzen

- kein DCC-Build im Erstellungscontainer,
- VCL ist funktional weiter als FMX,
- fortgeschrittene Gruppierungs-, Tree-, VerticalGrid-, Pivot-, Export-, Druck- und Accessibility-Module sind noch nicht vollständig implementiert.
