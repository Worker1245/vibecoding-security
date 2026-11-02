#!/usr/bin/env bash
# Tests scripts/check-setup.sh with fake skills and fake programs; touches nothing real.
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
FAILS=0

expect() { # expect <description> <pattern>
  if ! printf '%s\n' "$OUT" | grep -qE "$2"; then
    echo "FAIL: $1 (expected: $2)"; FAILS=$((FAILS + 1))
  fi
}

mkdir -p "$TMP/skills/semgrep" "$TMP/bin"
touch "$TMP/skills/semgrep/SKILL.md"
mkdir "$TMP/skills/owasp-security"   # no SKILL.md: must count as missing
printf '#!/bin/sh\nexit 0\n' > "$TMP/bin/git"
printf '#!/bin/sh\nsleep 30\n' > "$TMP/bin/docker"   # hanging daemon
printf '#!/bin/sh\nexit 1\n' > "$TMP/bin/podman"     # installed, not running
chmod +x "$TMP/bin/"*

OUT="$(CLAUDE_SKILLS_DIR="$TMP/skills" CHECK_TIMEOUT=1 PATH="$TMP/bin:/usr/bin:/bin" bash "$ROOT/scripts/check-setup.sh")"
STATUS=$?

[ "$STATUS" -eq 0 ] || { echo "FAIL: exit code $STATUS"; FAILS=$((FAILS + 1)); }
expect "installed skill"          '^OK[[:space:]]+skill[[:space:]]+semgrep'
expect "folder without SKILL.md"  '^MISSING[[:space:]]+skill[[:space:]]+owasp-security'
expect "absent skill"             '^MISSING[[:space:]]+skill[[:space:]]+security-audit'
expect "installed program"        '^OK[[:space:]]+program[[:space:]]+git'
expect "absent program"           '^MISSING[[:space:]]+program[[:space:]]+composer'
expect "hanging docker"           '^STOPPED[[:space:]]+container[[:space:]]+docker'
expect "podman not running"       '^STOPPED[[:space:]]+container[[:space:]]+podman'

if [ "$FAILS" -eq 0 ]; then echo "all tests passed"; else echo "$FAILS failed"; exit 1; fi
