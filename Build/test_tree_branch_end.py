#!/usr/bin/env python3
"""Behavioral model checks for the flattened-tree branch-end band.

The production implementation is Delphi code. These tests pin down the
controller-independent semantics so accidental changes to the lookup rules,
page-boundary handling, or replacement behavior become visible even on a
machine without DCC32/DCC64.
"""

from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class BranchEndResult:
    is_branch_end: bool
    closed_levels: int
    effective_spacing: int


def branch_end(
    levels: list[int],
    index: int,
    *,
    regular_spacing: int = 1,
    band_height: int = 7,
    include_end_of_data: bool = True,
    next_source_level: int | None = None,
) -> BranchEndResult:
    """Reference semantics mirrored by Th5uVclGrid/Th5uFmxGrid.

    ``next_source_level`` models look-ahead across a numbered-page boundary:
    the next row need not belong to the current visible page.
    """
    current = max(0, levels[index])
    if index + 1 < len(levels):
        next_level = max(0, levels[index + 1])
        has_next = True
    elif next_source_level is not None:
        next_level = max(0, next_source_level)
        has_next = True
    else:
        next_level = current
        has_next = False

    is_end = False
    closed = 0
    if current > 0:
        if not has_next:
            is_end = include_end_of_data
            if is_end:
                closed = current
        elif next_level < current:
            is_end = True
            closed = current - next_level

    # The band is an alternative to regular row spacing, never an addition.
    effective = band_height if is_end else regular_spacing
    return BranchEndResult(is_end, closed, effective)


def main() -> int:
    levels = [0, 1, 2, 2, 1, 2, 2, 1, 0]

    assert branch_end(levels, 0) == BranchEndResult(False, 0, 1)
    assert branch_end(levels, 1) == BranchEndResult(False, 0, 1)
    assert branch_end(levels, 2) == BranchEndResult(False, 0, 1)
    assert branch_end(levels, 3) == BranchEndResult(True, 1, 7)
    assert branch_end(levels, 6) == BranchEndResult(True, 1, 7)
    assert branch_end(levels, 7) == BranchEndResult(True, 1, 7)

    # Closing several levels at once reports all closed levels but still draws
    # exactly one replacement band.
    assert branch_end([0, 1, 2, 3, 0], 3) == BranchEndResult(True, 3, 7)

    # A root row is not a child-branch end merely because it is the last row.
    assert branch_end([0], 0) == BranchEndResult(False, 0, 1)

    # The final child may be closed at true end-of-data, and this is optional.
    assert branch_end([0, 1, 2], 2) == BranchEndResult(True, 2, 7)
    assert branch_end(
        [0, 1, 2], 2, include_end_of_data=False
    ) == BranchEndResult(False, 0, 1)

    # Height zero suppresses normal spacing at branch ends rather than falling
    # back to it.
    assert branch_end([0, 1, 0], 1, band_height=0) == BranchEndResult(True, 1, 0)

    # Numbered-page look-ahead: the last visible row of a page is not mistaken
    # for source EOF. A lower level on the next page still closes the branch.
    assert branch_end(
        [0, 1, 2], 2, next_source_level=1
    ) == BranchEndResult(True, 1, 7)
    assert branch_end(
        [0, 1, 2], 2, next_source_level=2
    ) == BranchEndResult(False, 0, 1)

    print("Tree branch-end semantic checks: 12 passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
