---
name: patch-dependency-alerts
description: Read dependency vulnerability alerts from #dependency-alerts on Slack, inspect affected repos, present a candidate table, then patch and CI-verify selected packages. Use when the user types /patch-dependency-alerts.
---

# /patch-dependency-alerts

Read dependency alerts from Slack, inspect repos, present patching candidates, then patch and verify selected ones.

You are the **orchestrator**. Delegate all work to sub-agents; synthesize their results yourself.

---

## Repo Resolution Reference (use in every sub-agent that needs a disk path)

> **Customize this table for your setup before using this skill.**

| Pattern | Disk path |
|---------|-----------|
| `<org>/<name>` | `~/data/<org>/<name>` |

If the path does not exist on disk, clone it first:
```
git clone git@github.com:<org>/<name>.git <DISK_PATH>
```

**Ecosystem detection** (check files at `<DISK_PATH>`, first match wins):
- `go.mod` → **Go**
- `pnpm-lock.yaml` → **pnpm**
- `yarn.lock` → **yarn**
- `pyproject.toml` or `requirements.txt` → **Python**

---

## Sub-Agent 1 — Slack Reader

Read the last 100 messages from #dependency-alerts. Collect **all** vulnerability alerts across **all** repositories. Deduplicate per repo by package name or CVE (keep the most recent alert per package per repo).

Return a JSON array grouped by repo:

```json
[
  {
    "repo": "myorg/myrepo",
    "alerts": [
      {
        "package": "golang.org/x/net",
        "vulnerable_range": "<0.38.0",
        "fix_version": "0.38.0",
        "cve_or_advisory": "CVE-2025-XXXX",
        "severity": "high",
        "message_ts": "..."
      }
    ]
  }
]
```

`package` is the npm package name, Go import path, or Python package name as appropriate.

If no alerts found at all, stop: "no dependency alerts found."

---

## Sub-Agents 2 — Dep Inspectors (all repos × all alerts, all in parallel)

For every `(repo, alert)` pair, spawn one sub-agent. Carry `DISK_PATH` and `ECOSYSTEM` derived from the Repo Resolution Reference above. Clone the repo first if the path does not exist.

Instructions vary by `ECOSYSTEM`:

### Go (`go.mod`)

> Inspect `<package>` (vulnerable: `<vulnerable_range>`, fix: `<fix_version>`). Working dir: `<DISK_PATH>`.
>
> 1. Check `go.mod` — is `<package>` a direct dependency? What version?
> 2. Run `go mod why <package>` — enumerate transitive chains.
> 3. Already resolved? (version in go.mod >= fix_version, or package not present at all) For pseudo-versions (`v0.0.0-YYYYMMDDHHMMSS-hash`), a pseudo-version is always older than any tagged release — if `go.mod` has a pseudo-version and `fix_version` is a tagged release, set `already_resolved: false`.
> 4. Is fix available? Run `go list -m -versions <package>` and confirm `<fix_version>` is listed.
> 5. Classify effort: `trivial` (patch/minor bump, direct dep), `low` (minor bump, single transitive parent), `medium` (major bump or single transitive parent with fix available), `high` (multiple transitive paths, no parent fix yet).

### yarn

> Inspect `<package>` (vulnerable: `<vulnerable_range>`, fix: `<fix_version>`). Working dir: `<DISK_PATH>`.
>
> 1. `grep -rl '"<package>"' apps/ packages/ 2>/dev/null` — record file→version pairs.
> 2. Read root `package.json` resolutions block — is `<package>` pinned there?
> 3. `yarn workspace <main-workspace> why <package>` — enumerate transitive chains.
>    (Detect the main workspace from the `workspaces` field in root `package.json`.)
> 4. Already resolved? (all pinned versions >= fix_version)
> 5. Classify effort (trivial/low/medium/high).

### pnpm

> Inspect `<package>` (vulnerable: `<vulnerable_range>`, fix: `<fix_version>`). Working dir: `<DISK_PATH>`.
>
> 1. `grep -rl '"<package>"' apps/ packages/ 2>/dev/null` — record file→version pairs.
> 2. Read root `package.json` → `pnpm.overrides` block — is `<package>` pinned there?
> 3. `pnpm why <package>` (from repo root) — enumerate transitive chains.
> 4. Already resolved? (all pinned versions >= fix_version)
> 5. Classify effort (trivial/low/medium/high).

### Python

> Inspect `<package>` (vulnerable: `<vulnerable_range>`, fix: `<fix_version>`). Working dir: `<DISK_PATH>`.
>
> 1. Check `pyproject.toml` — is `<package>` a direct dependency? What version constraint?
> 2. `uv tree` — enumerate transitive chains.
> 3. Already resolved? (resolved version >= fix_version)
> 4. Is fix available? Run `uv pip index versions <package>` and confirm `<fix_version>` is listed.
> 5. Classify effort (trivial/low/medium/high).

For `current_version`: Go → read from `go.mod`; yarn/pnpm → first value from `workspace_pins`, or null if empty; Python → read constraint from `pyproject.toml`.

**All ecosystems return:**

```json
{
  "repo": "...",
  "package": "...",
  "current_version": "currently installed version string, or null if not present",
  "already_resolved": boolean,
  "is_direct_dep": boolean,
  "workspace_pins": {"file": "version"},
  "resolution_pin": "version or null",
  "transitive_parents": ["..."],
  "fix_version_available": boolean,
  "effort_class": "trivial|low|medium|high",
  "effort_reasoning": "..."
}
```

---

## Candidate Selection (orchestrator, inline)

After all Sub-Agents 2 return, for **each repo** independently:
- `already_resolved: true` → **already patched**, skip.
- `fix_version_available: false` → **no upstream fix yet**, skip.
- Rank remaining by severity (critical→low) then effort (trivial→high).
- If none viable, mark repo as **nothing to patch**.

**Do NOT spawn patch agents automatically.** Present the user with a markdown table of all viable candidates:

| Repo | Package | Current | Fix | Effort | Notes |
|------|---------|---------|-----|--------|-------|
| ... | ... | ... | ... | ... | ... |

Note any repos with no viable candidates and why (already resolved / no fix available / not on disk).

Then **stop and wait** for the user to say which packages they want patched. The user may respond with package names, row numbers from the table, or 'all'. Match each item to the candidate row by package name or position; if a match is ambiguous, ask for clarification before proceeding. Proceed to Sub-Agents 3 only after receiving that input.

---

## Sub-Agents 3 — Patch Agents (one per selected package, spawned one at a time)

For each package the user selected, spawn one patch sub-agent and **wait for it to complete before spawning the next one**.

Patch `<package>` from vulnerable versions to `<fix_version>`. Working dir: `<DISK_PATH>`.

**All ecosystems:**
1. Confirm working tree is clean (`git status`). Stop if dirty (untracked files are fine) — return: `{"install_exit_code": 1, "install_error": "working tree is dirty", "commit_sha": null}` and stop.
2. `git fetch origin`. Detect the default branch: `DEFAULT=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||')`. If empty, use `main`. Check for an existing local branch: `git branch --list dependency-alerts/<slug>`. If it exists, run `git cherry origin/$DEFAULT dependency-alerts/<slug>` — if any line starts with `+`, stop and warn: "Branch dependency-alerts/<slug> has un-pushed commits. Delete or push it first." Then `git checkout -B dependency-alerts/<slug> origin/$DEFAULT`.
   (slug: strip `@`, replace `/` and `.` with `-`, e.g. `golang.org/x/net` → `golang-org-x-net`)

**Go:**
3. `go get <package>@<fix_version>`
4. `go mod tidy`

**yarn:**
3. `yarn install`
4. Bump every workspace file from `workspace_pins` in the vulnerable range to `<fix_version>`.
   Update root `package.json` resolutions entry if `resolution_pin` exists or effort is medium/high.
   (Check if the repo has a yarn constraints file that enforces version consistency — if so, every workspace must be bumped or CI will fail.)
5. `yarn install`
6. `yarn run generate --if-present`

**pnpm:**
3. `pnpm install`
4. Bump workspace pins in the vulnerable range to `<fix_version>`.
   Add/update `pnpm.overrides` in root `package.json` if effort is medium/high.
5. `pnpm install`
6. `pnpm run --if-present generate`

**Python:**
3. Update the version constraint for `<package>` in `pyproject.toml` to `>= <fix_version>`.
4. `uv lock && uv sync`

After all ecosystem-specific steps complete, create a local commit:
```
git add -u
git add go.mod go.sum uv.lock pnpm-lock.yaml yarn.lock 2>/dev/null || true
git commit -m "chore(deps): upgrade <package> to <fix_version>"
```
Do **not** push the branch or open a PR.

Return JSON: `repo`, `branch_name`, `files_changed`, `version_bumps`, `install_exit_code`, `install_error`, `commit_sha`.

Skip the corresponding Sub-Agent 4 if `install_exit_code` is non-zero.

---

## Sub-Agents 4 — CI Agents (one per successful patch, in parallel)

For each repo where the patch succeeded:

1. Confirm current branch is `<branch_name>`. Working dir: `<DISK_PATH>`.
2. Run CI:
   - yarn → check `scripts` in root `package.json`; run `yarn lint && yarn test` (or detected equivalents)
   - Go → `go build ./... && go test ./...`
   - pnpm → check `scripts` in root `package.json`; run `pnpm run lint && pnpm run test` (or detected equivalents)
   - Python → `uv run ruff check . && uv run pytest`

Return JSON: `repo`, `ci_passed`, `exit_code`, `failing_sections`, `failure_details`.

---

## Final Report (orchestrator, no sub-agent)

One section per repo:

- **Alerts scanned:** table of package / severity / status (already patched | no fix yet | patched | patch failed | skipped)
- **Selected candidate:** which package was patched and why
- **Branch:** name
- **Changes:** files and version bumps
- **CI:** pass/fail with details if failed
