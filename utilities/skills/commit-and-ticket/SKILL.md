---
name: commit-and-ticket
description: Check that HEAD's commit message matches its diff and links a valid Linear ticket, and fix either as needed. Use when the user types /commit-and-ticket.
---

# /commit-and-ticket

Usage: `/commit-and-ticket [team ENG] [parent ENG-900] [link to ENG-500] [skip ticket] [project "API Docs"] [no project]`

1. Call `Agent(subagent_type='utilities:commit-and-ticket')` with the user's raw args as the prompt. Do not parse or add to them. On a later turn that answers a `needs_input`, pass the original args plus `resolved team: X` or `resolved project: X` from the user's reply.
2. Show the result to the user. For `needs_input`, show the question and the options, then stop. Do not use AskUserQuestion, and do not call the agent again until the user replies.
