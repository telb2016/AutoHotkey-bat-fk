# Work plan: V28 - edit cells in the grid, like Excel

Do this AFTER V27 is finished. Work on `VisualMacroBlocks-makecode-telek-V27-grid.ahk2`, save as
`VisualMacroBlocks-makecode-telek-V28-editcells.ahk2`. Same rules as earlier plans. Prefix `V28_`.
Self-test `Failures: 0` and more PASS lines than V27. One commit per item + `V28-NOTES.md`.

## Goal (owner): "make the cells editable in the grid directly, like Excel"

## How (a ListView cannot edit cells by itself)
Put a small edit control ON TOP of the cell:
- Which cell: on double-click, F2 or Enter in the grid, find row + column with `LVM_SUBITEMHITTEST` (0x1039, an
  LVHITTESTINFO with the mouse point in client coordinates) - for F2 / Enter use the selected row and the "current
  column" (`s.GridCol`, set by the last click; Left / Right arrows move it; show it by putting `[ ]` around that
  column's header title or, simpler, in the status bar: `Cell: Waits first`).
- Where: `LVM_GETSUBITEMRECT` (0x1038; RECT.top = column index (1-based subitem), RECT.left = 0 for LVIR_BOUNDS) gives
  the cell rectangle; map it to the Gui and place the editor there (convert pixels to Gui units the same way V22's
  header code does).
- Editor: one hidden `Edit` (`s.CellEdit`) and one hidden `DropDownList` (`s.CellPick`) created once in `VMB_BuildGui`.
  Text columns use the Edit; choice columns use the drop-down.
- Enter = save and move down one row; Tab = save and move to the next editable cell in the row (Shift+Tab back);
  Esc = cancel; clicking elsewhere = save. Use `#HotIf` on "cell editor has focus" for Enter / Tab / Esc (see how
  `V13_InspFocused` does it for the Step settings panel).
- Hide the editor on scroll, column resize, sort, filter, refresh, and when a run or recording starts.

## Item A - what a cell change means (pure, self-tested)
`V28_Editable(node, key)` -> `""` (not editable), `"text"`, or an array of choices.
`V28_ApplyCell(node, key, input)` -> `{Ok: true}` or `{Ok: false, Error: "plain sentence"}`; changes the node only
when Ok. Rules:

| Column | Editable for | Editor | Writes |
|---|---|---|---|
| Text / keys | Type steps (not ask-each-run) | text | `text` |
| Text / keys | Press steps | text | `keys` (raw AutoHotkey keys; the editor opens with the RAW keys, e.g. `^{a}`, not the words; reject unbalanced `{` `}`) |
| Text / keys | Scroll steps | text `down 3` | `direction`, `count` |
| Button | click / drag | Left, Right, Middle | `button` |
| Clicks | click | 1, 2, 3 | `count` |
| Held keys | click / drag | none, Ctrl, Shift, Ctrl+Shift | `mods` (`""`, `^`, `+`, `^+`; delete the key when none) |
| X, Y | click / drag with `geo` | whole number >= 0 and inside the recorded size | `geo["cx"]` / `geo["cy"]`, and set `noVerify` := 1 (the saved picture no longer belongs to the new spot); old steps without `geo`: `scrX` / `scrY` |
| Waits first | every step | text: `2`, `2s`, `2.5 s`, `500ms`, `500`; blank or `auto` = automatic | `delayMs` (delete the key for automatic). A bare number below 30 means seconds, otherwise milliseconds - say this in the cell hint |
| Scroll back | steps that have `scroll` | text: row number; `no` removes it | `scroll["v"]` or delete `scroll` |
| Window size | Normalize steps | text `800 x 600` or `maximized` | `width`, `height`, `maximize` (min 50) |
| On | every step | on, off | `disabled` |
| Note | every step | text | `note` (delete the key when blank) |

Everything else (#, Inside, Program, Window, Action, On what, Where, Follows, Checks picture, Last run, Often shaky)
is worked out from other things and is NOT editable: double-click on those opens the normal Edit dialog instead.
Pure parser `V28_ParseWait(text)` -> ms, `"auto"`, or an error. Self-test every row of the table: one good value, one
bad value (node unchanged, error text returned), and the non-editable columns.

## Item B - the editor in the window
- Before a change: `VMB_Snapshot()` (so Ctrl+Z undoes one cell edit). After: `s.Dirty := true`,
  `VMB_Refresh(node)` (keeps sort / filter and reselects the row), `V7_AutoSaveNow()`.
- A rejected value: keep the editor open, show the error sentence in the status bar, select all text.
- Non-editable cells are shown as they are; when the user presses F2 on one, the status bar says
  `This cell is worked out from the step. Double-click opens the full Edit box.`
- Never while recording or playing (`VM_IsRecording()` / `VM_IsPlaying()`).
- When the grid is sorted or filtered, editing still works (it edits the node behind the row).

## Item C - small Excel habits
- Delete key on a Note / Waits cell clears it (note removed / wait automatic).
- Ctrl+D in the grid = copy the value of the cell ABOVE (in the shown order) into the current cell, when both are the
  same editable column and the value is valid for this step.
- Typing a letter or digit while a row is selected starts editing the current column's cell with that character
  (only when the cell is editable).

## Help and version
Line 1 `V27` -> `V28` + block; window title both places; "NEW IN V28" help paragraph listing which columns can be edited.

## PC check (new section "Edit cells" in PC-TEST-ALL.md)
1. Double-click a Waits cell, type `2`, Enter: cell shows `2 s*`, Ctrl+Z puts it back.
2. Change a Type step's text in the grid, Play: the new text is typed.
3. Change Clicks from 1 to 2: the Action column changes to Double-click.
4. Type `abc` into an X cell: nothing changes, the status bar explains why.
5. F2 on a Program cell: status bar says it is worked out.

## Hand back
Find / replace blocks, new function text, self-test lines and PASS count, anything unsure (especially the cell
rectangle at 125% / 150% scaling, and focus handling of the overlay editor).
