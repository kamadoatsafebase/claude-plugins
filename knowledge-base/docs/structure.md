# Project Structure Pattern

A reusable template for documenting projects in the knowledge vault.

## Directory Layout

```
projects/
├── {project-name}/           # Individual project directory
    ├── index.md              # Project overview & implementation status
    ├── {project-name}.canvas # Visual graph (optional)
    ├── context/              # Reference & design documentation
    │   └── *.md              # Domain-specific reference docs
    └── implementation/       # Historical execution records
        ├── pending/          # Steps not yet completed
        │   └── step-*.md     # Individual phase/task records
        └── complete/         # Completed steps
            └── step-*.md     # Individual phase/task records
```

## index.md Contents

Each project's `index.md` should contain:

1. **Intent** — What is this and why does it exist
2. **Target Directory Structure** — The actual codebase/infrastructure outcome
3. **Future Work** — Known gaps and next steps

## context/ Directory

Reference documentation that explains the project. Examples:
- `architecture.md` — Design decisions, patterns
- `repositories.md` or similar — Resource inventory
- `permissions.md` — Access/IAM patterns
- `integration.md` — How this fits with other systems

**Key principle**: context/ docs explain *why* and *how*, not the execution history.

Files are purely informational — no execution state or status tracking.

## implementation/ Directory

Records of how the project was built, organized by status:

- `pending/` — Steps not yet completed
- `complete/` — Steps that have been completed

Each step file should follow this structure (no frontmatter):

- `# Step Title` — Brief, clear title
- **Goal** — Brief paragraph explaining the objective
- `## Steps` — Numbered list with substeps:
  - **Action description** (what to do)
  - Expected: what success looks like
  - Validation: the exact command(s) to verify

**Moving steps:** When a step is completed, move its file from `pending/` to `complete/`.

## Top-level layout

```
~/kb/
├── projects/          # Active KB projects (managed by /new, /list, /execute)
└── completed-projects/  # Optional: archive directory for fully finished projects
```

`completed-projects/` is created by the first-time setup but is not managed by any skill — it is a manual archive location for projects you consider done.
