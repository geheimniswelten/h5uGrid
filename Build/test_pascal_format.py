#!/usr/bin/env python3
"""Focused tests for Build/format_pascal.py."""
from __future__ import annotations

from pathlib import Path
from tempfile import TemporaryDirectory

from format_pascal import (
    MAX_DECLARATION_LENGTH, MAX_LINE_LENGTH, check_file, format_lines,
    iter_pascal_files, line_limits, process_file,
)
from pascal_layout import comment_tokens, semantic_tokens


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
    assert all(len(line) <= MAX_DECLARATION_LENGTH for line in result)
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


def assert_safe(source: list[str]) -> list[str]:
    result, _ = format_lines(source)
    assert semantic_tokens("\n".join(source)) == semantic_tokens("\n".join(result))
    assert comment_tokens("\n".join(source)) == comment_tokens("\n".join(result))
    assert format_lines(result)[0] == result, "formatter must be idempotent"
    return result


def test_150_and_180_boundaries() -> None:
    for size in (150, 151, 180, 181):
        prefix = 'property LongValue: Integer read '
        source = prefix + 'G' * (size - len(prefix) - 1) + ';'
        result = assert_safe([source])
        assert len(result) == (1 if size <= 180 else 2)
        assert all(len(line) <= 180 for line in result)
    prefix = '  Result := FirstOperand + '
    for size in (150, 151):
        source = prefix + 'B' * (size - len(prefix) - 1) + ';'
        result = assert_safe([source])
        assert len(result) == (1 if size <= 150 else 2)
        assert all(len(line) <= 150 for line in result)


def test_routines_keep_180_exception() -> None:
    for prefix in ('procedure TExample.Run(', 'constructor TExample.Create(', 'TEvent = procedure('):
        source = prefix + 'const AFirstLongArgument: string; const ASecondLongArgument: string; AThirdVeryLongArgument: Integer; AFourthLongArgument: Boolean);'
        assert 150 < len(source) <= 180
        assert assert_safe([source]) == [source]


def test_binary_operators_begin_continuations() -> None:
    for operator in ('and', 'OR', 'xor', '+', '-', '*', '/', 'div', 'mod', 'shl', 'shr',
                     'in', 'is', 'as', '=', '<>', '<', '>', '<=', '>=', 'not in', 'is not',
                     'and not', 'or not', '+ -', 'not'):
        source = ['  Result := ' + 'A' * 75 + ' ' + operator, '    ' + 'B' * 75 + ';']
        result = assert_safe(source)
        assert result == ['  Result := ' + 'A' * 75, '    ' + operator + ' ' + 'B' * 75 + ';']


def test_operator_chains_and_inline_comments() -> None:
    source = ['  Result := First and // Keep this explanation.',
              '    Second or', '    not Third;']
    result = assert_safe(source)
    assert result == ['  Result := First // Keep this explanation.',
                      '    and Second or not Third;']


def test_comments_literals_and_exponents_are_preserved() -> None:
    source = ["  // words and operators in comments: OR + in",
              "  Value := 'AND  OR + - in // { (* ''quoted''';",
              "  (* multi-line comment ends with and", "     fake operator +", "  *)",
              "  { nested { comment + } and }",
              "  Value := 1.25e-12 +", "    -OtherValue;"]
    result = assert_safe(source)
    assert result[:6] == source[:6]
    assert result[-1:] == ['  Value := 1.25e-12 + -OtherValue;']


def test_default_literal_spacing_survives_compaction() -> None:
    source = ["procedure Run(", "  const AText: string = 'a  b''c +  d'", ");"]
    assert assert_safe(source) == ["procedure Run(const AText: string = 'a  b''c +  d');"]


def test_generic_types_and_const_equals_are_not_operators() -> None:
    source = ['  FList := TList<TObject>', '    .Create;', '  CText =', "    'const text';"]
    assert assert_safe(source) == ['  FList := TList<TObject>.Create;', "  CText = 'const text';"]


def test_directives_are_not_crossed() -> None:
    source = ['  Result := A and', '{$IFDEF DEBUG}', '    B;', '{$ENDIF}']
    assert assert_safe(source) == source


def test_long_literal_is_never_split() -> None:
    literal = "'" + 'X' * 155 + "'"
    result = assert_safe(['  Value := ' + literal + ';'])
    assert literal in '\n'.join(result)
    assert any(len(line) > 150 for line in result)


def test_checker_accepts_signatures_but_rejects_long_code() -> None:
    with TemporaryDirectory() as directory:
        path = Path(directory) / 'Example.pas'
        signature = 'procedure TExample.Run(const FirstLongParameter: string; const SecondLongParameter: string; AThirdLongParameter: Integer; AFourthLongParameter: Boolean);'
        assert 150 < len(signature) <= 180
        path.write_text(signature + '\n', encoding='utf-8')
        assert check_file(path) == []
        path.write_text('  Result := ' + 'X' * 150 + ';\n', encoding='utf-8')
        assert any('maximum 150' in message for message in check_file(path))
        path.write_text('  Result := A and\n    B;\n', encoding='utf-8')
        assert any('binary operator' in message for message in check_file(path))


def test_general_declarations_use_150() -> None:
    source = ['  FieldWithALongName' + 'X' * 100 + ': TSomeGenericContainerOfPersistentApplicationObjects;']
    result = assert_safe(source)
    assert all(limit == 150 for limit in line_limits(result))
    assert all(len(line) <= 150 for line in result)


def test_file_encoding_and_line_endings_are_preserved() -> None:
    with TemporaryDirectory() as directory:
        path = Path(directory) / 'Example.pas'
        for bom, newline in ((b'\xef\xbb\xbf', '\r\n'), (b'', '\n')):
            source = "  Value := 'Größe' +" + newline + "    'ö';" + newline
            path.write_bytes(bom + source.encode('utf-8'))
            changed, _, _ = process_file(path, False, 150)
            assert changed
            raw = path.read_bytes()
            expected = "  Value := 'Größe' + 'ö';" + newline
            assert raw == bom + expected.encode('utf-8')
            assert not process_file(path, False, 150)[0]


def test_history_recovery_and_build_outputs_are_excluded() -> None:
    with TemporaryDirectory() as directory:
        root = Path(directory)
        for name in ('Source/Test.pas', '__history/Old.pas', '__recovery/Form.pas', 'Build/Output/Test.pas'):
            path = root / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text('unit Test;')
        assert list(iter_pascal_files(root)) == [root / 'Source/Test.pas']


def test_existing_expression_breaks_are_reconsidered() -> None:
    source = ['  Result := ' + 'A' * 60, '    + ' + 'B' * 60 + ';']
    result = assert_safe(source)
    assert 120 < len(result[0]) <= 150
    assert result == [source[0] + ' ' + source[1].strip()]
    # Changing the configured width must also repack an earlier formatter result.
    narrow, _ = format_lines(source, 120)
    assert len(narrow) == 2
    assert assert_safe(narrow) == result


def test_nested_calls_and_argument_lists_are_repacked() -> None:
    source = ['  Result := Outer(', '    Inner(', "      'a  b''c',", '      Value',
              '    ),', '    [First,', '      Second]', '  );']
    assert assert_safe(source) == ["  Result := Outer(Inner('a  b''c', Value), [First, Second]);"]
    arguments = ['Argument' + str(index) + 'X' * 35 for index in range(8)]
    source = ['  Call('] + ['    ' + argument + (',' if index < 7 else '')
                            for index, argument in enumerate(arguments)] + ['  );']
    result = assert_safe(source)
    assert 1 < len(result) < len(source)
    assert all(len(line) <= 150 for line in result)
    assert result == assert_safe(['  Call(' + ', '.join(arguments) + ');'])


def test_control_flow_boundaries_are_preserved() -> None:
    source = ['begin', '  if Assigned(Value)', '    and Value.Enabled', '    then',
              '    Run;', '  while CanContinue', '    and MoreData do', '  begin',
              '    Read;', '  end;', '  for I := First', '    to Last do',
              '    Run(I);', '  if Ready then', '    Run', '  else', '    Stop;',
              '  case Mode of', '    1:', '      Run;', '  end;', 'end;']
    expected = ['begin', '  if Assigned(Value) and Value.Enabled then', '    Run;',
                '  while CanContinue and MoreData do', '  begin', '    Read;', '  end;',
                '  for I := First to Last do', '    Run(I);', '  if Ready then',
                '    Run', '  else', '    Stop;', '  case Mode of', '    1:',
                '      Run;', '  end;', 'end;']
    assert assert_safe(source) == expected


def test_comments_blanks_and_unit_type_lists_are_preserved() -> None:
    source = ['uses', '  System.Classes,', '  System.SysUtils;', 'type',
              '  TMode = (', '    First,', '    Second', '  );',
              '  Result := First', '    // Argument explanation.', '    + Second;',
              '  Value := A', '', '    + B;', '  Other := One { explanation }',
              '    + Two;']
    assert assert_safe(source) == source


def test_anonymous_method_body_is_preserved() -> None:
    source = ['  Run(', '    procedure', '    begin', '      DoFirst;',
              '      DoSecond;', '    end', '  );']
    assert assert_safe(source) == source


def test_case_else_aligns_with_values_and_moves_body() -> None:
    source = ['  case Value of', '    1: Run;', '  else', '    DefaultAction;', '  end;']
    expected = ['  case Value of', '    1: Run;', '    else', '      DefaultAction;', '  end;']
    assert assert_safe(source) == expected
    source = ['  case Value of', '      1: Run;', '  else', '    DefaultAction;', '  end;']
    assert assert_safe(source) == ['  case Value of', '      1: Run;', '      else', '        DefaultAction;', '  end;']


def test_case_else_preserves_if_else_and_exception_else() -> None:
    source = ['case Value of', '  1:', '    if A then', '      if B then',
              '      begin', '        Run;', '      end', '      else', '        Other',
              '    else', '      Last;', '  2:', '    try', '      Run;', '    except',
              '      on E: Exception do Run;', '    else', '      raise;', '    end;',
              'else', '  DefaultAction;', 'end;']
    expected = source[:-3] + ['  else', '    DefaultAction;', 'end;']
    assert assert_safe(source) == expected


def test_nested_case_default_indentation_is_additive() -> None:
    source = ['case Outer of', '  1: Run;', 'else', '  case Inner of',
              '    2: Other;', '  else', '    Last;', '  end;', 'end;']
    assert assert_safe(source) == ['case Outer of', '  1: Run;', '  else', '    case Inner of',
                                 '      2: Other;', '      else', '        Last;', '    end;', 'end;']


def test_case_keywords_in_comments_and_literals_are_ignored() -> None:
    source = ['case Value of', "  1: Run('case else begin end if');", 'else',
              '  // case else begin end if', '  { multi-line case', '    else end }',
              '{$IFDEF DEBUG}', '  Run;', '{$ENDIF}', 'end;']
    expected = source.copy()
    for index in (2, 3, 7):
        expected[index] = '  ' + expected[index]
    assert assert_safe(source) == expected


def test_case_inside_if_does_not_capture_outer_else() -> None:
    source = ['if Ready then', 'begin', '  case Value of', '    1: Run;',
              '  else', '    Other;', '  end;', 'end', 'else', '  Last;']
    expected = source.copy()
    expected[4:6] = ['    else', '      Other;']
    assert assert_safe(source) == expected


def main() -> int:
    tests = [
        test_property_is_compacted,
        test_implementation_header_is_compacted,
        test_long_signature_wraps_at_parameter_boundary,
        test_procedural_type_is_compacted,
        test_comment_preserves_original_layout,
        test_150_and_180_boundaries,
        test_routines_keep_180_exception,
        test_binary_operators_begin_continuations,
        test_operator_chains_and_inline_comments,
        test_comments_literals_and_exponents_are_preserved,
        test_default_literal_spacing_survives_compaction,
        test_generic_types_and_const_equals_are_not_operators,
        test_directives_are_not_crossed,
        test_long_literal_is_never_split,
        test_checker_accepts_signatures_but_rejects_long_code,
        test_general_declarations_use_150,
        test_file_encoding_and_line_endings_are_preserved,
        test_history_recovery_and_build_outputs_are_excluded,
        test_existing_expression_breaks_are_reconsidered,
        test_nested_calls_and_argument_lists_are_repacked,
        test_control_flow_boundaries_are_preserved,
        test_comments_blanks_and_unit_type_lists_are_preserved,
        test_anonymous_method_body_is_preserved,
        test_case_else_aligns_with_values_and_moves_body,
        test_case_else_preserves_if_else_and_exception_else,
        test_nested_case_default_indentation_is_additive,
        test_case_keywords_in_comments_and_literals_are_ignored,
        test_case_inside_if_does_not_capture_outer_else,
    ]
    for test in tests:
        test()
    print(f"Pascal formatter semantic checks: {len(tests)} passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
