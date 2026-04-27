#!/usr/bin/env bash
# test-check-display-width.sh — fixture-based tests for check-display-width.sh.
#
# Builds a synthetic widget tree per case and asserts the script's JSON output
# (or its stderr message for the missing-tree case).  Tests do not depend on
# the real tamboui-widgets source.

set -euo pipefail

repo_root="$(cd "$(dirname "$0")/../.." && pwd)"
script="$repo_root/scripts/check-display-width.sh"

assert_eq() {
  local label="$1" expected="$2" actual="$3"
  if [[ "$expected" != "$actual" ]]; then
    echo "ASSERT FAILED: $label"
    diff <(printf '%s\n' "$expected") <(printf '%s\n' "$actual") || true
    exit 1
  fi
}

# --- Case 1: missing widgets source root ---------------------------------------
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

if "$script" "$work" >/dev/null 2>/tmp/err.$$; then
  echo "Case 1: expected non-zero exit when widget source root is missing"
  exit 1
fi
err=$(cat /tmp/err.$$); rm -f /tmp/err.$$
case "$err" in
  *source\ root\ not\ found*) ;;
  *) echo "Case 1: expected error mentioning missing source root"; echo "got: $err"; exit 1 ;;
esac

# --- Case 2: clean source tree (no candidates) ---------------------------------
work=$(mktemp -d)
mkdir -p "$work/tamboui-widgets/src/main/java/dev/tamboui/widgets/foo"
cat >"$work/tamboui-widgets/src/main/java/dev/tamboui/widgets/foo/Foo.java" <<'EOF'
package dev.tamboui.widgets.foo;

public final class Foo {
    public int width() {
        return CharWidth.of("hello");
    }
}
EOF

actual=$("$script" "$work")
assert_eq "Case 2 no candidates" "[]" "$actual"

# --- Case 3: one length() candidate, one substring() candidate -----------------
work=$(mktemp -d)
mkdir -p "$work/tamboui-widgets/src/main/java/dev/tamboui/widgets/foo"
cat >"$work/tamboui-widgets/src/main/java/dev/tamboui/widgets/foo/Foo.java" <<'EOF'
package dev.tamboui.widgets.foo;

public final class Foo {
    public int width(String text) {
        return text.length();
    }
    public String trunc(String text, int max) {
        return text.substring(0, max);
    }
}
EOF

actual=$("$script" "$work")
expected='[
  {"file": "tamboui-widgets/src/main/java/dev/tamboui/widgets/foo/Foo.java", "line": 5, "kind": "length", "match": "return text.length();"},
  {"file": "tamboui-widgets/src/main/java/dev/tamboui/widgets/foo/Foo.java", "line": 8, "kind": "substring", "match": "return text.substring(0, max);"}
]'
assert_eq "Case 3 length and substring" "$expected" "$actual"

# --- Case 4: substring AND length on same line classifies as substring ---------
work=$(mktemp -d)
mkdir -p "$work/tamboui-widgets/src/main/java/dev/tamboui/widgets/bar"
cat >"$work/tamboui-widgets/src/main/java/dev/tamboui/widgets/bar/Bar.java" <<'EOF'
package dev.tamboui.widgets.bar;

public final class Bar {
    public String compose(String text) {
        return text.substring(0, text.length() / 2);
    }
}
EOF

actual=$("$script" "$work")
case "$actual" in
  *'"kind": "substring"'*) ;;
  *) echo "Case 4 expected substring classification when both appear on a line"; echo "got: $actual"; exit 1 ;;
esac

# --- Case 5: deterministic sort order across multiple files --------------------
work=$(mktemp -d)
mkdir -p "$work/tamboui-widgets/src/main/java/dev/tamboui/widgets/zeta"
mkdir -p "$work/tamboui-widgets/src/main/java/dev/tamboui/widgets/alpha"
echo 'class Z { int n() { return s.length(); } }' >"$work/tamboui-widgets/src/main/java/dev/tamboui/widgets/zeta/Z.java"
echo 'class A { int n() { return s.length(); } }' >"$work/tamboui-widgets/src/main/java/dev/tamboui/widgets/alpha/A.java"

run1=$("$script" "$work")
run2=$("$script" "$work")
assert_eq "Case 5 determinism" "$run1" "$run2"

# alpha must come before zeta in the sorted output
case "$run1" in
  *alpha/A.java*zeta/Z.java*) ;;
  *) echo "Case 5 expected alpha before zeta in output"; echo "got: $run1"; exit 1 ;;
esac

echo "all cases passed"
