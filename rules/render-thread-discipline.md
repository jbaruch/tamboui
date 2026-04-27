---
alwaysApply: true
---

# Render Thread Discipline

TamboUI uses a dedicated render thread (the thread running `TuiRunner.run()` / `ToolkitRunner.run()`), similar to JavaFX/Swing. **Why:** single-threaded UI mutation removes the need for locks, makes update ordering predictable, and surfaces wrong-thread access as a clean `IllegalStateException` instead of a flaky race.

## Where Each Callback Runs

- Event handlers, render callbacks, and `Element.render` all run on the render thread — you can mutate UI state freely from inside them
- Scheduled actions via `ToolkitRunner.schedule()`, `scheduleRepeating()`, `scheduleWithFixedDelay()` run on the **scheduler thread**, not the render thread — they must hop back before touching UI
- Any background work you start (network callbacks, executors, watchers) runs on its own thread

## Hop Back to the Render Thread for UI Updates

- From a background or scheduler thread, wrap the UI-mutating portion in `runner.runOnRenderThread(Runnable)` — it executes immediately if already on the render thread, otherwise it queues for the next loop iteration
- Use `runner.runLater(Runnable)` only when you want unconditional deferral (always queued, even from the render thread) — for example, to break a recursive update cycle
- Do the I/O / computation off-thread first, post only the small UI-update piece — do not move the whole task onto the render thread

## Assert Invariants in Custom Code

- In custom widgets, elements, or rendering helpers, call `RenderThread.checkRenderThread()` at entry of methods that mutate shared UI state — it throws with a diagnostic message if violated
- Use `RenderThread.isRenderThread()` for non-asserting checks (e.g., to choose between immediate execution and queueing)
- Thread checks are no-ops when no render thread is set, so unit tests do not need special setup

## Common Failure Modes

- A repeating scheduled task that mutates a `ListState` directly will appear to work in tests and corrupt rendering under load — wrap the mutation in `runOnRenderThread`
- Catching an exception on a background thread and silently dropping it is a data-loss bug; let the exception surface and route real UI updates through the render thread instead
