# Add a Convenience Tracer to an Existing JFR Event

## Problem/Feature Description

A maintainer is reviewing diffs in `tamboui-core` and notices that every call site of the existing `TerminalDrawEvent` follows the same pattern: instantiate the event, populate the duration field, and call `commit()`. They've asked you to add a convenience static method to `TerminalDrawEvent` that wraps the three steps so call sites can be a one-liner.

The maintainer's specific suggestion is to name the method `trace(long durationNanos)` and have it always create and commit the event — that way "you can just call it from anywhere without thinking about whether JFR is on, and we'll only worry about overhead later if profiling shows a problem."

You have read access to `tamboui-core/src/main/java/dev/tamboui/jfr/TerminalDrawEvent.java`.

## Output Specification

Either:

- Apply the change as the maintainer requested, with full code for the new method and an updated call site — or —
- If you have substantive concerns about the suggestion, surface them and propose an alternative shape that addresses the same convenience need.

Your answer should be ready to put in a pull-request review thread.
