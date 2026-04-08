# Changelog

## [1.3.0] - 2026-04-08

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
