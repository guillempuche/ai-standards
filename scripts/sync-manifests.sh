#!/bin/bash
# Generate the non-Claude manifests from the Claude ones, so each agent's catalog lists the same skills.
#   plugin.json                       <- .claude-plugin/plugin.json      (portable manifest: Codex, Antigravity)
#   .agents/plugins/marketplace.json  <- .claude-plugin/marketplace.json (Codex marketplace)
# Agents (ai-agent-* repos) are left out of the Codex marketplace: they only load in Claude Code.
# Usage: sync-manifests.sh [--check] [plugin-dir]
#   plugin-dir defaults to the repo root; generate-individual-repos.sh passes each dist repo.
#   --check exits 1 if the files are out of date instead of writing them.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

MODE=write
TARGET_DIR="$ROOT_DIR"
for arg in "$@"; do
  case "$arg" in
    --check) MODE=check ;;
    -*) echo "Unknown option: $arg" >&2; echo "Usage: $0 [--check] [plugin-dir]" >&2; exit 2 ;;
    *) TARGET_DIR="$arg" ;;
  esac
done

if ! command -v python3 > /dev/null; then
  echo "sync-manifests.sh needs python3 (run inside 'nix develop')" >&2
  exit 1
fi

python3 - "$TARGET_DIR" "$MODE" << 'PYEOF'
import json, os, sys

root, mode = sys.argv[1], sys.argv[2]

def load(rel):
    with open(os.path.join(root, rel), encoding="utf-8") as f:
        return json.load(f)

claude_plugin = load(".claude-plugin/plugin.json")
claude_market = load(".claude-plugin/marketplace.json")

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

def codex_source(entry):
    """Map a Claude marketplace source to a Codex one; None for agents, which Codex can't load."""
    source = entry["source"]
    if isinstance(source, str):
        return {"source": "local", "path": source}
    kind = source.get("source")
    if kind == "github":
        repo = source["repo"]
        if repo.split("/")[-1].startswith("ai-agent-"):
            return None
        mapped = {"source": "url", "url": f"https://github.com/{repo}.git"}
    elif kind in ("url", "git-subdir", "npm"):
        mapped = dict(source)
    else:
        sys.exit(f"Plugin '{entry['name']}': no Codex mapping for source {json.dumps(source)}; extend codex_source() in scripts/sync-manifests.sh")
    if "ref" in source:
        mapped["ref"] = source["ref"]
    return mapped

policy = {"installation": "AVAILABLE", "authentication": "ON_INSTALL"}
plugins = []
for entry in claude_market["plugins"]:
    mapped = codex_source(entry)
    if mapped is None:
        continue
    plugins.append({
        "name": entry["name"],
        "description": entry["description"],
        "source": mapped,
        "policy": policy,
        "category": "Productivity",
    })
codex_market = {
    "name": claude_market["name"],
    "interface": {"displayName": "AI Standards" if claude_market["name"] == "ai-standards" else claude_market["name"]},
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
    current = None
    if os.path.exists(path):
        with open(path, encoding="utf-8") as f:
            current = f.read()
    if current == text:
        continue
    if mode == "check":
        stale.append(rel)
    else:
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w", encoding="utf-8") as f:
            f.write(text)
        print(f"  ✓ wrote {rel}")

if stale:
    print("Out of date, run scripts/sync-manifests.sh: " + ", ".join(stale), file=sys.stderr)
    sys.exit(1)
PYEOF
