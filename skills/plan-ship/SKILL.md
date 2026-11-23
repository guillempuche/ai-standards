---
name: plan-ship
description: Plan a change in a fresh git worktree, audit the plan twice, and wait for approval before implementing, testing, reviewing, and opening one pull request. Use when asked to "plan and ship" a feature or fix, or to take a change from idea to PR.
license: MIT
compatibility: Requires git. Opening the PR goes through the `pr` skill, which assumes GitHub and the `gh` CLI. Uses the `pr`, `commit`, and `test-bdd` skills when installed.
metadata:
  version: 1.0.0
  author: ai-standards
allowed-tools: Bash Read Glob Grep AskUserQuestion Skill Agent
---

# Plan and Ship

Takes one change from an idea to an open pull request, with one human checkpoint: the plan.

1. Set up a worktree on a fresh base.
1. Write the plan.
1. Audit the plan in two rounds, reporting to the user after each.
1. **Stop** until the user approves the plan.
1. Implement, debugging your own work as you go.
1. Add tests where they earn their place.
1. Run a code review and fix only the findings that hold for this codebase.
1. Hand off to the `pr` skill for readability, end-to-end verification, commits, and opening the PR — then stop.

Every step that names a tool or skill has a fallback.
A missing tool changes *how* a step runs, never *whether* it runs; say which fallback you used.

Read `.claude/git-workflow.md` if the repo has one (the format is in the `pr` skill's `references/repo-config.md`).
Its `worktrees`, `gates`, and `roles` keys override the defaults below.

## 1 — Worktree and environment

Start from what the remote has now, not from a stale local branch:

```bash
git fetch --prune origin
git symbolic-ref -q refs/remotes/origin/HEAD >/dev/null || git remote set-head origin --auto
base=$(git symbolic-ref --short refs/remotes/origin/HEAD)   # e.g. origin/main
```

Name the branch as the `pr` skill's Step 1 describes (ticket ID in the tracker's shape when there is one).
Then pick where the work happens — the first case that applies wins:

1. **Already in a worktree.**
   Some agents start each session in one (`git rev-parse --git-dir` differs from `git rev-parse --git-common-dir`).
   Reuse it if it has no commits or changes of its own, and rebase it onto `$base`.
1. **The repo has its own worktree command.**
   Use it instead of `git worktree add`: such commands often also assign ports, databases, or env files, and a bare git worktree would miss them.
   Take it from `worktrees.create` in the config, else look for one:
   ```bash
   grep -inE 'worktree' package.json justfile Makefile Taskfile.yml 2>/dev/null
   ls scripts bin 2>/dev/null | grep -i worktree
   grep -il worktree AGENTS.md CLAUDE.md CONTRIBUTING.md docs/*.md 2>/dev/null
   ```
   Pass it the branch name and `$base` if it takes them; otherwise check that the branch it made starts at `$base`, and rebase it if not.
1. **The repo does not support worktrees.**
   The config says `worktrees.supported: false`, or the repo's docs say so (fixed ports, one shared container or database, absolute paths baked into the setup).
   Work on a new branch in the main checkout, and only if it is clean:
   ```bash
   test -z "$(git status --porcelain)" && git switch -c <branch> "$base"
   ```
   If it is not clean, ask the user what to do with those changes; never stash or discard them yourself.
   Tell the user the work is happening in their main checkout.
1. **Otherwise** create a plain git worktree inside the repo, so agents that keep the shell's directory only within the project still follow it:
   ```bash
   git worktree add -b <branch> .worktrees/<slug> "$base"
   exclude=$(git rev-parse --git-path info/exclude)
   grep -qxF '.worktrees/' "$exclude" || echo '.worktrees/' >> "$exclude"
   ```
   Use `git rev-parse --git-path info/exclude` rather than `.git/info/exclude`: inside a worktree `.git` is a file, not a directory.
   If a tool run from the main checkout (a file watcher, a repo-wide lint or test glob) starts picking up `.worktrees/`, put the worktree in a sibling directory instead.

When the signals are unclear — a worktree script that looks stale, docs that disagree with the config — ask the user once rather than guessing.
The rest of this skill says "worktree" for wherever the work happens, including the main checkout in case 3.
Some agents reset the working directory between commands, so prefix later commands with `cd <worktree> &&` until you have confirmed the directory sticks.

**Load the dev environment.**
An agent's shell is non-interactive, so the direnv hook never fires: `direnv allow` alone loads nothing into later commands.

- `.envrc` present → run `direnv allow` once, then run every project command through `direnv exec . <cmd>`.
- `flake.nix` without `.envrc` → run project commands through `nix develop -c <cmd>`.
- Neither → use the shell as it is.

The first Nix evaluation in a new worktree can take minutes; run it in the background or with a long timeout rather than concluding it hangs.
Confirm the toolchain resolves (`direnv exec . which <compiler-or-runtime>`) before planning around it.

Then run `worktrees.provision` if the config sets it and the repo's own worktree command did not already, and install dependencies if the repo keeps them per checkout (`node_modules`, `.venv`).
Gitignored files such as `.env` do not exist in a new worktree; if a step needs one, ask the user before copying it from the main checkout.

## 2 — Write the plan

Research before writing.
Read the code the change touches, the repo's own standards (`AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`, `docs/`), and `git log` for prior art in the same area.
When the plan leans on a dependency's behavior, read its source or docs (an `opensrc/` checkout or `node_modules` when present) instead of recalling it.

Write the plan to `PLAN.md` at the worktree root and keep it out of every commit:

```bash
exclude=$(git rev-parse --git-path info/exclude)
grep -qxF 'PLAN.md' "$exclude" || echo 'PLAN.md' >> "$exclude"
```

Use these sections, and keep each one short:

```markdown
# Plan: <change in one line>

## Goal
What the user will see or be able to do afterwards. Non-goals, one line each.

## Current state
Facts about the code today, each with `path:line` evidence.

## Approach
The chosen design, and the strongest alternative with one line on why not.

## Steps
1. <step> — files: … — check: <command or observation that proves this step works>

## Edge cases
| Case | Expected behavior | Test? (yes / no + why) |

## Tests
Which levels (unit, integration, browser, visual), and which areas deliberately get none and why.

## Verification
How the finished change is proven end to end: what to run, what to observe.

## Risks and open questions
Deploy order, migrations, compatibility, and decisions that belong to the user.

## Claims
| # | Claim the plan relies on | Status | Evidence |
```

**Edge cases.**
Go through the categories that apply and list each case the change can meet: empty, missing, or malformed input; boundaries and very large input; errors and partial failure; retries and idempotency; concurrency and ordering; permissions and tenancy; time zones and locales; offline and slow networks; existing data and backward compatibility.
Drop a category in one line when it cannot apply, rather than skipping it silently.

**Claims.**
Every statement the plan depends on — "this function is only called from X", "the API returns null when Y", "the column is nullable" — goes in the Claims table.
It is `verified` only with evidence you can point to: a `path:line`, a command and its output, a doc or source link.
Otherwise it is `unverified`, and that is fine to say.

## 3 — Audit the plan: two rounds

Each round attacks the plan from these angles, fixes `PLAN.md`, and then reports to the user.

- **Facts** — check every claim against the code, types, schemas, docs, or dependency source.
  When reading is not enough, run something: a query against the dev database, a throwaway script in a temp directory, the CLI with `--help` or `--dry-run`, a REPL.
  Delete probes afterwards; nothing from them lands in the worktree.
  Aim to move every claim to `verified`; mark what genuinely cannot be checked before implementation, and say why.
- **Edge cases** — look for cases the table misses, and for expected behaviors nobody decided.
- **Repo fit** — does an existing helper, service, or pattern already do part of this?
  Does the approach follow the documented architecture, or bend it?
- **Scope** — is this the smallest change that reaches the goal, and does it fit one PR?
- **Verifiability** — does every step have a check that would fail if the step were wrong?
- **Failure** — what breaks if the plan is wrong, and how is it rolled back?

**Round 1** is your own audit.
**Round 2** needs eyes not anchored on round 1: hand `PLAN.md` and the repo to a fresh reviewer that has not seen your reasoning (a subagent via `Agent` in Claude Code; otherwise re-read the plan cold, section by section, as a skeptical reviewer).
Round 2 also checks that round 1's fixes did not introduce new problems.

After each round, append `## Audit round N` to `PLAN.md` and send the same notes to the user:

- What was checked, and how.
- What changed in the plan.
- Claims still unverified, and why.
- Questions only the user can answer.

## 4 — Approval gate

Stop here.
Give the user the path to `PLAN.md`, a five-line summary, and the open questions, then wait for an explicit approval (`AskUserQuestion` in Claude Code, or a plain message).
Write no project code before it.

If the user edits the plan or answers questions, update `PLAN.md` and re-audit only what changed.
Run both rounds again only if the approach itself changed.

## 5 — Implement and debug your own work

Follow the plan's steps in order, and after each one run its check — the behavior, not just the compiler.

When something fails or surprises you, debug before patching:

1. Reproduce it with the smallest command or input you can.
1. State a hypothesis about the cause.
1. Confirm it with evidence — a log line, a failing test, a debugger, a printed value — before changing code.
1. Fix the cause, re-run the check, and remove any debug output you added.

Never stack a second guess on an unconfirmed first one.

When reality contradicts the plan, update `PLAN.md`.
If the approach, the scope, or a user-facing behavior has to change, stop and ask before continuing.

## 6 — Tests where they earn their place

Use the `test-bdd` skill; without it, write behavior tests with the project's own runner.

Write tests for logic with branches, parsing and data transforms, public API contracts, the edge cases the plan marked `yes`, and every bug fix (a regression test that fails before the fix).
Skip them for pure configuration, copy and style tweaks, thin wiring the type system already guards, generated code, and glue that could only be tested by mocking everything it touches.
Record each skip in the plan's Edge cases table with its reason.

## 7 — Code review, verified finding by finding

Review the whole diff against `$base` for correctness bugs, at high effort:

- Claude Code → the `code-review` skill at `xhigh`.
- Another agent with a built-in review command → that command.
- Neither → a fresh subagent given only the diff and the repo, or a cold self-review of the diff.

A finding is a hypothesis, not a fact.
For each one, decide whether it holds **in this codebase, for its real callers and inputs**:

- Trace the path from the actual callers, or write a test or probe that triggers it.
- Check whether the triggering input can occur here at all — a type, a validator, or an upstream guard may already rule it out.

Fix only the findings you confirmed, add a regression test where Step 6's rules call for one, and re-run the tests.
For each finding you dismissed, keep one line on why; the PR's review guide carries any you could not settle either way.

## 8 — Hand off to `pr`, stop at open

Leave the work uncommitted, and run the `pr` skill on the worktree's branch.
Tell it:

- The code review already ran and its confirmed findings are fixed, so its Step 3 needs only the self-read checklist unless the code changed since.
- Run its readability pass (the `readability-improver` agent where available).
- Verify end to end before opening: use a verification command or skill if the session has one (such as `/verify` or `run` in Claude Code), otherwise run the changed path by hand as its Step 2 describes.
- Land one or a few focused commits through the `commit` skill, and open exactly one pull request.
- Carry the plan's unverified claims and dismissed-but-unsure review findings into the PR's `## Review guide`.

Stop once the PR is open: do not wait for CI, work the review, or merge.
Report the PR URL, the branch and worktree path, and anything left unverified.
Leave the worktree in place for follow-up fixes; `PLAN.md` stays in it, uncommitted.
