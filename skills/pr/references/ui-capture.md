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
  Set the state up *before* you start recording, then perform only the steps that demonstrate the change.
  A few seconds, not a whole session.
- **Both** — when a flow is worth recording and it ends on a state worth a quick-scan still.

**Which screen sizes:**

- **Both small and large** whenever the change is responsive or layout-affecting — navigation that differs by breakpoint, grids and tables, a modal that becomes a sheet, anything gated on a media query.
  The two layouts differ, so one screenshot hides half the change.
- **One viewport** is enough for a size-agnostic change, or a surface that exists at one size only.
  Say which you captured and why.
