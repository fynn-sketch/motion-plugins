# motion-plugins

A Claude Code plugin marketplace for motion-graphics work.

## Plugins

- **motion-craft** — tool-agnostic motion-design knowledge layer: easing, the 12 principles, timing & pacing, kinetic typography, compositing architecture, plus a `/motion-review` command. Makes any runtime (HyperFrames, Remotion, GSAP) produce organic, principled motion.
- **motion-ae-bridge** — drives After Effects headless via the DoScript pipeline: scripted expressions, track mattes, pre-comps, and MOGRT export with baked-in gotchas, plus a guided GUI workflow for non-scriptable tracking and an `/ae-scaffold` command.

## Install

In an interactive Claude Code session:

```
/plugin marketplace add fynn-ignacczak/motion-plugins
/plugin install motion-craft@fynn-motion
/plugin install motion-ae-bridge@fynn-motion
```

Or from a local checkout:

```
/plugin marketplace add ~/Developer/motion-plugins
/plugin install motion-craft@fynn-motion
/plugin install motion-ae-bridge@fynn-motion
```
