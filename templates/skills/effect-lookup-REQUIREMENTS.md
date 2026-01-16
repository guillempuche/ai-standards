# Requirements

This skill works best with the **Effect Docs MCP server** for indexed documentation search.

## Setup MCP Server (Recommended)

1. Add to your Claude Code MCP settings (`~/.claude/settings.json`):

```json
{
  "mcpServers": {
    "effect-docs": {
      "command": "npx",
      "args": ["-y", "@effect/mcp-docs-server"]
    }
  }
}
```

2. Restart Claude Code

## Without MCP Server

The skill still works using grep/search on the local Effect source code, but MCP provides faster and more accurate lookups.

## Verify Setup

Ask Claude: "Search effect docs for Stream.map"

If MCP is configured, you'll see results from `mcp__effect-docs__effect_docs_search`.
