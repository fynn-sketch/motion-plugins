---
name: ae-expressions
description: Use when setting After Effects expressions via script instead of hand-keying — wiggle(), loopOut(), auto-fit text via sourceRectAtTime, editable faux-3D extrusion, gradient/glow via effect matchnames. Includes the scripting gotchas (temporal-ease dimensions, comp-invalid-after-export).
---

# AE Expressions via Script

One expression replaces hundreds of keyframes. Set them from ExtendScript on a property's `.expression`.

- `wiggle(2, 10)` — organic jitter (freq 2/sec, amplitude 10). The classic anti-mechanical trick.
- `loopOut()` — cycle keyframes forever without duplicating them.

## Auto-fit text (variable length)

Insert an extra null **"FIT"** between the pop-controller and the text layer, with this scale expression:

```javascript
maxW = 960;
w = thisComp.layer("WORD").sourceRectAtTime(time, false).width;
s = (w > maxW) ? maxW / w * 100 : 100;
[s, s]
```

`sourceRectAtTime` is independent of the parent transform → no circular reference. Long words shrink, short words stay at 100%.

## Editable faux-3D extrusion

N dark text duplicates, each offset by (dx, dy) behind the front word, each with:

```javascript
thisComp.layer("WORD").text.sourceText.value.text
```

This returns the **string** — so each copy keeps its own dark color. (Returning the whole `TextDocument` would inherit the front color.) All depth copies then follow the edited word automatically.

## Effect matchnames that work

- Gradient on text: effect `ADBE Ramp` (fills RGB, alpha stays). Start/End in comp coordinates; renders before the parent transform, so it survives FIT-scale.
- Glow: `ADBE Glo2` (0012/0013 = Color A/B, 0007 = 2 for A&B).
- Text animators: `ADBE Text Opacity`, `ADBE Text Blur`, `ADBE Text Position 3D` (2D values ok), `ADBE Text Tracking Amount`, `ADBE Text Percent Start/End`, `ADBE Text Selector Smoothness`.

## Gotchas

- `setTemporalEaseAtKey` expects arrays matching the property dimension — but 2D scale often still wants a **single** element. Wrap ease-setting in try/catch.
- After `exportAsMotionGraphicsTemplate`, the comp variable is **invalid** (`"Object is invalid"`). Render QA PNGs *before* export, or re-fetch the comp by name via `app.project.item(i)`.

## Cross-links

`ae-doscript` for how to dispatch these. `motion-easing` (motion-craft) for which curve a move should ride.
