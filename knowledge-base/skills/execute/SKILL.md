---
name: execute
description: Execute the next pending implementation step for a KB project. Use when the user types /execute <project> and wants to run the lowest-numbered pending step.
---

# /execute

Execute one and only one next pending step from a KB project.

Usage: `/execute <project-name>`

@/Users/kamadorueda/data/personal/claude-plugins/knowledge-base/docs/structure.md
@/Users/kamadorueda/data/personal/claude-plugins/knowledge-base/docs/config.md

---

Extract `KB_ROOT` from the config above. Substitute its literal value everywhere in this skill — in shell commands **and** in file path arguments to Read/Write tools. Never pass the string `$KB_ROOT` literally to any tool.

Extract the project name from args. If no project name is provided, ask for one.

## Phase 1 — Discover the next step

Spawn a subagent (substitute `$KB_ROOT` and `<project>` with their actual values before spawning):

> Run command 1: `test -d "$KB_ROOT/<project>" && echo __EXISTS__ || echo __NOT_FOUND__`
> Run command 2: `ls "$KB_ROOT/<project>/implementation/pending/" 2>/dev/null | grep '^step-.*\.md$' | sort -V`
> Return the single-line output of command 1 first, then the output of command 2.

If command 1 output is `__NOT_FOUND__`, report: `Project '<project>' not found in KB.` and stop.

If command 2 output is empty, report: `No pending steps for '<project>'. Nothing to do.` and stop.

Pick the **first** filename — call it `<step-file>`. Read the full content of the step file by substituting the resolved `KB_ROOT` value and the project name into the path — do not pass `$KB_ROOT` literally to the Read tool.

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
- Deleting or overwriting files outside the KB root

If any sub-step fails, stop immediately, do NOT move the file, and report what failed and what was completed so far.

## Phase 3 — Move the step to complete

After all sub-steps succeed, spawn a subagent (substitute `$KB_ROOT`, `<project>`, and `<step-file>` with their actual values before spawning):

> Run: `mv "$KB_ROOT/<project>/implementation/pending/<step-file>" "$KB_ROOT/<project>/implementation/complete/<step-file>" 2>&1`
> Return the exit code and any stderr output.

**If the exit code is non-zero:** do NOT print the success template. Report:

```
Move failed (exit <code>): <stderr>
Step remains in: implementation/pending/<step-filename>
```

and stop.

## Phase 4 — Report

```
Executed: <step-title>
  Project : <project-name>
  Step    : <step-filename>
  Status  : complete
  Moved to: implementation/complete/<step-filename>
```
