# Changelog

## [Unreleased]

### Added

- Codex marketplace (`.agents/plugins/marketplace.json`) listing the bundle and each skill, so `codex plugin marketplace add guillempuche/ai-standards` offers every skill on its own.
- Portable root `plugin.json` for Codex and Antigravity (`agy plugin install`).
- `scripts/sync-manifests.sh` generates both files from the Claude manifests, with a `--check` mode; the repo generator runs it.
- Generated skill repos get their own Codex marketplace, a portable `plugin.json`, and Codex and Antigravity install steps.
- README install steps and compatibility rows for Codex CLI and Antigravity.

## [1.8.2] - 2026-10-05

### Changed

- README and AGENTS.md document installing in Codex, Gemini CLI, OpenCode, Mastra Code, and other agents that read Agent Skills, and add portability rules for skills.
- `issue`: a plain-message fallback where the skill asks the user questions.
- `pr`, `issue`: the trigger phrases users type are back in the descriptions.
- Generated skill repos list `npx skills`, Gemini CLI, and manual installs.

## [1.8.1] - 2026-10-04

### Changed

- `pr`: one-commit-at-a-time reconciled with multi-commit previews.
- `test-bdd`: prose breaks at sentences instead of a column width.
- AGENTS.md and the README skill template keep `version` under `metadata` as three-part semver.

## [1.8.0] - 2026-10-04

### Changed

- Skill descriptions narrowed and over-specified guidance trimmed.
- `pr`: body, UI capture, and merge rules moved into references; one approval per commit.
- `test-bdd`: picks the test level from the file kind and runs the generated tests.
- `effect-lookup`: module tables covered by the references dropped.
- `unikraft`: says which commands the agent may run and which go to the developer.
- `tamagui`: links to GitHub instead of repo-root `opensrc` paths.
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

## [1.3.0] - 2026-04-08

### Changed

- `unikraft` (released 2026-07-10): rewritten for the new `unikraft` CLI, replacing legacy kraftkit `kraft`.
- `test-bdd` (released 2026-07-10): prefers stable code anchors over `file:line` in BDD reports.

### Changed

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
