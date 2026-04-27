---
alwaysApply: true
---

# Pick the API Level

TamboUI exposes four API levels. Picking the right one up front is much cheaper than rewriting later.

## Default to the Toolkit DSL

- New apps start with `ToolkitApp` (or `ToolkitRunner` for more control) and the static-import DSL from `dev.tamboui.toolkit.Toolkit.*`
- The DSL is declarative, retained-mode, with built-in focus management, event routing, and CSS support — the same things you would have to wire by hand at lower levels
- Use `panel`, `row`, `column`, `text`, `list`, `table`, `gauge`, etc. as factory methods; chain styling with `.bold()`, `.cyan()`, `.rounded()`

## Drop to TuiRunner when you need control

- Pick `TuiRunner` when you need a custom event loop, animation ticks at a specific cadence, or to render widgets directly without going through Toolkit elements
- The signature is `(EventHandler, Renderer)` — the handler returns `true` to request a redraw and `false` otherwise; do not redraw on every event

## Use Immediate Mode only for unusual cases

- Reserve `Terminal` + `Backend` direct usage for custom backends, game loops, or learning the rendering model
- It gives full control but no event loop, no error handler, no terminal restoration on crash — you own all of it

## Use Inline Mode for CLI tools

- For build/CLI tools that should preserve scroll history, pick `InlineApp` (declarative) or `InlineToolkitRunner` / `InlineDisplay` (lower-level)
- Inline reserves a fixed status area and lets `println()` scroll output above it — do not use full-screen `TuiRunner` for this pattern, it will take over the terminal

## Do not mix levels casually

- Toolkit elements can be embedded inside a `TuiRunner` callback, and immediate `Frame.buffer()` writes work alongside element rendering — but only mix when you have a real reason
- Mixing without need spreads UI state across abstractions and makes focus, CSS, and event routing harder to reason about
