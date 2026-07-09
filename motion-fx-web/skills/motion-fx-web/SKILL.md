---
name: motion-fx-web
description: Use when choosing or building a web-native visual effect (liquid glass, refraction, shape morph, masking, displacement) for HyperFrames or the web, or when getting three.js/WebGL to render inside a headless reel. Gives the effect map and the WebGL-headless render recipe; routes to the effect skills.
---

# Web-Native Motion FX

Runnable effect recipes that sit on top of your web runtimes (`three`, `gsap`, `css-animations`). For the *craft* (easing, timing, principles) see the **motion-craft** plugin — this is the *effects*.

## Effect map — which skill

| Want | Skill |
|---|---|
| Glassy translucent surface, frosted, Apple look | `liquid-glass-2d` (light, reel-safe) |
| Photoreal 3D glass, real refraction | `liquid-glass-3d` |
| One layer revealing/hiding through another | `masking-blend` |
| Icon-to-icon / blob transitions | `shape-morphing` |
| Water, smoke, heat haze, glitch warp | `displacement-distortion` |

## WebGL-headless render recipe (the cross-cutting one)

3D refraction in a reel means three.js inside headless Chromium (Playwright). Getting a GPU context there is the tricky part:

1. **Launch flags:** `--use-gl=angle --use-angle=swiftshader --enable-webgl --ignore-gpu-blocklist`. SwiftShader is *software* WebGL — slow but **deterministic**, which is what you want for frame-by-frame capture.
2. **Renderer:** `new THREE.WebGLRenderer({ preserveDrawingBuffer: true, antialias: true })`. `preserveDrawingBuffer` is required so Playwright can read the canvas after render.
3. **Frame-driven animation, not wall-clock.** Inject a frame index and derive all motion from it (the same discipline as Remotion `useCurrentFrame()`). Never `Date.now()` — it desyncs under variable headless frame time.
4. **Wait for the render before capturing.** Set `window.__frameRendered = false` before each frame; in the render callback set `= true`. Playwright waits on that flag, then screenshots.
5. **Fallback:** if 3D misbehaves headless, `liquid-glass-2d` gives ~the same read with zero WebGL.

## Cross-links

`motion-craft` for easing/timing on any effect; the `three` and `gsap` skills for the runtimes themselves.
