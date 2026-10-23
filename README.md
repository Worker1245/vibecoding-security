# code-rule-skill

A [Claude Code](https://claude.com/claude-code) skill with language-agnostic rules for writing, refactoring and reviewing code: structure, readability, secure coding (OWASP, NIST SSDF), slimming down and performance.

The skill maintains itself: when the user corrects a coding mistake or states a lasting rule, Claude adds it to `SKILL.md`, keeps the last three versions locally and commits the change. Every 90 days it proposes a cleanup.

## Install

```bash
git clone https://github.com/Worker1245/code-rule-skill.git
ln -s "$PWD/code-rule-skill" ~/.claude/skills/code-rule-skill
```

Or copy the folder to `~/.claude/skills/code-rule-skill`.

## License

MIT
