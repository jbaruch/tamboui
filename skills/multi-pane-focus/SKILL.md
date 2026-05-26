---
name: multi-pane-focus
description: Wire keyboard and mouse focus across multiple panes in a TamboUI Toolkit app — assign stable ids, set the initial focus in `onStart()`, and add a visible focused-pane border via `focusManager.focusedId()`. Use when the user says "add multi-pane focus", "set initial focus on the input", "highlight the focused pane", "tab between panes", "make the prompt focused by default", or asks how to manage focus across panels.
---

# Multi-Pane Focus

Process steps in order, do not skip ahead. The end state is a `ToolkitApp` where each pane has a stable id, the app starts with focus on the user's chosen pane (not the first-registered one), Tab cycles between panes, and the focused pane carries a visible border color the audience can spot from across a room. See `rules/focusable-needs-id.md` for why ids are mandatory, and `rules/projector-safe-colors.md` for the border color choice.

## Step 1 — Inventory the Focusable Panes

- List every pane the user should be able to interact with via keyboard or mouse: typically a chat/trace `ListElement`, an input `textInput(...)`, sometimes a sidebar list
- Decorative panes (titles, dividers, static status bars) are **not** focusable — leave them out of the chain
- Pick one stable id per pane: `"chat"`, `"trace"`, `"prompt"` — short, lowercase, no spaces

## Step 2 — Declare Pane IDs as Constants

- At the top of the `ToolkitApp` class, declare one constant per pane: `private static final String CHAT_ID = "chat";` (Java) or `companion object { const val CHAT_ID = "chat" }` (Kotlin)
- Constants prevent typos between the registration site (`.id(CHAT_ID)`) and the focus-set site (`setFocus(CHAT_ID)`) — typos are silent (no compile error, focus just lands on the wrong pane)

## Step 3 — Wire `.id(...)` and `.focusable()` on Each Pane

- For every pane in the inventory, append `.id(CONSTANT).focusable()` to its builder chain
- See `rules/focusable-needs-id.md` — `.focusable()` without `.id(...)` is dropped from the chain and the pane silently never receives events
- Stateful panes (list, textInput) must also be held as fields, not built inline in `render()` — see `rules/persistent-stateful-elements.md`

## Step 4 — Set Initial Focus in `onStart()`

- Override `onStart()` on the `ToolkitApp` and call `runner()?.focusManager()?.setFocus(<PREFERRED_ID>)`
- The focus manager picks the first-registered pane by default; "first-registered" is an accident of `render()` traversal order, not a user-meaningful default
- For chat/REPL apps, set initial focus to the input pane (`PROMPT_ID`) so the first keystroke goes where the user expects

## Step 5 — Add the Focused-Border Pattern

- In `render()`, look up the current focused id once: `val focused = runner()?.focusManager()?.focusedId()`
- For each pane, compute its border color based on whether `focused == ITS_ID` — focused → a projector-safe saturated color, unfocused → a dimmer-but-still-visible neutral
- Concrete shape:
  ```kotlin
  fun paneBorder(id: String) =
      if (runner()?.focusManager()?.focusedId() == id) Color.GREEN else Color.WHITE
  ```
- Apply via `panel("CHAT", chatList).rounded().borderColor(paneBorder(CHAT_ID))` — recompute each render so it tracks focus changes
- See `rules/projector-safe-colors.md` — do **not** use `Color.GRAY` for the unfocused border on a demo build, it disappears against light projector backgrounds

## Step 6 — Confirm Tab Cycling Works

- Toolkit gives Tab and Shift+Tab cycling for free across the registered focus chain — no extra wiring
- Run the app and confirm: Tab moves the green border to the next pane, Shift+Tab moves it back, and the initially-focused pane is the one you chose in Step 4 (not first-registered)
- If Tab seems stuck on one pane, the other pane likely has `.focusable()` without `.id(...)` — see `rules/focusable-needs-id.md`

## Step 7 — Verify Mouse-Click Focus

- With `mouseCapture(true)` enabled (see `rules/enable-mouse-capture-when-scrollable.md`), clicking inside a pane should move focus to it — Toolkit handles this automatically once panes are in the focus chain
- If click-to-focus does not work, the most likely cause is `mouseCapture` left at its `false` default — add the `configure()` override
- Finish here. Do not introduce per-pane custom Tab handling; Toolkit's built-in chain handles it correctly.
