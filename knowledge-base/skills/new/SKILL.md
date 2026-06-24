---
name: new
description: Create a new KB project with the canonical skeleton. Use when the user types /new <project>.
---

# /new

Create a new knowledge-base project with the canonical directory structure.

Usage: `/new <project-name>`

@../../docs/structure.md
@../../docs/config.md

---

Extract `KB_ROOT` from the config above. Substitute its literal value everywhere in this skill — in shell commands **and** in file path arguments to Read/Write tools. Never pass the string `$KB_ROOT` literally to any tool.

Extract the project name from args. If no project name is provided, ask for one.

## Existence check

Before creating anything, spawn a subagent (the main agent must substitute `$KB_ROOT` and `<project-name>` with their actual values before spawning):

> Run: `test -d "$KB_ROOT/projects/<project-name>" && echo exists || echo new`
> Return the output.

If the result is `exists`: ask the user — "Project `<project-name>` already exists. Overwrite? (yes/no)" — and stop until they confirm. Only proceed if they answer yes.

## What to create

```
<project-name>/
├── index.md
├── context/
│   └── .gitkeep
└── implementation/
    ├── pending/
    │   └── .gitkeep
    └── complete/
        └── .gitkeep
```

### `index.md` content

```markdown
# <project-name>

## Intent

<!-- What is this and why does it exist -->

## Target Directory Structure

<!-- The actual codebase/infrastructure outcome -->

## Future Work

<!-- Known gaps and next steps -->
```

### `.gitkeep` files

Empty files to ensure empty directories are tracked by git.

## Execution

Spawn a subagent (the main agent must substitute `$KB_ROOT` and `<project-name>` with their actual values before spawning):

1. Run: `mkdir -p "$KB_ROOT/projects/<project-name>/context" "$KB_ROOT/projects/<project-name>/implementation/pending" "$KB_ROOT/projects/<project-name>/implementation/complete" 2>&1`
   Return the exit code and any output. Stop if non-zero.
2. Write `index.md` at `$KB_ROOT/projects/<project-name>/index.md` with the template above (substituting the actual project name).
3. Write empty `.gitkeep` files at:
   - `$KB_ROOT/projects/<project-name>/context/.gitkeep`
   - `$KB_ROOT/projects/<project-name>/implementation/pending/.gitkeep`
   - `$KB_ROOT/projects/<project-name>/implementation/complete/.gitkeep`

If any Write in steps 2-3 fails, stop immediately and report the error — do not emit the success report.

After completion, report (substitute `<kb-root>` with the resolved KB_ROOT value and `<project-name>` with the actual project name):

```
Created KB project: <project-name>
  <kb-root>/projects/<project-name>/index.md
  <kb-root>/projects/<project-name>/context/.gitkeep
  <kb-root>/projects/<project-name>/implementation/pending/.gitkeep
  <kb-root>/projects/<project-name>/implementation/complete/.gitkeep
```
