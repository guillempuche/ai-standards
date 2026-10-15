---
name: release
description: Detect changes in skills/agents, ask about version bumps, update frontmatter versions, and deploy individual repos to GitHub.
metadata:
  internal: true
---

# Release Workflow

Detect changes, bump versions, and deploy individual plugin repos.
`metadata.internal: true` (a YAML boolean, which the `skills` CLI requires, so not a quoted string) hides this repo-only skill from `npx skills add`; Claude Code ignores the key.

## Step 1: Identify changed repos

With arguments, map them to repo names.
The user may pass source paths (`agents/readability-improver.md`, `skills/tamagui`) or repo names (`ai-agent-readability-improver`):

- `agents/<name>.md` → `ai-agent-<name>`
- `skills/<name>` → `ai-skill-<name>`

Without arguments, release everything that changed: take every skill and agent.

Generate and compare in one `bash` call, so word splitting works even when the user's shell is zsh:

```bash
bash -c '
REPOS="${*:-$(for d in skills/*/; do echo "ai-skill-$(basename "$d")"; done) $(for a in agents/*.md; do echo "ai-agent-$(basename "$a" .md)"; done)}"
./scripts/generate-individual-repos.sh $REPOS > /dev/null
for repo_name in $REPOS; do
  cache_dir=".repo-cache/$repo_name"
  repo_dir="dist-repos/$repo_name"
  if [ ! -d "$cache_dir" ]; then
    echo "NEW: $repo_name"
  elif changes=$(diff -rq --exclude=.git "$cache_dir" "$repo_dir"); then
    :
  else
    echo "CHANGED: $repo_name"
    echo "$changes"
  fi
done
' _ <repo-names...>
```

Drop `<repo-names...>` to release everything.
The generator also runs `scripts/sync-manifests.sh`, so if `git status` now shows `plugin.json` or `.agents/plugins/marketplace.json` modified, the Claude manifests had drifted: include them in the release commit.

If no repos have changes, tell the user "Nothing to release" and stop.

## Step 2: Classify each change

For each changed repo, show what changed (files added, modified, removed), and classify it:

- **Content**: the skill's `SKILL.md`, `references/`, `scripts/` or `assets/`, or the agent's `.md` file changed.
- **Packaging only**: only generated files changed (`README.md`, `plugin.json`, `.claude-plugin/`, `.agents/plugins/`), because the generator or the manifests changed.

Check content changes against the source, not only the dist diff: `git diff <last-release-commit> -- skills/<name>` or `agents/<name>.md`, where the last release commit is the newest "Bump versions for release".

## Step 3: Ask about version bumps

Ask about all repos in one question per repo (`AskUserQuestion` in Claude Code):

- **Packaging only**: default to **no bump**; the installed skill is identical, so users have nothing to update.
- **Content**: offer **patch** (fixes, small content updates), **minor** (new content or features), or **major** (breaking changes or rewrites).

Also ask whether to bump the bundle in `.claude-plugin/plugin.json` (patch, minor, major, or skip).
Suggest minor when the release adds a feature or install target, patch for fixes, skip when only per-skill repos changed.

## Step 4: Update source versions

For each repo that gets a bump, edit the `version:` line in the source frontmatter:

- Skills (`skills/<name>/SKILL.md`): under `metadata:`, as `  version: 1.0.0`, always three-part semver so YAML keeps it a string.
  The Agent Skills spec allows no top-level `version` key, and adding one breaks claude.ai upload and `package_skill.py` packaging.
- Agents (`agents/<name>.md`): top-level `version: 1.0.0`, since agent frontmatter follows the Claude Code subagent reference and never passes through that validator.

For the bundle, edit `"version"` in `.claude-plugin/plugin.json`, then run `./scripts/sync-manifests.sh`.
Codex reads the version from the root `plugin.json` first and reports `1.0.0` without one, so it must match.

Compute the new version from the current `X.Y.Z`:

- patch: increment Z
- minor: increment Y, reset Z to 0
- major: increment X, reset Y and Z to 0

## Step 5: Update the changelog

When the bundle is bumped, rename `## [Unreleased]` in `CHANGELOG.md` to `## [X.Y.Z] - YYYY-MM-DD`.
If there is no Unreleased section, draft one from the commits since the last release commit and show it to the user before writing it.

## Step 6: Regenerate and validate

Regenerate the changed repos so they pick up the new versions, then check the main repo:

```bash
bash -c './scripts/generate-individual-repos.sh "$@"' _ <changed-repo-names...>
./scripts/sync-manifests.sh --check
claude plugin validate . --strict
```

Stop and fix any failure before committing.

## Step 7: Commit

Stage every file a release can change, not just the sources:

```bash
git add skills/ agents/ .claude-plugin/plugin.json plugin.json .agents/plugins/marketplace.json CHANGELOG.md
git commit -m "Bump versions for release

Co-Authored-By: Claude <noreply@anthropic.com>"
```

Skip the commit when nothing was bumped and the manifests didn't drift, as in a packaging-only release.
Run `git status --short` afterwards; it must be empty.

## Step 8: Deploy

Deploy only the changed repos:

```bash
bash -c './scripts/deploy-individual-repos.sh "$@"' _ <changed-repo-names...>
```

## Step 9: Push main repo

```bash
git push origin main
```

## Step 10: Verify

When the bundle was bumped, confirm Codex sees the new version, using a throwaway `CODEX_HOME` so the user's own config stays untouched:

```bash
export CODEX_HOME="$(mktemp -d)"
codex plugin marketplace add guillempuche/ai-standards
codex plugin add ai-standards@ai-standards   # the install path ends in /<new version>
```

Skip this if `codex` isn't installed, and say so.

Show the user a summary: each released repo with its old and new version (or "no bump"), the bundle version, and the verification result.
