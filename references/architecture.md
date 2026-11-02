# Architecture and refactoring

## Architecture
- Source code dependencies point inward only: business logic names no framework, database or UI. Those are details behind an interface the inner code owns.
- Data crossing a boundary is a simple structure shaped for the inner side, never a database row or framework object. SQL stays in the persistence layer.
- Top-level folders name what the application does, not the framework, where the framework allows it.
- Start with presentation, domain logic and data access separated; split larger systems by domain first, then by layer.
- For each application, check whether the four Clean Architecture layers (entities, use cases, interface adapters, frameworks and drivers) are worth their cost, and state the result in one line. Use them only if size and expected change justify it; the dependency rule above applies regardless.
- Whatever runs unattended is bounded by construction (memory, stored data, anything it learns). The limits themselves are tested and measured in a long run.

## Refactoring and modernization
- Look for outdated patterns, libraries or language constructs that have better, established alternatives today, and propose them with reasons.
- Before a larger restructuring, state the plan briefly and wait for approval.
- A new version (program, mock-up, document) loses nothing silently, even when it is built differently. Before building, list the functions of the previous version, explicitly including test and demo helpers. Afterwards check the list point by point; name what is dropped or impossible when handing over, and remove something only after the user's consent.
- Replace legacy code gradually: build the new part alongside the old and move behavior over; no rewrite in one step.
- Keep the place that checks a feature toggle apart from the logic that decides it, and remove the toggle once it is no longer needed.
- Treat a code smell as a prompt to look, not as a defect: confirm a real problem before changing the code.
