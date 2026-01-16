# PowerSync Examples Reference

Official example projects from the [powersync-js repository](https://github.com/powersync-ja/powersync-js/tree/main/demos).

## React Web

| Example                              | Description                      | Source                                                                                                      |
| ------------------------------------ | -------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| react-supabase-todolist              | React + Supabase to-do list      | [GitHub](https://github.com/powersync-ja/powersync-js/tree/main/demos/react-supabase-todolist)              |
| react-supabase-todolist-tanstackdb   | React + TanStack DB collections  | [GitHub](https://github.com/powersync-ja/powersync-js/tree/main/demos/react-supabase-todolist-tanstackdb)   |
| react-supabase-todolist-sync-streams | React + Sync Streams (alpha)     | [GitHub](https://github.com/powersync-ja/powersync-js/tree/main/demos/react-supabase-todolist-sync-streams) |
| react-multi-client                   | Multi-client sync demo           | [GitHub](https://github.com/powersync-ja/powersync-js/tree/main/demos/react-multi-client)                   |
| react-neon-tanstack-query-notes      | React + Neon + TanStack Query    | [GitHub](https://github.com/powersync-ja/powersync-js/tree/main/demos/react-neon-tanstack-query-notes)      |
| yjs-react-supabase-text-collab       | Real-time collaboration with Yjs | [GitHub](https://github.com/powersync-ja/powersync-js/tree/main/demos/yjs-react-supabase-text-collab)       |

## React Native

| Example                               | Description                        | Source                                                                                                       |
| ------------------------------------- | ---------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| react-native-supabase-todolist        | React Native + Supabase to-do list | [GitHub](https://github.com/powersync-ja/powersync-js/tree/main/demos/react-native-supabase-todolist)        |
| react-native-supabase-group-chat      | Group chat app                     | [GitHub](https://github.com/powersync-ja/powersync-js/tree/main/demos/react-native-supabase-group-chat)      |
| react-native-supabase-background-sync | Background sync with Expo          | [GitHub](https://github.com/powersync-ja/powersync-js/tree/main/demos/react-native-supabase-background-sync) |
| react-native-web-supabase-todolist    | React Native for Web               | [GitHub](https://github.com/powersync-ja/powersync-js/tree/main/demos/react-native-web-supabase-todolist)    |
| react-native-barebones-opsqlite       | Minimal OP-SQLite setup            | [GitHub](https://github.com/powersync-ja/powersync-js/tree/main/demos/react-native-barebones-opsqlite)       |
| django-react-native-todolist          | React Native + Django backend      | [GitHub](https://github.com/powersync-ja/powersync-js/tree/main/demos/django-react-native-todolist)          |

## Vue

| Example               | Description               | Source                                                                                       |
| --------------------- | ------------------------- | -------------------------------------------------------------------------------------------- |
| vue-supabase-todolist | Vue + Supabase to-do list | [GitHub](https://github.com/powersync-ja/powersync-js/tree/main/demos/vue-supabase-todolist) |

## Angular

| Example                   | Description                   | Source                                                                                           |
| ------------------------- | ----------------------------- | ------------------------------------------------------------------------------------------------ |
| angular-supabase-todolist | Angular + Supabase to-do list | [GitHub](https://github.com/powersync-ja/powersync-js/tree/main/demos/angular-supabase-todolist) |

## Bundlers & Frameworks

| Example                 | Description            | Source                                                                                         |
| ----------------------- | ---------------------- | ---------------------------------------------------------------------------------------------- |
| example-vite            | Minimal Vite setup     | [GitHub](https://github.com/powersync-ja/powersync-js/tree/main/demos/example-vite)            |
| example-webpack         | Minimal Webpack setup  | [GitHub](https://github.com/powersync-ja/powersync-js/tree/main/demos/example-webpack)         |
| example-nextjs          | Next.js setup          | [GitHub](https://github.com/powersync-ja/powersync-js/tree/main/demos/example-nextjs)          |
| example-vite-encryption | Web encryption example | [GitHub](https://github.com/powersync-ja/powersync-js/tree/main/demos/example-vite-encryption) |

## Electron

| Example               | Description                      | Source                                                                                       |
| --------------------- | -------------------------------- | -------------------------------------------------------------------------------------------- |
| example-electron      | Electron with Web SDK (renderer) | [GitHub](https://github.com/powersync-ja/powersync-js/tree/main/demos/example-electron)      |
| example-electron-node | Electron with Node.js SDK (main) | [GitHub](https://github.com/powersync-ja/powersync-js/tree/main/demos/example-electron-node) |

## Capacitor

| Example           | Description   | Source                                                                                   |
| ----------------- | ------------- | ---------------------------------------------------------------------------------------- |
| example-capacitor | Capacitor app | [GitHub](https://github.com/powersync-ja/powersync-js/tree/main/demos/example-capacitor) |

## Node.js

| Example      | Description                  | Source                                                                              |
| ------------ | ---------------------------- | ----------------------------------------------------------------------------------- |
| example-node | CLI example with Node.js SDK | [GitHub](https://github.com/powersync-ja/powersync-js/tree/main/demos/example-node) |

## Local Source

If you've downloaded the repo with opensrc, examples are available at:

```
opensrc/repos/github.com/powersync-ja/powersync-js/demos/
```

## Key Files to Study

For each example, focus on:

- `src/powersync/` or `library/powersync/` - Schema, connector, setup
- `src/components/` - React/Vue components with hooks
- `package.json` - Dependencies and versions

## Official Documentation

- [Demo Apps Gallery](https://docs.powersync.com/resources/demo-apps-example-projects)
- [JavaScript Web SDK](https://docs.powersync.com/client-sdk-references/javascript-web)
- [React Native SDK](https://docs.powersync.com/client-sdk-references/react-native-and-expo)
- [Vue Composables](https://docs.powersync.com/client-sdk-references/javascript-web/javascript-spa-frameworks#vue-composables)
