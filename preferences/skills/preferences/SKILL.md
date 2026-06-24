---
name: preferences
description: Load and apply user preferences from CLAUDE.md. Use when the user types /preferences or asks to follow their personal instructions and settings.
---

Read ~/.claude/CLAUDE.md. If the file exists, follow it completely. If it does not exist, inform the user:

"No preferences file found at ~/.claude/CLAUDE.md. Create this file with your personal instructions to use this skill. Example contents:

```
Always use conventional commits.
Prefer functional programming patterns.
Default language: TypeScript.
```
"
