#!/bin/bash
# Generate the non-Claude manifests from the Claude ones, so each agent's catalog lists the same skills.
#   plugin.json                       <- .claude-plugin/plugin.json      (portable manifest: Codex, Antigravity)
#   .agents/plugins/marketplace.json  <- .claude-plugin/marketplace.json (Codex marketplace)
# Agents are left out of the Codex marketplace: they only load in Claude Code.
# Usage: sync-manifests.sh          # write the files
#        sync-manifests.sh --check  # exit 1 if they are out of date

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

python3 - "$ROOT_DIR" "${1:-}" << 'PYEOF'
import json, os, sys

root, mode = sys.argv[1], sys.argv[2]
claude_plugin = json.load(open(os.path.join(root, ".claude-plugin/plugin.json")))
claude_market = json.load(open(os.path.join(root, ".claude-plugin/marketplace.json")))

# Codex prefers this file over .claude-plugin/plugin.json and defaults to 1.0.0 without a version, so copy it.
portable = {
    "$schema": "https://agent-plugins.org/schemas/1.0.0/plugin.schema.json",
    "name": claude_plugin["name"],
    "version": claude_plugin["version"],
    "description": claude_plugin["description"],
}
for key in ("author", "homepage", "repository", "license", "keywords"):
    if key in claude_plugin:
        portable[key] = claude_plugin[key]

policy = {"installation": "AVAILABLE", "authentication": "ON_INSTALL"}
plugins = []
for entry in claude_market["plugins"]:
    source = entry["source"]
    if source == "./":
        codex_source = {"source": "local", "path": "./"}
    elif source.get("source") == "github" and source["repo"].split("/")[1].startswith("ai-skill-"):
        codex_source = {"source": "url", "url": f"https://github.com/{source['repo']}.git"}
    else:
        continue
    plugins.append({
        "name": entry["name"],
        "description": entry["description"],
        "source": codex_source,
        "policy": policy,
        "category": "Productivity",
    })
codex_market = {
    "name": claude_market["name"],
    "interface": {"displayName": "AI Standards"},
    "plugins": plugins,
}

outputs = {
    "plugin.json": portable,
    ".agents/plugins/marketplace.json": codex_market,
}
stale = []
for rel, data in outputs.items():
    path = os.path.join(root, rel)
    text = json.dumps(data, indent=2, ensure_ascii=False) + "\n"
    current = open(path).read() if os.path.exists(path) else None
    if current == text:
        continue
    if mode == "--check":
        stale.append(rel)
    else:
        os.makedirs(os.path.dirname(path), exist_ok=True)
        open(path, "w").write(text)
        print(f"  ✓ wrote {rel}")

if stale:
    print("Out of date, run scripts/sync-manifests.sh: " + ", ".join(stale), file=sys.stderr)
    sys.exit(1)
PYEOF
