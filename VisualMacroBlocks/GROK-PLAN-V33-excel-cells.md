# Work plan: V33 - more Excel: cell ranges, fill down, block paste, frozen columns, Excel look

Work on `VisualMacroBlocks-makecode-telek-V32-rows.ahk2`, save as `VisualMacroBlocks-makecode-telek-V33-cells.ahk2`.
Same rules as earlier plans (V19 plan section 1). Prefix `V33_`. Self-test `Failures: 0`, more than 906 PASS.
One commit per item, push after every commit, + `V33-NOTES.md`. Read V27..V32 NOTES first. When in doubt, do what Excel does.

## Item 0 - small fixes from V32
- The header arrow `▾` showed as an empty box in one font. Use `▼` (smaller is not needed) for "can filter" and keep `▼=`
  for "filtered"; one function returns both marks so they can be swapped (ASCII fallback `v` / `v=` when the ini
  `[V22] PlainMarks=1`).
- After Undo in the Steps grid, re-select the row at the same position (same row number, clamped) and keep the cell
  cursor's column, since the nodes are rebuilt.

## Item A - select a block of cells (Shift+arrows / Shift+click), like Excel
- V32 has a ROW range. Extend it to a CELL range: anchor cell + current cell define a rectangle of rows x columns in
  DISPLAY order (V29 column order, hidden columns skipped). Shift+Left / Right / Up / Down grow it; Ctrl+Shift+arrows
  jump to the edge; Ctrl+A selects all cells of the sheet; any plain arrow / click collapses to one cell.
  Draw it through the existing custom draw: light blue fill on the range, the green border on the current cell.
  Row operations from V32 (Alt+Up / Down, Shift+Delete, Ctrl+Shift+D) keep using the rows the range covers.
- Pure `V33_Rect(anchorRow, anchorCol, curRow, curCol, order)` -> {rows, keys}; self-test (reordered and hidden columns).
- Status bar summary for the range, like Excel's: `6 cells · Waits first: total 12.5 s` (count always; total only when
  every selected cell is a Waits cell with a time; for the List sheet: Count, and Sum when all are numbers).
  Pure `V33_Summary(cells, key)`; self-test.

## Item B - copy / paste / fill a block
- Ctrl+C copies the range as tab / line separated text (what Excel puts on the clipboard); a single cell as before.
- Ctrl+V: clipboard block pasted starting at the current cell, cell by cell through `V28_ApplyCell` (Steps sheet) or the
  sheet's own setter (List / Values). One undo step for the whole paste (one `VMB_Snapshot()` before, per-cell snapshots
  suppressed). Cells that refuse the value are skipped and counted: `Pasted 9 cells, 2 could not take the value.`
  A single copied value pasted onto a range fills the whole range (Excel behaviour). On the List sheet, pasting past the
  last row adds rows.
- Ctrl+D = fill down: copies the top cell of each selected column into the rest of the range (replaces V28's
  single-cell Ctrl+D, which is the 2-row case). Ctrl+R = fill right. Delete clears every clearable cell in the range.
- Pure `V33_ParseBlock(text)` / `V33_PlanPaste(block, rect)`; self-test.

## Item C - frozen first columns
Scrolling sideways hides `#` and Action, so the owner loses track of which step a cell belongs to.
- When the grid is scrolled right so that the `#` column is off screen, show a narrow second ListView (`s.GridFreeze`,
  not in `s.Ctl`) pinned at the grid's left edge with just two columns - `#` and Action - same rows, same font / zoom /
  row height, no scroll bars, vertical scroll kept in sync with the main grid (same top index on every scroll, selection
  and refill). It disappears when `#` is visible again. Clicking a row in it selects that row in the main grid.
  Keep it simple: it is a mirror, not editable; rebuild it in `V27_FillGrid`.
- A right-click header entry "Freeze # and Action" (ticked by default, saved in the ini) turns it off.
- If keeping two ListViews in sync proves unreliable under Wine, stop, leave the feature off by default, and say so.

## Item D - Excel look
- Header row: light grey background (0xF3F3F3), bold off, a thin bottom line - through header custom draw if it works,
  else leave native. Selected-row highlight light grey-green instead of dark blue so cell text stays black.
- Row-number feel: the `#` column grey-backed like Excel's row headers. Alternate rows NOT shaded (Excel does not).
- Sheet tabs: the active tab white and bold, the others grey - as far as native buttons allow.
- All colours in one function `V33_Look()` so they can be tuned; ini `[V33] ExcelLook=0` restores V32's look.

## Live check (Wine) and PC check
Live: grow a 2x3 range by Shift+arrows and log the rectangle; summary text for a Waits range; copy the block and compare
`A_Clipboard`; paste a 2x2 block of waits / notes and check each node, then one `VMB_Undo()` restores all four; fill
down a Note over 4 rows; paste on the List sheet past the last row; frozen pane appears after scrolling right
(LVM_SCROLL) and its top index equals the grid's after scrolling down; screenshots of a selected block with the summary
and of the frozen pane -> `V33-preview.png`, `V33-freeze.png` (look at both).
Add section "Cell ranges and Excel look" to PC-TEST-ALL.md.
