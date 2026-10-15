# Marketplace Resources

Quick reference for maintaining this plugin for the Claude Code and Codex marketplaces, and as an Antigravity plugin.

## Official Documentation

| Topic                   | Link                                                            |
| ----------------------- | --------------------------------------------------------------- |
| **Create plugins**      | <https://code.claude.com/docs/en/plugins>                       |
| **Plugin marketplaces** | <https://code.claude.com/docs/en/plugin-marketplaces>           |
| **Plugins reference**   | <https://code.claude.com/docs/en/plugins-reference>             |
| **Agent Skills**        | <https://code.claude.com/docs/en/skills>                        |
| **Plugin settings**     | <https://code.claude.com/docs/en/settings#plugin-configuration> |
| **Discover plugins**    | <https://code.claude.com/docs/en/discover-plugins>              |

## Plugin Manifest Schema

Required fields in `.claude-plugin/plugin.json`:

```json
{
  "name": "plugin-name",           // kebab-case, unique identifier
  "description": "...",            // shown in plugin manager
  "version": "1.0.0"               // semantic versioning
}
```

Optional fields:

- `author` - `{ "name": "...", "email": "...", "url": "..." }`
- `homepage` - plugin docs URL
- `repository` - source code URL
- `license` - SPDX identifier (e.g., "MIT")
- `keywords` - array of tags for discovery
- `skills` - path to skills directory

## Validation

Run before publishing:

```bash
claude plugin validate .
```

## Installation

### Full Bundle (all skills + agents)

```bash
# Add marketplace
/plugin marketplace add guillempuche/ai-standards

# Install plugin
/plugin install ai-standards@guillempuche-ai-standards
```

### Individual Skills

```bash
# PowerSync
/plugin marketplace add guillempuche/ai-skill-powersync
/plugin install powersync@guillempuche-ai-skill-powersync

# Effect Lookup
/plugin marketplace add guillempuche/ai-skill-effect-lookup
/plugin install effect-lookup@guillempuche-ai-skill-effect-lookup

# Unikraft
/plugin marketplace add guillempuche/ai-skill-unikraft
/plugin install unikraft@guillempuche-ai-skill-unikraft

# Tamagui
/plugin marketplace add guillempuche/ai-skill-tamagui
/plugin install tamagui@guillempuche-ai-skill-tamagui

# Test BDD
/plugin marketplace add guillempuche/ai-skill-test-bdd
/plugin install test-bdd@guillempuche-ai-skill-test-bdd
```

### Individual Agents

```bash
# Readability Improver
/plugin marketplace add guillempuche/ai-agent-readability-improver
/plugin install readability-improver@guillempuche-ai-agent-readability-improver

# Accessibility Reviewer
/plugin marketplace add guillempuche/ai-agent-a11y-accessibility-reviewer
/plugin install a11y-accessibility-reviewer@guillempuche-ai-agent-a11y-accessibility-reviewer
```

## Skills Structure

```
skills/
└── skill-name/
    ├── SKILL.md          # Required: frontmatter + instructions
    └── references/       # Optional: additional docs
```

### SKILL.md Frontmatter

```yaml
---
name: skill-name
description: What it does (max 1024 chars)
license: MIT
metadata:
  author: your-name
  version: "1.0"
---
```

## Agents Structure

```
agents/
└── agent-name.md         # Markdown with YAML frontmatter
```

### Agent Frontmatter

```yaml
---
name: agent-name
description: When Claude should invoke this agent (required for delegation)
tools: Read, Grep, Glob, Edit, Write
model: sonnet | opus | haiku
color: yellow                    # Optional: terminal color
permissionMode: default          # Optional: permission handling
---
```

### Supported Agent Fields

| Field             | Required | Purpose                                                          |
| ----------------- | -------- | ---------------------------------------------------------------- |
| `name`            | Yes      | Unique identifier (lowercase, hyphens)                           |
| `description`     | Yes      | When Claude should delegate to this agent                        |
| `tools`           | No       | Tools available (inherits all if omitted)                        |
| `disallowedTools` | No       | Tools to deny/remove                                             |
| `model`           | No       | Model: `sonnet`, `opus`, `haiku`, or `inherit`                   |
| `color`           | No       | Terminal color for agent output                                  |
| `permissionMode`  | No       | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan` |
| `skills`          | No       | Skills to load into agent context                                |
| `hooks`           | No       | Lifecycle hooks (PreToolUse, PostToolUse, Stop)                  |

### plugin.json with Agents

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "skills": "./skills/",
  "agents": "./agents/"
}
```

## Codex and Antigravity

The Claude manifests are the source of truth.
`scripts/sync-manifests.sh` generates the other two from them, and `generate-individual-repos.sh` runs it, so `/release` keeps them in step:

| File                               | Read by            | Generated from                    |
| ---------------------------------- | ------------------ | --------------------------------- |
| `.agents/plugins/marketplace.json` | Codex              | `.claude-plugin/marketplace.json` |
| `plugin.json`                      | Codex, Antigravity | `.claude-plugin/plugin.json`      |

Run `./scripts/sync-manifests.sh --check` to confirm they are current.

### Codex marketplace

Codex reads `.claude-plugin/marketplace.json` only as a legacy fallback, and drops entries with Claude's `"source": "github"`, so it needs its own file.
Each entry uses a `local` source for the bundle or a `url` source for a skill repo, and Codex requires `policy` and `category` on every entry.
Agents are left out because Codex can't load them.

```bash
codex plugin marketplace add guillempuche/ai-standards
codex plugin add powersync@ai-standards
```

Docs: <https://developers.openai.com/plugins/build/plugins>

### Portable plugin.json

The root `plugin.json` follows the [agent-plugins.org](https://agent-plugins.org/) schema.
Antigravity requires it (with `name`) to install a repo as a plugin; Codex prefers it over its legacy fallback.
Codex prefers it over `.claude-plugin/plugin.json` and reports `1.0.0` when it has no `version`, so the script copies the version across.
After bumping `.claude-plugin/plugin.json`, run the script and commit `plugin.json` with the bump.

```bash
agy plugin install https://github.com/guillempuche/ai-skill-powersync
```

Docs: <https://antigravity.google/docs/plugins>

## Checklist for Updates

- [ ] Update version in `.claude-plugin/plugin.json`
- [ ] Run `./scripts/sync-manifests.sh` after changing a Claude manifest
- [ ] Update `CHANGELOG.md` with changes
- [ ] Run `claude plugin validate .`
- [ ] Commit and push to GitHub
- [ ] Create GitHub release (optional)

## Related Standards

- [Agent Skills](https://agentskills.io/) - Portable skill format
- [AGENTS.md](https://agents.md/) - AI agent instructions spec
