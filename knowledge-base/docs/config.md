## Knowledge Base Configuration

The KB projects root:

```
KB_ROOT=~/kb
```

Edit this path to match your local setup before using any knowledge-base skill.

Store this variable at the start of any subagent that runs shell commands.

When substituting KB_ROOT into Read or Write tool `file_path` arguments (not Bash commands), if the value starts with `~`, first resolve it to an absolute path by running `echo <the-configured-value>` via Bash (e.g. `echo ~/kb`) and use the output.
