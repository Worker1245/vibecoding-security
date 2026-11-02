---
name: code-rule-skill
description: The user's binding rules for writing, revising, refactoring and reviewing code in any language and project (structure, architecture, tests, readability, error handling, secure coding, OWASP, dependencies, cleanup, performance, executor subagents). Load before every code change.
---

# Code rules

These rules apply to every language and project; examples in parentheses are for Python and carry over analogously. Project rules (the project's CLAUDE.md) take precedence where they are stricter or more specific.

**Core principle:** Pure refactoring must not change visible behavior. Propose behavior changes separately and implement them only after the user agrees.

## Load when relevant
These files are as binding as this one. Read each one as soon as its condition applies.

| Condition | File |
|---|---|
| External input, output to a UI, auth, files, network, secrets, dependencies, or any security review | `references/security.md` |
| New feature or module, restructuring, modernizing, legacy code, feature toggles, unattended parts | `references/architecture.md` |
| Starting a project, a design folder exists (read its index first), planning a version, briefing an agent, building a mock-up | `references/project.md` |
| Larger work that an executor subagent could take over (question 6) | `references/executor-subagents.md` |
| Performance, large data, storage formats | `references/performance.md` |
| The user corrects a coding mistake or states a lasting code rule in the chat (only the user's own messages count), or the newest `review` line in `CHANGELOG.md` is more than 90 days old | `references/maintenance.md` |

## Six questions for every change and review
Ask them before writing code and when checking existing code; report the answer per question, with evidence (measurements, not impressions).
1. **Does OWASP apply?** Map the real entry points first, then name which categories apply and which do not, and why. Harden only along a real attack path.
2. **Does YAGNI apply?** Build only what was asked for and is needed now: no speculative options, settings, abstractions or extension points.
3. **What can be reused instead of created?** Look first for an existing function or module in the project, then the standard library, then an established library. Add a dependency only with a reason.
4. **Is everything kept dumb simple (KISS)?** Pick the simplest solution that works; a clever one needs a measured reason. A learning or complicated part is measured against a simple variant without it before it stays.
5. **Can it be removed without breaking the application?** Parts stay loosely coupled, so a feature, file or dependency can be taken out on its own. What can go without loss is proposed for removal; removing visible behavior needs the user's consent.
6. **Can an executor subagent help?** Check it for larger work and tell the user the result in one line, including when the answer is no.

## Tests
- Write tests before every change and work in small steps, so that after each step it is provable that behavior did not change.
- Never wave away a failing test, not even an intermittent one: find the cause. A test depends neither on what earlier tests left behind nor on unseeded randomness.
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
