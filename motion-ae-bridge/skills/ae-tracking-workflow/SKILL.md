---
name: ae-tracking-workflow
description: Use when integrating text or objects into real footage in After Effects — 3D camera tracking, planar/Mocha tracking, match-moving, or Dynamic Link to Premiere. These are NOT scriptable; this is a guided step-by-step GUI workflow plus the match-moving craft, not automation.
---

# AE Tracking & Match-Moving — Guided GUI Workflow

**Honesty first:** AE's 3D Camera Tracker, Point/Planar Tracker, and Dynamic Link have **no usable scripting API**. This skill guides the GUI and the craft. It does **not** automate. Don't promise headless tracking — it doesn't exist.

## 3D Camera Tracker (moving camera, integrate into a shot)

1. Select the footage layer → Effect → Perspective → **3D Camera Tracker**.
2. Let it **analyze** (background pass; wait for "Solving Camera").
3. Hover the track points until you find a solid plane; the target (bullseye) appears.
4. Right-click the target → **Create Camera and Text** (or Null + Camera).
5. Parent your text/object to the created element so it inherits the solved camera motion.

## Planar / Mocha (flat surfaces: signs, screens, walls)

Prefer planar tracking when the surface is flat and you want a screen replacement or a label stuck to a plane. Track the plane in Mocha → export the corner-pin / transform → apply to your layer. More stable than point tracking on flat, low-detail surfaces.

## Match-moving craft (what makes it "stick")

- **Parent to the tracked null**, don't hand-animate.
- **Match motion blur** — real footage has it; add it to the inserted layer or it reads as pasted-on.
- **Respect perspective and scale** — the object must sit in the solved 3D space, not float.
- **Ground it** — a contact shadow or reflection sells the integration.
- See `motion-principles` (Arcs, Solid Drawing) in motion-craft for why these read as believable.

## Dynamic Link (Premiere ↔ AE)

A **manual** step: in Premiere, "Replace with After Effects Composition", or import the AE comp via Dynamic Link. No scripting API — treat it as a hand workflow between the two apps.

## Optional assist

The computer-use MCP can help click through these GUI steps, but there is **no automation guarantee** — tracking analysis is interactive and visual.
