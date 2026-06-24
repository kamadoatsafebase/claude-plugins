---
name: merge-prs
description: Find all open non-draft PRs created by the current user across all repos and run /merge-pr on each one, at most one per repo at a time. Use when the user types /merge-prs.
---

# /merge-prs

Find all your open PRs and babysit each to merge, running at most one per repo at a time.

---

You are the **orchestrator**. Delegate all shell commands to subagents.

## Step 1 — Discover

Spawn a **discovery** subagent:

> Run:
> ```
> gh search prs --author @me --state open --draft=false --json 'title,url,headRepository' --limit 100
> ```
> Return the raw JSON.

Group results by `headRepository.nameWithOwner`. If empty, report "No open PRs found." and stop. Otherwise report: "Found {N} PR(s) across {R} repo(s)" with a list.

## Step 2 — Merge

Spawn one **repo-merger** subagent per repo, all in parallel. Each receives its repo name and ordered list of PR URLs.

Each repo-merger processes its PRs **one at a time**. For each PR URL, loop until terminal:

1. Run both commands:
   ```
   gh pr view <PR_URL> --json state,mergeable,mergeStateStatus,statusCheckRollup
   gh pr checks <PR_URL> 2>&1
   ```

2. Decide:
   - **MERGED** → log "✓ merged." Move to next PR.
   - **CLOSED** → log "✗ closed without merging." Move to next PR.
   - **CLEAN** → run `gh pr merge <PR_URL> --squash --delete-branch 2>&1`. Log result. Move to next PR.
   - **BEHIND** → run `gh pr update-branch <PR_URL> 2>&1`. Log "branch updated, waiting for checks." Sleep 90s. Re-check.
   - **BLOCKED** with failed checks → log "✗ blocked: {failed check names}. Manual fix needed." Move to next PR.
   - **BLOCKED** or **UNSTABLE** with only pending checks → log "Waiting for: {check names}." Sleep 90s. Re-check.
   - **CONFLICTING** or **DIRTY** → log "✗ merge conflicts. Manual resolution needed." Move to next PR.
   - **UNKNOWN** → sleep 30s. Re-check.

## Step 3 — Report

After all repo-merger subagents complete, summarize: which PRs merged, which stopped with an issue.
