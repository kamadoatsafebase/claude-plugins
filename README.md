# claude-plugins

A personal [Claude Code](https://docs.claude.com/claude-code) plugin marketplace: skills, an agent, and hooks for code review, commit/ticket hygiene, knowledge management, and general dev productivity.

## Installing

This repo is a plugin marketplace (`.claude-plugin/marketplace.json`, owner `personal`). Add it and install plugins:

```
/plugin marketplace add kamadorueda/claude-plugins
/plugin install harness
/plugin install knowledge-base
/plugin install utilities
```

## Structure

Each top-level directory is a plugin with its own `.claude-plugin/plugin.json`:

```
<plugin>/
├── .claude-plugin/plugin.json
├── skills/<name>/SKILL.md   # slash-command skills
├── agents/<name>.md         # subagent definitions (utilities only)
├── hooks/                   # hook scripts + hooks.json (harness only)
└── scripts/                 # helper CLIs (knowledge-base only)
```

## Plugins

### harness

Always-on rules shaping how the main session works: delegate to subagents, and write every human-facing text in plain English.

- **SessionStart hook** — prints `session-start.txt` at session start. It carries two sections: *Orchestration Mode* (break requests into steps, delegate each via the Agent tool, parallelize independent steps, avoid pausing for clarification) and *Plain English Mode* (run `utilities:plain-english` over messages, commit messages, PR text, tickets, and docs, applying its rules directly for short replies).
- **UserPromptSubmit hook** (`hooks/user-prompt-submit.sh`) — reinjects both reminders on each main-session user prompt (skipped for subagents).

### knowledge-base

Manages long-lived "knowledge-base" projects (intent, context docs, implementation steps) on disk via the `kbctl` helper (`scripts/kbctl`, configured in `docs/config.md`, layout in `docs/structure.md`).

- **/elaborate `<project>`** — creates the KB project if new (`kbctl init`), reads its state, then collaborates with the user to define intent, target structure, future work, context docs, and numbered implementation steps.
- **/execute `<project>`** — runs the single next pending step (`kbctl next`) as written, blocking destructive commands (`rm -rf`, force-push, `DROP`/`TRUNCATE`, `terraform destroy`, etc.) pending user confirmation, then moves the step to `complete/` (`kbctl move`).
- **/list** — prints all KB projects with pending step counts and titles (`kbctl list`).

### utilities

Standalone developer-productivity skills, plus one agent.

- **/commit-and-ticket** — thin proxy invoking the `utilities:commit-and-ticket` agent to verify HEAD's commit message matches its diff and links a valid Linear ticket, regenerating the message and/or filing a ticket as needed.
- **commit-and-ticket agent** (`agents/commit-and-ticket.md`) — does the actual work: parses natural-language args (team, project, parent ticket, explicit ticket link, skip-ticket/skip-project), judges message accuracy against the diff, creates or links a Linear ticket (self-assigned, mandatory project or explicit opt-out), regenerates the message under commitlint-compatible rules, and amends HEAD.
- **/code-review-loop** — runs the built-in `code-review` skill repeatedly, triages findings into fix/skip, applies fixes and amends the commit, up to 5 turns or until clean.
- **/plain-english `[text|file|description]`** — rewrites text to read human, concise, and simple: runs the `humanizer` skill for AI-writing patterns, then applies the generalizable subset of [ASD-STE100](https://www.asd-ste100.org/) Simplified Technical English (active voice, sentence and paragraph caps, three-word compound nouns, plain-word substitutions), skipping the aerospace-only rules.
- **/open-terminal `[path|description]`** — opens a path (or cwd, or a path inferred from a description) in a new macOS Terminal window.
- **/remove-merged-branches** — deletes local git branches with zero unique commits vs. `origin/main`, after listing them and confirming with the user.

## Notes / gaps

- `knowledge-base/docs/config.md` hardcodes `KB_ROOT=~/data/kb` — edit before using knowledge-base skills on a new setup.
- No repo-level `CLAUDE.md`. Orchestration and plain-English behavior come solely from the `harness` plugin's hooks.
- `/plain-english` depends on the external `humanizer` plugin ([blader/humanizer](https://github.com/blader/humanizer)). Without it the skill runs the ASD-STE100 pass only.
- The `harness` plugin's Plain English Mode expects the `utilities` plugin to be installed.
