---
name: effect-lookup
description: Find Effect TypeScript signatures, source, and idioms from the local Effect checkout and docs. Use when you need to confirm an Effect API's signature, behavior, or deprecation, or find how an Effect pattern is done idiomatically.
license: MIT
metadata:
  version: 1.0.2
---

# Effect Library Lookup

Quick reference for finding and understanding Effect TypeScript library APIs from local source code.

## Source Code Access

Source code is available locally and on GitHub. Check local first, fall back to GitHub if not available.

| Repo           | Local path                                            | GitHub                                       |
| -------------- | ----------------------------------------------------- | -------------------------------------------- |
| Effect         | `opensrc/repos/github.com/effect-ts/effect/`          | https://github.com/effect-ts/effect          |
| EffectPatterns | `opensrc/repos/github.com/PaulJPhilp/EffectPatterns/` | https://github.com/PaulJPhilp/EffectPatterns |

## When to Use This Skill

Use this skill when:

- Looking up Effect function signatures or implementations
- Finding examples of Effect patterns (Effect.gen, Layer, Context, etc.)
- Understanding how Effect modules work internally
- Checking API availability or deprecation status
- Learning Effect idioms from source code

## How to Look Up Effect APIs

### 1. Use the Effect Docs MCP Server, if available

If the `effect-docs` MCP server is connected, `mcp__effect-docs__effect_docs_search` (search concepts) and `mcp__effect-docs__get_effect_doc` (fetch a doc by ID) are the fastest route for conceptual questions.
Otherwise use the local source or the website.

### 2. Search the Local Source

For signatures and implementation details, search `opensrc/repos/github.com/effect-ts/effect/packages/` (or the GitHub repo if there is no local checkout).
Ready-made grep recipes are under **Lookup Commands** in [`references/patterns.md`](references/patterns.md).

## Quick Reference

| Task              | Reference                |
| ----------------- | ------------------------ |
| Module categories | `references/modules.md`  |
| Common patterns   | `references/patterns.md` |

## Package Structure

```text
opensrc/repos/github.com/effect-ts/effect/
├── packages/
│   ├── effect/               # Core Effect library
│   │   └── src/              # Source files (Effect.ts, Layer.ts, etc.)
│   ├── platform/             # Cross-platform utilities (HTTP, FileSystem)
│   ├── platform-node/        # Node.js platform implementation
│   ├── platform-browser/     # Browser platform implementation
│   ├── cli/                  # CLI building utilities
│   ├── sql/                  # SQL database utilities
│   ├── sql-pg/               # PostgreSQL implementation
│   ├── sql-kysely/           # Kysely integration
│   ├── rpc/                  # Remote procedure calls
│   ├── cluster/              # Distributed computing
│   ├── opentelemetry/        # OpenTelemetry integration
│   ├── experimental/         # Experimental features
│   └── ai/                   # AI integrations (OpenAI, Anthropic, etc.)
```

## Finding the Right Module

Core modules live at `packages/effect/src/<Module>.ts` (e.g. `Effect.ts`, `Layer.ts`, `Schema.ts`, `Stream.ts`); platform, SQL, RPC, CLI, and AI integrations are separate packages.
For the full categorized list, read [`references/modules.md`](references/modules.md).
Tests under `packages/*/test/` show real usage, and the JSDoc in each source file is the most reliable signature reference.

## EffectPatterns Knowledge Base

Community-driven patterns and architectural guides at `opensrc/repos/github.com/PaulJPhilp/EffectPatterns/`.

Pattern write-ups are under `content/`, longer guides under `docs/`.

Covers: getting started, core concepts, error management, resource management, concurrency, streams, scheduling, domain modeling, schema, platform, HTTP APIs, data pipelines, testing, and observability.

## External References

- [Effect Website](https://effect.website/) - Official documentation
- [Effect API Reference](https://effect-ts.github.io/effect/) - Full API docs
- [Effect Discord](https://discord.gg/hdt7t7jpvn) - Community support
