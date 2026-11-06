# Recording with agent-browser

Quick reference for recording a UI change with `agent-browser`.
Read this from Step 2 of the `pr` skill, alongside `references/ui-capture.md`, only when `agent-browser` is the recorder.

Written against 0.41.2.
Use the newest version available, and trust the installed `agent-browser record --help` over this page when they differ.

Recording needs `ffmpeg` on `PATH` with the libvpx and libx264 encoders; `agent-browser doctor` checks it.

```bash
# Set up before recording: login, viewport, starting page
agent-browser --state ./auth.json open http://localhost:3000/settings   # saved login state; never commit it
agent-browser set viewport 390 844                                      # small size; 1440 900 for large

# Look up refs first, then record in one call so no idle time lands in the video
agent-browser snapshot -i                                  # find the ref, e.g. @e3
agent-browser batch \
  "record start ./pr-media/settings-save-small.mp4 --cursor --contact-sheet" \
  "click @e3" "wait 500" \
  "record stop"                                            # no --bail, so stop always runs; redo the take if any step shows ✗

# Before and after: on the base branch, save a still; on the PR branch, diff against it
agent-browser screenshot ./pr-media/settings-saved-large-before.png
agent-browser diff screenshot --baseline ./pr-media/settings-saved-large-before.png --output ./pr-media/settings-saved-large-diff.png

# Second size only if the change behaves differently there
agent-browser set viewport 1440 900
agent-browser record restart ./pr-media/settings-save-large.mp4
```

- `.mp4` (H.264) plays everywhere, phones included; `.webm` also works, and a path with no extension is rejected.
- `--cursor` draws the pointer where each click lands; it appears there almost at once rather than travelling, so a short `wait` after a click helps the reviewer see it.
- `--contact-sheet` also saves `<name>.contact-sheet.png`, one image with a frame per distinct visual change, a quick-scan still for `## Screenshots`.
- `diff url <before-url> <after-url> --screenshot` compares two running versions, such as the base's preview and the PR's.
- `set media dark` / `set media light reduced-motion` only when the change touches theming or animation.
- There are no action callouts or chapters; say what happens in the line above the video.
- `--fps 60` for a short, motion-heavy take; the default 30 is enough otherwise.
