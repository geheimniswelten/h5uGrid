#!/usr/bin/env python3
"""Generate Docs/API-EXTRACT.md from Delphi interface sections."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "Source"
TARGET = ROOT / "Docs" / "API-EXTRACT.md"
VERSION = (ROOT / "VERSION.txt").read_text(encoding="utf-8-sig").strip()

UNIT_RE = re.compile(r"(?im)^\s*unit\s+([^;]+);\s*$")
INTERFACE_RE = re.compile(r"(?im)^\s*interface\s*$")
IMPLEMENTATION_RE = re.compile(r"(?im)^\s*implementation\s*$")


def extract(path: Path) -> tuple[str, str]:
    text = path.read_text(encoding="utf-8-sig")
    unit_match = UNIT_RE.search(text)
    interface_match = INTERFACE_RE.search(text)
    implementation_match = IMPLEMENTATION_RE.search(text)
    if not unit_match or not interface_match or not implementation_match:
        raise RuntimeError(f"Cannot extract public interface from {path}")
    if implementation_match.start() <= interface_match.end():
        raise RuntimeError(f"Invalid interface/implementation order in {path}")
    unit_name = unit_match.group(1).strip()
    body = text[interface_match.end():implementation_match.start()].strip()
    return unit_name, body


def main() -> None:
    units = []
    for path in SOURCE.rglob("*.pas"):
        unit_name, body = extract(path)
        units.append((unit_name.casefold(), unit_name, path, body))
    units.sort(key=lambda item: item[0])

    lines = [
        "# h5u.Grid – öffentlicher API-Auszug",
        "",
        "> Automatisch aus den vollständigen `interface`-Abschnitten des ausgelieferten Quellstands erzeugt. Maßgeblich bleiben die Pascal-Units.",
        "",
        "**Erzeugt:** 1. September 2026  ",
        f"**Version:** {VERSION}",
        "",
    ]
    for _, unit_name, path, body in units:
        relative = path.relative_to(ROOT).as_posix()
        lines.extend([
            f"## `{unit_name}`",
            "",
            f"Quelle: `{relative}`",
            "",
            "```pascal",
            body,
            "```",
            "",
        ])

    TARGET.write_text("\n".join(lines).rstrip() + "\n", encoding="utf-8")
    print(f"Wrote {TARGET.relative_to(ROOT)} for {len(units)} units")


if __name__ == "__main__":
    main()
