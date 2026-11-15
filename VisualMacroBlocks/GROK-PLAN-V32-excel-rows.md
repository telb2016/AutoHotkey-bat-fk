# Work plan: V32 - more Excel: work with rows in the grid, filter arrows, Find

Work on `VisualMacroBlocks-makecode-telek-V31-onlywhen.ahk2`, save as `VisualMacroBlocks-makecode-telek-V32-rows.ahk2`.
Same rules as earlier plans (V19 plan section 1). Prefix `V32_`. Self-test `Failures: 0`, more than 871 PASS.
One commit per item (push after every commit) + `V32-NOTES.md`. When in doubt, do what Excel does.
Read V27..V31 NOTES first (grid, cell editor, cursor, columns, sheets, rules).

## Item A - rows like Excel rows (the owner should never need the old List view to arrange steps)
Today steps can only be deleted / moved / duplicated with the buttons under the list, which act on the hidden tree.
In the Steps grid (only in step order, with no filter - otherwise say `Sort and filter are on: switch to Step order to move rows.`):
- Right-click a row: Insert step above / below ▸ (the V31 "Add step" kinds), Duplicate row, Delete row, Move up, Move down,
  Turn off / on. Each calls the existing functions (`VMB_DeleteSelected`, `VMB_MoveSelected`, `VMB_Duplicate`,
  `VMB_ToggleDisabled`, the V31 add-step function) after selecting the node, so undo and autosave already work.
- Keys with the grid focused: Alt+Up / Alt+Down move the row; Ctrl+`-` deletes the row is taken by zoom, so use Ctrl+Shift+`-`
  ... NO: keep it simple and safe - Delete on a NON-clearable cell asks nothing and does nothing; row delete is
  Shift+Delete (with one confirm box the first time per session); Ctrl+Shift+`+` inserts a Type step below; Ctrl+Shift+D duplicates.
- Multi-row selection: Shift+Up / Shift+Down and Shift+click extend a row range (keep the ListView single-select and
  track the range yourself in `s.GridRange`, shading those rows through the existing custom draw). Delete / Move /
  Duplicate / Turn off act on the whole range (map to the tree's ticked-items feature: tick those nodes, call the
  existing function, untick). Pure `V32_Range(anchor, current, count)`; self-test.
- After any of these, the same step(s) stay selected and the cell cursor stays in its column.

## Item B - filter arrows in the headers (Excel AutoFilter)
- A small ▾ at the right of each header title. Clicking the ▾ area (the right 18 px of a header; a click elsewhere on
  the header still sorts) opens a popup list of that column's distinct values with tick boxes, plus (Select all),
  a search box on top, OK / Cancel - a small borderless Gui placed under the header, not a Menu (menus cannot hold tick lists).
- Several columns can be filtered at once (AND). A filtered column's header shows ▾ in bold / a funnel mark `▼=`.
  The V27 filter box and the two drop-downs keep working and combine with it; "Clear" clears everything.
- Pure `V32_Distinct(rows, key)` (sorted, numbers as numbers, `–` last) and `V32_ApplyPicks(rows, picks)`; self-test.

## Item C - Find (Ctrl+F)
- Ctrl+F with a grid focused opens a small Find bar above the grid: text box, Next (Enter / F3), Previous (Shift+F3),
  "n of m" count, Esc closes. It moves the CELL CURSOR to each matching cell (row order, then column order) and scrolls
  to it; it never filters. Works on the Steps, List and Values sheets (the sheet that has the focus).
  Pure `V32_FindAll(rows, columns, needle)` -> array of [row, key]; `V32_FindStep(matches, current, dir)`; self-test.

## Item D - hand-made loop / If blocks as band rows (left over from V30 item D)
For macros that contain Repeat / For / For each / If blocks made in List view: show each block as a shaded band row in the
Steps grid (Action column: `Repeat 5 times`, `If ...`, `Else`), its steps under it indented two spaces per level in the
Action column. Band rows are not editable, cannot be the cell cursor's row for editing, and are hidden while sorted by
anything but `#` or while filtered. `V27_Rows` already walks the blocks: add the band rows there behind a flag.

## Live check (Wine) and PC check
Live: range select by Shift+Down, move down, duplicate, delete, undo each, and compare the macro's step order with the
expected order after every action; insert a Type step below and edit its Text cell; header filter picks applied by
calling the popup's OK function with chosen values (two columns) and the shown rows logged; Find through 3 matches
forward and back; band rows for a hand-made Repeat with 2 steps. Screenshot with a range selected and a header filter
active -> `V32-preview.png` (look at it). `Menu.Show` blocks under Wine: call action functions directly.
Add section "Rows, filters, Find" to PC-TEST-ALL.md.
