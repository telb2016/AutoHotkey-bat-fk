# Work plan: V25 - run history: is it repeating the same way? (planner's pick)

Work on `VisualMacroBlocks-makecode-telek-V24-preflight.ahk2`, save as `VisualMacroBlocks-makecode-telek-V25-history.ahk2`.
Same rules as earlier plans (V19 plan section 1). Self-test `Failures: 0`, more than 412 PASS. One commit per item + `V25-NOTES.md`.

## V24 review
Accepted: 412 PASS, 0 failures. Open points (MsgBox look, minimised windows in `WinGetList`, DPI text) need the PC.
One answer: `WinGetList()` lists hidden windows only with `DetectHiddenWindows(true)`; minimised windows ARE listed
without it. Do not change anything for that.

## Why this round
The owner's goal is "replay the same way every time". Today each run's outcome is lost once the status bar changes.
Keep a short history so he can see at a glance whether runs are consistent, and which step keeps causing trouble.

## Item A - record each run (pure parts + one file)
- After every whole-macro run in `VMB_Play` (not Play selected, not Step by step), append one line to
  `<macro file without extension>.runs.csv` next to the macro (skip when the macro has never been saved):
  `When,Result,Seconds,Steps,Notes,NoteSteps` - e.g. `2026-11-15 09:12,Finished,41.3,17,2,"6;12"`.
  Result = `Finished`, `Stopped`, or `Failed at step N`. NoteSteps = step numbers from `V21_NoteSteps(result.Warnings)`.
- Keep only the last 200 lines (rewrite the file when it is longer).
- Pure helpers, self-tested: `V25_RunLine(result, seconds, steps, noteSteps)` and `V25_ParseRuns(text)` (array of Maps,
  tolerant of a missing or broken file).

## Item B - show it
- Right-click menu entry "Run history..." opens a small window (ListView, columns When / Result / Time / Notes) with the
  newest run first, plus one summary line on top made by pure `V25_Summary(runs)`:
  `Last 10 runs: 9 finished, 1 failed (step 6). Usually 41 s. Step 6 had notes in 4 runs.`
  (count the step with the most notes; "usually" = median seconds of finished runs; omit parts that do not apply).
- Self-test `V25_Summary`: no runs; all finished; mixed; most-noted step.

## Item C - one glance in the step list
In the V22 Marks column, a step that had a note in 3 or more of the last 10 runs gets the mark `≈` (ASCII fallback `~`
via `V22_MarkChars`), meaning "often shaky - check this step". Computed in `VMB_Refresh` from the history file once.
Add it to the help paragraph that explains the marks.

## PC check (put in V25-NOTES.md)
1. Save a macro, Play it 3 times: right-click > "Run history..." shows 3 lines and a summary.
2. A step that gets a note in 3 runs shows `≈` in the Marks column.
