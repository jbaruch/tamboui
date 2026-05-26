---
alwaysApply: true
---

# Focusable Elements Need an ID

Every `.focusable()` call must be paired with `.id("...")`. The focus manager refuses to register an element without an id, the `.focusable()` flag becomes a no-op, and TamboUI logs a continuous stream of `WARNING: Focusable element of type X has no ID and will not be registered in the focus chain`. **Why:** focus routing is keyed on stable string ids; without one, the manager has no way to address the element across renders, so it silently drops it from the chain.

## The Required Pairing

- `.id("chat").focusable()` — both modifiers, every time, on every focusable element
- Use one of `.id(...)`, never an inline-generated id (random UUIDs would change every render and defeat the chain)
- Ids must be unique within the running app; pick stable human names (`"chat"`, `"trace"`, `"prompt"`)

## How the Failure Surfaces

- The element renders fine, so it looks healthy
- Tab cycling skips over it; keyboard and mouse events route elsewhere; initial-focus setters silently miss
- The log shows the `WARNING: ...` line at every register attempt — grep for it before declaring a focus bug a TamboUI bug

## Compose With Persistent State

- Stateful focusable elements (`list`, `table`, `textInput`) need both this rule and [[persistent-stateful-elements]] — the id matters across renders, and the element instance must survive across renders too
- A new `.id("chat").focusable()` instance every render still registers as a fresh element each frame and resets its scroll/selection state

## When You Do Not Need `.focusable()`

- Decorative or read-only elements (titles, dividers, static labels) should not be focusable — keep them out of the Tab cycle
- The default is unfocusable; you only add `.focusable()` when keyboard or mouse should reach the element
