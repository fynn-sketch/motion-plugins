---
name: liquid-glass-2d
description: Use when building the Apple "Liquid Glass" / glassmorphism look in 2D for the web or HyperFrames — frosted translucency, a refracting edge, and a specular sheen with pure CSS + SVG (no WebGL). Renders cleanly in headless reels.
---

# Liquid Glass 2D

The Apple "Liquid Glass" look with zero WebGL — CSS + one SVG filter. Reel-safe (renders in headless Chromium). Three ingredients:

## 1. Frosted base

```css
.glass {
  background: rgba(255,255,255,.12);
  backdrop-filter: blur(14px) saturate(160%);
  -webkit-backdrop-filter: blur(14px) saturate(160%);
}
/* Fallback where backdrop-filter is unsupported: a heavier semi-opaque bg */
@supports not (backdrop-filter: blur(1px)) { .glass { background: rgba(30,30,40,.72); } }
```

## 2. Refracting edge (SVG)

```html
<svg width="0" height="0"><filter id="glassEdge">
  <feTurbulence type="fractalNoise" baseFrequency="0.008 0.012" numOctaves="2" seed="7" result="noise"/>
  <feDisplacementMap in="SourceGraphic" in2="noise" scale="10" xChannelSelector="R" yChannelSelector="G"/>
</filter></svg>
```
Apply with `filter: url(#glassEdge);`. `scale` ~8–12 is a subtle, believable refraction; higher reads as melting.

## 3. Specular sheen

```css
.glass { box-shadow: 0 8px 32px rgba(0,0,0,.35), inset 0 1px 0 rgba(255,255,255,.5); }
.glass::before { content:""; position:absolute; inset:0; border-radius:inherit; pointer-events:none;
  background: linear-gradient(135deg, rgba(255,255,255,.5), rgba(255,255,255,0) 40%); }
```

The `inset` highlight is the top-edge light catch; the `::before` gradient is the diagonal sheen.

Full runnable version: `assets/demos/liquid-glass-2d.html`.

## Cross-links

`displacement-distortion` (same `feTurbulence`/`feDisplacementMap` primitives, generalized); `liquid-glass-3d` when you need real refraction depth; `motion-fx-web` for the effect map.
