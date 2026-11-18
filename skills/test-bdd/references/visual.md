# Visual Test Patterns

> The code samples show the shape of a test, not a current API reference.
> Take exact calls and defaults from the docs and release notes of the installed library versions, preferring their newest APIs; libraries rename and deprecate APIs and change defaults between releases.

A visual test renders one fixed state and compares a screenshot with a baseline image a person has reviewed.
It checks what the user sees — layout, spacing, colour, theme, overflow — which text and role assertions cannot.
It only compares looks: behavior such as focus or what a click does belongs in a browser test (`browser.md`), so a failing screenshot always means "it looks different".
Use the tool the project already has; the example below uses Playwright's `toHaveScreenshot`.

## Make Every Screenshot Deterministic

A visual test that changes between runs gets ignored.
Before taking a screenshot, fix everything that can vary:

- **Data** — fixed fixtures, never live API data; stub the network at the boundary.
- **Time** — freeze the clock so dates and relative times ("3 minutes ago") don't change.
- **Animation** — disable CSS animations and transitions, and wait for any that must finish.
- **Fonts and images** — wait until web fonts and images have loaded.
- **Viewport and device scale** — fix them in the project config or the test, never leave them to the machine that runs it.
- **Dynamic regions** — mask what still changes (avatars from a CDN, ads, video frames) instead of skipping the whole screenshot.
- **Environment** — generate and compare baselines in the same browser build, because font rendering differs between machines (see **Where it runs** below).

## Choose the States

Take one screenshot per visual state the code distinguishes, not one per prop combination:

- Each variant the styles treat differently (primary / secondary, sizes)
- Each theme (light / dark) and each breakpoint where the layout changes
- Loading, empty, and error states
- Stress content: long text, many items, missing image, right-to-left text

Name each test after the state it shows, so a failing diff says what broke.

## Choose the Quality of Each Capture

Start every capture at 1× and normal strictness.
Raise a setting only for the captures that need it, and write the reason in a comment in the test, so a reviewer can tell a deliberate choice from a leftover.
Set the normal values once in the project config, so a test passes options only when it differs from them.
If the config already sets other values, keep them and ask before changing them: the config applies to every existing comparison.

### Pixel density

- **1× (default)** — for layout: wrapping, overflow, spacing, columns.
  A 1× image shows every layout change and keeps baselines small.
- **2×** — for fine detail: icons, 1 px borders, focus rings, small text, small badges, high-contrast themes.
  At 1× these blur into neighbouring pixels, so a real change can fall inside the tolerance.
  A 2× image is four times the file size, which is why it is not the default.

Check that the capture really uses device pixels: some tools capture at CSS pixels unless told otherwise (Playwright's `toHaveScreenshot` has `scale: 'css'` by default), so a 2× page still produces a 1× image.

### Strictness

Comparisons have two settings: how different a pixel's colour may be before it counts as changed (per pixel, from 0 to 1), and how many changed pixels are allowed (a count or a ratio).
Playwright calls them `threshold` and `maxDiffPixels` / `maxDiffPixelRatio`; Vitest's pixelmatch comparator calls them `threshold` and `allowedMismatchedPixels` / `allowedMismatchedPixelRatio`.

- **Exact** — 0 per pixel, 0 pixels.
  For captures whose point is colour: design values, contrast themes, brand colours.
  Any tolerance would let a slightly wrong colour through.
- **Normal (default)** — about 0.1 per pixel, 0 pixels.
  For screens and components: it ignores anti-aliasing differences nobody can see and still catches every visible change.
  It is Vitest's default; Playwright's default is 0.2, so set it in the config there.
- **Tolerant** — N pixels or a ratio, always with a comment that names the noise.
  Only for noise that can't be removed: gradients, blur and shadows, canvas and charts, maps, video.
  Differences between machines are not such noise: remove them by pinning the environment (see **Where it runs**), and tolerate them only where it can't be pinned.

Never loosen a setting to make a test pass.
Decide from a real diff: look at what changed, and loosen only if the change is noise the next run will repeat.

### What's captured

- **The smallest element that shows the state (default)** — a card, not the page, so unrelated changes elsewhere don't fail the test.
- **The visible screen** — when the point is what fits in it: what is above the fold, sticky bars.
- **The full scroll height** — when the point is far down: long text, the end of a long list, a "load more" button.

### Moving parts

Freeze data, the clock, and animations first (see **Make Every Screenshot Deterministic**).
Mask only what can't be frozen, because a masked region is a region the test no longer checks.

### Format

Always lossless PNG.
A lossy format such as JPEG adds compression noise that differs between runs and hides exactly the fine detail a 2× capture is for.

### Where it runs

Make and compare every baseline in one pinned rendering environment, on the laptop and in CI.
Fonts, anti-aliasing, and colour handling differ between operating systems and browser builds, so baselines made anywhere else fail for reasons nobody changed.

- **A browser you run yourself** — one pinned container image, at the same version as the test library, since a remote browser must match its client.
  A common setup: the tests run on the host, and only the browser runs in the container, reached over a websocket — for example Playwright's `run-server` in the container and `connectOptions` with `exposeNetwork: '<loopback>'` in the test config, so the containerised browser can reach the dev server on the host.
- **A hosted service** (Chromatic, Percy, Argos) — its renderer is the pinned environment and it stores the baselines; review changes in its UI, and the file steps below don't apply.
- **Neither** — say so and suggest one; don't commit baselines made on your machine, which CI on another OS would reject.

Both Playwright's default `snapshotPathTemplate` and Vitest's default screenshot names include the host OS (Vitest's the browser too).
With the browser in a container, drop the OS: the image renders the same whatever the host is, and the suffix would make the laptop and CI look for different files.
Without a container, keep it, so each OS compares against its own images.

For setup gotchas (locale, CSS-in-JS, separate tsconfig, collection checks), read `browser.md` → **Gotchas When Adding a Browser Runner**.

## Example: Playwright Screenshots of a Page Element

The example loads a page, so the app must be running (Playwright's `webServer` or `baseURL`); a component runner such as Vitest browser mode renders the component directly instead.

```typescript
import { expect, test } from '@playwright/test'

test.describe('PriceCard', () => {
    test.beforeEach(async ({ page }) => {
        // Freeze time and stub data so every run renders the same pixels
        await page.clock.setFixedTime(new Date('2026-01-15T10:00:00Z'))
        await page.route('**/api/prices', (route) =>
            route.fulfill({ json: [{ plan: 'Pro', amount: 1900 }] })
        )
    })

    test('should show the plan price in the light theme', async ({ page }) => {
        // GIVEN the pricing page in the light theme at desktop width
        await page.setViewportSize({ width: 1280, height: 800 })
        await page.goto('/pricing?theme=light')

        // THEN the card should match the reviewed baseline
        await expect(page.getByRole('article', { name: 'Pro' })).toHaveScreenshot(
            'price-card-light.png'
        )
    })

    test('should show a long plan name wrapped onto two lines on mobile', async ({ page }) => {
        // GIVEN a plan with a very long name on a narrow screen
        await page.route('**/api/prices', (route) =>
            route.fulfill({ json: [{ plan: 'Professional Plus Annual', amount: 1900 }] })
        )
        await page.setViewportSize({ width: 375, height: 812 })
        await page.goto('/pricing')

        // THEN the card should match the reviewed baseline
        await expect(page.getByRole('article')).toHaveScreenshot('price-card-long-name-mobile.png')
    })

    test.describe('in the high-contrast theme', () => {
        // 2× and exact: the theme's 1 px borders and badge colours are the point of
        // this capture, and at 1× or with any tolerance a wrong value can still pass
        test.use({ deviceScaleFactor: 2 })

        test('should outline the card and badge in the high-contrast colours', async ({ page }) => {
            // GIVEN the pricing page in the high-contrast theme
            await page.setViewportSize({ width: 1280, height: 800 })
            await page.goto('/pricing?theme=high-contrast')

            // THEN the card should match the reviewed baseline pixel for pixel
            await expect(page.getByRole('article', { name: 'Pro' })).toHaveScreenshot(
                'price-card-high-contrast.png',
                { scale: 'device', threshold: 0 }
            )
        })
    })
})
```

The first two captures use the project defaults (1×, normal strictness), so they pass no options and need no comment.
Playwright's `toHaveScreenshot` already disables animations and hides the text caret by default; other tools may need both set explicitly.

## Baselines

- The first run writes each missing baseline and fails; tell the user which images were created so they can review them before committing.
  Until then, a retry or rerun passes against an image nobody reviewed.
- Playwright and Vitest fail on a missing baseline by default, and in CI Vitest doesn't even write one; keep it that way and never pass the update flag (`-u`, `--update-snapshots`) in CI.
- When a comparison fails, report the diff.
  Update the baseline only when the user confirms the new look is intended, never to make the test pass.
- Keep each comparison at the strictness its capture needs (see **Strictness**); a loose threshold hides real regressions.

## Visual Tests vs. DOM Snapshots

Prefer behavior assertions or real screenshots over DOM snapshots (`toMatchSnapshot` of rendered HTML).
A DOM snapshot records markup, which is implementation: it fails on harmless refactors and misses broken CSS.
