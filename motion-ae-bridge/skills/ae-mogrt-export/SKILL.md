---
name: ae-mogrt-export
description: Use when exporting Motion Graphics Templates (.mogrt) from After Effects headless — exportAsMotionGraphicsTemplate, filename via motionGraphicsTemplateName, the font-sync dialog, bringing non-Adobe fonts in headless, and QA. Codifies the hard-won MOGRT-build gotchas.
---

# AE MOGRT Export (Headless)

Building `.mogrt` templates headless is doable but landmined. These rules come from actually shipping the Viral-Titles and Caption MOGRTs.

## One export per dispatch

Multiple exports in one script run crash with `"Object is invalid"` and leave a `"Temporary…"` comp. Do **one export per DoScript dispatch**, `sleep 6` between them, pass the target comp name via a /tmp control file, and clean temp comps at script start.

## Filename

`comp.exportAsMotionGraphicsTemplate(true, folder)` writes `<motionGraphicsTemplateName>.mogrt` into `folder` — **not** `<CompName>.mogrt`. Set `comp.motionGraphicsTemplateName` first, then search for exactly that name.

## Save first

Call `app.project.save()` before export, or you hit a modal `"project needs to be saved first"` dialog that blocks the dispatch.

## Font-sync dialog

The `"fonts were not synced from Adobe"` modal appears **only for activation-required (Adobe/Typekit) fonts**, not for system-installed TTFs. `app.beginSuppressDialogs()` does **not** help — clear it via the computer-use MCP (screenshot + OK), or confirm once manually and it usually won't reappear that session.

## Non-Adobe fonts, headless

1. Instance a variable font to a static cut via `fontTools.varLib.instancer` (e.g. `wght=700`).
2. Set a clean name table: own family + subfamily `"Regular"`, PS name like `Caveat-Bold`.
3. Drop it in `~/Library/Fonts`, restart AE.
4. **`app.fonts.allFonts` may NOT list user fonts** (FONTCOUNT unchanged) — this is a red herring. Real test: set a `TextDocument` and read `td.fontObject.postScriptName`; if it resolves to your name, AE renders it. Always verify visually via `saveFrameToPng` over black.

## Wrong PostScript name is silently substituted (Snell bug)

`td.font` accepts a wrong PS name silently, then AE substitutes the default at save/export. `"SnellRoundhand-BlackScript"` is **wrong**; correct is `"SnellRoundhand-Black"`. Verify PS names first via `fc-list` / Font Book before assigning `td.font`.

## Cross-links

`ae-doscript` for dispatch + QA mechanics.
