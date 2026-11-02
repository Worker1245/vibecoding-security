# code-rule-skill

A [Claude Code](https://claude.com/claude-code) skill with language-agnostic rules for writing, refactoring and reviewing code.

## What it covers

- Six questions for every change: OWASP, YAGNI, reuse, KISS, removability, executor subagent
- Project knowledge: design folder, short task cards for agents, git from the start
- Structure and architecture: inward-pointing dependencies, one reason to change, and a per-application check whether the four Clean Architecture layers are worth their cost
- Tests, including runs in a container (Docker Desktop or a free alternative) and one check command, and simple design
- Refactoring, readability and robustness
- Secure coding (OWASP, NIST SSDF) and how to judge security findings
- Slimming down, speed and data
- Executor subagents: when one helps, how to brief it, and how to verify its work

`SKILL.md` holds what applies to every change. Everything else is in `references/` and is read only when its condition applies, which keeps the text loaded per change short.

## Self-maintenance

The skill maintains itself: when the user corrects a coding mistake or states a lasting rule, Claude adds it to `SKILL.md`, keeps the last three versions locally in `versions/` and commits the change. Once a month it proposes a cleanup.

## Install

```bash
git clone https://github.com/Worker1245/code-rule-skill.git
ln -s "$PWD/code-rule-skill" ~/.claude/skills/code-rule-skill
```

Or copy the folder to `~/.claude/skills/code-rule-skill`.

## Optional companion tools

The skill points to these where they help. None is required or bundled; install them separately and review third-party skills first.

- Skills: `owasp-security` ([agamm/claude-code-owasp](https://github.com/agamm/claude-code-owasp)), `semgrep`, `differential-review`, `variant-analysis` and `supply-chain-risk-auditor` ([trailofbits/skills](https://github.com/trailofbits/skills)), `security-audit` ([cloudflare/security-audit-skill](https://github.com/cloudflare/security-audit-skill))
- [SkillSpector](https://github.com/NVIDIA/SkillSpector): security scanner for agent skills
- [OpenAnt](https://github.com/knostic/OpenAnt): LLM-based vulnerability discovery; separate API billing, mentioned only as an option

## Sources

The rules are written in our own words and draw on ideas from:

- Robert C. Martin: [The Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html), [Screaming Architecture](https://blog.cleancoder.com/uncle-bob/2011/09/30/Screaming-Architecture.html), [The Single Responsibility Principle](https://blog.cleancoder.com/uncle-bob/2014/05/08/SingleReponsibilityPrinciple.html)
- [martinfowler.com](https://martinfowler.com): [Test Pyramid](https://martinfowler.com/bliki/TestPyramid.html), [The Practical Test Pyramid](https://martinfowler.com/articles/practical-test-pyramid.html), [Beck Design Rules](https://martinfowler.com/bliki/BeckDesignRules.html), [Presentation Domain Data Layering](https://martinfowler.com/bliki/PresentationDomainDataLayering.html), [Strangler Fig](https://martinfowler.com/bliki/StranglerFigApplication.html), [Feature Toggles](https://martinfowler.com/articles/feature-toggles.html), [Code Smell](https://martinfowler.com/bliki/CodeSmell.html)
- [cloudflare/security-audit-skill](https://github.com/cloudflare/security-audit-skill) (MIT): design principles for judging findings

## License

MIT
