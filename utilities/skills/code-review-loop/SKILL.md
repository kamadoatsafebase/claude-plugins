---
name: code-review-loop
description: Run /code-review repeatedly, verify findings, fix valid ones, and repeat until clean or 5 turns exhausted. Use when the user types /code-review-loop.
---

# /code-review-loop

Run code-review → triage → fix → amend, up to 5 turns, stopping early when no valid findings remain.

Usage: `/code-review-loop [args]` — args are forwarded to each `/code-review` call.

> **Prerequisite:** The built-in `code-review` skill (ships with Claude Code).

---

Maintain a turn counter starting at 0. Repeat until it reaches 5 or a stop condition is met.

## Each turn

**Step 1 — Run code-review.** Increment the counter. Invoke `code-review` via the Skill tool, forwarding any args. Parse the JSON findings array from the last JSON code block. If empty:

```
code-review-loop: clean. Done after <N> turn(s).
```

Stop.

**Step 2 — Triage.** Spawn a sub-agent with: the findings array, the unified diff (`git diff @{upstream}...HEAD`; fall back to `git diff HEAD~1`), and file content around each finding's line. Classify each finding as:

- **fix** — genuine correctness bug with a concrete failure scenario that should be addressed now
- **skip** — style, cleanup, efficiency, altitude, or already handled in the diff

If the fix list is empty:

```
code-review-loop: <N> finding(s) reviewed — all style/altitude/already-fixed. Done after <turn> turn(s).
```

Stop.

**Step 3 — Fix.** Spawn a sub-agent with the fix findings. For each, read the file at the indicated line and apply the minimal edit that eliminates the failure — no cleanup, no added comments, no refactoring beyond the fix. After all edits:

> **Note:** `--no-verify` skips pre-commit hooks — re-run them manually if your workflow requires it. `git add -A` stages all untracked files, not only edited ones — ensure no unrelated files (secrets, generated output) are present.

```bash
git add -A && git commit --amend --no-edit --no-verify
```

Report which findings were fixed and which were skipped with a one-line reason.

**Step 4 — Next turn.** Return to Step 1.

## After turn 5

```
code-review-loop: reached 5-turn limit. Remaining findings:
<JSON array of last verified fix findings>
```

Stop.
