#!/usr/bin/env bash
set -euo pipefail

input="$(cat)"
agent_id="$(jq -r '.agent_id // empty' <<<"${input}")"

# Only nudge the main session — subagents don't need to be told to delegate further.
if [[ -n "${agent_id}" ]]; then
  exit 0
fi

jq -n '{
  hookSpecificOutput: {
    hookEventName: "UserPromptSubmit",
    additionalContext: "Follow the Orchestration Mode guidelines."
  }
}'
