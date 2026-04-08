# AI Standards

**Open-source AI coding skills for Claude Code, Cursor, Copilot, and AI agents**

Skills for TypeScript, React, React Native, local-first apps, offline sync, and modern web development.

## Quick Install

```bash
# Full bundle (all skills + agents)
/plugin marketplace add guillempuche/ai-standards

# Or install individually
/plugin marketplace add guillempuche/ai-skill-powersync
/plugin marketplace add guillempuche/ai-skill-effect-lookup
/plugin marketplace add guillempuche/ai-skill-unikraft
/plugin marketplace add guillempuche/ai-agent-readability-improver
/plugin marketplace add guillempuche/ai-agent-a11y-accessibility-reviewer
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

### tamagui

**Universal React + React Native UI with optimizing compiler**

|            |                                                  |
| ---------- | ------------------------------------------------ |
| Platforms  | Web, React Native, iOS, Android                  |
| Frameworks | Next.js, Expo, Vite, Metro                       |
| Features   | Design tokens, themes, 50+ accessible components |
| Compiler   | Build-time style extraction for performance      |

[View skill](./skills/tamagui/) | [Tamagui docs](https://tamagui.dev/)

______________________________________________________________________

## Agents Catalog

### readability-improver

**Improve code readability through renaming, comments, and whitespace**

|         |                                                             |
| ------- | ----------------------------------------------------------- |
| Focus   | Selective improvements - skips self-documenting code        |
| Actions | Rename variables, add whitespace, document "why" not "what" |
| Safety  | Never changes functionality, updates all imports            |

[View agent](./agents/readability-improver.md)

______________________________________________________________________

### a11y-accessibility-reviewer

**Review code for accessibility compliance (WCAG, VoiceOver, TalkBack)**

|           |                                                       |
| --------- | ----------------------------------------------------- |
| Platforms | React, React Native, Web                              |
| Standards | WCAG 2.1/2.2, WAI-ARIA, iOS/Android a11y APIs         |
| Coverage  | Visual, motor, auditory, cognitive, vestibular issues |

[View agent](./agents/a11y-accessibility-reviewer.md)

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

## Naming Conventions

Plugin names and GitHub repo slugs follow different conventions on purpose:

| Surface                                                       | Convention                  | Example                                                                         |
| ------------------------------------------------------------- | --------------------------- | ------------------------------------------------------------------------------- |
| Marketplace plugin name (`/plugin` UI, `/plugin install`)     | topic only, kebab-case      | `powersync`, `test-bdd`, `readability-improver`                                 |
| GitHub repo slug (`/plugin marketplace add guillempuche/…`)   | `ai-{skill\|agent}-{topic}` | `guillempuche/ai-skill-powersync`, `guillempuche/ai-agent-readability-improver` |
| Mixed-type escape hatch (repo bundles both skills and agents) | `ai-plugin-{topic}`         | `guillempuche/ai-plugin-toolbox`                                                |

**Why the split:** repo slugs are user-typed during `marketplace add` (one-time, and `guillempuche/powersync` would look like a library fork). Plugin names live inside the `/plugin` UI where users already know they're browsing Claude plugins, so a prefix would be noise.

**Install command shape** combines both:

```bash
/plugin install powersync@guillempuche-ai-skill-powersync
#              └─plugin──┘ └────── marketplace ──────┘
```

## Repository Structure

```
ai-standards/
├── .claude-plugin/
│   └── plugin.json          # Claude Code plugin manifest
├── skills/
│   └── <skill-name>/
│       ├── SKILL.md         # Main skill file
│       └── references/      # Detailed documentation
├── agents/
│   └── <agent-name>.md      # Agent with YAML frontmatter
├── templates/
│   ├── skills/              # Extra files for skill repos (REQUIREMENTS.md)
│   └── agents/              # Extra files for agent repos
├── scripts/
│   ├── generate-individual-repos.sh  # Generate dist-repos/
│   └── create-github-repos.sh        # Push to GitHub
├── AGENTS.md                # AI agent instructions
└── README.md
```

## Individual Repos

Skills and agents are also published as individual repos for standalone installation:

```bash
# Add the marketplace (one-time, uses repo slug)
/plugin marketplace add guillempuche/ai-skill-powersync
/plugin marketplace add guillempuche/ai-agent-readability-improver

# Install the plugin (plugin name is topic-only, marketplace suffix is repo-slug form)
/plugin install powersync@guillempuche-ai-skill-powersync
/plugin install readability-improver@guillempuche-ai-agent-readability-improver
```

Generate individual repos with:

```bash
./scripts/generate-individual-repos.sh  # Creates dist-repos/
./scripts/create-github-repos.sh        # Pushes to GitHub
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
