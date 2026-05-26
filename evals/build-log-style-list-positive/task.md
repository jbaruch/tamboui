# Add a Streaming Output Pane to a TamboUI Toolkit App

## Problem/Feature Description

A developer is building a TamboUI Toolkit app that needs a scrollable pane to display many lines of streamed log output — think `tail -f` inside a TUI. The app already has an input pane elsewhere; the new pane will sit beside it.

The pane must satisfy all of:

- Display the most recent line at the bottom; new lines push older lines up.
- Auto-scroll to follow new output, **unless** the user has scrolled away to look at older lines — in which case the view stays put until they scroll back to the bottom.
- Show a visible scroll-position indicator on the right edge.
- Accept mouse-wheel scrolling, not just keyboard.
- Cooperate with the rest of the app's focus management (the user will Tab between this pane and the input pane).
- Not look like there is a "selected" line in the pane — this is read-only streaming output, not a menu.
- Survive across the framework's re-render cycles without losing the user's scroll position.
- Handle lines longer than the pane's width without truncating them — long lines should appear wrapped across multiple visible rows.

The app uses the declarative Toolkit DSL (the static-import `Toolkit.*` factory methods). Assume the rest of the app — including the input pane, the focus-id constants for that pane, and the top-level layout — already exists.

## Output Specification

Produce a single Kotlin file `LogPane.kt` (or Java equivalent `LogPane.java`) containing the relevant slice of the `ToolkitApp` subclass:

1. The field declaration(s) for the new pane.
2. Any backing-collection field(s) the pane uses.
3. The `render()` slice that places the pane in the layout (just the part that builds the new pane element — the surrounding layout can be elided with a comment).
4. The `configure()` override if one is needed.
5. A helper method (if needed) for adding a new line to the pane from a background thread.

Use a constant `WRAP_WIDTH = 80` wherever a column width is needed.

Do **not** restate the requirements as comments — the code should make the choices visible on its own.
