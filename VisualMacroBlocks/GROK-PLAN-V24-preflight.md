# Work plan: V24 - "Ready to play?" check before a run (planner's pick)

Work on `VisualMacroBlocks-makecode-telek-V23-plain.ahk2`, save as `VisualMacroBlocks-makecode-telek-V24-preflight.ahk2`.
Same rules as earlier plans (V19 plan section 1). Self-test `Failures: 0`, more than 395 PASS. One commit per item + `V24-NOTES.md`.

## V23 review
Accepted as is: 395 PASS, 0 failures. Open points are Windows drawing only (PC check). Nothing to fix.

## Why this round
The commonest reason a replay goes wrong is that it starts from the wrong place: a program in the macro is
not open, or is minimized, or the screen size changed. Today the run discovers this at step 12 and stops halfway.
Catch it BEFORE step 1, in one plain message.

## Item A - pure check
`V24_Preflight(steps, settings, openExes, screenText)` - pure, no windows touched.
- `steps`: `VMF_Flatten(blocks)` (skip `disabled` steps).
- `openExes`: a `Map` of lower-case exe names that are running right now (filled by item B).
- Returns an array of problem lines, each one plain sentence, e.g.
  - `notepad is not open - step 2 uses it.` (one line per missing program, naming its FIRST step number;
    collect programs from each step's `win["exe"]` and from `det_use_window` / `det_normalize_win` targets
    via `V20_TargetName`; skip programs that a `Run` / launch step in the macro starts before their first use -
    if there is no such block kind, skip this rule and say so in the notes);
  - `The screen is 1920x1080 @ 125%, recorded on 1920x1080 @ 100% - clicks may land differently.`
    (from `settings["recScreen"]` vs `screenText`; only when both are set and differ);
  - `Step 7 types into a box that asks you each run.` - NOT a problem; do not list it.
- Self-test: all open -> empty array; one missing; two missing, order by first use; screen differs; disabled step ignored.

## Item B - run it before Play
- In `VMB_Play`, before `VM_Play` (and after `V18_WaitModsUp`), only when the macro has `steady` = 1 and the
  whole macro is played (not "Play selected", not Step by step):
  build `openExes` from `WinGetList()` -> `WinGetProcessName` (lower-case, wrap each in `try`),
  call `V24_Preflight`, and if there are problems show ONE MsgBox:
  title `Ready to play?`, the lines as bullets, then `Yes = play anyway, No = stop so I can fix it.`
  No = return without playing and put the first line in the status bar.
- Never block exported players (`V4_Start` path) - editor only.
- Ini `[V24] Preflight` default 1; right-click menu entry "Check before playing" toggles it.

## Item C - say it in the step list too
In V22's Program column, when a program in the column is not running right now, show its name with a
trailing `?` (e.g. `notepad?`), refreshed only when `VMB_Refresh` runs (no timer). Pure helper
`V24_AppCell(app, openExes)`; self-test it.

## PC check (put in V24-NOTES.md)
1. Close Notepad, press Play on a Notepad macro: the "Ready to play?" box names it; No stops before step 1.
2. Open Notepad, Play: no box, run starts at once.
3. Program column shows `notepad?` while Notepad is closed (after any edit / refresh).
