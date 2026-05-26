---
name: build-log-style-list
description: Build a log-style or chat-style scrollable pane in a TamboUI Toolkit app — `ListElement` configured with no selection highlight, sticky scroll, scrollbar, mouse-wheel capture, focus chain integration, and a pre-wrap helper for long content. Use when the user says "build a log pane", "add a chat pane", "make a scrollable list", "trace pane that auto-scrolls", "tail-style output", or asks how to display many lines of streamed text in a TUI.
---

# Build a Log-Style List

Process steps in order, do not skip ahead. The end state is a `ListElement` held as a field, configured with the log-style defaults (no selection, no highlight symbol, no inverted row), sticky scroll, a visible scrollbar, mouse-wheel capture enabled, focus chain id, and a pre-wrap helper for long content. This skill replaces several traps the default `list(...)` factory leaves open — see `rules/persistent-stateful-elements.md`, `rules/enable-mouse-capture-when-scrollable.md`, `rules/focusable-needs-id.md`, and `rules/pick-the-text-element.md`.

## Step 1 — Decide the Pane Role

- Confirm the pane is log/chat/trace style: many lines stream in, oldest at top, newest at bottom, no "select an item" interaction
- If the pane needs selection (e.g., a file picker or menu), this skill is the wrong fit — use the default `list(...)` instead
- Pick a stable id for the pane (`"chat"`, `"trace"`, `"log"`) — it becomes the focus-chain id and any future CSS selector target

## Step 2 — Hold the List as a Field

- In the `ToolkitApp` subclass, declare the list as a `final` / `val` field: `private final ListElement<String> chatList = list();`
- Inline construction in `render()` is wrong — see `rules/persistent-stateful-elements.md`. A fresh instance every frame loses scroll position and the user-scrolled-away flag
- Hold the backing collection as a separate field too (e.g., `private final List<String> chatLines = new ArrayList<>();`) so background threads can mutate it under `runOnRenderThread`

## Step 3 — Apply the Log-Style Modifiers

- Chain all three defaults-killers, in this exact shape:
  ```kotlin
  list<String>()
      .selected(-1)              // no row is "selected"
      .highlightSymbol("")       // no "> " prefix
      .highlightStyle(Style.EMPTY) // no inverted row colors
  ```
- Skipping any one of the three leaves a visible artifact on the first row that audiences read as a rendering bug
- The default `list(...)` is built for menus; log/chat use needs all three overrides

## Step 4 — Add Scroll and Scrollbar

- Append `.stickyScroll()` so new lines auto-scroll into view unless the user has scrolled away, and `.scrollbar()` so the user has a visible position indicator
- Order does not matter, but match the existing toolkit convention: log-style modifiers first, scroll modifiers second

## Step 5 — Add Focus Chain Integration

- Append `.id("<role>").focusable()` — the id must be stable and unique within the app
- See `rules/focusable-needs-id.md` — `.focusable()` without an id is silently dropped and the pane never receives keyboard or click events
- If the app has only one pane, focus is implicit and you can skip this — but most log-style panes coexist with at least one input pane

## Step 6 — Enable Mouse Capture in `configure()`

- Override `configure()` on the `ToolkitApp` and return `TuiConfig.builder().mouseCapture(true).build()`
- See `rules/enable-mouse-capture-when-scrollable.md` — without this, wheel scroll never reaches `ListElement.handleMouseEvent` and the pane appears broken
- One `configure()` override covers every scrollable pane in the app — you do not repeat the call per element

## Step 7 — Pre-Wrap Long Lines

- Auto-wrap inside a list cell falls back to ellipsis truncation (see `rules/pick-the-text-element.md`) — for variable-width content, pre-wrap into multiple short rows at insert time
- Add a helper `wrap(text: String, width: Int): List<String>` that does greedy word-wrap with a hard-break fallback for tokens longer than `width`
- On append: `chatList.runOnRenderThread { chatLines.addAll(wrap(line, WRAP)); chatList.elements(*chatLines.toTypedArray()) }` — mutate the backing collection, then feed the list

## Step 8 — Verify the Pane Behaves

- Run the app in a real terminal (not Gradle's daemon — no TTY) and confirm: (a) new lines push the view down, (b) wheel scroll stops the auto-scroll until you scroll back to the bottom, (c) the scrollbar tracks the visible window, (d) no inverted first-row stripe is visible
- If any of these fail, re-check the corresponding step — do not paper over with `Style.EMPTY` defaults elsewhere
- Finish here. Do not add selection, sorting, or filtering modifiers — those belong to menu-style lists, not log panes.
