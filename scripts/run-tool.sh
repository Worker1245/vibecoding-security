#!/usr/bin/env bash
# Runs a checking tool in a container, so it needs no installation. The project is mounted read-only.
# Usage: run-tool.sh <semgrep|phpcs|phpstan|composer-audit> <project folder>
# Exit codes: the tool's own, 2 wrong usage, 3 no container runtime, 4 does not apply to this project.
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
readonly ROOT
readonly SEMGREP_IMAGE="semgrep/semgrep:1.182.1"
readonly TOOLS_IMAGE="vibecode-help-tools:1"
readonly COMPOSER_IMAGE="composer:2"
readonly RUN_LIMIT_SECONDS=900
readonly PHPSTAN_LEVEL=5

reject() { echo "rejected: $1" >&2; exit 2; }
limited() { perl -e 'alarm shift; exec @ARGV' "$RUN_LIMIT_SECONDS" "$@"; }

[ "$#" -eq 2 ] || reject "usage: run-tool.sh <semgrep|phpcs|phpstan|composer-audit> <project folder>"
tool="$1"
[ -d "$2" ] || reject "no such folder: $2"
project="$(cd "$2" && pwd)"
readonly MOUNT="$project:/src:ro"

if ! limited docker info >/dev/null 2>&1; then
  echo "no running container runtime" >&2
  exit 3
fi

has_files() { [ -n "$(find "$project" -name "$1" -not -path '*/vendor/*' -not -path '*/node_modules/*' -print -quit)" ]; }

ensure_tools_image() {
  docker image inspect "$TOOLS_IMAGE" >/dev/null 2>&1 && return 0
  limited docker build -q -t "$TOOLS_IMAGE" -f "$ROOT/docker/tools.Dockerfile" "$ROOT/docker" >/dev/null
}

case "$tool" in
  semgrep)
    # Fetches rules from the Semgrep registry; --metrics=off sends no usage data and no code.
    configs=(--config p/security-audit --config p/secrets)
    has_files '*.php' && configs+=(--config p/php)
    has_files '*.js' && configs+=(--config p/javascript)
    has_files '*.py' && configs+=(--config p/python)
    limited docker run --rm -v "$MOUNT" -w /src "$SEMGREP_IMAGE" semgrep scan --metrics=off --text "${configs[@]}" .
    ;;
  phpcs)
    ensure_tools_image || exit 1
    limited docker run --rm --network none -v "$MOUNT" -w /src "$TOOLS_IMAGE" phpcs --standard=WordPress --extensions=php -s .
    ;;
  phpstan)
    ensure_tools_image || exit 1
    limited docker run --rm --network none -v "$MOUNT" -w /src "$TOOLS_IMAGE" phpstan analyse --no-progress --memory-limit=1G --level="$PHPSTAN_LEVEL" .
    ;;
  composer-audit)
    # Asks Packagist about the locked package names; sends no code.
    if [ ! -f "$project/composer.lock" ] || [ ! -f "$project/composer.json" ]; then
      echo "this project has no composer.json with composer.lock" >&2
      exit 4
    fi
    limited docker run --rm -v "$MOUNT" -w /src "$COMPOSER_IMAGE" audit --locked --no-interaction
    ;;
  *)
    reject "unknown tool: $tool"
    ;;
esac
