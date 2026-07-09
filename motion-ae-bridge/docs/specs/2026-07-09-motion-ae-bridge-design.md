# motion-ae-bridge — Design Spec

**Datum:** 2026-07-09
**Status:** Entwurf zur Review
**Autor:** Fynn Ignacczak (mit Claude)

## Kontext & Motivation

Teilprojekt 2 der Motion-Graphics-Plugin-Reihe (nach `motion-craft`). Deckt die
**tool-gebundene, After-Effects-spezifische** Technik ab, die `motion-craft` bewusst
ausgeklammert hat.

Fynn steuert AE 2026 auf seinem Mac bereits headless-artig über eine dokumentierte
**DoScript-Pipeline**: `osascript -e 'tell application "Adobe After Effects 2026" to
DoScript "$.evalFile(File(\"…/script.jsx\"))"'`, Ergebnis-Kommunikation über /tmp-Log/
Steuerdateien, ein Op pro Dispatch, Modal-Dialoge per Computer-Use. Damit wurden die
Viral-Titles- und Caption-MOGRTs gebaut. Dabei sind viele nicht-offensichtliche Gotchas
angefallen (dokumentiert in Fynns Memory `ae-mogrt-scripting`). Dieses Plugin **kodifiziert
diese Pipeline und die Gotchas als Skills**, damit sie nicht bei jedem Task neu entdeckt
werden müssen.

## Machbarkeits-Grenze (entscheidend fürs Design)

AEs Scripting-Umfang teilt die Wunschliste in zwei Hälften:

**Skriptbar (Automation):** Expressions per Script, Track Mattes, Pre-Comps/Sub-Comp-
Architektur, Text-Animatoren, MOGRT-Export. Fynn hat das meiste davon bereits gebaut.

**Nicht skriptbar (nur interaktive GUI):** 3D Camera Tracker, Point/Planar Tracker, Dynamic
Link zu Premiere. AE bietet dafür keine brauchbare Scripting-API. → Das Plugin liefert hier
einen **geführten manuellen GUI-Workflow** plus die Craft-Prinzipien, kein Automations-
Versprechen.

Gewählter Ansatz (Brainstorming): **Automation für alles Skriptbare + geführte Tracking-Docs.**

## Ziel & Nicht-Ziel

**Ziel:** Claude generiert und dispatcht ExtendScript für alle skriptbaren AE-Aufgaben,
mit den bekannten Gotchas als eingebaute Regeln; für Tracking ein ehrlicher geführter
GUI-Workflow.

**Nicht-Ziel:** 3D-Camera-Tracking/Match-Moving automatisieren (unmöglich). Dynamic Link
automatisieren (kein API). Liquid Glass / Refraktion / Shape-Morph-Internals (→ Plugin 3
`motion-fx-web`). Motion-Craft-Theorie duplizieren (→ verweist auf `motion-craft`).

## Architektur

Ansatz B (wie motion-craft): fokussierte Skills mit scharfen Triggern, plus **echt lauffähige
Helfer-Dateien** (Dispatch-Harness) und ein Scaffold-Command. Baut auf `motion-craft` auf
(verweist für Easing/Prinzipien/Compositing-Denke dorthin).

### Dateistruktur

```
~/Developer/motion-ae-bridge/
├── .claude-plugin/plugin.json
├── skills/
│   ├── ae-doscript/SKILL.md            # Kern: Dispatch-Mechanik + Betriebs-Gotchas
│   ├── ae-expressions/SKILL.md         # Expressions per Script
│   ├── ae-track-mattes/SKILL.md        # Track Mattes + Pre-Comp/Sub-Comp per Script
│   ├── ae-mogrt-export/SKILL.md        # MOGRT-Export mit allen Export-Gotchas
│   └── ae-tracking-workflow/SKILL.md   # Geführter GUI-Workflow (nicht skriptbar)
├── scripts/
│   ├── dispatch.sh                     # wiederverwendbarer Dispatch-Harness
│   └── skeleton.jsx                    # .jsx-Gerüst mit Log/Steuerdatei-Plumbing
├── commands/ae-scaffold.md             # /ae-scaffold
└── docs/
    ├── specs/2026-07-09-motion-ae-bridge-design.md
    └── plans/2026-07-09-motion-ae-bridge.md
```

## Komponenten im Detail

### Skill: `ae-doscript` (Kern/operational)

- **Zweck:** Wie man AE headless steuert.
- **Inhalt (aus Fynns dokumentierter Praxis):**
  - Dispatch: `osascript … DoScript "$.evalFile(File(\"…\"))"`; AE-App-Name **parametrisiert**
    per Env-Var `AE_APP` (Default `"Adobe After Effects 2026"`).
  - **Ein Op pro Dispatch**, dazwischen `sleep 6`; mehrere schwere Ops in einem Lauf crashen
    ("Object is invalid").
  - Ergebnis-Kommunikation nur über /tmp-Log-Dateien (`File open "a"`/flush nach jedem
    Schritt); AppleEvent-Timeout `-1712` ignorieren, Script läuft weiter.
  - Zweiter Dispatch während ein Script läuft → wird verworfen ("second script was not run");
    erst Log/Screenshot prüfen.
  - osascript hat **keinen** Accessibility-Zugriff → Modal-Dialoge nur per Computer-Use-MCP.
  - Temp-Comp-Cleanup am Scriptanfang.
  - QA: `saveFrameToPng` über Schwarz compositen (straight alpha!), echte Größe per
    PIL-bbox; braucht ffmpeg/PIL, **kein Node**.
- **Verweist auf:** `scripts/dispatch.sh` + `skeleton.jsx` als Startpunkt.
- **Trigger:** AE headless steuern, DoScript, ExtendScript dispatchen.

### Skill: `ae-expressions`

- **Zweck:** Expressions per Script statt hunderte Keyframes.
- **Inhalt:** `wiggle(freq,amp)`, `loopOut()`; `sourceRectAtTime`-Auto-Fit (variable
  Textlänge); editierbare Faux-3D-Extrusion (Duplikate mit `…sourceText.value.text`);
  Gradient (`ADBE Ramp`) / Glow (`ADBE Glo2`) Matchnames. Fallen: `setTemporalEaseAtKey`
  Property-Dimension; comp-Variable nach Export ungültig.
- **Trigger:** Expression, wiggle, loopOut, Auto-Fit-Text, Faux-3D.

### Skill: `ae-track-mattes`

- **Zweck:** Track Mattes + Compositing-Architektur per Script.
- **Inhalt:** Alpha/Luma-Matte-Zuweisung; Pre-Comp-Erzeugung, Naming (`BG/`, `LOGO/`, …).
  **Parenting-Scale-Bake-Bug:** erst parenten solange Parent-Null auf 100 % (keine Keyframes),
  Scale-/Pop-Keyframes **danach**. Parent-Relativ-Koordinate: Kind-Position `welt - parentPos
  + anchor`.
- **Verweist auf:** `compositing-architecture` (motion-craft) für die Denke dahinter.
- **Trigger:** Track Matte, Alpha/Luma-Matte, Pre-Comp per Script, Parenting.

### Skill: `ae-mogrt-export`

- **Zweck:** MOGRTs headless bauen — Fynns Memory als Skill.
- **Inhalt:** Ein Export pro Dispatch; Dateiname über `comp.motionGraphicsTemplateName` (nicht
  CompName); `app.project.save()` vor Export (sonst Save-Dialog); Font-Sync-Dialog nur bei
  Adobe/Typekit-Fonts (nicht bei system-installierten TTFs); Nicht-Adobe-Fonts per
  `fontTools.varLib.instancer` instanzieren, name-Table setzen, nach `~/Library/Fonts`, AE
  neu starten; `allFonts` ist Red Herring → echter Test `td.fontObject.postScriptName`;
  falscher PS-Name wird still substituiert (Snell-Bug) → PS-Namen vorher prüfen.
- **Trigger:** MOGRT, Motion Graphics Template, exportAsMotionGraphicsTemplate.

### Skill: `ae-tracking-workflow` (nicht skriptbar)

- **Zweck:** Ehrlicher geführter GUI-Workflow für das, was Scripting nicht kann.
- **Inhalt:** 3D Camera Tracker & Planar/Mocha Schritt-für-Schritt (was klicken); Match-Moving-
  Craft (worauf achten, damit Text „klebt"); Dynamic-Link-zu-Premiere als manueller Schritt.
  Explizit als **nicht automatisierbar** markiert; optional Computer-Use-Assistenz zum Klicken,
  aber kein Automations-Versprechen.
- **Trigger:** Camera Tracking, Match-Moving, Planar Tracking, Mocha, Dynamic Link.

### Helfer-Dateien (echt lauffähig)

- **`scripts/dispatch.sh`:** Bash-Harness. Nimmt einen .jsx-Pfad, liest `AE_APP` (Default
  2026), räumt vorher das /tmp-Log, dispatcht per osascript, pollt das Log bis Fertig-Marker
  oder Timeout, gibt das Log aus. Kommentiert.
- **`scripts/skeleton.jsx`:** ExtendScript-Gerüst mit Log-Helfer (`File open "a"`/flush),
  Steuerdatei-Lesen aus /tmp, Temp-Comp-Cleanup am Anfang, try/catch mit Log-Ausgabe,
  Fertig-Marker am Ende. Platzhalter-Block „// DEINE OP HIER".

### Command: `/ae-scaffold`

- **Zweck:** Neue AE-Automation aus einer Beschreibung aufsetzen.
- **Verhalten:** Kopiert Skeleton nach `~/Downloads/<name>_ae/`, füllt Steuerdatei-Konvention,
  wählt den passenden Skill (expressions/mattes/mogrt) und listet die für diesen Task-Typ
  relevanten Gotchas. Führt selbst nichts aus — Ausführung bleibt bewusst ein separater,
  vom Nutzer angestoßener Schritt.

## Datenfluss

1. Anfrage triggert einen Skill (oder `/ae-scaffold`).
2. Für skriptbare Aufgaben: Claude generiert .jsx (basierend auf `skeleton.jsx`), dispatcht per
   `dispatch.sh`, pollt /tmp-Log, behandelt Dialoge per Computer-Use, QA per `saveFrameToPng`.
3. Für Tracking: Claude liefert den geführten GUI-Workflow; keine Ausführung.

## Fehlerbehandlung / Randfälle

- **AE nicht offen / falsche Version:** `dispatch.sh` prüft, ob `AE_APP` läuft; sonst klare
  Meldung statt Timeout-Rätselraten.
- **Modal-Dialog blockiert Dispatch:** Skill weist an, per Computer-Use Screenshot + Klick zu
  lösen; osascript kann es nicht.
- **Tool-Grenze:** Tracking-/Dynamic-Link-Anfragen → `ae-tracking-workflow`, ehrlich als
  manuell markiert.
- **Node:** AE-Scripting braucht kein Node; QA braucht ffmpeg/PIL — Skill dokumentiert das.

## Testing / Verifikation

1. **Struktur:** alle Dateien vorhanden; plugin.json valide; Frontmatter parst.
2. **Harness-Syntax:** `bash -n dispatch.sh` (Syntax ok); `skeleton.jsx` per Klammer-/Quote-
   Sichtprüfung (kein AE nötig).
3. **Env-Var:** `dispatch.sh` nutzt `AE_APP` mit Default 2026 (grep-Check).
4. **Gotcha-Abdeckung:** Stichprobe — tauchen die Kern-Gotchas (ein Export pro Dispatch,
   motionGraphicsTemplateName, Parenting-Scale-Bake, Snell-PS-Name) in den Skills auf?
5. **Live-Test (manuell, interaktiv):** Gegen laufendes AE einen Mini-Op dispatchen (z.B.
   `wiggle` auf eine Test-Comp) + QA-PNG. Braucht AE + Computer-Use → an Fynn übergeben.

## Offene Punkte

Keine. AE-Version parametrisiert (`AE_APP`, Default `"Adobe After Effects 2026"`).
Speicherort: `~/Developer/motion-ae-bridge/`.
