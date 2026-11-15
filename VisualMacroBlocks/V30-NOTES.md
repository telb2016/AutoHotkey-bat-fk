# V30 notes (loops without loop blocks: List sheet, =Column cells, Run switch)

File: VisualMacroBlocks-makecode-telek-V30-listsheet.ahk2 (copy of V29-excel). Self-test: `Failures: 0`, **724 PASS** (V29 had 665).
All new code is one section `V30_*` above the "V4 STARTUP" line. New controls live in `s.RunBar`, `s.SheetTabs`, `s.ListBar`, `s.ListLV` (not in `s.Ctl`; Easy / Full layout and its control count unchanged).
Placed by `V30_Place`, called from `V27_PlaceGrid`: rows are Run line, filter row (Steps sheet) or list buttons (List sheet), the grid / list, then the Steps | List tabs. Visible in Easy and Full, only in grid view.

## Done
- **Item A (List sheet).** `settings["list"] = Map("headers", [..], "rows", [[..]])`, max 5000 rows / 30 columns. Pure: `V30_ColName`, `V30_ParsePaste`, `V30_ListData` (same shape as `VM_LoadData`).
  Header guess (no `V18D_GuessHeader` in the file): header when >= 2 lines, no cell a number, none empty, all different. Paste list / Ctrl+V, Add row, Delete row, Clear list, rename a column by clicking its name,
  double-click / F2 / Enter / typing edits a cell with its own overlay Edit (the V28 editor is tied to the Steps grid, so it was not reused: `V30_ListOpen`, Enter / Tab / Shift+Tab / Esc), Delete empties a cell, Ctrl+C copies it.
  Deviations: the list has its own undo (`s.ListUndo`, Ctrl+Z / Ctrl+Y on the List sheet) because `VMB_Snapshot` only stores the blocks; list edits call `V7_ScheduleAutoSave` and set Dirty but no `VMB_Snapshot`
  (that is used where steps change: auto-match, rename, Use list column). Column 1 of the sheet is `#` (row number), column 2 `Result` (width 0 until a run), then the data columns.
- **Item B.** `V30_ToStored / V30_ToShown / V30_Preview / V30_TextCell / V30_Match / V30_MatchText`; `=Name`, `=#` (stored `{{index}}`), `'=x` for a text starting with `=`. Hooked into `V28_EditText`, `V28_Plan`, `V27_Cells`.
  Only active when the macro "uses the list" (`V30_Gate`: it has a list, or runMode is list / times), so old macros show and edit exactly as in V29. Auto-match question after a paste (Yes -> `{{Name}}`, snapshot, undo with Ctrl+Z on the Steps sheet).
  Right-click on a Type text cell: menu "Use list column" (each column and `#`), "Type fixed text...", "Other step actions..." (`V30_TextMenu`; the menu itself was NOT shown under Wine, `Menu.Show` blocks - the code path `V30_UseColumn` was only reached by direct call).
  Preview row control: `Preview row: ◄ [1] ► of N` on the Run line (drops out when the line is narrow). In "times" mode it is labelled `Round:`.
- **Item C.** Run line (`once / for each row of the List (N rows) / [n] times`), `settings["runMode"]`, `["runTimes"]`. New grid column **Repeats** (after Waits first, so the grid has 23 columns; two V27 / V29 self-test numbers were updated) with a drop-down `yes / once at start`, stored as `node["once"]` 1 / 0.
  Default rule `V30_OnceFlags`: leading Normalize / Use Window steps are once; only a leading run may be once (`V30_SetOnce` refuses with a sentence). `V30_BuildRun(macro)` builds the run macro in memory (nodes shared; the saved macro is never changed):
  once -> same macro; list -> lead + `foreach` (data = `V30_ListData`); times -> lead + `repeat N`. Empty list / bad number / nothing to repeat -> sentence. A macro with hand-made loop blocks: the switch is replaced by the note and the macro plays as it is.
  Runner changes (all gated by a flag only the built macro has, so old macros are unaffected): `foreach` node with `v30` sets `LoopIndex` to the row number (so `=#` works in list mode); `OnFailure` with `v30Row` skips the row (`nextrow`, the "click falls back to coordinates" step is still tried first
  when the user's policy was `coords`); a failure in a once-at-start step stops the run; `RowLog` (row -> reason) and `RowsSeen` are returned in the result. Status sentence `12 rows: 11 done, 1 skipped (row 7).`, `Finished: ran 3 times.`; List sheet Result column (not saved).
  `rowFailLimit` does not exist in this file, so "stop after 3 bad rows in a row" was NOT done.
  Exported single-file player: `V4_Start` now calls `V30_BuildRun` (and sets `options.Data` for list mode) before `VM_Play`, so a macro exported with runMode list / times runs the same way; the list is inside the exported macro JSON. Not run (no player was exported in the test).
- Version text: line 1, both window titles, "NEW IN V30" in `V4_Help` and `V17_EasyHelp`, the plain 4-step paragraph at the top of `V17_EasyHelp`. PC-TEST-ALL.md section 6 "List".

## Not done
- **Item D (band rows for hand-made loop blocks in the grid)** was not started.
- Stop after 3 bad rows in a row (no `rowFailLimit` helper exists).

## Seen live (Wine, harness, real Notepad, `VMB_Play` and real key presses)
- 5 steps (Use Window, Type Smith, Tab, Type 250, Enter) + pasted 3-row list, auto-match accepted: texts became `{{Name}}` / `{{Amount}}`, grid cells `=Name → "Smith"`, preview row 2 gave `Jones` / `75`.
- List run: Notepad text exactly `Smith<tab>250 / Jones<tab>75 / Lee<tab>5` (3 lines), status `3 rows: 3 done.`, Result column `done` x3. Saved file (VM_Save then read back): has `list`, `runMode`, `{{Name}}`, no `foreach` / `repeat`; reloaded: 5 blocks, 3 rows; in-memory macro still 5 blocks.
- Bad row (a Call step with a missing file on row 2): text `Smith / JonesLee`, status `3 rows: 2 done, 1 skipped (row 2).`, Result `skipped: step #2: (2) File not found.`; saved onFail stayed `ask`.
- Times mode with `=#`: Notepad `1 2 3`, status `Finished: ran 3 times.`; list mode with `=#`: `1 2`; empty list in list mode: the sentence `The List is empty...`.
- List sheet: Ctrl+V with a real key press (dialog text checked, Yes clicked), F2, typed text + Tab to the next cell, Enter saves and selects the next row, Ctrl+Z, typing `x` opens the editor, Esc cancels, add / delete row, rename (steps follow), clear + undo, Repeats cell rules.
- Screenshots: `V30-preview.png` (Steps grid: Run line, `=Name → "Smith"`, `=Amount → "250"`, Preview row, tabs) and `V30-list-preview.png` (List sheet with Result column `done`).

## Not verified / unsure
- Mouse use (clicking the radios, tabs, buttons, header rename, double-click on a list cell, the right-click menus): mouse hooks do not work under Wine; handlers were called directly or reached by keyboard.
- Look under Windows scaling (125 / 150 %); the Run line width at narrow windows (the preview control drops out below ~480 px of grid width).
- The list sheet editor uses a plain single-line Edit: a cell with a line break (quoted in the paste) is shown on one line.
- The status text for a skipped row names the step as `step #N` of the saved macro (run macro index minus the added For each block).
