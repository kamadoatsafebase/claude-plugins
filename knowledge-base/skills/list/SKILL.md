---
name: list
description: List all KB projects with their pending step counts and titles. Use when the user types /list and wants an overview of knowledge-base projects.
---

# /list

List all knowledge-base projects and their pending implementation steps.

Usage: `/list`

@../../docs/config.md

---

Extract `KB_ROOT` from the config above. Run via Bash (substitute the actual `KB_ROOT` value — never pass it literally):

```bash
KB_ROOT=<resolved-kb-root> <plugin-dir>/bin/kb list
```

where `<plugin-dir>` is the knowledge-base plugin root (the directory containing `bin/kb`).

Print the output exactly as returned.
