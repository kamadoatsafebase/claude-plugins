# claude-plugins

A personal marketplace of [Claude Code](https://docs.claude.com/claude-code) plugins: skills, an agent, and hooks for code review, PR management, knowledge management, and general developer productivity.

## Installing

This repo is a Claude Code plugin marketplace (`.claude-plugin/marketplace.json`, owner `personal`). Add it as a marketplace and install individual plugins from it, e.g.:

```
/plugin marketplace add kamadorueda/claude-plugins
/plugin install orchestration
/plugin install knowledge-base
/plugin install utilities
```

## Structure

Each top-level directory is one plugin, with its own `.claude-plugin/plugin.json` manifest:

```
<plugin>/
├── .claude-plugin/plugin.json
├── skills/<name>/SKILL.md   # slash-command skills
├── agents/<name>.md         # subagent definitions (utilities only)
├── hooks/                   # hook scripts + hooks.json (orchestration only)
└── scripts/                 # helper CLIs (knowledge-base only)
```

## Plugins

### orchestration

Always-on rules that push the main session to delegate work to subagents instead of doing it directly.

- **SessionStart hook** — prints `session-start.txt` (the Orchestration Mode guidelines: break requests into steps, delegate each to a subagent via the Agent tool, run independent steps in parallel, avoid pausing for clarification) at the start of every session.
- **UserPromptSubmit hook** (`hooks/user-prompt-submit.sh`) — on each user prompt in the main session (skipped for subagents), injects a reminder to follow the Orchestration Mode guidelines.

### knowledge-base

Manage long-lived "knowledge-base" projects (intent, context docs, implementation steps) stored on disk, via the `kbctl` helper script (`scripts/kbctl`, configured through `docs/config.md`, layout defined in `docs/structure.md`).

- **/elaborate `<project>`** — creates a KB project if new (via `kbctl init`), reads its current state, then collaborates with the user to define intent, target structure, future work, context docs, and numbered implementation steps.
- **/execute `<project>`** — runs the single next pending implementation step (via `kbctl next`) exactly as written, with safety checks that block destructive commands (`rm -rf`, force-push, `DROP`/`TRUNCATE`, `terraform destroy`, etc.) until the user confirms, then moves the step file to `complete/` (via `kbctl move`).
- **/list** — prints all KB projects with their pending step counts and titles (via `kbctl list`).

### utilities

Standalone developer-productivity skills, plus one agent.

- **/commit-and-ticket** — thin proxy that invokes the `utilities:commit-and-ticket` agent to verify HEAD's commit message matches its diff and that it links a valid Linear ticket, regenerating the message and/or filing a ticket as needed.
- **commit-and-ticket agent** (`agents/commit-and-ticket.md`) — does the actual work behind the skill above: parses natural-language args (team, project, parent ticket, explicit ticket link, skip-ticket/skip-project), judges message accuracy against the diff, creates or links a Linear ticket (self-assigned to the invoking user, mandatory project or explicit opt-out), regenerates the commit message under commitlint-compatible rules, and amends HEAD.
- **/code-review-loop** — runs the built-in `code-review` skill repeatedly, triages findings into fix/skip, applies fixes and amends the commit, up to 5 turns or until clean.
- **/merge-pr `<PR_URL>`** — babysits a single already-approved PR (via `gh`) until it's merged, updating a behind branch, waiting out pending checks, and reporting blockers, using `ScheduleWakeup`/`/loop` to resume after a delay.
- **/merge-prs** — finds all of the current user's open non-draft PRs across repos and runs the merge-pr loop on each concurrently, one PR per subagent.
- **/open-terminal `[path|description]`** — opens a path (or the cwd, or an inferred path from a description) in a new macOS Terminal window.
- **/patch-dependency-alerts** — reads vulnerability alerts from a Slack channel, inspects affected repos (Go/yarn/pnpm/Python), presents a ranked patch-candidate table, then patches and CI-verifies the packages the user selects.
- **/remove-merged-branches** — deletes local git branches with zero unique commits compared to `origin/main`, after listing them and getting user confirmation.

## Notes / gaps

- `knowledge-base/docs/config.md` hardcodes `KB_ROOT=~/data/kb` and must be edited to match a new user's local setup before the knowledge-base skills are used.
- `utilities/skills/patch-dependency-alerts/SKILL.md` has a "Repo Resolution Reference" table that also needs customizing per user/org before use.
- No repo-level `CLAUDE.md`; orchestration behavior is delivered purely via the `orchestration` plugin's hooks.
