---
alwaysApply: true
---

# JFR Event Conventions

TamboUI emits Java Flight Recorder events for diagnostics and performance work. The conventions below exist so that JFR overhead stays near-zero when no recording is active and so that event names are stable across modules.

## Naming

- Use `@Name("dev.tamboui.<area>.<thing>")` — for example `dev.tamboui.terminal.draw`, `dev.tamboui.toolkit.route`
- Do **not** include the word `Event` in the `@Name` — the Java class can be `TerminalDrawEvent`, but the JFR-visible name is `dev.tamboui.terminal.draw`
- Core JFR events live under package `dev.tamboui.jfr`; toolkit events under `dev.tamboui.toolkit.jfr`; pick the package by which module owns the event

## Always Guard Emission With enabled()

- Callers must do `if (FooEvent.enabled()) { FooEvent.commit(...); }` — the `enabled()` check is what keeps overhead minimal when no recording is active
- The `enabled()` method must live on the event class itself so callers can short-circuit before allocating any objects, capturing any timestamps, or building any payload
- Never write `new FooEvent().commit()` unguarded — even if the event is disabled, the allocation cost is now in your hot path

## Helper Method Convention

- Prefer a static `commit(...)` helper on the event class over a separate tracer interface
- The helper creates the event, populates it, and calls `Event.commit()` — keeping all three together makes the event self-contained
- Name it `commit(...)` (matching the JDK convention) when it does just create + populate + commit

## Java 8 Compatibility

- Library modules target Java 8, but `jdk.jfr.*` requires the runtime to provide it
- Any module that adds JFR events must declare `compileOnly(libs.jfr.polyfill)` in its Gradle dependencies — without this the module will not compile under the project's Java 8 source level
- Do not depend on the JFR polyfill at runtime; it is `compileOnly` for a reason

## Documentation

- Add new event names to the "JFR tracing" section of the project README and to `docs/src/docs/asciidoc/tracing.adoc` so users can discover them
