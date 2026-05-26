---
alwaysApply: true
---

# Pick the Right Text Element

Toolkit offers several factories for "show some text" — `text`, `richText`, `richTextArea`, `markupText`, and the cell-content path inside `list`. Each computes its preferred size differently, so choosing the wrong one produces clipped output, ellipsis truncation, or a column layout that shrinks every line to height 1. **Why:** in a `column(...)` or `panel(...)`, parent layout calls `preferredSize(width)` on each child to allocate rows — and only some text elements actually wrap to compute their real height.

## Decision Tree

- One short, unwrapped line (status, label, title) → `text("...")` — fastest, no wrap, no width math
- Inline styled spans on a single line (mixed colors / bold / dim within one row) → `richText(...)` — height is always 1, content past the width clips
- Multi-line content that must wrap to fit available width → `richTextArea(...)` — `preferredSize` computes the wrapped height, so column layouts give it the rows it needs
- Markdown-flavored short blurbs (bold/italic/inline-code markers) → `markupText(...)` — height behaves like `richText`, do not use for long content
- One item per row in a scrollable surface → `list(...)` — pre-wrap long strings into multiple short items (see [[build-log-style-list]])

## The Wrap-Height Trap

- `RichTextElement.preferredSize(width)` returns `text.height() = 1` regardless of `.wrapWord()` — the modifier sets a flag the size calculation never reads
- Inside a `column(...)` each `richText(...)` child gets exactly one row; long content truncates with ellipsis even when the column has empty rows below
- Fix is always the same: switch to `richTextArea(...)` (which computes wrapped height), or pre-wrap the string yourself and feed multiple `text` lines

## Container-Only Constraints

- `text(...)` returns a `TextElement` whose `.constraint()` is a zero-arg getter — there is no setter overload, so you cannot give a bare line a fixed height in a column layout
- The compile error reads: `Argument type mismatch: actual type is 'Constraint!', but 'Element!' was expected. Too many arguments for 'fun constraint(): Constraint!'.`
- Wrap in a container that does accept `.constraint(...)`: `row(text("..."))` or `column(text("..."))` — containers are where sizing constraints live

## Stop Patterns

- A `richText` clipped with `…` inside a `panel` — switch to `richTextArea` or pre-wrap
- A `text("...").constraint(length(3))` compile error — wrap in `row(...)` or `column(...)`
- Auto-wrap inside a `list` cell falling back to ellipsis — pre-wrap into multiple list items (see [[build-log-style-list]])
