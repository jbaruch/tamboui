---
name: wrap-widget-as-element
description: Add a Toolkit `Element` wrapping an existing TamboUI widget so it gains CSS support, styled sub-components, focus integration, and a Toolkit factory method. Use when the user says "wrap a widget", "add an element for X widget", "make widget Y CSS-aware", "expose widget Z in the DSL", or asks to integrate a custom widget into the Toolkit.
---

# Wrap a Widget as a Toolkit Element

Process steps in order, do not skip ahead. The end state is an Element class that goes through `resolveEffectiveStyle` for every sub-component, with a Toolkit factory method, JavaDoc-documented CSS selectors, and tests that assert against `BufferAssertions`.

## Step 1 — Identify the Widget and Its Styled Sub-Components

- Locate the widget under `tamboui-widgets/src/main/java/dev/tamboui/widgets/{area}/` and read its `render` method to enumerate every visually distinct piece (e.g., for a Gauge: filled bar, label; for a List: items, scrollbar thumb/track)
- Each sub-component becomes one CSS child selector; pick a short stable name (e.g., `filled`, `unfilled`, `cursor`, `placeholder`, `item`, `header`)
- Run `scripts/list-tamboui-modules.sh` to confirm the toolkit module path, then list `tamboui-toolkit/src/main/java/dev/tamboui/toolkit/element/` for any existing `{Name}Element.java` — if one exists, stop and tell the user; the right move is to extend the existing Element, not write a duplicate

## Step 2 — Create the Element Class

- Create `tamboui-toolkit/src/main/java/dev/tamboui/toolkit/element/<Name>Element.java` extending `StyledElement` (or another existing element base if the widget is stateful)
- Constructor takes the widget's required inputs as parameters; optional configuration goes through fluent setters that return `this`
- Field declarations come first, then constructor, then setters, then `renderContent` last — match the existing element files

## Step 3 — Declare Nullable Style Fields and Defaults

- For each sub-component identified in Step 1, add `private Style <name>Style;` (nullable, no initializer) and `private static final Style DEFAULT_<NAME>_STYLE = ...;`
- Defaults should be minimal: `Style.EMPTY` plus a single modifier like `.reversed()` or `.dim()` — they compose with whatever the user adds
- **Do not** initialize the field to `Style.EMPTY` — that breaks CSS resolution; see `rules/css-element-style-resolution.md`
- Add a fluent setter for each: `public <Name>Element <name>Style(Style s) { this.<name>Style = s; return this; }`

## Step 4 — Implement renderContent Using resolveEffectiveStyle

- Inside `renderContent(RenderContext context, Rect area, Buffer buffer)`, resolve every sub-component style via `resolveEffectiveStyle(context, "<name>", <name>Style, DEFAULT_<NAME>_STYLE)` (or the pseudo-class overload for selected/focused state)
- Then either render directly to the buffer using the resolved styles, or instantiate the widget, configure it with the resolved styles, and call `widget.render(area, buffer)` — pick whichever is less duplication
- Honor `RenderThread.checkRenderThread()` if the element holds mutable state — `StyledElement` already does this, but custom render helpers may not

## Step 5 — Add the Toolkit Factory Method

- Open `dev/tamboui/toolkit/Toolkit.java` and add a `public static <Name>Element <name>(...)` method that constructs and returns the element
- The method name is the lower-camel-case widget name (e.g., `gauge`, `barChart`, `lineGauge`); match the table in the project README
- Place the new method alphabetically among existing factories; do not reorder unrelated entries

## Step 6 — Document the CSS Selectors

- In the Element class JavaDoc, add a `<h2>CSS Child Selectors</h2>` block listing each `<ElementName>-<name>` selector and its default
- Update the "Available CSS Child Selectors" table in `AGENTS.md` with one new row
- Add a brief widget entry to `docs/src/docs/asciidoc/widgets.adoc` if the widget itself is new; if the widget already exists, mention only the new Element wrapper

## Step 7 — Write Tests Using BufferAssertions

- Create `tamboui-toolkit/src/test/java/dev/tamboui/toolkit/element/<Name>ElementTest.java` using JUnit 5
- At minimum: render at a fixed `Rect`, assert the buffer contents with `BufferAssertions`, then assert that an explicit style overrides the default and (if you have a TCSS test fixture) that a CSS rule overrides the default but is overridden by an explicit setter
- Test data is fixed — never randomize; see `testing-standards.md` from the user's coding-policy tile

## Step 8 — Verify Locally

- Run `./gradlew -q :tamboui-toolkit:test` and then `./gradlew -q javadoc` — both must pass
- If the new element introduces a public type, also run `./gradlew -q assemble` to confirm Java 8 source compatibility
- Run `scripts/check-display-width.sh` (it emits JSON candidates) and triage any new entries against `rules/char-width-for-display.md` — false positives are expected, but a real violation in your render path means a glyph-width bug
- If any check fails, stop and surface the failure — do not paper over it by widening exception handlers or reducing assertions
- Finish here.
