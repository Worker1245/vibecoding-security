#!/usr/bin/env bash
# Read-only: reports which skills, programs and container runtimes this skill can use.
# Output, one per line: STATUS KIND NAME, with STATUS being OK, MISSING or STOPPED.
set -u

# Where Claude Code, Codex and GitHub Copilot keep personal skills.
readonly SKILL_FOLDERS="$HOME/.claude/skills $HOME/.agents/skills $HOME/.copilot/skills"
CHECK_TIMEOUT="${CHECK_TIMEOUT:-5}"
readonly SKILLS="owasp-security semgrep differential-review variant-analysis supply-chain-risk-auditor security-audit"
readonly PROGRAMS="git semgrep skillspector agnix npm pip-audit composer php phpcs phpstan wp-env"
readonly RUNTIMES="docker podman colima"
readonly DESKTOP_APP="/Applications/Docker.app"

report() { printf '%-8s %-10s %s\n' "$1" "$2" "$3"; }

skill_installed() {
  local folder
  for folder in $SKILL_FOLDERS; do
    [ -f "$folder/$1/SKILL.md" ] && return 0
  done
  return 1
}

for skill in $SKILLS; do
  if skill_installed "$skill"; then
    report OK skill "$skill"
  else
    report MISSING skill "$skill"
  fi
done

for program in $PROGRAMS; do
  if command -v "$program" >/dev/null 2>&1; then
    report OK program "$program"
  else
    report MISSING program "$program"
  fi
done

runtime_check() {
  case "$1" in
    colima) echo status ;;
    *) echo info ;;
  esac
}

for runtime in $RUNTIMES; do
  if ! command -v "$runtime" >/dev/null 2>&1; then
    if [ "$runtime" = docker ] && [ -d "$DESKTOP_APP" ]; then
      report STOPPED container docker
    else
      report MISSING container "$runtime"
    fi
  elif { perl -e 'alarm shift; exec @ARGV' "$CHECK_TIMEOUT" "$runtime" "$(runtime_check "$runtime")" >/dev/null 2>&1; } 2>/dev/null; then
    report OK container "$runtime"
  else
    report STOPPED container "$runtime"
  fi
done
