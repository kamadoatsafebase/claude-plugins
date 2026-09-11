---
name: open-terminal
description: Open a path in a new Terminal window (macOS only, needs Terminal.app). Use when the user types /open-terminal, wants to open a directory in Terminal, or says "open X in terminal". Args are optional and default to cwd.
---

# /open-terminal

Open a path in a new Terminal window.

Usage: `/open-terminal [description]`

- With no args: opens the current working directory (`$PWD`)
- With a description: read it as a literal path, or as a hint about which relevant path to open. For example, "the server app", "the terraform module", or "the tests dir".

---

Find the path to open:

1. If `args` is empty or blank, use `$PWD`. This is the agent's current working directory. Run `pwd` with Bash to get it.
2. If `args` looks like an absolute or relative path that exists, resolve it to an absolute path.
3. If not, read `args` as a natural-language description. Infer the most relevant absolute path from the context: cwd, recent file edits, project structure, and so on. Use your best judgment. Do not ask for clarification.

When you have the absolute path, run this command with Bash, exactly as shown:

(macOS only. This command needs Terminal.app and does not work on Linux or WSL.)

```
open -ga Terminal <resolved-path>
```

(The `-g` flag opens the window in the background and does not bring Terminal to the front. Switch to Terminal manually to see it.)

Report the path you opened in one short sentence.
