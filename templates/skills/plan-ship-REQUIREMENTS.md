# Requirements

`plan-ship` plans, audits, implements, and reviews on its own, but it hands the last step to other skills.
Install them alongside it in the same agent.

| Skill      | What it does here                                | Without it                                                    |
| ---------- | ------------------------------------------------ | ------------------------------------------------------------- |
| `pr`       | Commits the work and opens the pull request      | The run ends after the code review, with the work uncommitted |
| `commit`   | Writes commit messages in the repo's house style | `pr` writes them from the style of the repo's recent commits  |
| `test-bdd` | Writes behavior tests                            | Tests are written with the project's own test runner          |

## Install

With the [`skills`](https://github.com/vercel-labs/skills) CLI, which installs into Claude Code, Codex, and other agents:

```bash
npx skills add guillempuche/ai-skill-pr
npx skills add guillempuche/ai-skill-commit
npx skills add guillempuche/ai-skill-test-bdd
```

Or install the whole collection, which includes all of them:

```bash
npx skills add guillempuche/ai-standards
```

## Also needed

- `git`.
- The GitHub CLI, `gh`, signed in (`gh auth status`), for opening the pull request.
