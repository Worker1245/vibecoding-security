#!/usr/bin/env bash
# Appends one measurement to local/metrics.tsv and prints the change. Stores numbers only, stays local.
# Usage: record-metric.sh <project> <metric> <value>
set -u

ROOT="${SKILL_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
readonly ROOT
readonly FILE="$ROOT/local/metrics.tsv"
readonly METRICS="security_critical security_high security_medium security_low scanner_warnings tests_passed tests_failed runtime_seconds complexity"

reject() { echo "rejected: $1" >&2; exit 2; }

[ "$#" -eq 3 ] || reject "usage: record-metric.sh <project> <metric> <value>"
project="$1"; metric="$2"; value="$3"

[[ "$project" =~ ^[A-Za-z0-9][A-Za-z0-9_-]*$ ]] || reject "project must be a plain name"
case " $METRICS " in
  *" $metric "*) ;;
  *) reject "unknown metric, use one of: $METRICS" ;;
esac
[[ "$value" =~ ^[0-9]+(\.[0-9]+)?$ ]] || reject "value must be a number"

mkdir -p "$ROOT/local"
previous=""
if [ -f "$FILE" ]; then
  previous="$(awk -F'\t' -v p="$project" -v m="$metric" '$2 == p && $3 == m { v = $4 } END { print v }' "$FILE")"
fi
printf '%s\t%s\t%s\t%s\n' "$(date +%Y-%m-%d)" "$project" "$metric" "$value" >> "$FILE"

if [ -n "$previous" ]; then
  echo "$project $metric: $value (previous $previous)"
else
  echo "$project $metric: $value (no earlier value)"
fi
