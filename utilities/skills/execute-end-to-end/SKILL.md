---
name: execute-end-to-end
description: Run the full elaborate-to-PR pipeline for a KB project — rebase, execute all pending KB steps in a sub-agent, run a code-review loop, reconcile the commit with a Linear ticket, force-push, and open a PR. Use when the user types /execute-end-to-end <project>.
---

# /execute-end-to-end

Chain the full workflow from a rebased branch to an open pull request for a single knowledge-base project: rebase → execute all pending KB steps → code-review loop → commit-and-ticket → force-push → PR.

Usage: `/execute-end-to-end <project-name>`

**Standing authorization for this skill's run:** creating and amending commits, creating Linear tickets, force-pushing the current branch, and opening pull requests are all pre-authorized as part of invoking this skill — do not pause to re-confirm any of them individually.

**Stop condition (applies to every step below):** if you get stuck — a rebase conflict, an ambiguous state, a command failing in a way this skill doesn't describe how to handle, `/code-review-loop` hitting its 5-turn limit with findings still unresolved, `/commit-and-ticket` reporting `needs_input` or `failed`, a rejected push, or a PR that already exists — stop immediately and ask the user what to do. Do not guess your way past it.

## Step 1 — Rebase

Fetch and rebase the current branch onto the repo's default branch (`git remote show origin` or `gh repo view --json defaultBranchRef` to determine it, typically `main`):

```bash
git fetch origin
git rebase origin/<default-branch>
```

If the rebase reports conflicts, stop and ask the user how to resolve them — do not attempt to resolve conflicts yourself.

## Step 2 — Execute all pending KB steps

The KB project name is the argument passed to this skill. Spawn a sub-agent (`Agent` tool) to invoke the `knowledge-base:execute` skill for `<project-name>` via the Skill tool, then repeat: check whether pending steps remain (e.g. via the `knowledge-base:list` skill or the last execute's own report) and spawn another sub-agent invocation of `knowledge-base:execute` for the same project if so. Continue until it reports zero pending steps.

Each `knowledge-base:execute` call only runs the single lowest-numbered pending step — looping is required to reach "no pending steps left."

If a sub-agent invocation errors or the project itself reports it's stuck (e.g. an ambiguous step, missing context), stop and ask the user rather than guessing at the next step.

## Step 3 — Code review loop

Invoke the `code-review-loop` skill via the Skill tool (no args needed — it reviews the working diff). Let it run its own turns (up to 5) and fixes.

If it stops at the 5-turn limit with findings still unresolved, stop and surface those findings to the user instead of proceeding.

## Step 4 — Commit and ticket

Invoke the `commit-and-ticket` skill via the Skill tool to make sure HEAD's commit message is accurate and linked to a Linear ticket. Pass through any team/project hints the user gave when invoking `/execute-end-to-end`, if any; otherwise call it with no args and let it ask if it needs a team or project.

If it reports `needs_input` or `failed`, stop and relay that to the user — do not guess at a team, project, or ticket link on its behalf.

## Step 5 — Force-push

```bash
git push -f
```

If the push is rejected or errors for a reason not explained by a normal force-push (e.g. missing upstream, permission error), stop and ask the user.

## Step 6 — Open the pull request

Check whether a PR already exists for the current branch (`gh pr view` for the current branch). If one exists, report that it's already open (with its URL) and stop here — do not attempt to create a duplicate.

Otherwise:

```bash
gh pr create --fill-first
```

Report the resulting PR URL to the user as the final output of this skill.
