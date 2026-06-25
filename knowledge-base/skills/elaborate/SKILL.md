---
name: elaborate
description: Elaborate a KB project — create its structure if new, then work collaboratively with the user to define intent, context docs, and implementation steps. Use when the user types /elaborate <project>.
---

# /elaborate

Set up and collaboratively build out a KB project.

Usage: `/elaborate <project-name>`

@../../docs/structure.md

---

Extract the project name from args. If not provided, ask for one.

## Phase 1 — Ensure project exists

Spawn a subagent to run:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/kbctl init <project-name>
```

If the output starts with `Created:`, report it. If `exists`, continue silently. If non-zero exit, stop and report the error.

## Phase 2 — Read current state

Spawn a subagent to get the project directory:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/kbctl path <project-name>
```

Using the returned path as `<project-dir>`, read:
- `<project-dir>/index.md`
- All files in `<project-dir>/context/`
- All step files in `<project-dir>/implementation/pending/`
- All step files in `<project-dir>/implementation/complete/`

## Phase 3 — Collaborate

Engage the user in an open conversation to clarify and build out the project. Drive toward:

1. **Intent** — what this project is and why it exists
2. **Target Directory Structure** — the concrete outcome (files, dirs, infra, etc.)
3. **Future Work** — known gaps and next steps
4. **Implementation steps** — discrete, executable phases toward the target
5. **Context docs** — reference material (architecture, design decisions, resources) for `context/`

Ask questions. Propose structure. Push back on vague goals. Write files as the conversation converges — don't wait until the end.

## Phase 4 — Write

Create or update files under `<project-dir>`, following the formats in `structure.md` above:

- **`index.md`** — Intent, Target Directory Structure, Future Work
- **`context/*.md`** — explain *why* and *how*, not execution history
- **`implementation/pending/step-NN-<slug>.md`** — numbered from the next unused index; each file: `# Title`, **Goal** paragraph, `## Steps` with numbered items (Action, Expected, Validation)

Rename or resequence existing step files if needed.
