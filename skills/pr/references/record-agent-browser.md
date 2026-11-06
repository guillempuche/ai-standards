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
agent-browser batch --bail \
  "record start ./pr-media/settings-save-small.mp4" \
  "click @e3" "wait 500" \
  "record stop"                                            # gitignored or temp folder; the open page records as-is

# Second size only if the change behaves differently there
agent-browser set viewport 1440 900
agent-browser record restart ./pr-media/settings-save-large.mp4
```

- `.mp4` (H.264) plays everywhere, phones included; `.webm` also works, and a path with no extension is rejected.
- `--cursor` draws the pointer, which helps a reviewer follow clicks and drags.
- `--fps 60` for a short, motion-heavy take; the default 30 is enough otherwise.
- `--contact-sheet` also saves a PNG of each distinct visual change, a ready-made still for `## Screenshots`.
