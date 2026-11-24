# Per-repository configuration

The `commit`, `pr`, `issue`, and `plan-ship` skills hold decision logic only.
Every value that differs between repositories lives in one shared config file, so one copy of each skill serves every repo.

Nothing in this file is required.
A repo with no config still works: values are inferred, and roles nothing fills degrade to an inline fallback rather than being skipped.

## Where it lives

Look for the config in this order, and use the first one found; never merge the two.

| File                      | Why                                                                    |
| ------------------------- | ---------------------------------------------------------------------- |
| `.agents/git-workflow.md` | The agent-neutral place: Claude Code, Codex, and other agents read it  |
| `.claude/git-workflow.md` | Where repos that adopted these skills in Claude Code first may keep it |

Then read the `.local.md` file next to it (`.agents/git-workflow.local.md` or `.claude/git-workflow.local.md`), which overlays the committed one key by key.
The committed file is repo truth and is shared; the local file is for one machine or one person, so add it to `.gitignore`.
Credentials, machine-specific hostnames, and paths that exist only on one laptop belong in the local file; gates, scopes, and blast-radius items belong in the committed one.

Both are YAML frontmatter plus free-form markdown notes underneath.
The notes are read too — anything the skills should know that has no key of its own goes there in prose.

## Keys

| Skill       | Reads                                                                              |
| ----------- | ---------------------------------------------------------------------------------- |
| `commit`    | `format`, `scopes`, `types`, `attribution`, `tickets`                              |
| `issue`     | `attribution`, `issue-labels`, `areas`                                             |
| `pr`        | everything except `issue-labels`, `areas`, and `plan-ship`                         |
| `plan-ship` | `plan-ship`, plus `worktrees`, `gates`, and `roles`, and it hands the rest to `pr` |

```yaml
---
platform: github                    # github | gitlab | none — `pr` assumes github when unset
default-branch: main

# commit
format: pnpm biome format --write   # run before staging; omit if a git hook already formats
attribution: none                   # none | co-authored-by — also read by issue
types: [cicd, ai]                   # house additions in use here; omit to infer from history
scopes:                             # omit to infer from workspace layout, then from git log
  apps/api: api
  packages/core: core

# commit and pr — ticket IDs
tickets:
  tracker: linear                   # linear | jira | github | gitlab | none
  pattern: '[A-Z][A-Z0-9]+-[0-9]+'  # the ID's shape; '#[0-9]+' for GitHub and GitLab issues
  close: pr                         # commit | pr | last-pr | never — where closing words may go

# issue
issue-labels:                       # override the default label names
  bug: bug
  feature: enhancement
  task: chore
  docs: documentation
  priority-high: priority:high
  priority-normal: priority:normal
  priority-low: priority:low
areas:                              # path → area name for the issue title bracket
  apps/api: api
  packages/core: core

# pr — verification gates, in run order
gates:
  install: pnpm install
  typecheck: pnpm -w check-types
  lint: pnpm -w lint
  test: pnpm -w test
  build: pnpm -w build              # last: catches paths that only execute in a production build

ci:
  checked-bases: [main]             # a PR onto any other base gets no checks
  required: [ci, e2e]
  max-fix-tries: 3                  # pushes that fail to fix the same check before pr stops and reports

worktrees:
  supported: true                               # false when the setup breaks in a second checkout; plan-ship then branches in place
  create: pnpm cli worktree new <branch>        # the repo's own command that makes a worktree; omit to use `git worktree add`
  provision: pnpm cli worktree up && pnpm dev   # omit when a worktree is just a checkout
  host: https://<label>.example.localhost       # where the provisioned stack answers
  absent-when-worktree: [.env, .env.media]      # gitignored files a worktree will not have

roles:                              # skill / agent / script that fills each slot; omit or ~ for none
  stack-bringup: debug-apps
  code-review: code-review
  readability: readability-improver:readability-improver
  a11y: a11y-accessibility-reviewer:a11y-accessibility-reviewer
  security: security-review
  ui-capture: agent-browser         # may name a recorder, for UI PRs that need a recording
  media-upload: scripts/gh-pr-media.sh
  release: release

blast-radius:                       # repo-specific consequences a reviewer must be told about
  - Deploys do not run migrations — say which migration must land before the service tag.
  - Anything changing which tenant sees which rows is a security boundary; say what now sees what.

review-audience: >
  One reviewer, reading on a phone between other work.

# plan-ship — defaults for its options; options in the request override them
plan-ship:
  audits: 1
  review: deep
  tests: thorough
---
```

A role names whatever fills the slot in the agent the repo uses most; where the session has no such skill or agent, `pr` and `plan-ship` fall back to their `agent-tools.md` reference.

## Bootstrap

On first run in a repo with no config, infer the values the running skill needs, show them, and ask the user to confirm before writing `.agents/git-workflow.md`.
If the repo already has `.claude/git-workflow.md`, add to that file instead of starting a second one.
Inference costs one pass and turns adopting the skills into a single confirmation instead of hand-authoring YAML.

```bash
# Scope vocabulary the repo already uses
git log --pretty=%s -300 | grep -oE '^[a-z]+\(([^)]+)\)' | sed -E 's/^[a-z]+\(//' | sort | uniq -c | sort -rn

# Candidate gates
jq -r '.scripts | keys[]' package.json 2>/dev/null
ls Makefile justfile Taskfile.yml 2>/dev/null

# Which bases actually trigger CI
grep -rA5 '^on:' .github/workflows/*.y*ml 2>/dev/null | grep -A3 pull_request

# Does this repo provision worktrees, or is a worktree just a checkout?
git worktree list

# Ticket IDs: their shape, which tracker, and whether commits ever close
git log --pretty='%s %b' -300 | grep -oE '\b[A-Z][A-Z0-9]+-[0-9]+\b|#[0-9]+' | sed -E 's/[0-9]+$//' | sort | uniq -c | sort -rn
git branch -a --format='%(refname:short)' | grep -iE '[a-z]+-[0-9]+' | head
git log --pretty=%b -300 | grep -oiE 'linear\.app|atlassian\.net|#(done|close|resolve)\b' | sort | uniq -c
git log --pretty=%b -300 | grep -ciE '^(close[sd]?|fix(e[sd])?|resolve[sd]?) '

# Package directories that would give distinct issue areas
find . -maxdepth 3 \( -name package.json -o -name Cargo.toml -o -name go.mod -o -name pyproject.toml \) -not -path '*/node_modules/*'

# Labels that already exist
gh label list --limit 100
```

For tickets: a `linear.app` link or lowercase IDs in branch names point to Linear, `atlassian.net` or smart-commit commands to Jira, and only `#12` references to the host's own issues.
Commits that never carry a closing word suggest `close: pr`.
When there are no signals, leave `tickets` unset; when they disagree, ask.

Fill `roles` from the skills and agents available in the session, and leave a slot empty when nothing fills it.
Write only the keys whose values differ from the defaults — a short config is easier to keep true than a complete one.

## Degradation

An unfilled role is **never a silent skip**.

| Empty role      | Fallback                                                                                                                              |
| --------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| `stack-bringup` | Bring the stack up with the repo's documented commands, or say it could not be run.                                                   |
| `code-review`   | The agent's own review command, else a fresh reviewer, else a cold self-review, as `agent-tools.md` lists.                            |
| `readability`   | Do the readability pass inline against the self-review checklist.                                                                     |
| `a11y`          | Check the changed components against the checklist by hand.                                                                           |
| `security`      | Self-read the sensitive surface and say in the review guide that no scanner ran.                                                      |
| `ui-capture`    | Use a recording-capable browser tool if one is present; else capture by hand; skip only a self-evident change, stating why; else ask. |
| `media-upload`  | Attach with the host's CLI (`gh … --attach` on GitHub); else the web attachment path, with a placeholder line in the body.            |

| Situation                                                       | Fallback                                                               |
| --------------------------------------------------------------- | ---------------------------------------------------------------------- |
| No issue area maps cleanly (single-package repo, cross-cutting) | Omit the bracket, or use `[meta]`.                                     |
| A label in the computed set doesn't exist yet                   | Ask before creating it with `gh label create` — never create silently. |
| `gh auth status` fails                                          | Tell the user to run `gh auth login`; don't attempt the `gh` step.     |

Whatever could not be done is stated in the pull request's `## Review guide`, or asked before the issue draft.
That is what stops a portable skill from being quietly weaker than a repo-specific one.
