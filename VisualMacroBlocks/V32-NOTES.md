# V32 notes (rows like Excel rows, Find, header filter arrows, band rows)

File: VisualMacroBlocks-makecode-telek-V32-rows.ahk2 (copy of V31-onlywhen). Self-test: `Failures: 0`, **906 PASS** (V31.1 had 871).
All new code is one section `V32_*` above the "V4 STARTUP" line. New controls (the Find bar) are in `s.FindBar`, not in `s.Ctl`; the filter popup is a separate small window kept in `V32_Pop()`.
New fields of the `VMB()` object: `GridRange`, `GridBands`, `Bands`, `V32Last`, `V32Rows`, `V32Asked`, `V32NoAsk`, `Picks`, `FindBar`, `FindOn`, `FindHits`, `FindAt`, `FindSheet`.

## Item A - rows like Excel rows
- Row actions go through the existing functions (`VMB_MoveSelected`, `VMB_Duplicate`, `VMB_DeleteSelected`, `VMB_ToggleDisabled`, `VMB_InsertNode` with `V31_NewStep`), so snapshot / undo / autosave are unchanged. `V32_Run(nodes, fn)` ticks exactly the range's steps (the tree functions act on ticked lines), runs `fn`, and in a `finally` removes the ticks again and puts back the ticks the tree had before (one row: nothing is ticked, the tree selection is used).
- Keys (only under `V27_GridFocused()`): Alt+Up / Alt+Down move, Shift+Delete delete (one confirm box the first time per session, `s.V32Asked`; the existing delete box is skipped through `s.V32NoAsk`, set in a try / finally), Ctrl+Shift+= / Ctrl+Shift+numpad plus insert a Type step below, Ctrl+Shift+D duplicate, Shift+Up / Shift+Down extend the range. Ctrl+Shift+D was a global hotkey (Deterministic Lab); it now calls `V32_CtrlShiftD()` = duplicate when the grid has the focus, else the Lab as before. No collision with the V28 / V29 keys (checked: Enter, F2, arrows, Tab, Home / End, Ctrl+C / V / X / D, Delete, Ctrl+plus / minus / 0).
- Range: `s.GridRange = {A: node, C: node}` (anchor and current end, nodes not row numbers, so it survives refills). Pure `V32_Range(anchor, current, count)`. Shaded light blue through the V29 custom draw (selected row keeps the normal blue). A plain pick ends the range; Shift+click extends it (`V32_OnPick`, from `V27_OnSelect`).
- After every action the same steps stay selected (`V32_Reselect`) and `s.GridCol` is untouched. Insert selects the new step. Move that cannot move says `Cannot move further up / down.` Delete selects the row that follows.
- Refused with `Sort and filter are on: switch to Step order to move rows.` while a sort, filter text, drop-down or header pick is on. Extending the range is allowed there (shading only).
- Right-click: `V32_RowMenu` (Insert step above / below with the V31 kinds, Duplicate, Delete, Move up / down, Turn off / on, More step actions...). The Text-cell and Only-when-cell menus got a **Row actions...** entry.
## Item C - Find
- Ctrl+F on any of the three grids (Steps, List, Values) opens a bar in an extra row above the grid (the grid gets 28 px shorter; nothing is hidden). Pure `V32_FindAll(rows, columns, needle)`, `V32_FindStep`, `V32_FindNear`, `V32_FindCount`. Enter / F3 next, Shift+Enter / Shift+F3 previous, Esc closes, X button too. It moves the cell cursor only (Steps: `GridCol` + selected row; List / Values: row + `ListCol` / `ValCol`) and never filters. Searches the rows that are shown (a filtered view is searched as shown). Changing the sheet closes the bar.
## Item B - header filter arrows
- Every title ends with `▾`; a column with a pick shows `▼=`. Click in the right 18 px (scaled) of a title: popup (search box, tick list with (Select all), OK / Cancel, borderless window under the title). Pure `V32_Distinct`, `V32_ApplyPicks`, `V32_HitArrow`, `V32_HeadTitle`. Picks (`s.Picks`: key -> Map of values) are ANDed with the filter box and the two drop-downs; Clear clears them; a run clears and restores them like the filter. OK with nothing ticked is refused; all ticked = no filter on that column.
## Item D - band rows
- `V32_MakeBands(blocks, stepRows)` is called from `V27_FillGrid` and `V27_ViewRows` returns it only in step order with no filter (`V32_BandsOn`). Band row = Action `Repeat 5 times` / `If ...` / `Else if ...` / `Else`, steps indented 2 spaces per level in Action; the grid shows each band shaded. Band rows are not editable (`V28_Editable` refuses a container), selecting one selects the block in the tree (row actions then work on the whole block); Else bands have no node. Flag: ini `[V32] Bands=0` switches them off (`s.Bands`). Macros without blocks are unchanged. The V27 grid self-tests now run with the flag off; V32 checks cover the band rows.

## Seen live (Wine, real key presses, harnesses v32a / v32b / v32c / v32d)
- Steps A..F: Shift+Down range B,C; Alt+Down -> ADBCEF; Alt+Up x2 -> ABCDEF, BCADEF; sentence at the edge; Ctrl+Shift+D -> ABCBCDEF (the Lab did not open); Shift+Delete -> ADEF after one box, second delete no box; each undone with Ctrl+Z; Ctrl+Shift+= inserted `text` below B and F2 + `NEW` edited it; no ticks left; an old tick was kept; sorted view refused; Alt+Down in List view did nothing.
- Find: 3 matches, Enter / Shift+Enter / F3 / Shift+F3 incl. wrap, no match text, Esc gives the focus back and the grid back its place; List and Values sheets.
- Header filter: Program (notepad rows 1,3,6) then Action Type -> 1,6; text filter combined; Clear; run start / end.
- Bands: Repeat with 2 steps, If / Else, sorting / filtering hides them, Alt+Down inside a block, F2 on a band row refused.
- Screenshots: `V32-preview.png` (header filter `Program ▼=`, 3 rows shaded as a range); band rows were looked at in a screenshot too.

## Not verified / unsure
- Mouse: right-click menus (built, not shown: `Menu.Show` blocks under Wine), real Shift+click, a real click on the arrow part of a title (`V32_HeaderHit` reads the cursor; only the false case and the popup functions were exercised), the popup's tick boxes by mouse.
- `▾` showed as an empty box in the Wine font; `▼=` and `▼` were fine. Windows has the glyph through font fallback but this was not seen.
- 125 % / 150 % scaling of the arrow zone and the popup position.
- Ctrl+Shift+= depends on the keyboard layout (also Ctrl+Shift+numpad plus).
- Undo restores the step order but not the row selection (nodes are rebuilt from JSON); the cursor falls back to the first row.
