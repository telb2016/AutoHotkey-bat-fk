# V28 notes (edit cells in the grid)

File: VisualMacroBlocks-makecode-telek-V28-editcells.ahk2 (copy of V27-grid). Self-test: `Failures: 0`, **631 PASS** (V27 had 560).
All new code is one section `V28_*` above the "V4 STARTUP" line; the controls `s.CellEdit` / `s.CellPick` are not in `s.Ctl`.

## Leftover from V27
- Help ("NEW IN V27" in `V4_Help` and `V17_EasyHelp`) now mentions sort, filter and Copy table.

## Item A - pure rules (63 new checks)
- `V28_Editable(node, key)` -> "", "text" or an array of choices; `V28_ApplyCell(node, key, input)` -> {Ok, Error}; `V28_ParseWait(text)`.
  `V28_ParseWait` returns an object {Ok, Value (ms or "auto"), Error} (the plan said "ms, auto or an error").
- Built on `V28_Plan` (works out the changes without touching the node) + `V28_ApplyChanges`; the window code validates first, so a rejected value
  never takes a snapshot. Also `V28_EditText` (the raw text the editor opens with), `V28_Hint`, `V28_KeysError`.
- Every row of the plan's table has a good value, a bad value (node unchanged, sentence returned) and the non-editable columns are checked.
- Choices that go beyond the plan: wait over one hour is refused; scroll count 1..100; window size at most 20000; "x" Y/X also accept a leading/trailing space.
  X / Y write `noVerify := 1` also for old steps (scrX / scrY). The anchor (`ax` / `ay`) of a step is not changed when X / Y change.

## Item B - the editor
- `V28_Build` (from `VMB_BuildGui`): hidden Edit + DropDownList over the grid. `V28_Open(row, col)`, `V28_Commit`, `V28_Cancel`, `V28_Finish`, `V28_Enter(down|tab|back)`.
- Cell place: LVM_GETSUBITEMRECT (sub-item = column - 1) mapped to the window with MapWindowPoints, times 96 / A_ScreenDPI (like V22). The grid is scrolled sideways (LVM_SCROLL) first
  when the cell is not fully visible.
- Hotkeys (`#HotIf V28_EditorFocused()`: only while the editor has the focus, not recording / playing): Enter (saves, selects the row below), Tab (saves, opens the next
  editable cell of the row, wraps to the next row), Shift+Tab, Esc. In the grid (`V27_GridFocused()`): F2, Enter, Left / Right (current column, status bar `Cell: Waits first`), Delete, Ctrl+D.
- Double-click: editable cell -> editor; any other cell -> the old Edit box. Click sets the current column. Clicking elsewhere saves (LoseFocus); a mouse wheel on the grid closes it (a valid value is saved).
- The editor closes without saving when the grid is refilled, a view switch, a run start or a recording start; it saves when the window / grid is re-laid out (`V27_PlaceGrid`).
- Change = `VMB_Snapshot()`, apply, `Dirty`, `VMB_Refresh(node)`, `V7_AutoSaveNow()`; one Ctrl+Z undoes one cell edit.
- Fix needed on the way: the ListView got WS_CLIPSIBLINGS (`+0x4000000`), otherwise the grid repainted over the editor (the editor was invisible in the screenshot until this).

## Item C
- Delete on Note / Waits clears it; on other cells the status bar says Delete only clears those. Ctrl+D copies the raw value of the cell above (shown order) when both cells are editable
  in that column and the value is valid for this step (otherwise a status-bar sentence). Typing a letter / digit (no Ctrl / Alt) starts an edit with that character: via `OnMessage(0x100)` on the
  grid (AutoHotkey does not pass LVN_KEYDOWN to `OnNotify`); on a drop-down column the first choice that starts with the letter is chosen and the list opens.
- Ctrl+D: in the tree it still duplicates a step; in the grid it is now "copy cell above" (as the plan says).

## Version / help / PC check
- Line 1, both window titles say V28; "NEW IN V28" help in both help boxes; PC-TEST-ALL.md section 4 "Edit cells" (11 hand checks).

## Seen live (Wine, harness edit1.ahk / edit2.ahk, 9 steps; real keys with `SendEvent` + `SendLevel(1)` so the script's own hotkeys react)
- Waits cell: editor position = cell rectangle exactly (1437,193,90,15 both). Typed `2`, Enter: delayMs 2000, cell `2 s*`, selection moved one row down, focus back on the grid; Ctrl+Z restored.
- Bad X (`abc`): node unchanged, editor stays open, status `X must be a whole number, 0 or more.`; Esc: closed, `Not changed.` Good X `150`: cx 150, noVerify 1, undo restores both.
- Button drop-down (3 choices, current preselected): Middle chosen, Enter: node and cell changed. Clicks drop-down: 2, picked with the list-confirmed handler: Action became Double-click.
- Real Tab from X opened Y; Shift+Tab went back to X. F2 on a Program cell: the "worked out" sentence. F2 / Enter on Waits opened the editor. Right / Left moved the column, status `Cell: Scroll back ...`.
- Filter `chrome` + sort by Action: the editor opened on the right node (the wheel step), `up 2` made WheelUp 2, the other chrome click was untouched, undo kept the sorted / filtered view.
- Delete on Note and on Waits cleared them (undo restored). Ctrl+D copied a 2 s wait from the click row into the Type row below it; refused with a sentence for X on a Type step.
- Typing: `h` on a Type text cell opened the editor with `h`, `ey` Enter made `hey`; `3` on a Waits cell then Enter made 3 s; `q` on a Program cell did nothing; `r` on Button chose Right.
- Screenshot `V28-edit-preview.png`: Easy mode, grid scrolled to the right, the editor (white box with border, text `2` and caret) sits exactly on the Waits cell of the Click row; status bar shows the hint.

## Not verified / unsure
- Real mouse use (double-click, click elsewhere = save, picking from the open drop-down list, header resize, scroll-bar drag): mouse hooks do not work under Wine. `V28_OnPickDone`, Enter-from-list and the LoseFocus path were
  called directly or reached through keyboard focus changes only. LVN_ENDSCROLL / header notifications (`OnNotify`) are registered but never fired under Wine, so closing on scroll relies on LoseFocus and the mouse wheel handler.
- DPI: the cell rectangle is converted with 96 / A_ScreenDPI like V22's header code; Wine runs at 96 dpi, so 125% / 150% scaling is NOT tested. This is the first thing to check on the PC (PC-TEST-ALL 4.1).
- The drop-down opens automatically (CB_SHOWDROPDOWN); with the list open Enter takes the highlighted item. Not tried on real Windows.
- Delete / Left / Right / Enter / F2 / Ctrl+D in the grid are hotkeys with `#HotIf V27_GridFocused()`; Left / Right no longer scroll the grid sideways by keyboard (the grid is scrolled automatically to the current cell).
