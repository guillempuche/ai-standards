# Tamagui Core

Core packages, configuration APIs, hooks, and theming system.

## Main Packages

| Package         | Description                     | Source                                                              |
| --------------- | ------------------------------- | ------------------------------------------------------------------- |
| @tamagui/core   | Core styling engine             | [source](opensrc/repos/github.com/tamagui/tamagui/code/core/core)   |
| @tamagui/web    | Web-specific implementation     | [source](opensrc/repos/github.com/tamagui/tamagui/code/core/web)    |
| tamagui         | Full package with UI components | [source](opensrc/repos/github.com/tamagui/tamagui/code/ui/tamagui)  |
| @tamagui/config | Pre-built configuration         | [source](opensrc/repos/github.com/tamagui/tamagui/code/core/config) |

## Configuration APIs

| API           | Description               | Docs                                                                                               |
| ------------- | ------------------------- | -------------------------------------------------------------------------------------------------- |
| createTamagui | Initialize Tamagui config | [docs](opensrc/repos/github.com/tamagui/tamagui/code/tamagui.dev/data/docs/core/configuration.mdx) |
| createTokens  | Define design tokens      | [docs](opensrc/repos/github.com/tamagui/tamagui/code/tamagui.dev/data/docs/core/tokens.mdx)        |
| createThemes  | Generate theme variants   | [docs](opensrc/repos/github.com/tamagui/tamagui/code/tamagui.dev/data/docs/intro/themes.mdx)       |
| styled()      | Create styled components  | [docs](opensrc/repos/github.com/tamagui/tamagui/code/tamagui.dev/data/docs/core/styled.mdx)        |
| variants      | Define component variants | [docs](opensrc/repos/github.com/tamagui/tamagui/code/tamagui.dev/data/docs/core/variants.mdx)      |

## Theme System

| Package                  | Description                 | Source                                                                       |
| ------------------------ | --------------------------- | ---------------------------------------------------------------------------- |
| @tamagui/theme           | Theme context and provider  | [source](opensrc/repos/github.com/tamagui/tamagui/code/core/theme)           |
| @tamagui/themes          | Pre-built theme palettes    | [source](opensrc/repos/github.com/tamagui/tamagui/code/core/themes)          |
| @tamagui/theme-base      | Base theme utilities        | [source](opensrc/repos/github.com/tamagui/tamagui/code/core/theme-base)      |
| @tamagui/theme-builder   | Theme generation helpers    | [source](opensrc/repos/github.com/tamagui/tamagui/code/core/theme-builder)   |
| @tamagui/create-theme    | Create custom themes        | [source](opensrc/repos/github.com/tamagui/tamagui/code/core/create-theme)    |
| @tamagui/generate-themes | Build-time theme generation | [source](opensrc/repos/github.com/tamagui/tamagui/code/core/generate-themes) |

## Animation Drivers

Swappable animation systems for different platforms.

| Driver                           | Description            | Docs                                                                                            | Source                                                                               |
| -------------------------------- | ---------------------- | ----------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| @tamagui/animations-css          | CSS transitions (web)  | [docs](opensrc/repos/github.com/tamagui/tamagui/code/tamagui.dev/data/docs/core/animations.mdx) | [source](opensrc/repos/github.com/tamagui/tamagui/code/core/animations-css)          |
| @tamagui/animations-react-native | React Native Animated  | [docs](opensrc/repos/github.com/tamagui/tamagui/code/tamagui.dev/data/docs/core/animations.mdx) | [source](opensrc/repos/github.com/tamagui/tamagui/code/core/animations-react-native) |
| @tamagui/animations-moti         | Moti/Reanimated driver | [docs](opensrc/repos/github.com/tamagui/tamagui/code/tamagui.dev/data/docs/core/animations.mdx) | [source](opensrc/repos/github.com/tamagui/tamagui/code/core/animations-moti)         |
| @tamagui/animations-motion       | Framer Motion driver   | -                                                                                               | [source](opensrc/repos/github.com/tamagui/tamagui/code/core/animations-motion)       |

## Hooks

| Hook     | Description                 | Docs                                                                                           |
| -------- | --------------------------- | ---------------------------------------------------------------------------------------------- |
| useMedia | Responsive media queries    | [docs](opensrc/repos/github.com/tamagui/tamagui/code/tamagui.dev/data/docs/core/use-media.mdx) |
| useTheme | Access current theme values | [docs](opensrc/repos/github.com/tamagui/tamagui/code/tamagui.dev/data/docs/core/use-theme.mdx) |

## Hook Packages

| Package                         | Description                   | Source                                                                              |
| ------------------------------- | ----------------------------- | ----------------------------------------------------------------------------------- |
| @tamagui/use-debounce           | Debounced values              | [source](opensrc/repos/github.com/tamagui/tamagui/code/core/use-debounce)           |
| @tamagui/use-event              | Stable event callbacks        | [source](opensrc/repos/github.com/tamagui/tamagui/code/core/use-event)              |
| @tamagui/use-force-update       | Force re-render               | [source](opensrc/repos/github.com/tamagui/tamagui/code/core/use-force-update)       |
| @tamagui/use-controllable-state | Controlled/uncontrolled state | [source](opensrc/repos/github.com/tamagui/tamagui/code/core/use-controllable-state) |
| @tamagui/use-keyboard-visible   | Keyboard visibility detection | [source](opensrc/repos/github.com/tamagui/tamagui/code/core/use-keyboard-visible)   |
| @tamagui/use-window-dimensions  | Window size hook              | [source](opensrc/repos/github.com/tamagui/tamagui/code/core/use-window-dimensions)  |

## Font Packages

Pre-configured font families ready to use.

| Package                  | Font       | Source                                                                       |
| ------------------------ | ---------- | ---------------------------------------------------------------------------- |
| @tamagui/font-inter      | Inter      | [source](opensrc/repos/github.com/tamagui/tamagui/code/core/font-inter)      |
| @tamagui/font-dm-sans    | DM Sans    | [source](opensrc/repos/github.com/tamagui/tamagui/code/core/font-dm-sans)    |
| @tamagui/font-fira-mono  | Fira Mono  | [source](opensrc/repos/github.com/tamagui/tamagui/code/core/font-fira-mono)  |
| @tamagui/font-silkscreen | Silkscreen | [source](opensrc/repos/github.com/tamagui/tamagui/code/core/font-silkscreen) |

## Utilities

| Package             | Description               | Source                                                                  |
| ------------------- | ------------------------- | ----------------------------------------------------------------------- |
| @tamagui/helpers    | Shared helper functions   | [source](opensrc/repos/github.com/tamagui/tamagui/code/core/helpers)    |
| @tamagui/constants  | Shared constants          | [source](opensrc/repos/github.com/tamagui/tamagui/code/core/constants)  |
| @tamagui/colors     | Color palette utilities   | [source](opensrc/repos/github.com/tamagui/tamagui/code/core/colors)     |
| @tamagui/shorthands | Style property shorthands | [source](opensrc/repos/github.com/tamagui/tamagui/code/core/shorthands) |
| @tamagui/get-token  | Token access utilities    | [source](opensrc/repos/github.com/tamagui/tamagui/code/core/get-token)  |
| @tamagui/floating   | Floating UI integration   | [source](opensrc/repos/github.com/tamagui/tamagui/code/core/floating)   |

## CLI

| Tool           | Description         | Docs                                                                                                      | Source                                                                      |
| -------------- | ------------------- | --------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------- |
| @tamagui/cli   | Build and dev tools | [docs](opensrc/repos/github.com/tamagui/tamagui/code/tamagui.dev/data/docs/guides/cli.mdx)                | [source](opensrc/repos/github.com/tamagui/tamagui/code/core/cli)            |
| create-tamagui | Project scaffolding | [docs](opensrc/repos/github.com/tamagui/tamagui/code/tamagui.dev/data/docs/guides/create-tamagui-app.mdx) | [source](opensrc/repos/github.com/tamagui/tamagui/code/core/create-tamagui) |
