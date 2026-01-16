---
name: commit
description: Commit workflow for ai-standards repo. Formats all markdown files and previews changes before committing.
---

# Commit Workflow

Standard commit workflow for the ai-standards repository.

## Before Every Commit

### 1. Run Markdown Formatter

Format project markdown files using mdformat (excludes opensrc/ which contains external source):

```bash
nix develop -c mdformat skills/ .claude/ *.md
```

This formats all `.md` files with:

- YAML frontmatter preservation
- GitHub Flavored Markdown support

### 2. Preview Changes

Always show the user what will be committed:

```bash
git status
git diff --staged
git diff
```

### 3. Stage and Commit

After user reviews and approves:

```bash
git add -A
git commit -m "Commit message"
```

## Commit Message Guidelines

- Use lowercase, imperative mood
- Reference skill names in brackets when applicable: `[powersync] add sync pattern docs`

## Workflow Summary

1. Run `nix develop -c mdformat skills/ .claude/ *.md`
1. Show `git status` and `git diff`
1. Wait for user approval
1. Stage and commit changes
