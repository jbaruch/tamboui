# jbaruch/tamboui

[![tessl](https://img.shields.io/endpoint?url=https%3A%2F%2Fapi.tessl.io%2Fv1%2Fbadges%2Fjbaruch%2Ftamboui)](https://tessl.io/registry/jbaruch/tamboui)

A [tessl](https://tessl.io) tile that teaches AI coding agents how to use the [TamboUI](https://github.com/tamboui/tamboui) Java terminal-UI library without falling into its sharp edges (render-thread discipline, terminal display widths, CSS-aware element styling, JFR-event conventions).

This repo is the standalone home of the tile. The TamboUI library itself lives at [tamboui/tamboui](https://github.com/tamboui/tamboui).

## Install

```bash
tessl install jbaruch/tamboui
```

Run this from your TamboUI consumer project (or from the TamboUI repo itself if you're contributing). The rules apply automatically; the skills are invoked on demand.

## Rules

| Rule | What it enforces |
|------|------------------|
| [pick-the-api-level](rules/pick-the-api-level.md) | Default to Toolkit DSL; drop to TuiRunner / Immediate / Inline only when needed. |
| [render-thread-discipline](rules/render-thread-discipline.md) | All UI mutations on the render thread; use `runOnRenderThread` from background threads. |
| [char-width-for-display](rules/char-width-for-display.md) | Never use `String.length()` / `substring` for terminal widths — use `CharWidth`. |
| [exception-hierarchy](rules/exception-hierarchy.md) | Throw the right `TamboUIException` subtype with actionable context. |
| [resource-lifecycle](rules/resource-lifecycle.md) | Always try-with-resources for `TuiRunner`, `Backend`, `InlineDisplay`. |
| [css-element-style-resolution](rules/css-element-style-resolution.md) | Nullable style fields + `resolveEffectiveStyle` for CSS-aware elements. |
| [jfr-event-conventions](rules/jfr-event-conventions.md) | Naming, `enabled()` guards, `commit(...)` helpers, JFR polyfill for Java 8. |
| [java-8-source-compat](rules/java-8-source-compat.md) | Library modules are Java 8; demos can use Java 21+. |

## Skills

| Skill | When to use |
|-------|-------------|
| [scaffold-toolkit-app](skills/scaffold-toolkit-app/SKILL.md) | Bootstrap a new TUI app using the Toolkit DSL. |
| [wrap-widget-as-element](skills/wrap-widget-as-element/SKILL.md) | Add a Toolkit `Element` wrapping a widget, with proper CSS child-selector support. |
| [add-jfr-event](skills/add-jfr-event/SKILL.md) | Add a new JFR event under `dev.tamboui.{area}` with the project's conventions. |

## Scripts

The tile ships two helper scripts under `scripts/`. After install they live at `.tessl/tiles/jbaruch/tamboui/scripts/` in your workspace; both accept a path argument for the TamboUI repo root.

| Script | What it does |
|--------|--------------|
| [`scripts/list-tamboui-modules.sh`](scripts/list-tamboui-modules.sh) | Lists Gradle modules from `settings.gradle.kts` as JSON. |
| [`scripts/check-display-width.sh`](scripts/check-display-width.sh) | Greps widget render code for `length()` / `substring(` calls and emits candidates as JSON for review. |

## Eval Lift

Measured on `claude-sonnet-4-6` over 3 scenarios that test tile-specific (not universal) behaviour:

| Scenario | Baseline | With Tile | Lift |
|----------|---------:|----------:|-----:|
| Refuse to rename `commit→trace` and drop the JFR `enabled()` guard | 19% | 100% | **+81** |
| Add a JFR event with TamboUI naming, guard, helper, polyfill | 26% | 100% | **+74** |
| Wrap a widget with `resolveEffectiveStyle` + nullable Style fields | 62% | 100% | **+38** |
| **Aggregate (n=3)** | **36%** | **100%** | **+64** |

Two zero-lift scenarios were retired per `plugin-evals.md` ("coincidence with universal competence: retire or accept as documentation"). See `CHANGELOG.md` for the full history.

## Authoring Workflow

Local development runs against the included script-test suite:

```bash
bash scripts/tests/run-all.sh
tessl tile lint
tessl skill review --threshold 85 skills/scaffold-toolkit-app
tessl skill review --threshold 85 skills/wrap-widget-as-element
tessl skill review --threshold 85 skills/add-jfr-event
```

CI runs the same set on every PR (`.github/workflows/lint.yml`).

## Publishing

Publishing is automated via `tesslio/patch-version-publish` on push to `main` (`.github/workflows/publish.yml`). The action queries the registry for the latest published version, auto-bumps the patch if `tile.json` is at-or-behind, and publishes. To override (minor/major bump), edit `tile.json` `version` to a value greater than the registry latest before pushing.

The workflow needs a `TESSL_TOKEN` repository secret. Configure it at:

<https://github.com/jbaruch/tamboui/settings/secrets/actions>

Token can be generated at <https://tessl.io/settings/tokens>.

## Relationship to TamboUI Upstream

This tile is independent: it's authored by an external contributor against the public TamboUI surface. If the TamboUI maintainers want to adopt it as an official tile, the canonical place would be `tamboui/tamboui-tessl` (or similar) — at which point this repo would be archived with a pointer.

## License

MIT — same license as TamboUI itself, since the tile content paraphrases public TamboUI documentation and conventions.
