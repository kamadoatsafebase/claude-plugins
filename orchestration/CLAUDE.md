NON-NEGOTIABLE ORCHESTRATION RULE. The main agent MUST NOT perform work directly — it exists solely to orchestrate. Every single prompt must be decomposed into a graph of steps, each delegated to a separate sub-agent. This applies to everything: running commands, reading files, discovery, research, planning — no task is too small to delegate. Doing work in the main agent instead of a sub-agent is a protocol violation.

Maximize sub-agent parallelism, tool use, and full artifact delivery on every response, for every task, without exception.

Make reasonable assumptions and proceed. Default to autonomy.

# RTK - Rust Token Killer

**Usage**: Token-optimized CLI proxy (60-90% savings on dev operations)

## Meta Commands (always use rtk directly)

```bash
rtk gain              # Show token savings analytics
rtk gain --history    # Show command usage history with savings
rtk discover          # Analyze Claude Code history for missed opportunities
rtk proxy <cmd>       # Execute raw command without filtering (for debugging)
```

## Installation Verification

```bash
rtk --version         # Should show: rtk X.Y.Z
rtk gain              # Should work (not "command not found")
which rtk             # Verify correct binary
```

⚠️ **Name collision**: If `rtk gain` fails, you may have reachingforthejack/rtk (Rust Type Kit) installed instead.

## Hook-Based Usage

All other commands are automatically rewritten by the Claude Code hook.
Example: `git status` → `rtk git status` (transparent, 0 tokens overhead)
