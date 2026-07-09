# motion-craft — Design Spec

**Datum:** 2026-07-09
**Status:** Entwurf zur Review
**Autor:** Fynn Ignacczak (mit Claude)

## Kontext & Motivation

Fynn will ein Claude-Code-Plugin, das „alles kann, wenn es um Motion Graphics geht". Die
Anfrage umfasst zwei grundverschiedene Arten von Fähigkeiten:

1. **Craft/Theorie** — Easing & Interpolation, die 12 Prinzipien der Animation, Rhythmus &
   Pacing, Kinetic Typography, Compositing-Denke. Tool-agnostisch, überall anwendbar.
2. **Tool-gebundene Technik** — Match-Moving, 3D-Camera-Tracking, Track Mattes, Expressions,
   Dynamic Link, MOGRT. Existiert real nur in After Effects.

Diese Spec deckt **ausschließlich Teilprojekt 1** ab: die tool-agnostische Craft-Schicht
`motion-craft`. Die tool-gebundenen Teile werden in späteren, eigenständigen Plugins gebaut:

- **Plugin 2 — `motion-ae-bridge`** (später): After-Effects-Scripting-Layer für Match-Moving,
  3D-Camera-Tracking, Track Mattes, Expressions, Dynamic Link, MOGRT. Baut auf Fynns
  vorhandenem AE-MOGRT-Scripting-Wissen auf.
- **Plugin 3 — `motion-fx-web`** (später, optional): web-native Effekt-Skills — Liquid
  Glass/Refraktion 2D+3D, fortgeschrittenes Shape-Morphing, Masking.

`motion-craft` ist das Fundament, auf das 2 und 3 sich beziehen, und sofort nützlich, weil es
jedes Reel verbessert, das Fynn heute schon in HyperFrames/Remotion/GSAP baut.

### Nicht doppelt bauen (bestehendes Ökosystem)

- **HyperFrames-Suite** → Kinetic Typography, Data-in-Motion, Audio-reaktiv, Transitions (web/GSAP)
- **animation-suite / Remotion** → Motion Graphics → MP4, Logo-Reveals, Recreation-Briefings
- **GSAP / anime.js / three / waapi / shape-morph** → web-native Technik-Skills
- **AE MOGRT-Scripting** (in Fynns Memory dokumentiert) → After-Effects-Steuerung

Die *Runtimes* existieren also größtenteils schon. Was fehlt und was `motion-craft` liefert:
die **Craft-Schicht**, die diese Tools zu organischer, prinzipientreuer Bewegung anleitet.

## Ziel & Nicht-Ziel

**Ziel:** Eine Wissensschicht, die Claude die Physik und Sprache der Animation beibringt und
Theorie in Fynns konkrete Runtimes übersetzt. Antwort auf „lineare Bewegungen wirken
mechanisch und billig".

**Nicht-Ziel:** Selbst Video rendern. Tool-gebundene Technik (Tracking, Expressions, Dynamic
Link, MOGRT, Liquid Glass, konkretes Shape-Morphing). Diese Skills *verweisen* darauf, bauen
es aber nicht.

## Architektur

Ansatz **B** (aus dem Brainstorming): eine Suite aus fokussierten Einzel-Skills mit scharfen
Triggern plus ein schlankes Dach-Skill, das zusammenhält und zu den Runtimes brückt. Plus ein
`/motion-review` Command (das „Auge auf C").

Begründung: Die Domänen (Easing vs. Timing vs. Typography) triggern in sehr unterschiedlichen
Momenten. Getrennte Skills mit präzisen Beschreibungen treffen besser als ein Monolith und
laden nicht unnötig Kontext.

### Dateistruktur

```
~/Developer/motion-craft/
├── .claude-plugin/
│   └── plugin.json                        # Manifest
├── skills/
│   ├── motion-craft/
│   │   └── SKILL.md                        # Dach: mentale Landkarte + Runtime-Bridge
│   ├── motion-easing/
│   │   ├── SKILL.md
│   │   └── references/                     # Kurven-Cheatsheets, Werte-Tabellen
│   ├── motion-principles/
│   │   ├── SKILL.md
│   │   └── references/                     # 12 Prinzipien, je eine Checkliste
│   ├── motion-timing/
│   │   └── SKILL.md
│   ├── kinetic-typography/
│   │   └── SKILL.md
│   └── compositing-architecture/
│       └── SKILL.md
├── commands/
│   └── motion-review.md                    # /motion-review Command
└── docs/
    └── specs/
        └── 2026-07-09-motion-craft-design.md
```

## Komponenten im Detail

Jeder Skill ist eine eigenständige, testbar abgegrenzte Einheit. Für jede gilt: klarer Zweck,
scharfe Trigger-Beschreibung im Frontmatter, konkrete Werte statt Prosa.

### Dach-Skill: `motion-craft`

- **Zweck:** Mentale Landkarte („welches Prinzip greift wann") + Runtime-Bridge (übersetzt
  Theorie in Fynns Tools).
- **Runtime-Bridge (Kern-Mehrwert):** Mappt Konzepte auf konkrete Tools, z.B. organische Ease
  → Remotion `spring()` / gemappte `interpolate()`-Kurve, GSAP `power2.inOut`, HyperFrames-
  Äquivalent. Verweist auf Fynns CLAUDE.md-Regeln: `useCurrentFrame()` statt CSS-Keyframes,
  monoton steigende `inputRange`, `@remotion/google-fonts`.
- **Trigger:** allgemeine Anfragen wie „mach die Animation hochwertiger/organischer".
- **Abhängigkeiten:** verweist auf die fünf Fach-Skills und auf bestehende Runtime-Skills.

### `motion-easing`

- **Zweck:** Warum linear tötet; Ease-In/Out/InOut; Bezier-Kurven lesen & bauen; Spring-Physik
  (Masse, Stiffness, Damping); Anwendungsfall→Kurve-Mapping.
- **Inhalt:** Konkrete Kurven-Werte und Cheatsheets in `references/`. Keine Prosa.
- **Trigger:** Easing, Interpolation, „Bewegung wirkt mechanisch", Bezier, Spring.

### `motion-principles`

- **Zweck:** Die 12 Disney-Prinzipien als anwendbare Checklisten, nicht als Lexikon.
- **Inhalt:** Squash&Stretch, Anticipation, Follow-Through & Overlapping Action, Secondary
  Action, Slow In/Out, Arcs, Timing, Exaggeration, Staging, Solid Drawing, Appeal,
  Straight-Ahead vs. Pose-to-Pose. Je Prinzip: „woran erkenne ich, dass es fehlt / wie füge
  ich es hinzu". Details je Prinzip in `references/`.
- **Trigger:** Squash&Stretch, Anticipation, Follow-Through, „Shape/Logo lebendiger machen".

### `motion-timing`

- **Zweck:** Rhythmus, Pacing, Schnitt auf Musik.
- **Inhalt:** Frame-Budgets, Pacing, Beat-Mapping, Antizipations-/Haltezeiten, Stagger/
  Kaskaden. Verbindet sich mit Fynns Audio-reaktivem HyperFrames-Wissen.
- **Trigger:** Timing, Rhythmus, Pacing, „Schnitt auf Musik", Beat, Stagger.

### `kinetic-typography`

- **Zweck:** Das *Denken* hinter Text-Animation (nicht das GSAP-Wie).
- **Inhalt:** Wie Wort-Animation Bedeutung visuell unterstreicht, Emphasis-Hierarchie, Timing
  zum gesprochenen Wort, Lesbarkeit vs. Effekt. Verweist auf Fynns Reel-Untertitel-Style-Guide.
- **Trigger:** Kinetic Typography, Text animieren, Wort-Animation, Untertitel-Stil.

### `compositing-architecture`

- **Zweck:** Projekte in Ebenen/Sub-Comps logisch strukturieren.
- **Inhalt:** Naming, Wiederverwendung, Übersicht behalten. Denke, die in AE *und* HyperFrames/
  Remotion trägt (Brücke zu Plugin 2 & 3).
- **Trigger:** Compositing, Ebenen-Struktur, Sub-Comps, „Projekt strukturieren".

### Command: `/motion-review`

- **Zweck:** Bestehende Animation (Beschreibung, Code oder Datei) systematisch gegen die
  Prinzipien prüfen.
- **Verhalten:** Checkt Easing (mechanisch?), Anticipation/Follow-Through (fehlt?), Timing
  (off-beat?), Staging/Lesbarkeit. Gibt priorisierte, konkrete Fixes zurück.
- **Trigger:** manuell via `/motion-review`.

## Datenfluss

`motion-craft` speichert keinen State. Ablauf:

1. Nutzer-Anfrage triggert einen Skill (oder den `/motion-review` Command).
2. Skill lädt sein SKILL.md; bei Bedarf per Progressive Disclosure Referenz-Dateien.
3. Claude wendet die Prinzipien auf die Ziel-Runtime an (HyperFrames/Remotion/GSAP), geführt
   von der Runtime-Bridge im Dach-Skill.
4. `/motion-review` produziert einen priorisierten Fix-Report; kein Rendering.

## Fehlerbehandlung / Randfälle

- **Runtime nicht bekannt:** Fragt kurz nach dem Ziel-Tool, bevor tool-spezifische Werte
  gegeben werden.
- **Tool-gebundene Anfrage** (z.B. „track das an die Kamera"): Skill erklärt, dass das zu
  Plugin 2 `motion-ae-bridge` gehört, und liefert die Craft-Anteile die es geben kann.
- **Node-Umgebung:** Craft-Schicht braucht kein Node. Rendering-Schritte in Fynns Runtime-
  Skills prüfen `which node` gemäß CLAUDE.md — hier nicht relevant.

## Testing / Verifikation

Da es eine Wissensschicht ohne Code-Logik ist, erfolgt Verifikation über Anwendungsfälle:

1. **Trigger-Test:** Für jeden Skill eine Beispiel-Anfrage, die ihn korrekt (und keinen
   falschen) aktiviert.
2. **Inhalts-Test:** Stichprobe je Skill — sind die Werte konkret und korrekt (z.B. plausible
   Bezier-/Spring-Parameter)?
3. **Bridge-Test:** Eine „mach das organischer"-Anfrage gegen eine echte Remotion- und eine
   HyperFrames-Situation; liefert die Runtime-Bridge tool-korrekte Umsetzung?
4. **Command-Test:** `/motion-review` gegen ein bewusst mechanisches Beispiel; werden die
   fehlenden Prinzipien erkannt?
5. **Install-Test:** Plugin lokal via `/plugin` aus `~/Developer/motion-craft/` installierbar;
   Skills & Command erscheinen.

## Offene Punkte

Keine. Speicherort bestätigt: `~/Developer/motion-craft/`.
