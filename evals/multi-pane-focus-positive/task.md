# Wire Focus Across a Three-Pane TamboUI Toolkit App

## Problem/Feature Description

You are extending a TamboUI Toolkit app that has three interactive panes side by side: a chat history pane, a trace log pane, and an input prompt at the bottom. The skeleton of the app already exists, but focus management is broken in several user-visible ways:

- When the app starts, the **chat pane** receives keystrokes instead of the **input prompt**. The user has to press Tab once at startup before typing.
- All three panes look identical. The user has no way to tell at a glance which one currently has focus — and on a livestream where the audience is watching, that's worse than no focus at all.
- The user reports that clicking on a pane does nothing — focus stays where it was. Tab does cycle correctly, however.
- A previous attempt to "highlight the focused pane" used a gray border for unfocused panes; reviewers rejected it because the gray border was invisible on a projector at a recent conference talk.

Your job is to fix all four of these issues. The fix should be ergonomic enough that adding a fourth pane later is a one-liner — no per-pane special-case handling.

## Output Specification

Produce a single file `FocusedApp.kt` (or Java equivalent `FocusedApp.java`) containing the relevant slices of the `ToolkitApp` subclass. You do not need to reproduce the full panes — stubs are fine — but you DO need to show:

1. How the three panes are identified for focus purposes.
2. Whatever override(s) you add to fix the "wrong pane focused at startup" issue.
3. Whatever override(s) you add to fix the "no visible focused pane" issue. Show the full `render()` (or its relevant slice) and any helper you introduce.
4. Whatever override(s) you add to fix the "click does not focus" issue.

You may assume the three pane elements (`chatList`, `traceList`, `promptInput`) are already declared as fields elsewhere in the class and are built with the appropriate Toolkit factory methods — you only need to show the parts of their builder chain that pertain to focus.
