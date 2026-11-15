# V33 notes (more Excel: cell ranges, block copy / paste / fill, frozen columns, Excel look)

File: VisualMacroBlocks-makecode-telek-V33-cells.ahk2 (copy of V32-rows). Self-test: `Failures: 0`, **944 PASS** (V32 had 906).
All new code is one section `V33_*` above the "V4 STARTUP" line (ends with `; ==== V33 END`), plus small hooks listed below. New controls: `s.GridFreeze` (the frozen pane), none in `s.Ctl`.
New fields of the `VMB()` object: `ListRange`, `ValRange`, `ShLast`, `ShSync`, `V33`, `V33S`, `V33C`, `ExcelLook`, `GridFreeze`, `Freeze`, `FrzDirty`, `FrzShown`, `FrzSync`, `FrzSig`, `FrzSel`, `FrzErr`.
Commits: item 0 + A + B (+ the colours of D) in the first commit, D (header / tabs), C (frozen pane).

## Item 0 - small fixes
- `V33_FilterMarks(plain)` returns both header marks (`▼` can filter, `▼=` filtered; plain `v` / `v=`). `V32_HeadTitle` uses it (ini `[V22] PlainMarks=1` -> `V33_PlainMarks`). The sort triangle `▼` (descending) is unchanged, so a descending, filterable column reads `Program ▼ ▼`.
- Undo / Redo: `VMB_Undo` / `VMB_Redo` remember the selected grid row, `V33_UndoRestore` selects the same row number again (clamped, `V33_ClampRow`) after the refill; the cell cursor's column (`s.GridCol`) was never touched.

## Item A - cell range and summary
- Model: `s.GridRange = {A: node, C: node, Col: anchor column number}`. A = anchor step, C = current step (the selected row), `Col` = the anchor column, `s.GridCol` = the current column. Display order, hidden columns skipped (`V29_VisibleOrder`).
  Pure `V33_Rect(anchorRow, anchorCol, curRow, curCol, order)` -> `{rows: [first, last], keys: [...]}` (order = the columns in shown order; a hidden anchor column falls back to the other end). The live rectangle is `V33_Live()` (also holds Cols map, Count).
- Keys (all under `V27_GridFocused()`): Shift+Left / Right (`V33_ExtendCol`), Shift+Up / Down (the V32 `V32_Extend`, now keeps the anchor column), Ctrl+Shift+arrows (to the edge: first / last row or shown column), Ctrl+A (`V33_SelectAll`, current cell = top left). A plain arrow, Home / End / Tab (`V29_GoCol`, `V28_MoveCol`) or a plain click collapses (`V33_Collapse`); Shift+click extends (`V28_OnClick`, `V32_OnPick`). Row actions of V32 (Alt+Up / Down, Shift+Delete, Ctrl+Shift+D) work on the rows the range covers (unchanged code; `V32_Reselect` keeps the anchor column).
- Drawing: the V29 custom draw now paints cells, not rows: light blue on the cells of the range (`V33_Look()["Range"]`), the green frame on the current cell. With the Excel look the selected row is NOT dark blue: the draw clears `CDIS_SELECTED` for it and paints light grey-green with black text. Seen: this works under Wine. Every sub-item callback starts from white / black, because the colours of the previous cell otherwise stay (seen as a bug in the first screenshot, fixed).
- Summary: pure `V33_Summary(cells, key)` -> `6 cells · Waits first: total 12.5 s` (Waits column and every cell a time, no `auto`), `4 cells · Sum: 125` (List / Values, every cell a number, `1,250` and `1,5` work), else just the count. Shown in the status bar by `V33_Status` after every extend, with a hint.
- Same on the **List and Values sheets** (`V33_Sh`, `V33_SLive`, `V33_SExtend`, `V33_SSelectAll`, `V33_OnSheetSelect`, `V33_OnSheetDraw`; range in `s.ListRange` / `s.ValRange` = anchor row / column, current = selected row + `ListCol` / `ValCol`). The List sheet also got the green cell frame and range shading; its `#` column is grey with the Excel look.

## Item B - copy / paste / fill / clear
- Ctrl+C (`V33_Copy`): range = tab / line separated text (CRLF between rows, no trailing line break; each cell = the editor's raw text, as V29 does for one cell). One cell = old `V29_CopyCell`.
- Ctrl+V (`V33_Paste`): `V33_ParseBlock` (Excel's format incl. quoted cells with tabs / line breaks / doubled quotes), `V33_PlanPaste(block, rect, order, rowCount, grow)`: one value onto a range fills it; a block goes to the top left cell of the selection; a selection that is a whole multiple of the block is tiled; cells below the last row / right of the last column are dropped and counted (List sheet: `grow`, new rows added up to the 5000 limit). Applied by `V33_Apply` = `V28_Plan` / `V28_ApplyChanges` per cell, ONE `VMB_Snapshot` before the first change, one refresh, one autosave, `V31_AfterStepEdit` per changed step. Cells that refuse are counted: `Pasted 9 cells, 2 could not take the value.` The pasted block becomes the selection. A cell holding the same text is not a change (no empty undo step).
  A single value onto one cell is the old `V29_PasteCell` (same sentences).
- Ctrl+D (`V33_Fill("down")`): top cell of each selected column into the rest (`V33_PlanFill`); one cell selected = V28's copy-above as before. Ctrl+R: fill right (one cell: copies the left cell). A source cell that is worked out (not editable) is counted as refused. Delete (`V33_Delete`): every clearable cell (Note, Waits first, Only when, If it fails) in the range, others counted; Ctrl+X = copy then delete.
- List sheet: `V33_ListApply` (ONE `V30_ListPush`, Ctrl+Z on that sheet undoes the paste, rows added past the end, columns past the last one dropped). **Ctrl+V on a List that already has rows now pastes the block at the cell; on an empty List it still pastes the whole list (header guess + auto-match) as before; the "Paste list" button always does the whole-list paste.** Values sheet: `V33_ValApply` through `V31_EditValue`; only Value and When take part (a name is never renamed by a paste: counted); Delete empties Value cells only.

## Item D - Excel look
- All colours in `V33_Look(on)` (RGB), `V33_Bgr`, `V33_LookBgr`: header 0xF3F3F3 with a 0xBFBFBF bottom line, `#` column 0xF3F3F3, selected row 0xE3EFE6, range 0xD5E6F7, tab colours (not used, see below). Alternate rows are not shaded.
- Header: `V33_OnWmNotify` (OnMessage 0x4E) paints the heading of the Steps / List / Values grids and the frozen pane through the header's NM_CUSTOMDRAW, which the ListView forwards to its window. It WORKS under Wine (screenshot). Text is the title read back with HDM_GETITEMW (so the arrows and sort triangles stay).
- Tabs: native buttons cannot be coloured, so the active sheet tab is **bold** (`V33_StyleTabs`), the others normal. (White / grey tabs: not done.)
- `[V33] ExcelLook=0` gives V32's look exactly (native header, blue selected row, per-cell light-blue range; seen in a screenshot).

## Item C - frozen # and Action
- `s.GridFreeze`: a second ListView (columns `#`, `Action`, no border, no scroll bars - `ShowScrollBar` every tick), created last in `V30_Build`. A 120 ms timer (`V33_FreezeTick`) decides (`V33_FreezeWanted`, pure, self-tested): ini on, Steps grid visible, rows, `#` column completely scrolled out on the left (`V33_HashOff`), cell editor closed, width > 0. Then it moves the pane onto the grid's client area (same y, height = client height, width = the two column widths), copies the rows when `s.FrzDirty` (set at the end of `V27_FillGrid`) or the count differs, mirrors the selected row, and scrolls the pane with `LVM_SCROLL` until `LVM_GETTOPINDEX` equals the grid's. Layout also runs from `V27_PlaceGrid`.
- Click on a pane row: that row is selected in the grid (`V27_OnSelect` is called directly) and the grid gets the focus. The wheel over the pane is forwarded to the grid. The pane uses the grid's font (zoom). Widths follow the grid.
- Right-click a header -> `Freeze # and Action` (ticked by default, ini `[V33] Freeze`, `V33_ToggleFreeze`).
- The pane is a mirror: not editable, shows the grid's texts (so a sort / filter / band row is shown the same).

## Seen live (Wine, real AutoHotkey 2.0.19, real key presses with `SendEvent` + `SendLevel(1)`; harnesses v33a..v33d in the scratchpad)
See the final report of the run; the results listed there are from the last run of the final build.

## Not verified / unsure
- Mouse: Shift+click, a real click on a pane row, the right-click header menu with the new entry, the real wheel over the pane. Mouse hooks do not work under Wine; handlers were called directly.
- Real Windows: custom draw of the selected row (`CDIS_SELECTED` cleared) and of the headings only seen under Wine; themed list views may differ. 125 % / 150 % scaling of the frozen pane (positions are converted with 96 / A_ScreenDPI like V28) and the header drawing.
- The frozen pane is timer-driven (no scroll notification fires under Wine): a scroll shows in the pane within about 120 ms. Hiding the pane's vertical scroll bar with `ShowScrollBar` works under Wine; if some Windows version brings it back for a moment, set `[V33] Freeze=0`.
- Ctrl+Shift+Up / Down are not used by other V28 / V29 / V32 hotkeys in the grid (checked), but a keyboard layout where Ctrl+Shift switches the input language can swallow Ctrl+Shift+arrows.
- The Waits summary counts `auto` cells as "not a time", so a block that contains one shows only the count (Excel would add the numbers it can).
- Sheet tab colours (white / grey) are not possible with native buttons; only bold is used.
