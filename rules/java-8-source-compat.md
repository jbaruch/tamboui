---
alwaysApply: true
---

# Java 8 Source Compatibility

TamboUI's library modules (`tamboui-core`, `tamboui-widgets`, `tamboui-toolkit`, `tamboui-tui`, the backends, etc.) target **Java 8 source compatibility** so they can run on any modern JVM, including embedded scenarios. Demos and tooling are free to use newer Java. **Why:** dropping Java 8 here would lock out users on long-LTS deployments without their consent — and the cost of staying on Java 8 in the library is small.

## What Library Code Can Use

- All Java 8 language features: lambdas, method references, streams, default/static interface methods, `Optional`
- Standard library APIs available in Java 8 (`java.util.function`, `java.time`, `Collectors`, etc.)
- Immutable data structures via `Collections.unmodifiable*`, `Arrays.asList`, builder patterns

## What Library Code Must NOT Use

- `var` (Java 10), text blocks (Java 15), `record` (Java 16), `sealed` classes (Java 17), pattern matching for `instanceof` and `switch`
- `List.of`, `Map.of`, `Set.of` (Java 9) — use `Collections.unmodifiableList(Arrays.asList(...))` instead
- Any `java.util.*` API added after Java 8 (`Stream.toList`, `String.lines`, `Files.mismatch`, etc.)

## Demos and Tooling Are Different

- Demo modules under `demos/` should use Java 21 idioms — pattern matching, records, switch expressions, `var` — they exist to showcase modern Java
- The `tamboui-processor` module and build scripts can also use newer Java if useful
- Do not let demo idioms bleed into library modules during refactors

## Verifying

- `./gradlew -q assemble` will fail if a library module uses a too-new feature
- `./gradlew -q javadoc` must also pass before considering a change done — TamboUI treats javadoc warnings as errors
