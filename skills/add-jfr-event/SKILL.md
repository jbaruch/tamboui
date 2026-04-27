---
name: add-jfr-event
description: Add a new Java Flight Recorder event to a TamboUI module following project conventions — `dev.tamboui.AREA.THING` naming, `enabled()` guards, static `commit(...)` helper, and `compileOnly(libs.jfr.polyfill)` for Java 8 modules. Use when the user says "add a JFR event", "trace X with JFR", "instrument Y for flight recorder", or "emit a JFR event for Z".
---

# Add a JFR Event

Process steps in order, do not skip ahead. Every JFR event in TamboUI follows the same five constraints (name, package, `enabled()`, `commit()`, polyfill) — the steps below enforce them.

## Step 1 — Pick the Area and Thing

- Decide the JFR `@Name` as `dev.tamboui.{area}.{thing}` — `{area}` is the module concern (`terminal`, `toolkit`, `css`), `{thing}` is the operation in lowercase, dot- or hyphen-free (`draw`, `route`, `focus.change` is OK if it nests cleanly)
- Decide the Java class name as `{Thing}Event` in PascalCase (e.g., `ToolkitFocusChangeEvent`)
- The class name **may** end in `Event`; the JFR `@Name` **must not** include `Event`

## Step 2 — Pick the Package

- Core events: `dev.tamboui.jfr` (in `tamboui-core`)
- Toolkit events: `dev.tamboui.toolkit.jfr` (in `tamboui-toolkit`)
- Other modules: create `dev.tamboui.{module}.jfr` if no JFR package exists yet, otherwise reuse the existing one

## Step 3 — Define the Event Class

- Extend `jdk.jfr.Event`; annotate with `@Name("dev.tamboui.{area}.{thing}")`, `@Label("Human Readable Label")`, `@Category({"TamboUI", "{Area}"})`, and `@Description("Short description.")`
- Add typed payload fields with `@Label` annotations (e.g., `@Label("Duration") public long durationNanos;`)
- Mark the class `public final` — events are values, not extension points

## Step 4 — Add the enabled() Static Method

- Add `public static boolean enabled() { return EventTypeCache.isEnabled({ThingEvent}.class); }` (or use whatever the rest of `dev.tamboui.jfr` already does — match the existing pattern)
- This method **must** be on the event class itself so callers can short-circuit before allocating; do not put it on a tracer interface

## Step 5 — Add the commit(...) Static Helper

- Add a `public static void commit({payload args}) { var e = new {ThingEvent}(); e.field = arg; ...; e.commit(); }` helper
- Name it `commit` (matching the JDK convention) — not `trace`, not `record`
- Keep the helper minimal: create + populate + commit; no branching, no guards (the guard belongs at the call site, not here)

## Step 6 — Wire the JFR Polyfill (Java 8 Modules Only)

- Open the owning module's `build.gradle.kts` and check the `dependencies { ... }` block
- If it does not already declare `compileOnly(libs.jfr.polyfill)`, add it — without this the module fails to compile under Java 8 source level
- Do not change the runtime classpath; the polyfill is `compileOnly` deliberately

## Step 7 — Update Callers to Use the Guard Pattern

- At every call site, write `if ({ThingEvent}.enabled()) { {ThingEvent}.commit(...); }` — both pieces are required, never one without the other
- Capture timestamps and build payloads **inside** the guard; an unguarded `System.nanoTime()` defeats the point

## Step 8 — Document and Verify

- Add the new event name to the "JFR tracing" event list in the project `README.md` and to `docs/src/docs/asciidoc/tracing.adoc`
- Run `./gradlew -q :{module}:test` to verify the module still builds and existing tests pass
- Run `./gradlew -q javadoc` — TamboUI treats javadoc warnings as errors, and JFR annotations need full coverage
- If you can attach to a running app, verify the event surfaces in JFR with: `jcmd {pid} JFR.start name=tamboui-test settings=profile duration=10s filename=test.jfr` and inspect with `jfr print` — this is optional but recommended
- Finish here.
