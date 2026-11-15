# Work plan: V29 - make the grid look and act like Excel (round 1: zoom, cell cursor, cell copy / paste, columns remembered)

Work on `VisualMacroBlocks-makecode-telek-V28-editcells.ahk2`, save as `VisualMacroBlocks-makecode-telek-V29-excel.ahk2`.
Same rules as earlier plans (V19 plan section 1). Prefix `V29_`. Self-test `Failures: 0`, more than 633 PASS.
One commit per item + `V29-NOTES.md`. The owner likes Excel: when in doubt, do what Excel does.

## Item A - zoom like Excel
- Grid zoom is its own setting, separate from the list's A+ / A-: `s.GridZoom` in percent (50..200, default 100),
  saved in the ini (`[V29] GridZoom`). Font size = base size (9) * zoom / 100, rounded to the nearest half point is not
  possible in GDI: use whole points and keep the percent as the truth. Pure `V29_ZoomFont(basePt, pct)` and
  `V29_ZoomStep(pct, direction)` (Excel's steps: 50, 60, 70, 80, 90, 100, 110, 120, 130, 150, 175, 200); self-test both.
- Ways to zoom, all only when the grid has the focus / the mouse is over the grid:
  Ctrl + mouse wheel (WM_MOUSEWHEEL with MK_CONTROL over the grid: zoom and swallow the message), Ctrl + `+` / Ctrl + `-`
  (main row and numpad), Ctrl + 0 = 100%. In grid view these keys must act on the grid INSTEAD of the tree zoom that
  exists today for the editor window (check the existing `^=`, `^-`, `^0` hotkeys under `#HotIf VMB_EditorActive()`).
- A zoom control at the right end of the filter row, like Excel's status bar: `−`  `100%`  `+` (clicking the percent
  resets to 100%).
- Column widths scale with the zoom (keep each column's width at 100% in `s.GridColW`, apply width * zoom / 100).
  The header row uses the same font. The cell editor (V28 overlay) must use the zoomed font and still sit on its cell.

## Item B - a cell cursor, like Excel's selected cell
Today the whole row is highlighted and the "current column" is only named in the status bar.
- Draw the current cell (selected row + `s.GridCol`) with a clear 2 px dark-green border (Excel's 0x217346 look) using
  the ListView's custom draw (NM_CUSTOMDRAW: ask for sub-item post-paint, draw a frame on that sub-item's rectangle).
  Keep the row highlight light (default selection colour is fine). If custom draw proves unreliable under Wine, fall
  back to a thin borderless child window frame placed over the cell (4 one-pixel-thick static controls) and say so.
- A mouse click on a cell makes it the current cell (LVM_SUBITEMHITTEST on click). Arrow keys already move it; add
  Home / End (first / last column), Ctrl+Home (first row, first column), Ctrl+End (last row, last column),
  Tab / Shift+Tab move right / left when NOT editing (wrapping to the next / previous row like Excel).
- Above the grid, left of the filter box, a small read-only "name box" like Excel's: `Waits first · step 7`.

## Item C - copy / paste a cell
- Ctrl+C in the grid copies the CURRENT CELL's text (Excel behaviour). Shift+Ctrl+C copies the whole row (the V27
  behaviour). "Copy table" button unchanged.
- Ctrl+V pastes the clipboard text into the current cell through `V28_ApplyCell` (same validation, snapshot, undo,
  status-bar error when refused). Only the first line / first tab-separated field is used. Non-editable cell: say so.
- Ctrl+X = copy then clear, only on cells that Delete can clear (Note, Waits).

## Item D - columns behave like Excel columns
- Drag a header to reorder columns (ListView extended style LVS_EX_HEADERDRAGDROP 0x10). Double-click a header edge
  auto-fits (native). Remember widths (at 100% zoom) and order in the ini (`[V29] ColW`, `[V29] ColOrder`) on change
  and at exit; restore at start. Reordering must not break `s.GridCol` logic: keep working in column KEYS, and convert
  to display order with LVM_GETCOLUMNORDERARRAY (0x103B) wherever "next / previous column" is computed (pure helper
  `V29_NextCol(order, current, step)`; self-test it).
- Right-click a header: a menu with every column ticked / unticked to hide or show it (hidden = width 0 and skipped
  by the cursor), plus "Reset columns". Saved in the ini.

## Live check (Wine) and PC check
Live: zoom by key and by calling the wheel handler; log font size, percent label and one column's width at 100 / 150 / 70;
edit a cell at 150% and log editor vs cell rectangle; cell cursor follows arrows / Home / End / Tab; Ctrl+C / Ctrl+V on
Waits and on a non-editable cell; reorder two columns by LVM_SETCOLUMNORDERARRAY and check Right moves in display
order; hide a column; restart the editor in the harness and check zoom, order, widths, hidden are restored. Screenshot
at 150% -> `V29-preview.png` (look at it).
Add section "Excel feel" to PC-TEST-ALL.md: Ctrl+wheel zooms the grid; the green cell cursor follows clicks and arrows;
Ctrl+C / Ctrl+V on a Waits cell; drag a header to reorder; right-click header hides a column; all remembered after restart.

## Later rounds (do NOT do now; one per cycle, planner picks)
Filter arrows in each header (AutoFilter list of values with tick boxes) · Ctrl+F Find / Find next · freeze the first
columns while scrolling sideways · select a range of cells, fill down (Ctrl+D over a range), paste a block · status-bar
summary for the selection (count, total wait time) · Ctrl+Z / Ctrl+Y stay in the grid cell they changed ·
alternate-row shading and Excel-like header look · insert / delete / move rows from the grid (right-click row).
