---
name: displacement-distortion
description: Use when building warp/distortion effects on the web — water ripple, smoke, heat haze, glitch — with SVG feTurbulence + feDisplacementMap. Covers fractalNoise vs turbulence, octaves, animating baseFrequency/scale via SMIL or JS/GSAP.
---

# Displacement & Distortion

Warp any element by generating noise (`feTurbulence`) and pushing pixels along it (`feDisplacementMap`).

## The filter

```html
<filter id="warp">
  <feTurbulence type="fractalNoise" baseFrequency="0.012 0.02" numOctaves="2" seed="3" result="n"/>
  <feDisplacementMap in="SourceGraphic" in2="n" scale="26" xChannelSelector="R" yChannelSelector="G"/>
</filter>
```
Apply with `filter: url(#warp);`.

- **`type`** — `fractalNoise` = soft, cloudy (water, smoke); `turbulence` = sharper, veiny (fire, marble).
- **`baseFrequency`** — small = large slow waves; large = fine ripples. Two values = x/y anisotropy.
- **`numOctaves`** — detail layers; 1–2 is usually enough (higher = slower).
- **`scale`** (on displacement) — warp strength in px.

## Animating it

SMIL for a self-running loop (water):
```html
<feTurbulence ... >
  <animate attributeName="baseFrequency" dur="14s"
    values="0.012 0.02;0.016 0.024;0.012 0.02" repeatCount="indefinite"/>
</feTurbulence>
```
Or drive it from JS/GSAP for scriptable/frame-locked control:
```js
gsap.to('#warp feDisplacementMap', { attr: { scale: 40 }, duration: .3, yoyo: true, repeat: 5 }); // glitch burst
```

## Presets

- **Water:** `fractalNoise`, low freq, `scale` ~24, animate `baseFrequency` slowly.
- **Heat haze:** low freq, small `scale` (~6), animate subtly, vertical bias.
- **Glitch:** high freq, animate `scale` in short bursts (GSAP, `repeat`).

Full runnable version: `assets/demos/displacement-distortion.html`.

## Cross-links

`liquid-glass-2d` (uses the same primitives for the refracting edge); `motion-fx-web` for the map.
