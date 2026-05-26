---
alwaysApply: true
---

# Persistent Stateful Elements

Toolkit elements that carry per-instance state (scroll position, selection, cursor, expand/collapse, text-input buffer) must be held as fields on the `ToolkitApp` and re-used across renders. Building a fresh `list(...)`, `table(...)`, `tree(...)`, or `textInput(...)` inside `render()` discards the state every frame. **Why:** the render cycle replaces the element instance, but events targeting the *previous* instance have already mutated its now-orphaned state — from the outside it looks identical to "scroll/selection doesn't work."

## Hold Stateful Elements as Fields, Not Inline Expressions

- Declare each stateful element as a `val` / `final` field on the `ToolkitApp` subclass: `private final ListElement<String> chatList = list().stickyScroll().scrollbar()...;`
- In `render()`, refresh the **content** of that field — `chatList.elements(*chatItems)` or `.items(...)` — rather than calling the factory again
- Same rule for `TableElement`, `TreeElement`, anything ending in `*Element` that exposes a `*State` or a setter for its own collection

## Which Elements Are Stateful

- Any element that holds a `private final *State` field (e.g., `ListState`, `TreeState`, `TextInputState`)
- Any element that exposes scroll, selection, cursor, expand/collapse, or input-buffer behavior
- When in doubt, grep the element source for `State` — if it has one, it is stateful

## Symptom Cheat Sheet

- "Wheel scroll fires but the list snaps back" → element rebuilt every render
- "Selection clears on the next event" → element rebuilt every render
- "Cursor jumps to position 0 after every keystroke" → `textInput()` called inline

## Concrete Replacement Pattern

- Wrong (inline factory):
  ```kotlin
  override fun render() = panel("CHAT",
      list(*chatItems).stickyScroll().scrollbar()
  ).rounded()
  ```
- Right (field + content refresh):
  ```kotlin
  private val chatList = list<String>().stickyScroll().scrollbar()
                                       .id("chat").focusable()

  override fun render() = panel("CHAT",
      chatList.also { it.elements(*chatItems) }
  ).rounded()
  ```
