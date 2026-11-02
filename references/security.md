# Security (secure coding, shift left)

- Build security into the whole development lifecycle: before new features, do a short threat model (e.g. STRIDE: who attacks what through which interface, which control prevents it) and report the result to the user.
- Validate all external input and treat it as untrusted.
- Least privilege: every component gets only the rights it needs (database roles, API keys, file permissions, CI tokens).
- Zero trust: no component trusts another blindly; every request is authenticated and authorized, and the check lives on the server, never only in the UI.
- Prevent injection: parameterized queries / prepared statements instead of building commands from input; no shell commands built from input.
- Prevent XSS: context-appropriate output encoding (e.g. `<` becomes `&lt;`), no `innerHTML` with untrusted data, links only with allowed schemes.
- Prevent path traversal and unsafe deserialization with safe standard libraries, not home-grown solutions.
- No secrets in code or the repository; use environment variables or a secure store.
- Store passwords only salted and hashed with strong algorithms (Argon2id, bcrypt); encrypt data in transit end to end (TLS); compare secrets in constant time.
- Memory safety: in C/C++ avoid unsafe functions (e.g. `strcpy`, `gets`); prefer memory-safe languages (e.g. Rust) where possible.
- Check dependencies for known vulnerabilities (e.g. `npm audit`, `pip-audit`), update outdated versions and tell the user what changed.
- Benchmarks: current OWASP guidance (Top 10, ASVS), NIST Secure Software Development Framework (SSDF), SEI CERT Coding Standards. Always state the security trade-offs of a change.

## Judging findings
- Whoever checks a finding did not find it; the checker tries to disprove it.
- Severity requires concrete impact, not deviation from a checklist.
- If one layer already prevents the attack, a missing further layer is a hardening note, not a vulnerability.
- A lead without proof stays `needs_validation`, with the exact open fact; never report it as confirmed.

## Tools
Use these skills where installed; otherwise continue with the rules above:
- `owasp-security`: secure implementation and focused security review.
- `semgrep`: static pattern scan, including PHP and WordPress code.
- `differential-review`: security review of a diff or pull request.
- `variant-analysis`: after a bug is found, search for the same root cause elsewhere.
- `supply-chain-risk-auditor`: dependency audit for npm, Python and Go, not Composer. It sends dependency names to external services.
- `security-audit`: comprehensive audit of a whole codebase.
- [SkillSpector](https://github.com/NVIDIA/SkillSpector): scan a skill before installing or publishing it, when a project builds or installs skills.
- [OpenAnt](https://github.com/knostic/OpenAnt): optional second opinion, mention only; install or run it only at the user's request. PHP support is beta, it needs a separately billed API key with no spend limit, and code goes to the chosen LLM provider unless a local model is used.

## Optional technical safeguards
This skill is text: it instructs Claude but cannot force anything. No technical safeguard is set up by default. When the work touches production data, destructive actions or secrets, mention this once and offer the two levels below in plain words. Set them up only at the user's request, and agree on each one first.
- **Basic:** block destructive commands and secret files through permission rules, plus a secret scan before each commit.
- **Full:** Basic, plus a sandbox, a package check, a notice when existing tests change, and an extended check command.
