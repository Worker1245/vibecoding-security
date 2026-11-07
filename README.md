# vibecoding-security

An [Agent Skill](https://agentskills.io) with language-agnostic rules for writing, refactoring and reviewing code. It works with coding agents that read `SKILL.md`, such as [Claude Code](https://claude.com/claude-code), OpenAI Codex and GitHub Copilot. Install shows how far each one has been tested.

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
- A prompt creator that sharpens your prompt before any code is written
- Learning locally: the skill grows with you, under your control, and nothing learned is uploaded

`SKILL.md` holds what applies to every change. Everything else is in `references/` and is read only when its condition applies, which keeps the text loaded per change short.

## How to use it

The agent loads the skill on its own before code changes. You can also call it yourself:

- **Only the skill name, nothing else:** If you type just `/vibecoding-security` in the chat and no task is under way, nothing gets checked or changed yet. You get a short help with examples of what to type, and the agent asks what to work on. Your answer starts the work.
- **`/vibecoding-security what security tips do you have?`** checks what is set up (security skills, scanners, Docker Desktop or an alternative), installs nothing, and gives tips that fit the gaps.
- **`/vibecoding-security check my project`** runs all checks one after the other: the rules, the project's tests in a container, the scanners and the security skills. The agent shows the plan and starts right away; it asks first only for anything costly, anything that sends data out, and anything it would install. It changes no code and reports what ran, what could not run and what it found.
- **`/vibecoding-security` followed by your own prompt** first sharpens the prompt with you: the agent asks what you want to achieve, shows a refined prompt, suggests useful details and asks for the format of the result. Once you are satisfied, it does the work under these rules. Add "directly" to skip the questions.
- **`/vibecoding-security is there an update?`** looks for a newer version on GitHub.
- **`/vibecoding-security claude commands`** lists every built-in Claude Code command with a short explanation, and **`/vibecoding-security secret claude commands`** lists popular community skill commands (they work only once installed). Both need Claude Code with the `claude-code-help` skill; other agents say so instead.

The skill answers in the language you write in.

**What you will see while the agent works under the rules:**

- It names in one line which extra rule files it read and why.
- Before a change it answers the six questions, with evidence.
- It adds the security basics (access checks, input validation, output encoding) to every new entry point, even if you did not ask. It does not count them as extra scope.
- It adds no other functions you did not ask for. It asks first whether they are needed.
- It compares your instruction with the context and asks about what you may have forgotten, such as follow-up changes or related files.
- If something is unclear, it asks numbered questions with options and marks its recommendation with ★. A short answer like `1a 2b` is enough.
- If a test contradicts the specification, it stops and asks instead of changing the test to get green.
- If you correct a mistake or state a lasting rule, it shows the new wording and adds it only after your yes.

## Install

Clone once, then link it for your tool:

```bash
git clone https://github.com/Worker1245/vibecoding-security.git
```

Claude Code:

```bash
mkdir -p ~/.claude/skills && ln -s "$PWD/vibecoding-security" ~/.claude/skills/vibecoding-security
```

OpenAI Codex:

```bash
mkdir -p ~/.agents/skills && ln -s "$PWD/vibecoding-security" ~/.agents/skills/vibecoding-security
```

GitHub Copilot (CLI and VS Code):

```bash
mkdir -p ~/.copilot/skills && ln -s "$PWD/vibecoding-security" ~/.copilot/skills/vibecoding-security
```

Or copy the folder there instead; a copied folder cannot update itself.

Perplexity Computer: upload a ZIP of the skill, as a skill with its `SKILL.md` at the root. It should run as rules only: as a hosted agent it presumably cannot use the scripts, your Docker or the local `local/` folder, so the local learning does not apply there.

```bash
git -C vibecoding-security archive --format=zip -o ../vibecoding-security.zip HEAD
```

| | Claude Code | Codex | Copilot | Perplexity |
|---|---|---|---|---|
| Tested by the author | yes | no | partly (CLI, non-interactive) | no |
| Rules | yes | expected | yes | expected |
| Scripts, Docker, local learning | yes | expected | expected | no |
| Calling the skill | `/vibecoding-security` | `$vibecoding-security` or `/skills` | `/vibecoding-security` or `/skills` | through its own skills menu |

In the Copilot test, the skill loaded, the help appeared, the extra rule files were read and it answered in the user's language. The prompt creator's questions were skipped in that non-interactive run; interactive use is untested.

## Checking tools in containers

Semgrep, PHPCS with the WordPress standard, PHPStan and Composer audit need no installation. With Docker Desktop or an alternative running, `scripts/run-tool.sh <tool> <project>` starts them in a container:

- The project is mounted read-only, so the tools cannot change it.
- PHPCS and PHPStan run without network access. Semgrep fetches its rules with metrics turned off, and Composer audit asks Packagist about package names. Neither sends your code.
- The first run downloads about 2 GB of images.

## Updates

If you installed the skill with `git clone`, it looks for a newer version on GitHub at most once a month and tells you in one line. It shows what would change and installs only after your yes. Your own changes are kept: they stay as your own commits and the update is merged in. If an update touches the same lines, nothing changes until you decide. A copied folder cannot update itself.

## Learning and self-maintenance

The aim is to make vibe coding better for you: programs measurably more efficient and more secure.

- **It learns on your machine.** Mistakes, your own rules and measurements stay in the `local/` folder, which git ignores. They are never uploaded, and updates cannot overwrite them. The session itself still goes to the model provider as usual.
- **You stay in control.** After the same mistake happens twice, or when you state a lasting rule, the agent proposes a rule and adds it only after your yes. There are at most 100 own rules. A rule can never lower the security floor.
- **It measures.** After a check it records numbers only, such as security findings, test results and runtime, and reports the change since the last run. A trend shows a direction, not proof that a rule caused it.
- **It stays current.** Once a month it proposes how to optimize the skill and what to add, compares the security rules with current OWASP guidance and looks for new versions of the security skills. It also proposes removing your own rules if they show no use. This reads public pages and sends no project data.

Published rules are versioned: the last three versions stay in `versions/`, and changes are committed locally and pushed only when you say so.

## Optional technical safeguards

This skill is text. The agent normally follows it, but it can overlook or misjudge a rule, and nothing forces it to comply. A technical safeguard works like a lock instead of a sign: the software enforces it, whatever the agent decides. None is set up by default. The agent can set up either level on request and agrees on each safeguard with you first.

**Basic**
- *Blocked commands and files:* the agent refuses dangerous commands, such as deleting a database, and does not open files containing passwords.
- *Secret scan:* before each commit, a small program checks whether a password or key would end up in the code, and stops the commit if so.

**Full: Basic plus**
- *Sandbox:* the agent works in a closed room, so it cannot reach the rest of your computer or send data out freely.
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
bash tests/record-metric.test.sh
bash tests/run-tool.test.sh
```

## Sources

The rules are written in our own words and draw on ideas from:

- Robert C. Martin: [The Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html), [Screaming Architecture](https://blog.cleancoder.com/uncle-bob/2011/09/30/Screaming-Architecture.html), [The Single Responsibility Principle](https://blog.cleancoder.com/uncle-bob/2014/05/08/SingleReponsibilityPrinciple.html)
- [martinfowler.com](https://martinfowler.com): [Test Pyramid](https://martinfowler.com/bliki/TestPyramid.html), [The Practical Test Pyramid](https://martinfowler.com/articles/practical-test-pyramid.html), [Beck Design Rules](https://martinfowler.com/bliki/BeckDesignRules.html), [Presentation Domain Data Layering](https://martinfowler.com/bliki/PresentationDomainDataLayering.html), [Strangler Fig](https://martinfowler.com/bliki/StranglerFigApplication.html), [Feature Toggles](https://martinfowler.com/articles/feature-toggles.html), [Code Smell](https://martinfowler.com/bliki/CodeSmell.html)
- [cloudflare/security-audit-skill](https://github.com/cloudflare/security-audit-skill) (MIT): design principles for judging findings

## License

MIT
