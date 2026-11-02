#!/usr/bin/env bash
# Checks GitHub for a newer version of this skill, at most once per interval; changes no skill file.
# Prints one of: NOT-GIT, SKIPPED, OFFLINE, UP-TO-DATE, UPDATE <new commits> LOCAL <own commits>.
# --now checks regardless of the interval.
set -u

ROOT="${SKILL_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
readonly ROOT
readonly STAMP="$ROOT/.update-check"
readonly INTERVAL_SECONDS=$((30 * 24 * 60 * 60))
readonly FETCH_TIMEOUT_SECONDS=15

if [ ! -e "$ROOT/.git" ]; then
  echo NOT-GIT
  exit 0
fi

now="$(date +%s)"
if [ "${1:-}" != "--now" ] && [ -f "$STAMP" ]; then
  last="$(cat "$STAMP")"
  case "$last" in
    ''|*[!0-9]*) last=0 ;;
  esac
  if [ $((now - last)) -lt "$INTERVAL_SECONDS" ]; then
    echo SKIPPED
    exit 0
  fi
fi

if ! { GIT_TERMINAL_PROMPT=0 perl -e 'alarm shift; exec @ARGV' "$FETCH_TIMEOUT_SECONDS" git -C "$ROOT" fetch -q origin >/dev/null 2>&1; } 2>/dev/null; then
  echo OFFLINE
  exit 0
fi
printf '%s\n' "$now" > "$STAMP"

new="$(git -C "$ROOT" rev-list --count 'HEAD..@{upstream}' 2>/dev/null)" || { echo OFFLINE; exit 0; }
own="$(git -C "$ROOT" rev-list --count '@{upstream}..HEAD')"
if [ "$new" -eq 0 ]; then
  echo UP-TO-DATE
else
  echo "UPDATE $new LOCAL $own"
fi
