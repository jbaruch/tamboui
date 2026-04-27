#!/usr/bin/env bash
# check-display-width.sh — flag candidate display-width violations in widget render code.
#
# Heuristic: greps for `.length()` and `.substring(` calls inside files under
# `tamboui-widgets/src/main/java`.  These are *candidates* for review against
# `rules/char-width-for-display.md`, not confirmed bugs — the agent must triage.
#
# Usage:    check-display-width.sh [<repo-root>]
# Default:  $PWD
# Output:   stdout — JSON `[{"file": "...", "line": N, "match": "...", "kind": "length|substring"}, ...]`
# Exit:     0 always (informational); non-zero only if the search root is missing or unreadable.
#
# Deterministic: results are sorted by file then line.  Same tree -> same output.

set -euo pipefail

repo_root="${1:-$PWD}"
search_root="${repo_root%/}/tamboui-widgets/src/main/java"

if [[ ! -d "$search_root" ]]; then
  echo "check-display-width: source root not found at $search_root" >&2
  echo "check-display-width: run from the TamboUI repo root or pass it as the first argument" >&2
  exit 2
fi

# Collect matches into a sorted, stable stream.  Use grep -n for line numbers,
# limit to .java files, exclude test sources (none under main/java but be explicit).
matches=$(
  { grep -rn --include='*.java' -E '\.(length\(\)|substring\()' "$search_root" \
      2>/dev/null || true; } | sort
)

if [[ -z "$matches" ]]; then
  echo "[]"
  exit 0
fi

printf '[\n'
first=1
while IFS=: read -r file line content; do
  [[ -z "$file" ]] && continue
  trimmed=$(printf '%s' "$content" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
  # Classify: substring beats length when both appear; matches the rule's emphasis.
  if printf '%s' "$content" | grep -q '\.substring('; then
    kind="substring"
  else
    kind="length"
  fi
  # JSON-escape backslashes and quotes in the match text.
  escaped=$(printf '%s' "$trimmed" | sed 's/\\/\\\\/g; s/"/\\"/g')
  rel_file="${file#$repo_root/}"
  if [[ $first -eq 1 ]]; then
    first=0
  else
    printf ',\n'
  fi
  printf '  {"file": "%s", "line": %s, "kind": "%s", "match": "%s"}' \
    "$rel_file" "$line" "$kind" "$escaped"
done <<< "$matches"
printf '\n]\n'
