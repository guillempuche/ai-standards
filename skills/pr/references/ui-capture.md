# UI capture

How to capture visual proof for a pull request that changes a user interface.
Read this from Step 2 of the `pr` skill when the change touches a UI.

Attach proof so the reviewer sees the change without running the branch, using the `ui-capture` role's tool.

**Default to capturing — do it without asking.**
The only case where skipping is even on the table is a change whose visual result is self-evident from the diff alone: a token value, a one-word copy edit, a renamed label.
Skip it there and say why in one line under `## Screenshots`.
Never skip silently.
"The stack is slow to start" is not a reason to skip; if it genuinely won't come up, surface that and ask rather than burying a note in the PR body.

**Screenshot, recording, or both — pick by what changed:**

- **Screenshot** — a *state*: new or changed layout, copy, colour, a field, an empty / loading / error state.
  One still per distinct state.
  This is the default.
- **Short recording** — *behavior over time*: a multi-step flow, navigation, a modal opening and closing, an animation, an optimistic update, a loading-to-loaded sequence.
  How to record it is under [How to record](#how-to-record).
- **Both** — when a flow is worth recording and it ends on a state worth a quick-scan still.

**Which screen sizes:**

- **Both small and large** whenever the change is responsive or layout-affecting — navigation that differs by breakpoint, grids and tables, a modal that becomes a sheet, anything gated on a media query.
  The two layouts differ, so one screenshot hides half the change.
- **One viewport** is enough for a size-agnostic change, or a surface that exists at one size only.
  Say which you captured and why.

## How to record

- **Tool** — record with the tool the `ui-capture` role names.
  With no role, use a browser-automation tool in this session that can record, for example `agent-browser` or Playwright's CLI (`playwright-cli` or `npx playwright cli`).
  For those two, `SKILL.md` links a quick reference each; read only the one you use, and for any other tool use its own docs.
  If none can, take screenshots instead and say so in `## Review guide`.
- **Before recording** — set up the state, the viewport and the login, so the recording opens on the change.
  Record only the steps that show the change, and run start, steps and stop in one call (a batch or a script, with element refs looked up first).
  Thinking between separate commands leaves seconds of frozen screen in the video.
  Add a short wait only where the reviewer needs a moment to read the result.
  Do a second recording at the other size only if the change behaves differently there.
- **For the reviewer** — one behavior per recording, 5–15 seconds, opening on the ready state and ending on the result.
  Viewport-sized (about 1280×800 large, 390×844 small), 30 fps (60 only for motion), cursor shown, no audio.
  Put one line above it saying what to watch for, and add a still of the end state for a quick scan.
  Keep real speed, since reviewers judge timing; speed it up only when asked, and say so in that line ("2× speed").
- **Output** — record straight to `.mp4` when the tool can, since H.264 plays everywhere, phones included; otherwise keep its native `.webm` or `.mov`.
  Don't convert it yourself: compaction is the `media-upload` role's job; without one, `pr-body.md` says what trimming and shrinking is allowed.
- **Names** — `<screen>-<state-or-flow>-<size>.<ext>`, for example `settings-save-small.mp4` or `settings-saved-large.png`.
  The reviewer sees the name, and `gh` uses it as an image's alt text when none is given.
  Save captures to a temporary or gitignored folder, never into a commit.
- **Data** — captures may become public, so use seeded or invented data only, never production data or real personal data.
