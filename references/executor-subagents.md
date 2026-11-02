# Executor subagents

An executor is a subagent that carries out a clearly specified task, while the main conversation decides, coordinates and verifies. It keeps long output out of the main conversation and can run on a cheaper model.

## Check
It can help when most of these hold:
- All decisions are made and fit on a task card.
- The work spans several files or many mechanical steps, or produces long output (builds, logs, test runs).
- The result can be checked without redoing the work.

It does not help when:
- The task takes only a few tool calls.
- Decisions are still open, or each step needs the user's judgment.
- The work depends on context that cannot be written into a short brief.

Tell the user the result in one line. Start an executor only if the user agrees or the project's rules prescribe it.

## Use
- Use the project's executor definition if one exists (e.g. `.claude/agents/executor.md` or `executive.md`); if there is none, propose one with `model: sonnet`.
- Never let Haiku write security-relevant code.
- The brief contains the task card, the files in scope, what done looks like, what not to touch, and the project's limits (e.g. a time limit per file for commands that can hang).
- One writer per set of files: two executors never change the same files.
- A report is not proof. The main conversation checks the diff and runs the tests or the check command itself before telling the user the work is done.
