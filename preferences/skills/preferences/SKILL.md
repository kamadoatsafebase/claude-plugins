---
name: preferences
description: Load and apply user preferences from CLAUDE.md. Use when the user types /preferences or asks to follow their personal instructions and settings.
---

1. Read `~/.claude/settings.json` and extract `extraKnownMarketplaces.personal.source.path`.
2. Read `{path}/orchestration/CLAUDE.md` and follow all instructions completely.
3. If either file does not exist, inform the user.
