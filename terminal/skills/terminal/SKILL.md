---
name: terminal
description: Open a path in a new Terminal window (macOS only — requires Terminal.app). Use when the user types /terminal, wants to open a directory in Terminal, or says "open X in terminal". Args are optional — defaults to cwd if omitted.
---

# /terminal

Open a path in a new Terminal window.

Usage: `/terminal [description]`

- With no args: opens the current working directory (`$PWD`)
- With a description: interpret it as either a literal path or a hint about which relevant path to open (e.g. "the server app", "the terraform module", "the tests dir")

---

Determine the path to open:

1. If `args` is empty or blank, use `$PWD` (the agent's current working directory — run `pwd` via Bash to get it).
2. If `args` looks like an absolute or relative path that exists, resolve it to an absolute path.
3. Otherwise treat `args` as a natural-language description and infer the most relevant absolute path from context (cwd, recent files edited, project structure, etc.). Use your best judgment — don't ask for clarification.

Once you have the absolute path, run exactly:

(macOS only — this command requires Terminal.app and will not work on Linux or WSL)

```
open -ga Terminal <resolved-path>
```

(the `-g` flag opens the window in the background without bringing Terminal to the front — switch to Terminal manually to see it)

via Bash. Report the path you opened in one short sentence.
