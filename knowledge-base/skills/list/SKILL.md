---
name: list
description: List all KB projects with their pending step counts and titles. Use when the user types /list and wants an overview of knowledge-base projects.
---

# /list

List all knowledge-base projects and their pending implementation steps.

Usage: `/list`

---

Spawn a subagent to run:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/kbctl list
```

Print the output exactly as returned.
