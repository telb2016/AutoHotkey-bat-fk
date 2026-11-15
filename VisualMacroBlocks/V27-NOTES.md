# V27 notes (partial round: item 0 and Item A only)

File: VisualMacroBlocks-makecode-telek-V27-grid.ahk2 (copy of V26-pccheck).
Self-test: `Failures: 0`, **524 PASS** (V26 had 466).

## Item 0 - V26 review fixes
- "Check this PC" scroll test now runs in a separate helper program (`V27_ScrollTests`): a 300-row list box
  and a 300-line text box, started with `A_AhkPath` from a temp .ahk, closed by PID, temp file deleted.
  Both controls are tested (`V27_ScrollOne`); result lines say "Scroll (list box)" / "Scroll (text box)".
- Notepad is used only for the size test (`V26_NotepadTests`). Its position and size are read when found and
  put back (WinMove) before it is closed.
- Not verified: under Wine the helper's scroll bars report no range (GetScrollRange 0..0, GetScrollInfo 0), so the
  scroll read could not be checked here. The self-test does not cover it. Needs a check on the PC.
- If the owner runs a compiled .exe, `A_AhkPath` is the exe and the helper will not start; both scroll lines then
  show CHECK "could not open the test list window".

## Item A - cell data (pure)
- `V27_Columns` (22 columns), `V27_Cells(node, ctx)` (every key filled, "–" when not applicable), `V27_Rows(blocks,
  settings, state)` (walks like VMF_Flatten; "#" is the tree's number; Inside chain from the container labels).
- Choices that differ from or extend the plan:
  - Rows: every non-container block gets a row (set, ask, stop, call too), not only steps. Their Action is "Other".
  - Scroll back shows `row N` as stored position + 1 (the stored position is 0-based, as in V19).
  - Checks picture also says "no" when the step has `noVerify` set.
  - ctx and state are Maps (not objects). Each row Map also has `.Node` (the step's node) for the grid in Item B.
  - No `Starts` in ctx (no column uses it yet).
  - Main-window class is taken as "AutoHotkeyGUI" (the class of every AutoHotkey Gui).
- Self-tests: one check per column kind (click, double/right click with geo, typed text, ask text, keys, wheel,
  Normalize, waits, disabled, window kinds, Inside chain, last run, shaky, scroll, held keys, checks picture),
  and rows: nested Inside, numbering, node kept, no empty cell.

## Not done (out of this run's scope)
- Items B, C, D, E of V27, Part 2 (V28), help text / version. Line 1 and the window title still say V26.

## Fix to Item A - Window column
- "main window" now means: the step's window class equals the class in the macro's Macro-window setting
  (`defaultTarget`, the class after `ahk_class`). New `V27_MainClass(settings)`; `V27_Cells` passes it to `V27_WindowText`.
  With no Macro window set nothing is called "main window" (the plain class name shows). 529 PASS after this fix.

## Item B - the grid in the window
- `s.GridLV` (ListView, report mode, grid lines, single selection, double-buffered) is built last in `VMB_BuildGui`
  (`V27_BuildGrid`) with the buttons `c["ViewList"]`, `c["ViewGrid"]`. Not in the tree's place in the code: it is *moved to the
  tree's geometry* by `V27_PlaceGrid`, which `V22_PlaceHeader` calls at its end. That one hook covers resize, zoom, Easy/Full
  switch and refresh. The tree is hidden (not destroyed) in grid view, the V22 header line is hidden too.
- The [List] [Grid] buttons sit at the right end of the header line above the list (the current view's button is greyed).
  Both are in the Easy layout, so the Easy-layout self-test count went from 27 to 29.
- `V27_FillGrid(rows := "")`: default = all steps in step order; a later sort / filter can pass its own row array.
  Keeps `s.GridRows`, `s.GridNodes` (row -> node), `s.GridRowOf` (node -> row). Called at the end of `VMB_Refresh` in grid view.
  Column widths fitted on the first fill with rows (not below the start width, capped at 320 px for text, target, inside, note, lastrun).
- Selection: grid row -> `s.TV.Modify(...,"Select")` (`V27_OnSelect`); after a refresh the tree's selected step is selected in the
  grid (`V27_ShowNode`); `VMB_PlayStatus` selects the running row in grid view (the tree is not touched). Double-click = Edit,
  right-click = `VMB_TreeMenu`. View is remembered in the ini (`[V27] View`, default grid).
- `s.HasRun` (set after a run, cleared on new / open) and `s.History` (run history file has rows) feed the Last run / Often shaky columns.
- Help: line 1 and both window titles say V27; "NEW IN V27" paragraph in `V4_Help` and `V17_EasyHelp`.
- Self-test: **537 PASS**, Failures 0 (8 new checks incl. the fill on a hidden window).
- Seen live (Wine, harness, 9 steps incl. a Repeat): grid shows 9 rows, in Full and Easy mode, the grid has exactly the tree's
  position and size (logged equal) before and after resize, zoom and mode switches; tree visible again in list view.
  Screenshot `V27-grid-preview.png`: headers, grid lines, filled cells, "–" in non-applicable cells, grid where the tree was.
  Keyboard Down in the grid moved the tree selection to the same step.
- Unsure: under Wine a `ListView.Modify(row, "Select")` from code does not raise the ItemSelect event (a real Down key does), so
  selection sync was checked via the key press and by calling the handler directly; mouse clicks could not be tested here.
  Double-click / right-click handlers and the playback row follow are written but not exercised live. The grid font looks larger
  than the tree's under Wine (font fallback); not checked on Windows.
- Not done: items C (sort), D (filter), E (copy), Part 2 (V28); PC-TEST-ALL "Grid" section.

## Fixes before C / D / E
- Grid font: set like the tree's (`V27_ApplyGridFont`: "MS Shell Dlg 2" first, then Segoe UI, at `s.FontSize`). Under Wine the old
  `SetFont(..., "Segoe UI")` alone fell back to the big system font; this is why the grid looked larger than the window. `VMB_Zoom` (A+ / A-) now
  calls it too (seen: size 12 in the grid after a zoom of +3 from 9).
- Step numbers: unchanged (they match the tree and can skip a number where a Repeat / If block has one). Sorting by `#` is numeric, so
  1, 2, 4, 5, 10 stays in that order (self-test). The "Step order" button / `#` header restore the array order of `V27_Rows`.
- Layout: the new controls are NOT in `s.Ctl`; they are in `s.GridBar` (Map: Filter, Prog, Act, Clear, Reset, Copy) and placed by
  `V27_PlaceBar` from `V27_PlaceGrid`. One row (24 px) directly above the grid, grid view only, Easy and Full; the grid's top moves
  down by that row + 4 px, the tree and the Easy-layout control count (29) are unchanged.

## Item C - sort
- Click a header: ascending, again descending, small up / down triangle in the title (`V27_SortMarks`). `#` header and the "Step order"
  button: back to step order. Own sort: pure `V27_SortRows(rows, key, desc, isNum)` (stable merge sort, `V27_CmpRows`), `–` always last,
  numbers as numbers; the ListView's own sort is not used, so `GridNodes` / `GridRowOf` stay right. State: `s.SortKey`, `s.SortDesc`.
- Status: `Sorted by Program - this is only a view; steps still run in # order.` (`V27_ViewStatus`, from `V27_Refill`).
- `V27_FillGrid()` with no argument now rebuilds `s.GridAll` (all rows, step order) and shows `V27_ViewRows()` (filter, then sort);
  `V27_FillGrid(rows)` still shows exactly the given rows. `s.GridRows` = rows shown.
- Self-test: 8 checks (numbers, text, dash last, descending, stable, skipped step numbers, input untouched, edge cases). 545 PASS.

## Item D - filter
- Filter box (cue text "Filter..."), Program and Action drop-downs (All + each value found in the current rows), Clear button.
  `V27_FilterRows(rows, query, columns)`: words are ANDed, a word matches any cell (case-insensitive); `column:word` uses the column key or its
  title without spaces (`program:notepad`, `action:click`, `windowsize:800`); `program:` with no word yet = no limit; unknown column = plain text.
  Drop-downs match the whole cell exactly (`V27_PickRows`), so a program shown as `notepad?` is picked as `notepad?`.
  Filter and sort combine (`V27_ViewRows`). Status: `Showing 6 of 41 steps` (plus the sort sentence when sorted).
- Run: `V27_RunStart` (after `s.PlayFlat` is set in `VMB_Play`) saves and clears the filter, `V27_RunEnd` puts it back; the running row is never hidden.
- Self-test: 11 checks (any cell, column, several words, key, empty, `program:`, unknown column, no match, pick, distinct). 556 PASS.
- Under Wine, setting `Edit.Value` from code does not raise the Change event; typing with SendInput does (used for the live check).

## Item E - copy to Excel
- "Copy table": `V27_CopyTable` puts `V27_Tsv(s.GridRows, V27_Columns(), true)` on the clipboard: header row, tab between cells, CR LF between rows,
  tabs / line breaks inside a cell become a space. Ctrl+C in the grid (`#HotIf V27_GridFocused()`) copies the selected row only, WITHOUT a header row
  (my reading of "the same way": same format; a single row pastes better without a header). Easy to change in `V27_CopyRow`.
- Self-test: 4 checks (header + rows, no header, no rows, no tab / line break left). 560 PASS.

## Live check (Wine, harness, 9 steps in two programs incl. a Repeat; real key presses for typing and Down)
- Filter row at the grid's top in Easy and Full (same y as the tree top, grid 28 px lower), nothing overlaps; hidden in list view; tree unchanged there.
- Program asc / desc: 6,7,8,9,10,1,2,4,5 / 1,2,4,5,6,7,8,9,10 (rows are numbered by the # column, which skips 3). `#` click and Step order: 1,2,4,5,6,...
- Typed `hello`: row 4 only. `program:chrome`: 6-10. Drop-down Program: 1,2,4,5; plus Action=Window: row 1. Clear keeps the sort, Step order then clears it.
- Statuses seen: `Showing 4 of 9 steps`, `Sorted by Program - this is only a view; steps still run in # order.`, both together.
- Copy table with filter `chrome` + sort: clipboard 6 lines (header + 5), 22 tab-separated columns. Ctrl+C path (`V27_CopyRow`) called directly: one row.
- Selection while filtered `chrome` + sorted by Action, key Down x3: grid row 3 (#7, Scroll) selected the tree's wheel step.
- RunStart / RunEnd called directly (no real playback): filter cleared (9 rows), then restored (`chrome`, 5 rows).
- Not verified: a real mouse click on a header, the Ctrl+C hotkey itself, a real playback with a filter on, Windows appearance (screenshot `V27-grid-preview.png` is Wine).
