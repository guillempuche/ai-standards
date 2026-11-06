# Recording with Playwright's CLI

Quick reference for recording a UI change with Playwright's agent CLI.
Read this from Step 2 of the `pr` skill, alongside `references/ui-capture.md`, only when Playwright is the recorder.

The same commands ship two ways; use whichever the repo has:

- `playwright-cli`, from the standalone `@playwright/cli` package.
- `npx playwright cli`, built into the `playwright` package, so a repo that already has Playwright needs nothing extra.

The unscoped `playwright-cli` npm package is deprecated; don't install it.

Written against `@playwright/cli` 0.1.23 and `playwright` 1.65.
Use the newest version the repo allows, and trust the installed `--help` (`playwright-cli <command> --help`) over this page when they differ.

```bash
# Set up before recording: viewport, login, starting page
playwright-cli open --mobile                       # small size; plain `open` then `resize 1440 900` for large
playwright-cli state-load ./auth.json              # saved login state; never commit it
playwright-cli goto http://localhost:3000/settings

# Look up refs first, then record in one shell call so no idle time lands in the video
playwright-cli snapshot                            # find the ref, e.g. e3
playwright-cli video-start pr-media/settings-save-small.webm --size=390x844 --cursor \
  && playwright-cli click e3 \
  && playwright-cli video-stop
```

For a longer flow, put the steps in one script and run it between `video-start` and `video-stop`:

```bash
playwright-cli run-code --filename steps.js        # steps.js: async page => { await page.getByRole('button', { name: 'Save' }).click(); }
```

- Video is WebM only, which GitHub plays inline; leave conversion to the `media-upload` role.
- Pass `--size` to `video-start` matching the viewport; without it the video is fitted to 800×800.
- `--cursor` paces each action by about 800 ms so the pointer can travel; keep the take short.
- Run the second size in its own session (`-s=large`) so the small one's state is untouched.
- `video-chapter <title>` marks a step in a longer flow; `video-show-actions` adds a callout for each action.
- `recording-start` / `recording-stop` record *actions as Playwright code*, not video; use `video-start` for the PR.
