# motion-ae-bridge Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build `motion-ae-bridge`, a Claude Code plugin that drives After Effects via Fynn's documented headless DoScript pipeline — five skills (dispatch mechanics, expressions, track mattes, MOGRT export, guided tracking workflow), a runnable dispatch harness, and an `/ae-scaffold` command.

**Architecture:** Plugin under `~/Developer/motion-ae-bridge/`. Skills encode the operational pipeline + Fynn's hard-won gotchas; `scripts/dispatch.sh` + `scripts/skeleton.jsx` are runnable helpers with the AE app name parameterized via `AE_APP` (default "Adobe After Effects 2026"). Builds on `motion-craft` (references it for craft). Tracking is honestly marked non-scriptable.

**Tech Stack:** Markdown skills (`SKILL.md`), Bash + ExtendScript (.jsx) helpers, JSON manifest. AE-scripting needs no Node; QA uses ffmpeg/PIL.

---

## File Structure

```
~/Developer/motion-ae-bridge/
├── .claude-plugin/plugin.json
├── skills/
│   ├── ae-doscript/SKILL.md
│   ├── ae-expressions/SKILL.md
│   ├── ae-track-mattes/SKILL.md
│   ├── ae-mogrt-export/SKILL.md
│   └── ae-tracking-workflow/SKILL.md
├── scripts/dispatch.sh
├── scripts/skeleton.jsx
├── commands/ae-scaffold.md
├── .gitignore
└── docs/{specs,plans}/…
```

Verification: no automated test framework. Each "verify" step is a concrete check (JSON validity, frontmatter parse, `bash -n`, grep for required content). Git commits assume the repo is initialized. Frontmatter `description` fields are verbatim.

---

### Task 1: Repo, manifest, .gitignore

**Files:**
- Create: `.claude-plugin/plugin.json`, `.gitignore`

- [ ] **Step 1: Init repo + dirs**

```bash
cd ~/Developer/motion-ae-bridge && git init -q && git branch -m main 2>/dev/null
mkdir -p .claude-plugin skills/ae-doscript skills/ae-expressions skills/ae-track-mattes skills/ae-mogrt-export skills/ae-tracking-workflow scripts commands
```

- [ ] **Step 2: Write `.gitignore`**

```
.DS_Store
```

- [ ] **Step 3: Write `.claude-plugin/plugin.json`**

```json
{
  "name": "motion-ae-bridge",
  "version": "0.1.0",
  "description": "Drives After Effects headless via the DoScript pipeline — scripted expressions, track mattes, pre-comps, and MOGRT export with baked-in gotchas, plus a guided GUI workflow for non-scriptable tracking. Companion to motion-craft.",
  "author": { "name": "Fynn Ignacczak" }
}
```

- [ ] **Step 4: Verify JSON**

Run: `cd ~/Developer/motion-ae-bridge && python3 -c "import json; json.load(open('.claude-plugin/plugin.json')); print('valid')"`
Expected: `valid`

- [ ] **Step 5: Commit**

```bash
cd ~/Developer/motion-ae-bridge && git add -A && git -c user.name="Fynn Ignacczak" -c user.email="ignacczakfynn@gmail.com" commit -q -m "chore: init motion-ae-bridge, manifest"
```

---

### Task 2: Dispatch harness `scripts/dispatch.sh`

**Files:**
- Create: `scripts/dispatch.sh`

- [ ] **Step 1: Write the harness**

```bash
#!/usr/bin/env bash
# dispatch.sh — run one ExtendScript op in After Effects headless, poll its /tmp log.
# Usage: AE_APP="Adobe After Effects 2026" ./dispatch.sh /path/to/op.jsx [/tmp/ae_log.txt] [timeout_sec]
set -euo pipefail

AE_APP="${AE_APP:-Adobe After Effects 2026}"
JSX="${1:?need a .jsx path}"
LOG="${2:-/tmp/ae_log.txt}"
TIMEOUT="${3:-120}"

[ -f "$JSX" ] || { echo "jsx not found: $JSX" >&2; exit 1; }

# Confirm AE is running (osascript can't launch+script reliably; a Timeout -1712 otherwise looks like a hang).
if ! pgrep -f "$AE_APP" >/dev/null 2>&1; then
  echo "After Effects ('$AE_APP') does not appear to be running. Open it first." >&2
  exit 1
fi

# Fresh log so we only read this run's output.
: > "$LOG"

# Dispatch. AppleEvent may return Timeout (-1712) while the script keeps running — that's expected; we poll the log.
osascript -e "tell application \"$AE_APP\" to DoScript \"\$.evalFile(File(\\\"$JSX\\\"))\"" >/dev/null 2>&1 || true

# Poll the log for the DONE marker written by skeleton.jsx.
elapsed=0
while [ "$elapsed" -lt "$TIMEOUT" ]; do
  if grep -q "=== AE_DONE ===" "$LOG" 2>/dev/null; then
    cat "$LOG"; exit 0
  fi
  sleep 2; elapsed=$((elapsed + 2))
done

echo "--- log so far ---"; cat "$LOG"
echo "TIMEOUT after ${TIMEOUT}s (no AE_DONE marker). If a modal dialog is open, clear it via computer-use, then re-run." >&2
exit 2
```

- [ ] **Step 2: Verify bash syntax + AE_APP default present**

Run: `cd ~/Developer/motion-ae-bridge && bash -n scripts/dispatch.sh && grep -q 'AE_APP:-Adobe After Effects 2026' scripts/dispatch.sh && chmod +x scripts/dispatch.sh && echo ok`
Expected: `ok`

- [ ] **Step 3: Commit**

```bash
cd ~/Developer/motion-ae-bridge && git add scripts/dispatch.sh && git -c user.name="Fynn Ignacczak" -c user.email="ignacczakfynn@gmail.com" commit -q -m "feat: add AE dispatch harness"
```

---

### Task 3: ExtendScript skeleton `scripts/skeleton.jsx`

**Files:**
- Create: `scripts/skeleton.jsx`

- [ ] **Step 1: Write the skeleton**

```javascript
// skeleton.jsx — starting point for one headless AE op.
// Communicates results via a /tmp log (osascript AppleEvents time out; log is the source of truth).
// Reads optional control file (name of target comp etc.) from /tmp.
(function () {
    var LOG = "/tmp/ae_log.txt";
    var CONTROL = "/tmp/ae_control.txt"; // optional: e.g. "CompName|layer1,layer2|qaTimeSec"

    function log(msg) {
        var f = new File(LOG);
        f.open("a"); f.write(msg + "\n"); f.close(); // flush per step so a crash still leaves a trail
    }
    function readControl() {
        var f = new File(CONTROL);
        if (!f.exists) return null;
        f.open("r"); var t = f.read(); f.close(); return t;
    }
    // Clean stray temp comps from a previous crashed multi-export run.
    function cleanTempComps() {
        for (var i = app.project.numItems; i >= 1; i--) {
            var it = app.project.item(i);
            if (it instanceof CompItem && /^Temporary/.test(it.name)) { it.remove(); log("removed temp comp: " + it.name); }
        }
    }

    try {
        log("=== AE_START ===");
        cleanTempComps();
        var control = readControl();
        if (control) log("control: " + control);

        // ======== YOUR OP HERE ========
        // Do exactly ONE heavy op per dispatch (multiple exports in one run crash with
        // "Object is invalid"). Example: find a comp by name, tweak a property, QA it.
        // var comp = app.project.item(1);
        // ...
        // ===============================

        log("=== AE_DONE ===");
    } catch (e) {
        log("ERROR: " + e.toString() + (e.line ? (" @line " + e.line) : ""));
        log("=== AE_DONE ==="); // still mark done so dispatch.sh stops polling
    }
})();
```

- [ ] **Step 2: Verify the DONE marker and control-file convention are present**

Run: `cd ~/Developer/motion-ae-bridge && grep -q "AE_DONE" scripts/skeleton.jsx && grep -q "cleanTempComps" scripts/skeleton.jsx && echo ok`
Expected: `ok`

- [ ] **Step 3: Commit**

```bash
cd ~/Developer/motion-ae-bridge && git add scripts/skeleton.jsx && git -c user.name="Fynn Ignacczak" -c user.email="ignacczakfynn@gmail.com" commit -q -m "feat: add ExtendScript skeleton with log/control plumbing"
```

---

### Task 4: Skill `ae-doscript`

**Files:**
- Create: `skills/ae-doscript/SKILL.md`

- [ ] **Step 1: Write SKILL.md**

Frontmatter (verbatim):

```yaml
---
name: ae-doscript
description: Use when driving After Effects headless from the shell — dispatching ExtendScript (.jsx) via osascript DoScript, reading results from /tmp logs, or debugging why an AE dispatch hangs, times out, or silently does nothing. The operational core: one op per dispatch, log-based results, modal dialogs via computer-use.
---
```

Body must contain:
1. **The dispatch pattern:** `osascript -e 'tell application "$AE_APP" to DoScript "$.evalFile(File(\"…/op.jsx\"))"'`; AE app name parameterized via `AE_APP` (default "Adobe After Effects 2026"). Point to `scripts/dispatch.sh` + `scripts/skeleton.jsx` as the starting point.
2. **Hard rules (from Fynn's practice):**
   - **One heavy op per dispatch**; multiple exports/heavy ops in one run crash with "Object is invalid" and leave a "Temporary" comp. `sleep 6` between dispatches.
   - Results only via /tmp log (append + flush each step). AppleEvent **Timeout -1712 is expected** while the script keeps running — poll the log, don't treat it as failure.
   - A second dispatch while one runs is discarded ("second script was not run") — check log/screenshot first.
   - osascript has **no Accessibility access** → modal dialogs can only be cleared via computer-use MCP (screenshot + click).
   - Clean stray "Temporary…" comps at script start.
3. **QA without the render queue:** `comp.saveFrameToPng(time, File)` — PNG has straight alpha, composite over black via ffmpeg before judging; measure real size via PIL `Image.open(p).convert("RGBA").split()[3].getbbox()`. Needs ffmpeg/PIL, **not Node**.
4. Cross-link: for the craft (easing, principles) see the `motion-craft` plugin.

- [ ] **Step 2: Verify frontmatter + key rule present**

Run: `cd ~/Developer/motion-ae-bridge && python3 -c "t=open('skills/ae-doscript/SKILL.md').read(); assert 'description:' in t.split('---')[1]; assert '-1712' in t and 'AE_APP' in t; print('ok')"`
Expected: `ok`

- [ ] **Step 3: Commit**

```bash
cd ~/Developer/motion-ae-bridge && git add skills/ae-doscript/SKILL.md && git -c user.name="Fynn Ignacczak" -c user.email="ignacczakfynn@gmail.com" commit -q -m "feat: add ae-doscript operational skill"
```

---

### Task 5: Skill `ae-expressions`

**Files:**
- Create: `skills/ae-expressions/SKILL.md`

- [ ] **Step 1: Write SKILL.md**

Frontmatter (verbatim):

```yaml
---
name: ae-expressions
description: Use when setting After Effects expressions via script instead of hand-keying — wiggle(), loopOut(), auto-fit text via sourceRectAtTime, editable faux-3D extrusion, gradient/glow via effect matchnames. Includes the scripting gotchas (temporal-ease dimensions, comp-invalid-after-export).
---
```

Body must contain:
1. **Why:** one expression replaces hundreds of keyframes; e.g. `wiggle(2, 10)` for organic jitter, `loopOut()` for cycles.
2. **Auto-fit text (variable length):** extra null "FIT" between pop-controller and text, scale expression `maxW=960; w=thisComp.layer("WORD").sourceRectAtTime(time,false).width; s=(w>maxW)?maxW/w*100:100; [s,s]`. `sourceRectAtTime` is independent of parent transform → no circular reference.
3. **Editable faux-3D extrusion:** N dark text duplicates offset by (dx,dy) behind the front word, each with expression `thisComp.layer("WORD").text.sourceText.value.text` (returns the *string* so copies keep their own dark color; returning the TextDocument would inherit the front color).
4. **Effect matchnames that work:** gradient `ADBE Ramp` (fills RGB, alpha stays); glow `ADBE Glo2` (0012/0013 = Color A/B, 0007=2 for A&B). Text animators: `ADBE Text Opacity`, `ADBE Text Blur`, `ADBE Text Position 3D`, `ADBE Text Tracking Amount`, etc.
5. **Gotchas:** `setTemporalEaseAtKey` expects arrays matching the property dimension (2D scale often still wants 1 element — catch the ease error); after `exportAsMotionGraphicsTemplate` the comp variable is invalid ("Object is invalid") → render QA PNG *before* export or re-fetch the comp by name.
6. Cross-link: `ae-doscript` for how to dispatch these.

- [ ] **Step 2: Verify**

Run: `cd ~/Developer/motion-ae-bridge && python3 -c "t=open('skills/ae-expressions/SKILL.md').read(); assert 'description:' in t.split('---')[1]; assert 'sourceRectAtTime' in t and 'ADBE Ramp' in t; print('ok')"`
Expected: `ok`

- [ ] **Step 3: Commit**

```bash
cd ~/Developer/motion-ae-bridge && git add skills/ae-expressions/SKILL.md && git -c user.name="Fynn Ignacczak" -c user.email="ignacczakfynn@gmail.com" commit -q -m "feat: add ae-expressions skill"
```

---

### Task 6: Skill `ae-track-mattes`

**Files:**
- Create: `skills/ae-track-mattes/SKILL.md`

- [ ] **Step 1: Write SKILL.md**

Frontmatter (verbatim):

```yaml
---
name: ae-track-mattes
description: Use when assigning track mattes (alpha/luma) or building pre-comp / sub-comp architecture in After Effects via script — layer parenting, naming, and reuse. Includes the expensive parenting-scale-bake bug and parent-relative coordinate math.
---
```

Body must contain:
1. **Track mattes:** how to assign alpha/luma mattes by layer order via script; a matte reveals/hides the layer below.
2. **Pre-comp / sub-comp architecture:** create pre-comps for reused or grouped-as-one layers; name by role (`BG/`, `LOGO/`, `TEXT/`, `FX/`), never leave "Shape Layer 34".
3. **Parenting-scale-bake bug (expensive):** `layer.parent = null` preserves the child's WORLD transform by adjusting its scale. If the parent null has scale ≠ 100% at the current time (e.g. a pop-controller keyed [34,34] at t=0), the child gets ~294% baked in. **Fix:** parent while the parent null is at 100% (no keyframes yet), set the scale/pop keyframes *after* all parenting. Solvable only via script order.
4. **Parent-relative coordinates:** child parented to a null (anchor [50,50]) → child position becomes `world - parentPos + anchor`. For a centered child with offset dy, set `[50, 50+dy]`.
5. Cross-link: `compositing-architecture` in the `motion-craft` plugin for the conceptual thinking; `ae-doscript` for dispatch.

- [ ] **Step 2: Verify**

Run: `cd ~/Developer/motion-ae-bridge && python3 -c "t=open('skills/ae-track-mattes/SKILL.md').read(); assert 'description:' in t.split('---')[1]; assert 'parent' in t.lower() and '100%' in t; print('ok')"`
Expected: `ok`

- [ ] **Step 3: Commit**

```bash
cd ~/Developer/motion-ae-bridge && git add skills/ae-track-mattes/SKILL.md && git -c user.name="Fynn Ignacczak" -c user.email="ignacczakfynn@gmail.com" commit -q -m "feat: add ae-track-mattes skill"
```

---

### Task 7: Skill `ae-mogrt-export`

**Files:**
- Create: `skills/ae-mogrt-export/SKILL.md`

- [ ] **Step 1: Write SKILL.md**

Frontmatter (verbatim):

```yaml
---
name: ae-mogrt-export
description: Use when exporting Motion Graphics Templates (.mogrt) from After Effects headless — exportAsMotionGraphicsTemplate, filename via motionGraphicsTemplateName, the font-sync dialog, bringing non-Adobe fonts in headless, and QA. Codifies the hard-won MOGRT-build gotchas.
---
```

Body must contain:
1. **One export per dispatch** (multiple crash with "Object is invalid", leaving a "Temporary" comp). `sleep 6` between dispatches; pass target name via a /tmp control file.
2. **Filename:** `comp.exportAsMotionGraphicsTemplate(true, folder)` writes `<motionGraphicsTemplateName>.mogrt` into `folder` (NOT `<CompName>.mogrt`). Set `comp.motionGraphicsTemplateName` first and search for exactly that name.
3. **Save first:** call `app.project.save()` before export or you hit a "project needs to be saved first" dialog.
4. **Font-sync dialog:** appears only for activation-required (Adobe/Typekit) fonts, NOT for system-installed TTFs. `app.beginSuppressDialogs()` does NOT help — clear it via computer-use.
5. **Non-Adobe fonts headless:** instance a variable font to a static cut via `fontTools.varLib.instancer` (e.g. wght=700), set a clean name table (own family + subfamily "Regular", PS name like `Caveat-Bold`), drop in `~/Library/Fonts`, restart AE. `app.fonts.allFonts` may NOT list user fonts (red herring) — real test: set a TextDocument and read `td.fontObject.postScriptName`; if it resolves to your name, AE renders it. Verify visually via `saveFrameToPng` over black.
6. **Wrong PostScript name is silently substituted** (the Snell bug: "SnellRoundhand-BlackScript" is wrong; correct is "SnellRoundhand-Black"). Verify PS names first via `fc-list`/Font Book before assigning `td.font`.
7. Cross-link: `ae-doscript` for dispatch/QA.

- [ ] **Step 2: Verify**

Run: `cd ~/Developer/motion-ae-bridge && python3 -c "t=open('skills/ae-mogrt-export/SKILL.md').read(); assert 'description:' in t.split('---')[1]; assert 'motionGraphicsTemplateName' in t and 'fontObject.postScriptName' in t; print('ok')"`
Expected: `ok`

- [ ] **Step 3: Commit**

```bash
cd ~/Developer/motion-ae-bridge && git add skills/ae-mogrt-export/SKILL.md && git -c user.name="Fynn Ignacczak" -c user.email="ignacczakfynn@gmail.com" commit -q -m "feat: add ae-mogrt-export skill"
```

---

### Task 8: Skill `ae-tracking-workflow` (non-scriptable)

**Files:**
- Create: `skills/ae-tracking-workflow/SKILL.md`

- [ ] **Step 1: Write SKILL.md**

Frontmatter (verbatim):

```yaml
---
name: ae-tracking-workflow
description: Use when integrating text or objects into real footage in After Effects — 3D camera tracking, planar/Mocha tracking, match-moving, or Dynamic Link to Premiere. These are NOT scriptable; this is a guided step-by-step GUI workflow plus the match-moving craft, not automation.
---
```

Body must contain:
1. **Honesty banner:** AE's 3D Camera Tracker, Point/Planar Tracker, and Dynamic Link have no usable scripting API. This skill guides the GUI; it does not automate.
2. **3D Camera Tracker workflow:** step-by-step GUI clicks (apply effect → analyze → pick track points → create camera + null/text) and what to check.
3. **Planar/Mocha workflow:** when to prefer planar tracking (flat surfaces, signs, screens) and the click path.
4. **Match-moving craft:** what makes text "stick" — parent to the tracked null, match motion blur, respect perspective/scale, ground it with shadow/contact. Cross-link `motion-principles` (arcs, solid drawing) in motion-craft.
5. **Dynamic Link:** described as a manual Premiere↔AE step, not automated.
6. Optional: computer-use MCP can assist with clicking, but no automation promise.

- [ ] **Step 2: Verify**

Run: `cd ~/Developer/motion-ae-bridge && python3 -c "t=open('skills/ae-tracking-workflow/SKILL.md').read(); assert 'description:' in t.split('---')[1]; assert 'not' in t.lower() and 'scriptable' in t.lower(); print('ok')"`
Expected: `ok`

- [ ] **Step 3: Commit**

```bash
cd ~/Developer/motion-ae-bridge && git add skills/ae-tracking-workflow/SKILL.md && git -c user.name="Fynn Ignacczak" -c user.email="ignacczakfynn@gmail.com" commit -q -m "feat: add ae-tracking-workflow guided skill"
```

---

### Task 9: Command `/ae-scaffold`

**Files:**
- Create: `commands/ae-scaffold.md`

- [ ] **Step 1: Write the command**

Frontmatter (verbatim):

```yaml
---
description: Scaffold a new headless AE automation from a description — copies the skeleton, sets up the control-file convention, and lists the relevant gotchas for the task type.
---
```

Body must instruct Claude to:
1. Read the task description from `$ARGUMENTS`; if empty, ask what the automation should do.
2. Create a work dir `~/Downloads/<name>_ae/`, copy `scripts/skeleton.jsx` and `scripts/dispatch.sh` into it.
3. Identify the task type and invoke the matching skill: expressions → `ae-expressions`, mattes/pre-comps → `ae-track-mattes`, MOGRT → `ae-mogrt-export`, tracking → `ae-tracking-workflow` (and note it's manual).
4. Fill the skeleton's "YOUR OP HERE" block and the /tmp control-file convention for this task.
5. List the specific gotchas that apply to this task type (from the chosen skill), so they're front-of-mind.
6. **Do not dispatch/execute** — running against AE is a separate, user-initiated step (needs AE open + computer-use for dialogs).

- [ ] **Step 2: Verify**

Run: `cd ~/Developer/motion-ae-bridge && python3 -c "t=open('commands/ae-scaffold.md').read(); assert 'description:' in t.split('---')[1]; print('ok')"`
Expected: `ok`

- [ ] **Step 3: Commit**

```bash
cd ~/Developer/motion-ae-bridge && git add commands/ae-scaffold.md && git -c user.name="Fynn Ignacczak" -c user.email="ignacczakfynn@gmail.com" commit -q -m "feat: add /ae-scaffold command"
```

---

### Task 10: End-to-end verification

- [ ] **Step 1: File tree**

Run: `cd ~/Developer/motion-ae-bridge && find . -type f -not -path './.git/*' | sort`
Expected: manifest, 5 SKILL.md, dispatch.sh, skeleton.jsx, ae-scaffold.md, .gitignore, 2 docs.

- [ ] **Step 2: All frontmatter + harness syntax**

Run:
```bash
cd ~/Developer/motion-ae-bridge
python3 - <<'PY'
import glob
for f in sorted(glob.glob('skills/*/SKILL.md')+glob.glob('commands/*.md')):
    t=open(f).read(); assert t.startswith('---'), f; assert 'description:' in t.split('---')[1], f
print('frontmatter ok')
PY
bash -n scripts/dispatch.sh && echo "dispatch.sh syntax ok"
```
Expected: `frontmatter ok` and `dispatch.sh syntax ok`.

- [ ] **Step 3: Gotcha coverage spot-check**

Run:
```bash
cd ~/Developer/motion-ae-bridge
grep -rq "one op per dispatch\|One heavy op per dispatch\|one export per dispatch\|One export per dispatch" skills/ && \
grep -rq "motionGraphicsTemplateName" skills/ae-mogrt-export/ && \
grep -rq "parent" skills/ae-track-mattes/ && echo "gotchas covered"
```
Expected: `gotchas covered`

- [ ] **Step 4: Install + live test (manual, interactive)**

Install locally via `/plugin` from `~/Developer/motion-ae-bridge/`. Then, with AE 2026 open, dispatch a trivial op (e.g. `wiggle` on a test comp via `dispatch.sh`) and QA the PNG. This needs AE running + computer-use for any dialog → hand to Fynn; the agent cannot run it in a non-interactive session.

- [ ] **Step 5: Final commit**

```bash
cd ~/Developer/motion-ae-bridge && git add -A && git -c user.name="Fynn Ignacczak" -c user.email="ignacczakfynn@gmail.com" commit -q -m "chore: complete motion-ae-bridge v0.1.0" || echo "nothing to commit"
```

---

## Self-Review (completed by plan author)

- **Spec coverage:** manifest+gitignore (T1); dispatch harness (T2); skeleton (T3); ae-doscript (T4); ae-expressions (T5); ae-track-mattes (T6); ae-mogrt-export (T7); ae-tracking-workflow (T8); /ae-scaffold (T9); verify incl. manual live test (T10). All spec sections covered.
- **Placeholder scan:** helper scripts are full runnable content; skills specify verbatim frontmatter + concrete required gotchas. No TBD/TODO.
- **Name consistency:** `AE_APP`, `/tmp/ae_log.txt`, `=== AE_DONE ===`, skill folder names, and cross-references are consistent across dispatch.sh, skeleton.jsx, and all skills.
- **Adaptation note:** Markdown/script plugin has no unit tests; verify steps use JSON validity, frontmatter parse, `bash -n`, and grep. The AE live test is inherently manual (needs AE + computer-use) and is handed to Fynn.
