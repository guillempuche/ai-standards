# AGENTS.md

Instructions for AI coding agents working on this repository.

## Project Overview

This repository contains AI skills. Each skill is a self-contained folder with
a `SKILL.md` file and optional supporting resources.

### Follow the official Agent Skills guidelines

All skills in this repo MUST follow the official Agent Skills guidelines at
<https://agentskills.io/> (full spec: <https://agentskills.io/specification>).
Treat that site as the source of truth — when it disagrees with this file,
the official guidelines win, and this file should be updated to match.

Before adding or modifying a skill, check the official guidelines for the
current rules on:

- `SKILL.md` structure and required frontmatter fields
- `name` / `description` / `version` / `license` / `metadata` / `allowed-tools`
- Progressive disclosure (when to split into `references/`, `assets/`, `scripts/`)
- File-size and line-count limits

If a PR introduces a skill that doesn't comply with agentskills.io, reject it
or fix it before merging.

## Repository Structure

```
ai-standards/
├── README.md               # Human documentation
├── AGENTS.md               # You are here - agent instructions
├── skills/
│   └── <skill-name>/
│       ├── SKILL.md        # Required: skill definition
│       ├── references/     # Optional: detailed docs
│       └── assets/         # Optional: schemas, examples
├── agents/
│   └── <agent-name>.md     # Agent with YAML frontmatter
├── scripts/
│   ├── generate-individual-repos.sh  # Generate dist-repos/
│   └── deploy-individual-repos.sh    # Push to GitHub
├── .claude/skills/          # Local skills (/commit, /release)
└── dist-repos/              # Generated individual repos (gitignored)
```

## Adding a New Skill

1. Create a folder under `skills/` with a lowercase, hyphenated name
1. Create `SKILL.md` with required YAML frontmatter:

```yaml
---
name: skill-name
description: Description of what this skill does and when to use it (max 1024 chars)
license: Apache-2.0
metadata:
  version: 1.0.0
  author: author-name
---
```

1. Add markdown instructions below the frontmatter
1. Optionally add `references/`, `scripts/`, or `assets/` directories
1. Update `README.md` to add skill to the Skills Catalog
1. Update `.claude-plugin/marketplace.json` to add the skill entry

The spec allows exactly six frontmatter keys: `name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools`.
Anything else — including a top-level `version:` — is a hard error when the skill is uploaded to claude.ai, sent through the Skills API, or packaged with `package_skill.py`, so the version belongs under `metadata`.
Always write a three-part semver there: `metadata` values must be strings, and `mdformat` strips the quotes, so a two-part `1.0` would parse as a YAML float.

## SKILL.md Requirements

### Frontmatter (Required Fields)

| Field         | Constraints                                                             |
| ------------- | ----------------------------------------------------------------------- |
| `name`        | Max 64 chars, lowercase letters/numbers/hyphens, must match folder name |
| `description` | Max 1024 chars, describes what skill does AND when to use it            |

### Frontmatter (Optional Fields)

| Field           | Purpose                                  |
| --------------- | ---------------------------------------- |
| `license`       | License name or reference                |
| `compatibility` | Environment requirements (max 500 chars) |
| `metadata`      | String key-value pairs; holds `version`  |
| `allowed-tools` | Space-delimited pre-approved tools       |

### Body Content Guidelines

- Keep main `SKILL.md` under 500 lines
- Include step-by-step instructions
- Provide examples of inputs/outputs
- Document common edge cases
- Move detailed reference material to `references/` folder

## Adding a New Agent

Agents live at `agents/<agent-name>.md` and are picked up by auto-discovery.
`.claude-plugin/plugin.json` deliberately omits the `agents` field: setting it *replaces* the default `agents/` scan, so a newly added agent would silently never load.

Frontmatter follows the [Claude Code subagent reference](https://code.claude.com/docs/en/sub-agents), not the Agent Skills spec:

```yaml
---
name: agent-name
version: 1.0.0
description: When Claude should delegate to this agent. Include "use proactively" to encourage automatic delegation.
tools: Read, Grep, Glob
model: opus
color: yellow
---
```

`version` is not part of the subagent reference either, but Claude Code ignores unknown agent keys and `/release` reads it.
Unlike skills, agents never pass through the claude.ai packaging validator, so it causes no hard error here.
`permissionMode`, `mcpServers`, and `hooks` are ignored for plugin subagents — use `tools` and `disallowedTools` to constrain what an agent can reach.

### Tools a subagent cannot have

Claude Code removes these from every subagent, even when the `tools` field lists them: `AskUserQuestion`, `EnterPlanMode`, `EndConversation`, `ScheduleWakeup`, `TaskOutput`, `WaitForMcpServers`, and `Workflow`.

Never write an agent prompt that asks the user a question mid-task.
Have the agent collect what it could not resolve and return it in its final report, which the main session can then put to the user.

Background subagents lose more still.
They keep only `Read`, `Grep`, `Glob`, `Bash`, `PowerShell`, `Edit`, `Write`, `NotebookEdit`, `WebFetch`, `WebSearch`, `TodoWrite`, `Skill`, `ToolSearch`, `EnterWorktree`, `ExitWorktree`, `Monitor`, `TaskStop`, `SendMessage`, and `Artifact`.

## Validation

Before committing, verify:

- Folder name matches `name` field in frontmatter
- Name uses only lowercase, numbers, hyphens (no consecutive hyphens, no leading/trailing hyphens)
- Description is non-empty and under 1024 characters
- Frontmatter uses only the six spec keys (no top-level `version`)
- All file references use relative paths from skill root
- `claude plugin validate . --strict` passes

## Code Style

- Use 2-space indentation in YAML
- Use standard markdown formatting
- Break prose lines at sentence boundaries, one sentence per line — never mid-sentence, and never wrapped at a column width (`mdformat` runs with the default `--wrap keep`, so it preserves these breaks)
- Use fenced code blocks with language identifiers

## Testing Changes

To test locally with Claude Code:

```bash
# Load entire plugin
claude --plugin-dir .

# Or install from marketplace
/plugin marketplace add guillempuche/ai-skill-powersync
```

## Templates

Add extra files for individual repos in `templates/`:

- `templates/skills/<skill-name>-REQUIREMENTS.md` → copied to skill repo as `REQUIREMENTS.md`
- `templates/agents/<agent-name>-REQUIREMENTS.md` → copied to agent repo as `REQUIREMENTS.md`

These files are NOT part of the main plugin, only the individual repos.

## Generating Individual Repos

Skills and agents are published both in the bundle and as individual repos:

```bash
./scripts/generate-individual-repos.sh    # Creates dist-repos/
./scripts/deploy-individual-repos.sh      # Pushes to GitHub
```

Or use the `/release` skill which automates the full workflow: detect changes, bump versions, regenerate, and deploy.

Use `/commit` to format and commit changes to the main repo.

## PR Guidelines

- Title format: `[skill-name] Brief description`
- Include what the skill does in the PR description
- Ensure all validation checks pass
- One skill per PR when adding new skills

<!-- opensrc:start -->

## Source Code Reference

Source code for dependencies is available in `opensrc/` for deeper understanding of implementation details.

See `opensrc/sources.json` for the list of available packages and their versions.

Use this source code when you need to understand how a package works internally, not just its types/interface.

### Fetching Additional Source Code

To fetch source code for a package or repository you need to understand, run:

```bash
npx opensrc <package>           # npm package (e.g., npx opensrc zod)
npx opensrc pypi:<package>      # Python package (e.g., npx opensrc pypi:requests)
npx opensrc crates:<package>    # Rust crate (e.g., npx opensrc crates:serde)
npx opensrc <owner>/<repo>      # GitHub repo (e.g., npx opensrc vercel/ai)
```

<!-- opensrc:end -->
