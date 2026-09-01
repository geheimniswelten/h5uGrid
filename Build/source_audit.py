#!/usr/bin/env python3
"""Static consistency checks for the h5u.Grid Delphi prototype.

This is intentionally not a replacement for DCC32/DCC64. It checks the
repository structure, unit/file names, package references, form resources,
known accidental Delphi-incompatible constructs and, when installed,
tree-sitter-pascal syntax diagnostics.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Iterable


@dataclass
class Finding:
    severity: str
    file: str
    line: int
    message: str


UNIT_RE = re.compile(r"(?im)^\s*unit\s+([A-Za-z0-9_.]+)\s*;")
PACKAGE_RE = re.compile(r"(?im)^\s*package\s+([A-Za-z0-9_]+)\s*;")
FORM_CLASS_RE = re.compile(
    r"(?is)\b(T\w+)\s*=\s*class\s*\(\s*T(?:Form|CommonCustomForm)\s*\)"
)
RESOURCE_RE = re.compile(r"\{\$R\s+\*\.((?:dfm)|(?:fmx))\s*\}", re.I)
CONTAINS_PATH_RE = re.compile(
    r"(?im)^\s*([A-Za-z0-9_.]+)\s+in\s+'([^']+)'"
)
USES_PATH_RE = re.compile(
    r"(?im)^\s*([A-Za-z0-9_.]+)\s+in\s+'([^']+)'"
)

KNOWN_BAD_PATTERNS = [
    (re.compile(r"(?m)^\s*begin\s*$\n\s*begin\s*$"),
     "duplicate begin block is likely a Delphi syntax error"),
    (re.compile(r"\bread\s+GetCollection\s*;"), "typed property still reads TCollection.GetCollection"),
    (re.compile(r"\b(?:Max|Min|EnsureRange)\s*<\s*(?:Int64|Integer)\s*>\s*\("),
     "C++-style generic call is not valid for Delphi Math overloads"),
    (re.compile(r"\bAValue\.AsCurrency\b"), "TValue.AsCurrency is not a portable Delphi API"),
    (re.compile(r"\bTH5u[A-Za-z0-9_]*\b"), "public h5u type uses TH5u instead of canonical Th5u spelling"),
]


def line_of(text: str, offset: int) -> int:
    return text.count("\n", 0, offset) + 1


def rel(path: Path, root: Path) -> str:
    return path.relative_to(root).as_posix()



def check_balanced_delimiters(
    text: str,
    path: Path,
    root: Path,
    findings: list[Finding],
) -> None:
    """Check () and [] outside Delphi strings and comments.

    This deliberately stays below the level of a Pascal parser, but catches
    common editing leftovers without depending on third-party packages.
    """
    stack: list[tuple[str, int]] = []
    pairs = {")": "(", "]": "["}
    i = 0
    length = len(text)
    state = "code"
    comment_stack: list[str] = []

    while i < length:
        ch = text[i]
        nxt = text[i + 1] if i + 1 < length else ""

        if state == "string":
            if ch == "'":
                if nxt == "'":
                    i += 2
                    continue
                state = "code"
            i += 1
            continue

        if state == "line-comment":
            if ch in "\r\n":
                state = "code"
            i += 1
            continue

        if state == "comment":
            if ch == "{" and (not comment_stack or comment_stack[-1] == "{"):
                comment_stack.append("{")
                i += 1
                continue
            if ch == "(" and nxt == "*":
                comment_stack.append("(*")
                i += 2
                continue
            if ch == "}" and comment_stack and comment_stack[-1] == "{":
                comment_stack.pop()
                i += 1
                if not comment_stack:
                    state = "code"
                continue
            if ch == "*" and nxt == ")" and comment_stack and comment_stack[-1] == "(*":
                comment_stack.pop()
                i += 2
                if not comment_stack:
                    state = "code"
                continue
            i += 1
            continue

        if ch == "'":
            state = "string"
            i += 1
            continue
        if ch == "/" and nxt == "/":
            state = "line-comment"
            i += 2
            continue
        if ch == "{":
            state = "comment"
            comment_stack = ["{"]
            i += 1
            continue
        if ch == "(" and nxt == "*":
            state = "comment"
            comment_stack = ["(*"]
            i += 2
            continue

        if ch in "([":
            stack.append((ch, i))
        elif ch in ")]":
            if not stack or stack[-1][0] != pairs[ch]:
                findings.append(
                    Finding(
                        "error",
                        rel(path, root),
                        line_of(text, i),
                        f"unmatched delimiter {ch!r}",
                    )
                )
                return
            stack.pop()
        i += 1

    if state == "string":
        findings.append(
            Finding("error", rel(path, root), len(text.splitlines()), "unterminated string literal")
        )
    elif state == "comment":
        findings.append(
            Finding("error", rel(path, root), len(text.splitlines()), "unterminated block comment")
        )
    if stack:
        delimiter, offset = stack[-1]
        findings.append(
            Finding(
                "error",
                rel(path, root),
                line_of(text, offset),
                f"unclosed delimiter {delimiter!r}",
            )
        )

def check_pascal_file(path: Path, root: Path, findings: list[Finding]) -> None:
    text = path.read_text(encoding="utf-8-sig")
    for line_number, line in enumerate(text.splitlines(), 1):
        if len(line) > 180:
            findings.append(Finding("error", rel(path, root), line_number, f"line has {len(line)} characters; maximum is 180"))
        if "\t" in line:
            findings.append(Finding("error", rel(path, root), line_number, "tab character in Pascal source"))
    match = UNIT_RE.search(text)
    if path.suffix.lower() == ".pas":
        if not match:
            findings.append(Finding("error", rel(path, root), 1, "unit declaration not found"))
        else:
            unit_name = match.group(1)
            if unit_name.casefold() != path.stem.casefold():
                findings.append(
                    Finding(
                        "error",
                        rel(path, root),
                        line_of(text, match.start()),
                        f"unit name {unit_name!r} does not match file name {path.stem!r}",
                    )
                )

    check_balanced_delimiters(text, path, root, findings)

    for pattern, message in KNOWN_BAD_PATTERNS:
        for bad in pattern.finditer(text):
            findings.append(
                Finding("error", rel(path, root), line_of(text, bad.start()), message)
            )

    if not re.search(r"(?is)\bend\s*\.\s*$", text):
        findings.append(Finding("error", rel(path, root), len(text.splitlines()), "file does not end with end."))

    # Catch a few common accidental placeholders.
    for token in ("TODO-COMPILE", "FIXME-COMPILE", "<UNRESOLVED>"):
        pos = text.find(token)
        if pos >= 0:
            findings.append(Finding("error", rel(path, root), line_of(text, pos), f"unresolved marker {token}"))


def check_project_paths(path: Path, root: Path, findings: list[Finding]) -> None:
    text = path.read_text(encoding="utf-8-sig")
    base = path.parent
    for unit_name, raw_path in CONTAINS_PATH_RE.findall(text):
        target = (base / raw_path.replace("\\", "/")).resolve()
        if not target.exists():
            findings.append(
                Finding("error", rel(path, root), 1, f"referenced source does not exist: {raw_path}")
            )
            continue
        if target.suffix.lower() == ".pas":
            source = target.read_text(encoding="utf-8-sig")
            unit_match = UNIT_RE.search(source)
            if not unit_match or unit_match.group(1).casefold() != unit_name.casefold():
                findings.append(
                    Finding(
                        "error",
                        rel(path, root),
                        1,
                        f"reference {unit_name!r} does not match declaration in {raw_path}",
                    )
                )


def check_demo(main_pas: Path, root: Path, findings: list[Finding]) -> None:
    text = main_pas.read_text(encoding="utf-8-sig")
    resource = RESOURCE_RE.search(text)
    if not resource:
        findings.append(Finding("error", rel(main_pas, root), 1, "form unit has no {$R *.dfm/fmx} resource"))
        return

    form_resource = main_pas.with_suffix("." + resource.group(1).lower())
    if not form_resource.exists():
        findings.append(
            Finding("error", rel(main_pas, root), 1, f"missing form resource {form_resource.name}")
        )
        return

    class_match = FORM_CLASS_RE.search(text)
    resource_text = form_resource.read_text(encoding="utf-8-sig")
    root_match = re.search(r"(?im)^\s*(?:object|inherited)\s+\w+\s*:\s*(T\w+)", resource_text)
    if class_match and root_match and class_match.group(1).casefold() != root_match.group(1).casefold():
        findings.append(
            Finding(
                "error",
                rel(main_pas, root),
                line_of(text, class_match.start()),
                f"form class {class_match.group(1)} differs from resource root {root_match.group(1)}",
            )
        )

    event_handlers = sorted(set(re.findall(r"(?im)^\s*On\w+\s*=\s*(\w+)\s*$", resource_text)))
    for handler in event_handlers:
        declaration = re.search(
            rf"(?im)^\s*(?:class\s+)?(?:procedure|function)\s+{re.escape(handler)}\b",
            text,
        )
        implementation = re.search(
            rf"(?im)^\s*(?:procedure|function)\s+\w+\.{re.escape(handler)}\b",
            text,
        )
        if not declaration and not implementation:
            findings.append(
                Finding(
                    "error",
                    rel(main_pas, root),
                    1,
                    f"resource event handler {handler!r} is not declared in the form unit",
                )
            )


def run_tree_sitter(root: Path, findings: list[Finding]) -> str:
    try:
        from tree_sitter import Language, Parser
        import tree_sitter_pascal
    except Exception:
        return "not installed"

    try:
        language = Language(tree_sitter_pascal.language())
        parser = Parser(language)
    except Exception as exc:
        return f"unavailable: {exc}"

    # The grammar does not support every Delphi extension. Only missing top-level
    # structure is an error here; detailed parser ERROR nodes are emitted as
    # warnings so the report remains useful without producing false failures.
    for path in sorted(root.rglob("*.pas")):
        data = path.read_bytes()
        tree = parser.parse(data)
        if not tree.root_node.has_error:
            continue

        count = 0
        stack = [tree.root_node]
        while stack and count < 8:
            node = stack.pop()
            if node.type == "ERROR" or node.is_missing:
                row, col = node.start_point
                snippet = data[node.start_byte : min(node.end_byte, node.start_byte + 100)]
                display = snippet.decode("utf-8", "replace").replace("\n", " ")
                findings.append(
                    Finding(
                        "warning",
                        rel(path, root),
                        row + 1,
                        f"tree-sitter diagnostic at column {col + 1}: {display!r}",
                    )
                )
                count += 1
            stack.extend(reversed(node.children))
    return "tree-sitter-pascal"


def write_report(root: Path, findings: list[Finding], parser_name: str) -> None:
    errors = [item for item in findings if item.severity == "error"]
    warnings = [item for item in findings if item.severity == "warning"]
    lines = [
        "# h5u.Grid static source audit",
        "",
        f"- Pascal parser: `{parser_name}`",
        f"- Errors: **{len(errors)}**",
        f"- Warnings: **{len(warnings)}**",
        "",
    ]
    if not findings:
        lines += [
            "All static repository checks passed.",
            "",
            "> This does not replace compilation with the Embarcadero Delphi compiler.",
        ]
    else:
        lines += ["| Severity | File | Line | Finding |", "|---|---|---:|---|"]
        for item in findings:
            message = item.message.replace("|", r"\|")
            lines.append(f"| {item.severity} | `{item.file}` | {item.line} | {message} |")
        lines += [
            "",
            "> Tree-sitter warnings can be false positives for Delphi-specific syntax.",
        ]

    build = root / "Build"
    build.mkdir(exist_ok=True)
    (build / "STATIC_AUDIT.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    (build / "static-audit.json").write_text(
        json.dumps([asdict(item) for item in findings], indent=2, ensure_ascii=False),
        encoding="utf-8",
    )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--strict-parser", action="store_true")
    args = parser.parse_args()
    root = args.root.resolve()

    findings: list[Finding] = []
    for path in sorted(root.rglob("*.pas")):
        check_pascal_file(path, root, findings)
    for path in sorted(root.rglob("*.dpk")):
        check_project_paths(path, root, findings)
    for path in sorted(root.rglob("*.dpr")):
        check_project_paths(path, root, findings)
    for main_pas in sorted((root / "Demos").rglob("Main.pas")):
        check_demo(main_pas, root, findings)

        demo_path = main_pas.as_posix().casefold()
        combined = main_pas.read_text(encoding="utf-8-sig")
        for extension in (".dfm", ".fmx"):
            resource = main_pas.with_suffix(extension)
            if resource.exists():
                combined += "\n" + resource.read_text(encoding="utf-8-sig")
                break

        expected = None
        if "/clientdataset/" in demo_path:
            expected = "Th5uSampleClientDataSet"
        elif "/objectlist/" in demo_path:
            expected = "Th5uObjectListController"
        elif "/virtuallive/" in demo_path:
            expected = "Th5uVirtualController"

        if expected and expected.casefold() not in combined.casefold():
            findings.append(
                Finding(
                    "error",
                    rel(main_pas, root),
                    1,
                    f"demo does not reference expected component {expected}",
                )
            )

    expected_files = [
        "Source/Common/h5u.Grid.Types.pas",
        "Source/Common/h5u.Grid.Factory.pas",
        "Source/Common/h5u.Grid.Columns.pas",
        "Source/Common/h5u.Grid.Selection.pas",
        "Source/Common/h5u.Grid.Options.pas",
        "Source/Common/h5u.Grid.AdjacentGroups.pas",
        "Source/Common/h5u.Grid.Data.Core.pas",
        "Source/Common/h5u.Grid.Data.DataSet.pas",
        "Source/Common/h5u.Grid.Data.Memory.pas",
        "Source/Common/h5u.Grid.Data.Objects.pas",
        "Source/Common/h5u.Grid.Data.Virtual.pas",
        "Source/Common/h5u.Grid.SampleData.pas",
        "Source/Vcl/Vcl.h5u.Grid.pas",
        "Source/FMX/FMX.h5u.Grid.pas",
    ]
    for expected in expected_files:
        if not (root / expected).exists():
            findings.append(Finding("error", expected, 1, "required prototype source is missing"))

    demo_projects = sorted((root / "Demos").rglob("*.dpr"))
    if len(demo_projects) != 6:
        findings.append(
            Finding(
                "error",
                "Demos",
                1,
                f"expected six demo projects, found {len(demo_projects)}",
            )
        )

    parser_name = run_tree_sitter(root, findings)
    write_report(root, findings, parser_name)

    errors = [item for item in findings if item.severity == "error"]
    if args.strict_parser:
        errors += [item for item in findings if item.severity == "warning"]
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
