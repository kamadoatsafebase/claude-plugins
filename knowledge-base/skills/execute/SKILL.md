---
name: execute
description: Execute the next pending implementation step for a KB project. Use when the user types /execute <project> and wants to run the lowest-numbered pending step.
---

# /execute

Execute one and only one next pending step from a KB project.

Usage: `/execute <project-name>`

@../../docs/structure.md

---

Extract the project name from args. If not provided, ask for one.

## Phase 1 — Discover the next step

Spawn a subagent to run:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/kbctl next <project>
```

If exit code is 2, report: `Project '<project>' not found in KB.` and stop.

If output is empty, report: `No pending steps for '<project>'. Nothing to do.` and stop.

The output is the step filename (e.g. `step-01-setup.md`). Call it `<step-file>`.

Get the project directory:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/kbctl path <project>
```

Read the full content of `<project-dir>/implementation/pending/<step-file>`.

## Phase 2 — Execute the step

Follow the step file exactly:
- `# Title` — the step name
- **Goal** paragraph — what this step achieves
- `## Steps` — execute every numbered item in order:
  - Perform the **Action** described
  - Verify the **Expected** outcome
  - Run any **Validation** commands specified

Delegate shell commands and file operations to subagents as needed.

**Safety constraints — before executing any sub-step, read the entire step file and scan for the patterns below. If any match, stop and ask the user before starting any execution:**
- Any `rm -rf` with a directory target (regardless of path)
- Any mass file-delete (`find … -delete`, `xargs rm`, or similar) regardless of path
- Force-push to any git remote (`git push --force`, `git push -f`)
- Any SQL DDL that drops or truncates (`DROP TABLE`, `TRUNCATE`, `DROP DATABASE`, `DROP SCHEMA`)
- `terraform destroy`
- `kubectl delete namespace` or `kubectl delete` on cluster-scoped resources
- Any `gcloud … delete` on projects, clusters, or databases
- Any `aws … delete` or `aws s3 rb` command
- Any `gsutil rm -r` or `az … delete` command

If any sub-step fails, stop immediately, do NOT move the file, and report what failed and what was completed so far.

## Phase 3 — Move the step to complete

Spawn a subagent to run:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/kbctl move <project> <step-file>
```

If non-zero exit, report the error and do NOT print the success template.

## Phase 4 — Report

```
Executed: <step-title>
  Project : <project-name>
  Step    : <step-file>
  Status  : complete
  Moved to: implementation/complete/<step-file>
```
