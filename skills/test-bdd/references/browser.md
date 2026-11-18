# Browser Test Patterns

> The code samples show the shape of a test, not a current API reference.
> Take exact calls and defaults from the docs and release notes of the installed library versions, preferring their newest APIs; libraries rename and deprecate APIs and change defaults between releases.

A browser test renders one component or page in a real browser engine and checks behavior a simulated DOM (jsdom, happy-dom) cannot compute.
It asserts on behavior, like a unit test: focus, position, visibility, what a native control does.
It never compares screenshots; that is a visual test, in its own file (see `visual.md`).

## What Belongs Here

Write a browser test only when the answer depends on the engine:

- **Tab order that CSS decides** — controls a stylesheet or media query hides, skip links that appear on focus, `inert` regions.
  In a simulated DOM the testing library imitates Tab from DOM order and `tabindex`, without the app's CSS files, so it can't see what the stylesheet removes.
  A focus trap or roving focus written in JavaScript works there too, so test it in the simulated DOM unless it relies on CSS or native behavior.
- **Layout and position** — overflow, one element covering another, an element pushed out of the viewport, sticky headers.
  A simulated DOM has no layout: every box measures 0×0.
- **CSS that hides or shows** — stylesheets, media queries, container queries, `:hover` and `:focus-visible` rules.
  A simulated DOM doesn't load the app's CSS files by default, and jsdom ignores `@media`, so an element hidden that way still counts as visible.
- **Native controls and browser APIs** — date and time inputs, `details`/`summary`, `dialog`, `matchMedia`, `IntersectionObserver`, `ResizeObserver`.
  jsdom lacks most of them and happy-dom imitates some against a fixed default window, so the test would check the imitation.

Everything else — logic, rendered text and roles, callbacks, state — stays in the simulated-DOM test, which runs in a fraction of the time.
If a browser test needs auth, cookies, server rendering, or navigation between pages, it is an end-to-end test instead.

## Keep It Repeatable

Layout and visibility depend on the environment as much as on the code:

- **Viewport** — set it in every test that depends on it; Vitest's `page.viewport()` carries over to the later tests in the same file.
- **Fonts** — wait for web fonts before measuring, since a fallback font wraps text differently.
- **Time and animation** — freeze the clock and disable animations before checking position or visibility.
- **Browser build** — assertions that depend on text metrics (wrapping, overflow) need the same pinned browser as visual tests (see `visual.md` → **Where it runs**).

## Example: Vitest Browser Mode

```typescript
// FilterPanel.browser.test.tsx — next to FilterPanel.tsx
import { describe, expect, it } from 'vitest'
import { page, userEvent } from 'vitest/browser'
import { render } from 'vitest-browser-react'

import { FilterPanel } from './FilterPanel'

describe('FilterPanel', () => {
    it('should skip the collapsed filter list when tabbing on a narrow screen', async () => {
        // GIVEN a phone-sized viewport, where the stylesheet collapses the filter list
        await page.viewport(375, 812)
        await render(<FilterPanel filters={['In stock', 'On sale']} />)

        // WHEN the user tabs into the panel
        await userEvent.tab()
        // THEN the filters toggle should take focus
        await expect.element(page.getByRole('button', { name: 'Show filters' })).toHaveFocus()

        // WHEN the user tabs again
        await userEvent.tab()
        // THEN focus should skip the hidden checkboxes and land on Apply
        await expect.element(page.getByRole('button', { name: 'Apply filters' })).toHaveFocus()
    })

    it('should keep Apply on screen when the filter list is taller than the viewport', async () => {
        // GIVEN a short desktop viewport and more filters than fit in it
        await page.viewport(1280, 600)
        const filters = Array.from({ length: 40 }, (_, i) => `Filter ${i + 1}`)

        // WHEN the panel renders
        await render(<FilterPanel filters={filters} />)

        // THEN the sticky Apply button should be in the viewport, not below the list
        await expect.element(page.getByRole('button', { name: 'Apply filters' })).toBeInViewport()
    })
})
```

In a simulated DOM neither outcome depends on the code: the stylesheet isn't loaded, so the second Tab always reaches a checkbox, and nothing has a position, so "in the viewport" can't be measured.
That is the test for whether a case belongs in this file.

## Gotchas When Adding a Browser Runner

Seen with Vitest 5 browser mode and Playwright 1.65, with the browser in a Docker container; recheck them against the installed versions.

- **Date and time formats** — Chromium on Linux formats date and time fields from the `LANG` / `LANGUAGE` environment variables, not from `--lang` or the context locale.
  Set them in the browser container, or a date input renders differently in CI than on a laptop.
- **Unstyled components** — a bundler that pre-bundles a UI library (Vite's `optimizeDeps`) may skip that library's CSS-in-JS transform, so the browser renders, and screenshots capture, unstyled components.
  Leave such libraries out of pre-bundling.
- **Server-only imports in shared fakes** — a shared test fake that imports a server-only module (for example `node:async_hooks`) fails to load in the browser.
  Give the browser config a test-only stand-in for that module (an alias to a stub) rather than forking the fake.
- **Matcher types leaking** — importing the browser runner's matcher types can change the matcher types of the simulated-DOM tests in the same TypeScript project.
  Give the files that run under the browser runner their own tsconfig, exclude them from the main one (or the leak stays), and make the type-check command cover both.
- **Collection checks** — each config must include only its own suffix, and the simulated-DOM config must exclude the browser ones.
  If the project has a check that every test file is collected exactly once, add the new config to it, so no test runs twice or not at all.
