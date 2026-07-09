# motion-fx-web — Design Spec

**Datum:** 2026-07-09
**Status:** Entwurf zur Review
**Autor:** Fynn Ignacczak (mit Claude)

## Kontext & Motivation

Teil 3 (und Abschluss) der Motion-Graphics-Plugin-Reihe nach `motion-craft` (Craft-Wissen)
und `motion-ae-bridge` (After-Effects-Automation). Dieses Plugin deckt die **web-nativen
visuellen Effekte** ab, die in HyperFrames/three/GSAP real umsetzbar sind — die dritte Hälfte
der ursprünglichen Wunschliste (Liquid Glass/Refraktion, Shape-Morphing, Masking).

Es liefert **lauffähige Copy-Paste-Rezepte** (fertiger Code je Effekt), nicht nur Wissen, und
verweist für die Runtimes (`three`, `shape-morph`, `gsap`, `css-animations`, `waapi`) und für
die Craft (Easing/Timing) auf die bestehenden Skills bzw. `motion-craft` — dupliziert nichts
davon.

## Entscheidungen aus dem Brainstorming

- **Liquid Glass 2D UND 3D gleichwertig** (nicht nur der leichte 2D-Look).
- **Deliverable = lauffähige Rezepte** (fertiger Code), nicht reines Wissen.
- **Effekt-Roster:** zusätzlich zu Glass 2D+3D auch Shape-Morphing, Masking & Blend,
  Displacement & Distortion — alle drei rein.
- **3D-Ansatz:** beide Wege gleichwertig dokumentieren (`MeshPhysicalMaterial` transmission
  *und* Custom-GLSL-Shader) mit Trade-offs.

## Ziel & Nicht-Ziel

**Ziel:** Fertige, getestete Effekt-Rezepte für web-natives Motion, inkl. der Lösung fürs
**WebGL-Headless-Rendering** in Fynns Reels (Playwright/headless Chromium).

**Nicht-Ziel:** `three`/`shape-morph`/`gsap` duplizieren (→ referenzieren). AE-Themen
(→ Plugin 2). Craft-Theorie (→ motion-craft).

## Architektur

Ansatz B (wie die Vorgänger): fokussierte Effekt-Skills mit lauffähigem Code, ein Dach-Skill
mit Effekt-Landkarte + WebGL-Headless-Querschnitt, eigenständige HTML-Demos in `assets/demos/`,
plus ein `/fx-demo` Command.

### Dateistruktur

```
~/Developer/motion-fx-web/
├── .claude-plugin/plugin.json
├── skills/
│   ├── motion-fx-web/SKILL.md          # Dach: Landkarte + WebGL-Headless-Rezept
│   ├── liquid-glass-2d/SKILL.md
│   ├── liquid-glass-3d/SKILL.md
│   ├── shape-morphing/SKILL.md
│   ├── masking-blend/SKILL.md
│   └── displacement-distortion/SKILL.md
├── assets/demos/
│   ├── liquid-glass-2d.html
│   ├── masking-blend.html
│   └── displacement-distortion.html
├── commands/fx-demo.md
└── docs/{specs,plans}/…
```

Anmerkung zu Demos: Die 2D/SVG-Effekte (glass-2d, masking-blend, displacement) bekommen echte
Standalone-HTML-Demos (im Browser sofort lauffähig, kein Build). Die 3D-Demos leben als
Code-Blöcke im Skill (three via ESM-CDN-Import), weil ein sinnvoller three-Demo eine
Netzwerk/Modul-Abhängigkeit hat und nicht als reines Datei-Snippet trägt.

## Komponenten im Detail

Jeder Skill: scharfe Trigger-Beschreibung, **fertiger lauffähiger Code**, Verweise statt
Duplikat.

### Dach-Skill: `motion-fx-web`

- **Zweck:** Effekt-Landkarte (welcher Effekt löst welches Problem) + der WebGL-Headless-
  Querschnitt.
- **WebGL-Headless-Rezept (Kern):** Wie three.js in Playwright/headless Chromium rendert:
  Software-Rendering via SwiftShader/ANGLE ist langsam aber deterministisch; `WebGLRenderer({
  preserveDrawingBuffer:true, antialias:true })`; **Animation frame-getrieben** (Frame-Index
  rein, nicht `Date.now()` — analog zu Remotions `useCurrentFrame()`); vor dem Abfilmen auf
  `renderer.render()`-Abschluss warten (Flag/Promise setzen). Fallback: wenn 3D im Headless
  zickt, ist `liquid-glass-2d` immer verfügbar.
- **Trigger:** allgemeine „welcher Web-Effekt für X", WebGL in Reels/headless rendern.
- **Verweist auf:** `motion-craft` (Easing/Timing), `three`, `gsap`.

### `liquid-glass-2d`

- **Zweck:** Apple-„Liquid Glass"-Look, lauffähig, reel-tauglich.
- **Rezept:** `backdrop-filter: blur() saturate()` für die Milchglas-Basis; SVG-Filter
  `feTurbulence` → `feDisplacementMap` für die Rand-Brechung; Specular-Highlight per
  Linear-/Radial-Gradient-Overlay; Border-Sheen. Vollständig in `assets/demos/liquid-glass-2d.html`.
- **Trigger:** Liquid Glass, Glassmorphism, frosted glass, Brechungsrand (2D/CSS).

### `liquid-glass-3d`

- **Zweck:** Echte 3D-Refraktion in three.js.
- **Rezept (beide Wege gleichwertig):**
  1. **`MeshPhysicalMaterial`** mit `transmission`, `ior`, `thickness`, `roughness` (+
     `Environment`/Env-Map) — robust, wenig Shader-Code.
  2. **Custom GLSL** — Fragment-Shader mit Env-Map-Sampling entlang der gebrochenen Normalen +
     Chromatic Aberration (drei leicht versetzte IOR-Samples für R/G/B).
  Trade-offs benannt; beide mit dem Headless-Setup aus dem Dach-Skill.
- **Trigger:** 3D Refraktion, Glas-Shader, transmission material, IOR, chromatic aberration.

### `shape-morphing`

- **Zweck:** Fortgeschrittenes SVG-Path-Morphing über den bestehenden `shape-morph`-Skill
  hinaus.
- **Rezept:** Multi-Path-Morph, ungleiche Punktzahlen via Flubber-`interpolate` oder GSAP
  `MorphSVGPlugin`; Easing aus `motion-easing` (motion-craft); Beispiel Icon-zu-Icon und
  Blob-Morph.
- **Trigger:** Shape Morphing, SVG path morph, Flubber, MorphSVG, Blob-Morph.
- **Verweist auf:** `shape-morph` (Basis), `motion-easing`.

### `masking-blend`

- **Zweck:** Web-Äquivalent zu AE Track Mattes.
- **Rezept:** CSS `mask`/`-webkit-mask` (Alpha/Luminanz), `mask-composite`, `clip-path` (inkl.
  animierbar), `mix-blend-mode`. Beispiele: Text-durch-Bild-Reveal, Wipe-Transition,
  Luminanz-Matte. Vollständig in `assets/demos/masking-blend.html`.
- **Trigger:** Mask, Track Matte (web), clip-path, blend mode, Reveal, Wipe.
- **Verweist auf:** `ae-track-mattes` (Plugin 2, gleiche Denke andere Runtime).

### `displacement-distortion`

- **Zweck:** Generisches Warp-Toolkit (Wasser, Rauch, Heat-Haze, Glitch).
- **Rezept:** SVG `feTurbulence` (fractalNoise vs. turbulence, Oktaven, Seed-Animation) →
  `feDisplacementMap` (scale animiert); animiert per SMIL oder JS/GSAP auf die Filter-Attribute.
  Vollständig in `assets/demos/displacement-distortion.html`.
- **Trigger:** Displacement, feDisplacementMap, feTurbulence, Warp, Wasser/Rauch-Verzerrung,
  Glitch-Warp.

### Command: `/fx-demo`

- **Zweck:** Effekt-Demo als Standalone-HTML scaffolden.
- **Verhalten:** Nimmt einen Effektnamen aus `$ARGUMENTS`; kopiert die passende
  `assets/demos/*.html` (bzw. generiert den 3D-Demo aus dem Skill-Code) nach `~/Downloads/`,
  öffnet sie optional im Browser. Bei unbekanntem/leerem Namen: listet die verfügbaren Effekte.

## Datenfluss

1. Anfrage triggert einen Effekt-Skill (oder `/fx-demo`).
2. Claude liefert das lauffähige Rezept, angepasst an Ziel (HyperFrames-Szene vs. Standalone-Web),
   Craft-Parameter aus motion-craft.
3. Für 3D: Headless-Setup aus dem Dach-Skill mit anwenden.

## Fehlerbehandlung / Randfälle

- **WebGL im Headless zickt:** Dach-Skill nennt SwiftShader-Flags + Fallback auf `liquid-glass-2d`.
- **`backdrop-filter` Support:** Hinweis auf Browser-Support + Fallback (halbtransparenter BG).
- **Morph mit ungleicher Punktzahl:** Flubber/MorphSVG handhaben das; Skill zeigt wie, statt
  naivem Punkt-für-Punkt-Lerp (das bricht).
- **Node:** Standalone-HTML-Demos brauchen kein Node. three via CDN-ESM. Reel-Rendering nutzt
  Fynns HyperFrames/Playwright-Kette (dort `which node` gemäß CLAUDE.md).

## Testing / Verifikation

1. **Struktur:** alle Dateien vorhanden; plugin.json valide; Frontmatter parst.
2. **Demo-Validität:** die drei `.html`-Demos sind wohlgeformt (öffnen im Browser ohne Konsole-
   Fehler); Sichtprüfung des Effekts. Optional per Playwright screenshotten.
3. **Rezept-Abdeckung:** Stichprobe je Skill — enthält es echten, vollständigen Code (kein
   Pseudocode)? Enthält glass-3d beide Wege? Enthält das Dach-Skill das Headless-Rezept?
4. **Command:** `/fx-demo <effekt>` legt eine lauffähige HTML in ~/Downloads an.
5. **Install-Test (interaktiv):** Plugin lokal via `/plugin`; Skills + `/fx-demo` erscheinen.

## Offene Punkte

Keine. 2D+3D gleichwertig; Rezepte lauffähig; Roster = Glass2D/Glass3D/Morphing/Masking/
Displacement; 3D beide Wege. Speicherort `~/Developer/motion-fx-web/`.
