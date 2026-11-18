# Case-List Report Format

The shape a subagent (or your own survey) uses to report the cases before any test is written.

Ask the agent to report back using a BDD-native shape — the same `describe / context / it` nesting with `GIVEN/WHEN/THEN` that the generated test file will use.
This keeps review cheap (the scenarios map 1:1 to the code you're about to write) and keeps the skill internally consistent.

Prefer spec style (matches vitest / jest / RSpec output; maps onto test classes or nested functions elsewhere):

```text
describe <unit under test>
  context <condition, state, or collaborator setup>
    it should <expected observable behavior>  (unit | integration | browser | visual)
      GIVEN ...
      WHEN ...
      THEN ...
      [`if (!user)` branch]
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
- Tag each `it` with its level, so a mix splits into the right files and each case can be checked against **Where a UI test runs** in `SKILL.md`.
- Cap report length (e.g. "under 400 lines") so it stays reviewable.
