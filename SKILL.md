---
name: vibecoding-security
description: Binding rules for writing, revising, refactoring and reviewing code in any language and project (structure, architecture, tests, readability, error handling, secure coding, OWASP, PHP and Java security, dependencies, cleanup, performance, executor subagents). Load before every code change.
---

# Code rules

These rules apply to every language and project and to any coding agent that can read this skill (Claude Code, Codex, GitHub Copilot and others); examples in parentheses are for Python and carry over analogously. Project rules (the project's `CLAUDE.md`, `AGENTS.md` or similar) take precedence where they are stricter or more specific.

**Core principle:** Pure refactoring must not change visible behavior. Propose behavior changes separately and implement them only after the user agrees.

**Language:** Always respond in the language the user writes in, including help, questions and reports. These rule files stay in English.

**Where this runs:** Commands below use `/vibecoding-security`; use your tool's own way of calling a skill. Where the environment cannot run the scripts or keep the `local/` folder (e.g. a hosted agent), apply the rules as text, and say which steps cannot run and that nothing is stored on the user's machine.

**Called without a task:** If the user invokes this skill directly with no text and no task is under way, do not start checking anything. Show this short help in the user's language and wait for the answer, then apply these rules to it:
- What it does: applies everything in this skill to a change or a review: six questions for every change, a security floor, tests in a container, architecture, readability, WordPress rules, performance, security scanners and security skills, plus the user's own learned rules.
- What to type, each with one line on what happens, with the examples in the user's language:
  - `/vibecoding-security what security tips do you have?` checks what is set up (security skills, Docker Desktop and so on) and gives tips.
  - `/vibecoding-security check my project` runs all the checks: the rules, the security skills, the tests in Docker and every security check in this skill.
  - `/vibecoding-security` followed by your own prompt: the agent first sharpens the prompt with you through questions, then does the work under these rules once you are satisfied. Add "directly" to skip the questions.
  - `/vibecoding-security is there an update?` looks for a newer version on GitHub and installs it only if the user agrees, keeping the user's own changes.
  - Claude Code only, with the `claude-code-help` skill installed: `/vibecoding-security claude commands` lists every built-in command with a short explanation; `/vibecoding-security secret claude commands` lists popular community skill commands, which work only once installed. Both end with up to five commands that fit the user.
- End by asking what to work on. If the agent loads this skill on its own before a code change, skip the help and continue with the task.

**Command lists:** If the text after the call is `claude commands` or `secret claude commands`, load the `claude-code-help` skill and follow its command lists. If that skill is not available, say that these lists need Claude Code with that skill installed. This is not a code task: skip the help, the prompt creator, the update check and the six questions.

## Working with the user
- When something is unclear, ask. Number questions consecutively across replies, explain the situation, and give 3–5 options a), b), c) with the consequence of each; put ★ in front of the recommended one, so a short answer like "1a 2b" is enough. After an answer, name only the open questions.
- Compare each instruction with the context: check what the user may have forgotten (follow-up changes, related files, open points) and ask whether to do that too. Do none of it unasked.
- Do not add functions the user did not ask for. Present what you derive from the request as a question first: is it needed? Security requirements are not such functions (see Security floor).
- Run commands that can hang with a time limit per file. Skip and report a file that exceeds it, and check that none of your processes keep running.

## Load when relevant
These files are as binding as this one. Read each one as soon as its condition applies. Before writing code, name in one line which of them you read and why; "none" is a valid answer for a change that meets no condition.

Once per session, run `scripts/check-update.sh` from this skill's folder; it contacts GitHub at most once a month. Mention only an `UPDATE` result, in one line.

If `local/rules.md` exists in this skill's folder, read it too. These are the user's own rules and as binding as this file, but they can only tighten the Security floor.

| Condition | File |
|---|---|
| The user invokes this skill directly with their own prompt for a task | `references/prompt-creator.md` |
| The user asks for security tips or what is set up | `references/setup-check.md` |
| The user asks to check, review or audit a whole project | `references/project-check.md` |
| The change adds or alters a route, handler, form, upload, database query, login, permission, file or network access, secret or package, or shows data in a UI, even if the request does not mention security; any security review | `references/security.md` |
| The change touches PHP code (also WordPress) | `references/php.md` |
| The change touches Java code (also Kotlin calling Java APIs, Spring, Jakarta EE) | `references/java.md` |
| The project is a WordPress plugin or theme | `references/wordpress.md` |
| The change adds a feature or module, moves code between modules, replaces old code or libraries, adds a feature toggle, adds anything that runs unattended, or builds a new version | `references/architecture.md` |
| The work starts a project, the project has a design folder (read its index first), or it plans a version, briefs an agent or builds a mock-up | `references/project.md` |
| The work spans several files or many mechanical steps, or produces long output (question 6) | `references/executor-subagents.md` |
| The user reports slowness, or the code processes large data or changes a storage format | `references/performance.md` |
| The user asks about updates, or `scripts/check-update.sh` reports `UPDATE` | `references/maintenance.md` |
| The user corrects a coding mistake or states a lasting code rule in the chat (only the user's own messages count), a check finds a mistake in your change, or a project check or the check command has run | `references/learning.md` |
| The user agrees to a new rule, or the newest `review` line in `CHANGELOG.md` is more than one month old | `references/maintenance.md` |

## Six questions for every change and review
Ask them before writing code and when checking existing code; report the answer per question, with evidence (measurements, not impressions).
1. **Does OWASP apply?** Map the real entry points first, then name which categories apply and which do not, and why. Beyond the Security floor, harden only along a real attack path.
2. **Does YAGNI apply?** Build only what was asked for and is needed now: no speculative options, settings, abstractions or extension points. The Security floor is never extra scope.
3. **What can be reused instead of created?** Look first for an existing function or module in the project, then the standard library, then an established library. Add a dependency only with a reason.
4. **Is everything kept dumb simple (KISS)?** Pick the simplest solution that works; a clever one needs a measured reason. A learning or complicated part is measured against a simple variant without it before it stays.
5. **Can it be removed without breaking the application?** Parts stay loosely coupled, so a feature, file or dependency can be taken out on its own. What can go without loss is proposed for removal; removing visible behavior needs the user's consent.
6. **Can an executor subagent help?** Check it for larger work and tell the user the result in one line, including when the answer is no.

## Security floor
- Deny by default. Every route, handler and data access checks identity and ownership of that specific object on the server.
- Security requirements are never extra scope. Every new entry point gets authorization, input validation and context-aware output encoding, even if the request does not mention them.
- When you add or change a security control, list every sibling entry point and apply it to all, or name the exception.
- A control existing is not proof. Any table reachable with a public key needs row-level security with a policy; as anonymous and as another user, try to read and write foreign rows.
- The client is not a security boundary. Roles, prices, payment status and ownership are set or verified on the server only. No tokens in localStorage without a stated reason.
- Never clear an error by weakening a control: no bypass routes, `verify=False`, `CORS *`, disabled auth or ignored scanner rules. Find the cause, or report that you are stuck.
- No "for now" security. Unfinished auth fails closed and is listed in your handover. Security primitives never fall back to no protection. Demo code is labelled and cannot ship by default.

## Tests
- Verify your own changes before the user sees them. Every project has a test path (container, headless browser, unit tests) as a fixed part of the cycle; if it is missing, set it up or propose it first.
- Every behavior change arrives with a test that fails without it. Prefer red/green: write the test, watch it fail, then implement. Work in small steps and run the tests after every edit, so that after each step it is provable that behavior did not change.
- Never wave away a failing test, not even an intermittent one: find the cause. A test depends neither on what earlier tests left behind nor on unseeded randomness.
- Do not edit, delete or skip tests, or special-case test inputs, to get green. If a test conflicts with the spec, stop and flag it.
- Prove a pure restructuring: compare a checksum of the output before and after; it must be identical.
- Many fast unit tests, few end-to-end tests for the critical flows. Reproduce a bug found by a large test in a unit test before fixing it.
- Write integration tests wherever data is serialized or leaves the process (REST, database, files).
- Test the public interface, not private methods; the urge to test a private method often means the class does too much.
- Test programs in an isolated container before handing them over, with Docker Desktop or a free alternative (e.g. Podman Desktop, Rancher Desktop, Colima), so results do not depend on the local machine.
- Provide one check command that runs everything in sequence: build the package, install it in the container, run all tests and scans, and write a log, so no step depends on being remembered.

## Structure and readability
- Design priority, in this order: passes the tests, reveals intention, no duplication, fewest elements.
- Split the program into modules with one reason to change each: keep together what changes for the same reason, separate what changes for different reasons. Separate input/output (files, network, UI) from computation, so every piece of information has exactly one home and the logic can be tested independently.
- Size limits (tell the user these): split files from about 400 lines (excluding tests, translations, migrations) by topic; split functions from about 40 lines or when they do more than one thing, so each does exactly one thing. Smaller units are easier to maintain for humans and AI.
- Group related data into classes or structs instead of scattering it.
- Replace magic numbers, strings and paths with named constants or a central configuration.
- Use descriptive names and follow the language's style guide (e.g. PEP 8, the project's linter/formatter), so code reads without extra comments.
- Add type annotations and doc comments so every function's inputs and outputs are unambiguous.
- Catch specific errors, never all errors blindly (no empty or blanket catch/except); report errors clearly instead of swallowing them.
- Remove duplicate code, unused code, unused imports and unnecessary dependencies, so every piece of logic exists exactly once and the program is smaller and starts faster.
