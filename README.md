# motion-plugins

A Claude Code plugin marketplace for motion-graphics work.

## Plugins

- **motion-craft** — tool-agnostic motion-design knowledge layer: easing, the 12 principles, timing & pacing, kinetic typography, compositing architecture, plus a `/motion-review` command. Makes any runtime (HyperFrames, Remotion, GSAP) produce organic, principled motion.
- **motion-ae-bridge** — drives After Effects headless via the DoScript pipeline: scripted expressions, track mattes, pre-comps, and MOGRT export with baked-in gotchas, plus a guided GUI workflow for non-scriptable tracking and an `/ae-scaffold` command.
- **motion-fx-web** — runnable web-native effect recipes: liquid glass (2D CSS/SVG + 3D three.js refraction), advanced SVG shape-morphing, masking & blend (web track mattes), displacement/distortion, plus a WebGL-headless render recipe and an `/fx-demo` command.

## Install

In an interactive Claude Code session:

```
/plugin marketplace add fynn-ignacczak/motion-plugins
/plugin install motion-craft@fynn-motion
/plugin install motion-ae-bridge@fynn-motion
/plugin install motion-fx-web@fynn-motion
```

Or from a local checkout:

```
/plugin marketplace add ~/Developer/motion-plugins
/plugin install motion-craft@fynn-motion
/plugin install motion-ae-bridge@fynn-motion
/plugin install motion-fx-web@fynn-motion
```
