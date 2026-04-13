#!/bin/bash
# Generate individual plugin repos from ai-standards bundle
# Usage: generate-individual-repos.sh <repo-name> [repo-name...]
# Example: generate-individual-repos.sh ai-agent-readability-improver ai-skill-tamagui

set -e

if [ $# -eq 0 ]; then
  echo "Usage: $0 <repo-name> [repo-name...]"
  echo "Example: $0 ai-agent-readability-improver ai-skill-tamagui"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="${ROOT_DIR}/dist-repos"

AUTHOR="guillempuche"
AUTHOR_URL="https://github.com/guillempuche"

mkdir -p "$OUTPUT_DIR"

TARGETS=("$@")
GENERATED=()

echo "Generating repos in $OUTPUT_DIR"

# Generate skill repos
for skill_dir in "$ROOT_DIR"/skills/*/; do
  [ -d "$skill_dir" ] || continue

  skill_name=$(basename "$skill_dir")
  repo_name="ai-skill-${skill_name}"

  # Skip if not in targets
  [[ " ${TARGETS[*]} " == *" $repo_name "* ]] || continue

  repo_dir="$OUTPUT_DIR/$repo_name"
  rm -rf "$repo_dir"

  echo "Creating $repo_name..."

  # Create structure
  mkdir -p "$repo_dir/.claude-plugin"
  mkdir -p "$repo_dir/skills"

  # Copy skill (strip trailing slash so cp preserves the skill_name subfolder on BSD/macOS)
  cp -r "${skill_dir%/}" "$repo_dir/skills/"

  # Copy LICENSE
  cp "$ROOT_DIR/LICENSE" "$repo_dir/"

  # Create .gitignore
  cat > "$repo_dir/.gitignore" << 'GITIGNORE'
.DS_Store
*.log
node_modules/
GITIGNORE

  # Copy REQUIREMENTS.md from templates/ if exists
  requirements_file="$ROOT_DIR/templates/skills/${skill_name}-REQUIREMENTS.md"
  if [ -f "$requirements_file" ]; then
    cp "$requirements_file" "$repo_dir/REQUIREMENTS.md"
    has_requirements=true
  else
    has_requirements=false
  fi

  # Extract description and version from SKILL.md frontmatter
  description=$(sed -n '/^---$/,/^---$/p' "$skill_dir/SKILL.md" | grep '^description:' | sed 's/^description: *//' | head -1)
  [ -z "$description" ] && description="AI skill for $skill_name"
  version=$(sed -n '/^---$/,/^---$/p' "$skill_dir/SKILL.md" | grep '^version:' | sed 's/^version: *//' | head -1)
  [ -z "$version" ] && version="1.0.0"

  # Truncate description if too long (for JSON)
  description=$(echo "$description" | cut -c1-200)

  # Generate plugin.json (plugin name is topic-only; repo slug stays ai-skill-*)
  cat > "$repo_dir/.claude-plugin/plugin.json" << EOF
{
  "name": "$skill_name",
  "version": "$version",
  "description": "$description",
  "author": {
    "name": "$AUTHOR",
    "url": "$AUTHOR_URL"
  },
  "homepage": "https://github.com/$AUTHOR/$repo_name",
  "repository": "https://github.com/$AUTHOR/$repo_name",
  "license": "MIT",
  "skills": "./skills/"
}
EOF

  # Generate marketplace.json (outer name = marketplace ID mirrors repo slug; inner plugin name = topic)
  cat > "$repo_dir/.claude-plugin/marketplace.json" << EOF
{
  "name": "$repo_name",
  "owner": {
    "name": "$AUTHOR",
    "url": "$AUTHOR_URL"
  },
  "plugins": [
    {
      "name": "$skill_name",
      "source": "./"
    }
  ]
}
EOF

  # Generate README
  if [ "$has_requirements" = true ]; then
    requirements_section="
## Requirements

See [REQUIREMENTS.md](./REQUIREMENTS.md) for setup instructions.
"
  else
    requirements_section=""
  fi

  cat > "$repo_dir/README.md" << EOF
# $repo_name

$description

## Install

\`\`\`bash
# Add marketplace (uses repo slug)
/plugin marketplace add $AUTHOR/$repo_name

# Install plugin (plugin name is topic-only)
/plugin install $skill_name@$AUTHOR-$repo_name
\`\`\`
$requirements_section
## Part of AI Standards

This skill is also available in the [ai-standards](https://github.com/$AUTHOR/ai-standards) bundle with other skills and agents.

## License

MIT
EOF

  GENERATED+=("$repo_name")
  echo "  ✓ $repo_name"
done

# Generate agent repos
for agent_file in "$ROOT_DIR"/agents/*.md; do
  [ -f "$agent_file" ] || continue

  agent_name=$(basename "$agent_file" .md)
  repo_name="ai-agent-${agent_name}"

  # Skip if not in targets
  [[ " ${TARGETS[*]} " == *" $repo_name "* ]] || continue

  repo_dir="$OUTPUT_DIR/$repo_name"
  rm -rf "$repo_dir"

  echo "Creating $repo_name..."

  # Create structure
  mkdir -p "$repo_dir/.claude-plugin"
  mkdir -p "$repo_dir/agents"

  # Copy agent
  cp "$agent_file" "$repo_dir/agents/"

  # Copy LICENSE
  cp "$ROOT_DIR/LICENSE" "$repo_dir/"

  # Create .gitignore
  cat > "$repo_dir/.gitignore" << 'GITIGNORE'
.DS_Store
*.log
node_modules/
GITIGNORE

  # Extract description and version from agent frontmatter
  description=$(sed -n '/^---$/,/^---$/p' "$agent_file" | grep '^description:' | sed 's/^description: *//' | head -1)
  [ -z "$description" ] && description="AI agent for $agent_name"
  version=$(sed -n '/^---$/,/^---$/p' "$agent_file" | grep '^version:' | sed 's/^version: *//' | head -1)
  [ -z "$version" ] && version="1.0.0"

  # Truncate description if too long (for JSON)
  description=$(echo "$description" | cut -c1-200)

  # Generate plugin.json (plugin name is topic-only; agents field requires explicit file paths)
  cat > "$repo_dir/.claude-plugin/plugin.json" << EOF
{
  "name": "$agent_name",
  "version": "$version",
  "description": "$description",
  "author": {
    "name": "$AUTHOR",
    "url": "$AUTHOR_URL"
  },
  "homepage": "https://github.com/$AUTHOR/$repo_name",
  "repository": "https://github.com/$AUTHOR/$repo_name",
  "license": "MIT",
  "agents": ["./agents/${agent_name}.md"]
}
EOF

  # Generate marketplace.json (outer name = marketplace ID mirrors repo slug; inner plugin name = topic)
  cat > "$repo_dir/.claude-plugin/marketplace.json" << EOF
{
  "name": "$repo_name",
  "owner": {
    "name": "$AUTHOR",
    "url": "$AUTHOR_URL"
  },
  "plugins": [
    {
      "name": "$agent_name",
      "source": "./"
    }
  ]
}
EOF

  # Generate README
  cat > "$repo_dir/README.md" << EOF
# $repo_name

$description

## Install

\`\`\`bash
# Add marketplace (uses repo slug)
/plugin marketplace add $AUTHOR/$repo_name

# Install plugin (plugin name is topic-only)
/plugin install $agent_name@$AUTHOR-$repo_name
\`\`\`

## Part of AI Standards

This agent is also available in the [ai-standards](https://github.com/$AUTHOR/ai-standards) bundle with other skills and agents.

## License

MIT
EOF

  GENERATED+=("$repo_name")
  echo "  ✓ $repo_name"
done

# Warn about targets that didn't match any source
for target in "${TARGETS[@]}"; do
  if [[ ! " ${GENERATED[*]} " == *" $target "* ]]; then
    echo "ERROR: '$target' did not match any skill or agent source"
    exit 1
  fi
done

echo ""
echo "Done!"
