#!/usr/bin/env bash
# Tests scripts/run-tool.sh with a fake docker that records its arguments; starts no container.
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
FAILS=0
mkdir -p "$TMP/bin" "$TMP/project"
touch "$TMP/project/plugin.php"
cat > "$TMP/bin/docker" <<STUB
#!/bin/sh
echo "\$*" >> "$TMP/calls"
case "\$1" in
  info) [ -z "\${DOCKER_DOWN:-}" ] ;;
  image) exit \${IMAGE_MISSING:-0} ;;
  *) exit 0 ;;
esac
STUB
chmod +x "$TMP/bin/docker"

run() { PATH="$TMP/bin:/usr/bin:/bin" bash "$ROOT/scripts/run-tool.sh" "$@" >/dev/null 2>&1; }
fail() { echo "FAIL: $1"; FAILS=$((FAILS + 1)); }
expect_call() { grep -qE -- "$2" "$TMP/calls" || fail "$1 (expected: $2)"; }
reset() { : > "$TMP/calls"; }

reset; run semgrep "$TMP/project" || fail "semgrep failed"
expect_call "semgrep without metrics" 'semgrep scan .*--metrics=off'
expect_call "semgrep php rules" '--config p/php'
expect_call "semgrep read-only" ':/src:ro'
grep -q -- '--config auto' "$TMP/calls" && fail "semgrep must not use auto config"

reset; run phpcs "$TMP/project" || fail "phpcs failed"
expect_call "phpcs without network" 'run .*--network none'
expect_call "phpcs read-only" ':/src:ro'
expect_call "phpcs WordPress standard" 'phpcs .*--standard=WordPress'

reset; run phpstan "$TMP/project" || fail "phpstan failed"
expect_call "phpstan without network" 'run .*--network none'
expect_call "phpstan read-only" ':/src:ro'

reset; IMAGE_MISSING=1 run phpcs "$TMP/project" || fail "build path failed"
expect_call "image is built when missing" 'build '

reset; run composer-audit "$TMP/project"; [ $? -eq 4 ] || fail "composer-audit without lock file must return 4"
touch "$TMP/project/composer.lock"
run composer-audit "$TMP/project"; [ $? -eq 4 ] || fail "composer-audit without composer.json must return 4"
touch "$TMP/project/composer.json"
reset; run composer-audit "$TMP/project" || fail "composer-audit failed"
expect_call "composer-audit read-only" ':/src:ro'
expect_call "composer-audit locked" 'audit .*--locked'

run nonsense "$TMP/project"; [ $? -eq 2 ] || fail "unknown tool must return 2"
run semgrep "$TMP/does-not-exist"; [ $? -eq 2 ] || fail "missing folder must return 2"
DOCKER_DOWN=1 run semgrep "$TMP/project"; [ $? -eq 3 ] || fail "stopped runtime must return 3"

if [ "$FAILS" -eq 0 ]; then echo "all tests passed"; else echo "$FAILS failed"; exit 1; fi
