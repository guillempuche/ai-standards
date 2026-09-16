# Per-repository configuration

The `issue` skill holds decision logic only.
Every value that differs between repositories lives in `.claude/git-workflow.md` — the same file the `commit` and `pr` skills read — so one copy of the skill serves every repo.

Nothing in this file is required.
A repo with no config still works: labels and areas fall back to inference or the defaults below, and attribution defaults to none.

## Where it lives

| File                            | Scope                     | Committed?               |
| ------------------------------- | ------------------------- | ------------------------ |
| `.claude/git-workflow.md`       | Repo truth, shared        | Yes                      |
| `.claude/git-workflow.local.md` | One machine or one person | No — add to `.gitignore` |

The local file overlays the committed one key by key. If this repo already configured `.claude/git-workflow.md` for `commit` or `pr`, `issue` reads the same `attribution` key from it — nothing to duplicate.

## Keys

`issue` reads `attribution`, `issue-labels`, and `areas`.

```yaml
---
attribution: none          # none | co-authored-by — shared key, same file as commit/pr

issue-labels:                # override the default label names
  bug: bug
  feature: enhancement
  task: chore
  docs: documentation
  priority-high: priority:high
  priority-normal: priority:normal
  priority-low: priority:low

areas:                       # optional path → area-name map for the title bracket
  apps/api: api
  packages/core: core
---
```

Write only the keys whose values differ from the defaults above — a short config is easier to keep true than a complete one.

## Bootstrap

On first run in a repo with no `areas` config, infer the area vocabulary and show it before writing anything:

```bash
# Package directories that would give distinct areas
find . -maxdepth 3 \( -name package.json -o -name Cargo.toml -o -name go.mod -o -name pyproject.toml \) -not -path '*/node_modules/*'

# Labels that already exist, so Step 6 knows what it doesn't need to create
gh label list --limit 100
```

Confirm the inferred `areas` map with the user before writing it to `.claude/git-workflow.md`.

## Degradation

| Situation                                                        | Fallback                                                               |
| ---------------------------------------------------------------- | ---------------------------------------------------------------------- |
| No area maps cleanly (single-package repo, cross-cutting change) | Omit the bracket, or use `[meta]`.                                     |
| A label in the computed set doesn't exist yet                    | Ask before creating it with `gh label create` — never create silently. |
| `gh auth status` fails                                           | Tell the user to run `gh auth login`; don't attempt issue creation.    |

Whatever couldn't be resolved automatically is surfaced as a question before the draft, not buried in the created issue.
