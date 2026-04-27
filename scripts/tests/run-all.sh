#!/usr/bin/env bash
# run-all.sh — run every test in scripts/tests/ that matches `test-*.sh`.
#
# Each test prints its name and PASS/FAIL.  Exit code is 0 only if every test
# passes; non-zero if any test fails.

set -u

here="$(cd "$(dirname "$0")" && pwd)"
failed=0
total=0

for test in "$here"/test-*.sh; do
  [[ -f "$test" ]] || continue
  total=$((total + 1))
  name="$(basename "$test")"
  if bash "$test" >/tmp/tile-test.out 2>&1; then
    echo "PASS  $name"
  else
    failed=$((failed + 1))
    echo "FAIL  $name"
    sed 's/^/      | /' /tmp/tile-test.out
  fi
done

echo
echo "$((total - failed))/$total passed"
exit "$failed"
