# Visual Test Patterns

> The code samples show the shape of a test, not a current API reference.
> Take exact calls from the docs of the installed library versions, preferring their newest APIs; libraries rename and deprecate APIs between releases.

A visual test renders one fixed state and compares a screenshot with a baseline image a person has reviewed.
It checks what the user sees — layout, spacing, colour, theme, overflow — which text and role assertions cannot.
Use the tool the project already has; the example below uses Playwright's `toHaveScreenshot`.

## Make Every Screenshot Deterministic

A visual test that changes between runs gets ignored.
Before taking a screenshot, fix everything that can vary:

- **Data** — fixed fixtures, never live API data; stub the network at the boundary.
- **Time** — freeze the clock so dates and relative times ("3 minutes ago") don't change.
- **Animation** — disable CSS animations and transitions, and wait for any that must finish.
- **Fonts and images** — wait until web fonts and images have loaded.
- **Viewport and device scale** — set them explicitly for each test.
- **Dynamic regions** — mask what still changes (avatars from a CDN, ads, video frames) instead of skipping the whole screenshot.
- **Environment** — generate and compare baselines on the same OS and browser, usually in CI or a container, because font rendering differs between machines.

## Choose the States

Take one screenshot per visual state the code distinguishes, not one per prop combination:

- Each variant the styles treat differently (primary / secondary, sizes)
- Each theme (light / dark) and each breakpoint where the layout changes
- Loading, empty, and error states
- Stress content: long text, many items, missing image, right-to-left text

Name each test after the state it shows, so a failing diff says what broke.

## Example: Playwright Component Screenshots

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

    test('should wrap a long plan name without overflowing on mobile', async ({ page }) => {
        // GIVEN a plan with a very long name on a narrow screen
        await page.route('**/api/prices', (route) =>
            route.fulfill({ json: [{ plan: 'Professional Plus Annual', amount: 1900 }] })
        )
        await page.setViewportSize({ width: 375, height: 812 })
        await page.goto('/pricing')

        // THEN the card should match the reviewed baseline
        await expect(page.getByRole('article')).toHaveScreenshot('price-card-long-name-mobile.png')
    })
})
```

Playwright's `toHaveScreenshot` already disables animations and hides the text caret by default, so the example passes no options; other tools may need both set explicitly.

Screenshot the smallest element that shows the state — a card, not the whole page — so unrelated changes don't fail the test.

## Baselines

- The first run writes the baseline images; tell the user which ones were created so they can review them before committing.
- When a comparison fails, report the diff.
  Update the baseline only when the user confirms the new look is intended, never to make the test pass.
- Keep the comparison threshold as tight as the environment allows; a loose threshold hides real regressions.

## Visual Tests vs. DOM Snapshots

Prefer behavior assertions or real screenshots over DOM snapshots (`toMatchSnapshot` of rendered HTML).
A DOM snapshot records markup, which is implementation: it fails on harmless refactors and misses broken CSS.
