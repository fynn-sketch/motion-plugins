# motion-craft Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build `motion-craft`, a Claude Code plugin that acts as a tool-agnostic motion-design knowledge layer (five focused skills + one review command) so Claude produces organic, principled motion in any runtime.

**Architecture:** A plugin under `~/Developer/motion-craft/` containing a `.claude-plugin/plugin.json` manifest, five skills (`motion-craft` umbrella + `motion-easing`, `motion-principles`, `motion-timing`, `kinetic-typography`, `compositing-architecture`), and a `/motion-review` command. No code logic; content is Markdown with sharp trigger frontmatter. Verification is by manifest validity, file presence, and trigger/content spot-checks.

**Tech Stack:** Markdown skill files (`SKILL.md` with YAML frontmatter), JSON manifest, Claude Code plugin format. No Node required.

---

## File Structure

```
~/Developer/motion-craft/
├── .claude-plugin/plugin.json
├── skills/
│   ├── motion-craft/SKILL.md
│   ├── motion-easing/SKILL.md
│   ├── motion-easing/references/curves.md
│   ├── motion-principles/SKILL.md
│   ├── motion-principles/references/twelve-principles.md
│   ├── motion-timing/SKILL.md
│   ├── kinetic-typography/SKILL.md
│   └── compositing-architecture/SKILL.md
├── commands/motion-review.md
└── docs/
    ├── specs/2026-07-09-motion-craft-design.md   (exists)
    └── plans/2026-07-09-motion-craft.md          (this file)
```

Verification note: there is no automated test framework for Markdown skills. Each task's "verify" step is a concrete manual/CLI check. Frontmatter `description` fields are copied **verbatim** — they drive triggering and must not be paraphrased.

---

### Task 1: Plugin manifest

**Files:**
- Create: `~/Developer/motion-craft/.claude-plugin/plugin.json`

- [ ] **Step 1: Write the manifest**

```json
{
  "name": "motion-craft",
  "version": "0.1.0",
  "description": "Tool-agnostic motion-design knowledge layer: easing, the 12 principles, timing & pacing, kinetic typography, and compositing architecture — makes any runtime (HyperFrames, Remotion, GSAP) produce organic, principled motion.",
  "author": { "name": "Fynn Ignacczak" }
}
```

- [ ] **Step 2: Verify it is valid JSON**

Run: `python3 -c "import json,sys; json.load(open('$HOME/Developer/motion-craft/.claude-plugin/plugin.json')); print('valid')"`
Expected: `valid`

- [ ] **Step 3: Commit** (only if the repo has been git-initialized and Fynn approved git)

```bash
cd ~/Developer/motion-craft && git add .claude-plugin/plugin.json && git commit -m "feat: add motion-craft plugin manifest"
```

---

### Task 2: Umbrella skill `motion-craft`

**Files:**
- Create: `~/Developer/motion-craft/skills/motion-craft/SKILL.md`

- [ ] **Step 1: Write SKILL.md**

Frontmatter (verbatim):

```yaml
---
name: motion-craft
description: Use when improving the overall quality or organic feel of ANY motion graphics / animation without a specific technique named — "make this animation more polished / organic / less cheap / less mechanical". Gives the mental map of which motion principle applies when, and translates it into the target runtime (HyperFrames, Remotion, GSAP). Routes to motion-easing, motion-principles, motion-timing, kinetic-typography, or compositing-architecture.
---
```

Body must contain, in this order:

1. **Mental map** — a short decision guide: "motion feels stiff/cheap → motion-easing; shape/logo/object feels dead → motion-principles; feels off-beat / mistimed → motion-timing; text should carry meaning → kinetic-typography; project sprawling / hard to manage → compositing-architecture."
2. **Runtime Bridge** table mapping a concept to each runtime. Must include these concrete rows:
   - Organic entrance ease → Remotion: `spring({fps, frame, config:{damping:200,mass:1,stiffness:100}})` or `interpolate(...,{easing:Easing.out(Easing.cubic)})`; GSAP: `power2.out`; HyperFrames: GSAP-backed `power2.out`.
   - Snappy exit → Remotion `Easing.in(Easing.cubic)`; GSAP `power2.in`.
   - Overshoot/pop → Remotion low-damping spring; GSAP `back.out(1.7)`.
3. **Fynn's runtime rules** (reference his CLAUDE.md): use `useCurrentFrame()` interpolation, never CSS keyframes, in headless Remotion; `inputRange` arrays must be monotonically increasing; use `@remotion/google-fonts`.
4. **Scope note:** tool-bound techniques (tracking, expressions, Dynamic Link, MOGRT) belong to the future `motion-ae-bridge` plugin; Liquid Glass / shape-morph internals to `motion-fx-web`. This skill covers craft only.

- [ ] **Step 2: Verify frontmatter parses and description is present**

Run: `python3 -c "import re; t=open('$HOME/Developer/motion-craft/skills/motion-craft/SKILL.md').read(); assert t.startswith('---'); assert 'description:' in t.split('---')[1]; print('ok')"`
Expected: `ok`

- [ ] **Step 3: Commit** (if git in use)

```bash
cd ~/Developer/motion-craft && git add skills/motion-craft/SKILL.md && git commit -m "feat: add motion-craft umbrella skill with runtime bridge"
```

---

### Task 3: `motion-easing` skill + references

**Files:**
- Create: `~/Developer/motion-craft/skills/motion-easing/SKILL.md`
- Create: `~/Developer/motion-craft/skills/motion-easing/references/curves.md`

- [ ] **Step 1: Write SKILL.md**

Frontmatter (verbatim):

```yaml
---
name: motion-easing
description: Use when animation motion feels mechanical / linear / cheap, or when choosing easing curves, cubic-bezier, or spring physics for any animation. Covers why linear kills, ease-in/out/in-out, reading & building Bezier curves, spring physics (mass/stiffness/damping), and use-case → curve mapping with concrete values.
---
```

Body must contain:
1. **Why linear kills** — real motion accelerates and decelerates; linear reads as mechanical. Only exception: constant motion (continuous rotation, marquee scroll).
2. **The three families** with concrete cubic-bezier values:
   - ease-out (entrances, things arriving): `cubic-bezier(0.0, 0.0, 0.2, 1)`
   - ease-in (exits, things leaving): `cubic-bezier(0.4, 0.0, 1, 1)`
   - ease-in-out (moves that start and stop on screen): `cubic-bezier(0.4, 0.0, 0.2, 1)`
3. **Spring physics** — mass, stiffness, damping; higher stiffness = faster, lower damping = more overshoot. Note Remotion `config:{mass,damping,stiffness}` and when to prefer a spring over a bezier (natural, interruptible, physical objects).
4. Pointer: "Concrete curve presets and per-use-case mappings in `references/curves.md`."

- [ ] **Step 2: Write references/curves.md**

Must contain a table: use-case → recommended curve → concrete values across CSS bezier / GSAP ease / Remotion. Rows at minimum: UI element enter, UI element exit, modal/overlay, logo pop, number counter, camera/pan move, looping rotation (→ linear, the one legit case). Include a GSAP quick list: `power2.out`, `power3.out`, `expo.out`, `back.out(1.7)`, `elastic.out(1,0.3)` with one-line "use when".

- [ ] **Step 3: Verify both files exist and frontmatter parses**

Run: `python3 -c "import os,re; b='$HOME/Developer/motion-craft/skills/motion-easing/'; assert os.path.exists(b+'SKILL.md') and os.path.exists(b+'references/curves.md'); t=open(b+'SKILL.md').read(); assert 'description:' in t.split('---')[1]; print('ok')"`
Expected: `ok`

- [ ] **Step 4: Commit** (if git in use)

```bash
cd ~/Developer/motion-craft && git add skills/motion-easing && git commit -m "feat: add motion-easing skill with curve references"
```

---

### Task 4: `motion-principles` skill + references

**Files:**
- Create: `~/Developer/motion-craft/skills/motion-principles/SKILL.md`
- Create: `~/Developer/motion-craft/skills/motion-principles/references/twelve-principles.md`

- [ ] **Step 1: Write SKILL.md**

Frontmatter (verbatim):

```yaml
---
name: motion-principles
description: Use when animating shapes, logos, characters, or objects that need to feel alive — applies the 12 principles of animation (squash & stretch, anticipation, follow-through & overlapping action, arcs, staging, etc.) as actionable checklists: how to spot when a principle is missing and how to add it.
---
```

Body must contain:
1. One-line framing: "The 12 principles are the difference between a shape moving and a shape being alive."
2. A **quick checklist** naming all 12 principles so Claude can scan them: Squash & Stretch, Anticipation, Staging, Straight-Ahead vs. Pose-to-Pose, Follow-Through & Overlapping Action, Slow In & Slow Out, Arcs, Secondary Action, Timing, Exaggeration, Solid Drawing, Appeal.
3. Pointer to `references/twelve-principles.md` for the per-principle detail.

- [ ] **Step 2: Write references/twelve-principles.md**

Each of the 12 principles gets: **name**, one-line definition, **"missing when…"** (observable symptom), **"add it by…"** (concrete action). Example row content to include for at least these three so the format is unmistakable:
- Anticipation — "small opposite move before the main action." Missing when: motion starts abruptly from rest. Add it by: 2-4 frames of counter-movement/wind-up before the main move.
- Follow-Through & Overlapping Action — "parts keep moving after the object stops; parts move at different rates." Missing when: everything stops on the same frame. Add it by: let trailing elements settle 2-6 frames later, stagger their stop.
- Slow In & Slow Out — "ease around keyframes." Missing when: constant velocity between poses. Add it by: apply ease-out/in (see motion-easing).

Fill the remaining nine in the same three-line format.

- [ ] **Step 3: Verify files exist and all 12 principle names appear in references**

Run: `python3 -c "b='$HOME/Developer/motion-craft/skills/motion-principles/'; t=open(b+'references/twelve-principles.md').read().lower(); names=['squash','anticipation','staging','pose-to-pose','follow-through','slow in','arcs','secondary','timing','exaggeration','solid drawing','appeal']; missing=[n for n in names if n not in t]; assert not missing, missing; print('all 12 present')"`
Expected: `all 12 present`

- [ ] **Step 4: Commit** (if git in use)

```bash
cd ~/Developer/motion-craft && git add skills/motion-principles && git commit -m "feat: add motion-principles skill with 12-principles checklist"
```

---

### Task 5: `motion-timing` skill

**Files:**
- Create: `~/Developer/motion-craft/skills/motion-timing/SKILL.md`

- [ ] **Step 1: Write SKILL.md**

Frontmatter (verbatim):

```yaml
---
name: motion-timing
description: Use when working on animation timing, rhythm, pacing, cutting to music, beat-mapping, hold times, or stagger/cascade sequencing. Covers frame budgets, pacing, mapping cuts to a beat, anticipation/hold durations, and staggered reveals.
---
```

Body must contain concrete numbers (assume 30fps, note how to scale to 60):
1. **Frame budgets @30fps:** UI micro-move 6–12f; element entrance 15–25f; hold/read beat 30–60f; scene transition 12–20f.
2. **Beat mapping:** frames-per-beat = `60 / bpm * fps`. Worked example: 120 bpm @30fps → 15 frames per beat; land key cuts/reveals on beat multiples.
3. **Stagger/cascade:** 2–4 frames between siblings for a lively cascade; larger gaps read as a list, smaller as one mass.
4. **Anticipation/hold:** wind-up 2–4f; hold a revealed element long enough to read (min ~0.5s = 15f @30fps) before the next move.
5. Cross-link: pair with Fynn's audio-reactive HyperFrames work for beat sync; pair with motion-easing for the curve on each timed move.

- [ ] **Step 2: Verify frontmatter parses**

Run: `python3 -c "t=open('$HOME/Developer/motion-craft/skills/motion-timing/SKILL.md').read(); assert 'description:' in t.split('---')[1]; print('ok')"`
Expected: `ok`

- [ ] **Step 3: Commit** (if git in use)

```bash
cd ~/Developer/motion-craft && git add skills/motion-timing/SKILL.md && git commit -m "feat: add motion-timing skill"
```

---

### Task 6: `kinetic-typography` skill

**Files:**
- Create: `~/Developer/motion-craft/skills/kinetic-typography/SKILL.md`

- [ ] **Step 1: Write SKILL.md**

Frontmatter (verbatim):

```yaml
---
name: kinetic-typography
description: Use when animating text so the motion reinforces meaning — kinetic typography for reels, explainer videos, PR messages, and social content. Covers emphasis hierarchy, timing text to the spoken word, one focal idea per beat, and readability vs. effect. The thinking behind word animation, not the GSAP how.
---
```

Body must contain:
1. **Core rule:** the animation should mean what the word means — motion underlines the message, it does not decorate it.
2. **One focal idea per beat:** emphasize a single word/phrase at a time via scale, weight, or color; everything else stays quiet.
3. **Timing to the spoken word:** key word lands on its VO syllable; keep each phrase on-screen long enough to read (link to motion-timing hold budgets).
4. **Readability vs. effect:** if the effect hurts legibility, the effect loses; entrance should resolve to a stable, readable state.
5. Cross-link: defer visual style (fonts, colors, sizes, sub-bar) to Fynn's existing Reel-Untertitel Style Guide; this skill is the *thinking*, not the styling.

- [ ] **Step 2: Verify frontmatter parses**

Run: `python3 -c "t=open('$HOME/Developer/motion-craft/skills/kinetic-typography/SKILL.md').read(); assert 'description:' in t.split('---')[1]; print('ok')"`
Expected: `ok`

- [ ] **Step 3: Commit** (if git in use)

```bash
cd ~/Developer/motion-craft && git add skills/kinetic-typography/SKILL.md && git commit -m "feat: add kinetic-typography skill"
```

---

### Task 7: `compositing-architecture` skill

**Files:**
- Create: `~/Developer/motion-craft/skills/compositing-architecture/SKILL.md`

- [ ] **Step 1: Write SKILL.md**

Frontmatter (verbatim):

```yaml
---
name: compositing-architecture
description: Use when structuring a complex animation project into layers and sub-compositions — naming, reuse, and keeping oversight across many layers, whether in After Effects, HyperFrames, or Remotion. The thinking for organizing hundreds of layers without losing control.
---
```

Body must contain:
1. **Pre-comp / sub-composition rule:** group into a sub-comp when a set of layers (a) is reused, (b) needs to be transformed/animated as one unit, or (c) exceeds ~10 layers doing one conceptual job.
2. **Naming convention:** name by role not default (`BG/`, `LOGO/`, `TEXT/`, `FX/` prefixes); number scenes; never ship "Shape Layer 34".
3. **Reuse:** build once, reference many (Remotion components, HyperFrames scenes, AE sub-comps) instead of copy-paste.
4. **Bridge note:** this thinking carries into `motion-ae-bridge` (Plugin 2, AE sub-comps) and `motion-fx-web` (Plugin 3) — it is the structural foundation both build on.

- [ ] **Step 2: Verify frontmatter parses**

Run: `python3 -c "t=open('$HOME/Developer/motion-craft/skills/compositing-architecture/SKILL.md').read(); assert 'description:' in t.split('---')[1]; print('ok')"`
Expected: `ok`

- [ ] **Step 3: Commit** (if git in use)

```bash
cd ~/Developer/motion-craft && git add skills/compositing-architecture/SKILL.md && git commit -m "feat: add compositing-architecture skill"
```

---

### Task 8: `/motion-review` command

**Files:**
- Create: `~/Developer/motion-craft/commands/motion-review.md`

- [ ] **Step 1: Write the command file**

Frontmatter (verbatim):

```yaml
---
description: Review an existing animation (description, code, or file) against motion-craft principles and return prioritized, concrete fixes.
---
```

Body must instruct Claude to:
1. Take the target from `$ARGUMENTS` (a description, a path, or pasted code); if none given, ask what to review.
2. Check it systematically against four axes, invoking the matching skill for each: **Easing** (mechanical/linear? → motion-easing), **Principles** (anticipation / follow-through / arcs missing? → motion-principles), **Timing** (off-beat, too fast/slow, no holds? → motion-timing), **Staging & readability** (focal clarity, text legible? → kinetic-typography where text is involved).
3. Return a **prioritized** list of fixes (highest-impact first), each with the concrete change to make (curve value, frame count, principle to add) — not vague advice.
4. Not render anything.

- [ ] **Step 2: Verify frontmatter parses**

Run: `python3 -c "t=open('$HOME/Developer/motion-craft/commands/motion-review.md').read(); assert 'description:' in t.split('---')[1]; print('ok')"`
Expected: `ok`

- [ ] **Step 3: Commit** (if git in use)

```bash
cd ~/Developer/motion-craft && git add commands/motion-review.md && git commit -m "feat: add /motion-review command"
```

---

### Task 9: Install & end-to-end verification

**Files:** none created.

- [ ] **Step 1: Confirm full file tree**

Run: `cd ~/Developer/motion-craft && find . -type f -not -path './.git/*' | sort`
Expected: manifest, five `SKILL.md`, two `references/*.md`, `commands/motion-review.md`, and the two docs files — matching the File Structure above.

- [ ] **Step 2: Validate every SKILL.md + command has a name/description frontmatter**

Run:
```bash
python3 - <<'PY'
import glob,os
base=os.path.expanduser('~/Developer/motion-craft')
for f in glob.glob(base+'/skills/*/SKILL.md')+glob.glob(base+'/commands/*.md'):
    t=open(f).read(); assert t.startswith('---'), f; fm=t.split('---')[1]; assert 'description:' in fm, f
print('all frontmatter ok')
PY
```
Expected: `all frontmatter ok`

- [ ] **Step 3: Install the plugin locally**

In an interactive Claude Code session, add the local dir as a plugin (e.g. via `/plugin` → install from `~/Developer/motion-craft/`). Note: this step is manual and interactive; the agent should hand it to Fynn if not in an interactive session.
Expected: `motion-craft` appears with 5 skills and the `/motion-review` command.

- [ ] **Step 4: Trigger spot-check (manual reasoning)**

For each skill, confirm its `description` would fire on its intended prompt and not on the others — e.g. "make this reel feel less cheap" → `motion-craft`/`motion-easing`; "animate this headline word by word" → `kinetic-typography`; "cut this to the beat" → `motion-timing`. Fix any description that over/under-triggers.

- [ ] **Step 5: Final commit** (if git in use)

```bash
cd ~/Developer/motion-craft && git add -A && git commit -m "chore: complete motion-craft v0.1.0"
```

---

## Self-Review (completed by plan author)

- **Spec coverage:** manifest (Task 1); umbrella + runtime bridge (Task 2); easing (3); 12 principles (4); timing (5); kinetic typography (6); compositing (7); `/motion-review` (8); install/verify incl. install-test (9). All spec sections covered.
- **Placeholder scan:** no TBD/TODO; every skill has verbatim frontmatter and concrete required content (bezier values, frame budgets, beat formula, 12-principle format).
- **Type/name consistency:** skill folder names, `name:` fields, and cross-references (`motion-easing`, `motion-principles`, `motion-timing`, `kinetic-typography`, `compositing-architecture`, `/motion-review`) are consistent across all tasks.
- **Adaptation note:** Markdown skills have no unit tests; TDD steps are replaced by concrete "verify" checks (JSON validity, file presence, frontmatter parse, 12-principle presence, trigger spot-check). Git commits are conditional on Fynn approving git init.
