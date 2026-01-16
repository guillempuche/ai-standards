# Deployment Guide

How to deploy changes to ai-standards and individual repos.

## Repository Structure

```
ai-standards (bundle)          → guillempuche/ai-standards
├── skills/powersync/          → guillempuche/ai-skill-powersync
├── skills/effect-lookup/      → guillempuche/ai-skill-effect-lookup
├── skills/unikraft/           → guillempuche/ai-skill-unikraft
├── agents/readability-improver.md    → guillempuche/ai-agent-readability-improver
└── agents/a11y-accessibility-reviewer.md → guillempuche/ai-agent-a11y-accessibility-reviewer
```

## Deployment Flow

### 1. Make Changes

Edit files in `skills/`, `agents/`, or `templates/`:

```bash
# Edit a skill
vim skills/powersync/SKILL.md

# Edit an agent
vim agents/readability-improver.md

# Add requirements for individual repo
vim templates/skills/powersync-REQUIREMENTS.md
```

### 2. Commit to ai-standards

Use the commit skill:

```bash
/commit
```

Or manually:

```bash
nix develop -c mdformat skills/ .claude/ agents/ templates/ *.md
git add -A
git commit -m "Your message"
git push
```

### 3. Regenerate Individual Repos

```bash
./scripts/generate-individual-repos.sh
```

This creates/updates `dist-repos/` with:

- Copies skill/agent files
- Generates plugin.json and marketplace.json
- Generates README.md
- Copies REQUIREMENTS.md from templates/ (if exists)
- Copies LICENSE and .gitignore

### 4. Push to Individual Repos

```bash
./scripts/deploy-individual-repos.sh
```

This:

- **New repos:** Creates GitHub repo, initial commit, adds topics
- **Existing repos:** Clones repo, copies changes, commits "Update from ai-standards", pushes
- **No changes:** Skips commit if files unchanged

History is preserved - each update creates a new commit, not a force push.

## Common Scenarios

### Add a New Skill

1. Create `skills/new-skill/SKILL.md`
1. Optionally add `templates/skills/new-skill-REQUIREMENTS.md`
1. Update `README.md` with skill info
1. Commit to ai-standards
1. Run both scripts

### Update Existing Skill

1. Edit `skills/skill-name/SKILL.md`
1. Commit to ai-standards
1. Run both scripts

### Add Requirements to Skill

1. Create `templates/skills/skill-name-REQUIREMENTS.md`
1. Commit to ai-standards
1. Run both scripts (REQUIREMENTS.md appears in individual repo only)

### Update Agent

1. Edit `agents/agent-name.md`
1. Commit to ai-standards
1. Run both scripts

## Quick Deploy (All Steps)

```bash
# 1. Format and commit
nix develop -c mdformat skills/ .claude/ agents/ templates/ *.md
git add -A && git commit -m "Your changes"
git push

# 2. Deploy to individual repos
./scripts/generate-individual-repos.sh
./scripts/deploy-individual-repos.sh
```

## Version Bumping

Update version in `.claude-plugin/plugin.json` and `CHANGELOG.md` for significant changes:

```json
{
  "version": "1.3.0"
}
```

Individual repos always use `1.0.0` (they track ai-standards releases).
