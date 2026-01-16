#!/bin/bash
# Create GitHub repos for all individual plugins in dist-repos/
# Run after generate-individual-repos.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
DIST_DIR="${ROOT_DIR}/dist-repos"

AUTHOR="guillempuche"

# Topics for each repo type
SKILL_TOPICS="ai-skills claude-code cursor copilot ai-agents"
AGENT_TOPICS="ai-agents claude-code cursor copilot ai-skills"

if [ ! -d "$DIST_DIR" ]; then
  echo "Error: dist-repos/ not found. Run generate-individual-repos.sh first."
  exit 1
fi

echo "Creating GitHub repos from $DIST_DIR"
echo ""

for repo_dir in "$DIST_DIR"/*/; do
  [ -d "$repo_dir" ] || continue

  repo_name=$(basename "$repo_dir")

  echo "=== $repo_name ==="

  # Determine topics based on repo type
  if [[ "$repo_name" == ai-skill-* ]]; then
    skill_name="${repo_name#ai-skill-}"
    topics="$SKILL_TOPICS $skill_name"
  else
    agent_name="${repo_name#ai-agent-}"
    topics="$AGENT_TOPICS $agent_name"
  fi

  # Check if repo already exists
  if gh repo view "$AUTHOR/$repo_name" &>/dev/null; then
    echo "  Repo already exists, updating..."
  else
    echo "  Creating repo..."
    gh repo create "$AUTHOR/$repo_name" --public --description "$(cat "$repo_dir/.claude-plugin/plugin.json" | grep '"description"' | sed 's/.*: "\(.*\)",/\1/' | cut -c1-200)"
  fi

  # Initialize git if needed
  cd "$repo_dir"
  if [ ! -d .git ]; then
    git init
    git add -A
    git commit --author="Guillem Puche <>" -m "Initial commit"
  fi

  # Set remote and push
  git remote remove origin 2>/dev/null || true
  git remote add origin "https://github.com/$AUTHOR/$repo_name.git"
  git branch -M main
  git push -u origin main --force

  # Add topics
  echo "  Adding topics: $topics"
  for topic in $topics; do
    gh repo edit "$AUTHOR/$repo_name" --add-topic "$topic" 2>/dev/null || true
  done

  echo "  ✓ https://github.com/$AUTHOR/$repo_name"
  echo ""

  cd "$ROOT_DIR"
done

echo "Done! All repos created."
echo ""
echo "Install commands:"
for repo_dir in "$DIST_DIR"/*/; do
  repo_name=$(basename "$repo_dir")
  echo "  /plugin marketplace add $AUTHOR/$repo_name"
done
