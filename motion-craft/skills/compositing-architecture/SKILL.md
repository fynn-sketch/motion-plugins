---
name: compositing-architecture
description: Use when structuring a complex animation project into layers and sub-compositions — naming, reuse, and keeping oversight across many layers, whether in After Effects, HyperFrames, or Remotion. The thinking for organizing hundreds of layers without losing control.
---

# Compositing Architecture

Complex animations are hundreds of layers. The difference between a maintainable project and chaos is structure — the same discipline whether you're nesting AE comps, composing Remotion components, or sequencing HyperFrames scenes.

## When to make a sub-composition

Group a set of layers into a sub-comp / component / scene when it:

1. **Is reused** — the same element appears more than once → build once, reference many.
2. **Moves as one unit** — you need to transform or animate the group together (scale, fade, offset the whole thing).
3. **Exceeds ~10 layers doing one conceptual job** — pre-comp it to keep the parent readable.

## Naming

Name by **role**, never leave defaults. Prefix by function and number scenes:

- `BG/` background, `LOGO/` brand, `TEXT/` copy, `FX/` effects, `UI/` interface.
- Scenes numbered: `01_Intro`, `02_Problem`, `03_Solution`.
- Never ship "Shape Layer 34" or "Comp 7". A layer name should tell you what it is without opening it.

## Reuse over copy-paste

Build the element once and reference it: Remotion components with props, HyperFrames reusable scenes, AE sub-comps instanced across the timeline. Copy-paste is how a project rots — one change means editing twenty copies.

## Bridge note

This structural thinking is the foundation the later plugins build on: **motion-ae-bridge** (Plugin 2) for AE sub-comps and pre-comping, **motion-fx-web** (Plugin 3) for composing web-native effect layers. Get the architecture right here and both inherit it.
