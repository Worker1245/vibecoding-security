# Changelog

2026-10-23: moved to own repository; self-update and quarterly review added
2026-10-23: review – baseline
2026-11-02: five questions added for every change and review (OWASP applies?, YAGNI, reuse, KISS, removable without breaking)
2026-11-02: design folder rule added (index read first, one document per journey or feature, explicit do, do not, stop)
2026-11-02: rules added: failing tests never waved away, checksum proof for restructuring, unattended limits tested, complicated parts measured against a simple variant
2026-11-02: architecture, tests and simple design, situational refactoring rules and security review principles added; companion tools listed; README updated
2026-11-02: rule added: test programs in a container (Docker Desktop or a free alternative)
2026-11-02: rules added: task cards for agents, git from the start, mock-ups built from product code, one check command
2026-11-02: restructured into a short SKILL.md and references/ loaded on condition; duplicates merged; executor subagent check added as question 6; description shortened
2026-11-02: review interval changed from 90 days to once a month
2026-11-02: short help when called without a task; responses in the user's language; load conditions name observable triggers; loaded files are named in one line
2026-11-02: security floor added to SKILL.md; test rules sharpened (test with every behavior change, no editing tests to get green); references/wordpress.md added; rules on questions, no unrequested functions, own verification, time limits and no silent losses added; self-update now needs the user's yes; SKILL.md re-sorted
2026-11-02: technical safeguards stay optional; basic and full level described, README explains them in plain words
2026-11-02: help shows examples; setup check with security tips and full project check added, with scripts/check-setup.sh; monthly update check from GitHub, installed only after the user's yes by merge, keeping own changes
2026-11-02: local learning added: lessons, own rules (max 30) and measurements stay in local/; rules proposed from the second same mistake; monthly review prunes own rules and keeps security functions current
2026-11-02: checking tools run in containers through scripts/run-tool.sh, project read-only; limit for own rules raised to 100
2026-11-02: help and description name the whole skill, not only the user's rules
2026-11-02: prompt creator added: a direct call with an own prompt sharpens the prompt first, then does the work
2026-11-02: works across agents: neutral wording, setup check looks in the Claude Code, Codex and Copilot skill folders, README shows installation per tool
2026-11-02: monthly review now optimizes the skill and adds what is missing; length alone is no reason to shorten it
2026-11-02: rule added: compare instructions with the context and ask about what may be forgotten
2026-11-03: renamed from code-rule-skill to vibecode-help; repository moved to github.com/Worker1245/vibecode-help
2026-11-03: renamed from vibecode-help to vibecoding-security; repository moved to github.com/Worker1245/vibecoding-security
2026-11-07: rule added: check every push for personal data, including commit metadata; licence names the GitHub account
2026-11-07: help names the command lists "claude commands" and "secret claude commands", handed over to the claude-code-help skill
2026-11-07: command lists end with suggestions that fit the user
2026-11-07: PHP and Java security rules added (references/php.md, references/java.md), based on a sourced research report; WordPress rules build on them
