#!/usr/bin/env bash
# Tests scripts/record-metric.sh against a throwaway skill folder.
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
FAILS=0
FILE="$TMP/local/metrics.tsv"

run() { SKILL_ROOT="$TMP" bash "$ROOT/scripts/record-metric.sh" "$@" 2>&1; }

fail() { echo "FAIL: $1"; FAILS=$((FAILS + 1)); }

OUT="$(run shop security_high 3)" || fail "valid value rejected: $OUT"
[ -f "$FILE" ] || fail "file not created"
grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}	shop	security_high	3$' "$FILE" || fail "wrong line: $(cat "$FILE")"
case "$OUT" in *"no earlier value"*) ;; *) fail "first value: $OUT" ;; esac

OUT="$(run shop security_high 1)" || fail "second value rejected"
case "$OUT" in *"previous 3"*) ;; *) fail "previous value not shown: $OUT" ;; esac

OUT="$(run shop runtime_seconds 1.5)" || fail "decimal rejected: $OUT"
LINES="$(wc -l < "$FILE")"

run shop security_high 'password123' >/dev/null && fail "text value accepted"
run shop unknown_metric 1 >/dev/null && fail "unknown metric accepted"
run '../etc' security_high 1 >/dev/null && fail "path as project accepted"
run 'a	b' security_high 1 >/dev/null && fail "tab in project accepted"
run shop security_high >/dev/null && fail "missing argument accepted"
[ "$(wc -l < "$FILE")" -eq "$LINES" ] || fail "rejected input was written"

if [ "$FAILS" -eq 0 ]; then echo "all tests passed"; else echo "$FAILS failed"; exit 1; fi
