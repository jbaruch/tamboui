# Add JFR Tracing to Toolkit Element Rendering

## Problem/Feature Description

The TamboUI toolkit team wants to give users a way to diagnose rendering performance without invasive logging. Java Flight Recorder (JFR) is the preferred profiling mechanism because it has negligible overhead when no recording is active. The team has identified toolkit element rendering as a high-value operation to instrument: knowing the element type, the render area dimensions, and the time taken would let users pinpoint slow elements in complex layouts.

The project follows strict conventions for how JFR events are structured and emitted, and a new team member needs to add this event correctly so it fits the existing JFR infrastructure in the codebase.

## Output Specification

Produce the following files in your working directory:

1. `ToolkitRenderEvent.java` — the complete JFR event class for tracing toolkit element renders. Include fields for: the element class name (String), the render area width and height (int), and the duration in nanoseconds (long).

2. `build-snippet.txt` — the Gradle `dependencies { }` block snippet showing what needs to be added to `tamboui-toolkit/build.gradle.kts` to support this event class.

3. `call-site-example.java` — a realistic Java code snippet (not a full class, just the relevant method body or block) demonstrating how a caller inside tamboui-toolkit would instrument an existing render method to emit this event. Include a comment in the snippet indicating where the actual render logic would go.

4. `docs-update.md` — a short markdown document listing the changes that should be made to project documentation to register the new event, showing the exact text to add to each file.
