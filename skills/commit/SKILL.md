---
name: commit
description: Write and validate git commit messages in a Conventional-Commits house style — type, scope, imperative subject, past-tense body bullets, issue-closing trailers. Use when committing changes, splitting work into several commits, or checking whether a proposed message follows the format. Portable across repositories — scope vocabulary, extra types, and the pre-commit formatter are read from the repo's own config or inferred from the repo, never hardcoded.
license: MIT
metadata:
  version: 1.0.0
  author: ai-standards
---

# Git Commit Messages

Draft well-formed commit messages that follow the conventions of whatever repository this runs in.

This file holds the decision logic.
Everything that varies between repositories — scope names, the formatter to run first, which extra types are in use — is read from `.claude/git-workflow.md` or inferred from the repo, never written into the skill.
See [`references/repo-config.md`](references/repo-config.md) for the config keys and the one-time bootstrap.

## Workflow

1. **Adapt to the repo** (next section) — read the config if there is one, otherwise infer.
1. Run the repo's formatter if one is configured, so formatting noise lands with the change instead of in a follow-up commit.
1. Run `git status` and `git diff --staged`, or `git diff` when nothing is staged.
1. Work out what actually changed — which files, what was added or removed, and why.
1. Choose a type and scope for each logical group.
1. Group files into commits, one purpose per commit.
1. Draft each message.
1. Run the **Validation checklist** on every message.
1. Return a **preview** and wait for the user's OK before running `git commit`.

## Adapt to the repo

Resolve every repo-specific value in this order: the config file, then inference from the repo, then the generic default.

| Value       | Config key    | Inferred from                                                    | Default        |
| ----------- | ------------- | ---------------------------------------------------------------- | -------------- |
| Formatter   | `format`      | —                                                                | none           |
| Scopes      | `scopes`      | workspace layout, then the scope vocabulary already in `git log` | omit the scope |
| Extra types | `types`       | presence of CI / AI-config files in the repo                     | base types     |
| Attribution | `attribution` | —                                                                | none           |

**Never invent a formatter.**
Run one only when the config names it.
A repo with a pre-commit hook (lefthook, husky, pre-commit) formats on its own and needs nothing here.

**Read the scope vocabulary the repo already uses** before deriving a new one:

```bash
git log --pretty=%s -300 | sed -nE 's/^[a-z]+\(([^)]+)\).*/\1/p' | sort | uniq -c | sort -rn
```

Matching what the repo has done for 300 commits beats a scope you derived correctly but that nobody else uses.

**If the repo does not use this format at all**, the repo wins.
A history of sentence-style subjects, a `[component] Subject` prefix, or any other consistent convention is a decision someone made, and a lone Conventional-Commits message in the middle of it is the odd one out — not an improvement.
Follow what the history shows, apply the parts of this skill that still hold (imperative subject, body that explains why, no attribution, issue trailers), and say in one line that you matched the existing style.
Switching a repo's convention is the user's call; offer it, don't do it.

## Output format

For each commit, return:

```
### Commit N

**Files:**
- path/to/file1.ts
- path/to/file2.ts

**Message:**
type(scope): subject

- Body bullet.
```

Rules for previews:

- List every staged file that belongs to each commit.
- When proposing several commits, make it unambiguous which files go in each.
- Group related files together — same feature, same scope.
- Present the preview and wait for approval; never commit unprompted.

## Message format

```
type(scope): subject in imperative mood

- Body bullet in past tense with period.
- Another change description.

Closes #123
```

The `Closes #123` trailer is optional — include it only when this single commit is the complete fix for a tracked issue (Rule 9).

## Types

| Type       | When to use                                                              |
| ---------- | ------------------------------------------------------------------------ |
| `feat`     | Added new functionality or new capabilities                              |
| `fix`      | Fixed a bug                                                              |
| `refactor` | Restructured code, no behavior change, no new capabilities               |
| `chore`    | Dev-time: dependencies, tooling, local configs                           |
| `docs`     | Documentation                                                            |
| `test`     | Tests                                                                    |
| `cicd`     | Ship-time: CI/CD, releases, deployment, containers, git hooks            |
| `revert`   | Reverted a previous commit                                               |
| `ai`       | AI configuration — agent configs, skills, prompts, MCP servers, AI rules |

`cicd` and `ai` are house additions to Conventional Commits.
Use them when the repo has files of that kind; a repo whose history never uses them keeps to the base set.

**`chore` vs `cicd`:** if it affects how code *gets to production* (build, CI, release, deploy) it is `cicd`.
If it affects how developers *work locally* (deps, formatting, linting, editor) it is `chore`.

## Scope

Scope is derived from context and varies by type.

| Type                      | Scope convention                                  | Examples                                   |
| ------------------------- | ------------------------------------------------- | ------------------------------------------ |
| `feat`, `fix`, `refactor` | Path-based, from the package the change lives in  | `feat(api):`, `fix(core):`                 |
| `chore`, `docs`           | Path-based, or omitted when the change is mixed   | `chore(web):`, `docs:`                     |
| `cicd`                    | Functional: `release`, `deploy`, or omitted       | `cicd(release):`, `cicd(deploy):`, `cicd:` |
| `test`                    | Path-based: the same scope as the code under test | `test(core):`, `test(api):`                |
| `ai`                      | Component: `skills`, `agents`, `mcp`, or omitted  | `ai(skills):`, `ai(mcp):`, `ai:`           |
| `revert`                  | Matches the original commit's scope               | `revert(web):`                             |

When a change spans several scopes, omit the scope entirely.

### Deriving a path-based scope

Use the **deepest meaningful package directory** — the directory that owns a `package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, or equivalent, named by the workspace globs in `pnpm-workspace.yaml`, `package.json` `workspaces`, `go.work`, or the Cargo workspace members.
The scope is that directory's name, not its full path: `apps/api/` gives `api`, `packages/core/` gives `core`.

Files outside any package — top-level `docs/`, root configs, CI definitions — have no package scope, so omit it.
A single-package repo has no useful path scopes at all; omit the scope or use functional ones the history already shows.

## The `ai` type

`ai` covers anything that **directly configures, instructs, or extends AI capabilities**.

| Category         | Examples                                                            |
| ---------------- | ------------------------------------------------------------------- |
| Agent configs    | `.claude/`, `.cursor/`, `.github/copilot/`, `.aider/`, `.continue/` |
| MCP servers      | `.mcp.json`, MCP server implementations                             |
| Skills & prompts | Skills, system prompts, prompt templates                            |
| AI rules         | `CLAUDE.md`, `AGENTS.md`, `COPILOT.md`, AI coding guidelines        |
| Model configs    | Model selection, temperature, context window settings               |
| AI tooling       | Repomix configs, AI-specific linting rules                          |

Excluded — use another type instead:

- Code that *calls* an AI API is `feat` or `fix`.
- AI library dependencies are `chore`.
- Documentation *about* AI features is `docs`.

## File → type quick lookup

Check the changed paths against these patterns before choosing a type.

| File pattern                                                        | Type   | Scope    |
| ------------------------------------------------------------------- | ------ | -------- |
| `.mcp.json`                                                         | `ai`   | `mcp`    |
| `.claude/skills/**`, `skills/**`                                    | `ai`   | `skills` |
| `.claude/agents/**`, `agents/**`                                    | `ai`   | `agents` |
| `.claude/**`, `CLAUDE.md`, `AGENTS.md`, `COPILOT.md`                | `ai`   | —        |
| `.cursor/**`, `.github/copilot/**`                                  | `ai`   | —        |
| `.github/workflows/**`, `Dockerfile`, container and unikernel files | `cicd` | —        |
| Git-hook and release-tool configs (lefthook, husky, release-it, …)  | `cicd` | —        |

If every changed file matches an `ai` pattern, use the `ai` type.
When AI files are mixed with non-AI files, split them into separate commits.

## Rules

1. **Subject**: imperative mood, lowercase after the colon, no trailing period, at most 72 characters.
1. **Body**: past tense, capital start, period at the end.
   One physical line per bullet — never hard-wrap a bullet mid-sentence at ~72 columns; only the subject has a length limit, so let the terminal soft-wrap.
   **Keep each bullet to a sentence or two.**
   "No hard-wrapping" is about newlines, not about length, and is not licence to write a paragraph on one line.
   A bullet that runs past about two sentences is carrying reasoning that belongs in the pull request description, where there is room for it and where a reader is looking for it.
   `git log` shows these one after another with no headings, so a wall of long bullets is unreadable exactly where commit messages are most often read.
1. **Attribution**: follow the repo's `attribution` policy.
   The default is none — no "Co-Authored-By", no "Generated with", no AI or tool attribution of any kind.
1. **AI-only changes**: when every changed file configures AI (see the `ai` type), use `ai`.
1. **No mechanical cleanup or implementation narration**: don't mention consequences obvious from the primary change (removed unused imports, unwrapped single-child fragments, re-indentation), and don't describe how the diff achieves the change ("added a helper that maps X to Y" when the diff *is* the helper).
   Focus on intent and why, not mechanism.
1. **Plain language for everyone**: write the subject and body so a non-technical reader and a brand-new contributor can follow the change without prior context.
   Lead with the everyday-terms "what changed and why it matters", spell out an acronym or internal name (a table, a service, a flag) the first time it appears, and don't lean on unstated background.
   Keep the precise technical terms — add the plain-language point on top, don't trade it away.
   Commit messages outlive their context: they are read in `git blame`, changelogs, and release notes long after the surrounding work is forgotten.
   **Plain first, exact term right after, in the same sentence.**
   Not a plain paragraph followed by a technical one, and not a technical sentence with a glossary at the end — the reader should never have to hold an unexplained term while waiting for its meaning.
   Write "nothing touching which organisation can see what (row-level security)", not "no RLS changes".
   **The failure mode to watch for is the invented compound noun.**
   "Id-keyed profile pages", "wire-shape change", "boot-time provider selection" all read as established terms to the person who just wrote them and as nothing at all to everybody else.
   When you catch yourself coining one, say it as a sentence instead and give an example.
1. **No tautology**: the subject must not repeat the type as a verb.
   The type already conveys the action — `fix: fix the login` becomes `fix: resolve login failure`; `refactor: refactor auth` becomes `refactor: simplify auth flow`.
1. **No bare `#` tokens in the body**: on GitHub, and in any changelog generated from commit messages, `#<token>` renders as an issue reference — so a hex colour or a fragment id becomes a broken issue link.
   Write `b05220 → 95400f`, not `#b05220 → #95400f`.
1. **Issue-closing trailer**: when one commit is the *complete* fix for a tracked issue, add a `Closes #<issue>` line as the last line, after a blank line, and the host auto-closes the issue when the commit lands on the default branch (`Fixes` and `Resolves` are equivalent keywords).
   This deliberate reference is the one sanctioned exception to Rule 8.
   Only tag the commit that finishes the issue: if the fix spans several commits, leave the trailer off each partial commit and put `Closes #<issue>` in the pull request description instead, so the issue closes once on merge rather than on the first partial commit.
   Skip it entirely for a commit that touches no tracked issue.

## Body sizing

**One bullet per topic, not per file.**
Files are an implementation detail and the diff already lists them.
A topic is a distinct concern a reader needs to understand: a behavior change, a follow-up worth flagging, a side effect that lives outside the diff.
A ten-file rename across one package is one topic; a one-file change that fixes a bug *and* changes an API shape *and* defers a TODO is three.

The diff shows what changed; the message answers *why*.
When in doubt, fewer bullets.
Each bullet earns its place by carrying information the diff doesn't.

| Topics in the change                                    | Body                                                                         |
| ------------------------------------------------------- | ---------------------------------------------------------------------------- |
| Zero — the subject already conveys the intent fully     | None                                                                         |
| One                                                     | 0–1 bullet, at most 2 sentences                                              |
| Two or three — split into separate commits if practical | 2–3 bullets                                                                  |
| More                                                    | First reconsider whether this should be several commits; if not, 3–5 bullets |

**Skip a bullet that:**

- Restates the subject in different words.
- Lists files — `git log --stat` shows them.
- Narrates implementation steps the diff already shows.
- Recaps the investigation, which belongs in the pull request description.
- Reports test counts or "all green" results, unless the change itself is a test-infrastructure fix.

**Keep a bullet that:**

- Explains *why* when it isn't obvious from the diff — a non-local invariant, a regression cause, an external constraint.
- Flags a side effect a future reader might miss — an API shape change, an env var added, a performance trade-off.
- Notes follow-up work intentionally deferred.

## Validation checklist

Run this on every message **before** returning the preview.

1. **Length** — count the subject; reject anything over 72 characters.
1. **Scope** — confirm the scope matches the package the files live in, or is omitted for root-level and mixed changes, and that it matches the vocabulary the repo already uses.
1. **Tautology** — the subject does not repeat the type word.
1. **Mood** — the subject is imperative ("add", "fix", "migrate"), not past tense ("added", "fixed").
1. **Body** — every bullet starts with a capital, uses past tense, and ends with a period.
1. **Body wrapping** — each bullet is a single physical line, with no hard wrap mid-sentence.
1. **Attribution** — no attribution trailers unless the repo's config asks for them.
1. **Issue trailer** — if this one commit fully closes a tracked issue, a `Closes #<issue>` trailer sits alone on the last line; if the fix spans commits, the trailer is absent.

## Examples

```
feat(api): add health check endpoint
```

```
fix(web): handle an empty result list without throwing
```

```
test(api): make the attachment-download test self-sufficient

- The old version reused an account from the seed data, so a parallel test that truncated accounts made this one fail in setup. Synthetic fixture ids survive the truncate and clean up after themselves.
```

```
feat(api): add company search with filters

- Returned summary projections rather than whole records to keep the payload small.
```

```
refactor(core): move the retry policy into the client

- Callers were each choosing their own backoff, so a slow provider was retried three different ways depending on the entry point.
```

```
chore: update workspace dependencies

- Bumped the formatter to 2.4.10 for the stable ordering of import groups.
```

```
cicd(deploy): build workspace packages before the service image

- The shared package now builds first so the service's imports resolve inside the container.
```

```
ai(skills): add a portable commit-message skill
```

```
fix(auth): stop expired sessions from silently renewing

Closes #412
```
