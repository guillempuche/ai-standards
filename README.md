# AI Standards

**Open-source AI coding skills for Claude Code, Cursor, Copilot, and AI agents**

Skills for TypeScript, React, React Native, local-first apps, offline sync, and modern web development.

## Quick Install

```bash
# Claude Code
/plugin marketplace add guillempuche/ai-standards

# Or use individual skills directly
claude --skill https://raw.githubusercontent.com/guillempuche/ai-standards/main/skills/powersync/SKILL.md
```

## Skills Catalog

### powersync

**Build local-first, offline-capable apps with real-time sync**

|            |                                                 |
| ---------- | ----------------------------------------------- |
| Platforms  | Web, React Native, Node.js, Capacitor, Electron |
| Frameworks | React, Vue, Angular                             |
| ORMs       | Kysely, Drizzle, TanStack DB                    |
| Backends   | Postgres, MongoDB, MySQL, SQL Server, Supabase  |

[View skill](./skills/powersync/) | [PowerSync docs](https://docs.powersync.com/)

______________________________________________________________________

### effect-lookup

**Quick lookup for Effect TypeScript library APIs and patterns**

|          |                                                       |
| -------- | ----------------------------------------------------- |
| Coverage | Core Effect, Platform, CLI, RPC, SQL, AI packages     |
| Features | Module reference, common patterns, source code lookup |
| Includes | MCP server integration for indexed docs               |

[View skill](./skills/effect-lookup/) | [Effect docs](https://effect.website/)

______________________________________________________________________

### unikraft

**Kraft CLI for building and deploying Unikraft unikernels**

|          |                                                    |
| -------- | -------------------------------------------------- |
| Commands | Build, deploy, manage instances, volumes, services |
| Platform | Unikraft Cloud (KraftCloud)                        |
| Features | Rolling updates, scale-to-zero, compose support    |

[View skill](./skills/unikraft/) | [Unikraft docs](https://unikraft.org/docs/cli)

______________________________________________________________________

## Compatibility

Skills follow the [Agent Skills specification](https://agentskills.io/specification) and work with:

| Agent           | Support                 |
| --------------- | ----------------------- |
| Claude Code     | Native plugin support   |
| Cursor          | Via SKILL.md loading    |
| VS Code Copilot | Via context files       |
| Windsurf        | Via context files       |
| Gemini CLI      | Via skill loading       |
| Custom agents   | Via agentskills.io spec |

## Creating Skills

1. Create folder under `skills/` with lowercase hyphenated name
1. Add `SKILL.md` with YAML frontmatter:

```yaml
---
name: your-skill
description: What it does and when to use it (max 1024 chars)
license: MIT
metadata:
  author: your-name
  version: "1.0"
---

# Your Skill

Instructions here...
```

1. Add `references/` folder for detailed docs (keeps SKILL.md under 500 lines)

See [AGENTS.md](./AGENTS.md) for full guidelines.

## Repository Structure

```
ai-standards/
├── .claude-plugin/
│   └── plugin.json      # Claude Code plugin manifest
├── skills/
│   └── <skill-name>/
│       ├── SKILL.md     # Main skill file
│       └── references/  # Detailed documentation
├── AGENTS.md            # AI agent instructions
└── README.md
```

## Standards

- [Agent Skills](https://agentskills.io/) - Portable skill format for AI coding agents
- [AGENTS.md](https://agents.md/) - Instructions for AI agents working on repositories

## Contributing

1. Fork this repository
1. Create your skill under `skills/` following the structure above
1. Validate: folder name matches `name` field, description under 1024 chars
1. Submit PR with title: `[skill-name] Brief description`

## License

MIT
