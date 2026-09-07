"""Lexical helpers for whitespace-only Delphi source formatting."""
from __future__ import annotations

import re
from bisect import bisect_right
from dataclasses import dataclass

BINARY_OPERATORS = {
    "and", "or", "xor", "in", "is", "as", "div", "mod", "shl", "shr",
    "+", "-", "*", "/", "=", "<>", "<", ">", "<=", ">=",
}
ATOM_RE = re.compile(
    r"&?[A-Za-z_\u0080-\uffff][\w]*|\$[0-9A-Fa-f]+|"
    r"\#(?:\$[0-9A-Fa-f]+|[0-9]+)|"
    r"[0-9]+(?:\.[0-9]+)?(?:[eE][+-]?[0-9]+)?|:=|<=|>=|<>|\.\.|[^\s]"
)


@dataclass(frozen=True)
class Token:
    kind: str
    value: str
    start: int
    end: int


def tokens(text: str) -> list[Token]:
    result = []
    i = 0
    while i < len(text):
        if text[i].isspace():
            i += 1
            continue
        start = i
        kind = "code"
        if text.startswith("//", i):
            end = text.find("\n", i)
            i = len(text) if end < 0 else end
            kind = "comment"
        elif text[i] == "{" or text.startswith("(*", i):
            opener = "{" if text[i] == "{" else "(*"
            kind = "directive" if text.startswith(opener + "$", i) else "comment"
            stack = [opener]
            i += len(opener)
            while i < len(text) and stack:
                close = "}" if stack[-1] == "{" else "*)"
                if text.startswith(close, i):
                    stack.pop()
                    i += len(close)
                elif text.startswith("(*", i):
                    stack.append("(*")
                    i += 2
                elif text[i] == "{":
                    stack.append("{")
                    i += 1
                else:
                    i += 1
        elif text[i] == "'":
            kind = "string"
            i += 1
            while i < len(text):
                if text[i] == "'":
                    i += 1
                    if i < len(text) and text[i] == "'":
                        i += 1
                        continue
                    break
                i += 1
        else:
            match = ATOM_RE.match(text, i)
            assert match is not None
            i = match.end()
        result.append(Token(kind, text[start:i], start, i))
    return result


def semantic_tokens(text: str) -> list[tuple[str, str]]:
    """Keep literal spelling and directive positions; ignore ordinary comments."""
    return [(token.kind, token.value) for token in tokens(text) if token.kind != "comment"]


def comment_tokens(text: str) -> list[str]:
    return [token.value for token in tokens(text) if token.kind == "comment"]


def indent_case_else(lines: list[str]) -> list[str]:
    """Align a CASE default with its labels, preserving nested IF/ELSE pairs."""
    text = "\n".join(lines)
    starts = [0]
    starts.extend(match.end() for match in re.finditer("\n", text))
    stack = []
    shifts = [0] * len(lines)
    blocked = opaque_lines(lines)
    for token in tokens(text):
        if token.kind != "code":
            continue
        word = token.value.lower()
        line = bisect_right(starts, token.start) - 1
        indent = len(lines[line]) - len(lines[line].lstrip())
        if word == "case":
            stack.append({"kind": "case", "indent": indent, "label_indent": None,
                          "header": True, "ifs": 0, "else_line": None})
            continue
        if not stack:
            continue
        frame = stack[-1]
        if word in {"begin", "try", "asm", "record", "repeat"}:
            stack.append({"kind": word})
        elif word == "until" and frame["kind"] == "repeat":
            stack.pop()
        elif word == "end":
            frame = stack.pop()
            if frame["kind"] == "case" and frame["else_line"] is not None:
                first = frame["else_line"]
                old_indent = len(lines[first]) - len(lines[first].lstrip())
                target = frame["label_indent"]
                if target is None:
                    target = frame["indent"] + 2
                for index in range(first, max(first + 1, line)):
                    if index not in blocked and lines[index].strip():
                        shifts[index] += target - old_indent
        elif frame["kind"] == "case":
            if frame["header"]:
                if word == "of":
                    frame["header"] = False
            elif word == "if":
                frame["ifs"] += 1
            elif word == ";":
                frame["ifs"] = 0
            elif word == ":" and frame["label_indent"] is None:
                frame["label_indent"] = indent
            elif word == "else":
                if frame["ifs"]:
                    frame["ifs"] -= 1
                elif frame["else_line"] is None and not text[starts[line]:token.start].strip():
                    frame["else_line"] = line
    result = []
    for line, shift in zip(lines, shifts):
        indent = len(line) - len(line.lstrip())
        result.append(" " * max(0, indent + shift) + line.lstrip() if shift else line)
    return result


def opaque_lines(lines: list[str]) -> set[int]:
    """Protect multiline comments/literals and compiler directives from reflow."""
    result = set()
    text = "\n".join(lines)
    for token in tokens(text):
        if token.kind == "directive" or "\n" in token.value:
            start = text.count("\n", 0, token.start)
            result.update(range(start, start + token.value.count("\n") + 1))
    return result


def trailing_operator(line: str) -> tuple[int, int] | None:
    code = [t for t in tokens(line) if t.kind != "comment"]
    if not code or code[-1].kind != "code":
        return None
    last = code[-1]
    start = last.start
    if last.value.lower() not in BINARY_OPERATORS | {"not"}:
        return None
    # Keep compound operators and following unary operators together.
    for previous in reversed(code[:-1]):
        if previous.kind != "code" or previous.value.lower() not in BINARY_OPERATORS | {"not"}:
            break
        start = previous.start
    # A type/constant declaration's equals sign is not a binary expression.
    if last.value == "=" and re.fullmatch(r"\s*[\w.]+(?:\s*:\s*[\w.]+)?\s*", line[:start]):
        return None
    # Do not mistake a generic type's closing angle bracket for a comparison.
    if last.value in {"<", ">"} and start > 0 and not line[start - 1].isspace():
        return None
    return start, last.end


def leading_operators(lines: list[str], protected: set[int]) -> list[str]:
    result = lines.copy()
    blocked = protected | opaque_lines(lines)
    for i in range(len(result) - 1):
        if i in blocked:
            continue
        span = trailing_operator(result[i])
        if span is None:
            continue
        j = i + 1
        while j < len(result) and not [t for t in tokens(result[j]) if t.kind != "comment"]:
            if j in blocked:
                break
            j += 1
        if j >= len(result) or j in blocked:
            continue
        start, end = span
        operator = result[i][start:end]
        tail = result[i][end:].lstrip()
        result[i] = result[i][:start].rstrip() + (" " + tail if tail else "")
        indent = result[j][:len(result[j]) - len(result[j].lstrip())]
        result[j] = indent + operator + " " + result[j].lstrip()
    return result


STRUCTURAL_WORDS = {
    "begin", "end", "else", "try", "except", "finally", "repeat", "until",
    "var", "const", "type", "uses", "requires", "contains", "label", "asm",
    "interface", "implementation", "initialization", "finalization",
    "private", "protected", "public", "published", "strict",
    "procedure", "function", "constructor", "destructor", "property",
}


def continues_expression(left: str, right: str) -> bool:
    """Recognize expression continuations without merging statements or blocks."""
    before, after = tokens(left), tokens(right)
    if not before or not after:
        return False
    if any(t.kind in {"comment", "directive"} for t in before + after):
        return False
    first, last = before[0].value.lower(), before[-1].value.lower()
    next_first = after[0].value.lower()
    if next_first in STRUCTURAL_WORDS or last in STRUCTURAL_WORDS | {"then", "do", "of", ";"}:
        return False
    if first in STRUCTURAL_WORDS - {"until"}:
        return False
    # Keep type definitions (including enumerations) and declaration lists laid out.
    if re.match(r"^\s*\w+\s*=\s*(?:class|record|interface|dispinterface|packed|array|set|\()", left, re.I):
        return False
    depth = 0
    for token in before:
        if token.kind == "code":
            if token.value in {"(", "["}:
                depth += 1
            elif token.value in {")", "]"}:
                depth -= 1
    if depth > 0:
        return True
    if last == ":":  # A case label starts a new statement, not a continuation.
        return False
    if trailing_operator(left) or last in {":=", "=", "."}:
        return True
    if next_first in BINARY_OPERATORS | {".", "(", "[", ":=", "then", "do"}:
        return True
    # These incomplete statement heads may have been split at ordinary whitespace.
    return any(t.value == ":=" for t in before) or first in {
        "if", "while", "for", "with", "case", "until", "raise", "inherited",
    }


def join_continuation(left: str, right: str) -> str:
    """Change only whitespace at the former line boundary."""
    left, right = left.rstrip(), right.lstrip()
    before, after = tokens(left)[-1], tokens(right)[0]
    tight = before.value in {"(", "[", "."} or after.value in {")", "]", ",", ";", "."}
    return left + ("" if tight else " ") + right


def reflow_code(lines: list[str], protected: set[int], limit: int) -> list[str]:
    """Re-evaluate existing expression/call breaks, then wrap at the new width."""
    blocked = protected | opaque_lines(lines)
    # Unit lists and enum/type layouts are structural lists, not expressions.
    in_unit_list = False
    type_depth = 0
    for index, line in enumerate(lines):
        code = [t.value.lower() for t in tokens(line) if t.kind == "code"]
        if code and code[0] in {"uses", "requires", "contains"}:
            in_unit_list = True
        if in_unit_list:
            blocked.add(index)
            if ";" in code:
                in_unit_list = False
        if re.match(r"^\s*\w+\s*=\s*\(", line):
            type_depth = 0
            blocked.add(index)
            type_depth += code.count("(") - code.count(")")
        elif type_depth > 0:
            blocked.add(index)
            type_depth += code.count("(") - code.count(")")

    result = []
    index = 0
    while index < len(lines):
        current = lines[index]
        if index in blocked:
            result.append(current)
            index += 1
            continue
        index += 1
        while index < len(lines) and index not in blocked and continues_expression(current, lines[index]):
            current = join_continuation(current, lines[index])
            index += 1
        result.extend(wrap_code_line(current, limit))
    return result


def wrap_code_line(line: str, limit: int) -> list[str]:
    """Break at token boundaries, preferring a leading binary operator."""
    if len(line) <= limit:
        return [line]
    indent = line[:len(line) - len(line.lstrip())] + "  "
    result = []
    current = line
    while len(current) > limit:
        lexed = tokens(current)
        preferred, separators, spaces = [], [], []
        for previous, token in zip(lexed, lexed[1:]):
            if token.start > limit or not current[:token.start].strip():
                continue
            if token.kind in {"comment", "directive"} or previous.kind in {"comment", "directive"}:
                continue
            left, right = previous.value.lower(), token.value.lower()
            if left in BINARY_OPERATORS or left == "not":
                continue
            if right in BINARY_OPERATORS or right == "not" or right == "is":
                preferred.append(token.start)
            elif left in {",", ";", "(", "[", ":="}:
                separators.append(token.start)
            elif current[previous.end:token.start].isspace():
                spaces.append(token.start)
        choices = preferred or separators or spaces
        if not choices:
            break  # Report an indivisible token via check_file; never alter it.
        split = max(choices)
        result.append(current[:split].rstrip())
        current = indent + current[split:].lstrip()
    result.append(current)
    return result
