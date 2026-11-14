# V24 notes - handback

File: `VisualMacroBlocks-makecode-telek-V24-preflight.ahk2` (new, copied from V23-plain; older files untouched).
One commit per item (A, B, C), this file last. Rules: V19 plan section 1.

## Result
- Self-test under Wine (AutoHotkey 2.0.27): **412 PASS, `Failures: 0`** (395 before; +11 item A, +0 item B, +6 item C - B adds no pure function). Validate: rc 0, no output.
- After each item: Notepad record / replay (`KEEP MEhello grokbot` / `line2`, 0 notes) and replay of an older (V18-recorded) macro (same result, 0 notes).
- Item B live in Wine: recorded Notepad macro, Notepad closed, Ctrl+Shift+P -> "Ready to play?" box (`notepad is not open - step 2 uses it.`); No -> nothing played, first line in the status bar; Notepad reopened, Play -> no box, run finished normally.
- Item C live in Wine: Program column shows `notepad?` on every row after an edit (Delete + confirm) with Notepad closed.

## Item A (198972ea) - pure check
- `V24_Preflight(steps, settings, openExes, screenText)` -> array of plain sentences. Helper `V24_Programs(steps)` -> array of `[exe, first step number]` in order of first use
  (an ordered array, not a Map: AutoHotkey Maps iterate alphabetically, which would break "order by first use").
- Programs come from a step's `win["exe"]` and from `det_use_window` / `det_normalize_win` targets that name `ahk_exe` (a target with only `ahk_class` is not a program, so it is skipped).
  Switched-off steps are skipped but still count in the step numbering (numbers match the list).
- **No Run / launch block kind exists** in this file, so the "skip programs a launch step starts" rule is skipped, as the plan allows.
- Screen line only when `settings["recScreen"]` and `screenText` are both set and differ. "Asks each run" text steps are not listed.
- Self-test: 11 checks (all open, one missing, two missing, order not alphabetical, screen differs / same / not recorded, disabled step, Use Window + Normalize targets, class-only target, ask-each-run).

## Item B (4d78a755) - run it before Play
- In `VMB_Play`, only when `s.Preflight` and the macro has `steady` = 1 and it is the whole macro (`onlySelected` false, `startMode = "run"`; Step by step and Play selected skip it; a run-to-line counts as whole macro).
- `V24_ReadyToPlay(macro, settings)`: builds `openExes` (`V24_OpenExes`: `WinGetList()` -> `WinGetProcessName`, lower-case, each in `try`), calls `V24_Preflight`; no problems = plays at once.
  Otherwise ONE MsgBox "Ready to play?", bullets, `Yes = play anyway, No = stop so I can fix it.` No = return without playing, first line to the status bar.
- Placement: the check sits just before the run bar / window hiding / undo snapshot are set up (so No needs no clean-up), with its own `V18_WaitModsUp()` call right before it; the original `V18_WaitModsUp()` before `VM_Play` is unchanged.
  This differs slightly from "after V18_WaitModsUp, before VM_Play" on purpose: stopping later would have to undo the hidden editor, run bar and snapshot.
- Editor only: exported players (`V4_Start`) never call it.
- Ini `[V24] Preflight` (default 1) -> `s.Preflight`; right-click > "Check before playing" (ticked when on) toggles and writes ini.

## Item C (60bb4bac) - Program column
- `V24_AppCell(app, openExes, known := 0)`: adds `?` when the program is not running. `V24_MarkApps` applies it to the `V22_FillApps` result.
  Only programs the macro uses by exe (`V24_Programs`) are marked, so `web page` and class-only names are never marked.
- `VMB_Refresh` reads the running programs once (`s.OpenExes`) and marks; the lighter row-refresh path reuses that last list (no new window query). No timer.

## What Wine could not prove
- Real Windows MsgBox look and focus (icon, button focus, that it appears in front of the editor); under Wine it appeared and Yes / No worked.
- `WinGetList` / `WinGetProcessName` on a real PC with many windows, minimised windows (visible-window list should include them, not proven), elevated or protected programs.
- DPI scaling text (`@ 125%`) differing between two real machines.

## PC check
1. Close Notepad, press Play on a Notepad macro: the "Ready to play?" box names it; No stops before step 1.
2. Open Notepad, Play: no box, run starts at once.
3. Program column shows `notepad?` while Notepad is closed (after any edit / refresh).
4. Right-click > "Check before playing" untick: Play with Notepad closed gives no box (old behaviour).
5. Minimise Notepad, Play: no box (a minimised program counts as open).
6. Step by step (F10) and Play only selected never show the box.
