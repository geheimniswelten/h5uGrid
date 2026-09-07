#!/usr/bin/env python3
"""Whitespace-only Delphi formatter: 150 columns, properties/signatures 180.

Binary operators begin continuation lines. Literal contents, comments, compiler
directives, BOM and existing line endings are preserved.
"""
from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

from pascal_layout import (
    comment_tokens, indent_case_else, leading_operators, opaque_lines, semantic_tokens,
    reflow_code, tokens, trailing_operator, wrap_code_line,
)

MAX_LINE_LENGTH = 150
MAX_DECLARATION_LENGTH = 180
WIDE_DECLARATIONS = {"property", "routine", "procedural-type"}
PASCAL_SUFFIXES = {".pas", ".dpr", ".dpk", ".inc"}

PROPERTY_START_RE = re.compile(r"^\s*(?:class\s+)?property\b", re.I)
ROUTINE_START_RE = re.compile(
    r"^\s*(?:class\s+)?(?:procedure|function|constructor|destructor|operator)\s+[A-Za-z_&]",
    re.I,
)
PROCEDURAL_TYPE_START_RE = re.compile(
    r"^\s*[A-Za-z_][A-Za-z0-9_]*\s*=\s*(?:reference\s+to\s+)?(?:procedure|function)\b",
    re.I,
)
SPLIT_FIELD_START_RE = re.compile(r"^\s*[A-Za-z_][A-Za-z0-9_,\s]*:\s*$", re.I)
PROPERTY_CLAUSE_RE = re.compile(
    r"\s+(?=(?:read|write|stored|default|nodefault|implements|index|dispid)\b)",
    re.I,
)


@dataclass(frozen=True)
class CandidateBlock:
    start: int
    end: int
    kind: str


def iter_pascal_files(root: Path) -> Iterable[Path]:
    for path in sorted(root.rglob("*")):
        if (
            path.is_file()
            and path.suffix.lower() in PASCAL_SUFFIXES
            and not any(part.lower() in {".git", "__history", "__recovery", "__pycache__", "output", "_dcu", "_bin"}
                        for part in path.relative_to(root).parts)
        ):
            yield path


def classify_start(line: str) -> str | None:
    if PROPERTY_START_RE.match(line):
        return "property"
    if ROUTINE_START_RE.match(line):
        return "routine"
    if PROCEDURAL_TYPE_START_RE.match(line):
        return "procedural-type"
    if SPLIT_FIELD_START_RE.match(line):
        return "field"
    return None


def has_top_level_semicolon(lines: list[str]) -> bool:
    paren_depth = 0
    bracket_depth = 0
    state = "code"
    comment_stack: list[str] = []

    for line in lines:
        i = 0
        while i < len(line):
            ch = line[i]
            nxt = line[i + 1] if i + 1 < len(line) else ""

            if state == "string":
                if ch == "'":
                    if nxt == "'":
                        i += 2
                        continue
                    state = "code"
                i += 1
                continue

            if state == "line-comment":
                break

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
                break
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

            if ch == "(":
                paren_depth += 1
            elif ch == ")":
                paren_depth = max(0, paren_depth - 1)
            elif ch == "[":
                bracket_depth += 1
            elif ch == "]":
                bracket_depth = max(0, bracket_depth - 1)
            elif ch == ";" and paren_depth == 0 and bracket_depth == 0:
                return True
            i += 1

        if state == "line-comment":
            state = "code"

    return False


def find_candidate(lines: list[str], start: int) -> CandidateBlock | None:
    kind = classify_start(lines[start])
    if kind is None:
        return None

    block: list[str] = []
    for end in range(start, min(len(lines), start + 80)):
        line = lines[end]
        if end > start and not line.strip():
            return None
        if end > start and line.lstrip().startswith("//"):
            return None
        block.append(line)
        if has_top_level_semicolon(block):
            return CandidateBlock(start, end, kind)
    return None


def normalize_joined(value: str) -> str:
    literals = [token for token in tokens(value) if token.kind == "string"]
    for i, token in reversed(list(enumerate(literals))):
        value = value[:token.start] + f"\x01{i}\x02" + value[token.end:]
    value = re.sub(r"[ \t]+", " ", value.strip())
    value = re.sub(r"\(\s+", "(", value)
    value = re.sub(r"\[\s+", "[", value)
    value = re.sub(r"\s+\)", ")", value)
    value = re.sub(r"\s+\]", "]", value)
    value = re.sub(r"\s+([,;])", r"\1", value)
    value = re.sub(r"\)\s+:\s*", "): ", value)
    value = re.sub(r"\]\s+:\s*", "]: ", value)
    for i, token in enumerate(literals):
        value = value.replace(f"\x01{i}\x02", token.value)
    return value


def split_routine_chunks(value: str) -> list[str]:
    """Split a routine signature at first-level parameter semicolons.

    The final parameter stays attached to the closing parenthesis, result type
    and directives so a continuation line never consists only of `);`.
    """
    open_pos = value.find("(")
    if open_pos < 0:
        return [value]

    prefix = value[: open_pos + 1]
    chunks = [prefix]
    start = open_pos + 1
    depth = 1
    bracket_depth = 0
    state = "code"
    separators: list[int] = []
    close_pos = -1
    i = open_pos + 1

    while i < len(value):
        ch = value[i]
        nxt = value[i + 1] if i + 1 < len(value) else ""
        if state == "string":
            if ch == "'":
                if nxt == "'":
                    i += 2
                    continue
                state = "code"
            i += 1
            continue
        if ch == "'":
            state = "string"
            i += 1
            continue
        if ch == "[":
            bracket_depth += 1
        elif ch == "]":
            bracket_depth = max(0, bracket_depth - 1)
        elif ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
            if depth == 0:
                close_pos = i
                break
        elif ch == ";" and depth == 1 and bracket_depth == 0:
            separators.append(i)
        i += 1

    if close_pos < 0:
        return [value]

    for separator in separators:
        part = value[start : separator + 1].strip()
        if part:
            chunks.append(part)
        start = separator + 1

    tail = value[start:].strip()
    if tail:
        chunks.append(tail)

    # Empty parameter list: keep the complete signature together.
    if len(chunks) == 2 and chunks[1].startswith(")"):
        return [value]
    return chunks


def split_property_chunks(value: str) -> list[str]:
    parts = [part.strip() for part in PROPERTY_CLAUSE_RE.split(value) if part.strip()]
    return parts or [value]


def split_long_chunk(chunk: str, available: int) -> list[str]:
    return [line.strip() for line in wrap_code_line(chunk, available)]


def declaration_chunks(value: str, kind: str, available: int) -> list[str]:
    if kind in {"routine", "procedural-type"}:
        chunks = split_routine_chunks(value)
    elif kind == "property":
        chunks = split_property_chunks(value)
    else:
        chunks = [value]

    expanded: list[str] = []
    for chunk in chunks:
        if len(chunk) <= available:
            expanded.append(chunk)
        else:
            expanded.extend(split_long_chunk(chunk, available))
    return expanded


def join_chunks(chunks: list[str]) -> str:
    return normalize_joined(" ".join(chunks))


def format_block(block: list[str], kind: str, max_length: int = MAX_DECLARATION_LENGTH) -> list[str]:
    indent = block[0][: len(block[0]) - len(block[0].lstrip())]
    continuation_indent = indent + "  "
    stripped = [line.strip() for line in block if line.strip()]

    # Comments and compiler directives can intentionally define formatting or
    # scope. Leave such declarations untouched.
    if any("//" in line or "{" in line or "(*" in line for line in stripped):
        return block

    value = normalize_joined(" ".join(stripped))
    if len(indent) + len(value) <= max_length:
        return [indent + value]

    chunks = declaration_chunks(value, kind, max_length - len(continuation_indent))
    groups: list[list[str]] = []
    current: list[str] = []
    current_indent = indent

    for chunk in chunks:
        candidate = join_chunks(current + [chunk])
        if current and len(current_indent) + len(candidate) > max_length:
            groups.append(current)
            current = [chunk]
            current_indent = continuation_indent
        else:
            current.append(chunk)
    if current:
        groups.append(current)

    return [
        (indent if index == 0 else continuation_indent) + join_chunks(group)
        for index, group in enumerate(groups)
    ]


def wide_line_indexes(lines: list[str]) -> set[int]:
    indexes: set[int] = set()
    index = 0
    blocked = opaque_lines(lines)
    while index < len(lines):
        candidate = None if index in blocked else find_candidate(lines, index)
        if candidate is None:
            index += 1
            continue
        if candidate.kind in WIDE_DECLARATIONS:
            indexes.update(range(candidate.start, candidate.end + 1))
        index = candidate.end + 1
    return indexes


def line_limits(
    lines: list[str], max_length: int = MAX_LINE_LENGTH,
    declaration_length: int = MAX_DECLARATION_LENGTH,
) -> list[int]:
    wide = wide_line_indexes(lines)
    return [declaration_length if index in wide else max_length for index in range(len(lines))]


def format_lines(
    lines: list[str], max_length: int = MAX_LINE_LENGTH,
    declaration_length: int = MAX_DECLARATION_LENGTH,
) -> tuple[list[str], int]:
    result: list[str] = []
    changed_blocks = 0
    index = 0
    blocked = opaque_lines(lines)
    while index < len(lines):
        candidate = None if index in blocked else find_candidate(lines, index)
        if candidate is None:
            result.append(lines[index].rstrip())
            index += 1
            continue
        original = [line.rstrip() for line in lines[candidate.start:candidate.end + 1]]
        limit = declaration_length if candidate.kind in WIDE_DECLARATIONS else max_length
        formatted = format_block(original, candidate.kind, limit)
        changed_blocks += int(original != formatted)
        result.extend(formatted)
        index = candidate.end + 1

    result = indent_case_else(result)
    protected = wide_line_indexes(result)
    result = leading_operators(result, protected)
    wrapped = reflow_code(result, protected, max_length)

    before, after = "\n".join(lines), "\n".join(wrapped)
    if semantic_tokens(before) != semantic_tokens(after) or comment_tokens(before) != comment_tokens(after):
        raise ValueError("Formatting would change Pascal tokens, literal contents or comments")
    return wrapped, changed_blocks


def check_file(
    path: Path, max_length: int = MAX_LINE_LENGTH,
    declaration_length: int = MAX_DECLARATION_LENGTH,
) -> list[str]:
    lines = path.read_text(encoding="utf-8-sig", errors="strict").splitlines()
    messages: list[str] = []
    limits = line_limits(lines, max_length, declaration_length)
    protected = wide_line_indexes(lines) | opaque_lines(lines)
    for index, (line, limit) in enumerate(zip(lines, limits)):
        if len(line) > limit:
            messages.append(f"{path}:{index + 1}: line has {len(line)} characters (maximum {limit})")
        if index not in protected and trailing_operator(line):
            messages.append(f"{path}:{index + 1}: binary operator must begin the continuation line")
    proposed, _ = format_lines(lines, max_length, declaration_length)
    if proposed != lines:
        messages.append(f"{path}: formatting differs ({max_length}/{declaration_length} limits, continuation operators or CASE/ELSE indentation)")
    return messages


def process_file(path: Path, check: bool, max_length: int, declaration_length: int = MAX_DECLARATION_LENGTH) -> tuple[bool, int, list[str]]:
    if check:
        messages = check_file(path, max_length, declaration_length)
        return bool(messages), 0, messages

    raw = path.read_bytes()
    has_bom = raw.startswith(b"\xef\xbb\xbf")
    text = raw.decode("utf-8-sig")
    newline = "\r\n" if "\r\n" in text else "\n"
    had_final_newline = text.endswith(("\n", "\r"))
    lines = text.splitlines()
    formatted, changed_blocks = format_lines(lines, max_length, declaration_length)
    new_text = newline.join(formatted)
    if had_final_newline:
        new_text += newline
    new_raw = new_text.encode("utf-8-sig" if has_bom else "utf-8")
    changed = new_raw != raw
    if changed:
        path.write_bytes(new_raw)
    return changed, changed_blocks, check_file(path, max_length, declaration_length)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("root", nargs="?", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--check", action="store_true", help="do not write files; fail when formatting differs")
    parser.add_argument("--max-line-length", type=int, default=MAX_LINE_LENGTH)
    parser.add_argument("--max-declaration-length", type=int, default=MAX_DECLARATION_LENGTH)
    args = parser.parse_args()
    if args.max_line_length < 20 or args.max_declaration_length < args.max_line_length:
        parser.error("limits must satisfy 20 <= max-line-length <= max-declaration-length")

    root = args.root.resolve()
    changed_files = 0
    changed_blocks = 0
    messages: list[str] = []

    for path in iter_pascal_files(root):
        changed, blocks, file_messages = process_file(path, args.check, args.max_line_length, args.max_declaration_length)
        changed_files += int(changed)
        changed_blocks += blocks
        messages.extend(file_messages)

    if args.check:
        for message in messages:
            print(message)
        if messages:
            print(f"Pascal formatting check failed with {len(messages)} finding(s).", file=sys.stderr)
            return 1
        print(f"Pascal formatting check passed (code {args.max_line_length}, properties/signatures {args.max_declaration_length}; leading operators).")
        return 0

    for message in messages:
        print(message)
    if messages:
        print("Some lines need manual formatting; literals and directives were preserved.", file=sys.stderr)
        return 1
    print(f"Formatted {changed_blocks} declaration block(s) in {changed_files} file(s); code {args.max_line_length}, properties/signatures {args.max_declaration_length}; leading operators.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
