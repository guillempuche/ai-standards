# Changelog

## [1.16.0] - 2026-11-24

### Added

- `pr`: keeps an open PR green — fixes failing checks, rebases on conflicts or a moved base, and answers review comments from people and bots; posts what changed and how to undo it after every push; stops when told, after `ci.max-fix-tries` failed pushes on one check (default 3), or when only a person's review is left; never approves.
- `pr`, `plan-ship`: `findings.md`, shared rules for review findings — verify each against real callers, then sort into `important`, `pre-existing`, or `nit`.
- `pr`, `plan-ship`: `agent-tools.md`, mapping each action and each review depth to Claude Code, Codex, and other agents.
- `plan-ship`: `--stop review`, which also works review comments after the PR opens; it never merges.
- `pr`: without the `commit` skill, writes messages in the style of the last 20 commits and still shows each as a preview.
  `plan-ship` without `pr` warns before planning and ends with the work uncommitted.
- `pr`, `plan-ship`: `REQUIREMENTS.md` in the individual repos, listing companion skills and what happens without each.

### Changed

- `commit`, `issue`, `pr`, `plan-ship`: read `.agents/git-workflow.md` first, then `.claude/git-workflow.md`; first-run setup writes `.agents/`.
- `plan-ship`: `--review` takes `quick|standard|deep` (default `standard`); `high`, `xhigh`, and `max` still work as `standard`, `deep`, `deep`.
- `pr`: steps 4 and 5 merge into "Land new changes"; steps are referred to by name; the conventions recap is cut.
- `plan-ship`: the hand-off to `pr` keeps only what differs from `pr`'s defaults; branch naming comes from its own copy of `tickets.md`.
- `commit`: `.agents/` and `.codex/` count as AI config.
- References several skills share live once in `shared/references/` and are copied by `scripts/sync-manifests.sh`, whose `--check` fails on a stale copy; `issue`'s config docs merge into the shared `repo-config.md`.

## [1.15.0] - 2026-11-23

### Added

- `plan-ship`: a new skill that takes one change from a description, issue, or spec to an open pull request: a worktree on a fresh base, a plan with edge-case and claims tables, audit rounds (later ones by fresh reviewers with one lens each), an approval gate, evidence-first debugging, tests where they earn their place, each code-review finding checked against real callers, then a hand-off to `pr`.
- `plan-ship`: options as flags or plain words (`--branch`, `--draft`, `--stop plan|impl|pr|ci`, `--audits 0-3`, `--review high|xhigh|max`, `--tests auto|none|thorough`, `--commits one|few`, `--no-approval`), repo defaults from a `plan-ship:` block in `.agents/git-workflow.md` or `.claude/git-workflow.md`, and resuming a run from the plan's `Status:` line.
- `plan-ship`: picks where to work (the session's own worktree, the repo's worktree command, a branch in the main checkout when the repo does not support worktrees, or a plain git worktree) and runs project commands through `direnv exec` or `nix develop`.
- `pr`: the config reference documents `worktrees.supported` and `worktrees.create`.

## [1.14.0] - 2026-11-18

### Added

- `test-bdd`: a browser level, separate from visual, for what only a real engine can answer: Tab order that CSS decides, layout and position, CSS that hides or shows, native controls and browser APIs. An ordered list picks simulated DOM (default), browser, visual or end-to-end, and says what a simulated DOM only imitates (jsdom vs. happy-dom).
- `test-bdd`: one file suffix per level, with the default globs that match them all, Go build tags and pytest markers where the runner fixes the name, and tests next to their code unless the project keeps a `tests/` tree.
- `test-bdd`: `browser.md`, with a browser test example, how to keep layout assertions repeatable, and gotchas from a containerised browser setup (Linux locale, CSS-in-JS pre-bundling, server-only imports, matcher types, collection checks).
- `test-bdd`: choosing the quality of each visual capture — 1× or 2× density, exact, normal or tolerant strictness (with Playwright's and Vitest's option names), element, screen or full-page area, lossless PNG, one pinned rendering environment (container or hosted service) — with the reason for any raised setting in a comment.

### Changed

- `test-bdd`: visual tests compare looks only; they may interact to reach a state, but behavior checks move to browser tests.
- `test-bdd`: React Native stays in its test renderer, with no browser level; without a browser runner, engine-only cases are reported as not covered instead of faked in a simulated DOM.
- `test-bdd`: the first visual run fails on purpose while it writes baselines, which are reviewed before the fail check; the update flag never runs in CI.
- `test-bdd`: the version check covers defaults and tool facts as well as calls, reads release notes (a releases page when there is no changelog) and the docs for the installed release rather than the latest, and searches the issues when a version behaves differently from its docs.
- `test-bdd`: the case-list report format moves to `case-list.md`, and each case carries its level, keeping `SKILL.md` within its size budget.

### Fixed

- `test-bdd`: examples test both sides of each length limit, use user-event instead of `fireEvent`, fake the network and payment provider at the boundary, check the email recipient, and keep GIVEN/THEN on every test; the report template's sample anchor no longer uses the `file:line` form it warns against.

## [1.13.0] - 2026-11-06

### Added

- `pr`: before-and-after captures for changes to existing UI, joined side by side with `ffmpeg hstack`, with `agent-browser diff screenshot` / `diff url` for a pixel diff. The before comes from an existing capture, visual-test baseline or deployed base first, then from switching the PR's own checkout (worktree or not) to the base; a second stack is never brought up for it.
- `pr`: a need-to-tool table in `ui-capture.md`, so with no `ui-capture` role the agent picks Playwright's CLI for flows a reviewer must follow and agent-browser for before/after diffs and plain state changes.
- `pr`: reviewer aids in the recorder references: Playwright action callouts and chapters, agent-browser contact sheets, and dark-mode / reduced-motion emulation when the change touches them.

### Fixed

- `pr`: the agent-browser example records with `--cursor`, as the defaults ask, and drops `--bail`, which skipped `record stop` on a failed step and left an unplayable file; the Playwright example stops the video even when a step fails.

## [1.12.0] - 2026-11-06

### Added

- `pr`: UI PRs can carry a screen recording, not only screenshots — `ui-capture.md` says how to record (tool, setup, raw output, seeded data only), and recordings embed as inline video, shrunk rather than dropped when over the host's limit.
- `pr`: quick recording references for `agent-browser` and Playwright's CLI (`playwright-cli` or `npx playwright cli`), each read only when that tool is the recorder and deferring to the installed version's `--help`.
- `pr`: a naming rule for captures (`<screen>-<state-or-flow>-<size>.<ext>`, kept out of commits) and reviewer-friendly recording defaults: one behavior, 5–15 seconds, viewport-sized, cursor on, `.mp4` when the tool can write it.
- `pr`: recordings run start, steps and stop in one call (`agent-browser batch`, a chained or scripted `playwright-cli`) so agent think time leaves no frozen gaps; with no `media-upload` role, leftover gaps are trimmed with `ffmpeg mpdecimate`, and video stays at real speed unless asked.

### Changed

- `repo-config.md`: the `ui-capture` role may name a recorder, and with no role the fallback uses a recording-capable browser tool before capturing by hand.
- `pr`: with no `media-upload` role, captures attach with `gh … --attach` (2.99+) instead of a drag-in placeholder, which stays only for an older `gh` or another host.

## [1.11.0] - 2026-11-02

### Added

- `test-bdd`: visual tests (screenshots against reviewed baselines) alongside unit and integration, and coverage for HTTP handlers, databases, jobs and scripts.
- `test-bdd`: a table of what to drive and what to assert for each kind of code.
- `test-bdd`: `backend-and-scripts.md` and `visual.md` references, with TypeScript and Python samples.

### Changed

- `test-bdd`: tests check behavior through inputs and observable outputs, never implementation details; mocks stay at the boundary, elements are found the way users find them, and each new test is checked to fail when the behavior breaks.
- `test-bdd`: API calls come from the installed library versions' docs, preferring their newest APIs (experimental ones included) and never deprecated ones.

## [1.10.0] - 2026-10-21

### Added

- `commit`, `pr`: optional ticket IDs from Linear, Jira, GitHub or GitLab. The ID leads the commit subject and PR title (`PROJ-12/feat(api): …`), comes from the request or branch name, and is never guessed.
- `commit`, `pr`: a `tickets.md` reference on what each tracker reads in branches, commits, PR titles and bodies, keeping link words apart from close words.
- `repo-config.md`: a `tickets` key (tracker, ID pattern, close policy) inferred from history when unset.

## [1.9.0] - 2026-10-15

### Added

- Codex marketplace (`.agents/plugins/marketplace.json`) listing the bundle and each skill, so `codex plugin marketplace add guillempuche/ai-standards` offers every skill on its own.
- Portable root `plugin.json` for Codex and Antigravity (`agy plugin install`).
- `scripts/sync-manifests.sh` generates both files from the Claude manifests, with a `--check` mode; the repo generator runs it.
- Generated skill repos list `npx skills`, Codex, Gemini CLI, Antigravity, and manual installs, and get their own Codex marketplace and portable `plugin.json`.
- README install steps and compatibility rows for Codex CLI and Antigravity.

## [1.8.2] - 2026-10-05

### Changed

- README and AGENTS.md document installing in Codex, Gemini CLI, OpenCode, Mastra Code, and other agents that read Agent Skills, and add portability rules for skills.
- `issue`: a plain-message fallback where the skill asks the user questions.
- `pr`, `issue`: the trigger phrases users type are back in the descriptions.

## [1.8.1] - 2026-10-04

### Changed

- `unikraft`: says which commands the agent may run and which go to the developer.
- `tamagui`: links to GitHub instead of repo-root `opensrc` paths.
- `pr`: one-commit-at-a-time reconciled with multi-commit previews.
- `test-bdd`: prose breaks at sentences instead of a column width.
- AGENTS.md and the README skill template keep `version` under `metadata` as three-part semver.

## [1.8.0] - 2026-10-04

### Changed

- Skill descriptions narrowed and over-specified guidance trimmed.
- `pr`: body, UI capture, and merge rules moved into references; one approval per commit.
- `test-bdd`: picks the test level from the file kind and runs the generated tests.
- `effect-lookup`: module tables covered by the references dropped.
- `a11y-accessibility-reviewer`: fixes Critical and Major issues instead of only reporting them.

## [1.7.0] - 2026-09-17

### Changed

- `unikraft`: targets CLI 0.5 and flags the comma split in `-e` values.

## [1.6.0] - 2026-09-16

### Added

- `issue` skill: portable GitHub issue workflow.

## [1.5.1] - 2026-09-11

### Changed

- `test-bdd`: documents the `it()` description format and aligns the report template.

## [1.5.0] - 2026-09-07

### Added

- `commit` and `pr` skills: portable commit and pull request workflows.

## [1.4.0] - 2026-08-29

### Changed

- Skill frontmatter and repo generation fixed for current plugin specs.
- Marketplace descriptions added; the agents manifest override dropped so `agents/` auto-discovery works.
- `readability-improver`: reports open questions instead of calling `AskUserQuestion`.
- `a11y-accessibility-reviewer`: code fences that broke the output template fixed.

## [1.3.0] - 2026-07-10

### Changed

- `unikraft`: rewritten for the new `unikraft` CLI, replacing legacy kraftkit `kraft`.
- `test-bdd`: prefers stable code anchors over `file:line` in BDD reports.
- Marketplace plugin names are now topic-only (`powersync`, `effect-lookup`, `unikraft`, `tamagui`, `readability-improver`, `a11y-accessibility-reviewer`) instead of `ai-skill-*` / `ai-agent-*`. GitHub repo slugs are unchanged. Install commands now read `/plugin install powersync@guillempuche-ai-skill-powersync`.

### Added

- `test-bdd` skill: BDD-style test file generator focused on public API and observable behavior. TypeScript + vitest + testing-library patterns for components, hooks, utilities, and constants.
- Naming Conventions section in README documenting the split between marketplace plugin names (topic-only) and GitHub repo slugs (`ai-{type}-{topic}`).

## [1.2.0] - 2026-01-16

### Added

- Readability Improver agent for code clarity improvements
- A11y Reviewer agent for accessibility compliance reviews
- Agents documentation in MARKETPLACE.md

## [1.1.0] - 2026-01-16

### Added

- Effect Lookup skill with module reference and common patterns
- Unikraft skill for unikernel deployment with Kraft CLI

## [1.0.0] - 2026-01-16

### Added

- Initial release
- PowerSync skill for local-first TypeScript apps
