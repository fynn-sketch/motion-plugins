---
description: Scaffold a new headless AE automation from a description — copies the skeleton, sets up the control-file convention, and lists the relevant gotchas for the task type.
---

# /ae-scaffold

Set up a new headless After Effects automation from a description. **Do not dispatch or execute anything** — running against AE is a separate, user-initiated step (needs AE open + computer-use for any modal dialog).

## Steps

1. **Read the task** from `$ARGUMENTS`. If empty, ask what the automation should do (which comp, what change, what output).
2. **Create a work dir** `~/Downloads/<name>_ae/` and copy `scripts/skeleton.jsx` and `scripts/dispatch.sh` into it.
3. **Identify the task type** and invoke the matching skill for its rules:
   - Expressions (wiggle, loopOut, auto-fit, faux-3D) → `ae-expressions`
   - Track mattes / pre-comps / parenting → `ae-track-mattes`
   - MOGRT export → `ae-mogrt-export`
   - Camera/planar tracking, match-moving, Dynamic Link → `ae-tracking-workflow` (and note it is a manual GUI workflow, not automation)
   - Any dispatch/log/dialog mechanics → `ae-doscript`
4. **Fill the skeleton** — replace the `// YOUR OP HERE` block with the ExtendScript for this task, and define the `/tmp/ae_control.txt` convention (e.g. `CompName|layer1,layer2|qaTimeSec`).
5. **List the applicable gotchas** for this task type (pulled from the chosen skill) so they're front-of-mind before the user runs it — e.g. one export per dispatch, `motionGraphicsTemplateName` for filenames, the parenting-scale-bake order, the Snell PS-name check.
6. **Hand off to the user** to run `AE_APP=… ./dispatch.sh op.jsx` with AE open, and to clear any modal dialog via computer-use.
