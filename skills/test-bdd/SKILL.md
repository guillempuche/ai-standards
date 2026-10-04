---
name: test-bdd
description: Generate BDD-style test files with GIVEN/WHEN/THEN comments that test only public API and observable outcomes; tuned for, but not limited to, TypeScript + vitest + testing-library. Use when asked to write or add tests for a specific file or module.
license: MIT
metadata:
  version: 1.3.0
---

# BDD Test File Generator

Generate behavior-driven test files that focus on public API and observable behavior.

## Quick Start Workflow

1. **Read the source file** to understand what needs to be tested
1. **Identify the public API** - all exported functions, constants, hooks, or component props
1. **Check for existing test setup** - look for `setup.ts`, `vitest.config.ts`, or existing test files
1. **Pick unit, integration, or both** (see below) — ask only when the file kind is ambiguous
1. **Gather context and draft the case list** — delegate to a subagent when the unit has callers, collaborators, or history worth surveying (see below)
1. **Prune the case list**, resolving any open questions with the user, then generate the test file using patterns from `references/patterns.md`
1. **Run the new tests** — fix failures caused by the test itself, and report any that reveal a real bug in the code instead of changing the assertion to match it

## Delegate Analysis to a Subagent

A single file rarely tells the full story: callers pass specific shapes,
sibling files encode invariants, existing tests hint at conventions, and the
bug that prompted the test may live in the git log. Before writing cases, gather that context and draft the case list — usually via a subagent.
For a self-contained pure function or a constants file, reading it yourself is enough.

Use whatever subagent mechanism your environment offers (in Claude Code, the `Explore` or `general-purpose` agent via the `Agent` tool); without one, do the same survey yourself.
Give it a self-contained brief that includes:

- The exact source path(s) being tested
- The testing level chosen in the previous step (unit / integration / both)
- The framework stack (e.g. vitest + testing-library, jest + supertest)
- The edge-case dimensions listed under **Edge Cases: Analyze from Context**
  — ask the agent to walk those dimensions against the actual code, not as
  a generic checklist
- An instruction to read callers, sibling modules, existing tests, and any
  obvious schema/constant files before proposing cases

Ask the agent to report back using a BDD-native shape — the same
`describe / context / it` nesting with `GIVEN/WHEN/THEN` that the generated
test file will use. This keeps review cheap (the scenarios map 1:1 to the
code you're about to write) and keeps the skill internally consistent.

Prefer spec style (matches vitest / jest / RSpec output):

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

Use Gherkin-style `Feature / Scenario` instead only if the project already
uses Cucumber or a Gherkin runner.

Notes for the agent's report:

- Group scenarios by the code branch or collaborator state they exercise
  (the `context`), not by a "happy / edge / error" bucket — BDD treats them
  as a single flat list of scenarios.
- Annotate each `it` with the code anchor that motivates it, so pruning is
  reviewable. Prefer a **stable** anchor — a named branch or symbol
  (`` `if (!user)` branch ``, `split('?')`) — over `file:line`; line
  numbers drift even between the agent writing the report and you reading
  it. This annotation lives in the report, to be reviewed and discarded.
- Cap report length (e.g. "under 400 lines") so it stays reviewable.

When the report (or your own survey) is done:

1. Resolve the **Open Questions** with the user before generating code, if there are any
1. Drop any case the code doesn't actually distinguish
1. Add anything the agent missed that you can justify from the source

Only then move on to generating the test file.

## Choose: Unit, Integration, or Both?

Decide which level(s) of tests to write for *this* file:

- **Unit tests** — exercise the module in isolation; collaborators (network,
  DB, other modules, timers, the DOM beyond what a single hook/component
  needs) are mocked or stubbed. Fast, many cases, focused on one unit's
  contract.
- **Integration tests** — let the real collaborators run and test how this
  module behaves inside its actual neighborhood (real DB/driver, real HTTP
  client hitting a test server, real router, multiple hooks/components
  composed together). Slower, fewer cases, focused on wiring and
  boundaries.
- **Both** — produce separate files (e.g. `foo.test.ts` and
  `foo.integration.test.ts`) so they can run under different configs.

Default level by file kind:

| File kind                                      | Default level |
| ---------------------------------------------- | ------------- |
| Pure function / utility / constants            | Unit          |
| Hook / component with mockable deps            | Unit          |
| Repository / DB query / HTTP client            | Integration   |
| Router, workflow, or multi-module orchestrator | Both          |

When the file kind matches a row, state the choice and why, and proceed — the user can redirect.
When it is ambiguous (e.g. a hook that also talks to the network), ask the user before generating.
If the user already said which level they want, use that.

## Edge Cases: Analyze from Context, Don't Use a Generic Checklist

"Empty string / null / zero" is a starting list, not the finish line. Before
writing cases, read the source carefully and derive edge cases from what the
code actually does. Check each of these against the file in front of you:

- **Inputs and types** — what does each parameter accept? For every type,
  what are its degenerate values (empty, zero-length, `undefined`, `NaN`,
  `-0`, very large, very small, unicode, trailing whitespace)?
- **Branches and guards** — every `if`, `switch`, `?.`, `??`, `try/catch`,
  early return. Each branch is an edge case worth naming.
- **Boundaries** — off-by-one around lengths/indices, inclusive vs.
  exclusive ranges, min/max of numeric domains, first/last element
  behavior.
- **State and time** — initial render vs. after update, before vs. after
  async resolution, stale closures, cleanup on unmount, race between two
  in-flight requests, timers firing after teardown.
- **Collaborator failures** — what happens when the thing this code calls
  throws, times out, returns `null`, or returns an unexpected shape? Cover
  the ones the code *handles*, and at least one it *doesn't* (to document
  the contract).
- **Concurrency & ordering** — duplicate events, rapid re-renders,
  out-of-order responses, double-submits.
- **Authorization & identity** — missing user, wrong role, expired token —
  wherever the code branches on identity.
- **Environment** — feature-flag on/off, locale/timezone, SSR vs. client,
  dev vs. prod env checks in the code.

Only include cases that the code's behavior actually distinguishes. Don't
pad the file with cases the implementation treats identically — one test per
observable behavior.

## Core Principle

Test public API and observable behavior only, never internal implementation:

- **Hooks/Components**: Test user interactions, props, rendered output
- **Functions/Utilities**: Test inputs → outputs, not internal algorithm steps
- **Constants**: Test exported values are correct

## Test Description Style

The `it(...)` string itself must read as `should <observable behavior>`, matching the THEN outcome.
For example: `it('should redirect the user when the protected route is accessed unauthenticated')`.
Avoid vague (`'works correctly'`) or implementation-focused (`'calls setState'`) descriptions — see `references/patterns.md` → **BDD Description Guidelines** for more good/bad examples.

Inside the test body, use flexible GIVEN/WHEN/THEN/AND comments to document the scenario the description names:

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

The motivating annotations from the agent's case-list report are for review
and pruning — by default keep them OUT of the committed test; the
GIVEN/WHEN/THEN already documents intent. Add an anchor only when an
assertion genuinely benefits from pointing at the code it locks in (e.g.
several sibling `it`s each pin a different branch). When you do, use a
**bare symbol or branch hint** in brackets and nothing more:

```typescript
// GIVEN a magic-link URL with the token in the query
// WHEN normalised
// THEN only the path survives
// [split('?')]
```

Never put a `file:line` in a committed test — the line goes stale on the
next edit above it and silently misleads. Drop the filename too when the
test is co-located with the unit it imports; it's redundant.

## Coverage Requirements

- Primary success paths (happy path)
- Edge cases derived from the code (see **Edge Cases: Analyze from Context**
  above — not a generic "empty / null / zero" checklist)
- Error states (graceful error handling for every `catch`, rejection, or
  fallback branch in the source)
- All exported items
- For integration tests: the real wiring between this module and each
  collaborator it owns in production (don't re-test the collaborator itself)

## References

- `references/patterns.md` - Detailed test patterns and mock handling
- `references/examples.md` - Complete example test files
