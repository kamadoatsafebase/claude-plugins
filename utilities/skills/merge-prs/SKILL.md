---
name: merge-prs
description: Find all open non-draft PRs created by the current user across all repos and run /merge-pr on each one, at most one per repo at a time. Use when the user types /merge-prs.
---

# /merge-prs

Find all your open PRs and merge each one concurrently.

---

You are the **orchestrator**. Your job: discover PRs, then delegate each one to a subagent.

## Step 1 — Discover

Run this command yourself:

```
gh search prs --author @me --state open --draft=false --json 'title,url,headRepository,createdAt' --limit 100
```

Parse the JSON. If empty, report "No open PRs found." and stop. Sort results by `createdAt` ascending (oldest first). List them in that order: "Found {N} PR(s) across {R} repo(s): ..." and continue.

## Step 2 — Merge

Spawn one **pr-merger** subagent per PR, all in parallel. Each one receives a single PR URL and is fully responsible for babysitting that PR to a terminal state. It should never return until the PR is merged, closed, or stuck.

Use this exact prompt for each pr-merger (substitute `{PR_URL}` with the actual URL):

> You are babysitting PR `{PR_URL}`. Your job is to get it merged. Loop until you reach a terminal state.
>
> On each iteration:
>
> 1. Run both commands:
>    ```
>    gh pr view {PR_URL} --json state,mergeable,mergeStateStatus,statusCheckRollup
>    gh pr checks {PR_URL} 2>&1
>    ```
>
> 2. Decide:
>    - **state is MERGED** → print "merged" and stop.
>    - **state is CLOSED** → print "closed without merging" and stop.
>    - **mergeStateStatus is CLEAN** → run `gh pr merge {PR_URL} --squash --delete-branch 2>&1`, print the result, and stop.
>    - **mergeStateStatus is BEHIND** → run `gh pr update-branch {PR_URL} 2>&1`, print "branch updated", then run `sleep 90 && echo retry`.
>    - **mergeStateStatus is BLOCKED or UNSTABLE** with failed checks → print "blocked: {failed check names} — manual fix needed" and stop.
>    - **mergeStateStatus is BLOCKED or UNSTABLE** with only pending checks → print "waiting for: {pending check names}", then run `sleep 90 && echo retry`.
>    - **mergeStateStatus is CONFLICTING or DIRTY** → print "merge conflicts — manual resolution needed" and stop.
>    - **mergeStateStatus is UNKNOWN** → run `sleep 30 && echo retry`.
>
> Return your final one-line status when done.

## Step 3 — Report

After all pr-merger subagents finish, summarize results: which PRs merged successfully, which ones stopped with an issue and why.
