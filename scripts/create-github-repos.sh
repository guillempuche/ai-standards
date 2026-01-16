#!/bin/bash
# Create/update GitHub repos for all individual plugins in dist-repos/
# Run after generate-individual-repos.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
DIST_DIR="${ROOT_DIR}/dist-repos"
TEMP_DIR="${ROOT_DIR}/.repo-cache"

AUTHOR="guillempuche"

# Topics for each repo type
SKILL_TOPICS="ai-skills claude-code cursor copilot ai-agents"
AGENT_TOPICS="ai-agents claude-code cursor copilot ai-skills"

if [ ! -d "$DIST_DIR" ]; then
  echo "Error: dist-repos/ not found. Run generate-individual-repos.sh first."
  exit 1
fi

mkdir -p "$TEMP_DIR"

echo "Updating GitHub repos from $DIST_DIR"
echo ""

for repo_dir in "$DIST_DIR"/*/; do
  [ -d "$repo_dir" ] || continue

  repo_name=$(basename "$repo_dir")
  cache_dir="$TEMP_DIR/$repo_name"

  echo "=== $repo_name ==="

  # Determine topics based on repo type
  if [[ "$repo_name" == ai-skill-* ]]; then
    skill_name="${repo_name#ai-skill-}"
    topics="$SKILL_TOPICS $skill_name"
  else
    agent_name="${repo_name#ai-agent-}"
    topics="$AGENT_TOPICS $agent_name"
  fi

  # Check if repo exists on GitHub
  if gh repo view "$AUTHOR/$repo_name" &>/dev/null; then
    echo "  Repo exists, cloning..."

    # Clone or pull existing repo to cache
    if [ -d "$cache_dir/.git" ]; then
      cd "$cache_dir"
      git pull origin main --rebase 2>/dev/null || true
      cd "$ROOT_DIR"
    else
      rm -rf "$cache_dir"
      gh repo clone "$AUTHOR/$repo_name" "$cache_dir"
    fi

    # Copy new files (excluding .git)
    rsync -a --exclude='.git' --delete "$repo_dir/" "$cache_dir/"

    cd "$cache_dir"

    # Check if there are changes
    if git diff --quiet && git diff --staged --quiet && [ -z "$(git status --porcelain)" ]; then
      echo "  No changes"
    else
      git add -A
      git commit --author="Guillem Puche <>" -m "Update from ai-standards

Co-Authored-By: Claude <noreply@anthropic.com>"
      git push origin main
      echo "  ✓ Updated"
    fi
  else
    echo "  Creating new repo..."
    gh repo create "$AUTHOR/$repo_name" --public --description "$(cat "$repo_dir/.claude-plugin/plugin.json" | grep '"description"' | sed 's/.*: "\(.*\)",/\1/' | cut -c1-200)"

    # Initialize and push
    rm -rf "$cache_dir"
    cp -r "$repo_dir" "$cache_dir"
    cd "$cache_dir"
    git init
    git add -A
    git commit --author="Guillem Puche <>" -m "Initial commit

Co-Authored-By: Claude <noreply@anthropic.com>"
    git remote add origin "https://github.com/$AUTHOR/$repo_name.git"
    git branch -M main
    git push -u origin main
    echo "  ✓ Created"
  fi

  # Add/update topics (for both new and existing repos)
  for topic in $topics; do
    gh repo edit "$AUTHOR/$repo_name" --add-topic "$topic" 2>/dev/null || true
  done

  echo "  https://github.com/$AUTHOR/$repo_name"
  echo ""

  cd "$ROOT_DIR"
done

echo "Done!"
echo ""
echo "Install commands:"
for repo_dir in "$DIST_DIR"/*/; do
  repo_name=$(basename "$repo_dir")
  echo "  /plugin marketplace add $AUTHOR/$repo_name"
done
