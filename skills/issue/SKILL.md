---
name: issue
description: Turn a rough ask into a well-formed GitHub issue, following this repo's own conventions. Use when asked to "create an issue", "open an issue", "file an issue", "raise an issue", "log a bug", "track this as an issue", "make a GitHub issue", or when describing a bug / feature / task to capture in the tracker. Interviews for gaps, researches the repo for real references and duplicates, drafts a type-aware (bug / feature / task) issue, shows it for approval, then creates it via gh. Portable across repositories — labels, areas, and attribution are read from the repo's own config or inferred, never hardcoded.
license: MIT
compatibility: Requires git. Issue creation assumes GitHub and the `gh` CLI; on another host the same drafting logic applies but the commands need translating.
metadata:
  version: 1.0.0
  author: ai-standards
allowed-tools: Bash(gh:*) Bash(rg:*) Bash(grep:*) Bash(mktemp:*) Bash(rm:*) Read Grep Glob Write AskUserQuestion
---

# Create GitHub Issue

Turn a rough ask into a well-formed GitHub issue, following this repo's own conventions.
The flow is **interview → research → draft → approve → create**.
One issue per run, in the current repo, unassigned.

This file holds the decision logic.
Everything that varies between repositories — labels, area vocabulary, and attribution — is read from `.claude/git-workflow.md` or inferred from the repo, never hardcoded.
See [`references/repo-config.md`](references/repo-config.md) for the config keys and the one-time bootstrap.

## Conventions (apply these exactly)

| Aspect              | Rule                                                                                                                                                                                                                                                                                                                                                                       |
| ------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Type                | Auto-detect `bug` / `feature` / `task`; confirm in the draft. Docs-only work is a flavor of `task` — same template, different label (see Type label).                                                                                                                                                                                                                      |
| Title               | `[area] <plain imperative>`. Area(s) derived per **Area detection**. **Stack brackets** when work genuinely spans subsystems: `[email][mcp] …`. No single area (repo-wide, process, or no matching package) → `[meta]`; docs-only → `[docs]`. No type/colon prefix.                                                                                                        |
| Type label          | `bug` → `bug`; `feature` → `enhancement`; `task` → `chore`; docs-only task → `documentation`. These are defaults — override with `issue-labels` in config.                                                                                                                                                                                                                 |
| Priority label      | Every issue gets a high/normal/low priority label (default `priority:high` \| `priority:normal` \| `priority:low`). Infer it, confirm in the draft. Area is **not** a label — it lives in the title.                                                                                                                                                                       |
| References          | A `## References` list of `path:line` when the issue concerns specific code.                                                                                                                                                                                                                                                                                               |
| Acceptance          | A checkbox task list. Each task carries a size (`S`/`M`/`L` or `~time`).                                                                                                                                                                                                                                                                                                   |
| Verbosity           | Match the ask — small ask → tight issue, big ask → fuller sections. No padding, no truncation.                                                                                                                                                                                                                                                                             |
| Clarity             | Write so a **non-technical reader and a new contributor** grasp it without prior context — plain-language summary of the problem or goal first, spell out an acronym or internal name (a table, a service, a flag) on first use, keep jargon *after* the everyday-terms point, not instead of it. Whoever picks this up later shouldn't need to already know the codebase. |
| Line wrapping       | **One line per paragraph; never hard-wrap prose mid-sentence.** GitHub renders every newline in an issue/PR/comment body as a `<br>`, so a paragraph wrapped at ~80 cols shows as ragged broken lines. Let prose reflow; only lists break per line (one item per line is correct).                                                                                         |
| Scope               | One issue per run — never split into epics/sub-issues. Current repo only. Unassigned, no milestone, no project.                                                                                                                                                                                                                                                            |
| Voice & attribution | First person singular ("I"). Follow the repo's `attribution` config — default is none: no "Generated with…" / Co-Authored-By lines.                                                                                                                                                                                                                                        |

## Workflow

### 0. Adapt to the repo

Read `.claude/git-workflow.md` — the same file `commit` and `pr` read — if present; otherwise infer and fall back to the defaults below. See [`references/repo-config.md`](references/repo-config.md).

- **Labels** — `issue-labels` in config, else the defaults in the table above.
- **Areas** — `areas` in config, else inferred per **Area detection**.
- **Attribution & voice** — `attribution` in config, else `none` / first person singular.
- **Repo** — whatever `gh` resolves from the current directory. Never hardcode an owner/repo.
- **`gh` availability** — run `gh auth status` once. If it fails, stop and tell the user to run `gh auth login` rather than letting a later step fail on a raw CLI error.

### 1. Understand the ask, interview for gaps

Classify the work as `bug`, `feature`, or `task`. Ask clarifying questions (AskUserQuestion or free-form) for anything material that's missing before drafting — e.g. repro steps + expected/actual for a bug, motivation + acceptance for a feature, definition-of-done for a task. Don't invent details; ask.

### 2. Research the repo (grounding)

Use Grep/Glob/Read to find the code the issue concerns and collect `file:line` references. Derive the area(s) from the touched paths (see **Area detection**).

For **bugs**, also gather repro evidence and show it for trimming before it lands in the body:

- recent matching errors from the repo's own logs, if there's an obvious location — check `docs/`, `CONTRIBUTING.md`, or an observability guide for where logs live before guessing a path, or ask the user to paste the relevant lines,
- any failing-test output the user pointed at.

Keep snippets short (a few lines) and redact secrets, tokens, and personal data; follow the repo's own logging guidance if it documents what not to log.

### 3. Check for duplicates

`gh issue list --search "<keywords>" --state open` (then `--state all` if nothing). If a likely match exists, **stop** and show it; ask: proceed anyway / link as `Related: #N` / cancel.

### 4. Infer priority

From urgency cues: prod-down, blocker, data-loss, or security → `high`; cosmetic or nice-to-have → `low`; otherwise `normal`. Surface the pick in the draft so the user can override.

### 5. Draft the issue

Pick the template for the type (below) and resolve the type down to its actual label now (e.g. `feature` → `enhancement`) — every later step works with that resolved label, never the raw type. Title is `[area] imperative` (stack brackets when it spans). Show the **full draft inline** plus the proposed **type, priority, labels, title**. Then confirm or adjust.

### 6. Ensure labels exist

Compute the label set: the resolved type label + `priority:<level>`. Check what actually exists with `gh label list`, rather than assuming — a repo can have deleted or renamed its defaults. For any label in the set that isn't there, **ask once**, then create with `gh label create`:

- `priority:high` → color `b60205`
- `priority:normal` → color `fbca04`
- `priority:low` → color `0e8a16`
- `chore` → color `c5def5`

(`bug`, `enhancement`, and `documentation` are GitHub's own defaults and normally already exist — the `gh label list` check above catches the case where they don't.)

### 7. Create

Write the body to a temp file (`mktemp`), then:

```bash
gh issue create --title "<title>" --body-file <tmp> --label "<type-label>" --label "priority:<level>"
```

`<type-label>` is the resolved label from Step 5 (`bug` / `enhancement` / `chore` / `documentation`) — never the raw type. Current repo, no `--assignee`/`--milestone`/`--project`. Remove the temp file after.

### 8. Report

Print the issue URL plus a one-line recap: **title · type · priority · area(s) · labels** (and the linked duplicate, if any).

## Area detection

Derive the area for the title bracket, in this order:

1. `areas` in `.claude/git-workflow.md`, matched against the issue's touched paths.
1. Otherwise, the deepest meaningful package directory the touched files live in — the directory owning a `package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, or a workspace-member entry, named by the workspace globs (`pnpm-workspace.yaml`, `package.json` `workspaces`, `go.work`, Cargo workspace members). This is the same rule `commit` uses to derive a scope.
1. Docs-only change → `docs`.
1. Repo-wide, process, or no single area → `meta`.

Stack brackets (`[area1][area2]`) only when the work genuinely spans subsystems. A single-package repo has no useful path-based areas — fall back to `meta`, or omit the bracket if the config says so.

Area lives in the **title bracket only** — it is never a label.

## Type templates

### bug → labels: `bug`, `priority:<level>`

```
[area] <imperative>

<one-line summary of the wrong behavior>

## Steps to reproduce
1. …

## Expected
…

## Actual
…

## Environment
- Where: production | staging | local
- Version / SHA: <if known>

## Evidence
<short log / test snippets, if gathered — redacted>

## References
- path/to/file.ts:line
```

### feature → labels: `enhancement`, `priority:<level>`

```
[area] <imperative>

## Summary
…

## Motivation
<why this matters / what it unblocks>

## Acceptance
- [ ] … (S/M/L)

## Tasks
- [ ] … (S/M/L)

## References
- path/to/file.ts:line
```

### task → labels: `chore` (or `documentation` if docs-only), `priority:<level>`

```
[area] <imperative>

## Summary
…

## Definition of done
- [ ] …

## Tasks
- [ ] … (S/M/L)

## References
- path/to/file.ts:line
```

## Guardrails

- One issue per run — never auto-split into epics/sub-issues.
- Current repo only; unassigned; no milestone/project.
- Confirm before creating any brand-new label.
- On a likely duplicate, stop and ask first.
- Follow the repo's `attribution` config; the default is none — write as "I", no "Generated with…" / Co-Authored-By lines.
