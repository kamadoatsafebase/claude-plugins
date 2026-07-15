#!/usr/bin/env bash
set -euo pipefail

input="$(cat)"
agent_id="$(jq -r '.agent_id // empty' <<<"${input}")"

# Subagent tool calls are the whole point of Orchestration Mode — let them through.
if [[ -n "${agent_id}" ]]; then
  exit 0
fi

jq -n '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "allow",
    additionalContext: "Follow the Orchestration Mode guidelines."
  }
}'
