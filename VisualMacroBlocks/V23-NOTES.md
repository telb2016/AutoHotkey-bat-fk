# V23 notes - handback

File: `VisualMacroBlocks-makecode-telek-V23-plain.ahk2` (new, copied from V22-columns; older files untouched).
One commit per item (A, B), this file last. Rules: V19 plan section 1.

## Result
- Self-test under Wine (AutoHotkey 2.0.27): **395 PASS, `Failures: 0`** (388 before; +4 item A, +3 item B). Validate: rc 0, no output.
- After each item: Notepad record / replay (`KEEP MEhello grokbot` / `line2`, 0 notes) and replay of an older (V18-recorded) macro (same result, 0 notes).
- Screenshot after A: list is black on white, no coloured bars; the toolbox keeps its colours.

## Item A (1132185f) - plain list
- `[V23] PlainList` (default 1) -> `s.PlainList`. In `VMB_OnCustomDraw` (macro list only) no `s.ItemColor` backgrounds when on:
  running step stays black on yellow, selected row = system default (`return 0`), disabled steps grey 0x909090 on white,
  container rows default (black, no fill). Toolbox unchanged.
- Per-row `s.ItemKind` / `s.ItemState` (set in `VMB_AddBody`) feed the pure helper `V23_RowColors(kind, state)` -> `[text, back]` or 0.
- Right-click > "Coloured rows" (ticked when the old look is on) toggles `PlainList`, writes ini, `VMB_Refresh()`.
- Self-test: 4 checks of `V23_RowColors`.

## Item B (61e95d30) - red text for last-run notes
- A step with a note in `s.LastNotes` gets state "note" -> `V23_RowColors` = [0x0000C0, 0xFFFFFF] (dark red on white). Only last-run notes;
  control rows stay default; "off" wins over "note". Self-test: 3 more checks.

## What Wine could not prove
- Real Windows TreeView drawing (selection colour, yellow running row during playback, red row after a run with a note): not seen under Wine.
  Only the plain list, the toolbox colours and pure-function results were verified.

## PC check
1. The list is black text on white, no coloured bars.
2. Playing highlights the running row in yellow.
3. Right-click > "Coloured rows" brings the old look back.
4. After a run with a note, that row's text is red.
