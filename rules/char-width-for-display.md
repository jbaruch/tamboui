---
alwaysApply: true
---

# Use CharWidth for Display Widths

Java's `String.length()` returns UTF-16 code units, **not** terminal display columns. A CJK character is one code unit but two columns wide, an emoji is two code units and two columns, and a ZWJ family glyph can be five code units and two columns. Using `length()` or `substring()` for terminal layout produces visible breakage: misaligned tables, half-rendered glyphs, off-by-N truncation, garbled scroll regions.

## The Required Replacements

- For width: `CharWidth.of(text)` — returns the display column count
- For display-aware truncation: `CharWidth.substringByWidth(text, maxWidth)` (from start), `CharWidth.substringByWidthFromEnd(text, w)` (from end)
- For ellipsized truncation: `CharWidth.truncateWithEllipsis(text, w, position)`
- For a single code point: `CharWidth.of(int codePoint)`

## What Counts as a Display-Width Use

- Computing a column count for layout, alignment, padding, or buffer placement
- Truncating text that will land in a `Buffer` cell, in a widget render path, or in a status string sent to the terminal
- Comparing string sizes against an `Rect` width, a `Constraint`, or an inline-display width

## What Does NOT Need CharWidth

- Index arithmetic on input that is guaranteed ASCII (e.g., parsing a config key) — `length()` is fine there
- Logging, JSON serialization, file I/O — those are not terminal display surfaces
- When in doubt about user-provided text, default to `CharWidth`

## Reference Implementation

- `Paragraph.java` shows the correct pattern for line-breaking and truncation; copy from it rather than inventing a new approach
- For new widgets, mirror Paragraph's loop structure: walk grapheme clusters, accumulate width, break on the cell boundary returned by `CharWidth`
