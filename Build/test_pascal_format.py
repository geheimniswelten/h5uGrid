#!/usr/bin/env python3
"""Focused tests for Build/format_pascal.py."""
from __future__ import annotations

from format_pascal import MAX_LINE_LENGTH, format_lines


def apply(value: str) -> list[str]:
    result, _ = format_lines(value.strip("\n").splitlines(), MAX_LINE_LENGTH)
    return result


def test_property_is_compacted() -> None:
    result = apply(
        """
    property PreserveStateOnDataChange: Boolean
      read FPreserveStateOnDataChange
      write SetPreserveStateOnDataChange default True;
"""
    )
    assert result == [
        "    property PreserveStateOnDataChange: Boolean read FPreserveStateOnDataChange write SetPreserveStateOnDataChange default True;"
    ]


def test_implementation_header_is_compacted() -> None:
    result = apply(
        """
procedure TFoo.SetValue(
  const AName: string;
  AValue: Integer
);
"""
    )
    assert result == ["procedure TFoo.SetValue(const AName: string; AValue: Integer);"]


def test_long_signature_wraps_at_parameter_boundary() -> None:
    result = apply(
        """
procedure TFoo.DrawSomething(
  const ABounds: TRect;
  AElementKind: TLongElementKind;
  AColumn: TVeryLongColumnClassName;
  AViewRowIndex: Int64;
  const ARowKey: TVeryLongStableRowKey;
  AColor: TVeryLongPlatformIndependentColor;
  const AStyleName: string;
  ATreeLevel: Integer;
  AClosedTreeLevels: Integer
);
"""
    )
    assert len(result) > 1
    assert all(len(line) <= MAX_LINE_LENGTH for line in result)
    assert result[0].startswith("procedure TFoo.DrawSomething(")
    assert result[-1].endswith(");")
    assert result[-1].strip() != ");"


def test_procedural_type_is_compacted() -> None:
    result = apply(
        """
  TChangedEvent = procedure(
    Sender: TObject;
    const AName: string;
    var AAccepted: Boolean
  ) of object;
"""
    )
    assert result == [
        "  TChangedEvent = procedure(Sender: TObject; const AName: string; var AAccepted: Boolean) of object;"
    ]


def test_comment_preserves_original_layout() -> None:
    source = [
        "procedure TFoo.SetValue(",
        "  // Intentionally documented parameter layout.",
        "  AValue: Integer",
        ");",
    ]
    result, _ = format_lines(source, MAX_LINE_LENGTH)
    assert result == source


def main() -> int:
    tests = [
        test_property_is_compacted,
        test_implementation_header_is_compacted,
        test_long_signature_wraps_at_parameter_boundary,
        test_procedural_type_is_compacted,
        test_comment_preserves_original_layout,
    ]
    for test in tests:
        test()
    print(f"Pascal formatter semantic checks: {len(tests)} passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
