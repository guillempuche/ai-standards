---
name: test-bdd
description: Generate BDD-style tests with GIVEN/WHEN/THEN comments that check behavior through inputs and observable outputs, never implementation details — unit, integration, browser, or visual, for frontend, backend, or scripts. Use when asked to write or add tests for a file, module, endpoint, or script.
license: MIT
metadata:
  version: 1.5.0
---

# BDD Test File Generator

Generate behavior-driven tests that check what the code does through its inputs and observable outputs, not how it does it.
The same approach covers unit, integration, browser, and visual tests, in any language or framework the project already uses.

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
| Browser (component, page)    | Real keyboard and pointer, viewport size    | Focus, element position and visibility, what CSS hides or shows          |
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
1. **Pick the level: unit, integration, browser, visual, or a mix** (see below) — ask only when the code kind is ambiguous
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
- The testing level(s) chosen in the previous step (unit / integration / browser / visual)
- The language and test stack (e.g. vitest + testing-library, pytest, Go `testing`, Playwright)
- The edge-case dimensions listed under **Edge Cases: Analyze from Context** — ask the agent to walk those dimensions against the actual code, not as a generic checklist
- An instruction to read callers, sibling modules, existing tests, and any obvious schema/constant files before proposing cases

Ask the agent to report the cases in the same `describe / context / it` shape with GIVEN/WHEN/THEN that the test file will use, each tagged with its level and the code that motivates it, plus open questions; read `references/case-list.md` for the report format to put in the brief.

When the report (or your own survey) is done:

1. Resolve the **Open Questions** with the user before generating code, if there are any
1. Drop any case the code doesn't actually distinguish
1. Add anything the agent missed that you can justify from the source

Only then move on to generating the test file.

## Choose: Unit, Integration, Browser, Visual, or a Mix?

Decide which level(s) of tests to write for *this* code:

- **Unit tests** — exercise the module in isolation; collaborators at its boundary (network, database, third-party services, clock and timers) are faked or stubbed, while its own internal modules run for real.
  Fast, many cases, focused on one unit's contract.
  Web UI units run in a simulated DOM (jsdom or happy-dom); React Native components run in the platform's test renderer (React Native Testing Library).
- **Integration tests** — let the real collaborators run and test how this module behaves inside its actual neighborhood (real DB/driver, real HTTP server, real router, the script run as a real process, multiple components composed together).
  Slower, fewer cases, focused on wiring and boundaries.
- **Browser tests** — render the component in a real browser engine and check behavior that a simulated DOM cannot compute (see **Where a UI test runs** below).
  The rest of the component's logic stays in the faster simulated-DOM tests.
- **Visual tests** — render a fixed state and compare a screenshot with a reviewed baseline.
  They catch what assertions describe badly: spacing, colour, theming, typography, how a layout looks at each breakpoint.
  They may click, hover, or focus to reach a state, but the screenshot is their only assertion, so a failing one means "it looks different", never "it behaves differently".
  They complement behavior tests; they never replace them.
- **A mix** — produce separate files so each runs under its own config (see **File names** below).

Default level by code kind:

| Code kind                                         | Default level                                                              |
| ------------------------------------------------- | -------------------------------------------------------------------------- |
| Pure function / utility / constants               | Unit                                                                       |
| Hook / store / component logic with mockable deps | Unit                                                                       |
| Component whose behavior depends on CSS or layout | Unit + Browser                                                             |
| Design-system component, page layout              | Unit + Visual, plus Browser for what only a real engine can answer         |
| Repository / DB query / HTTP client               | Integration                                                                |
| HTTP handler / route / job / queue consumer       | Integration                                                                |
| CLI / script                                      | Integration (run it as a process), plus Unit for any pure logic it exports |
| Router, workflow, or multi-module orchestrator    | Unit + Integration                                                         |

When the code kind matches a row, state the choice and why, and proceed — the user can redirect.
When it is ambiguous (e.g. a hook that also talks to the network), ask the user before generating (`AskUserQuestion` in Claude Code, or a plain message).
If the user already said which level they want, use that.
Write browser or visual tests only when the project already has a tool that runs a real browser (Vitest browser mode, Playwright, Storybook with Chromatic or a test runner, Loki, …); otherwise suggest one and ask before adding the dependency.
Until one exists, write the simulated-DOM tests and list the engine-only cases in your report as not covered; never write them against a simulated DOM, where they check nothing.

### Where a UI test runs

Pick the first level that can answer the question; each one down is slower and more fragile, so a case moves down only when the ones above cannot see the behavior.

1. **Simulated DOM — jsdom, happy-dom (default):** logic, rendered text and roles, events, callbacks, state, ARIA attributes, and focus moved by the component's own code.
1. **Real browser, one component or page:** Tab order where CSS decides what is reachable; layout and position (overflow, one element covering another, out of the viewport, sticky); CSS that hides or shows (stylesheets, media and container queries, `:hover` styles); native controls and APIs (date inputs, `details`/`summary`, `dialog`, `inert`, `matchMedia`, `IntersectionObserver`, `ResizeObserver`).
1. **Real browser, screenshot:** looks only — spacing, colour, theme, typography, a layout no assertion describes well.
1. **End-to-end, the whole app:** what needs the deployed stack — auth, cookies, Content Security Policy, server rendering, navigation between pages.

A simulated DOM has no layout (every box measures 0×0) and doesn't load the app's CSS files by default.
The rest it imitates: the testing library moves focus on Tab by DOM order and `tabindex`, jsdom ignores `@media` and lacks `matchMedia`, `dialog.showModal()` and `inert`, and happy-dom evaluates media queries against a fixed default window.
An assertion about any of these checks the imitation, not the app.

React Native has no browser level unless it renders through react-native-web: its logic and rendering stay in the test renderer, and on-device behavior belongs to the end-to-end suite (Detox, Maestro).
Don't propose a browser runner for it.

Don't write end-to-end tests unasked: when a case needs one, say so and suggest it for the project's end-to-end suite.
When the user asks for one, the same BDD rules apply, in the project's end-to-end tool.

### File names

Unless the project already separates levels differently, give each level its own suffix, so each config includes its own files and excludes the rest:

- `x.test.ts(x)` — unit (simulated DOM for web UI)
- `x.integration.test.ts` — integration
- `x.browser.test.tsx` — browser
- `x.visual.test.tsx` — visual

Default globs match all of these at once (`*.test.*` in Vitest and Jest; `*.test.*` and `*.spec.*` in Playwright Test), so narrow each config's include and exclude the other levels, or a test runs twice, in the wrong environment, or not at all.
Where the runner fixes the file name, separate levels its own way instead: Go compiles only `_test.go` files as tests (use `//go:build integration`), and pytest collects only `test_*.py` and `*_test.py` (use markers or folders).

Put each test file next to the code it tests, so it moves and gets deleted with that code — unless the project keeps tests in a separate tree such as `tests/`; then follow it, since a file outside the runner's test paths is never collected.
Keep shared utilities (fixtures, fakes, render helpers) in a test folder.

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
- **Layout and input** (browser tests) — each viewport or container width where something hides, moves, or wraps; keyboard-only use; content long enough to scroll or overflow.
- **Visual states** (visual tests) — each theme, breakpoint, and variant the component styles differently; loading, empty, and error states; long text, overflow, right-to-left.
- **Environment** — feature-flag on/off, locale/timezone, SSR vs. client, dev vs. prod env checks in the code.

Only include cases that the code's behavior actually distinguishes.
Don't pad the file with cases the implementation treats identically — one test per observable behavior.

## Test Description Style

The test name must read as `should <observable behavior>`, matching the THEN outcome.
For example: `it('should redirect the user when the protected route is accessed unauthenticated')`, or `test_should_exit_with_code_2_when_the_input_file_is_missing` where the runner uses function names.
Avoid vague (`'works correctly'`) or implementation-focused (`'calls setState'`) descriptions — see `references/patterns.md` → **BDD Description Guidelines** for more good/bad examples.

Inside the test body, use flexible GIVEN/WHEN/THEN/AND comments, in the language's comment syntax, to document the scenario the name describes; `references/patterns.md` → **BDD Comment Combinations** shows the other forms:

```typescript
// GIVEN a user is authenticated
// AND the user has the admin role
// WHEN the admin panel loads
// THEN the user list should be displayed
// AND the audit link should be visible
```

### Optional code anchor in the committed test

Keep the case-list report's code anchors out of the committed test by default; the GIVEN/WHEN/THEN already documents intent.
Add one only when several sibling tests each pin a different branch, as a bare symbol or branch hint in brackets after the THEN, such as `// [split('?')]`.
Never put a `file:line` (or the filename of a co-located unit) in a committed test: the line goes stale on the next edit above it and silently misleads.

## Use the Installed Library Versions

Test libraries rename options, change defaults, deprecate helpers, and ship breaking changes; the code samples in `references/` and the tool facts this skill states (defaults, file names, what a simulated DOM supports) can fall behind them.
Treat the samples as the *shape* of a good test — what to drive, what to assert, how to word GIVEN/WHEN/THEN — and the tool facts as claims to recheck, never as the current API.
Before writing calls or relying on a default, check what the installed versions offer:

1. **The installed version** — read it from the lockfile or manifest (`package.json`, `pyproject.toml`, `go.mod`, …).
1. **That version's official docs and release notes** — the changelog, or the repository's releases page when there is none; they show the newest APIs, including experimental ones, and what was renamed, deprecated, or given a new default.
   Docs sites usually show the latest release, so use the versioned docs or the docs at the installed release's tag.
   When the installed version behaves differently from its docs, search the repository's issues before working around it.
1. **The installed package's types or source** — for exact signatures when the docs are unclear.
1. **The project's existing tests** — for conventions such as fixtures, helpers, and file layout, not as a limit on which APIs to use.

Use the newest API the installed version offers, experimental ones included, even where existing tests still use an older call.
Never use a deprecated call; when the runner prints a deprecation warning, switch to the replacement it names before finishing.
When a test relies on an experimental API, say so in your final report, so the user knows to recheck it on the next upgrade.
Don't add an option that only restates a default.

## Run the Tests and Check They Can Fail

1. Run the new tests with the project's own command.
   Browser and visual tests often have their own command and may need browser binaries, a browser container, or a running dev server; start what the project's config expects and say what you started.
1. Fix failures caused by the test itself.
   Report any that reveal a real bug in the code instead of changing the assertion to match it.
1. Check that each test can fail: briefly break the behavior it covers (flip a condition, return a wrong value) and confirm the test goes red, then restore the code.
   A test that stays green is not testing that behavior — rewrite it.
   Do this for at least the tests whose assertions you are least sure of; revert every such change before finishing.
1. For visual tests, the first run writes each missing baseline and fails on purpose (Vitest and Playwright both do); that failure is not one to fix.
   Tell the user which baseline images were created so they can review them before trusting a green run: a retry or a second run passes against whatever image the first one wrote.
   Check that a visual test can fail only after its baseline is reviewed, because breaking the code first would record the broken look as the baseline.
   Never regenerate a baseline or loosen a threshold to make a failing comparison pass without reporting the difference.

## Coverage Requirements

- Primary success paths (happy path)
- Edge cases derived from the code (see **Edge Cases: Analyze from Context** above — not a generic "empty / null / zero" checklist)
- Error states (graceful error handling for every `catch`, rejection, fallback branch, or non-zero exit in the source)
- Every entry point a caller uses
- For integration tests: the real wiring between this module and each collaborator it owns in production (don't re-test the collaborator itself)
- For browser tests: one test per behavior that needs the real engine; anything a simulated DOM can check stays in the unit file
- For visual tests: one screenshot per visual state the code distinguishes, not one per prop combination

## References

The samples show the shape of each kind of test; take the exact API calls from the project's installed versions (see **Use the Installed Library Versions**).

- `references/case-list.md` - Read when briefing a subagent (or drafting the case list yourself): the report format and how to annotate each case
- `references/patterns.md` - Read when writing frontend unit tests: React with vitest and testing-library (other frameworks' testing-library packages take the same shape), mock handling, and description guidelines
- `references/backend-and-scripts.md` - Read when testing HTTP handlers, repositories with a real database, jobs, or scripts run as processes; TypeScript and Python examples
- `references/browser.md` - Read when writing a browser test or adding a browser runner: what to check there, an example, and setup gotchas
- `references/visual.md` - Read when writing a visual test: making screenshots deterministic, choosing states, the quality of each capture, and handling baselines
- `references/examples.md` - Read when you want a complete test file to model: a component, a hook, validators, and constants
