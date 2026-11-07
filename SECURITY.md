# Security policy

This skill gives rules to coding agents and ships small shell scripts (`scripts/`) that start checking tools in containers.

## Reporting a vulnerability

Please report security problems privately through GitHub: **Security → Report a vulnerability** in this repository. Do not open a public issue for them.

Useful to include:
- what is affected (a script, a Docker call, or a rule that leads agents to insecure code)
- steps to reproduce, with a minimal, made-up example
- the impact you expect

Do not include secrets, personal data or code from your own projects.

## Scope

- In scope: the scripts in `scripts/`, the Docker image in `docker/`, and rules in `SKILL.md` or `references/` that are wrong or make code less secure.
- Out of scope: vulnerabilities in third-party tools (Semgrep, PHPCS, PHPStan, Composer, Trivy) or in the agents themselves; report those to their projects.

Only the latest version on `main` gets fixes.
