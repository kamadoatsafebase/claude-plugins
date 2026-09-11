---
name: code-review-loop
description: Run /code-review again and again, verify the findings, fix the valid ones, and repeat until the review is clean or 5 turns are done. Use when the user types /code-review-loop.
---

# /code-review-loop

Run code-review, triage the findings, fix them, then amend the commit. Do a maximum of 5 turns. Stop early when no valid findings are left.

Usage: `/code-review-loop [args]`. The args go to each `/code-review` call.

> **Prerequisite:** The built-in `code-review` skill (ships with Claude Code).

---

Keep a turn counter. Start it at 0. Repeat the turn until the counter is 5, or until a stop condition occurs.

## Each turn

### Step 1 — Run code-review

Increment the counter. Invoke `code-review` through the Skill tool, and forward any args. Parse the JSON findings array from the last JSON code block. If the array is empty, print:

```
code-review-loop: clean. Done after <N> turn(s).
```

Stop.

### Step 2 — Triage

Spawn a sub-agent. Give it the findings array and the unified diff (`git diff @{upstream}...HEAD`, or `git diff HEAD~1` if that command fails). Also give it the file content around the line of each finding. Put each finding in one of two classes:

- **fix**: a true correctness bug with a concrete failure scenario to correct now.
- **skip**: style, cleanup, efficiency, altitude, or already corrected in the diff.

If the fix list is empty, print:

```
code-review-loop: <N> finding(s) reviewed — all style/altitude/already-fixed. Done after <turn> turn(s).
```

Stop.

### Step 3 — Fix

Spawn a sub-agent and give it the fix findings. For each finding, read the file at the given line. Apply the minimal edit that removes the failure. Do no cleanup, add no comments, and do not refactor anything else. After all the edits:

> **Note:** `--no-verify` skips pre-commit hooks. Run them manually if your workflow needs it. `git add -A` stages all untracked files, not only the edited files. Make sure that no unrelated files (secrets, generated output) are present.

```bash
git add -A && git commit --amend --no-edit --no-verify
```

Report which findings you fixed and which you skipped, with a one-line reason.

### Step 4 — Next turn

Go to Step 1.

## After turn 5

```
code-review-loop: reached 5-turn limit. Remaining findings:
<JSON array of last verified fix findings>
```

Stop.
