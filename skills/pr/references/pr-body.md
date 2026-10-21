# PR body

The house style for the pull request description, the ticket link or close line, the blast-radius checklist, and how to embed media.
Read this from Step 7 of the `pr` skill when writing or refreshing the body.

## House style

The diff already shows *what code changed*.
The PR text exists to carry **what the diff can't show**: the intent, and the blast radius across this system.
Every line should answer "what does the reviewer need to know that reading the diff wouldn't tell them?"
Cut anything that just narrates the diff.

If the config names a `review-audience`, write for that reader.
Either way, write so it also lands for someone without today's context — a non-technical stakeholder, or a new contributor a year from now.
Open with the plain-language point: what changes for the product or the person using it, and why it matters.
This is added on top of the technical precision, not traded for it — keep the exact terms, just don't lead with them.
**Plain first, exact term right after, in the same sentence** — including in `## Impact`, where drift into jargon is most likely: "nothing touching which organisation can see what (row-level security)", not "no RLS changes".
A reader should never have to hold an unexplained term while waiting for its meaning.
Spell out acronyms and internal names on first use.
Watch for invented compound nouns ("id-keyed profile pages", "wire-shape change"): they read as established terms to whoever coined them and as nothing at all to everybody else, so say it as a sentence with an example instead.

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
  This is where Step 3 (self-review) of the `pr` skill surfaces what it couldn't resolve.
- `## Screenshots` / `## Demo` — **mandatory for UI PRs**: embed the media, or — only for a change whose visual result is self-evident from the diff — one line `> Screenshots skipped: <reason>`.
  Neither present means an incomplete PR; there is no silent third option.
- `## Tests` — what is covered, when notable.
- `## Verification` — only what you **actually ran**: the gates you executed and the live check you actually performed.
  Never write "all tests pass" for a run you didn't do; an unverified claim here is worse than saying nothing.
- `## Deferred` — follow-ups intentionally not in this PR.

Voice: first-person singular, never "we".
No AI attribution.

## Linking the ticket — link or close, deliberately

If the PR belongs to a ticket, end the body with one line the tracker reads — but the **word matters**, because a closing word moves the ticket to done on merge and a link word only ties the PR to it.
The words differ by tracker (`Fixes ENG-12` / `Part of ENG-12` in Linear, `Closes #12` / `Refs #12` on GitHub); Jira reads no body words, so the title's key is the link.
See [`tickets.md`](tickets.md).

Default to **closing** when the PR finishes the ticket and `tickets.close` allows it (`commit` or `pr`; under `last-pr`, only the final PR): merging the fix is what resolves the ticket, the release is a separate delivery step, and the ticket can be reopened if verification later fails.
This is the common case; don't overthink it.

**Link** without closing when merge genuinely does not finish the ticket — a follow-up slice, a coordinated deploy, a migration someone runs by hand — or when the policy is `never`.
In Linear a branch or title link alone closes on merge, so a PR that should not close leaves the ID out of its title and links with `Part of ENG-12` in the body.
When you choose to link only and the policy would allow closing, say so in one line and **ask the user** whether they'd rather close on merge.
A merged fix that leaves its ticket open, with nobody told why, reads as unfinished work.

## Blast radius — what to surface

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

## Embedding media

Media goes **with the PR**.
Never create a media branch — it clutters the repo with a branch nobody asked for, and surprises like that erode trust even when they work.

- **If the repo has a `media-upload` role**, run it: it uploads the captures somewhere public, compacts them, and prints the markdown to paste into the body.
- **Otherwise**, use the host's own attachment path — on GitHub, dragging the file into the description in the web UI mints an attachment URL bound to the PR, and a video becomes an inline player.
  Leave a `> _Drag the recording in here._` placeholder so the spot is obvious.
