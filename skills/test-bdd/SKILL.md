---
name: test-bdd
description: Generate BDD-style tests with GIVEN/WHEN/THEN comments that check behavior through inputs and observable outputs, never implementation details — unit, integration, or visual, for frontend, backend, or scripts. Use when asked to write or add tests for a file, module, endpoint, or script.
license: MIT
metadata:
  version: 1.4.0
---

# BDD Test File Generator

Generate behavior-driven tests that check what the code does through its inputs and observable outputs, not how it does it.
The same approach covers unit, integration, and visual tests, in any language or framework the project already uses.

## Core Principle

Test behavior through inputs and observable outputs, never internal implementation.
Drive the code the way its callers do — call the function, render the component, send the request, run the script — and assert on what comes back or what a caller can see.
Internal helpers still get covered, through the entry point that uses them.
A test that breaks when the code is refactored without changing its behavior is testing implementation.

Read the code to *find* the cases (branches, guards, boundaries), but *assert* only through the outputs.

### Inputs and outputs by code kind

| Code kind                    | Drive it with                               | Assert on                                                                |
| ---------------------------- | ------------------------------------------- | ------------------------------------------------------------------------ |
| Function / utility           | Arguments                                   | Return value, thrown error                                               |
| Constants / config           | Import                                      | Exported values and the invariants between them                          |
| Component                    | Props, user events (click, type, keyboard)  | Rendered text and roles, callback props fired, navigation                |
| Hook / store                 | Its API, rendered in a test host            | Returned state after each action                                         |
| Visual (component, page)     | A fixed state: props, theme, viewport, data | A screenshot compared with a reviewed baseline                           |
| HTTP handler / route         | A request                                   | Status, body, headers, and the side effect (row written, message queued) |
| Repository / DB query        | Its methods against a real test database    | Data returned, data persisted                                            |
| Job / queue consumer / event | The message or trigger                      | State changed, messages emitted, retries or dead-lettering               |
| CLI / script                 | Arguments, env vars, stdin, input files     | Exit code, stdout/stderr, files written or changed                       |

### Mock at the boundary, assert on outcomes

Mock or fake only what the test cannot or should not run for real: the network, third-party APIs, the clock, randomness, and — in unit tests — slow collaborators such as the database.
Prefer an in-memory fake or a test server over a mock that records calls.
Never mock the unit's own internal modules just to check that one part called another.

Asserting that a mock was called (`toHaveBeenCalledWith`, `assert_called_with`) is fine only when that call **is** the output a caller cares about: a callback prop fired, an email sent, an outgoing request's parameters, an event published.
Say so in the THEN comment, so a reader knows why the call is the behavior.

## Quick Start Workflow

1. **Read the source** to understand what needs to be tested
1. **Identify the entry points** - the exported functions, constants, hooks, component props, routes, jobs, or command-line interface a caller drives; inputs go in and outputs come out there
1. **Check the existing test setup** - runner, config, fixtures, helpers, and existing tests; match the project's language, framework, file naming, and style instead of assuming one, and note the installed version of each test library (see **Use the Installed Library Versions**)
1. **Pick the level: unit, integration, visual, or a mix** (see below) — ask only when the code kind is ambiguous
1. **Gather context and draft the case list** — delegate to a subagent when the unit has callers, collaborators, or history worth surveying (see below)
1. **Prune the case list**, resolving any open questions with the user, then write the tests, using the reference that matches the stack (see **References**)
1. **Run the new tests and check that they can fail** (see below)

## Delegate Analysis to a Subagent

A single file rarely tells the full story: callers pass specific shapes, sibling files encode invariants, existing tests hint at conventions, and the bug that prompted the test may live in the git log.
Before writing cases, gather that context and draft the case list — usually via a subagent.
For a self-contained pure function or a constants file, reading it yourself is enough.

Use whatever subagent mechanism your environment offers (in Claude Code, the `Explore` or `general-purpose` agent via the `Agent` tool); without one, do the same survey yourself.
Give it a self-contained brief that includes:

- The exact source path(s) being tested
- The testing level(s) chosen in the previous step (unit / integration / visual)
- The language and test stack (e.g. vitest + testing-library, pytest, Go `testing`, Playwright)
- The edge-case dimensions listed under **Edge Cases: Analyze from Context** — ask the agent to walk those dimensions against the actual code, not as a generic checklist
- An instruction to read callers, sibling modules, existing tests, and any obvious schema/constant files before proposing cases

Ask the agent to report back using a BDD-native shape — the same `describe / context / it` nesting with `GIVEN/WHEN/THEN` that the generated test file will use.
This keeps review cheap (the scenarios map 1:1 to the code you're about to write) and keeps the skill internally consistent.

Prefer spec style (matches vitest / jest / RSpec output; maps onto test classes or nested functions elsewhere):

```text
describe <unit under test>
  context <condition, state, or collaborator setup>
    it should <expected observable behavior>
      GIVEN ...
      WHEN ...
      THEN ...
      [src/foo.ts:42 — `if (!user)` branch]
    it ...
  context ...

Open questions
  - <ambiguity the agent couldn't resolve from the code>
```

Use Gherkin-style `Feature / Scenario` instead only if the project already uses Cucumber or a Gherkin runner.

Notes for the agent's report:

- Group scenarios by the code branch or collaborator state they exercise (the `context`), not by a "happy / edge / error" bucket — BDD treats them as a single flat list of scenarios.
- Annotate each `it` with the code anchor that motivates it, so pruning is reviewable.
  Prefer a **stable** anchor — a named branch or symbol (`` `if (!user)` branch ``, `split('?')`) — over `file:line`; line numbers drift even between the agent writing the report and you reading it.
  This annotation lives in the report, to be reviewed and discarded.
- Cap report length (e.g. "under 400 lines") so it stays reviewable.

When the report (or your own survey) is done:

1. Resolve the **Open Questions** with the user before generating code, if there are any
1. Drop any case the code doesn't actually distinguish
1. Add anything the agent missed that you can justify from the source

Only then move on to generating the test file.

## Choose: Unit, Integration, Visual, or a Mix?

Decide which level(s) of tests to write for *this* code:

- **Unit tests** — exercise the module in isolation; collaborators (network, DB, other modules, timers, the DOM beyond what a single hook/component needs) are faked or stubbed.
  Fast, many cases, focused on one unit's contract.
- **Integration tests** — let the real collaborators run and test how this module behaves inside its actual neighborhood (real DB/driver, real HTTP server, real router, the script run as a real process, multiple components composed together).
  Slower, fewer cases, focused on wiring and boundaries.
- **Visual tests** — render a fixed state and compare a screenshot with a reviewed baseline.
  They catch what text and role assertions cannot: layout, spacing, colour, theming, overflow, responsive breakpoints.
  They complement behavior tests; they never replace them.
- **A mix** — produce separate files (e.g. `foo.test.ts`, `foo.integration.test.ts`, `foo.visual.spec.ts`) so each runs under its own config, following the project's existing naming.

Default level by code kind:

| Code kind                                         | Default level                                                              |
| ------------------------------------------------- | -------------------------------------------------------------------------- |
| Pure function / utility / constants               | Unit                                                                       |
| Hook / store / component logic with mockable deps | Unit                                                                       |
| Design-system component, page layout              | Unit + Visual                                                              |
| Repository / DB query / HTTP client               | Integration                                                                |
| HTTP handler / route / job / queue consumer       | Integration                                                                |
| CLI / script                                      | Integration (run it as a process), plus Unit for any pure logic it exports |
| Router, workflow, or multi-module orchestrator    | Unit + Integration                                                         |

When the code kind matches a row, state the choice and why, and proceed — the user can redirect.
When it is ambiguous (e.g. a hook that also talks to the network), ask the user before generating (`AskUserQuestion` in Claude Code, or a plain message).
If the user already said which level they want, use that.
Write visual tests only when the project already has a visual-testing tool (Playwright screenshots, Storybook with Chromatic or a test runner, Loki, …); otherwise suggest one and ask before adding the dependency.

## Edge Cases: Analyze from Context, Don't Use a Generic Checklist

"Empty string / null / zero" is a starting list, not the finish line.
Before writing cases, read the source carefully and derive edge cases from what the code actually does.
Check each of these against the code in front of you:

- **Inputs and types** — what does each parameter, request field, or command-line argument accept?
  For every type, what are its degenerate values (empty, zero-length, `undefined`/`None`, `NaN`, `-0`, very large, very small, unicode, trailing whitespace)?
- **Branches and guards** — every `if`, `switch`, `?.`, `??`, `try/catch`, early return.
  Each branch is an edge case worth naming.
- **Boundaries** — off-by-one around lengths/indices, inclusive vs. exclusive ranges, min/max of numeric domains, first/last element behavior, pagination edges.
- **State and time** — initial render vs. after update, before vs. after async resolution, stale closures, cleanup on unmount, race between two in-flight requests, timers firing after teardown, dates around midnight or DST.
- **Collaborator failures** — what happens when the thing this code calls throws, times out, returns `null`, or returns an unexpected shape?
  Cover the ones the code *handles*, and at least one it *doesn't* (to document the contract).
- **Concurrency & ordering** — duplicate events, rapid re-renders, out-of-order responses, double-submits, the same message delivered twice, two writers on one row.
- **Authorization & identity** — missing user, wrong role, expired token — wherever the code branches on identity.
- **Process and filesystem** (scripts, jobs) — missing env var, missing or unreadable input file, existing output file, empty stdin, interrupted run, re-running after a partial run.
- **Visual states** (visual tests) — each theme, breakpoint, and variant the component styles differently; loading, empty, and error states; long text, overflow, right-to-left.
- **Environment** — feature-flag on/off, locale/timezone, SSR vs. client, dev vs. prod env checks in the code.

Only include cases that the code's behavior actually distinguishes.
Don't pad the file with cases the implementation treats identically — one test per observable behavior.

## Test Description Style

The test name must read as `should <observable behavior>`, matching the THEN outcome.
For example: `it('should redirect the user when the protected route is accessed unauthenticated')`, or `test_should_exit_with_code_2_when_the_input_file_is_missing` where the runner uses function names.
Avoid vague (`'works correctly'`) or implementation-focused (`'calls setState'`) descriptions — see `references/patterns.md` → **BDD Description Guidelines** for more good/bad examples.

Inside the test body, use flexible GIVEN/WHEN/THEN/AND comments, in the language's comment syntax, to document the scenario the name describes:

```typescript
// Full form
// GIVEN an unauthenticated user
// WHEN the protected route is accessed
// THEN the user should be redirected

// With AND for multiple assertions
// GIVEN a user is authenticated
// WHEN the profile page loads
// THEN the username should be displayed
// AND the avatar should be visible

// Simple form (no WHEN needed)
// GIVEN an empty array
// THEN length should be zero

// Multiple conditions
// GIVEN a valid token
// AND the user has admin role
// WHEN accessing admin panel
// THEN access should be granted
```

### Optional code anchor in the committed test

The motivating annotations from the agent's case-list report are for review and pruning — by default keep them OUT of the committed test; the GIVEN/WHEN/THEN already documents intent.
Add an anchor only when an assertion genuinely benefits from pointing at the code it locks in (e.g. several sibling `it`s each pin a different branch).
When you do, use a **bare symbol or branch hint** in brackets and nothing more:

```typescript
// GIVEN a magic-link URL with the token in the query
// WHEN normalised
// THEN only the path survives
// [split('?')]
```

Never put a `file:line` in a committed test — the line goes stale on the next edit above it and silently misleads.
Drop the filename too when the test is co-located with the unit it imports; it's redundant.

## Use the Installed Library Versions

Test libraries rename options, deprecate helpers, and ship breaking changes; the code samples in `references/` can fall behind them.
Treat those samples as the *shape* of a good test — what to drive, what to assert, how to word GIVEN/WHEN/THEN — never as the current API.
Before writing calls, check what the installed versions offer:

1. **The installed version** — read it from the lockfile or manifest (`package.json`, `pyproject.toml`, `go.mod`, …).
1. **That version's official docs and changelog** — they show the newest APIs, including experimental ones, and what was renamed or deprecated.
1. **The installed package's types or source** — for exact signatures when the docs are unclear.
1. **The project's existing tests** — for conventions such as fixtures, helpers, and file layout, not as a limit on which APIs to use.

Use the newest API the installed version offers, experimental ones included, even where existing tests still use an older call.
Never use a deprecated call; when the runner prints a deprecation warning, switch to the replacement it names before finishing.
When a test relies on an experimental API, say so in your final report, so the user knows to recheck it on the next upgrade.
Don't add an option that only restates a default.

## Run the Tests and Check They Can Fail

1. Run the new tests with the project's own command.
1. Fix failures caused by the test itself.
   Report any that reveal a real bug in the code instead of changing the assertion to match it.
1. Check that each test can fail: briefly break the behavior it covers (flip a condition, return a wrong value) and confirm the test goes red, then restore the code.
   A test that stays green is not testing that behavior — rewrite it.
   Do this for at least the tests whose assertions you are least sure of; revert every such change before finishing.
1. For visual tests, the first run writes the baselines.
   Tell the user which baseline images were created so they can review them, and never regenerate a baseline to make a failing comparison pass without reporting the difference.

## Coverage Requirements

- Primary success paths (happy path)
- Edge cases derived from the code (see **Edge Cases: Analyze from Context** above — not a generic "empty / null / zero" checklist)
- Error states (graceful error handling for every `catch`, rejection, fallback branch, or non-zero exit in the source)
- Every entry point a caller uses
- For integration tests: the real wiring between this module and each collaborator it owns in production (don't re-test the collaborator itself)
- For visual tests: one screenshot per visual state the code distinguishes, not one per prop combination

## References

The samples show the shape of each kind of test; take the exact API calls from the project's installed versions (see **Use the Installed Library Versions**).

- `references/patterns.md` - TypeScript patterns: vitest, testing-library, mock handling, and description guidelines
- `references/backend-and-scripts.md` - HTTP handlers, repositories with a real database, and scripts run as processes, with TypeScript and Python examples
- `references/visual.md` - Visual tests: making screenshots deterministic, choosing states, and handling baselines
- `references/examples.md` - Complete example test files
