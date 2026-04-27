---
name: scaffold-toolkit-app
description: Bootstrap a new TamboUI Toolkit DSL application — generates a `ToolkitApp` subclass with a working `render()` and a `main` entry point, plus the right Maven/Gradle/JBang dependencies. Use when the user says "create a TamboUI app", "scaffold a TUI", "new tamboui app", "hello world TamboUI", or asks to start a TUI project from scratch.
---

# Scaffold a Toolkit DSL App

Process steps in order, do not skip ahead. The default API level for new apps is the Toolkit DSL — this skill never picks TuiRunner or Immediate Mode unless the user explicitly asks for them.

## Step 1 — Confirm Scope

- Ask the user (or infer from the request) three things: the **package** (e.g., `com.example.demo`), the **class name** (e.g., `HelloApp`), and the **delivery channel** (JBang single-file, Maven module, or Gradle module)
- If any of the three is missing and the request is ambiguous, ask once with a concrete default; otherwise pick the default and state it in your reply
- Defaults: package `dev.example`, class `HelloApp`, channel JBang

## Step 2 — Choose Dependencies

- Always include `dev.tamboui:tamboui-toolkit` (the DSL) and `dev.tamboui:tamboui-jline3-backend` (a backend is required)
- Pick the version: if the target project already pins a TamboUI version, reuse it; otherwise use the snapshot repo `https://central.sonatype.com/repository/maven-snapshots/` and the latest snapshot
- Do **not** add `tamboui-tui` or `tamboui-widgets` directly — `tamboui-toolkit` already pulls them in

## Step 3 — Write the App Class

- Create the source file at the right path for the chosen channel (JBang: a single `.java` at the chosen location; Maven/Gradle: under `src/main/java/<package-path>/`)
- The class must extend `ToolkitApp` and override `render()` to return a single root `Element` — start with `panel("Title", text("Hello").bold().cyan(), spacer(), text("Press 'q' to quit").dim()).rounded()`
- The `main` method must be `public static void main(String[] args) throws Exception { new ClassName().run(); }`
- Use `import static dev.tamboui.toolkit.Toolkit.*;` so the factory methods are unqualified

## Step 4 — Wire the Build Channel

- **JBang:** add `//DEPS dev.tamboui:tamboui-toolkit:<version>` and `//DEPS dev.tamboui:tamboui-jline3-backend:<version>` at the top of the file; if using snapshots, add `//REPOS central-portal-snapshots` (JBang ≥ 0.136) or the explicit URL
- **Maven:** ensure `pom.xml` declares the snapshot repo and pulls the BOM `dev.tamboui:tamboui-bom`, then `tamboui-toolkit` and `tamboui-jline3-backend` without versions
- **Gradle (Kotlin DSL):** add the snapshot repo with `mavenContent { snapshotsOnly() }`, then `implementation(platform("dev.tamboui:tamboui-bom:<version>"))` and the two artifacts

## Step 5 — Verify the App Builds and Runs

- For JBang: run `jbang <file>` in the user's terminal — TamboUI needs a real TTY, so this must run in an actual terminal, not a Gradle task or IntelliJ Run config
- For Maven/Gradle: build with `mvn -q compile` or `./gradlew -q assemble`; for the run step, instruct the user to invoke the produced JAR from a real terminal (Gradle's daemon has no TTY — see `getting-started.adoc`'s "Running/Debugging" section)
- If any step fails: stop, surface the failure verbatim, do not silently change the dependency version or backend choice — those are the user's call
- Finish here. Do not extend the app with widgets the user did not ask for; this skill only scaffolds the minimum.
