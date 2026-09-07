---
name: pr
description: Turn a finished change into a reviewable, mergeable pull request. Use when asked to "open a PR", "create a pull request", "raise a PR", "PR this", or "send it for review". Drives the whole lifecycle — re-baseline on the default branch, verify end-to-end with visual proof for UI work, self-review for pattern drift and AI-code smells, commit, run the verification gates, write the PR body in a house style, work the review loop, and merge by rebase or squash. Portable across repositories — gates, CI shape, worktree handling, and companion skills are read from the repo's own config or inferred, never hardcoded. Stops at merge; deploying is a separate step.
license: MIT
compatibility: Requires git. The pull-request steps assume GitHub and the `gh` CLI; on another host the same gates apply but the commands need translating.
metadata:
  version: 1.0.0
  author: ai-standards
allowed-tools: Bash Read Glob Grep AskUserQuestion Skill
---

# Pull Request Workflow

Takes a finished change and turns it into a reviewed, mergeable pull request.

By the time this runs the work is usually already committed on a local feature branch, so the default path is review → verify → push → open → review loop → merge.
The readability and commit steps fire only when there are *new* changes to land — self-review fixes, or follow-ups from review.
The uncommitted case is handled too.

Work from a feature branch, ideally a worktree, and never commit on the default branch.
The steps are sequential gates: don't merge or hand the PR off until every one is green.

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
Before doing anything, re-fetch and confirm the branch sits on the current tip.

```bash
git branch --show-current                 # must be a feature branch
git fetch origin <default-branch>
git log HEAD..origin/<default-branch> --oneline   # what landed under you
```

If the base moved, rebase onto it before continuing, then **re-read the actual files in the touched area** — don't trust an earlier read or a subagent's generalization.

Then take stock; the rest of the flow branches on this:

```bash
git status --short                                  # uncommitted changes? usually none
git log --oneline origin/<default-branch>..HEAD     # the commits that will form the PR
gh pr view --json number,state,isDraft 2>/dev/null || echo "no PR yet"
```

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

When the change touches a user interface, attach proof so the reviewer sees it without running the branch.
Use the `ui-capture` role's tool.

**Default to capturing — do it without asking.**
The only case where skipping is even on the table is a change whose visual result is self-evident from the diff alone: a token value, a one-word copy edit, a renamed label.
Even then, don't decide for the user — `AskUserQuestion` whether to capture or skip, and follow the answer.
Never skip silently.
"The stack is slow to start" is not a reason to skip; if it genuinely won't come up, surface that and ask rather than burying a note in the PR body.

**Screenshot, recording, or both — pick by what changed:**

- **Screenshot** — a *state*: new or changed layout, copy, colour, a field, an empty / loading / error state.
  One still per distinct state.
  This is the default.
- **Short recording** — *behavior over time*: a multi-step flow, navigation, a modal opening and closing, an animation, an optimistic update, a loading-to-loaded sequence.
  Set the state up *before* you start recording, then perform only the steps that demonstrate the change.
  A few seconds, not a whole session.
- **Both** — when a flow is worth recording and it ends on a state worth a quick-scan still.

**Which screen sizes:**

- **Both small and large** whenever the change is responsive or layout-affecting — navigation that differs by breakpoint, grids and tables, a modal that becomes a sheet, anything gated on a media query.
  The two layouts differ, so one screenshot hides half the change.
- **One viewport** is enough for a size-agnostic change, or a surface that exists at one size only.
  Say which you captured and why.

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
- **UI change** → run the `a11y` role on the changed components.
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
- Call `Skill(skill="commit")` to draft and validate the message, and use the validated preview verbatim.
  Never hand-roll a message and skip the skill.
- **Before each `git commit`**, give a plain-English explanation of what is about to land and why — which files, what the diff does, any risk — then **wait for the user's OK**.
  One commit at a time; don't batch "here are the next three, OK?".
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
- **If you are unsure about anything in the PR, ask the user.**
  A judgment call you can't settle, a path you couldn't verify, an ambiguity in scope — raise it as a question rather than guessing or burying it in the body.
- The title mirrors the lead commit's subject, under the same type and scope rules as `/commit`.
- **Stacked PR:** if this branch depends on another unmerged branch, set `--base <dep-branch>` so the diff shows only this slice, and retarget to the default branch once the dependency merges.
  Check `ci.checked-bases` first — where CI only runs for PRs onto the default branch, a stacked PR gets *no checks at all*, and a base change alone won't fire them, so push a fresh commit to trigger the run.

### PR body — house style

The diff already shows *what code changed*.
The PR text exists to carry **what the diff can't show**: the intent, and the blast radius across this system.
Every line should answer "what does the reviewer need to know that reading the diff wouldn't tell them?"
Cut anything that just narrates the diff.

If the config names a `review-audience`, write for that reader.
Either way, write it so it also lands for someone who doesn't hold today's context — a non-technical stakeholder, or a new contributor opening this PR a year from now.
Open with the plain-language point: what changes for the product or the person using it, and why it matters.
Spell out acronyms and internal names the first time they appear, and don't assume the surrounding context is in the reader's head.
This is *added on top of* the technical precision, not traded for it — keep the exact terms, just don't lead with them.

**Plain first, exact term right after, in the same sentence** — including in `## Impact`, the section most likely to drift technical because it is the one carrying consequences.
A reader should never have to hold an unexplained term while waiting for its meaning.
Write "nothing touching which organisation can see what (row-level security)", not "no RLS changes".
The failure mode to watch for is the invented compound noun — "id-keyed profile pages", "wire-shape change" — which reads as an established term to whoever coined it and as nothing at all to everybody else.
Say it as a sentence and give an example instead.

Match the recently merged PRs in this repo (`gh pr list --state merged --limit 5 --json number` then `gh pr view <n> --json body`).
Include only the sections that apply, in this order:

- `## What` — one paragraph, opening in plain language: what the change does and **why it matters**, before any jargon.
  Name the surface it lives in so the reviewer knows where to stand.
- `## Changes`, or `## The fix` for a bug — open with a one-line **"Touches:"** naming the moving parts in plain words, then the substantive changes as bullets describing **intent**.
  Not a file list; the diff shows files, and actual filenames belong in `## Review guide` where they help navigation.
  The line may name a neighbouring part this PR did *not* change when that is what makes the flow make sense.
  A reviewer who can picture the flow reads the rest far faster than one reconstructing it from the diff.
- `## Impact` — the blast radius (checklist below).
  Usually the most valuable section, because a decoupled system's ripples don't show in the diff.
  Omit only if genuinely none apply.
- `## Review guide` — how to review this fast: where to look first, the riskiest part and why, any decision you made that the reviewer might overrule, and anything you could not fully verify.
  Mark generated or mechanical parts as skippable.
  This is where Step 3 surfaces what it couldn't resolve.
- `## Screenshots` / `## Demo` — **mandatory for UI PRs**: embed the media, or — only for a self-evident change the user approved skipping — one line `> Screenshots skipped (approved): <reason>`.
  Neither present means an incomplete PR; there is no silent third option.
- `## Tests` — what is covered, when notable.
- `## Verification` — only what you **actually ran**: the gates you executed and the live check you actually performed.
  Never write "all tests pass" for a run you didn't do; an unverified claim here is worse than saying nothing.
- `## Deferred` — follow-ups intentionally not in this PR.

Voice: first-person singular, never "we".
No AI attribution.

### Linking the issue — pick the keyword deliberately

If the PR resolves a tracked issue, end the body with a reference — but the **word matters**, because only `Closes` / `Fixes` / `Resolves` auto-close the issue on merge.
`Addresses` and a bare `#N` link without closing.

Default to **`Closes #N`**: merging the fix is what resolves the issue, the release is a separate delivery step, and the issue can be reopened if verification later fails.
This is the common case; don't overthink it.

Use a non-closing link **only** when merge genuinely does not resolve the issue and something outside this PR must land first — a coordinated deploy, a follow-up slice, a migration someone runs by hand.
When you choose non-closing, say so in one line and **ask the user** whether they'd rather close on merge.
A merged fix that leaves its issue open, with nobody told why, reads as unfinished work.

### Blast radius — what to surface

These are things a human reviewer must act on or verify and **cannot infer from the diff**.
Call out every one the change touches, usually in `## Impact`.

- **Schema or migration** — state which migration must run and *when* relative to the code deploy.
  If the deploy does not run migrations, new code on an unmigrated schema fails on boot.
  Flag any destructive or irreversible step.
- **API or wire-shape contract** — a shape consumed by another service or a typed client ripples outward.
  Note new, removed, or renamed fields, and say whether data must be recreated.
- **New required configuration** — every new environment variable or setting, and that the deployment must set it or the service fails to start.
- **Auth, permissions, or tenancy** — any change to what a given user, role, or tenant can see or do.
  This is a security boundary; say what now sees what.
- **Cross-service or deploy coupling** — anything needing more than one target deployed together, or touching allow-lists, CORS, or forwarding between apps.
- **Cost, rate limits, or fan-out** — new outbound calls, concurrency changes, or paid-provider spend.

Add the repo's own items from `blast-radius:` in the config.
If a change touches none of these, say so briefly rather than leaving the reviewer guessing.

### Embedding media

Media goes **with the PR**.
Never create a media branch — it clutters the repo with a branch nobody asked for, and surprises like that erode trust even when they work.

- **If the repo has a `media-upload` role**, run it: it uploads the captures somewhere public, compacts them, and prints the markdown to paste into the body.
- **Otherwise**, use the host's own attachment path — on GitHub, dragging the file into the description in the web UI mints an attachment URL bound to the PR, and a video becomes an inline player.
  Leave a `> _Drag the recording in here._` placeholder so the spot is obvious.

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

- Treat each fix as a normal change: self-review it (Step 3) → readability (Step 4) → commit (Step 5, with the explain-and-wait gate) → push.
  Don't bypass the gates for "small" review fixes; that is how regressions and drift slip in.
- Reply to each thread with what you did and resolve it once pushed, then re-request review when all are addressed.
- **Keep the PR body in sync** as commits land: if the scope grew, update `## What`, `## Changes`, and `## Impact`.

Loop until CI is green and the review is approved.

## Step 9 — Merge

After approval and green checks.
**Never use a merge commit** — it adds a noisy parent that breaks `git log --oneline` and `git bisect`.

Don't pick squash versus rebase alone.
Post the commit trail with a one-line summary per commit and ask which to use:

```bash
git log <default-branch>..HEAD --oneline
```

**Size decides the starting point.**
A short trail — a handful of commits, each a focused topic — rebases.
A long one is a sign the work sprawled, and squashing to one commit is usually the better end state; the individual commits stay visible on the PR page either way, so squashing costs a reviewer nothing.

**Then check the trail is worth keeping, because a rebase puts every commit on the default branch forever.**
The reason to prefer rebase is that someone can later bisect to the commit that broke something, and that only works if each commit builds on its own.
Verify it rather than assuming:

```bash
for sha in $(git rev-list --reverse <default-branch>..HEAD); do
  git checkout -q $sha
  <typecheck gate> >/dev/null 2>&1 && echo "OK   $(git log --oneline -1)" || echo "FAIL $(git log --oneline -1)"
done
git checkout -q -
```

If commits fail, **squash**: rebasing them puts broken revisions on the mainline, which is worse than one honest commit, because a bisect lands on a build failure and tells you nothing.

This bites hardest after regrouping a sprawling trail by topic.
Splitting by area is the natural way to make a big PR readable, and it reliably produces commits that do not build alone, because a file in one group references something that only arrives in another.
Regrouping is still worth doing — it buys readability, not bisectability.
Do not offer bisect as its justification.

If squashing, draft the squashed message through `/commit` first so it is reviewable.

```bash
gh pr merge <N> --rebase --delete-branch    # or --squash --delete-branch
```

**Never `--delete-branch` a PR that another open PR is stacked on.**
GitHub closes the child instead of retargeting it, and a PR closed because its base branch was deleted cannot be reopened or retargeted — it has to be recreated from scratch.
To land a stack: merge each parent **without** `--delete-branch`, retarget the child and rebase it onto the mainline, then delete the orphaned branches once nothing targets them.

If the rebase hits conflicts, pause and surface it: rebase locally, force-push, then retry the rebase merge.
Never fall back to a merge commit.

`--delete-branch` removes the remote branch only.
Afterwards drop the local one, and if the work was done in a worktree, remove and prune it.

## Conventions this skill encodes

- Re-baseline on the default branch before editing or finalizing a long session.
- The branch is usually already committed; readability and commit fire only for new fixes.
- Verify end-to-end; visual proof for UI, captured by default and skipped only with the user's say-so.
- Self-review the whole branch — reuse not reinvent, pattern conformance against the repo's own docs, scope discipline, AI-code smells — and escalate to review tooling by risk.
- Explain and wait for approval before every commit.
- Tests ride with their logic in one commit.
- Gates in order, build last, no invented commands.
- A PR body that carries what the diff cannot: intent, blast radius, a review guide, and verification claims that are true.
- Plain wording first with the exact term right after it, in the same sentence.
- Open ready by default, watch CI to green, and put review fixes through the same gates.
- Merge by rebase or squash after consulting, never a merge commit, and rebase only a trail whose commits each build on their own.
- An unfilled role degrades to a stated fallback, never a silent skip.
