---
name: ae-doscript
description: Use when driving After Effects headless from the shell — dispatching ExtendScript (.jsx) via osascript DoScript, reading results from /tmp logs, or debugging why an AE dispatch hangs, times out, or silently does nothing. The operational core: one op per dispatch, log-based results, modal dialogs via computer-use.
---

# AE DoScript — Driving After Effects Headless

This is the operational core. AE 2026 can be driven headless-style from the shell; the trick is that AppleEvents time out while scripts keep running, so **the /tmp log is the source of truth**, not the osascript return.

Start from `scripts/dispatch.sh` + `scripts/skeleton.jsx` — they already contain the plumbing below.

## The dispatch pattern

```bash
osascript -e "tell application \"$AE_APP\" to DoScript \"\$.evalFile(File(\\\"/path/op.jsx\\\"))\""
```

The AE app name is parameterized via `AE_APP` (default `"Adobe After Effects 2026"`) so an AE upgrade doesn't require touching the plugin. Use `dispatch.sh`, which wraps this and polls the log.

## Hard rules (learned the hard way)

- **One heavy op per dispatch.** Multiple exports / heavy ops in a single run crash with `"Unable to execute script: Object is invalid"` (uncatchable alert) and leave a `"Temporary…"` comp behind. Do one, `sleep 6`, then the next.
- **Results only via the /tmp log** — append + flush after every step (`File.open("a")`). A crash then still leaves a trail.
- **AppleEvent Timeout `-1712` is expected** while the script runs. Do not treat it as failure — poll the log for the `=== AE_DONE ===` marker.
- **A second dispatch while one is running is discarded** (`"second script was not run"`). Check the log / a screenshot before re-dispatching.
- **osascript has no Accessibility access** (System Events blocked). Modal dialogs (font sync, "save first", etc.) can only be cleared via the **computer-use MCP** — screenshot + click OK.
- **Clean stray `"Temporary…"` comps at script start** (the skeleton does this).

## QA without the render queue

`comp.saveFrameToPng(time, File)` is the fastest visual check. Caveats:
- The PNG has **straight alpha** — white text over white looks dark in a viewer. Always composite over black/grey via ffmpeg before judging.
- Measure the real rendered size via PIL: `Image.open(p).convert("RGBA").split()[3].getbbox()`.
- Needs **ffmpeg / PIL, not Node**. (AE scripting itself needs no Node.)

## Cross-links

For the craft — easing, the 12 principles, timing, compositing thinking — see the **motion-craft** plugin. This skill is only *how to drive AE*, not what makes motion good.
