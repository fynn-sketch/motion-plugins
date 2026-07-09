# motion-fx-web Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build `motion-fx-web`, a Claude Code plugin of runnable web-native motion-effect recipes — liquid glass 2D+3D, shape-morphing, masking/blend, displacement — with an umbrella skill covering the WebGL-headless-render recipe, standalone HTML demos, and a `/fx-demo` command.

**Architecture:** Plugin under `~/Developer/motion-fx-web/`. Six skills (umbrella + 5 effects), each carrying real copy-paste code; 2D/SVG effects ship standalone `assets/demos/*.html`; 3D ships as three-via-ESM-CDN code in the skill. References motion-craft (craft) and the existing three/shape-morph/gsap skills instead of duplicating.

**Tech Stack:** Markdown skills, HTML/CSS/SVG, three.js (ESM CDN), JSON manifest. Standalone demos need no Node.

---

## File Structure

```
~/Developer/motion-fx-web/
├── .claude-plugin/plugin.json
├── skills/
│   ├── motion-fx-web/SKILL.md
│   ├── liquid-glass-2d/SKILL.md
│   ├── liquid-glass-3d/SKILL.md
│   ├── shape-morphing/SKILL.md
│   ├── masking-blend/SKILL.md
│   └── displacement-distortion/SKILL.md
├── assets/demos/{liquid-glass-2d,masking-blend,displacement-distortion}.html
├── commands/fx-demo.md
├── .gitignore
└── docs/{specs,plans}/…
```

Verification: no automated test framework. Verify steps = JSON validity, frontmatter parse, HTML well-formedness (python `html.parser`), and grep for required code. Git commits assume repo initialized. Frontmatter verbatim.

---

### Task 1: Repo, manifest, .gitignore

**Files:** Create `.claude-plugin/plugin.json`, `.gitignore`

- [ ] **Step 1: Init**
```bash
cd ~/Developer/motion-fx-web && git init -q && git branch -m main 2>/dev/null
mkdir -p .claude-plugin skills/motion-fx-web skills/liquid-glass-2d skills/liquid-glass-3d skills/shape-morphing skills/masking-blend skills/displacement-distortion assets/demos commands
printf '.DS_Store\n' > .gitignore
```

- [ ] **Step 2: `plugin.json`**
```json
{
  "name": "motion-fx-web",
  "version": "0.1.0",
  "description": "Runnable web-native motion-effect recipes — liquid glass (2D CSS/SVG + 3D three.js refraction), advanced SVG shape-morphing, masking & blend (web track mattes), and displacement/distortion — with a WebGL-headless render recipe for reels. Third of the motion-* series.",
  "author": { "name": "Fynn Ignacczak" }
}
```

- [ ] **Step 3: Verify + commit**
```bash
cd ~/Developer/motion-fx-web && python3 -c "import json; json.load(open('.claude-plugin/plugin.json')); print('valid')"
git add -A && git -c user.name="Fynn Ignacczak" -c user.email="ignacczakfynn@gmail.com" commit -q -m "chore: init motion-fx-web, manifest"
```
Expected: `valid`

---

### Task 2: Umbrella skill `motion-fx-web`

**Files:** Create `skills/motion-fx-web/SKILL.md`

- [ ] **Step 1: Write SKILL.md**

Frontmatter (verbatim):
```yaml
---
name: motion-fx-web
description: Use when choosing or building a web-native visual effect (liquid glass, refraction, shape morph, masking, displacement) for HyperFrames or the web, or when getting three.js/WebGL to render inside a headless reel. Gives the effect map and the WebGL-headless render recipe; routes to the effect skills.
---
```

Body must contain:
1. **Effect map** table: glassy translucent surface → `liquid-glass-2d` (light) or `liquid-glass-3d` (photoreal); layer-reveals-through-layer → `masking-blend`; icon/blob transitions → `shape-morphing`; water/smoke/warp → `displacement-distortion`.
2. **WebGL-headless render recipe** (concrete): in Playwright/headless Chromium, launch with `--use-gl=angle --use-angle=swiftshader --enable-webgl --ignore-gpu-blocklist`; create renderer `new THREE.WebGLRenderer({ preserveDrawingBuffer: true, antialias: true })`; drive animation by an injected **frame index**, not `Date.now()` (deterministic, like Remotion `useCurrentFrame()`); set `window.__frameRendered = false` before each frame and `= true` in the render callback so Playwright waits for it before capturing. Note SwiftShader is software → slow but deterministic; fallback to `liquid-glass-2d` if 3D misbehaves.
3. Cross-links: `motion-craft` for easing/timing; `three` and `gsap` skills for the runtimes.

- [ ] **Step 2: Verify + commit**
```bash
cd ~/Developer/motion-fx-web && python3 -c "t=open('skills/motion-fx-web/SKILL.md').read(); assert 'description:' in t.split('---')[1]; assert 'swiftshader' in t.lower() and 'preserveDrawingBuffer' in t; print('ok')"
git add skills/motion-fx-web/SKILL.md && git -c user.name="Fynn Ignacczak" -c user.email="ignacczakfynn@gmail.com" commit -q -m "feat: add motion-fx-web umbrella skill with WebGL-headless recipe"
```
Expected: `ok`

---

### Task 3: `liquid-glass-2d` skill + demo

**Files:** Create `skills/liquid-glass-2d/SKILL.md`, `assets/demos/liquid-glass-2d.html`

- [ ] **Step 1: Write the demo `assets/demos/liquid-glass-2d.html`**

```html
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Liquid Glass 2D</title>
<style>
  body { margin:0; min-height:100vh; display:grid; place-items:center;
    background:url('https://images.unsplash.com/photo-1502134249126-9f3755a50d78?w=1200') center/cover fixed, #123; font-family:system-ui; }
  .glass {
    width:340px; padding:32px; border-radius:28px; color:#fff;
    background:rgba(255,255,255,.12);
    backdrop-filter:blur(14px) saturate(160%);
    -webkit-backdrop-filter:blur(14px) saturate(160%);
    border:1px solid rgba(255,255,255,.35);
    box-shadow:0 8px 32px rgba(0,0,0,.35), inset 0 1px 0 rgba(255,255,255,.5);
    filter:url(#glassEdge);
    position:relative; overflow:hidden;
  }
  .glass::before { content:""; position:absolute; inset:0; border-radius:inherit;
    background:linear-gradient(135deg, rgba(255,255,255,.5), rgba(255,255,255,0) 40%); pointer-events:none; }
  h1 { margin:0 0 8px; font-size:22px; } p { margin:0; opacity:.85; }
</style>
</head>
<body>
  <svg width="0" height="0"><filter id="glassEdge">
    <feTurbulence type="fractalNoise" baseFrequency="0.008 0.012" numOctaves="2" seed="7" result="noise"/>
    <feDisplacementMap in="SourceGraphic" in2="noise" scale="10" xChannelSelector="R" yChannelSelector="G"/>
  </filter></svg>
  <div class="glass"><h1>Liquid Glass</h1><p>backdrop-filter + SVG refraction edge + specular sheen.</p></div>
</body>
</html>
```

- [ ] **Step 2: Write SKILL.md**

Frontmatter (verbatim):
```yaml
---
name: liquid-glass-2d
description: Use when building the Apple "Liquid Glass" / glassmorphism look in 2D for the web or HyperFrames — frosted translucency, a refracting edge, and a specular sheen with pure CSS + SVG (no WebGL). Renders cleanly in headless reels.
---
```
Body must contain: the three ingredients with real values — (1) `backdrop-filter: blur(14px) saturate(160%)` base + `-webkit-` prefix + a support fallback (semi-opaque bg); (2) SVG `feTurbulence`→`feDisplacementMap` (`scale` ~8–12) applied via `filter:url(#glassEdge)` for the refracting edge; (3) specular via a `::before` linear-gradient highlight + `inset 0 1px 0 rgba(255,255,255,.5)` box-shadow. Point to `assets/demos/liquid-glass-2d.html` as the full runnable version. Cross-link `displacement-distortion` (same SVG primitives) and `motion-fx-web` for the map.

- [ ] **Step 3: Verify + commit**
```bash
cd ~/Developer/motion-fx-web && python3 -c "
import html.parser,sys
class P(html.parser.HTMLParser):
    pass
P().feed(open('assets/demos/liquid-glass-2d.html').read())
t=open('skills/liquid-glass-2d/SKILL.md').read(); assert 'description:' in t.split('---')[1]; assert 'backdrop-filter' in t and 'feDisplacementMap' in t
print('ok')"
git add skills/liquid-glass-2d assets/demos/liquid-glass-2d.html && git -c user.name="Fynn Ignacczak" -c user.email="ignacczakfynn@gmail.com" commit -q -m "feat: add liquid-glass-2d skill + demo"
```
Expected: `ok`

---

### Task 4: `liquid-glass-3d` skill (both approaches)

**Files:** Create `skills/liquid-glass-3d/SKILL.md`

- [ ] **Step 1: Write SKILL.md**

Frontmatter (verbatim):
```yaml
---
name: liquid-glass-3d
description: Use when building real 3D glass refraction in three.js — transmission/IOR materials or a custom GLSL refraction shader with chromatic aberration, for the web or a headless reel. Documents both approaches with trade-offs.
---
```
Body must contain BOTH approaches as real code:
- **Approach A — MeshPhysicalMaterial:** `new THREE.MeshPhysicalMaterial({ transmission:1, ior:1.5, thickness:1.2, roughness:0.05, metalness:0 })` plus an environment map (`RoomEnvironment`/`scene.environment`) so there's something to refract. Robust, minimal shader code.
- **Approach B — Custom GLSL:** a `ShaderMaterial` fragment shader that samples an env cube map along the refracted normal (`refract(viewDir, normal, 1.0/ior)`) three times at slightly different IOR for R/G/B (chromatic aberration). Show the key `refract()` lines.
- **Trade-offs:** A = fast/stable/less control; B = full control/heavier/trickier headless.
- Apply the **headless setup** from `motion-fx-web` (frame-driven, `preserveDrawingBuffer`, SwiftShader flags).
- three imported via ESM CDN (e.g. `import * as THREE from 'https://esm.sh/three'`).
Cross-link `three` (runtime) and `motion-fx-web`.

- [ ] **Step 2: Verify + commit**
```bash
cd ~/Developer/motion-fx-web && python3 -c "t=open('skills/liquid-glass-3d/SKILL.md').read(); assert 'description:' in t.split('---')[1]; assert 'MeshPhysicalMaterial' in t and 'refract(' in t and 'transmission' in t; print('ok')"
git add skills/liquid-glass-3d/SKILL.md && git -c user.name="Fynn Ignacczak" -c user.email="ignacczakfynn@gmail.com" commit -q -m "feat: add liquid-glass-3d skill (both approaches)"
```
Expected: `ok`

---

### Task 5: `shape-morphing` skill

**Files:** Create `skills/shape-morphing/SKILL.md`

- [ ] **Step 1: Write SKILL.md**

Frontmatter (verbatim):
```yaml
---
name: shape-morphing
description: Use when morphing SVG paths on the web beyond simple cases — multi-path, unequal point counts, icon-to-icon and blob morphs — via Flubber or GSAP MorphSVG, eased with motion-craft curves. Extends the shape-morph skill, does not duplicate it.
---
```
Body must contain real code for both routes:
- **Flubber:** `const interp = flubber.interpolate(pathA, pathB); gsap.to({t:0},{t:1, onUpdate(){ el.setAttribute('d', interp(this.targets()[0].t)); }, ease:'power2.inOut'})`. Note flubber handles unequal point counts (the thing naive lerp breaks on).
- **GSAP MorphSVG:** `gsap.to('#shape',{morphSVG:'#target', duration:1, ease:'power2.inOut'})`.
- When to use which; blob-morph tip (animate between several rounded random paths, `loop`).
Cross-link the existing `shape-morph` skill (base) and `motion-easing` (curve).

- [ ] **Step 2: Verify + commit**
```bash
cd ~/Developer/motion-fx-web && python3 -c "t=open('skills/shape-morphing/SKILL.md').read(); assert 'description:' in t.split('---')[1]; assert 'flubber' in t.lower() and 'morphSVG' in t; print('ok')"
git add skills/shape-morphing/SKILL.md && git -c user.name="Fynn Ignacczak" -c user.email="ignacczakfynn@gmail.com" commit -q -m "feat: add shape-morphing skill"
```
Expected: `ok`

---

### Task 6: `masking-blend` skill + demo

**Files:** Create `skills/masking-blend/SKILL.md`, `assets/demos/masking-blend.html`

- [ ] **Step 1: Write the demo `assets/demos/masking-blend.html`**

```html
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Masking & Blend</title>
<style>
  body { margin:0; background:#0b0b10; color:#fff; font-family:system-ui; display:grid; gap:40px; place-items:center; padding:48px; }
  .demo { width:min(560px,90vw); }
  /* 1. Image revealed through text (luminance-ish alpha mask) */
  .text-mask { font:900 96px/1 system-ui; text-transform:uppercase; text-align:center;
    background:url('https://images.unsplash.com/photo-1470770841072-f978cf4d019e?w=1000') center/cover;
    -webkit-background-clip:text; background-clip:text; color:transparent; }
  /* 2. clip-path wipe on hover */
  .wipe { height:160px; border-radius:16px; background:linear-gradient(135deg,#ff6b6b,#4ecdc4);
    clip-path:inset(0 60% 0 0); transition:clip-path .6s cubic-bezier(.4,0,.2,1); }
  .wipe:hover { clip-path:inset(0 0 0 0); }
  /* 3. mask-image with gradient */
  .fade { height:120px; background:conic-gradient(from 0deg,#f7971e,#ffd200,#f7971e); border-radius:16px;
    -webkit-mask:linear-gradient(90deg,transparent,#000 30%,#000 70%,transparent);
            mask:linear-gradient(90deg,transparent,#000 30%,#000 70%,transparent); }
  /* 4. mix-blend-mode */
  .blend { position:relative; height:160px; border-radius:16px; overflow:hidden; background:#222; }
  .blend b { position:absolute; inset:0; display:grid; place-items:center; font:900 80px/1 system-ui;
    color:#fff; mix-blend-mode:overlay; }
  .blend i { position:absolute; inset:0; background:radial-gradient(circle at 30% 40%,#e14eca,#4568dc); }
</style>
</head>
<body>
  <div class="demo"><div class="text-mask">GLOW</div></div>
  <div class="demo"><div class="wipe"></div><small>hover: clip-path wipe</small></div>
  <div class="demo"><div class="fade"></div><small>mask-image gradient</small></div>
  <div class="demo"><div class="blend"><i></i><b>MIX</b></div></div>
</body>
</html>
```

- [ ] **Step 2: Write SKILL.md**

Frontmatter (verbatim):
```yaml
---
name: masking-blend
description: Use when making one layer reveal or hide through another on the web — the web equivalent of After Effects track mattes. Covers CSS mask / -webkit-mask (alpha & luminance), mask-composite, animatable clip-path, background-clip:text, and mix-blend-mode, for reveals, wipes, and transitions.
---
```
Body must contain real snippets for: `mask`/`-webkit-mask` with a gradient (alpha matte); `background-clip:text` (image-through-text); animatable `clip-path:inset(...)` wipe with a transition; `mix-blend-mode`; a note on `mask-composite` for combining masks. Point to `assets/demos/masking-blend.html`. Cross-link `ae-track-mattes` (Plugin 2 — same idea, AE runtime).

- [ ] **Step 3: Verify + commit**
```bash
cd ~/Developer/motion-fx-web && python3 -c "
import html.parser
html.parser.HTMLParser().feed(open('assets/demos/masking-blend.html').read())
t=open('skills/masking-blend/SKILL.md').read(); assert 'description:' in t.split('---')[1]; assert 'mask' in t and 'clip-path' in t and 'mix-blend-mode' in t
print('ok')"
git add skills/masking-blend assets/demos/masking-blend.html && git -c user.name="Fynn Ignacczak" -c user.email="ignacczakfynn@gmail.com" commit -q -m "feat: add masking-blend skill + demo"
```
Expected: `ok`

---

### Task 7: `displacement-distortion` skill + demo

**Files:** Create `skills/displacement-distortion/SKILL.md`, `assets/demos/displacement-distortion.html`

- [ ] **Step 1: Write the demo `assets/demos/displacement-distortion.html`**

```html
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Displacement & Distortion</title>
<style>
  body { margin:0; min-height:100vh; background:#07131a; display:grid; place-items:center; font-family:system-ui; }
  .warp { width:min(560px,90vw); height:320px; border-radius:20px;
    background:url('https://images.unsplash.com/photo-1505118380757-91f5f5632de0?w=1000') center/cover;
    filter:url(#water); }
</style>
</head>
<body>
  <svg width="0" height="0"><filter id="water">
    <feTurbulence type="fractalNoise" baseFrequency="0.012 0.02" numOctaves="2" seed="3" result="n">
      <animate attributeName="baseFrequency" dur="14s" values="0.012 0.02;0.016 0.024;0.012 0.02" repeatCount="indefinite"/>
    </feTurbulence>
    <feDisplacementMap in="SourceGraphic" in2="n" scale="26" xChannelSelector="R" yChannelSelector="G"/>
  </filter></svg>
  <div class="warp"></div>
</body>
</html>
```

- [ ] **Step 2: Write SKILL.md**

Frontmatter (verbatim):
```yaml
---
name: displacement-distortion
description: Use when building warp/distortion effects on the web — water ripple, smoke, heat haze, glitch — with SVG feTurbulence + feDisplacementMap. Covers fractalNoise vs turbulence, octaves, animating baseFrequency/scale via SMIL or JS/GSAP.
---
```
Body must contain: `feTurbulence` params explained (`type` fractalNoise vs turbulence, `baseFrequency`, `numOctaves`, `seed`) → feeding `feDisplacementMap` (`scale` = warp strength, channel selectors); how to animate (SMIL `<animate>` on `baseFrequency` for water, or JS/GSAP setting the attribute for scriptable control); presets: water (`scale` ~24), heat haze (low freq, small scale, animate), glitch (high freq, animate scale in bursts). Point to `assets/demos/displacement-distortion.html`. Cross-link `liquid-glass-2d` (shares these primitives).

- [ ] **Step 3: Verify + commit**
```bash
cd ~/Developer/motion-fx-web && python3 -c "
import html.parser
html.parser.HTMLParser().feed(open('assets/demos/displacement-distortion.html').read())
t=open('skills/displacement-distortion/SKILL.md').read(); assert 'description:' in t.split('---')[1]; assert 'feTurbulence' in t and 'feDisplacementMap' in t
print('ok')"
git add skills/displacement-distortion assets/demos/displacement-distortion.html && git -c user.name="Fynn Ignacczak" -c user.email="ignacczakfynn@gmail.com" commit -q -m "feat: add displacement-distortion skill + demo"
```
Expected: `ok`

---

### Task 8: Command `/fx-demo`

**Files:** Create `commands/fx-demo.md`

- [ ] **Step 1: Write the command**

Frontmatter (verbatim):
```yaml
---
description: Scaffold a standalone, runnable HTML demo of a motion-fx-web effect into ~/Downloads for quick preview and tweaking.
---
```
Body must instruct Claude to:
1. Read the effect name from `$ARGUMENTS` (liquid-glass-2d, liquid-glass-3d, shape-morphing, masking-blend, displacement-distortion). If empty/unknown, list the available effects.
2. For effects with an `assets/demos/*.html`, copy it to `~/Downloads/<effect>_demo.html`. For `liquid-glass-3d` (no static demo), generate a standalone HTML from the skill's three-via-ESM-CDN recipe.
3. Optionally `open` it in the browser.
4. Tell the user the path and that it's self-contained (no build/Node).

- [ ] **Step 2: Verify + commit**
```bash
cd ~/Developer/motion-fx-web && python3 -c "t=open('commands/fx-demo.md').read(); assert 'description:' in t.split('---')[1]; print('ok')"
git add commands/fx-demo.md && git -c user.name="Fynn Ignacczak" -c user.email="ignacczakfynn@gmail.com" commit -q -m "feat: add /fx-demo command"
```
Expected: `ok`

---

### Task 9: End-to-end verification

- [ ] **Step 1: Tree + all frontmatter + all demos well-formed**
```bash
cd ~/Developer/motion-fx-web
find . -type f -not -path './.git/*' | sort
python3 - <<'PY'
import glob, html.parser
for f in sorted(glob.glob('skills/*/SKILL.md')+glob.glob('commands/*.md')):
    t=open(f).read(); assert t.startswith('---'), f; assert 'description:' in t.split('---')[1], f
for h in sorted(glob.glob('assets/demos/*.html')):
    html.parser.HTMLParser().feed(open(h).read())
print('frontmatter + demos ok')
PY
```
Expected: `frontmatter + demos ok`

- [ ] **Step 2: Recipe coverage spot-check**
```bash
cd ~/Developer/motion-fx-web
grep -q "swiftshader" skills/motion-fx-web/SKILL.md && \
grep -q "MeshPhysicalMaterial" skills/liquid-glass-3d/SKILL.md && grep -q "refract(" skills/liquid-glass-3d/SKILL.md && \
grep -qi "flubber" skills/shape-morphing/SKILL.md && \
grep -q "mix-blend-mode" skills/masking-blend/SKILL.md && \
grep -q "feTurbulence" skills/displacement-distortion/SKILL.md && echo "recipes covered"
```
Expected: `recipes covered`

- [ ] **Step 3: Optional visual check (interactive)** — open each `assets/demos/*.html` in a browser (or Playwright screenshot) and confirm the effect renders with no console errors. Hand to Fynn if not interactive.

- [ ] **Step 4: Install test (interactive)** — `/plugin` install from `~/Developer/motion-fx-web/`; confirm 6 skills + `/fx-demo` appear.

- [ ] **Step 5: Final commit**
```bash
cd ~/Developer/motion-fx-web && git add -A && git -c user.name="Fynn Ignacczak" -c user.email="ignacczakfynn@gmail.com" commit -q -m "chore: complete motion-fx-web v0.1.0" || echo "nothing to commit"
```

---

## Self-Review (completed by plan author)

- **Spec coverage:** manifest (T1); umbrella + WebGL-headless recipe (T2); liquid-glass-2d + demo (T3); liquid-glass-3d both approaches (T4); shape-morphing (T5); masking-blend + demo (T6); displacement-distortion + demo (T7); /fx-demo (T8); verify incl. demo well-formedness + install (T9). All spec sections covered.
- **Placeholder scan:** demos and manifest are full runnable content; skills specify verbatim frontmatter + concrete required code (backdrop-filter, refract(), flubber, mix-blend-mode, feTurbulence). No TBD/TODO.
- **Name consistency:** skill folder names, effect names in `/fx-demo`, and cross-references (liquid-glass-2d/3d, shape-morphing, masking-blend, displacement-distortion) are consistent across tasks.
- **Adaptation note:** effects are HTML/CSS/three, not unit-testable; verify uses JSON validity, frontmatter parse, `html.parser` well-formedness, and grep. Visual + install checks are interactive and handed to Fynn.
