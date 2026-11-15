# Work plan: V27 - Excel-style step grid (real cells, sort, filter)

Work on `VisualMacroBlocks-makecode-telek-V26-pccheck.ahk2`, save as `VisualMacroBlocks-makecode-telek-V27-grid.ahk2`.
Same rules as earlier plans (V19 plan section 1). New functions prefixed `V27_`. Self-test `Failures: 0`, more than
466 PASS. One commit per item + `V27-NOTES.md`.

## V26 review
Accepted: 466 PASS, 0 failures. Two fixes, do them first (item 0):
- Windows 11 Notepad has no classic `Edit1` box. In "Check this PC", do not use Notepad for the scroll test: create the
  test list in a SEPARATE helper process so it counts as "another program": write a tiny temp .ahk (a Gui with a
  300-row ListBox and a multi-line Edit) and run it with `A_AhkPath`; test both controls; close it by PID and delete
  the temp file. Keep Notepad only for the size test.
- The size test must put the window back where it found it (position AND size) before closing it.

## What the owner asked for (his words, shortened)
"Keep improving the column information: more columns, sort / filter. Make it super easy to tell what each step does -
clicks, keys, which program, window size, everything you can think of. Every row has every column filled in. It should
look like Excel cells."

## Design decision
Padded text in the tree cannot give real cells, sorting or filtering. Add a real grid: a **ListView in report mode with
grid lines** that sits exactly where the tree is, switched by two small buttons above the list: **[List] [Grid]**.
- The tree stays the single source of truth and keeps all editing (drag, tick boxes, nesting). It is only hidden.
- The grid is a VIEW: one row per STEP (containers are not rows; they appear in the "Inside" column).
- Selecting a grid row selects the same step in the hidden tree (`s.TV.Modify(s.NodeItem[node], "Select")`), so every
  existing button (Edit, Delete, Move up / down, Test, Play selected ...) keeps working unchanged. Double-click = Edit.
- Sorting and filtering change only what is shown. They never reorder or change the macro.
- Remember the choice in the ini (`[V27] View` = list / grid; default grid in Easy mode AND Full mode).

## Item A - the cell data (pure, fully self-tested)
`V27_Columns()` returns the columns in order: `{Key, Title, Width, Num}` (`Num` = sort as number).
`V27_Cells(node, ctx)` returns a `Map` Key -> text for one step. **Every key always has a value; when it does not apply
use `–` (en dash), never an empty string.** `ctx` = `{Num, App, Starts, Inside, LastNote, Shaky, Open, Settings}`.

| Key | Title | Content |
|---|---|---|
| num | # | step number |
| inside | Inside | chain of blocks the step is in: `Repeat 5 › If amount is 250`; `–` at top level (build from `V21_BlockLine`, without the "(n steps inside)" part) |
| app | Program | `V22_FillApps` value (always filled), with V24's `?` when not running |
| window | Window | kind of window the step uses: for a step with `win`: its class in plain words - `main window` when the class equals the Macro window's class, `dialog` for `#32770`, `menu` for `#32768`, else the class name; for Use Window / Normalize: the target's class or `–` |
| winsize | Window size | recorded window size: `geo["ww"] × geo["wh"]` (or `maximized` when `geo["max"]`); for Normalize its own width × height; for other steps the size from the nearest earlier step in the same program that had one; `–` when none |
| action | Action | one word group: `Click`, `Double-click`, `Right-click`, `Drag`, `Scroll`, `Type`, `Press`, `Wait`, `Window`, `Web`, `Other` |
| target | On what | `V20_WhatText(node)` (`the "OK" button`, `a text box`); for web steps `V21_SelectorName`; else `–` |
| text | Text / keys | typed text in quotes (`V20_Short`, 50), `(asks each run)` for ask steps - never the text; for keys `V20_KeysText`; for wheel `down × 3`; else `–` |
| button | Button | `Left` / `Right` / `Middle`; `–` for non-mouse steps |
| clicks | Clicks | `1`, `2`, `3`; `–` for non-mouse |
| held | Held keys | `Ctrl`, `Shift`, `Ctrl+Shift`; `none` for mouse steps without; `–` for non-mouse |
| x | X | `geo["cx"]` (else `scrX`); `–` |
| y | Y | `geo["cy"]` (else `scrY`); `–` |
| zone | Where | `V20_Zone(...)`; `–` |
| anchor | Follows | which edges the spot follows when the window changes size: `top-left`, `bottom-right`, `top, scaled across` ... from `geo["ax"]`/`geo["ay"]` (reuse `V14_AnchorText` without "from "); `screen spot` for old steps; `–` |
| wait | Waits first | `V22_WaitText(node)`; `0` when none |
| scroll | Scroll back | `row 150` (from `scroll["v"]`, plus `, col N` when `h`); `no` for mouse steps without; `–` otherwise |
| check | Checks picture | `yes` for click/drag steps with a `pattern` when the macro is `steady` and `verifyClicks` is not 0; else `no`; `–` for non-mouse |
| lastrun | Last run | `ok`, or the note text (shortened to 60) from `ctx.LastNote`; `not run yet` when there is no last run |
| shaky | Often shaky | `yes` / `no` from V25 history; `no history` when none |
| onoff | On | `on` / `off` (disabled) |
| note | Note | the step's note; `–` |

Helper `V27_Rows(blocks, settings, state)` walks the blocks once and returns the array of cell Maps in step order
(compute `Inside` on the way down; carry the last window size per program). Keep it pure: `state` carries
`LastNotes`, the shaky map, the open-programs map and whether there was a last run.
Self-tests: one check per column for a click, a typed text, a keys step, a wheel step, a Normalize step, an ask-text
step (text never shown), a nested step (Inside chain), and one check that NO cell of any of those rows is `""`.

## Item B - the grid in the window
- `c["Grid"]` cannot be used (already the "Step grid..." button). Name the control `s.GridLV`.
  Create it in `VMB_BuildGui` with the tree's position and options `"Grid -Multi +LV0x10000 Hidden"` (grid lines, single
  selection, double-buffered), font Segoe UI at the tree's size. `VMB_OnSize` and the Easy layout move / size it exactly
  like the tree (search every place that moves `s.TV`, including `V17_EasyLayout` / `V17_ApplyMode` and V22's header
  code; the V22 header label is hidden in grid view).
- `V27_FillGrid()` at the end of `VMB_Refresh` (only when grid view is on): `-Redraw`, delete rows, add rows, `+Redraw`.
  Keep `s.GridNodes` (row number -> node) rebuilt on every fill / sort / filter.
- Selection sync both ways: grid ItemSelect -> select the node in the tree; and after `VMB_Refresh(selectNode)` select
  that node's row and `EnsureVisible`.
- Double-click a row -> `VMB_EditSelected()`. Right-click a row -> the existing tree menu (`VMB_TreeMenu`) for that node.
- During playback the running step must still be visible: in `VMB_PlayStatus`, when grid view is on, select and
  `EnsureVisible` the running step's row (in addition to what it does now).
- Colours: plain (default ListView). Do not custom-draw in this round.
- Column widths: start from `V27_Columns()`; after the first fill auto-size each column to its content
  (`ModifyCol(n, "AutoHdr")`), capped at 320 px for `text`, `target`, `inside`, `note`, `lastrun`.
- Buttons `c["ViewList"]`, `c["ViewGrid"]` (small, above the list at its right end); in Easy mode too (add both to
  `V17_EasyLayout`; update the Easy-layout self-test count and say so in the notes).

## Item C - sort
- Click a column header: sort ascending; click again: descending; a small ▲ / ▼ in the header title.
- Do the sorting yourself on the row array (pure `V27_SortRows(rows, key, desc, isNum)`, stable, numbers as numbers,
  `–` always last), then refill. Do NOT use the ListView's own sort (row -> node map must stay right).
- A button `c["GridReset"]` "Step order" (and clicking the `#` header) returns to step order.
- While sorted by anything but `#`, show a status line: `Sorted by Program - this is only a view; steps still run in # order.`
- Self-test `V27_SortRows`: numbers, text, `–` last, descending, stable for equal keys.

## Item D - filter
- One Edit above the grid: "Filter..." (cue text). Typing keeps the rows where ANY cell contains the text
  (case-insensitive). Several words = all must match. `col:word` limits to one column by title or key
  (`program:notepad`, `action:click`). Pure `V27_FilterRows(rows, query, columns)`; self-test it.
- Two drop-downs next to it filled from the current rows: Program (All + each program) and Action (All + each action).
- Status line when filtered: `Showing 6 of 41 steps`. A "Clear" button. Filter and sort combine.
- Filtering never hides the running step during playback: clear the filter when a run starts, restore it after.

## Item E - copy to Excel
- Button "Copy table" above the grid: copies the rows currently shown (after sort / filter) with the header row as
  tab-separated text to the clipboard, so it pastes straight into Excel. Pure `V27_Tsv(rows, columns)` (tabs and line
  breaks inside cells become spaces); self-test it.
- Ctrl+C in the grid copies the selected row the same way.

## Help text and version
- Line 1 `V26` -> `V27` + 3-line block; window title both places -> `V27`.
- `V4_Help` / `V17_EasyHelp`: a short "NEW IN V27" paragraph: List / Grid buttons, what sort and filter do (view only),
  Copy table, and the meaning of `–`.

## PC check (add to PC-TEST-ALL.md as a new section "Grid")
1. Grid shows one row per step, every cell filled, with grid lines. 2. Click "Program" header: rows group by program;
"Step order" puts them back. 3. Type `click` in Filter: only click steps show. 4. Select a row, press Edit: the right
step opens. 5. Play: the running row is selected and scrolls into view. 6. Copy table, paste into Excel: columns land
in cells. 7. [List] brings the tree back exactly as before.

## Hand back
Find / replace blocks, new function text, self-test lines and PASS count, anything unsure.
