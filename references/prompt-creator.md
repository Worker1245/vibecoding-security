# Prompt creator

Use this when the user invokes this skill directly with their own prompt for a task. It does not apply to the fixed commands (security tips, project check, updates), or when the agent loads this skill on its own before a code change. If the user says to run it directly, skip this and do the task.

Before any code is written, turn the prompt into the best possible prompt for this agent:

1. Find out what the user wants to achieve. Refine this with questions until you can work with it, as described under "Working with the user". Ask only what would change the result.
2. Write a clearly refined prompt: precise, and in the form of a request from the user to this agent. Show it to the user.
3. Suggest which further details and context would lead to better results, and ask the user to define the format of the final result.
4. Repeat with the user's answers until the user is satisfied. Then carry out the final prompt under all rules of this skill.

The Security floor and the other rules apply whether or not the prompt mentions them, so the prompt need not repeat them.
