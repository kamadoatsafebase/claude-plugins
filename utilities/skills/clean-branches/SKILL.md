---
name: clean-branches
description: Find and delete local git branches that have no unique commits compared to origin/main (already merged or rebased). Use when the user types /clean-branches.
---

# /clean-branches

Delete local branches that have no unique commits compared to `origin/main`.

---

Before starting, run `rm -f branches.txt`.

## Step 1 — Find stale branches

Use the Agent tool with the following prompt to fetch and analyze branches:

> Run `git fetch origin --prune`.
>
> List all local branches except `main` and `master`:
> ```
> git branch --format='%(refname:short)' | grep -vE '^(main|master)$'
> ```
>
> Run `git rev-parse --verify origin/main`. If it exits non-zero, print "Error: \`origin/main\` not found. This skill requires \`origin/main\` to exist. If your default branch is named differently, run \`git cherry <remote>/<default-branch> <branch>\` manually." and stop immediately — do NOT proceed to the branch loop.
>
> For each branch, run `git cherry origin/main <branch>`. If `git cherry` exits non-zero, skip that branch and do not include it in `branches.txt`. Otherwise count lines starting with `+`.
>
> Write `branches.txt` with one line per branch that has 0 unique commits. If no branches qualify, create an empty file with `touch branches.txt`.

## Step 2 — Verify

Run `test -f branches.txt`. If it fails, go back to Step 1. Retry up to 3 times before stopping.

## Step 3 — Confirm

Print the contents of `branches.txt`. If the file is empty, print "No stale branches found." and stop. Otherwise wait for the user to confirm before proceeding.

## Step 4 — Delete *(only after user confirms)*

Use the Agent tool with the following prompt to delete the branches:

> Read `branches.txt`.
> Get the current branch: `git branch --show-current`.
> If the current branch is in the list, first run `git checkout main 2>/dev/null || git checkout -b main origin/main`.
> For each branch: try `git branch -d <branch>`. If it fails, retry with `git branch -D <branch>` (safe: git cherry already verified 0 unique commits). Print each result.

## Step 5 — Cleanup

Run `rm -f branches.txt`. Print "Done."
