#!/usr/bin/env python3
"""Behavioral model checks for adjacent-group folding.

The production implementation is Delphi code. These checks pin down the
controller-independent semantics on machines without DCC32/DCC64:

* only directly consecutive equal IDs share a run;
* a later run with the same ID is independent;
* collapsing keeps the first row and hides only the following rows;
* the optional end band replaces regular row spacing;
* its visibility can be Never, CollapsedOnly, ExpandedOnly or Always.
"""

from __future__ import annotations

from dataclasses import dataclass
from enum import Enum


class EndBandVisibility(Enum):
    NEVER = "never"
    COLLAPSED_ONLY = "collapsed-only"
    EXPANDED_ONLY = "expanded-only"
    ALWAYS = "always"


@dataclass
class Run:
    group_id: object
    first: int
    last: int
    collapsed: bool = False

    @property
    def count(self) -> int:
        return self.last - self.first + 1

    @property
    def foldable(self) -> bool:
        return self.count > 1


def build_runs(ids: list[object]) -> list[Run]:
    if not ids:
        return []
    result: list[Run] = []
    first = 0
    for index in range(1, len(ids) + 1):
        if index == len(ids) or ids[index] != ids[first]:
            result.append(Run(ids[first], first, index - 1))
            first = index
    return result


def visible_rows(runs: list[Run]) -> list[int]:
    result: list[int] = []
    for run in runs:
        result.append(run.first)
        if not run.collapsed:
            result.extend(range(run.first + 1, run.last + 1))
    return result


def show_end_band(run: Run, mode: EndBandVisibility) -> bool:
    if not run.foldable:
        return False
    if mode is EndBandVisibility.NEVER:
        return False
    if mode is EndBandVisibility.COLLAPSED_ONLY:
        return run.collapsed
    if mode is EndBandVisibility.EXPANDED_ONLY:
        return not run.collapsed
    return True


def effective_spacing(
    run: Run,
    mode: EndBandVisibility,
    *,
    regular_spacing: int = 1,
    band_height: int = 7,
) -> int:
    # The band is an alternative, never an addition to regular row spacing.
    return band_height if show_end_band(run, mode) else regular_spacing


def main() -> int:
    ids = [1, 1, 1, 2, 3, 3, 1, 1, 1, 4]
    runs = build_runs(ids)
    assert [(r.group_id, r.first, r.last) for r in runs] == [
        (1, 0, 2),
        (2, 3, 3),
        (3, 4, 5),
        (1, 6, 8),
        (4, 9, 9),
    ]

    # Same ID later creates a separate independently foldable run.
    assert runs[0].group_id == runs[3].group_id
    assert runs[0].first != runs[3].first

    runs[0].collapsed = True
    assert visible_rows(runs) == [0, 3, 4, 5, 6, 7, 8, 9]
    runs[3].collapsed = True
    assert visible_rows(runs) == [0, 3, 4, 5, 6, 9]
    runs[0].collapsed = False
    assert visible_rows(runs) == [0, 1, 2, 3, 4, 5, 6, 9]

    expanded = Run(7, 10, 12, collapsed=False)
    collapsed = Run(7, 10, 12, collapsed=True)
    singleton = Run(8, 13, 13, collapsed=False)

    assert not show_end_band(expanded, EndBandVisibility.NEVER)
    assert not show_end_band(expanded, EndBandVisibility.COLLAPSED_ONLY)
    assert show_end_band(collapsed, EndBandVisibility.COLLAPSED_ONLY)
    assert show_end_band(expanded, EndBandVisibility.EXPANDED_ONLY)
    assert not show_end_band(collapsed, EndBandVisibility.EXPANDED_ONLY)
    assert show_end_band(expanded, EndBandVisibility.ALWAYS)
    assert show_end_band(collapsed, EndBandVisibility.ALWAYS)
    assert not show_end_band(singleton, EndBandVisibility.ALWAYS)

    assert effective_spacing(
        expanded,
        EndBandVisibility.EXPANDED_ONLY,
        regular_spacing=1,
        band_height=7,
    ) == 7
    assert effective_spacing(
        collapsed,
        EndBandVisibility.EXPANDED_ONLY,
        regular_spacing=1,
        band_height=7,
    ) == 1
    assert effective_spacing(
        collapsed,
        EndBandVisibility.COLLAPSED_ONLY,
        regular_spacing=3,
        band_height=0,
    ) == 0

    print("Adjacent-group-folding semantic checks: 16 passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
