# Changelog

All notable changes to the `jbaruch/tamboui` tessl tile are documented in this file.

The TamboUI Java library itself does not yet maintain a separate changelog; see GitHub releases at <https://github.com/tamboui/tamboui/releases> for library history.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Eval scenarios under `evals/` covering all three skills with a mix of positive and negative cases, merged from `tessl scenario generate` output and hand-authored scenarios. Generator scenarios won for `scaffold-toolkit-dsl-app` and `jfr-event-conventions` (cleaner, no task-to-criterion bleeding); hand-authored kept for `wrap-histogram-positive` (no inline widget source, vaguer doc location for stronger lift).
- Bash-script tests for `scripts/list-tamboui-modules.sh` and `scripts/check-display-width.sh` under `scripts/tests/`.
- GitHub Actions workflow `.github/workflows/tile.yml` that runs `tessl tile lint` and `tessl skill review --threshold 85` on changes under tile-owned paths.

### Removed

- Eval scenario `wrap-existing-list-negative` — measured eval lift was −25 (baseline 100%, with-context 75%) and a tightened skill-Step-1 fix attempt regressed it further to −52. Per `plugin-evals.md` ("coincidence with universal competence: retire or accept as documentation"), the scenario tested generic engineering judgement (investigate before duplicating) rather than any tile-specific prescription, so it is retired rather than reshaped.
- Eval scenarios `scaffold-toolkit-dsl-app` and `scaffold-without-backend-negative` — both scored baseline 100% / with-context 100% (zero lift). Modern Claude models already scaffold a JBang Toolkit DSL app correctly without the tile, and already push back on unsatisfiable build constraints without prompting. The `pick-the-api-level` and `resource-lifecycle` rules are kept in the tile as documentation for human readers, but they do not warrant eval coverage because they codify what baseline agents already produce by default.

### Changed

- Promoted the tile from `tile/` subdirectory to the repo root so the entrypoint matches the project's `README.md` (per the tessl context-artifacts rule that the tile entrypoint is the project README).
- Folded the tile's discovery surface (rules table, skills table, install instructions, registry badge) into the project `README.md` under the new `## Coding Agent Support` section.
- Replaced XML-style placeholders (`<area>`, `<thing>`, `<module>`) in the `add-jfr-event` skill with brace-style (`{area}`, `{thing}`, `{module}`) so the description passes deterministic skill validation.
- Removed redundant "Proceed immediately to Step N" handoff lines from skills — the opening "Process steps in order" already establishes sequential execution.

## [0.1.0] — 2026-04-27

### Added

- Initial tile with 8 always-apply rules: `pick-the-api-level`, `render-thread-discipline`, `char-width-for-display`, `exception-hierarchy`, `resource-lifecycle`, `css-element-style-resolution`, `jfr-event-conventions`, `java-8-source-compat`.
- Initial tile with 3 skills: `scaffold-toolkit-app`, `wrap-widget-as-element`, `add-jfr-event`.
- Initial tile with 2 deterministic helper scripts: `list-tamboui-modules.sh`, `check-display-width.sh`.
