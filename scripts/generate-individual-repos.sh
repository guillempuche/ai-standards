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

  # Copy REQUIREMENTS.md from templates/ if exists
  requirements_file="$ROOT_DIR/templates/skills/${skill_name}-REQUIREMENTS.md"
  if [ -f "$requirements_file" ]; then
    cp "$requirements_file" "$repo_dir/REQUIREMENTS.md"
    has_requirements=true
  else
    has_requirements=false
  fi

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

  # Generate marketplace.json (makes repo installable via /plugin marketplace add)
  cat > "$repo_dir/.claude-plugin/marketplace.json" << EOF
{
  "name": "$repo_name",
  "owner": {
    "name": "$AUTHOR",
    "url": "$AUTHOR_URL"
  },
  "plugins": [
    {
      "name": "$repo_name",
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
# Add marketplace
/plugin marketplace add $AUTHOR/$repo_name

# Install plugin
/plugin install $repo_name@$AUTHOR-$repo_name
\`\`\`
$requirements_section
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

  # Generate plugin.json (agents field requires explicit file paths, not directory)
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
  "agents": ["./agents/${agent_name}.md"]
}
EOF

  # Generate marketplace.json (makes repo installable via /plugin marketplace add)
  cat > "$repo_dir/.claude-plugin/marketplace.json" << EOF
{
  "name": "$repo_name",
  "owner": {
    "name": "$AUTHOR",
    "url": "$AUTHOR_URL"
  },
  "plugins": [
    {
      "name": "$repo_name",
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
# Add marketplace
/plugin marketplace add $AUTHOR/$repo_name

# Install plugin
/plugin install $repo_name@$AUTHOR-$repo_name
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
