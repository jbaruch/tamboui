# Expose a Histogram Widget in the Declarative DSL

## Problem/Feature Description

The TamboUI codebase has a low-level `Histogram` widget under `tamboui-widgets/src/main/java/dev/tamboui/widgets/histogram/Histogram.java`. The widget renders a vertical histogram with three visually distinct pieces: the filled bar bodies, the count labels printed on top of each bar, and the axis tick labels printed at the bottom.

The widget currently has no entry into the declarative `tamboui-toolkit` module, so users of the DSL cannot drop it into a `panel(...)` or style it through CSS. Your job is to add a `HistogramElement` wrapper in the toolkit, expose it through a Toolkit factory method, and make sure each of the three sub-components can be styled independently — by an explicit Java setter, by a CSS rule, or by a built-in default — with the explicit setter winning over CSS, and CSS winning over the default.

A test class should exercise both the default render and the explicit-style override path.

## Output Specification

Produce:

- `tamboui-toolkit/src/main/java/dev/tamboui/toolkit/element/HistogramElement.java` — the element class.
- An update to `tamboui-toolkit/src/main/java/dev/tamboui/toolkit/Toolkit.java` adding the factory method (assume the file exists with other factory methods).
- `tamboui-toolkit/src/test/java/dev/tamboui/toolkit/element/HistogramElementTest.java` — JUnit 5 test.
- An update to the project's agent-facing documentation file at the repo root so any new sub-component selectors the element exposes are discoverable from the existing per-element documentation index there.

You do not need to actually re-implement the Histogram render logic — instantiating the existing widget with the resolved styles and delegating to its `render(area, buffer)` is fine.
