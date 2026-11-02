#!/usr/bin/env bash
# Tests scripts/check-update.sh and the merge path against throwaway git repositories.
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
FAILS=0
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@example.test GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@example.test

check() { # check <description> <expected pattern> [args...]
  local description="$1" pattern="$2"; shift 2
  local out
  out="$(SKILL_ROOT="$CLONE" bash "$ROOT/scripts/check-update.sh" "$@")"
  if ! printf '%s\n' "$out" | grep -qE "$pattern"; then
    echo "FAIL: $description (expected: $pattern, got: $out)"; FAILS=$((FAILS + 1))
  fi
}

git init -q --bare -b main "$TMP/origin.git"
git clone -q "$TMP/origin.git" "$TMP/upstream" 2>/dev/null
printf 'line one\nline two\n\nline four\n' > "$TMP/upstream/SKILL.md"
git -C "$TMP/upstream" add . && git -C "$TMP/upstream" commit -qm base && git -C "$TMP/upstream" push -q origin HEAD:main
git clone -q "$TMP/origin.git" "$TMP/clone"
CLONE="$TMP/clone"

CLONE="$TMP/plain"; mkdir "$CLONE"
check "copy without git" '^NOT-GIT' --now
CLONE="$TMP/clone"

check "nothing new" '^UP-TO-DATE' --now
check "recently checked is skipped" '^SKIPPED'

printf 'line one\nline two\n\nline four\nnew upstream rule\n' > "$TMP/upstream/SKILL.md"
git -C "$TMP/upstream" commit -qam upstream && git -C "$TMP/upstream" push -q origin HEAD:main
check "new upstream commit" '^UPDATE 1 LOCAL 0' --now

printf 'my own rule\nline two\n\nline four\n' > "$CLONE/SKILL.md"
git -C "$CLONE" commit -qam "Rule: my own rule"
check "local commit is counted" '^UPDATE 1 LOCAL 1' --now

git -C "$CLONE" merge -q --no-edit '@{upstream}'
if ! grep -q 'my own rule' "$CLONE/SKILL.md"; then echo "FAIL: merge lost the local rule"; FAILS=$((FAILS + 1)); fi
if ! grep -q 'new upstream rule' "$CLONE/SKILL.md"; then echo "FAIL: merge missed the update"; FAILS=$((FAILS + 1)); fi

git -C "$CLONE" remote set-url origin "$TMP/does-not-exist.git"
check "unreachable remote" '^OFFLINE' --now

if [ "$FAILS" -eq 0 ]; then echo "all tests passed"; else echo "$FAILS failed"; exit 1; fi
