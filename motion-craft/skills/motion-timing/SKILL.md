---
name: motion-timing
description: Use when working on animation timing, rhythm, pacing, cutting to music, beat-mapping, hold times, or stagger/cascade sequencing. Covers frame budgets, pacing, mapping cuts to a beat, anticipation/hold durations, and staggered reveals.
---

# Motion Timing

Motion graphics live on rhythm. The right curve on a badly-timed move still feels wrong. All numbers below assume **30fps** — double them for 60fps.

## Frame budgets (@30fps)

| Move | Frames | Seconds |
|---|---|---|
| UI micro-move (hover, small shift) | 6–12 | 0.2–0.4s |
| Element entrance | 15–25 | 0.5–0.8s |
| Hold / read beat | 30–60 | 1–2s |
| Scene transition | 12–20 | 0.4–0.7s |

## Beat mapping (cut to music)

`frames per beat = 60 / bpm × fps`

Worked example: **120 bpm @30fps → 60/120 × 30 = 15 frames per beat.** Land key cuts, reveals, and accents on beat multiples (every 15, 30, 45 frames). Snapping hits to the beat is what makes a reel feel "produced" instead of arbitrary.

## Stagger / cascade

Reveal siblings with **2–4 frames** between them for a lively cascade. Smaller gaps read as one mass moving; larger gaps (8+ frames) read as a sequential list. Pick based on whether the group is one thing or many things.

## Anticipation & hold

- **Wind-up:** 2–4 frames of anticipation before a main move (ties to motion-principles → Anticipation).
- **Hold:** once something is revealed, hold it long enough to read — **minimum ~0.5s (15 frames @30fps)** — before the next move. Rushing past readable content is the most common pacing mistake.

## Cross-links

- Pair with Fynn's **audio-reactive HyperFrames** work for actual beat sync.
- Pair with **motion-easing** for the curve on each timed move — timing sets *how long*, easing sets *how it feels* getting there.
