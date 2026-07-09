---
name: kinetic-typography
description: Use when animating text so the motion reinforces meaning — kinetic typography for reels, explainer videos, PR messages, and social content. Covers emphasis hierarchy, timing text to the spoken word, one focal idea per beat, and readability vs. effect. The thinking behind word animation, not the GSAP how.
---

# Kinetic Typography

The point of animating text is not decoration — it is **meaning**. Motion should underline what the word says. A word like "grow" scales up; "drop" falls; "fast" whips in and settles. If the animation doesn't reinforce the message, it's noise.

## Core rules

**1. Motion means what the word means.** Match the verb to the movement. When in doubt, ask: what does this word *do*? Then make it do that.

**2. One focal idea per beat.** Emphasize a single word or phrase at a time — via scale, weight, or color — while everything else stays quiet. If three words shout at once, none of them land. This is Staging (motion-principles) applied to text.

**3. Timing to the spoken word.** The key word lands on its syllable in the voiceover. Keep each phrase on screen long enough to read — reuse motion-timing's hold budgets (min ~0.5s / 15 frames @30fps per readable phrase). Text that outruns the read is the most common failure.

**4. Readability beats effect.** If the effect hurts legibility, the effect loses. Entrances should *resolve* to a stable, fully readable state — animate *into* clarity, don't leave the word mid-blur.

## Cross-links

- **Visual style** (fonts, colors, sizes, sub-bar treatment) is defined by Fynn's existing **Reel-Untertitel Style Guide** — defer to it. This skill is the *thinking*, not the styling.
- **motion-timing** for hold durations and beat-mapping to the VO.
- **motion-easing** for the curve each word rides in on.
