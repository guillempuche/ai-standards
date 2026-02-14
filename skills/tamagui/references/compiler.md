# Tamagui Compiler

Optimizing compiler that extracts styles at build time for better performance.

## Overview

The Tamagui compiler analyzes styled components and extracts static styles to CSS, reducing runtime overhead. It works with various bundlers through dedicated plugins.

## Bundler Plugins

| Plugin                | Bundler         | Docs                                                                                                   | Source                                                                        |
| --------------------- | --------------- | ------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------- |
| @tamagui/vite-plugin  | Vite            | [docs](opensrc/repos/github.com/tamagui/tamagui/code/tamagui.dev/data/docs/guides/vite.mdx)            | [source](opensrc/repos/github.com/tamagui/tamagui/code/compiler/vite-plugin)  |
| @tamagui/next-plugin  | Next.js         | [docs](opensrc/repos/github.com/tamagui/tamagui/code/tamagui.dev/data/docs/guides/next-js.mdx)         | [source](opensrc/repos/github.com/tamagui/tamagui/code/compiler/next-plugin)  |
| @tamagui/metro-plugin | Metro (RN/Expo) | [docs](opensrc/repos/github.com/tamagui/tamagui/code/tamagui.dev/data/docs/guides/metro.mdx)           | [source](opensrc/repos/github.com/tamagui/tamagui/code/compiler/metro-plugin) |
| @tamagui/babel-plugin | Babel           | [docs](opensrc/repos/github.com/tamagui/tamagui/code/tamagui.dev/data/docs/intro/compiler-install.mdx) | [source](opensrc/repos/github.com/tamagui/tamagui/code/compiler/babel-plugin) |
| @tamagui/loader       | Webpack         | [docs](opensrc/repos/github.com/tamagui/tamagui/code/tamagui.dev/data/docs/guides/webpack.mdx)         | [source](opensrc/repos/github.com/tamagui/tamagui/code/compiler/loader)       |

## Core Compiler

| Package                | Description                    | Source                                                                         |
| ---------------------- | ------------------------------ | ------------------------------------------------------------------------------ |
| @tamagui/static        | Static extraction engine       | [source](opensrc/repos/github.com/tamagui/tamagui/code/compiler/static)        |
| @tamagui/static-worker | Worker for parallel extraction | [source](opensrc/repos/github.com/tamagui/tamagui/code/compiler/static-worker) |

## Framework Setup Guides

| Framework | Description                         | Guide                                                                                          |
| --------- | ----------------------------------- | ---------------------------------------------------------------------------------------------- |
| Vite      | Web development with Vite plugin    | [docs](opensrc/repos/github.com/tamagui/tamagui/code/tamagui.dev/data/docs/guides/vite.mdx)    |
| Next.js   | SSR and App Router integration      | [docs](opensrc/repos/github.com/tamagui/tamagui/code/tamagui.dev/data/docs/guides/next-js.mdx) |
| Expo      | Expo managed and bare workflows     | [docs](opensrc/repos/github.com/tamagui/tamagui/code/tamagui.dev/data/docs/guides/expo.mdx)    |
| Metro     | React Native bundler setup          | [docs](opensrc/repos/github.com/tamagui/tamagui/code/tamagui.dev/data/docs/guides/metro.mdx)   |
| Webpack   | Legacy Webpack loader configuration | [docs](opensrc/repos/github.com/tamagui/tamagui/code/tamagui.dev/data/docs/guides/webpack.mdx) |
| One       | One framework integration           | [docs](opensrc/repos/github.com/tamagui/tamagui/code/tamagui.dev/data/docs/guides/one.mdx)     |

## Documentation

| Topic                 | Description                         | URL                                                                                                    |
| --------------------- | ----------------------------------- | ------------------------------------------------------------------------------------------------------ |
| Compiler Installation | Setup guide for adding the compiler | [docs](opensrc/repos/github.com/tamagui/tamagui/code/tamagui.dev/data/docs/intro/compiler-install.mdx) |
| Why a Compiler        | Performance benefits and tradeoffs  | [docs](opensrc/repos/github.com/tamagui/tamagui/code/tamagui.dev/data/docs/intro/why-a-compiler.mdx)   |
| Benchmarks            | Performance comparisons and metrics | [docs](opensrc/repos/github.com/tamagui/tamagui/code/tamagui.dev/data/docs/intro/benchmarks.mdx)       |
| Developing            | Local development and debugging     | [docs](opensrc/repos/github.com/tamagui/tamagui/code/tamagui.dev/data/docs/guides/developing.mdx)      |
