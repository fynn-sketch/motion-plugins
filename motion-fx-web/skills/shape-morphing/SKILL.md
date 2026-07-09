---
name: shape-morphing
description: Use when morphing SVG paths on the web beyond simple cases — multi-path, unequal point counts, icon-to-icon and blob morphs — via Flubber or GSAP MorphSVG, eased with motion-craft curves. Extends the shape-morph skill, does not duplicate it.
---

# Advanced SVG Shape Morphing

Naive point-for-point path lerp breaks the moment two shapes have different point counts. Use a real morph engine.

## Route A — Flubber (free, handles unequal points)

```js
import { interpolate } from 'https://esm.sh/flubber';
const interp = interpolate(pathA, pathB, { maxSegmentLength: 2 });
gsap.to({ t: 0 }, {
  t: 1, duration: 1, ease: 'power2.inOut',
  onUpdate() { document.querySelector('#shape').setAttribute('d', interp(this.targets()[0].t)); }
});
```
Flubber resamples both paths so unequal point counts morph cleanly. `maxSegmentLength` controls smoothness.

## Route B — GSAP MorphSVGPlugin (paid, smoothest)

```js
gsap.registerPlugin(MorphSVGPlugin);
gsap.to('#shape', { morphSVG: '#target', duration: 1, ease: 'power2.inOut' });
```
Best-in-class morphing (shape hints, point mapping); needs the Club GSAP plugin.

## Which & how

- **Icon-to-icon** (menu↔close, play↔pause): either route; keep the ease `power2.inOut` so it feels mechanical-free.
- **Blob morph** (organic background): cycle between several rounded random paths on a loop (`repeat:-1, yoyo:true`).
- Pick the curve deliberately — see `motion-easing` (motion-craft). A morph on a linear ease looks cheap.

## Cross-links

`shape-morph` (base skill) for the fundamentals; `motion-easing` for the curve; `motion-fx-web` for the map.
