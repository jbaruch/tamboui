#!/usr/bin/env bash
# list-tamboui-modules.sh — emit TamboUI Gradle modules as JSON.
#
# TamboUI's settings.gradle.kts declares modules in two ways:
#   1. A static `val modules = listOf("tamboui-core", ...)` block.
#   2. Dynamic discovery of demo subdirectories via `includeDemosFrom()`,
#      which scans `demos/` and each `<module>/demos/`.
#
# This script reproduces both: it extracts the static list from settings.gradle.kts
# and walks the filesystem for demo directories the same way Gradle would.
#
# Usage:    list-tamboui-modules.sh [<repo-root>]
# Default:  $PWD
# Output:   stdout — JSON array of objects:
#             [{"name": "tamboui-core", "path": "tamboui-core", "kind": "library"},
#              {"name": "sparkline-demo", "path": "demos/sparkline-demo", "kind": "demo"}, ...]
# Errors:   non-zero exit + diagnostic on stderr if settings.gradle.kts is missing.
#
# Deterministic: same repo state -> same output, sorted by path.

set -euo pipefail

repo_root="${1:-$PWD}"
settings_file="${repo_root%/}/settings.gradle.kts"

if [[ ! -f "$settings_file" ]]; then
  echo "list-tamboui-modules: settings.gradle.kts not found at $settings_file" >&2
  echo "list-tamboui-modules: pass the TamboUI repo root as the first argument, or run from it" >&2
  exit 1
fi

# --- 1. Static modules from `val modules = listOf("...", "...")` ----------------
# Capture the body of the listOf(...) call (single- or multi-line), then pull
# every double-quoted name.  Stops at the closing paren so we do not pick up
# unrelated string literals later in the file.
static_modules=$(
  awk '
    /val[[:space:]]+modules[[:space:]]*=[[:space:]]*listOf[[:space:]]*\(/ { capture = 1 }
    capture {
      print
      if (/\)/) { capture = 0 }
    }
  ' "$settings_file" \
    | { grep -oE '"[^"]+"' || true; } \
    | tr -d '"'
)

# --- 2. Dynamic demos: demos/* directories -------------------------------------
# `includeDemosFrom(File(settingsDir, "demos"), "demos:")` registers every
# subdirectory of demos/ as a project under :demos:<dir>.
demo_paths=()
if [[ -d "${repo_root%/}/demos" ]]; then
  while IFS= read -r -d '' dir; do
    demo_paths+=("demos/$(basename "$dir")")
  done < <(find "${repo_root%/}/demos" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)
fi

# --- 3. Dynamic demos: each <module>/demos/* -----------------------------------
# `modules.forEach { module -> includeDemosFrom(File(settingsDir, "$module/demos"), "$module:demos:") }`
while IFS= read -r module; do
  [[ -z "$module" ]] && continue
  module_demos="${repo_root%/}/$module/demos"
  if [[ -d "$module_demos" ]]; then
    while IFS= read -r -d '' dir; do
      demo_paths+=("$module/demos/$(basename "$dir")")
    done < <(find "$module_demos" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)
  fi
done <<< "$static_modules"

# --- 4. Emit JSON --------------------------------------------------------------
emit() {
  # $1 = path, $2 = kind
  local path="$1" kind="$2"
  local name="${path##*/}"
  printf '  {"name": "%s", "path": "%s", "kind": "%s"}' "$name" "$path" "$kind"
}

# Build a sorted, deduped, classified list: <path>\t<kind>.
# `|| true` on each AND-list keeps `set -e` from killing the subshell when the
# guard fails on an empty input.
combined=$(
  {
    while IFS= read -r m; do
      [[ -n "$m" ]] && printf '%s\tlibrary\n' "$m" || true
    done <<< "$static_modules"
    for d in "${demo_paths[@]:-}"; do
      [[ -n "$d" ]] && printf '%s\tdemo\n' "$d" || true
    done
  } | sort -u
)

if [[ -z "$combined" ]]; then
  echo "[]"
  exit 0
fi

printf '[\n'
first=1
while IFS=$'\t' read -r path kind; do
  [[ -z "$path" ]] && continue
  if [[ $first -eq 1 ]]; then
    first=0
  else
    printf ',\n'
  fi
  emit "$path" "$kind"
done <<< "$combined"
printf '\n]\n'
