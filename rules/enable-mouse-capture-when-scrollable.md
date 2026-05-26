---
alwaysApply: true
---

# Enable Mouse Capture When Using Scrollable Widgets

`TuiConfig.mouseCapture` defaults to `false`, which means mouse-wheel and click events never reach the runner — and therefore never reach `ListElement.handleMouseEvent`, `RichTextAreaElement.handleMouseEvent`, or any other element that already has correct mouse handling. **Why:** without explicit opt-in, "scroll doesn't work" looks like a TamboUI bug when it is actually a missing one-line config override.

## When You Must Override `configure()`

- Any `ToolkitApp` that uses a scrollable widget (`list`, `table`, `tree`, `richTextArea`, scrollable `paragraph`) must override `configure()` and enable mouse capture
- This applies even when keyboard scrolling already works — wheel scroll is the user expectation for log/chat panes, and silent failure here is a livestream-support issue

## The Required Snippet

```kotlin
override fun configure(): TuiConfig =
    TuiConfig.builder().mouseCapture(true).build()
```

(Java equivalent: `return TuiConfig.builder().mouseCapture(true).build();`)

## What You Get For Free

- `ListElement`, `RichTextAreaElement`, and other built-ins already route `SCROLL_UP` / `SCROLL_DOWN` to their internal scroll state — you do not need to wire mouse handlers manually
- Click-to-focus on focusable elements also depends on mouse capture being on — without it, only Tab cycling reaches non-default-focused panes

## When You Can Leave It Off

- Single-pane, single-screen apps with no scroll, no list, no multi-pane focus (e.g., a static status display) — mouse capture is purely overhead there
- The default is `false` deliberately so dashboards that only print text do not eat the terminal's native text selection
