---
name: code-review-loop
description: Run /code-review repeatedly, verify findings, fix valid ones, and repeat until clean or 5 turns exhausted. Use when the user types /code-review-loop.
---

# /code-review-loop

Iteratively run code-review → verify → fix → amend commit, up to 5 turns, stopping early when no valid findings remain.

Usage: `/code-review-loop [args]`

Any args are forwarded to each `/code-review` invocation (e.g. a branch name or file path).

---

> **Prerequisite:** This skill requires the built-in `code-review` skill, which ships with Claude Code and is available by default.

Maintain a **turn counter** starting at 0. Repeat the following loop until the counter reaches 5 or a stop condition is met.

## Each turn

### Step 1 — Run code-review

Increment the turn counter. Invoke the `code-review` skill (via the Skill tool) forwarding any args.

Parse the JSON findings array from its output (the last JSON code block). If the array is `[]`, print:

```
code-review-loop: clean. Done after <N> turn(s).
```

and stop.

### Step 2 — Triage findings

Spawn a sub-agent. Give it:
- The full findings array from Step 1.
- The current unified diff (run `git diff @{upstream}...HEAD`; fall back to `git diff HEAD~1` if that produces no output).
- For each finding, the actual file content around the indicated line.

Instruct it to classify each finding as one of:
- **fix** — a genuine correctness bug with a concrete failure scenario that should be addressed now.
- **skip** — style, cleanup, efficiency, altitude, or a finding that is provably already handled in the diff.

Return a JSON array of only the **fix** findings, preserving the original `file`, `line`, `summary`, and `failure_scenario` fields.

If the fix array is empty, print:

```
code-review-loop: <N> finding(s) reviewed — all style/altitude/already-fixed. Done after <turn> turn(s).
```

and stop.

### Step 3 — Fix findings

Spawn a sub-agent with the fix-array findings. For each finding in order:

1. Read the file at the indicated line.
2. Understand the `failure_scenario`.
3. Apply the **minimal** edit that eliminates the failure — change only what is required. No surrounding cleanup, no new comments, no refactoring beyond the fix.
4. Continue through all findings without stopping on the first.

After all edits are applied, amend the HEAD commit:

> **Note:** `--no-verify` is used intentionally to prevent pre-commit hooks from blocking the automated amend. Your hooks will not run on this commit — re-run them manually if required by your workflow.

```bash
git add -A && git commit --amend --no-edit --no-verify
```

Report back: which findings were fixed, and any that were skipped with a one-line reason.

### Step 4 — Next turn

Continue to Step 1 of the next turn.

## After turn 5

If 5 turns have elapsed without the loop stopping, print:

```
code-review-loop: reached 5-turn limit. Remaining findings:
<JSON array of last verified fix findings>
```

and stop.
