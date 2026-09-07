# Per-repository configuration

The `commit` and `pr` skills hold decision logic only.
Every value that differs between repositories lives here, so one copy of each skill serves every repo.

Nothing in this file is required.
A repo with no config still works: values are inferred, and roles nothing fills degrade to an inline fallback rather than being skipped.

## Where it lives

| File                            | Scope                     | Committed?               |
| ------------------------------- | ------------------------- | ------------------------ |
| `.claude/git-workflow.md`       | Repo truth, shared        | Yes                      |
| `.claude/git-workflow.local.md` | One machine or one person | No — add to `.gitignore` |

The local file overlays the committed one key by key.
Credentials, machine-specific hostnames, and paths that exist only on one laptop belong in the local file; gates, scopes, and blast-radius items belong in the committed one.

Both are YAML frontmatter plus free-form markdown notes underneath.
The notes are read too — anything the skills should know that has no key of its own goes there in prose.

## Keys

`commit` reads `format`, `scopes`, `types`, and `attribution`.
`pr` reads all of them.

```yaml
---
platform: github                    # github | gitlab | none — `pr` assumes github when unset
default-branch: main

# /commit
format: pnpm biome format --write   # run before staging; omit if a git hook already formats
attribution: none                   # none | co-authored-by
types: [cicd, ai]                   # house additions in use here; omit to infer from history
scopes:                             # omit to infer from workspace layout, then from git log
  apps/api: api
  packages/core: core

# /pr — verification gates, in run order
gates:
  install: pnpm install
  typecheck: pnpm -w check-types
  lint: pnpm -w lint
  test: pnpm -w test
  build: pnpm -w build              # last: catches paths that only execute in a production build

ci:
  checked-bases: [main]             # a PR onto any other base gets no checks
  required: [ci, e2e]

worktrees:
  provision: pnpm cli worktree up && pnpm dev   # omit when a worktree is just a checkout
  host: https://<label>.example.localhost       # where the provisioned stack answers
  absent-when-worktree: [.env, .env.media]      # gitignored files a worktree will not have

roles:                              # skill / agent / script that fills each slot; omit or ~ for none
  stack-bringup: debug-apps
  code-review: code-review
  readability: readability-improver:readability-improver
  a11y: a11y-accessibility-reviewer:a11y-accessibility-reviewer
  security: security-review
  ui-capture: agent-browser
  media-upload: scripts/gh-pr-media.sh
  release: release

blast-radius:                       # repo-specific consequences a reviewer must be told about
  - Deploys do not run migrations — say which migration must land before the service tag.
  - Anything changing which tenant sees which rows is a security boundary; say what now sees what.

review-audience: >
  One reviewer, reading on a phone between other work.
---
```

## Bootstrap

On first run in a repo with no config, infer the values, show them, and ask the user to confirm before writing `.claude/git-workflow.md`.
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
```

Fill `roles` from the skills and agents available in the session, and leave a slot empty when nothing fills it.
Write only the keys whose values differ from the defaults — a short config is easier to keep true than a complete one.

## Degradation

An unfilled role is **never a silent skip**.

| Empty role      | Fallback                                                                            |
| --------------- | ----------------------------------------------------------------------------------- |
| `stack-bringup` | Bring the stack up with the repo's documented commands, or say it could not be run. |
| `readability`   | Do the readability pass inline against the self-review checklist.                   |
| `a11y`          | Check the changed components against the checklist by hand.                         |
| `security`      | Self-read the sensitive surface and say in the review guide that no scanner ran.    |
| `ui-capture`    | Ask the user whether to skip screenshots; never drop them silently.                 |
| `media-upload`  | Use the host's manual attachment path and leave a placeholder line in the body.     |

Whatever could not be done is stated in the pull request's `## Review guide`.
That is what stops a portable skill from being quietly weaker than a repo-specific one.
