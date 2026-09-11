---
name: commit-and-ticket
description: Verify that the HEAD commit's message matches its diff and links a valid Linear ticket. Fix either as needed: regenerate the message, file a ticket, or both. Use when the user types /commit-and-ticket.
---

# /commit-and-ticket

Make sure HEAD's commit message is accurate and linked to a Linear ticket. File a new ticket or rewrite the message only when needed.

Usage: `/commit-and-ticket [team ENG] [parent ENG-900] [link to ENG-500] [skip ticket] [project "API Docs"] [no project]`

The target is always HEAD of the current branch. This skill cannot select a different commit.

**Idempotency:** if you run this skill again on an unchanged commit, it converges to the same correct end state: an accurate message with a valid embedded ticket key. It does not guarantee zero duplicate Linear tickets if an operation fails or times out. This small residual risk is accepted to keep the design much simpler. The skill never silently replaces a ticket key that is present but does not match the topic. It only flags the mismatch for the user to correct by hand.

The `utilities:commit-and-ticket` agent does all the work: it parses the natural-language args, runs the git and regex pre-check, judges message accuracy, looks up or creates the ticket, regenerates the message, and amends the commit. This skill only forwards the call and shows what comes back. It does not interpret the user's args, and it does not retry.

## Step 1 — Invoke the agent

Call `Agent(subagent_type='utilities:commit-and-ticket')`. Pass the user's raw invocation args straight through, unparsed. Do not extract or interpret them.

The agent finds the team, parent, explicit link, skip-ticket, project, and no-project mentions in the raw text itself. It also re-derives the commit SHA, message, and diff on its own.

A project, or an explicit decision to skip one, is mandatory when a new ticket is created. If the user supplies neither, the agent asks for it through the same `needs_input` mechanism it uses for a missing team.

## Step 2 — Relay the result

Give whatever the agent returns as this skill's own final output. Keep its content.

- If `done`: show the summary.
- If `failed`: show the reason.
- If `needs_input`: show what the agent asks for, for example the team or the project options, directly to the user as this skill's answer. Do not use `AskUserQuestion`. Do not call the agent again automatically. The user responds, and a future turn supplies the missing input.
