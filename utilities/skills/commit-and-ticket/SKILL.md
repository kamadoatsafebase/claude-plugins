---
name: commit-and-ticket
description: Verify the HEAD commit's message accurately reflects its diff and that it links a valid Linear ticket, fixing either as needed — regenerating the message and/or filing a ticket. Use when the user types /commit-and-ticket.
---

# /commit-and-ticket

Make sure HEAD's commit message is accurate and linked to a Linear ticket, filing a new ticket or rewriting the message only when needed.

Usage: `/commit-and-ticket [team ENG] [parent ENG-900] [link to ENG-500] [skip ticket]`

Target is always **HEAD of the current branch**; this skill does not support selecting a different commit.

**Idempotency:** re-running this skill on an unchanged commit converges to the same correct end state (accurate message + valid embedded ticket key). It does **not** guarantee zero duplicate Linear tickets under failure/timeout — a small residual risk is explicitly accepted in exchange for a much simpler design. It never silently replaces a present-but-topically-mismatched ticket key; it only flags the mismatch for the user to resolve by hand.

All of the actual mechanics — natural-language arg parsing, the git/regex pre-check,
message-accuracy judging, ticket lookup/creation, message regeneration, and the commit
amend itself — live in the `utilities:commit-and-ticket` agent. This skill is a thin
invoke-then-relay proxy in front of it: it does not interpret the user's args itself, and
it does not orchestrate any retry — it just forwards the call and surfaces whatever comes
back.

## Step 1 — Invoke the agent

Call `Agent(subagent_type='utilities:commit-and-ticket')`, passing the user's raw
invocation args straight through, **unparsed, as-is** — no extraction, no interpretation.
The agent is fully self-sufficient: it parses team/parent/explicit-link/skip-ticket
mentions out of the raw text itself, and re-derives the commit SHA, message, and diff on
its own.

## Step 2 — Relay the result

Relay whatever the agent returns as this skill's own final output, verbatim in spirit:

- If `done`: show the summary.
- If `failed`: show the reason.
- If `needs_input`: surface what it's asking for (e.g. the team options) directly to the
  user as this skill's answer. Do **not** use `AskUserQuestion` and do **not**
  automatically re-invoke the agent — getting the missing input and trying again is a
  natural follow-up (the user responds, and a future turn supplies it), not something
  this skill orchestrates itself.
