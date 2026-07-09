---
name: ae-track-mattes
description: Use when assigning track mattes (alpha/luma) or building pre-comp / sub-comp architecture in After Effects via script — layer parenting, naming, and reuse. Includes the expensive parenting-scale-bake bug and parent-relative coordinate math.
---

# AE Track Mattes & Compositing Architecture (Scripted)

## Track mattes

A track matte uses one layer to reveal/hide the layer directly below it. Assigned by layer order + matte type (alpha or luma). Alpha matte = the matte's transparency drives visibility; luma matte = its brightness does. Set the matte layer directly above its fill layer and assign the matte type on the fill layer.

## Pre-comp / sub-comp architecture

Create a pre-comp when a set of layers is reused, must animate as one unit, or exceeds ~10 layers doing one job. Name by **role**, never leave defaults:

- `BG/` background, `LOGO/` brand, `TEXT/` copy, `FX/` effects, `UI/` interface.
- A layer name should say what it is without opening it — never ship `"Shape Layer 34"`.

## The parenting-scale-bake bug (expensive)

`layer.parent = null` preserves the child's **world** transform by adjusting its scale. If the parent null has scale ≠ 100% at the current comp time (e.g. a pop-controller keyed `[34,34]` at t=0), the child gets `100/0.34 ≈ 294%` baked in → text wildly oversized.

**Fix — solvable only via script order:**
1. Parent **while the parent null is at 100%** (no keyframes yet).
2. Set the scale / pop keyframes on the null **after** all parenting is done.

## Parent-relative coordinates

Child parented to a null (anchor `[50,50]`) → child position becomes `world - parentPos + anchor`. For a centered child with vertical offset `dy`, set position `[50, 50 + dy]`.

## Cross-links

`compositing-architecture` (motion-craft) for the conceptual thinking behind structuring layers; `ae-doscript` for dispatch.
