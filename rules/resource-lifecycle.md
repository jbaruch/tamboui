---
alwaysApply: true
---

# Resource Lifecycle

A TamboUI app puts the terminal into raw mode, hides the cursor, and (usually) switches to the alternate screen. If the process exits without restoring those, the user's terminal is left broken — no echo, no cursor, no normal scrollback. **Why try-with-resources matters here:** the close path is the only place that restoration is guaranteed to run, including on uncaught exceptions.

## Always Use try-with-resources

- `TuiRunner`, `Backend`, `Terminal`, `InlineDisplay`, `InlineTuiRunner` — all `AutoCloseable`, all must be in a try-with-resources block
- Never assign one to a long-lived field unless you also wire its `close()` into a clear lifecycle (e.g., a CLI shutdown hook); the default is the local try-with-resources
- For immediate-mode setup: open the backend in the resource block, then call `enableRawMode()` and `enterAlternateScreen()` inside the `try` body — close handles the restoration

## Do Not Swallow IOException From the Backend

- Catching and dropping a backend `IOException` leaves the terminal half-configured (raw mode on, alt screen on, cursor hidden) — even if your code returns "successfully"
- If you need to handle a backend failure, log it and let the close path run — never `catch (IOException ignored)`

## Scheduler Ownership

- An internally-created scheduler (the default) is shut down when the runner closes
- An externally-injected scheduler (via `TuiConfig`/`ToolkitConfig`) is **not** shut down — the caller owns its lifecycle
- When sharing a scheduler across multiple `InlineTuiRunner` instances, inject one and shut it down yourself; otherwise the first runner to close will tear down a scheduler other runners are still using

## Error Handlers Are Not a Lifecycle Substitute

- `RenderErrorHandler` (and `RenderErrorHandlers.suppress()`) decide what to *display* when render/event callbacks throw — they do not own terminal restoration
- The runner's `close()` still has to run; the error handler runs inside the loop, the close runs after it exits
