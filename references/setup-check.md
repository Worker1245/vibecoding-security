# Setup check and security tips

Use this when the user asks for security tips or what is set up. Change and install nothing.

1. Run `scripts/check-setup.sh` from this skill's folder. It reports each skill, program and container runtime as OK, MISSING or STOPPED (installed but not running).
2. Show the result as a short table in plain words: name, status, what it is for. Say which gaps matter for this project; for example, the PHP tools only matter for PHP projects.
3. Give the tips that fit the gaps, most important first, each with one concrete next step:
   - The rules of the Security floor apply to every change, even when nobody asks for them.
   - No container runtime running: tests depend on this machine. Name Docker Desktop or a free alternative.
   - Missing scanners or skills: name what each would add. Third-party skills are reviewed before installing (e.g. with SkillSpector).
   - Rules are text and cannot force anything: explain the optional technical safeguards from `security.md`.
4. End with the next step: `/code-rule-skill check my project`, in the user's language. Install something only if the user asks for it.
