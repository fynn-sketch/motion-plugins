---
description: Scaffold a standalone, runnable HTML demo of a motion-fx-web effect into ~/Downloads for quick preview and tweaking.
---

# /fx-demo

Scaffold a self-contained HTML demo of a motion-fx-web effect into `~/Downloads/` so it can be previewed and tweaked immediately.

## Steps

1. Read the effect name from `$ARGUMENTS`. Valid names: `liquid-glass-2d`, `liquid-glass-3d`, `shape-morphing`, `masking-blend`, `displacement-distortion`. If empty or unknown, list these and stop.
2. **For effects with a static demo** (`liquid-glass-2d`, `masking-blend`, `displacement-distortion`): copy `assets/demos/<effect>.html` to `~/Downloads/<effect>_demo.html`.
3. **For `liquid-glass-3d` and `shape-morphing`** (no static demo): generate a standalone HTML into `~/Downloads/<effect>_demo.html` from the skill's recipe, importing three/flubber via ESM CDN (`https://esm.sh/...`) so it runs with no build.
4. Optionally `open ~/Downloads/<effect>_demo.html` in the browser.
5. Report the path and note it is self-contained — no build, no Node. (three/flubber load from CDN, so it needs a network connection the first time.)
