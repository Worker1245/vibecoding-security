# Contributing

Rule proposals, corrections and reports of agents ignoring a rule are welcome.

## Proposing a rule

Open an issue with the **Rule proposal** template. A good proposal:
- states the rule in one English sentence and names the target file (`SKILL.md` for what applies to every change, `references/` for everything else)
- shows the mistake it prevents, as a minimal, made-up example
- cites an official source for security facts (OWASP, the language or framework documentation)

Rules are written in English, stay short and general, and never lower the security floor.

## Pull requests

- Keep each pull request to one topic.
- Run the tests before you open it:

  ```bash
  for t in tests/*.test.sh; do bash "$t"; done
  ```
- Add a line to `CHANGELOG.md`: `YYYY-MM-DD: <what changed>`.

## Privacy

Never include personal data, secrets, local paths or code and content from your own projects in issues, pull requests or commits. Use made-up names such as `$input` or `doThing()`.
