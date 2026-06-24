---
name: list
description: List all KB projects with their pending step counts and titles. Use when the user types /list and wants an overview of knowledge-base projects.
---

# /list

List all knowledge-base projects and their pending implementation steps.

Usage: `/list`

@../../docs/config.md

---

Extract `KB_ROOT` from the config above. Substitute its literal value everywhere in this skill — in shell commands **and** in file path arguments to Read/Write tools. Never pass the string `$KB_ROOT` literally to any tool.

## Execution

Spawn a subagent to:

1. Run: `find "$KB_ROOT" -mindepth 1 -maxdepth 1 -type d | sort`
   This lists all project directories as full paths. The project name for display is the final path segment (basename) of each path. Collect this as the project list.
2. For each project path from step 1, run (using the full path directly as `<project-path>`):
   `find "<project-path>/implementation/pending" -maxdepth 1 -name 'step-*.md' 2>/dev/null | sort -V`
   Collect the resulting filenames as that project's pending steps.
3. Collect all pending step file paths from step 2. If there are no pending step files across all projects, skip this step. Otherwise run `head -1` once, passing all paths as arguments, to get each file's `# Title` heading. Use the actual paths — not placeholder paths.
4. Emit the output directly in the format below — do not return intermediate structured data.

## Output format

One block per project, sorted alphabetically:

```
<project-name>  (<N> pending steps)
  • step-01-foo.md — Do the first thing
  • step-02-bar.md — Do the second thing

<project-name-2>  (0 pending steps)
```

If no project directories exist, print: `No KB projects found.`
