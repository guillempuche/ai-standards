# Requirements

`pr` works on its own, and uses the `commit` skill for commit messages when it is installed.
Without `commit`, it writes messages from the style of the repo's recent commits and still shows each one for approval.

## Install the companion skill

With the [`skills`](https://github.com/vercel-labs/skills) CLI, which installs into Claude Code, Codex, and other agents:

```bash
npx skills add guillempuche/ai-skill-commit
```

Or install the whole collection:

```bash
npx skills add guillempuche/ai-standards
```

## Also needed

- `git`.
- The GitHub CLI, `gh`, signed in (`gh auth status`).
