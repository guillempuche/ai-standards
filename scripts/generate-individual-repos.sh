#!/bin/bash
# Generate individual plugin repos from ai-standards bundle
# Each skill becomes ai-skill-<name>, each agent becomes ai-agent-<name>

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="${ROOT_DIR}/dist-repos"

AUTHOR="guillempuche"
AUTHOR_URL="https://github.com/guillempuche"

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

echo "Generating individual repos in $OUTPUT_DIR"

# Generate skill repos
for skill_dir in "$ROOT_DIR"/skills/*/; do
  [ -d "$skill_dir" ] || continue

  skill_name=$(basename "$skill_dir")
  repo_name="ai-skill-${skill_name}"
  repo_dir="$OUTPUT_DIR/$repo_name"

  echo "Creating $repo_name..."

  # Create structure
  mkdir -p "$repo_dir/.claude-plugin"
  mkdir -p "$repo_dir/skills"

  # Copy skill
  cp -r "$skill_dir" "$repo_dir/skills/"

  # Copy LICENSE
  cp "$ROOT_DIR/LICENSE" "$repo_dir/"

  # Create .gitignore
  cat > "$repo_dir/.gitignore" << 'GITIGNORE'
.DS_Store
*.log
node_modules/
GITIGNORE

  # Extract description from SKILL.md frontmatter
  description=$(sed -n '/^---$/,/^---$/p' "$skill_dir/SKILL.md" | grep '^description:' | sed 's/^description: *//' | head -1)
  [ -z "$description" ] && description="AI skill for $skill_name"

  # Generate plugin.json
  cat > "$repo_dir/.claude-plugin/plugin.json" << EOF
{
  "name": "$repo_name",
  "version": "1.0.0",
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

  # Generate README
  cat > "$repo_dir/README.md" << EOF
# $repo_name

$description

## Install

\`\`\`bash
/plugin marketplace add $AUTHOR/$repo_name
\`\`\`

## Part of AI Standards

This skill is also available in the [ai-standards](https://github.com/$AUTHOR/ai-standards) bundle with other skills and agents.

## License

MIT
EOF

  echo "  ✓ $repo_name"
done

# Generate agent repos
for agent_file in "$ROOT_DIR"/agents/*.md; do
  [ -f "$agent_file" ] || continue

  agent_name=$(basename "$agent_file" .md)
  repo_name="ai-agent-${agent_name}"
  repo_dir="$OUTPUT_DIR/$repo_name"

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

  # Extract description from agent frontmatter
  description=$(sed -n '/^---$/,/^---$/p' "$agent_file" | grep '^description:' | sed 's/^description: *//' | head -1)
  [ -z "$description" ] && description="AI agent for $agent_name"

  # Truncate description if too long (for JSON)
  description=$(echo "$description" | cut -c1-200)

  # Generate plugin.json
  cat > "$repo_dir/.claude-plugin/plugin.json" << EOF
{
  "name": "$repo_name",
  "version": "1.0.0",
  "description": "$description",
  "author": {
    "name": "$AUTHOR",
    "url": "$AUTHOR_URL"
  },
  "homepage": "https://github.com/$AUTHOR/$repo_name",
  "repository": "https://github.com/$AUTHOR/$repo_name",
  "license": "MIT",
  "agents": "./agents/"
}
EOF

  # Generate README
  cat > "$repo_dir/README.md" << EOF
# $repo_name

$description

## Install

\`\`\`bash
/plugin marketplace add $AUTHOR/$repo_name
\`\`\`

## Part of AI Standards

This agent is also available in the [ai-standards](https://github.com/$AUTHOR/ai-standards) bundle with other skills and agents.

## License

MIT
EOF

  echo "  ✓ $repo_name"
done

echo ""
echo "Done! Generated repos:"
ls -1 "$OUTPUT_DIR"
echo ""
echo "Next steps:"
echo "1. Review repos in $OUTPUT_DIR"
echo "2. Create GitHub repos for each"
echo "3. Push each directory to its repo"
