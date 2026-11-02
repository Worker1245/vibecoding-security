# code-rule-skill

A [Claude Code](https://claude.com/claude-code) skill with language-agnostic rules for writing, refactoring and reviewing code.

## What it covers

- How to work with the user: numbered questions with options, no functions nobody asked for
- Six questions for every change: OWASP, YAGNI, reuse, KISS, removability, executor subagent
- Project knowledge: design folder, short task cards for agents, git from the start
- Structure and architecture: inward-pointing dependencies, one reason to change, and a per-application check whether the four Clean Architecture layers are worth their cost
- Tests, including runs in a container (Docker Desktop or a free alternative) and one check command, and simple design
- Refactoring, readability and robustness
- A security floor for every change, secure coding (OWASP, NIST SSDF) and how to judge security findings
- WordPress plugins and themes
- Slimming down, speed and data
- Executor subagents: when one helps, how to brief it, and how to verify its work

`SKILL.md` holds what applies to every change. Everything else is in `references/` and is read only when its condition applies, which keeps the text loaded per change short.

## How to use it

Claude loads the skill on its own before code changes. You can also call it yourself:

- **Only the skill name, nothing else:** If you type just `/code-rule-skill` in the chat and no task is under way, nothing gets checked or changed yet. You get a short help with examples of what to type, and Claude asks what to work on. Your answer starts the work.
- **`/code-rule-skill what security tips do you have?`** checks what is set up (security skills, scanners, Docker Desktop or an alternative), installs nothing, and gives tips that fit the gaps.
- **`/code-rule-skill check my project`** runs all checks one after the other: the rules, the project's tests in a container, the scanners and the security skills. Claude shows the plan and starts right away; it asks first only for anything costly, anything that sends data out, and anything it would install. It changes no code and reports what ran, what could not run and what it found.
- **`/code-rule-skill add a contact form`** does the work under these rules.
- **`/code-rule-skill is there an update?`** looks for a newer version on GitHub.

The skill answers in the language you write in.

**What you will see while Claude works under the rules:**

- It names in one line which extra rule files it read and why.
- Before a change it answers the six questions, with evidence.
- It adds the security basics (access checks, input validation, output encoding) to every new entry point, even if you did not ask. It does not count them as extra scope.
- It adds no other functions you did not ask for. It asks first whether they are needed.
- If something is unclear, it asks numbered questions with options and marks its recommendation with ★. A short answer like `1a 2b` is enough.
- If a test contradicts the specification, it stops and asks instead of changing the test to get green.
- If you correct a mistake or state a lasting rule, it shows the new wording and adds it only after your yes.

## Install

```bash
git clone https://github.com/Worker1245/code-rule-skill.git
ln -s "$PWD/code-rule-skill" ~/.claude/skills/code-rule-skill
```

Or copy the folder to `~/.claude/skills/code-rule-skill`.

## Updates

If you installed the skill with `git clone`, it looks for a newer version on GitHub at most once a month and tells you in one line. It shows what would change and installs only after your yes. Your own changes are kept: they stay as your own commits and the update is merged in. If an update touches the same lines, nothing changes until you decide. A copied folder cannot update itself.

## Self-maintenance

The skill maintains itself: when the user corrects a coding mistake or states a lasting rule, Claude proposes the new wording and, after your yes, adds it to the skill, keeps the last three versions locally in `versions/` and commits the change. Once a month it proposes a cleanup.

## Optional technical safeguards

This skill is text. Claude normally follows it, but it can overlook or misjudge a rule, and nothing forces it to comply. A technical safeguard works like a lock instead of a sign: the software enforces it, whatever Claude decides. None is set up by default. Claude can set up either level on request and agrees on each safeguard with you first.

**Basic**
- *Blocked commands and files:* Claude Code refuses dangerous commands, such as deleting a database, and does not open files containing passwords.
- *Secret scan:* before each commit, a small program checks whether a password or key would end up in the code, and stops the commit if so.

**Full: Basic plus**
- *Sandbox:* Claude works in a closed room, so it cannot reach the rest of your computer or send data out freely.
- *Package check:* before an add-on is installed, a check confirms it really exists and is not suspiciously new. AI sometimes invents package names, and attackers register such names.
- *Test-change notice:* you are told when existing tests were changed, so a failing test cannot quietly be made to pass.
- *Extended check command:* one command also runs code analysis and looks for secrets and known vulnerabilities in add-ons.

The price is one round of setup, more confirmation prompts and an occasional false alarm.

## Optional companion tools

The skill points to these where they help. None is required or bundled; install them separately and review third-party skills first.

- Skills: `owasp-security` ([agamm/claude-code-owasp](https://github.com/agamm/claude-code-owasp)), `semgrep`, `differential-review`, `variant-analysis` and `supply-chain-risk-auditor` ([trailofbits/skills](https://github.com/trailofbits/skills)), `security-audit` ([cloudflare/security-audit-skill](https://github.com/cloudflare/security-audit-skill))
- [SkillSpector](https://github.com/NVIDIA/SkillSpector): security scanner for agent skills
- [OpenAnt](https://github.com/knostic/OpenAnt): LLM-based vulnerability discovery; separate API billing, mentioned only as an option

## Tests

```bash
bash tests/check-setup.test.sh
bash tests/check-update.test.sh
```

## Sources

The rules are written in our own words and draw on ideas from:

- Robert C. Martin: [The Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html), [Screaming Architecture](https://blog.cleancoder.com/uncle-bob/2011/09/30/Screaming-Architecture.html), [The Single Responsibility Principle](https://blog.cleancoder.com/uncle-bob/2014/05/08/SingleReponsibilityPrinciple.html)
- [martinfowler.com](https://martinfowler.com): [Test Pyramid](https://martinfowler.com/bliki/TestPyramid.html), [The Practical Test Pyramid](https://martinfowler.com/articles/practical-test-pyramid.html), [Beck Design Rules](https://martinfowler.com/bliki/BeckDesignRules.html), [Presentation Domain Data Layering](https://martinfowler.com/bliki/PresentationDomainDataLayering.html), [Strangler Fig](https://martinfowler.com/bliki/StranglerFigApplication.html), [Feature Toggles](https://martinfowler.com/articles/feature-toggles.html), [Code Smell](https://martinfowler.com/bliki/CodeSmell.html)
- [cloudflare/security-audit-skill](https://github.com/cloudflare/security-audit-skill) (MIT): design principles for judging findings

## License

MIT
