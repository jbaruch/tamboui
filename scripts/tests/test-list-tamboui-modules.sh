#!/usr/bin/env bash
# test-list-tamboui-modules.sh — fixture-based tests for list-tamboui-modules.sh.
#
# Builds a synthetic repo layout in a temp dir per test case so the test does
# not depend on the actual TamboUI source tree.  Each case asserts an exact
# JSON output (sorted, deterministic) or an exact stderr message.

set -euo pipefail

repo_root="$(cd "$(dirname "$0")/../.." && pwd)"
script="$repo_root/scripts/list-tamboui-modules.sh"

assert_eq() {
  local label="$1" expected="$2" actual="$3"
  if [[ "$expected" != "$actual" ]]; then
    echo "ASSERT FAILED: $label"
    diff <(printf '%s\n' "$expected") <(printf '%s\n' "$actual") || true
    exit 1
  fi
}

# --- Case 1: missing settings.gradle.kts ---------------------------------------
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

if "$script" "$work" >/dev/null 2>/tmp/err.$$; then
  echo "Case 1: expected non-zero exit when settings.gradle.kts is missing"
  exit 1
fi
err=$(cat /tmp/err.$$); rm -f /tmp/err.$$
case "$err" in
  *settings.gradle.kts*not\ found*) ;;
  *) echo "Case 1: expected error mentioning missing settings.gradle.kts"; echo "got: $err"; exit 1 ;;
esac

# --- Case 2: empty listOf, no demos --------------------------------------------
work=$(mktemp -d)
cat >"$work/settings.gradle.kts" <<'EOF'
rootProject.name = "test"
val modules = listOf()
include(*modules.toTypedArray())
EOF

actual=$("$script" "$work")
assert_eq "Case 2 empty modules" "[]" "$actual"

# --- Case 3: two static modules, no demos --------------------------------------
work=$(mktemp -d)
cat >"$work/settings.gradle.kts" <<'EOF'
rootProject.name = "test"
val modules = listOf(
    "alpha-core",
    "alpha-widgets"
)
include(*modules.toTypedArray())
EOF

expected='[
  {"name": "alpha-core", "path": "alpha-core", "kind": "library"},
  {"name": "alpha-widgets", "path": "alpha-widgets", "kind": "library"}
]'
actual=$("$script" "$work")
assert_eq "Case 3 two static modules" "$expected" "$actual"

# --- Case 4: static modules + root demos ---------------------------------------
work=$(mktemp -d)
cat >"$work/settings.gradle.kts" <<'EOF'
val modules = listOf("alpha-core")
EOF
mkdir -p "$work/demos/hello-demo"
mkdir -p "$work/demos/world-demo"

expected='[
  {"name": "alpha-core", "path": "alpha-core", "kind": "library"},
  {"name": "hello-demo", "path": "demos/hello-demo", "kind": "demo"},
  {"name": "world-demo", "path": "demos/world-demo", "kind": "demo"}
]'
actual=$("$script" "$work")
assert_eq "Case 4 root demos" "$expected" "$actual"

# --- Case 5: per-module demos --------------------------------------------------
work=$(mktemp -d)
cat >"$work/settings.gradle.kts" <<'EOF'
val modules = listOf("alpha-core")
EOF
mkdir -p "$work/alpha-core/demos/inner-demo"

expected='[
  {"name": "alpha-core", "path": "alpha-core", "kind": "library"},
  {"name": "inner-demo", "path": "alpha-core/demos/inner-demo", "kind": "demo"}
]'
actual=$("$script" "$work")
assert_eq "Case 5 per-module demos" "$expected" "$actual"

echo "all cases passed"
