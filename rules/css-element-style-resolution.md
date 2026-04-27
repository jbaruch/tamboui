---
alwaysApply: true
---

# CSS-Aware Element Style Resolution

Toolkit elements that have sub-components (cursor, placeholder, scrollbar thumb, list item, etc.) must let users style them three ways: by explicit Element-API call, by CSS rule, or by the element's built-in default. The order is **explicit > CSS > default**, and the helper that enforces it is `StyledElement.resolveEffectiveStyle()`. **Why:** any element that bakes in `Style.EMPTY` as a default kills the CSS path entirely — the cascade has nothing to override because the explicit value is already set.

## Style Fields Must Be Nullable

- Declare per-child style fields as `private Style cursorStyle;` — leave them `null` by default
- `null` means "use CSS or fall back to the default"; `Style.EMPTY` means "explicitly empty, do not let CSS override" — they are not the same
- Setter methods may pass through `null` (to clear an explicit value) or a real `Style`

## Define Default Style Constants

- One `private static final Style DEFAULT_X_STYLE = ...` per child role (e.g., `DEFAULT_CURSOR_STYLE`, `DEFAULT_PLACEHOLDER_STYLE`)
- These are the fallback when both the explicit field and CSS produce nothing
- Keep them minimal (`Style.EMPTY.reversed()`, `Style.EMPTY.dim()`) so they compose cleanly

## Resolve in renderContent()

- Simple case: `Style effective = resolveEffectiveStyle(context, "cursor", cursorStyle, DEFAULT_CURSOR_STYLE);`
- With pseudo-class: `resolveEffectiveStyle(context, "item", PseudoClassState.ofSelected(), highlightStyle, DEFAULT_HIGHLIGHT_STYLE);`
- The second-argument string is the CSS child-selector suffix (e.g., `ListElement-item` matches `"item"`)

## Document the Selectors

- Add a `<h2>CSS Child Selectors</h2>` block to the element's class JavaDoc listing every selector and its default
- Update the table in `AGENTS.md` ("Available CSS Child Selectors") so other authors can discover it
- Without these two updates, a CSS-aware field is effectively undocumented and will not be used
