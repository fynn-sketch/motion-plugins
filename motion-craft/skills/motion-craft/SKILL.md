---
name: motion-craft
description: Use when improving the overall quality or organic feel of ANY motion graphics / animation without a specific technique named — "make this animation more polished / organic / less cheap / less mechanical". Gives the mental map of which motion principle applies when, and translates it into the target runtime (HyperFrames, Remotion, GSAP). Routes to motion-easing, motion-principles, motion-timing, kinetic-typography, or compositing-architecture.
---

# Motion Craft

The difference between motion that looks cheap and motion that looks expensive is not the tool. It is craft: organic acceleration, believable weight, timing that lands, and structure you can control. This skill is the map. It tells you which principle applies and how to express it in the runtime you are actually building in.

**This is craft only.** Tool-bound techniques — match-moving, 3D camera tracking, expressions, Dynamic Link, MOGRT — belong to the future `motion-ae-bridge` plugin. Liquid Glass / refraction and concrete shape-morph internals belong to `motion-fx-web`. When a request needs those, say so and deliver the craft parts you can.

## Mental map — which skill applies

| Symptom | Skill |
|---|---|
| Motion feels stiff, mechanical, linear, "cheap" | **motion-easing** |
| A shape / logo / object feels dead, lifeless | **motion-principles** |
| Feels off-beat, mistimed, too fast or too slow, no rhythm | **motion-timing** |
| Text should carry / underline meaning | **kinetic-typography** |
| Project is sprawling, hundreds of layers, hard to manage | **compositing-architecture** |

Most "make it better" requests are a mix. Default order: fix **easing** first (biggest cheap-look win), then **timing**, then layer in **principles**.

## Runtime Bridge — translate the concept into the tool

| Concept | Remotion | GSAP | HyperFrames |
|---|---|---|---|
| Organic entrance ease | `spring({fps, frame, config:{damping:200, mass:1, stiffness:100}})` or `interpolate(frame,[a,b],[0,1],{easing: Easing.out(Easing.cubic)})` | `power2.out` / `power3.out` | GSAP-backed `power2.out` |
| Snappy exit | `interpolate(..., {easing: Easing.in(Easing.cubic)})` | `power2.in` | `power2.in` |
| Overshoot / pop | low-damping spring, e.g. `config:{damping:12, mass:0.6, stiffness:120}` | `back.out(1.7)` | `back.out(1.7)` |
| Constant loop (rotation, marquee) | linear `interpolate` (the one legit linear case) | `none` / `linear` | `linear` |

See **motion-easing** for the full curve catalogue and concrete values.

## Fynn's runtime rules (from CLAUDE.md — respect these)

- In headless Remotion rendering, drive animation with `useCurrentFrame()` interpolation — **never CSS keyframes**, which freeze in headless mode.
- Always confirm `interpolate()` `inputRange` arrays are **monotonically increasing** before use.
- Use the `@remotion/google-fonts` package, not Google Fonts CDN URLs.
- Before Node-based commands, verify `which node && node --version`; alert if missing instead of retrying installs.
