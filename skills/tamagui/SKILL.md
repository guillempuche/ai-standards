---
name: tamagui
description: Tamagui styling, themes, tokens, compiler, and UI kit for React and React Native. Use when the project uses or is adopting Tamagui and you are writing or debugging its components, config, or compiler setup.
license: MIT
metadata:
  version: 1.0.3
  author: ai-standards
  language: typescript
  frameworks: react, react-native, next, expo, vite
compatibility: React 18+, React Native 0.71+
allowed-tools: Read Write Edit Bash Grep Glob
---

# Tamagui Skill

Style React fast with 100% parity on React Native, an optional UI kit, and optimizing compiler.

## Source Code Access

Links in this skill and its references point to GitHub.
If the project has a local checkout at `opensrc/repos/github.com/tamagui/tamagui/` (from `npx opensrc tamagui/tamagui`), the same paths exist under it — read those first, since they match the version the project fetched.

## Documentation

Core concepts for understanding and using Tamagui's styling system.

| Topic         | Description                              | URL                                                                                                        |
| ------------- | ---------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| Introduction  | Overview and key concepts                | [docs](https://github.com/tamagui/tamagui/blob/main/code/tamagui.dev/data/docs/intro/introduction.mdx)     |
| Installation  | Getting started and setup                | [docs](https://github.com/tamagui/tamagui/blob/main/code/tamagui.dev/data/docs/intro/installation.mdx)     |
| Configuration | createTamagui and config options         | [docs](https://github.com/tamagui/tamagui/blob/main/code/tamagui.dev/data/docs/core/configuration.mdx)     |
| Themes        | Dark/light modes and custom themes       | [docs](https://github.com/tamagui/tamagui/blob/main/code/tamagui.dev/data/docs/intro/themes.mdx)           |
| Tokens        | Design tokens for spacing, colors, fonts | [docs](https://github.com/tamagui/tamagui/blob/main/code/tamagui.dev/data/docs/core/tokens.mdx)            |
| styled()      | Create styled components with variants   | [docs](https://github.com/tamagui/tamagui/blob/main/code/tamagui.dev/data/docs/core/styled.mdx)            |
| Animations    | Animation drivers and configuration      | [docs](https://github.com/tamagui/tamagui/blob/main/code/tamagui.dev/data/docs/core/animations.mdx)        |
| Compiler      | Optimizing compiler setup                | [docs](https://github.com/tamagui/tamagui/blob/main/code/tamagui.dev/data/docs/intro/compiler-install.mdx) |
| UI Components | Pre-built component library overview     | [docs](https://github.com/tamagui/tamagui/blob/main/code/tamagui.dev/data/docs/components/intro/1.0.0.mdx) |

## Source Code

Direct links to implementation code in the monorepo.

| Area             | Description                          | Path                                                                          |
| ---------------- | ------------------------------------ | ----------------------------------------------------------------------------- |
| Repository       | Main monorepo with all packages      | [tamagui/tamagui](https://github.com/tamagui/tamagui)                         |
| UI Components    | 50+ themed, accessible components    | [`code/ui`](https://github.com/tamagui/tamagui/tree/main/code/ui)             |
| Core Packages    | Styling engine, themes, hooks, fonts | [`code/core`](https://github.com/tamagui/tamagui/tree/main/code/core)         |
| Compiler Plugins | Bundler plugins for style extraction | [`code/compiler`](https://github.com/tamagui/tamagui/tree/main/code/compiler) |

## Framework Guides

Setup instructions for integrating Tamagui with specific frameworks and bundlers.

| Framework | Description                             | Docs                                                                                               |
| --------- | --------------------------------------- | -------------------------------------------------------------------------------------------------- |
| Expo      | React Native with Expo managed workflow | [docs](https://github.com/tamagui/tamagui/blob/main/code/tamagui.dev/data/docs/guides/expo.mdx)    |
| Next.js   | Server-side rendering and App Router    | [docs](https://github.com/tamagui/tamagui/blob/main/code/tamagui.dev/data/docs/guides/next-js.mdx) |
| Vite      | Fast web development with HMR           | [docs](https://github.com/tamagui/tamagui/blob/main/code/tamagui.dev/data/docs/guides/vite.mdx)    |
| Metro     | React Native bundler configuration      | [docs](https://github.com/tamagui/tamagui/blob/main/code/tamagui.dev/data/docs/guides/metro.mdx)   |

## Local References

Detailed reference files with component and API documentation.

- `references/components.md` - UI component library with docs and source links
- `references/core.md` - Core packages, configuration APIs, and hooks
- `references/compiler.md` - Bundler plugins and optimization setup
