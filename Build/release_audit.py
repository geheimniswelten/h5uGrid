#!/usr/bin/env python3
"""Reproducible, compiler-independent release audit for h5u.Grid.

The audit intentionally checks only rules that can be verified reliably
without an Embarcadero Delphi compiler. It does not claim a DCC build.
"""
from __future__ import annotations

import json
import re
import subprocess
import sys
from dataclasses import asdict, dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "Source"
DEMOS = ROOT / "Demos"
BUILD = ROOT / "Build"


@dataclass
class Finding:
    severity: str
    check: str
    file: str
    message: str
    line: int | None = None


findings: list[Finding] = []
checks: dict[str, dict[str, int | str]] = {}


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8-sig", errors="replace")


def relative(path: Path | str) -> str:
    value = Path(path)
    try:
        return value.resolve().relative_to(ROOT.resolve()).as_posix()
    except Exception:
        return str(path)


def line_no(value: str, pos: int) -> int:
    return value.count("\n", 0, pos) + 1


def add(severity: str, check: str, path: Path | str, message: str, line: int | None = None) -> None:
    findings.append(Finding(severity, check, relative(path), message, line))


def finish(name: str, before: int, status: str | None = None) -> None:
    own = findings[before:]
    result: dict[str, int | str] = {
        "errors": sum(item.severity == "error" for item in own),
        "warnings": sum(item.severity == "warning" for item in own),
    }
    if status:
        result["status"] = status
    checks[name] = result


def require_patterns(name: str, rel: str, patterns: list[tuple[str, str]]) -> None:
    path = ROOT / rel
    if not path.is_file():
        add("error", name, path, "Datei fehlt")
        return
    value = read(path)
    for pattern, description in patterns:
        if not re.search(pattern, value, re.I | re.S | re.M):
            add("error", name, path, f"Erwartete Signatur fehlt: {description}")


def check_layout() -> None:
    name = "required-layout"
    before = len(findings)
    required = [
        "Source/Common/h5u.Grid.Types.pas",
        "Source/Common/h5u.Grid.Factory.pas",
        "Source/Common/h5u.Grid.Columns.pas",
        "Source/Common/h5u.Grid.Options.pas",
        "Source/Common/h5u.Grid.AdjacentGroups.pas",
        "Source/Common/h5u.Grid.Selection.pas",
        "Source/Common/h5u.Grid.Data.Core.pas",
        "Source/Common/h5u.Grid.Data.DataSet.pas",
        "Source/Common/h5u.Grid.Data.Objects.pas",
        "Source/Common/h5u.Grid.Data.Virtual.pas",
        "Source/Common/h5u.Grid.Data.Memory.pas",
        "Source/Common/h5u.Grid.SampleData.pas",
        "Source/Vcl/Vcl.h5u.Grid.pas",
        "Source/FMX/FMX.h5u.Grid.pas",
        "Docs/CONCEPT.md",
        "Docs/QUICKHELP.md",
        "Docs/FEATURE-MATRIX.md",
        "VERSION.txt",
        "Build/test_tree_branch_end.py",
        "Build/test_adjacent_group_folding.py",
    ]
    for rel in required:
        if not (ROOT / rel).is_file():
            add("error", name, ROOT / rel, "Erforderliche Datei fehlt")

    expected = {(platform, demo) for platform in ("VCL", "FMX") for demo in ("ClientDataSet", "ObjectList", "VirtualLive")}
    actual: set[tuple[str, str]] = set()
    for dpr in DEMOS.rglob("*.dpr"):
        parts = dpr.relative_to(DEMOS).parts
        if len(parts) >= 3:
            actual.add((parts[0], parts[1]))
    for platform, demo in sorted(expected - actual):
        add("error", name, DEMOS / platform / demo, "Erwartetes Demo-Projekt fehlt")
    if len(list(DEMOS.rglob("*.dpr"))) != 6:
        add("error", name, DEMOS, "Es werden exakt sechs Demo-DPRs erwartet")
    finish(name, before)


def check_units_and_paths() -> None:
    name = "units-and-project-paths"
    before = len(findings)
    unit_re = re.compile(r"^\s*unit\s+([^;]+);", re.I | re.M)
    for path in SOURCE.rglob("*.pas"):
        value = read(path)
        match = unit_re.search(value)
        if not match:
            add("error", name, path, "Unit-Deklaration fehlt")
            continue
        declared = match.group(1).strip()
        if declared.casefold() != path.stem.casefold():
            add("error", name, path, f"Unit {declared!r} stimmt nicht mit dem Dateinamen überein")
        if path.parent.name == "Common" and re.search(r"\b(?:Vcl|FMX)\.", value, re.I):
            add("error", name, path, "Gemeinsame Unit referenziert einen Plattform-Namensraum")
        if path.parent.name == "Vcl" and re.search(r"\bFMX\.", value, re.I):
            add("error", name, path, "VCL-Unit referenziert FMX")
        if path.parent.name == "FMX" and re.search(r"\bVcl\.", value, re.I):
            add("error", name, path, "FMX-Unit referenziert VCL")
        if not re.search(r"\bend\s*\.\s*$", value, re.I | re.S):
            add("error", name, path, "Unit endet nicht mit end.")

    path_re = re.compile(r"\bin\s*['\"]([^'\"]+)['\"]", re.I)
    for path in list((ROOT / "Packages").rglob("*.dpk")) + list(DEMOS.rglob("*.dpr")):
        value = read(path)
        for match in path_re.finditer(value):
            raw = match.group(1)
            target = (path.parent / raw.replace("\\", "/")).resolve()
            if not target.is_file():
                add("error", name, path, f"Referenzierte Datei fehlt: {raw}", line_no(value, match.start()))

    build_script = ROOT / "Build" / "build-delphi.ps1"
    if build_script.is_file():
        value = read(build_script)
        for match in re.finditer(r"Join-Path\s+\$root\s+'([^']+)'", value, re.I):
            raw = match.group(1)
            target = (ROOT / raw.replace("\\", "/")).resolve()
            if not target.exists():
                add(
                    "error",
                    name,
                    build_script,
                    f"Buildskript referenziert fehlenden Pfad: {raw}",
                    line_no(value, match.start()),
                )
    finish(name, before)


def check_naming() -> None:
    name = "h5u-naming"
    before = len(findings)
    for path in list(SOURCE.rglob("*.pas")) + list(DEMOS.rglob("*.pas")) + list(DEMOS.rglob("*.dpr")):
        value = read(path)
        for match in re.finditer(r"\b(?:TH5u|IH5u|EH5u)[A-Za-z0-9_]*", value):
            add("error", name, path, f"Nichtkanonische Schreibweise: {match.group(0)}", line_no(value, match.start()))
    if (SOURCE / "Common" / "h5u.Grid.pas").exists():
        add("error", name, SOURCE / "Common" / "h5u.Grid.pas", "Name ist für die Vcl./FMX.-Fassade reserviert")
    finish(name, before)


def check_forms() -> None:
    name = "form-resources"
    before = len(findings)
    resource_results: list[dict[str, str]] = []
    resources = sorted(list(DEMOS.rglob("*.dfm")) + list(DEMOS.rglob("*.fmx")))
    for resource in resources:
        pas = resource.with_suffix(".pas")
        if not pas.is_file():
            add("error", name, resource, "Zugehörige Pascal-Unit fehlt")
            continue
        rvalue = read(resource)
        pvalue = read(pas)
        root = re.search(r"^\s*(?:object|inherited|inline)\s+\w+\s*:\s*([\w.]+)", rvalue, re.I | re.M)
        if not root:
            add("error", name, resource, "Root-Objekt nicht gefunden")
        else:
            cls = root.group(1).split(".")[-1]
            if not re.search(r"\b" + re.escape(cls) + r"\s*=\s*class\b", pvalue, re.I):
                add("error", name, resource, f"Formklasse {cls} fehlt in Pascal-Unit")
        for event in re.finditer(r"^\s*(On[A-Za-z0-9_]+)\s*=\s*([A-Za-z_][A-Za-z0-9_]*)\s*$", rvalue, re.M):
            method = event.group(2)
            if not re.search(r"\b" + re.escape(method) + r"\s*\(", pvalue, re.I):
                add("error", name, resource, f"Handler {method} für {event.group(1)} fehlt", line_no(rvalue, event.start()))
        if re.search(r"^\s*FileName\s*=", rvalue, re.I | re.M):
            add("error", name, resource, "Externe ClientDataSet-Datei eingetragen")
        resource_results.append({"resource": relative(resource), "unit": relative(pas), "status": "checked"})

    form_findings = [item for item in findings[before:] if item.check == name]
    payload = {
        "resource_files": len(resources),
        "demo_projects": len(list(DEMOS.rglob("*.dpr"))),
        "errors": sum(item.severity == "error" for item in form_findings),
        "resources": resource_results,
        "findings": [asdict(item) for item in form_findings],
    }
    (BUILD / "form-resource-audit.json").write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
    lines = [
        "# Form-/Ressourcen-Audit",
        "",
        f"- Ressourcen: **{payload['resource_files']}**",
        f"- Demo-Projekte: **{payload['demo_projects']}**",
        f"- Harte Befunde: **{payload['errors']}**",
        "",
    ]
    if form_findings:
        lines += ["## Befunde", ""]
        for item in form_findings:
            lines.append(f"- **{item.severity.upper()}** `{item.file}` – {item.message}")
    else:
        lines.append("Alle DFM-/FMX-Ressourcen, Rootklassen und eingetragenen Eventhandler wurden konsistent gefunden.")
    (BUILD / "FORM_RESOURCE_AUDIT.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    finish(name, before)


def check_factory_and_features() -> None:
    name = "factory-and-feature-signatures"
    before = len(findings)
    require_patterns(name, "Source/Common/h5u.Grid.Types.pas", [
        (r"Th5uFactoryContext\s*=\s*record", "Factory-Kontext"),
        (r"\bGrid\s*:\s*TObject", "Grid-Zeiger im Factory-Kontext"),
        (r"\bView\s*:\s*TObject", "View-Zeiger im Factory-Kontext"),
        (r"\bDataController\s*:\s*TObject", "Controller-Zeiger im Factory-Kontext"),
        (r"\bColumn\s*:\s*TObject", "Column-Zeiger im Factory-Kontext"),
        (r"\bRowKey\s*:\s*Th5uRowKey", "RowKey im Factory-Kontext"),
        (r"Th5uVerticalScrollMode\s*=.*?WholeRows.*?PixelSnap", "vertikale Scrollmodi"),
        (r"RowSpacing.*?ColumnSpacing.*?ContentPadding.*?TreeBranchEndBand", "Separator- und Tree-Abschlusselementarten"),
        (r"h5uClassIdGridTreeBranchEndBand.*?h5u\.grid\.spacing\.tree-branch-end", "Factory-ID der Tree-Abschlussleiste"),
        (r"TreeLevel\s*:\s*Integer.*?ClosedTreeLevels\s*:\s*Integer", "Tree-Metadaten im Factory-Kontext"),
        (r"Th5uGetTreeLevelEvent", "Tree-Level-Event"),
        (r"Th5uGetTreeBranchEndEvent", "Tree-Astende-Event"),
        (r"h5uClassIdGridAdjacentGroupFoldGlyph.*?h5u\.grid\.visual\.adjacent-group-fold-glyph", "Factory-ID des Folgegruppen-Faltzeichens"),
        (r"h5uClassIdGridAdjacentGroupEndBand.*?h5u\.grid\.spacing\.adjacent-group-end", "Factory-ID der Folgegruppen-Abschlussleiste"),
        (r"AdjacentGroupFoldGlyph.*?AdjacentGroupEndBand", "Folgegruppen-Elementarten"),
        (r"Th5uAdjacentGroupEndBandVisibility\s*=.*?Never.*?CollapsedOnly.*?ExpandedOnly.*?Always", "vier Folgegruppen-Abschlussleistenmodi"),
        (r"Th5uGetAdjacentGroupIdEvent", "Folgegruppen-ID-Event"),
        (r"Th5uAdjacentGroupStateChangedEvent", "Folgegruppen-Zustandsereignis"),
        (r"AdjacentGroupAnchorRowKey\s*:\s*Th5uRowKey.*?AdjacentGroupRowCount\s*:\s*Int64", "Folgegruppen-Metadaten im Factory-Kontext"),
        (r"h5uColorLightGray\s*=\s*Th5uColor\(\$FFD3D3D3\)", "hellgrauer Defaultfarbwert"),
    ])
    require_patterns(name, "Source/Common/h5u.Grid.Factory.pas", [
        (r"Th5uFactoryScope", "lokaler Factory-Scope"),
        (r"OnGetClass", "OnGetClass"),
        (r"OnCreateInstance", "OnCreateInstance"),
        (r"OnConfigureInstance", "OnConfigureInstance"),
        (r"function\s+RegisterClass\s*\(", "Klassenregistrierung"),
    ])
    require_patterns(name, "Source/Common/h5u.Grid.Options.pas", [
        (r"Th5uGridSpacingOptions\s*=\s*class", "Spacing-Options"),
        (r"property\s+Left:.*?default\s+1", "Left-Default 1"),
        (r"property\s+Top:.*?default\s+1", "Top-Default 1"),
        (r"property\s+Right:.*?default\s+1", "Right-Default 1"),
        (r"property\s+Bottom:.*?default\s+1", "Bottom-Default 1"),
        (r"property\s+RowSpacing:.*?default\s+1", "RowSpacing-Default 1"),
        (r"DefaultColumnRightSpacing.*?default\s+1", "ColumnSpacing-Default 1"),
        (r"RowSpacingColor.*?default\s+h5uColorLightGray", "Row-Separatorfarbe"),
        (r"ColumnSpacingColor.*?default\s+h5uColorLightGray", "Column-Separatorfarbe"),
        (r"ContentPaddingColor.*?default\s+h5uColorLightGray", "Außenrandfarbe"),
        (r"constructor\s+Th5uGridSpacingOptions\.Create.*?FLeft\s*:=\s*1.*?FTop\s*:=\s*1.*?FRight\s*:=\s*1.*?FBottom\s*:=\s*1.*?FRowSpacing\s*:=\s*1.*?FDefaultColumnRightSpacing\s*:=\s*1", "Laufzeitdefaults der Separatorbreiten"),
        (r"constructor\s+Th5uGridSpacingOptions\.Create.*?FRowSpacingColor\s*:=\s*h5uColorLightGray.*?FColumnSpacingColor\s*:=\s*h5uColorLightGray.*?FContentPaddingColor\s*:=\s*h5uColorLightGray", "Laufzeitdefaults der Separatorfarben"),
        (r"procedure\s+SetAllSeparators\s*\(", "gemeinsames Aktivieren/Deaktivieren"),
        (r"Th5uGridAppearanceOptions", "Grid-Appearance"),
        (r"DefaultCellColor", "Grid-Defaultfarbe"),
        (r"Th5uTreeBranchEndBandOptions\s*=\s*class", "Tree-Abschlussleisten-Optionen"),
        (r"property\s+Height:.*?default\s+6", "Tree-Abschlussleistenhöhe"),
        (r"FStyleName\s*:=\s*''", "optionaler Style der Tree-Abschlussleiste"),
        (r"property\s+IncludeEndOfData:.*?default\s+True", "Tree-Abschluss am Datenende"),
        (r"Th5uTreeOptions\s*=\s*class", "Tree-Optionen"),
        (r"property\s+LevelColumnId", "Tree-Level-Column"),
        (r"property\s+BranchEndBand", "Tree-Abschlussleisten-Property"),
        (r"Th5uAdjacentGroupEndBandOptions\s*=\s*class", "Folgegruppen-Abschlussleistenoptionen"),
        (r"property\s+Visibility:.*?default\s+Th5uAdjacentGroupEndBandVisibility\.Never", "Folgegruppen-Abschlussleisten-Default Never"),
        (r"property\s+Height:.*?default\s+6", "Folgegruppen-Abschlussleistenhöhe"),
        (r"Th5uAdjacentGroupFoldingOptions\s*=\s*class", "Folgegruppen-Faltungsoptionen"),
        (r"property\s+IdColumnId", "Folgegruppen-ID-Column"),
        (r"property\s+InitialState:.*?default\s+Th5uAdjacentGroupInitialState\.Expanded", "Folgegruppen-Initialzustand"),
        (r"property\s+ShowFoldGlyph:.*?default\s+True", "Faltzeichen-Option"),
        (r"property\s+PreserveStateOnDataChange:.*?default\s+True", "Zustandserhalt über Datenänderungen"),
        (r"property\s+EndBand:.*?Th5uAdjacentGroupEndBandOptions", "Folgegruppen-Abschlussleisten-Property"),
    ])
    require_patterns(name, "Source/Common/h5u.Grid.AdjacentGroups.pas", [
        (r"Th5uAdjacentGroupMap\s*=\s*class", "sichtbare Folgegruppen-View-Abbildung"),
        (r"StateKey: string.*?AnchorRowKey: Th5uRowKey", "laufbezogener Zustandsanker"),
        (r"function\s+BuildStateKey.*?row:.*?\|id:", "Zustandsschlüssel aus Anchor-RowKey und ID"),
        (r"if\s+FHasPendingRun\s+and\s+LCanGroup.*?FPendingRun\.ComparisonKey\s*=\s*LComparisonKey", "nur benachbarte IDs werden zusammengefasst"),
        (r"if\s+LRun\.Collapsed\s+then\s+Continue", "eingeklappt blendet Folgezeilen aus"),
        (r"function\s+SetCollapsedAtViewRow", "einzelnen Lauf falten"),
        (r"function\s+ExpandAll", "alle Läufe öffnen"),
        (r"function\s+CollapseAll", "alle Läufe falten"),
    ])
    require_patterns(name, "Source/Common/h5u.Grid.Columns.pas", [
        (r"property\s+RightSpacing:.*?default\s+-1", "RightSpacing mit Vererbungswert -1"),
        (r"constructor\s+Th5uGridColumn\.Create.*?FRightSpacing\s*:=\s*-1", "RightSpacing-Laufzeitdefault -1"),
        (r"constructor\s+Th5uGridColumn\.Create.*?FColor\s*:=\s*h5uColorDefault", "Column-Farbdefault"),
        (r"property\s+Color:\s*Th5uColor", "Column-Farbe"),
        (r"AutoHeight", "AutoHeight"),
        (r"RowSpan", "Header RowSpan"),
        (r"ColumnSpan", "Header ColumnSpan"),
    ])
    for rel, grid_class in [
        ("Source/Vcl/Vcl.h5u.Grid.pas", "Th5uVclGrid"),
        ("Source/FMX/FMX.h5u.Grid.pas", "Th5uFmxGrid"),
    ]:
        require_patterns(name, rel, [
            (rf"{grid_class}\s*=\s*class", "Grid-Klasse"),
            (r"property\s+Spacing:\s*Th5uGridSpacingOptions", "Spacing-Property"),
            (r"property\s+Appearance:\s*Th5uGridAppearanceOptions", "Appearance-Property"),
            (r"property\s+GridLines:\s*Boolean", "GridLines-Komfortschalter"),
            (r"procedure\s+" + grid_class + r"\.SetGridLines.*?SetAllSeparators\(1\).*?SetAllSeparators\(0\)", "GridLines setzt 1 oder 0"),
            (r"function\s+" + grid_class + r"\.GetGridLines.*?FSpacing\.Left.*?FSpacing\.Top.*?FSpacing\.Right.*?FSpacing\.Bottom.*?FSpacing\.RowSpacing.*?FSpacing\.DefaultColumnRightSpacing", "GridLines berücksichtigt alle globalen Separatoren"),
            (r"OnGetRowSpacing", "zeilenabhängiger Abstand"),
            (r"DrawSpacingRect", "Separator-Rendering"),
            (r"DrawContentPadding", "Außenrand-Rendering"),
            (r"GetEffectiveColumnRightSpacing", "Column-Vererbung"),
            (r"property\s+Tree:\s*Th5uTreeOptions", "Tree-Optionen am Grid"),
            (r"OnGetTreeLevel", "Tree-Level-Event am Grid"),
            (r"OnGetTreeBranchEnd", "Tree-Astende-Event am Grid"),
            (r"GetEffectiveRowSeparatorFor.*?Result\s*:=\s*FTree\.BranchEndBand\.Height", "Tree-Abschluss ersetzt den normalen Separator"),
            (r"Th5uElementKind\.TreeBranchEndBand", "Tree-Abschluss-Rendering"),
            (r"Th5u(?:Vcl|Fmx)SpacingCell\s*=\s*class", "gepoolte Separator-/Abschlusszelle"),
            (r"DrawSpacingRect.*?AcquireVisualCell", "Separatoren durchlaufen den lokalen Factory-Scope"),
            (r"ClosedTreeLevels", "Anzahl geschlossener Tree-Ebenen im Zeichenkontext"),
            (r"property\s+AdjacentGroupFolding:\s*Th5uAdjacentGroupFoldingOptions", "Folgegruppen-Faltung am Grid"),
            (r"OnGetAdjacentGroupId", "Folgegruppen-ID-Event am Grid"),
            (r"OnAdjacentGroupStateChanged", "Folgegruppen-Zustandsereignis am Grid"),
            (r"EnsureAdjacentGroupMap", "sichtbare Folgegruppen-Abbildung"),
            (r"MapViewToControllerRowIndex", "View-zu-Controller-Abbildung"),
            (r"GetAdjacentGroupEndBandInfo.*?CollapsedOnly.*?ExpandedOnly.*?Always", "vier Abschlussleistenmodi im Renderer"),
            (r"GetEffectiveRowSeparatorFor.*?Th5uElementKind\.AdjacentGroupEndBand.*?EndBand\.Height", "Folgegruppen-Abschlussleiste ersetzt RowSpacing"),
            (r"h5uClassIdGridAdjacentGroupFoldGlyph", "Factory-Erzeugung des Faltzeichens"),
            (r"h5uClassIdGridAdjacentGroupEndBand", "Factory-Erzeugung der Abschlussleiste"),
            (r"ToggleAdjacentGroup", "einzelnen Folgegruppenlauf umschalten"),
            (r"CollapseAllAdjacentGroups", "alle Folgegruppenläufe falten"),
            (r"ExpandAllAdjacentGroups", "alle Folgegruppenläufe öffnen"),
            (r"FactoryScope", "Factory-Scope pro Grid"),
            (r"AcquireVisualCell", "gepoolte sichtbare Zellobjekte"),
        ])
    require_patterns(name, "Demos/VCL/ClientDataSet/Main.pas", [
        (r"Grid\.GridLines\s*:=\s*SeparatorsCheck\.Checked", "VCL Separator-Schalter"),
        (r"RightSpacing\s*:=\s*8", "VCL individueller Column-Abstand"),
        (r"DefaultCellColor", "VCL Grid-Farbe"),
        (r"\.Color\s*:=\s*h5uColorFromRgb", "VCL Column-Farbe"),
        (r"Grid\.Tree\.Enabled\s*:=\s*TreeEndBandCheck\.Checked", "VCL Tree-Abschluss-Schalter"),
        (r"Tree\.BranchEndBand\.Enabled", "VCL Tree-Abschlussoption"),
        (r"Grid\.AdjacentGroupFolding\.Enabled\s*:=\s*AdjacentGroupCheck\.Checked", "VCL Folgegruppen-Schalter"),
        (r"AdjacentGroupFolding\.IdColumnId\s*:=\s*'fold_group'", "VCL Folgegruppen-ID"),
        (r"CollapsedOnly.*?ExpandedOnly.*?Always", "VCL vier Abschlussleistenmodi"),
        (r"CollapseAllAdjacentGroups.*?ExpandAllAdjacentGroups|ExpandAllAdjacentGroups.*?CollapseAllAdjacentGroups", "VCL Alle-falten/-öffnen"),
    ])
    require_patterns(name, "Demos/FMX/ClientDataSet/Main.pas", [
        (r"Grid\.GridLines\s*:=\s*SeparatorsCheck\.IsChecked", "FMX Separator-Schalter"),
        (r"RightSpacing\s*:=\s*8", "FMX individueller Column-Abstand"),
        (r"DefaultCellColor", "FMX Grid-Farbe"),
        (r"\.Color\s*:=\s*h5uColorFromRgb", "FMX Column-Farbe"),
        (r"Grid\.Tree\.Enabled\s*:=\s*TreeEndBandCheck\.IsChecked", "FMX Tree-Abschluss-Schalter"),
        (r"Tree\.BranchEndBand\.Enabled", "FMX Tree-Abschlussoption"),
        (r"Grid\.AdjacentGroupFolding\.Enabled\s*:=\s*AdjacentGroupCheck\.IsChecked", "FMX Folgegruppen-Schalter"),
        (r"AdjacentGroupFolding\.IdColumnId\s*:=\s*'fold_group'", "FMX Folgegruppen-ID"),
        (r"CollapsedOnly.*?ExpandedOnly.*?Always", "FMX vier Abschlussleistenmodi"),
        (r"CollapseAllAdjacentGroups.*?ExpandAllAdjacentGroups|ExpandAllAdjacentGroups.*?CollapseAllAdjacentGroups", "FMX Alle-falten/-öffnen"),
    ])
    require_patterns(name, "Source/Common/h5u.Grid.SampleData.pas", [
        (r"Name\s*:=\s*'TREE_LEVEL'", "TREE_LEVEL-Feld in den Designer-Musterdaten"),
        (r"FieldByName\('TREE_LEVEL'\)\.AsInteger", "TREE_LEVEL-Werte in den Musterdaten"),
        (r"Name\s*:=\s*'FOLD_GROUP'", "FOLD_GROUP-Feld in den Designer-Musterdaten"),
        (r"FieldByName\('FOLD_GROUP'\)\.AsInteger", "FOLD_GROUP-Werte in den Musterdaten"),
        (r"case\s+\(AIndex\s*-\s*1\)\s+mod\s+10.*?0,\s*1,\s*2:.*?6,\s*7,\s*8:", "getrennte Wiederholung derselben Folgegruppen-ID"),
    ])
    require_patterns(name, "Source/Common/h5u.Grid.Data.Core.pas", [
        (r"function\s+IsRowAvailable", "seitenübergreifender Tree-Lookahead"),
    ])
    finish(name, before)



def check_documented_api() -> None:
    name = "documented-public-api"
    before = len(findings)
    forbidden: list[tuple[str, str]] = [
        (r"\bRegisterOverride\s*\(", "nicht vorhandene Factory-Methode RegisterOverride"),
        (r"\bRegisterRule\s*\(", "nicht vorhandene Factory-Methode RegisterRule"),
        (r"\.ItemClass\s*:?=", "nicht vorhandene ObjectList-Property ItemClass"),
        (r"\.AddObject\s*\(", "nicht vorhandene ObjectList-Methode AddObject"),
        (r"\bTh5uDataCacheMode\b", "veralteter Cache-Typname"),
        (r"ScrollHints\.Vertical\.", "veralteter verschachtelter ScrollHint-Pfad"),
    ]
    for rel in ("Docs/CONCEPT.md", "Docs/QUICKHELP.md"):
        path = ROOT / rel
        if not path.is_file():
            continue
        value = read(path)
        for pattern, description in forbidden:
            for match in re.finditer(pattern, value, re.I):
                add("error", name, path, description, line_no(value, match.start()))

    require_patterns(name, "Docs/QUICKHELP.md", [
        (r"FactoryScope\.RegisterClass\s*\(", "reale Factory-API"),
        (r"ObjectController1\.Add\s*\(", "reale ObjectList-API"),
        (r"ASourceRowIndex\s*:\s*Int64", "reale VirtualController-Signatur"),
        (r"Spacing\.SetAllSeparators\s*\(1\)", "Separator-Komfortmethode"),
        (r"AdjacentGroupFolding\.IdColumnId", "Folgegruppen-ID-API"),
        (r"CollapsedOnly", "Abschlussleiste nur eingeklappt"),
        (r"ExpandedOnly", "Abschlussleiste nur ausgeklappt"),
        (r"CollapseAllAdjacentGroups", "alle Folgegruppen falten"),
        (r"ExpandAllAdjacentGroups", "alle Folgegruppen öffnen"),
    ])
    finish(name, before)

def check_placeholders_and_version() -> None:
    name = "source-placeholders-and-version"
    before = len(findings)
    for path in SOURCE.rglob("*.pas"):
        value = read(path)
        for match in re.finditer(r"\b(?:TODO-COMPILE|FIXME-COMPILE|NotImplemented|<UNRESOLVED>)\b", value, re.I):
            add("error", name, path, f"Nicht aufgelöster Platzhalter: {match.group(0)}", line_no(value, match.start()))
    version = read(ROOT / "VERSION.txt").strip() if (ROOT / "VERSION.txt").exists() else ""
    if version != "0.1.3":
        add("error", name, ROOT / "VERSION.txt", f"Erwartete Version 0.1.3, gefunden {version!r}")
    for rel in ("README.md", "CHANGELOG.md", "Build/BUILD_STATUS.md"):
        path = ROOT / rel
        if path.exists() and "0.1.3" not in read(path):
            add("error", name, path, "Version 0.1.3 wird nicht genannt")
    finish(name, before)



def check_method_consistency() -> None:
    """Compare declarations and implementations for release-touched classes."""
    name = "declaration-implementation-consistency"
    before = len(findings)
    targets = [
        ("Source/Common/h5u.Grid.Options.pas", "Th5uGridSpacingOptions"),
        ("Source/Common/h5u.Grid.Options.pas", "Th5uGridAppearanceOptions"),
        ("Source/Common/h5u.Grid.Options.pas", "Th5uTreeBranchEndBandOptions"),
        ("Source/Common/h5u.Grid.Options.pas", "Th5uTreeOptions"),
        ("Source/Common/h5u.Grid.Options.pas", "Th5uAdjacentGroupEndBandOptions"),
        ("Source/Common/h5u.Grid.Options.pas", "Th5uAdjacentGroupFoldingOptions"),
        ("Source/Common/h5u.Grid.AdjacentGroups.pas", "Th5uAdjacentGroupMap"),
        ("Source/Common/h5u.Grid.Columns.pas", "Th5uGridColumn"),
        ("Source/Vcl/Vcl.h5u.Grid.pas", "Th5uVclSpacingCell"),
        ("Source/Vcl/Vcl.h5u.Grid.pas", "Th5uVclAdjacentGroupGlyphCell"),
        ("Source/Vcl/Vcl.h5u.Grid.pas", "Th5uVclGrid"),
        ("Source/FMX/FMX.h5u.Grid.pas", "Th5uFmxSpacingCell"),
        ("Source/FMX/FMX.h5u.Grid.pas", "Th5uFmxAdjacentGroupGlyphCell"),
        ("Source/FMX/FMX.h5u.Grid.pas", "Th5uFmxGrid"),
    ]
    for rel, class_name in targets:
        path = ROOT / rel
        value = read(path)
        start = re.search(
            rf"(?im)^\s*{re.escape(class_name)}\s*=\s*class(?:\s*\([^\n]+\))?\s*$",
            value,
        )
        if not start:
            add("error", name, path, f"Klassenrumpf {class_name} nicht gefunden")
            continue
        end_match = re.search(r"(?im)^\s*end\s*;", value[start.end():])
        if not end_match:
            add("error", name, path, f"Ende des Klassenrumpfs {class_name} nicht gefunden")
            continue
        block = value[start.start():start.end() + end_match.end()]
        declarations = {
            match.group(1).casefold()
            for match in re.finditer(
                r"(?im)^\s*(?:class\s+)?(?:function|procedure|constructor|destructor)\s+"
                r"([A-Za-z_][A-Za-z0-9_]*)\b",
                block,
            )
        }
        implementations = {
            match.group(1).casefold()
            for match in re.finditer(
                rf"(?im)^\s*(?:class\s+)?(?:function|procedure|constructor|destructor)\s+"
                rf"{re.escape(class_name)}\.([A-Za-z_][A-Za-z0-9_]*)\b",
                value,
            )
        }
        for method in sorted(declarations - implementations):
            add("error", name, path, f"Implementierung fehlt: {class_name}.{method}")
        for method in sorted(implementations - declarations):
            add("error", name, path, f"Deklaration fehlt: {class_name}.{method}")
    finish(name, before)


def check_demo_sample_contract() -> None:
    name = "clientdataset-demo-contract"
    before = len(findings)
    stale = (
        "PopulateAtDesignTime",
        "SampleRecordCount",
        "SampleDataKind",
        "RebuildSampleData",
        "CREATED_AT",
    )
    for rel in (
        "Demos/VCL/ClientDataSet/Main.pas",
        "Demos/VCL/ClientDataSet/Main.dfm",
        "Demos/FMX/ClientDataSet/Main.pas",
        "Demos/FMX/ClientDataSet/Main.fmx",
    ):
        path = ROOT / rel
        value = read(path)
        for token in stale:
            match = re.search(r"\b" + re.escape(token) + r"\b", value, re.I)
            if match:
                add("error", name, path, f"Veraltete Demo-Signatur: {token}", line_no(value, match.start()))
    for rel in (
        "Demos/VCL/ClientDataSet/Main.dfm",
        "Demos/FMX/ClientDataSet/Main.fmx",
    ):
        require_patterns(name, rel, [
            (r"Tree\.LevelColumnId\s*=\s*'TREE_LEVEL'", "TREE_LEVEL im Designer"),
            (r"Tree\.BranchEndBand\.Enabled\s*=\s*True", "aktive Tree-Abschlussleiste im Designer"),
            (r"AdjacentGroupFolding\.Enabled\s*=\s*True", "aktive Folgegruppen-Faltung im Designer"),
            (r"AdjacentGroupFolding\.IdColumnId\s*=\s*'fold_group'", "Folgegruppen-ID im Designer"),
            (r"AdjacentGroupFolding\.EndBand\.Visibility\s*=\s*Always", "Abschlussleistenmodus im Designer"),
            (r"Id\s*=\s*'fold_group'.*?FieldName\s*=\s*'FOLD_GROUP'.*?Visible\s*=\s*False", "unsichtbare FOLD_GROUP-Column"),
        ])
    finish(name, before)


def check_tree_branch_end_semantics() -> None:
    name = "tree-branch-end-semantics"
    before = len(findings)
    script = BUILD / "test_tree_branch_end.py"
    if not script.is_file():
        add("error", name, script, "Semantischer Tree-Test fehlt")
        finish(name, before)
        return
    result = subprocess.run(
        [sys.executable, str(script)],
        cwd=ROOT,
        text=True,
        capture_output=True,
        check=False,
    )
    if result.returncode != 0:
        detail = (result.stderr or result.stdout or "unbekannter Fehler").strip()
        add("error", name, script, f"Semantischer Tree-Test fehlgeschlagen: {detail}")
    finish(name, before, (result.stdout or "").strip() or None)

def check_adjacent_group_folding_semantics() -> None:
    name = "adjacent-group-folding-semantics"
    before = len(findings)
    script = BUILD / "test_adjacent_group_folding.py"
    if not script.is_file():
        add("error", name, script, "Semantischer Folgegruppen-Test fehlt")
        finish(name, before)
        return
    result = subprocess.run(
        [sys.executable, str(script)],
        cwd=ROOT,
        text=True,
        capture_output=True,
        check=False,
    )
    if result.returncode != 0:
        detail = (result.stderr or result.stdout or "unbekannter Fehler").strip()
        add("error", name, script, f"Semantischer Folgegruppen-Test fehlgeschlagen: {detail}")
    finish(name, before, (result.stdout or "").strip() or None)

def check_optional_parser() -> None:
    name = "tree-sitter-pascal"
    before = len(findings)
    try:
        from tree_sitter import Language, Parser  # type: ignore
        import tree_sitter_pascal  # type: ignore
    except Exception:
        checks[name] = {"errors": 0, "warnings": 0, "status": "optionale Abhängigkeit nicht installiert"}
        return

    parser = Parser(Language(tree_sitter_pascal.language()))
    for path in SOURCE.rglob("*.pas"):
        data = path.read_bytes()
        tree = parser.parse(data)
        if tree.root_node.has_error:
            add("warning", name, path, "Parser meldet Delphi-spezifische Syntaxdiagnosen; mit DCC prüfen")
    finish(name, before, "Parser ausgeführt")


def write_reports() -> int:
    errors = sum(item.severity == "error" for item in findings)
    warnings = sum(item.severity == "warning" for item in findings)
    payload = {
        "date": "2026-09-01",
        "version": read(ROOT / "VERSION.txt").strip(),
        "source_units": len(list(SOURCE.rglob("*.pas"))),
        "demo_projects": len(list(DEMOS.rglob("*.dpr"))),
        "checks": checks,
        "summary": {"errors": errors, "warnings": warnings},
        "findings": [asdict(item) for item in findings],
        "note": "Dieser Audit ersetzt keinen Build mit dem Embarcadero-Delphi-Compiler.",
    }
    (BUILD / "RELEASE_AUDIT.json").write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")

    lines = [
        "# Reproduzierbarer Release-Audit",
        "",
        "**Stand:** 1. September 2026  ",
        f"**Version:** {payload['version']}",
        "",
        f"- Source-Units: **{payload['source_units']}**",
        f"- Demo-Projekte: **{payload['demo_projects']}**",
        f"- Harte Befunde: **{errors}**",
        f"- Warnungen: **{warnings}**",
        "",
        "## Prüfungen",
        "",
    ]
    for check, result in checks.items():
        status = f" – {result['status']}" if "status" in result else ""
        lines.append(f"- `{check}`: {result.get('errors', 0)} Fehler, {result.get('warnings', 0)} Warnungen{status}")
    lines += ["", "## Befunde", ""]
    if findings:
        for item in findings:
            location = f":{item.line}" if item.line else ""
            lines.append(f"- **{item.severity.upper()}** `{item.file}{location}` – {item.message}")
    else:
        lines.append("Keine harten oder inhaltlichen Befunde aus den zuverlässig compilerunabhängig prüfbaren Regeln.")
    lines += [
        "",
        "> Der optionale Pascal-Parser ist in dieser Umgebung nicht installiert. Der Audit ersetzt ausdrücklich keinen DCC-/IDE-Build.",
    ]
    (BUILD / "RELEASE_AUDIT.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    return 1 if errors else 0


def main() -> int:
    check_layout()
    check_units_and_paths()
    check_naming()
    check_forms()
    check_factory_and_features()
    check_documented_api()
    check_placeholders_and_version()
    check_method_consistency()
    check_demo_sample_contract()
    check_tree_branch_end_semantics()
    check_adjacent_group_folding_semantics()
    check_optional_parser()
    return write_reports()


if __name__ == "__main__":
    sys.exit(main())
