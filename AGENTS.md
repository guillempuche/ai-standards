# AGENTS.md

Instructions for AI coding agents working on this repository.

## Project Overview

This repository contains AI skills following the [Agent Skills specification](https://agentskills.io/specification). Each skill is a self-contained folder with a `SKILL.md` file and optional supporting resources.

## Repository Structure

```
ai-standards/
├── README.md           # Human documentation
├── AGENTS.md           # You are here - agent instructions
├── skills/
│   └── <skill-name>/
│       ├── SKILL.md    # Required: skill definition
│       ├── references/ # Optional: detailed docs
│       ├── scripts/    # Optional: helper scripts
│       └── assets/     # Optional: templates, schemas
└── template/
    └── SKILL.md        # Template for new skills
```

## Adding a New Skill

1. Create a folder under `skills/` with a lowercase, hyphenated name
2. Create `SKILL.md` with required YAML frontmatter:

```yaml
---
name: skill-name
description: Description of what this skill does and when to use it (max 1024 chars)
license: Apache-2.0
metadata:
  author: author-name
  version: "1.0"
---
```

3. Add markdown instructions below the frontmatter
4. Optionally add `references/`, `scripts/`, or `assets/` directories

## SKILL.md Requirements

### Frontmatter (Required Fields)

| Field | Constraints |
|-------|-------------|
| `name` | Max 64 chars, lowercase letters/numbers/hyphens, must match folder name |
| `description` | Max 1024 chars, describes what skill does AND when to use it |

### Frontmatter (Optional Fields)

| Field | Purpose |
|-------|---------|
| `license` | License name or reference |
| `compatibility` | Environment requirements (max 500 chars) |
| `metadata` | Key-value pairs for additional info |
| `allowed-tools` | Space-delimited pre-approved tools |

### Body Content Guidelines

- Keep main `SKILL.md` under 500 lines
- Include step-by-step instructions
- Provide examples of inputs/outputs
- Document common edge cases
- Move detailed reference material to `references/` folder

## Validation

Before committing, verify:
- Folder name matches `name` field in frontmatter
- Name uses only lowercase, numbers, hyphens (no consecutive hyphens, no leading/trailing hyphens)
- Description is non-empty and under 1024 characters
- All file references use relative paths from skill root

## Code Style

- Use 2-space indentation in YAML
- Use standard markdown formatting
- Keep lines under 100 characters where possible
- Use fenced code blocks with language identifiers

## Testing Changes

To test a skill locally with Claude Code:
```bash
# From repo root
claude --skill ./skills/your-skill-name
```

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