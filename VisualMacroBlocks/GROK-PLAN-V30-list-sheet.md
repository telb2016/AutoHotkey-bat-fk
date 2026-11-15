# Work plan: V30 - loops without loop blocks: a "List" sheet and a "Run for each row" switch

Do this AFTER V29. Work on the newest version file (`...-V29-excel.ahk2`), save as `VisualMacroBlocks-makecode-telek-V30-listsheet.ahk2`.
Same rules as earlier plans (V19 plan section 1). Prefix `V30_`. Self-test `Failures: 0`, more PASS than V29. One commit per item + `V30-NOTES.md`.

## The owner's problem (his words): "I am struggling to understand how to do the loops."
He thinks in Excel. Loop blocks (Repeat / For / For each, `{{i}}`) are programmer ideas. Replace the idea, not the engine:

> **Steps sheet** = what to do once.  **List sheet** = the things to do it for.  **One switch** = "Run for each row of the List".

No blocks to drag, nothing to nest. The existing `foreach` engine, `{{Column}}` placeholders and results file do the work underneath.

## Item A - the List sheet (pure parts first)
- Two tabs under the grid, like Excel sheet tabs: **[Steps]** **[List]**. Steps = the V27 grid. List = a second ListView grid.
- The list lives IN the macro file: `settings["list"] = Map("headers", [..], "rows", [[..], ..])` (max 5000 rows, 30 columns).
  Old macros have no `list`; nothing changes for them.
- List sheet: first row = column names (shown as the header; default names `A`, `B`, `C` ... like Excel when the pasted
  data has no header - reuse `V18D_GuessHeader` if present in this file, else: first row is a header when no cell in it
  is a number and all are different). **Paste from Excel** (Ctrl+V with the List sheet focused, or a "Paste list" button):
  tab / line separated text -> rows. Cells editable with the V28 overlay editor (reuse it; all cells are plain text).
  Buttons: Paste list, Add row, Delete row, Clear list. Every change: `VMB_Snapshot()`, dirty, autosave.
- Pure, self-tested: `V30_ParsePaste(text)` -> {headers, rows}; `V30_ColName(n)` (1 -> A, 27 -> AA);
  `V30_ListData(settings)` -> the `{Headers, Rows, DrugCol}` object the runner already takes as `opts.Data`
  (see `VM_LoadData` for the exact shape).

## Item B - use a list column in a step, Excel-formula style
- In the Steps grid, the Text cell of a Type step may be written as `=Name` (or `=A`). Stored in the node as the existing
  placeholder `{{Name}}`; mixed text works too: `Dr. =Name` is NOT supported - only a whole-cell `=Column`, or the
  existing `{{Column}}` inside longer text (mention in help). Pure `V30_ToStored(cellText, headers)` /
  `V30_ToShown(storedText)`; unknown column -> refused with a plain sentence listing the column names.
- Right-click a Type step's Text cell -> "Use list column ▸" with each column name (and "Type fixed text...").
- **Auto-match after pasting a list** (the key convenience): if the list's FIRST data row has a cell equal to the text a
  Type step types, offer once: `Step 4 types "Smith", which is row 1 of column Name. Use the Name column there? (same
  for 2 more steps)` Yes -> those steps become `=Name` etc. Pure `V30_Match(steps, headers, row1)`; self-test.
- **Preview row** spinner above the grid (`Preview row: [ 1 ] of 12`): Text cells that use a column show what will be
  typed for that row: `=Name → "Smith"`. Pure `V30_Preview(storedText, headers, row)`.

## Item C - the switch
- Above the grid, one line, always visible in grid view:
  `Run:  (•) once   ( ) for each row of the List (12 rows)   ( ) [ 5 ] times`
  Stored as `settings["runMode"]` = `once` / `list` / `times`, `settings["runTimes"]`.
- **Which steps repeat:** a new grid column "Repeats" (`yes` / `once at start`), editable by drop-down. Default: the leading
  window-setup steps (Normalize / Use Window at the very top) are `once at start`, everything else `yes`. Only a leading
  run of steps may be `once at start` (refuse otherwise with a plain sentence). Stored per node as `once` = 1.
- At Play, when runMode is not `once`, build the macro to run WITHOUT changing the saved one:
  `[once-at-start steps] + [foreach { repeating steps }]` (or `repeat N`), data = `V30_ListData(settings)`.
  Pure `V30_BuildRun(macro)` returning a new macro Map that shares the step nodes; self-test: once -> same blocks;
  list -> lead + one foreach holding the rest; times -> lead + repeat N; empty list in list mode -> error sentence.
  Bad rows: in list mode use the "skip this row and go on" policy for the run (`onFail` = `nextrow` on the built macro
  only) and stop after 3 bad rows in a row if that helper exists in this file (search `rowFailLimit`; if not, skip it).
- A macro that already contains loop blocks made by hand (Repeat / For / For each): the switch is disabled with the note
  `This macro has its own loop blocks (see List view).` Do not try to combine the two.
- After a list run, the status bar: `12 rows: 11 done, 1 skipped (row 7).` and the List sheet gets a first column
  "Result" (`done` / `skipped: <reason>`), cleared at the next run. Not saved in the file.
- `{{i}}`-style counter for "N times": the column name `=#` means the round number (1, 2, 3 ...), also usable in list mode.

## Item D - show hand-made loops in the grid too
For macros that do have loop blocks, the Steps grid shows each block as a shaded band row (text in the Action column:
`Repeat 5 times`, `For each row`, `If ...`; other cells empty) with its steps under it, indented two spaces per level in
the Action column. Band rows are not editable and sort/filter treats them as part of their steps (when sorted by
anything but `#`, bands are hidden).

## Help (plain words, in `V17_EasyHelp`, first paragraph)
"To do the same thing for many items: 1. Record it once for the first item. 2. Click the List tab and paste your items
from Excel. 3. Say Yes when asked to use the list columns. 4. Choose 'for each row of the List' and press Play."

## Live check (Wine) and PC check
Live: record-free harness: 5 hand-made steps typing "Smith" Tab "250" Enter into Notepad; paste a 3-row list by
`V30_ParsePaste`; accept the auto-match; preview row 2 shows the second row's values; run in list mode; Notepad's text
equals the three expected lines; Result column filled; saved macro file still has no loop block; `times` mode with `=#`.
Screenshot of the List sheet and of the Steps grid with `=Name → "Smith"` -> `V30-preview.png`.
PC-TEST-ALL.md new section "List": the four help steps on a real program.
