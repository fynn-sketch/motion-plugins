---
description: Review an existing animation (description, code, or file) against motion-craft principles and return prioritized, concrete fixes.
---

# /motion-review

Review the target animation against the motion-craft principles and return prioritized, concrete fixes. **Do not render anything.**

## Target

The thing to review is in `$ARGUMENTS` — it may be a plain-language description, a file path, or pasted code. If `$ARGUMENTS` is empty, ask what to review (description, path, or code) before continuing.

## Review axes

Check the target systematically against these four axes. For each, invoke the matching skill to ground the judgement:

1. **Easing** (→ `motion-easing`) — Is any motion linear or mechanical? Are entrances ease-out, exits ease-in? Would a spring read more organically?
2. **Principles** (→ `motion-principles`) — Is anticipation missing (abrupt starts)? Follow-through (everything stops on one frame)? Arcs (dead-straight paths)? Scan the 12 for what's absent.
3. **Timing** (→ `motion-timing`) — Off-beat? Too fast to read or too slow? Missing holds? If music/VO is involved, are hits on the beat?
4. **Staging & readability** (→ `kinetic-typography` when text is involved) — Is the focal point clear? One idea per beat? Is text legible and resolved to a stable state?

## Output

Return a **prioritized** list, highest-impact fix first. Each item states the **concrete change** — a specific curve value, a frame count, the principle to add — not vague advice like "improve the easing". Group nothing; just the ranked fixes with what to do.
