---
alwaysApply: true
---

# Exception Hierarchy

TamboUI exposes a small unchecked exception hierarchy rooted at `dev.tamboui.error.TamboUIException`. Throwing the right subtype lets callers catch what they actually want to handle (terminal I/O vs. framework misuse vs. backend failure) without blanket `catch (RuntimeException)`.

## Pick the Right Subtype

- `RuntimeIOException` — terminal I/O failures; `Terminal` wraps every `IOException` from the backend in this with a descriptive message
- `BackendException` — non-I/O backend failures (native/Panama init, provider lookup, capability detection)
- `TuiException` — TUI framework misuse (render-thread violations, invalid bindings, lifecycle errors)
- Domain-specific (already exist, keep them): `SolverException`, `CssParseException`, `UnknownCssPropertyException`

## Backend vs. Terminal Layer

- The `Backend` interface methods still throw checked `IOException` — backends are low-level
- The `Terminal` layer wraps backend `IOException`s into `RuntimeIOException` so user-facing APIs are unchecked
- If you add a new method to `Terminal`, follow the wrap pattern; if you extend `Backend`, throw `IOException`

## Parameter Validation Uses Standard JDK Exceptions

- `Objects.requireNonNull(value, "fieldName")` for null checks
- `IllegalArgumentException` for invalid argument values
- `IllegalStateException` for invalid object state
- Do not invent a TamboUI subtype for these — the JDK ones are conventional and IDEs surface them well

## Always Include Actionable Context

- Bad: `throw new RuntimeIOException("Error", e);`
- Good: `throw new RuntimeIOException(String.format("Failed to set cursor position to %s: %s", pos, e.getMessage()), e);`
- For backends: `throw new BackendException("Failed to load backend: " + backendName, e);`
- The message should tell a maintainer what was being attempted, with what input — the stack trace already shows where
