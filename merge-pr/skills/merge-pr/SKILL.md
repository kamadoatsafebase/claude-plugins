---
name: merge-pr
description: Babysit a PR until it's merged. Use when the user types /merge-pr or wants to monitor and auto-merge a pull request that is already approved.
---

## Prerequisites

This skill requires the [GitHub CLI (`gh`)](https://cli.github.com/) to be installed and authenticated. Run `gh auth status` to verify before using this skill.

# /merge-pr

Babysit a PR until it's merged. The PR is already approved.

Usage: `/merge-pr <PR_URL>`

---

You are the **orchestrator**. Never run `gh` or any shell command yourself — delegate every operation to a subagent. Your only job is to inspect subagent results and decide the next step.

Extract the PR URL from the args passed to this skill.

## Loop

### Step 1 — Check state

Spawn a **state-checker** subagent with this prompt:

> Run these two commands and return the raw output of both:
> 1. `gh pr view <PR_URL> --json state,mergeable,mergeStateStatus,statusCheckRollup`
> 2. `gh pr checks <PR_URL> 2>&1`

Parse the result and build this summary:
- `prState`: "OPEN" | "MERGED" | "CLOSED"
- `mergeStateStatus`: "CLEAN" | "BEHIND" | "BLOCKED" | "UNSTABLE" | "CONFLICTING" | "DIRTY" | "UNKNOWN"
- `pendingChecks`: names of checks where status is IN_PROGRESS, QUEUED, or state is PENDING
- `failedChecks`: names of checks where conclusion is FAILURE or ACTION_REQUIRED

### Step 2 — Decide

**MERGED** → report "PR merged. Done." and stop (no ScheduleWakeup).

**CLOSED** → report "PR was closed without merging." and stop.

**CLEAN** → spawn a **merger** subagent:
> Note: this skill always merges via squash and deletes the source branch after merge. If you need a different merge strategy, edit the command below.
> Run: `gh pr merge <PR_URL> --squash --delete-branch 2>&1`
> Then run: `gh pr view <PR_URL> --json state,mergedAt`
> Return both outputs.

Report the merge result and stop.

**BEHIND** → spawn a **branch-updater** subagent:
> Run: `gh pr update-branch <PR_URL> 2>&1`
> Return the output.

Log "Branch updated — waiting for checks to restart." Then schedule next check in ~90s.

**BLOCKED**:
- If `failedChecks` is non-empty → report "Required check failed: `<name>`. Manual fix needed." and stop.
- If `pendingChecks` is non-empty → log "Waiting for: `<names>`." Schedule next check in ~90s.
- Otherwise → report "Blocked for unknown reason (all checks pass, PR approved)." and stop.

**UNSTABLE** → same logic as BLOCKED: inspect pending/failed checks and wait or stop accordingly.

**CONFLICTING** or **DIRTY** → report "PR has merge conflicts. Manual resolution needed." and stop.

**UNKNOWN** → schedule next check in ~30s (GitHub still computing state).

**Anything else** → report "Unexpected mergeStateStatus: `<value>`." and stop.

## Scheduling

When scheduling the next check, call `ScheduleWakeup` with:
- `delaySeconds`: as specified above (30, 60, or 90)
- `reason`: one sentence describing what you're waiting for
- `prompt`: `/loop /merge-pr:merge-pr <PR_URL>`
