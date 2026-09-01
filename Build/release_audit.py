#!/usr/bin/env python3
"""Reproduzierbarer, compilerunabhängiger Release-Audit für h5u.Grid.

Der Audit ersetzt keinen Delphi-Build. Er prüft jedoch Quell-/Unit-Namen,
Projektpfade, Form-Ressourcen, Demo-Verdrahtung, Namenskonventionen und einige
hochwertige Konsistenzregeln. tree-sitter-pascal wird optional verwendet.
"""
from __future__ import annotations

import json
import re
import sys
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Iterable

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


def add(severity: str, check: str, path: Path | str, message: str, line: int | None = None) -> None:
    p = Path(path)
    try:
        filename = str(p.resolve().relative_to(ROOT.resolve()))
    except Exception:
        filename = str(path)
    findings.append(Finding(severity, check, filename, message, line))


def text(path: Path) -> str:
    return path.read_text(encoding="utf-8-sig", errors="replace")


def line_no(value: str, pos: int) -> int:
    return value.count("\n", 0, pos) + 1


def finish_check(name: str, before: int) -> None:
    own = findings[before:]
    checks[name] = {
        "errors": sum(x.severity == "error" for x in own),
        "warnings": sum(x.severity == "warning" for x in own),
    }


def iter_code_files() -> Iterable[Path]:
    yield from SOURCE.rglob("*.pas")
    yield from (ROOT / "Packages").rglob("*.dpk")
    yield from DEMOS.rglob("*.pas")
    yield from DEMOS.rglob("*.dpr")


def check_required_layout() -> None:
    name = "required-layout"
    before = len(findings)
    required = [
        "Source/Common/h5u.Grid.Types.pas",
        "Source/Common/h5u.Grid.Factory.pas",
        "Source/Common/h5u.Grid.Selection.pas",
        "Source/Common/h5u.Grid.Columns.pas",
        "Source/Common/h5u.Grid.Options.pas",
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
    ]
    for rel in required:
        if not (ROOT / rel).is_file():
            add("error", name, rel, "Erforderliche Datei fehlt")
    expected = {(p, d) for p in ("VCL", "FMX") for d in ("ClientDataSet", "ObjectList", "VirtualLive")}
    actual: set[tuple[str, str]] = set()
    for dpr in DEMOS.rglob("*.dpr"):
        rel = dpr.relative_to(DEMOS).parts
        if len(rel) >= 3:
            actual.add((rel[0], rel[1]))
    for item in sorted(expected - actual):
        add("error", name, DEMOS / item[0] / item[1], "Erwartetes Demo-Projekt fehlt")
    if len(list(DEMOS.rglob("*.dpr"))) != 6:
        add("error", name, DEMOS, "Es werden exakt sechs Demo-DPRs erwartet")
    finish_check(name, before)


def check_units_and_namespaces() -> None:
    name = "unit-namespaces"
    before = len(findings)
    unit_names: set[str] = set()
    for path in SOURCE.rglob("*.pas"):
        value = text(path)
        match = re.search(r"^\s*unit\s+([^;]+);", value, re.I | re.M)
        if not match:
            add("error", name, path, "Unit-Deklaration fehlt")
            continue
        unit_name = match.group(1).strip()
        unit_names.add(unit_name.lower())
        if unit_name.lower() != path.stem.lower():
            add("error", name, path, f"Unit-Name {unit_name!r} stimmt nicht mit Dateiname überein")
        if path.parent.name == "Common" and re.search(r"\b(?:Vcl|FMX)\.", value, re.I):
            add("error", name, path, "Gemeinsame Unit referenziert einen Plattform-Namensraum")
        if path.parent.name == "Vcl" and re.search(r"\bFMX\.", value, re.I):
            add("error", name, path, "VCL-Unit referenziert FMX")
        if path.parent.name == "FMX" and re.search(r"\bVcl\.", value, re.I):
            add("error", name, path, "FMX-Unit referenziert VCL")
    if (SOURCE / "Common" / "h5u.Grid.pas").exists():
        add("error", name, SOURCE / "Common" / "h5u.Grid.pas", "Name ist für Vcl./FMX.-Fassade reserviert")
    finish_check(name, before)


def check_identifier_casing() -> None:
    name = "identifier-casing"
    before = len(findings)
    for path in list(SOURCE.rglob("*.pas")) + list(DEMOS.rglob("*.pas")) + list(DEMOS.rglob("*.dpr")):
        value = text(path)
        for match in re.finditer(r"\b(?:TH5u|IH5u|EH5u)[A-Za-z0-9_]*", value):
            add("error", name, path, f"Nichtkanonische Schreibweise: {match.group(0)}", line_no(value, match.start()))
    finish_check(name, before)


def check_project_paths() -> None:
    name = "project-paths"
    before = len(findings)
    for path in list((ROOT / "Packages").rglob("*.dpk")) + list(DEMOS.rglob("*.dpr")):
        value = text(path)
        for match in re.finditer(r"\bin\s*['\"]([^'\"]+)['\"]", value, re.I):
            rel = match.group(1).replace("\\", "/")
            target = (path.parent / rel).resolve()
            if not target.is_file():
                add("error", name, path, f"Referenzierte Datei fehlt: {match.group(1)}", line_no(value, match.start()))
        if re.search(r"\{\$R\s+\*\.res\}", value, re.I) and not path.with_suffix(".res").exists():
            add("error", name, path, "{$R *.res} vorhanden, aber Projekt-/Package-RES fehlt")
    finish_check(name, before)


def check_forms() -> None:
    name = "form-resources"
    before = len(findings)
    resources = list(DEMOS.rglob("*.dfm")) + list(DEMOS.rglob("*.fmx"))
    for path in resources:
        value = text(path)
        pas = path.with_suffix(".pas")
        if not pas.is_file():
            add("error", name, path, "Zugehörige Pascal-Unit fehlt")
            continue
        pvalue = text(pas)
        root = re.search(r"^\s*(?:object|inherited|inline)\s+\w+\s*:\s*([\w.]+)", value, re.I | re.M)
        if not root:
            add("error", name, path, "Root-Objekt nicht gefunden")
        else:
            cls = root.group(1).split(".")[-1]
            if not re.search(r"\b" + re.escape(cls) + r"\s*=\s*class\b", pvalue, re.I):
                add("error", name, path, f"Formklasse {cls} fehlt in Pascal-Unit")
        for event in re.finditer(r"^\s*(On[A-Za-z0-9_]+)\s*=\s*([A-Za-z_][A-Za-z0-9_]*)\s*$", value, re.M):
            method = event.group(2)
            if not re.search(r"\b" + re.escape(method) + r"\s*\(", pvalue, re.I):
                add("error", name, path, f"Handler {method} für {event.group(1)} nicht deklariert", line_no(value, event.start()))
        if re.search(r"^\s*FileName\s*=\s*.+$", value, re.I | re.M):
            add("error", name, path, "Externe ClientDataSet-Datei eingetragen")
        if path.parent.name == "ClientDataSet":
            for pattern, message in [
                (r":\s*Th5uSampleClientDataSet\b", "Th5uSampleClientDataSet fehlt"),
                (r":\s*TDataSource\b", "TDataSource fehlt"),
                (r":\s*Th5uDataSetController\b", "Th5uDataSetController fehlt"),
                (r"AutoCreateSampleData\s*=\s*True", "Designer-Musterdaten sind nicht aktiviert"),
                (r"DataSet\s*=\s*\w+", "TDataSource ist nicht mit DataSet verbunden"),
                (r"DataSource\s*=\s*\w+", "DataSet-Controller ist nicht mit TDataSource verbunden"),
                (r"DataController\s*=\s*\w+", "Grid ist nicht mit DataController verbunden"),
            ]:
                if not re.search(pattern, value, re.I):
                    add("error", name, path, message)
    finish_check(name, before)


def check_feature_signatures() -> None:
    name = "feature-signatures"
    before = len(findings)
    requirements: dict[str, list[str]] = {
        "Source/Common/h5u.Grid.Factory.pas": [
            r"Th5uFactoryContext", r"FactoryScope", r"OnGetClass", r"OnCreateInstance", r"OnConfigureInstance",
            r"\bGrid\s*:", r"\bView\s*:", r"\bDataController\s*:", r"\bColumn\s*:", r"\bRowKey\s*:",
        ],
        "Source/Common/h5u.Grid.Selection.pas": [r"SelectedRows", r"SelectedColumns", r"CellRanges", r"MultiRange"],
        "Source/Common/h5u.Grid.Columns.pas": [r"RowSpan", r"ColumnSpan", r"ScrollHintText", r"AutoHeight"],
        "Source/Common/h5u.Grid.Options.pas": [r"WholeRows", r"PixelSnap", r"ThumbHint", r"RowHeight", r"RepeatEvery|Period"],
        "Source/Common/h5u.Grid.SampleData.pas": [r"TClientDataSet", r"AutoCreateSampleData", r"ftBlob", r"PICTURE"],
        "Source/Vcl/Vcl.h5u.Grid.pas": [r"CustomDraw", r"FactoryScope", r"OnGetRowHeight", r"OnGetThumbHint"],
        "Source/FMX/FMX.h5u.Grid.pas": [r"CustomDraw", r"FactoryScope", r"OnGetRowHeight", r"OnGetThumbHint"],
    }
    for rel, patterns in requirements.items():
        path = ROOT / rel
        if not path.exists():
            continue
        value = text(path)
        for pattern in patterns:
            if not re.search(pattern, value, re.I | re.S):
                add("error", name, path, f"Erwartete Prototyp-Signatur fehlt: {pattern}")
    finish_check(name, before)


def check_source_placeholders_and_direct_creates() -> None:
    name = "source-policy"
    before = len(findings)
    create_pattern = re.compile(
        r"\b(Th5u[A-Za-z0-9_]*(?:Column|Cell|Editor|View|Renderer|Painter|Cache|Page|Session|Header|VisibleRow|VisibleColumn|StyleAdapter|MetricsProvider)[A-Za-z0-9_]*)\.Create\s*\(",
        re.I,
    )
    for path in SOURCE.rglob("*.pas"):
        value = text(path)
        for pattern in (r"\bTODO\b", r"\bFIXME\b", r"NotImplemented"):
            for match in re.finditer(pattern, value, re.I):
                add("error", name, path, f"Quellplatzhalter: {match.group(0)}", line_no(value, match.start()))
        for match in create_pattern.finditer(value):
            add("error", name, path, f"Kandidat für direkte Factory-Umgehung: {match.group(1)}.Create", line_no(value, match.start()))
    finish_check(name, before)


def check_method_coverage() -> None:
    """Konservativer Namens-/Anzahlvergleich nicht abstrakter Klassenmethoden."""
    name = "method-coverage"
    before = len(findings)
    for path in SOURCE.rglob("*.pas"):
        value = text(path)
        marker = re.search(r"^\s*implementation\b", value, re.I | re.M)
        if not marker:
            continue
        iface, impl = value[: marker.start()], value[marker.end() :]
        impl_counts: dict[tuple[str, str], int] = {}
        for match in re.finditer(
            r"^\s*(?:class\s+)?(?:procedure|function|constructor|destructor)\s+([A-Za-z_][A-Za-z0-9_]*)\.([A-Za-z_][A-Za-z0-9_]*)\b",
            impl,
            re.I | re.M,
        ):
            key = (match.group(1).lower(), match.group(2).lower())
            impl_counts[key] = impl_counts.get(key, 0) + 1
        source_lines = iface.splitlines()
        i = 0
        while i < len(source_lines):
            start = re.match(r"^\s*(Th5u[A-Za-z0-9_]*)\s*=\s*(class|record)\b(?!\s+of\b)", source_lines[i], re.I)
            if not start:
                i += 1
                continue
            cls, kind = start.group(1), start.group(2).lower()
            depth, j, block = 1, i + 1, []
            while j < len(source_lines):
                current = source_lines[j]
                if re.search(r"=\s*(?:class|record)\b(?!\s+of\b)", current, re.I):
                    depth += 1
                if re.match(r"^\s*end\s*;", current, re.I):
                    depth -= 1
                    if depth == 0:
                        break
                block.append(current)
                j += 1
            declared: dict[tuple[str, str], int] = {}
            k = 0
            while k < len(block):
                method = re.match(
                    r"^\s*(?:class\s+)?(?:procedure|function|constructor|destructor)\s+([A-Za-z_][A-Za-z0-9_]*)\b",
                    block[k],
                    re.I,
                )
                if method:
                    signature, q = block[k].strip(), k + 1
                    while ";" not in signature and q < len(block):
                        signature += " " + block[q].strip()
                        q += 1
                    k = q - 1
                    low = signature.lower()
                    if kind != "interface" and " abstract" not in low and " external" not in low:
                        key = (cls.lower(), method.group(1).lower())
                        declared[key] = declared.get(key, 0) + 1
                k += 1
            for key, count in declared.items():
                have = impl_counts.get(key, 0)
                if have < count:
                    add("error", name, path, f"{cls}.{key[1]}: {count} Deklaration(en), {have} Implementierung(en)")
            i = max(i + 1, j + 1)
    finish_check(name, before)


def check_tree_sitter() -> None:
    name = "tree-sitter-pascal"
    before = len(findings)
    try:
        from tree_sitter import Language, Parser  # type: ignore
        import tree_sitter_pascal  # type: ignore
    except Exception:
        checks[name] = {"errors": 0, "warnings": 1, "status": "optional dependency unavailable"}
        return
    parser = Parser(Language(tree_sitter_pascal.language()))
    for path in SOURCE.rglob("*.pas"):
        data = path.read_bytes()
        tree = parser.parse(data)
        stack = [tree.root_node]
        errors = 0
        first = None
        while stack:
            node = stack.pop()
            if node.type == "ERROR" or node.is_missing:
                errors += 1
                if first is None:
                    first = node
            stack.extend(node.children)
        if errors and first is not None:
            add(
                "error",
                name,
                path,
                f"{errors} Syntaxbaumfehler; erster bei Zeile {first.start_point.row + 1}, Spalte {first.start_point.column + 1}",
                first.start_point.row + 1,
            )
    finish_check(name, before)


def write_reports() -> int:
    errors = sum(x.severity == "error" for x in findings)
    warnings = sum(x.severity == "warning" for x in findings)
    payload = {
        "date": "2026-09-01",
        "root": str(ROOT),
        "source_units": len(list(SOURCE.rglob("*.pas"))),
        "demo_projects": len(list(DEMOS.rglob("*.dpr"))),
        "checks": checks,
        "summary": {"errors": errors, "warnings": warnings},
        "findings": [asdict(x) for x in findings],
        "note": "Dieser Audit ersetzt keinen Build mit dem Embarcadero-Delphi-Compiler.",
    }
    (BUILD / "RELEASE_AUDIT.json").write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
    lines = [
        "# Reproduzierbarer Release-Audit",
        "",
        "**Stand:** 1. September 2026",
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
        extra = f" – {result['status']}" if "status" in result else ""
        lines.append(f"- `{check}`: {result.get('errors', 0)} Fehler, {result.get('warnings', 0)} Warnungen{extra}")
    lines += ["", "## Befunde", ""]
    if findings:
        for item in findings:
            location = f":{item.line}" if item.line else ""
            lines.append(f"- **{item.severity.upper()}** `{item.file}{location}` – {item.message}")
    else:
        lines.append("Keine Befunde.")
    lines += [
        "",
        "> Der Audit ist compilerunabhängig und ersetzt keinen DCC-/IDE-Build. Versionsabhängige VCL-/FMX-API-Unterschiede können nur mit der Zielversion abschließend geprüft werden.",
    ]
    (BUILD / "RELEASE_AUDIT.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    return 1 if errors else 0


def main() -> int:
    check_required_layout()
    check_units_and_namespaces()
    check_identifier_casing()
    check_project_paths()
    check_forms()
    check_feature_signatures()
    check_source_placeholders_and_direct_creates()
    check_method_coverage()
    check_tree_sitter()
    return write_reports()


if __name__ == "__main__":
    sys.exit(main())
