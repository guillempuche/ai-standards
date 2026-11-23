# Auditing a plan

Read this before the first audit round.
It holds the evidence ladder, ways to break common claims, edge-case techniques, the angles for each kind of repo, and the brief for a fresh reviewer.

## Evidence ladder

From weakest to strongest:

1. Read it in the code or the docs.
1. The type checker or compiler agrees — for example, a deliberately wrong call fails to compile.
1. An existing test exercises it.
1. A probe shows it: a throwaway script, a read-only query, a REPL session.
1. Observed at runtime: a log line, a trace, or a response from the running app.

For a dependency, the bar is the source or docs of the version the lockfile pins, not the latest release and not memory.
Write the highest rung reached in the Evidence column — `read: src/x.ts:40`, `probe: query returned 0 rows` — so the user can weigh it.

## Breaking common claims

| Claim                       | Where it usually breaks                                                                                                                                                                                                                                                                                                                 |
| --------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| "Only called from X"        | Find-references in a language server when the agent has one, then a word-bounded text search, then what neither sees: names built from strings, reflection, dependency injection, routes or jobs registered in config, generated code, other packages in the monorepo, other repos (`gh search code`), external clients of a public API |
| "Never null" / "always set" | The schema allows null; existing rows already hold it (count them with a read-only query); another writer skips the field; an older app version still writes the old shape                                                                                                                                                              |
| "X happens before Y"        | Concurrent requests, retries, queues, caches, and background jobs                                                                                                                                                                                                                                                                       |
| "Nothing depends on this"   | A public API, serialized or stored data, URLs, CLI output that scripts parse, the docs                                                                                                                                                                                                                                                  |
| "The library supports this" | The pinned version predates it, or its changelog says it changed                                                                                                                                                                                                                                                                        |

## Finding edge cases

- **Equivalence classes and boundaries** — split each input into classes, then try the minimum, one below it, the maximum, one above it, zero, one, and many.
- **State × event** — list the states an entity can be in and every event that reaches it; each pair is a case, including an event arriving in the wrong state.
- **Role × action** — each role or tenant against each new action, including no session and an expired one.
- **Lifecycle** — first run, upgrade over old data, rollback after a partial deploy, a migration interrupted halfway.
- **Hostile input** — Unicode and emoji, right-to-left text, very long values, whitespace only, and null versus missing versus empty.
- **Time** — a daylight-saving change, a leap day, the end of a month, other time zones, clocks that disagree between machines.
- **Concurrency** — a double submit, two open tabs, a retry after a timeout, messages delivered out of order.

## Angles by kind of repo

Use only the rows that match what the change touches.

| Kind                 | Ask about                                                                                                                                                     |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Frontend             | Empty, loading, and error states; keyboard and screen reader; translations and long strings; small screens; offline and slow networks; stale cached data      |
| Backend or API       | Authorization per tenant; retries that must be idempotent; transactions and partial failure; timeouts and rate limits; responses that old clients still parse |
| Data and migrations  | Existing rows that break a new constraint; backfill size and table locks; reversibility; the deploy order of migration and code                               |
| CLI and scripts      | Exit codes; piped input versus a terminal; interruption by a signal; paths with spaces; running twice                                                         |
| Library or SDK       | Semver impact on the public API; supported runtime and platform versions; bundle size and tree-shaking; a deprecation path                                    |
| Mobile               | Old app versions still in use; denied OS permissions; backgrounding and resuming; slow devices                                                                |
| Infrastructure or CI | Drift from the declared state; rollback; secrets and permissions; blast radius per environment                                                                |
| Jobs and queues      | Duplicate delivery; messages that always fail; the backlog after an outage; schedules across time zones                                                       |

## Briefing a fresh reviewer

A fresh reviewer is only useful if it is not anchored on your reasoning, so give it:

- the paths to the plan file and the worktree;
- the input sources — the user's words, the issue, the spec;
- one lens from the list below;
- these rules: read-only probes only; return findings as severity, evidence, and suggested change; do not edit the plan or the code; list questions for the user rather than trying to ask them.

Leave out your own reasoning and what earlier rounds concluded, beyond the plan file itself.

Choose lenses by the size of the change — one for a small change, all three in parallel for a risky one:

- **Facts and correctness** — the Claims table, the requirements trace, and whether each step's check would catch a wrong step.
- **Adversarial** — security, abuse, data loss, privacy, and the edge-case techniques above.
- **Operations** — deploy order, migrations, observability, rollback, and performance at real data sizes.
