---
name: pr
description: Take a finished branch through to a merged GitHub pull request — verify, self-review, open, work the review, merge. Use when asked to "open a PR", "raise a PR", "PR this", "send it for review", or to update or merge a PR.
license: MIT
compatibility: Requires git. The pull-request steps assume GitHub and the `gh` CLI; on another host the same gates apply but the commands need translating.
metadata:
  version: 1.1.1
  author: ai-standards
allowed-tools: Bash Read Glob Grep AskUserQuestion Skill
---

# Pull Request Workflow

Takes a finished change and turns it into a reviewed, mergeable pull request.

By the time this runs the work is usually already committed on a local feature branch, so the default path is review → verify → push → open → review loop → merge.
The readability and commit steps fire only when there are *new* changes to land — self-review fixes, or follow-ups from review.
The uncommitted case is handled too.

Work from a feature branch, ideally a worktree, and never commit on the default branch.
Don't merge or hand the PR off until every gate is green.
Stop at merge; deploying is a separate step.

This file holds the decision logic.
Everything that varies between repositories comes from `.claude/git-workflow.md` or is inferred from the repo — see [`references/repo-config.md`](references/repo-config.md).

## Step 0 — Adapt to the repo

Read the config if there is one; otherwise infer and, on first run, offer to write it.

- **Gates** — `gates:` in config, else the repo's `package.json` scripts, `Makefile`, `justfile`, or equivalent.
- **CI** — `ci.checked-bases`, else the `pull_request` triggers in `.github/workflows/*`.
  Never assume a PR gets checks; confirm the trigger matches this PR's base.
- **Worktrees** — `git rev-parse --git-common-dir` differing from `.git` means this is a worktree.
  `worktrees.provision` says whether one needs its own stack brought up or is just a checkout.
- **Roles** — `roles:` maps each slot (stack bring-up, readability, a11y, security, UI capture, media upload) to whatever this repo has.
  Where the config is silent, look for a skill or agent in this session that fills the slot.
  Where nothing does, use the fallback in the reference — an empty slot is never a silent skip.

## Step 1 — Re-baseline on the default branch

Branches drift while a session runs, especially when other PRs are merging in parallel.
Before doing anything, confirm you're on a feature branch, fetch the default branch, and check what landed under you.
If the base moved, rebase onto it before continuing, then **re-read the actual files in the touched area** — don't trust an earlier read or a subagent's generalization.

Then take stock of uncommitted changes, the commits that will form the PR, and whether a PR already exists; the rest of the flow branches on this:

- **Already committed (common)** — Steps 2–3 review the whole branch; Steps 4–5 fire only if you make fixes.
- **Uncommitted (rarer)** — the full readability and commit flow applies before the gates.
- **PR already exists** — you will update it, not open a duplicate.

**In a worktree:** gitignored files do not exist here.
`.env`, local credentials, and machine-specific config live only in the main checkout, so a script that reads them fails in a worktree for a reason that has nothing to do with the change.
`worktrees.absent-when-worktree` lists the ones that bite in this repo; run those scripts from the main checkout rather than concluding the tool is unavailable.

## Step 2 — Verify end-to-end (do not skip)

Type-checks and unit tests are **not** enough — they have passed on changes that produced wrong behavior at runtime.
Run the changed path for real and confirm the user-visible behavior.

Bring the stack up with the `stack-bringup` role if the repo has one.
In a worktree that needs provisioning, use `worktrees.provision` and target the host it prints rather than the shared local host.

- **CLI** — run the actual command and inspect its output and any state it wrote.
- **Service** — hit the endpoint, check the response and the service log.
- **UI** — drive the page and confirm the rendered state.
- **Data** — reset and re-seed, verify what landed, then drive the surface that reads it.

### UI changes — capture visual proof (required)

When the change touches a user interface, capture screenshots or a short recording with the `ui-capture` role, without asking.
Skip only when the visual result is self-evident from the diff — a token value, a one-word copy edit, a renamed label — and say why in one line under `## Screenshots`.
What to capture and at which screen sizes: [`references/ui-capture.md`](references/ui-capture.md).

If the repo localizes its interface, confirm every new user-facing string goes through the translation mechanism and that any extraction step has been run.

## Step 3 — Self-review: the review-readiness gate

The reviewer's time is for judgment calls, not for catching what a careful self-read or the repo's own tooling would.
Review your own diff and fix what you find, so the PR that reaches a human is already pattern-conformant, on-direction, and free of AI-code smells.
Review the **whole branch**, since the work is usually already committed: `git diff origin/<default-branch>...HEAD`, plus `git diff` for anything uncommitted.
Scale the depth to the change.

**Always — self-read the diff against this checklist:**

- **Reuse, not reinvent** — did I add a service, helper, type, or component that already exists?
  Search before adding; AI-written code tends to recreate what is already there.
- **Pattern conformance** — does the diff match the repo's documented patterns?
  Read the repo's own standards (`AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`, `docs/`) rather than guessing from the surrounding file.
- **No directional drift** — does this quietly bend the architecture: a new ad-hoc layer, a dependency pointing the wrong way, a boundary sidestepped "just here"?
  If it diverges from the documented design, that is a decision to **surface** in the `## Review guide`, not to bury.
- **Scope discipline** — every hunk serves this PR's one purpose.
  No drive-by reformatting, unrelated renames, or tangential edits.
  If something unrelated must ride along, call it out explicitly.
- **AI-code smells** — no leftover `TODO`, debug logging, or commented-out blocks; no escape hatches out of the type system where narrowing would do; no over-abstraction; no refactoring-narration or plan-label comments.
- **Tests test behavior** — assert observable outcomes through the public API, not implementation details, and cover branches, guards, and edge cases rather than only the happy path.

**Escalate by risk, and fix findings before opening the PR:**

- **Substantive logic change** → run the `code-review` role on the diff for correctness bugs.
- **Sensitive surface** — auth, tenancy or permission scoping, a parser or sanitizer, crypto, file upload, a webhook or other external input → run the `security` role.
  Note in the review guide if no scanner was available.
- **UI change** → run the `a11y` role on the changed components; it may apply fixes itself, so review its diff and handle its open items.
- **Trivial diff** — typo, copy, dependency bump, comment → the self-read alone is enough.

Fix what these surface, re-verify (Step 2), and re-read the checklist on the fix.
Carry anything you couldn't resolve into the `## Review guide` rather than leaving it silent.

**Drift is bigger than one PR.**
This step catches point-in-time deviations.
The same small deviation repeated across many PRs is invisible at diff granularity, so a per-PR gate cannot catch it alone — that needs enforcement-as-code (lint rules, import-boundary checks in CI), generated or tested docs, and a scheduled repo-wide audit.

## Step 4 — Readability pass (only when committing new changes)

Steps 4 and 5 fire **only if there is something uncommitted to land** — the original work in the uncommitted case, or fixes from Steps 2–3 or from review.
If the branch is already fully committed and self-review found nothing, skip to Step 6.

Otherwise run the `readability` role on the files about to be committed.
It is selective and skips self-documenting code, so the cost is low.
Skip it only for a trivial commit — a single-line typo, a dependency bump, a rename with no body change.
Re-run the type-check gate after it edits.

## Step 5 — Commit

Same condition as Step 4: only when there is something uncommitted to land.

- Stage one logical group at a time.
  **Tests ride in the same commit as the logic they cover** — never a separate logic-then-tests split.
  A standalone `test:` commit is fine only when no logic changed.
- Use the `commit` skill to draft and validate the message, and use the validated preview verbatim.
  Never hand-roll a message and skip the skill.
- **The commit preview is the approval gate.**
  When the `commit` skill shows its preview, add a plain-English explanation alongside it — which files, what the diff does, any risk — and that one OK covers the commit.
  One commit at a time; don't batch "here are the next three, OK?".
  If the `commit` skill's preview proposes several commits, show the whole plan once, then get the OK and land each commit in turn.
- One PR per slice, with focused commits.
  Never split a slice across PRs.

## Step 6 — Verification gates

Run the repo's gates in order: install → type-check, lint, and test in parallel → build last.
Every one must exit zero before the PR opens.

Build goes last because it is the only gate that executes production-only paths — bundling, chunking, catalog compilation, dead-code elimination.
A green test suite with a broken build has shipped before.
Fix and re-run until all are green; don't assume CI will catch it.

If a gate does not exist in this repo, say so rather than inventing a command or quietly skipping the check.

## Step 7 — Push and open (or update) the PR

Push the branch, then create or update — never open a duplicate:

```bash
git push -u origin <branch>
gh pr view --json number,state,isDraft 2>/dev/null \
  && echo "PR exists → the push updated it; refresh the body if the scope grew" \
  || gh pr create --base <default-branch> --title "type(scope): subject" --body-file <file>
```

- **Open ready for review by default.**
  A committed, self-reviewed, verified change is finished.
  Reserve `--draft` for work you can *name* as unfinished: a partial slice, a known-broken intermediate, something opened early for direction.
  Protect the reviewer by working CI to green before handing off, not by parking finished work in draft.
- **Ask the user only about decisions that are theirs** — a scope ambiguity, a trade-off only the user can settle.
  Anything you couldn't verify goes in `## Review guide`, stated plainly, rather than guessed or buried.
- The title mirrors the lead commit's subject, under the same type and scope rules as the `commit` skill.
- **Stacked PR:** if this branch depends on another unmerged branch, set `--base <dep-branch>` so the diff shows only this slice, and retarget to the default branch once the dependency merges.
  Check `ci.checked-bases` first — where CI only runs for PRs onto the default branch, a stacked PR gets *no checks at all*, and a base change alone won't fire them, so push a fresh commit to trigger the run.

### PR body

The body carries what the diff can't show: the intent, and the blast radius across the system.
Write it per [`references/pr-body.md`](references/pr-body.md) — section order, the plain-language rule, which issue-closing keyword to use, the blast-radius checklist, and how to embed media.

## Step 8 — Review loop

Between opening and merging is where most of the work is; don't jump to merge.

**Watch CI to green:**

```bash
gh pr checks <N> --watch
```

A check that passes locally and fails in CI is usually an environment or strict-mode difference — env scoping, build-only paths, a stricter CI config.
Fix it, push, and re-run the relevant gate on the fix.
If you opened as a draft and the work is now complete, `gh pr ready <N>`.

**Address review comments:**

```bash
gh pr view <N> --comments
```

- Treat each fix as a normal change: self-review it (Step 3) → readability (Step 4) → commit (Step 5, through the preview gate) → push.
  Don't bypass the gates for "small" review fixes; that is how regressions and drift slip in.
- Reply to each thread with what you did and resolve it once pushed, then re-request review when all are addressed.
- **Keep the PR body in sync** as commits land: if the scope grew, update `## What`, `## Changes`, and `## Impact`.

Loop until CI is green and the review is approved.

## Step 9 — Merge

After approval and green checks.
**Never use a merge commit** — it adds a noisy parent that breaks `git log --oneline` and `git bisect`.

Recommend rebase or squash with the reason, then confirm with the user before merging.
A short trail of focused commits that each build on their own rebases; a long trail, or one with commits that don't build, squashes.
**Never `--delete-branch` a PR that another open PR is stacked on** — GitHub closes the child, and it cannot be reopened.

The decision rules, the per-commit build check, and how to land a stack are in [`references/merge.md`](references/merge.md).

## Conventions this skill encodes

- Re-baseline on the default branch before editing or finalizing a long session.
- The branch is usually already committed; readability and commit fire only for new fixes.
- Verify end-to-end; visual proof for UI, captured by default and skipped only for self-evident changes, with the reason stated.
- Self-review the whole branch — reuse not reinvent, pattern conformance against the repo's own docs, scope discipline, AI-code smells — and escalate to review tooling by risk.
- One approval per commit: the explained preview.
- Tests ride with their logic in one commit.
- Gates in order, build last, no invented commands.
- A PR body that carries what the diff cannot: intent, blast radius, a review guide, and verification claims that are true.
- Plain wording first with the exact term right after it, in the same sentence.
- Open ready by default, watch CI to green, and put review fixes through the same gates.
- Merge by rebase or squash after confirming, never a merge commit, and rebase only a trail whose commits each build on their own.
- An unfilled role degrades to a stated fallback, never a silent skip.
