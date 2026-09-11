---
name: remove-merged-branches
description: Find and delete local git branches that have no unique commits compared to origin/main (already merged or rebased). Use when the user types /remove-merged-branches.
---

# /remove-merged-branches

Delete local branches that have no unique commits compared to `origin/main`.

---

Before you start, run `rm -f branches.txt`.

## Step 1 — Find stale branches

Use the Agent tool with this prompt:

> Run `git fetch origin --prune`.
>
> List all local branches except `main` and `master`:
> ```
> git branch --format='%(refname:short)' | grep -vE '^(main|master)$'
> ```
>
> Run `git rev-parse --verify origin/main`. If it exits non-zero, do all of this:
>
> - Run `touch branches.txt`.
> - Print "Error: \`origin/main\` not found. This skill requires \`origin/main\` to exist. If your default branch is named differently, run \`git cherry <remote>/<default-branch> <branch>\` manually."
> - Stop immediately. Do NOT continue to the branch loop.
>
> For each branch, run `git cherry origin/main <branch>`. If `git cherry` exits non-zero, skip that branch. Do not write it to `branches.txt`. If it exits zero, count the lines that start with `+`.
>
> Write `branches.txt` with one line for each branch that has 0 unique commits. If no branch qualifies, create an empty file with `touch branches.txt`.

## Step 2 — Verify

Run `test -f branches.txt`. If it fails, go back to Step 1. Retry up to 3 times before stopping.

## Step 3 — Confirm

Print the contents of `branches.txt`. If the file is empty, print "No stale branches found." and stop.

If the file is not empty, stop and wait for the user to confirm. Do NOT continue to Step 4 until the user confirms.

## Step 4 — Delete *(only after user confirms)*

Use the Agent tool with this prompt:

> Read `branches.txt`.
> Get the current branch: `git branch --show-current`.
> If the current branch is in the list, first run `git checkout main 2>/dev/null || git checkout -b main origin/main`.
> For each branch: try `git branch -d <branch>`. If it fails, retry with `git branch -D <branch>` (safe: git cherry already showed 0 unique commits). Print each result.

## Step 5 — Cleanup

Run `rm -f branches.txt`. Print "Done."
