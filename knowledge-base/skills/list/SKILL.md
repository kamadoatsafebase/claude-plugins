---
name: list
description: List all KB projects with their pending step counts and titles. Use when the user types /list and wants an overview of knowledge-base projects.
---

# /list

List all knowledge-base projects and their pending implementation steps.

Usage: `/list`

@../../docs/config.md

---

Extract `KB_ROOT` from the config above. Spawn a subagent to run:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/skills/list/scripts/list-projects.sh" KB_ROOT
```

Substitute `KB_ROOT` with the literal configured value — the shell expands `~` automatically.

Print the output exactly as returned.
