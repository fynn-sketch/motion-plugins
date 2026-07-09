---
name: motion-easing
description: Use when animation motion feels mechanical / linear / cheap, or when choosing easing curves, cubic-bezier, or spring physics for any animation. Covers why linear kills, ease-in/out/in-out, reading & building Bezier curves, spring physics (mass/stiffness/damping), and use-case → curve mapping with concrete values.
---

# Motion Easing

Easing is the single biggest lever between "cheap" and "expensive" motion. Get it right and even a plain fade reads as polished.

## Why linear kills

Nothing in the physical world moves at constant velocity from a standstill — objects accelerate and decelerate. Linear motion has no acceleration, so the eye reads it as mechanical, robotic, cheap. **The only legitimate use of linear is constant motion:** a continuously spinning element, a looping marquee scroll, a conveyor. Everything that starts or stops needs easing.

## The three families (with concrete cubic-bezier values)

- **ease-out** — fast start, slow settle. For things **arriving** (entrances, elements appearing, a value landing). `cubic-bezier(0.0, 0.0, 0.2, 1)`
- **ease-in** — slow start, fast end. For things **leaving** (exits, elements flying off, dismissals). `cubic-bezier(0.4, 0.0, 1, 1)`
- **ease-in-out** — ease both ends. For moves that **start and stop on screen** (repositioning, a card sliding across). `cubic-bezier(0.4, 0.0, 0.2, 1)`

Rule of thumb: entrances get ease-**out** (the audience should see the resting state quickly, then it gently settles); exits get ease-**in** (accelerate away).

## Spring physics

A spring is defined by three parameters:

- **mass** — heavier = slower to start and stop, more inertia.
- **stiffness** (tension) — higher = faster, snappier pull toward the target.
- **damping** (friction) — higher = less overshoot; **lower damping = more bounce/overshoot**.

Prefer a spring over a bezier when you want natural, physical, interruptible motion — logos popping in, UI elements with weight, anything that should feel alive rather than "played back". A critically-damped spring (no overshoot) is a great default entrance; drop the damping for a deliberate pop.

Concrete curve presets and per-use-case mappings are in `references/curves.md`.
