# V25 notes - handback

File: `VisualMacroBlocks-makecode-telek-V25-history.ahk2` (new, copied from V24-preflight; older files untouched).
One commit per item (A, B, C), this file last. Rules: V19 plan section 1.

## Result
- Self-test under Wine (AutoHotkey 2.0.27): **442 PASS, `Failures: 0`** (412 before; +16 item A, +7 item B, +7 item C). Validate: rc 0, no output.
- After each item: Notepad record / replay (`KEEP MEhello grokbot` / `line2`, 0 notes) and replay of an older (V18-recorded) macro (same result, 0 notes).
- Item A live: the old macro opened from a file and played 3 times wrote 3 lines to `old.vmacro.runs.csv` (`Finished,2.3,5,0,""`); an unsaved ("Untitled") macro wrote no file.
- Item B live: right-click > "Run history..." opened the window: summary `Last 3 runs: 3 finished. Usually 2 s.` and 3 rows, newest first.
- Item C live: a hand-made history with step 3 noted in 3 runs showed `≈` in the Marks column of step 3 only.

## Item A (f0580f6d) - record each run
- `V25_RunLine(result, seconds, steps, noteSteps, when := "")`, `V25_ParseRuns(text)`, plus `V25_TrimRuns`, `V25_RunsPath`, `V25_ReadRuns`, `V25_RecordRun`, `V25_SortNums`.
- `VMB_Play`: after a whole-macro run (`startMode = "run"`, not Play selected, not Step by step) one line is appended. **Also skipped for a run-to-line** (it stops on purpose, so it would look like a short "Finished" run) - the plan did not mention this case.
- File: `<macro file without its last extension>.runs.csv`, e.g. `order.vmacro.json` -> `order.vmacro.runs.csv`. Written only when the macro has a saved path.
- A **header line** (`When,Result,Seconds,Steps,Notes,NoteSteps`) is written first; "last 200 lines" means the newest 200 run lines, the header stays on top.
- Result: `Finished` (also "Ended by macro"), `Stopped`, `Failed at step N` (`Failed` when no step number is known). Seconds with one decimal.
- Any file error (read-only folder) is ignored: no history, no error box.

## Item B (1e58487f) - show it
- `V25_Summary(runs)`: last 10 runs: `Last 10 runs: 9 finished, 1 failed (step 6). Usually 41 s. Step 6 had notes in 4 runs.` One run reads `Last run: ...`; stopped runs are counted as `N stopped`; no runs = `No runs yet.`; ties for most notes keep the lower step.
- `V25_ShowHistory`: right-click menu "Run history..." (under "Check before playing"): ListView When / Result / Time / Notes (notes as `2 (steps 6, 12)`), newest first, Close button / Esc. Unsaved macro: the status bar says to save first.

## Item C (c65d6a94) - one glance
- `V25_Shaky(runs)`: steps with a note in 3 or more of the last 10 runs (a step counts once per run). `VMB_Refresh` reads the history file once (`s.Shaky`); the lighter row refresh reuses it.
- Marks column: `≈` after the other marks (plain marks: `~`, `V22_MarkChars` key `shaky`). Both help texts explain it.
- Step numbers in the file are the numbers at the time of the run: if steps are inserted or deleted afterwards, an old `≈` can point at a different step until new runs replace the old lines.

## What Wine could not prove
- Real Windows look of the "Run history" window (font, spacing, ListView column widths) and whether `≈` is drawn in the Marks column font on the PC (if it shows as a box, the ini `[V22] PlainMarks=1` gives `~`).
- Write access to the macro folder on the work PC (network drive, OneDrive); runs on such a folder were not tried.
- Real runs that end with notes (Wine runs here had none): the NoteSteps column and `≈` were proven with a hand-made file and self-test only.

## PC check
1. Save a macro, Play it 3 times: right-click > "Run history..." shows 3 lines and a summary.
2. A step that gets a note in 3 runs shows `≈` in the Marks column.
