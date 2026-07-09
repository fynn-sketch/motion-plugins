---
name: masking-blend
description: Use when making one layer reveal or hide through another on the web — the web equivalent of After Effects track mattes. Covers CSS mask / -webkit-mask (alpha & luminance), mask-composite, animatable clip-path, background-clip:text, and mix-blend-mode, for reveals, wipes, and transitions.
---

# Masking & Blend (Web Track Mattes)

The web equivalent of AE track mattes: use one layer to reveal/hide another.

## Alpha / luminance mask

```css
.el {
  -webkit-mask: linear-gradient(90deg, transparent, #000 30%, #000 70%, transparent);
          mask: linear-gradient(90deg, transparent, #000 30%, #000 70%, transparent);
  /* mask-mode: luminance;  <- switch from alpha to luminance matte */
}
```
A gradient or PNG/SVG as the mask = an alpha matte. `mask-mode: luminance` turns it into a luma matte (brightness drives visibility) — the direct analogue of AE's luma track matte.

## Image through text

```css
.text-mask {
  background: url(pic.jpg) center/cover;
  -webkit-background-clip: text; background-clip: text; color: transparent;
}
```

## Animatable wipe (clip-path)

```css
.wipe { clip-path: inset(0 60% 0 0); transition: clip-path .6s cubic-bezier(.4,0,.2,1); }
.wipe.open { clip-path: inset(0 0 0 0); }
```
`clip-path` (inset/polygon/circle) is animatable → wipes and directional reveals.

## Combining masks

`mask-composite: intersect | exclude | add | subtract` (`-webkit-mask-composite` uses `source-in` etc.) combines multiple mask layers — e.g. a shape minus a hole.

## Blend

`mix-blend-mode: overlay | screen | multiply | difference` blends a layer into what's behind it — for glows, knockout text, duotone.

Full runnable version: `assets/demos/masking-blend.html`.

## Cross-links

`ae-track-mattes` (motion-ae-bridge) — same idea in the AE runtime; `motion-fx-web` for the map.
