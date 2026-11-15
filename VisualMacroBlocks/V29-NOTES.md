# V29 notes (the grid feels like Excel: round 1)

File: VisualMacroBlocks-makecode-telek-V29-excel.ahk2 (copy of V28-editcells). Self-test: `Failures: 0`, **665 PASS** (V28 had 633).
All new code is one section `V29_*` above the "V4 STARTUP" line. The new controls (name box, zoom control) are in `s.GridBar`, not in `s.Ctl`.
State lives in new fields of the `VMB()` object: `GridZoom`, `GridColW`, `GridColApplied`, `GridHidden`, `ColsSaved`, `CurCell`.

## Item A - zoom
- `s.GridZoom` (50..200 %, default 100, ini `[V29] GridZoom`), separate from the list's A+ / A-. Font = `V29_ZoomFont(9, pct)` (whole points, never below 5);
  `V27_ApplyGridFont` and the cell editor use it. Pure: `V29_ZoomFont`, `V29_ZoomStep` (Excel's 12 steps, works from any percent), `V29_ClampZoom`, `V29_ColWidth`.
- Ways: Ctrl + wheel over the grid or its header (`OnMessage(0x20A)`, MK_CONTROL, returns 0 = swallowed), Ctrl + `=` / `-` / numpad `+` / `-` / `0`
  under `#HotIf V27_GridFocused()` (placed before the `VMB_EditorActive()` block, so the grid wins only when the grid has the focus; in list view the tree zoom is unchanged).
- Zoom control `-  100%  +` at the right end of the filter row (click the percent = 100 %).
- Column widths: `s.GridColW` holds each width at 100 %; `V29_ApplyColWidths` applies width * zoom / 100. `V29_CaptureWidths` reads user changes back
  (only columns whose real width differs from what was applied, so there is no rounding drift when zooming back and forth).
- An open cell editor is saved first (valid value) when the zoom changes. Editor font follows the zoom; editor rectangle = cell rectangle at 150 % (seen).
- The filter row has more controls now (name box, zoom control); `V27_PlaceBar` hides the name box when the row is narrow and repaints the row,
  because under Wine a moved drop-down left a stale picture behind (seen in a screenshot; fixed with RedrawWindow of the row).

## Item B - cell cursor
- Custom draw (`NM_CUSTOMDRAW` on the ListView, `V29_OnCustomDraw`): only the selected row asks for sub-item paint; after the current column's cell is painted
  a 2 px frame in 0x217346 is drawn (`V29_DrawFrame`, PS_INSIDEFRAME pen, hollow brush). It WORKS under Wine (no fallback to child windows needed);
  the row highlight is the normal blue selection. First column: rectangle cut to the column width (`V29_CursorRect`).
- Click on a cell = current cell (the V28 click handler; now also repaints the frame and the name box). Home / End = first / last SHOWN column,
  Ctrl+Home / Ctrl+End = first / last row and column, Tab / Shift+Tab = next / previous cell, wrapping to the next / previous row; all only while the grid has the focus
  (while the editor is open its own Tab / Enter / Esc keys are unchanged). Pure `V29_NextCol(order, current, step)` (no wrap; a hidden / unknown column goes to the first / last).
- Name box left of the filter: `Waits first · step 7` (`V29_NameText`), read-only.
- Left / Right (V28) and Tab inside the editor now move in the DISPLAY order and skip hidden columns.

## Item C - copy / paste
- Ctrl+C = current cell. An editable cell gives the editor's raw text (`2 s`, so it pastes back exactly); a worked-out cell gives what is shown (also `–`).
  Shift+Ctrl+C = the row (the V27 behaviour). Ctrl+V = first line / first tab field of the clipboard through `V28_Plan` + `V28_Do` (snapshot, undo, autosave, status-bar
  sentence when refused; worked-out cell says it cannot be pasted into). Ctrl+X = copy then `V28_DeleteCell`, only Note and Waits first.
- Help text of V27 ("Ctrl+C copies the selected row") was corrected.

## Item D - columns
- `+LV0x10` (LVS_EX_HEADERDRAGDROP): drag a header to reorder; native double-click on a header edge auto-fits. Work stays in column KEYS / numbers (the ListView keeps the
  original sub-item numbers; `ColClick`, cell rectangles and `s.GridCol` are unaffected); the display order is read with LVM_GETCOLUMNORDERARRAY (`V29_DisplayOrder`, `V29_VisibleOrder`).
- Hide / show: right-click a header -> menu with every column ticked + "Reset columns" (`V29_BuildColMenu`, `V29_ToggleCol`, `V29_ResetCols`); hidden = width 0, skipped by the cursor,
  at least one column always stays; hiding the cursor's column moves the cursor to its neighbour.
- Ini: `[V29] ColW` (key=width at 100 %, only columns whose width differs from the start width), `ColOrder` (keys), `ColHidden` (keys), `GridZoom`. Pure parse / write functions with self-tests.
  Saved when the grid loses the focus, on zoom, on view switch, at exit (`VMB_OnExit`), after menu actions. Saved widths mean no auto-fit at start.

## Version / help / PC check
- Line 1, both window titles say V29; "NEW IN V29" in `V4_Help` and `V17_EasyHelp`; PC-TEST-ALL.md section 5 "Excel feel" (9 hand checks).

## Seen live (Wine, harness, 9 steps, real keys through `SendEvent` + `SendLevel(1)`)
- Zoom: keys Ctrl+= (100 -> 110 -> 120), Ctrl+numpad plus, Ctrl+0, the wheel handler called directly (Ctrl+wheel up 120 -> 130; down x3 from 100 -> 70; without Ctrl and on another window it returns nothing = not swallowed).
  Font 9 / 10 / 11 / 6 / 14 pt, label `110%`..., the "text" column 220 / 242 / 154 / 330 px at 100 / 110 / 70 / 150 %, back at 100 = 220 again. List view: Ctrl+= still changed the TREE size (9 -> 10), grid zoom untouched.
- Editor at 150 %: editor rectangle 135x22 = cell rectangle, editor font 14 pt. Zoom while editing: the editor closed (saved).
- Cell cursor: Right / End / Home / Ctrl+End / Ctrl+Home / Tab (from the last column on to the next row's first) / Shift+Tab / Down, with the name box text and status each time.
  A click path: hit test at a cell + the click handler -> current column and name box changed.
- Copy / paste: Ctrl+C on Waits `2 s`, on Program `notepad?`; Shift+Ctrl+C one line, 21 tabs; Ctrl+V on another step's Waits -> 2000 ms, `2 s*`, undo restores; Ctrl+V on Program refused; `tomorrow` refused with the sentence;
  `7<tab>8<nl>9` -> 7 s; Ctrl+X on Note and on Waits copies and clears (undo restores); Ctrl+X on Text refused.
- Columns: wait moved to position 3 by SETCOLUMNORDERARRAY; Right / Home / End follow the display order; inside and zone hidden (width 0), Right from `#` skips inside; hiding the cursor's column moved the cursor to its neighbour;
  Tab in the editor from a reordered Waits cell opened the next EDITABLE cell in display order (Button); text width set to 333, zoom 150 -> 500 real / 333 stored, back at 100 -> 333.
  Restart (second process): zoom 120, order, hidden, `text` width 400 (= 333 * 1.2) all restored; Reset columns: start order, nothing hidden, widths 264 (= 220 * 1.2).
  The header menu was built (24 items, ticks right) but not shown.
- Screenshots: `V29-preview.png` = Easy mode at 150 %, the cell cursor on the Action cell of step 2 (a dark-green 2 px frame is visible on the blue row), name box `Action · step 2`, zoom control `- 150% +`,
  text clearly larger than at 100 %. Full mode at 150 % also checked (no overlap in the filter row).

## Not verified / unsure
- Real mouse: Ctrl + the real wheel, a real header drag, a real right-click on a header, clicking `-` / `+` / percent. Mouse hooks do not work under Wine; the wheel handler and the menu build were called directly.
  Whether the right-click on a header reaches `V27_OnMenu` or only `V29_OnGuiMenu` (both are wired, with a 400 ms guard against showing the menu twice) is NOT known - check on the PC (PC-TEST-ALL 5.6).
- The menu itself was never displayed (`Menu.Show` blocks; could not be closed from the script under Wine).
- Frame look on real Windows: custom-draw rectangles of sub-items and the first column were only seen under Wine. Not tested at 125 % / 150 % screen scaling (Wine runs at 96 dpi).
- Header drag-drop of the FIRST column (`#`) was not tried by hand.
- Widths dragged by hand are saved when the grid loses the focus / at exit; no header-notification is used (LVN / HDN notifications never fired under Wine in V28). A crash loses the last drag.
- Ctrl+V / Ctrl+C / Ctrl+X while the cell editor is open are the editor's own text keys (unchanged); Ctrl + zoom keys do nothing while the editor has the focus (the wheel does zoom and saves the cell).
- "Later rounds" of the plan were not started.
