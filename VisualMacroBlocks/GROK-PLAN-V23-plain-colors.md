# Work plan: V23 - plain black-on-white step list (+ one improvement)

Work on `VisualMacroBlocks-makecode-telek-V22-columns.ahk2`, save as `VisualMacroBlocks-makecode-telek-V23-plain.ahk2`.
Same rules as earlier plans (V19 plan section 1). Self-test `Failures: 0`, more than 388 PASS. One commit per item + `V23-NOTES.md`.

## Why it looks bad now (owner: "colours in the middle make it hard to read")
`VMB_OnCustomDraw` gives every tree row a filled BACKGROUND colour from `VMB_KindColor` (via `s.ItemColor`).
A TreeView fills only behind the row's text, so with V22's long padded columns each row is a coloured bar of a
different length, starting after the margin - blocks of blue/green/purple in the middle of the list.

## Item A - plain list (default)
- New ini setting `[V23] PlainList`, default 1. Store in `s.PlainList` at startup.
- In `VMB_OnCustomDraw`, for `ctl = s.TV` when `s.PlainList` is on: do NOT apply `s.ItemColor` backgrounds.
  Use default white background, black text. Keep these exceptions only:
  - running step (`item = s.HiItem`): black on yellow (unchanged - needed to follow playback);
  - selected row: keep the system default selection (just `return 0`), not the forced white-on-black;
  - disabled steps (`(off)`): grey text 0x909090 on white background;
  - container rows (Repeat / If / Else / For): black text, no fill (they are already bold).
- The toolbox (`s.Pal`) keeps its colours; only the macro list changes.
- Right-click menu entry "Coloured rows" toggles `PlainList` (writes ini, `VMB_Refresh()`), so the old look is one click away.
- Pure helper `V23_RowColors(kind, state)` returning `[text, back]` or 0 (= default); self-test it.

## Item B - warning rows in red text (planner's pick)
With colour gone, make the one thing that matters stand out: a step with a note in the last run (`s.LastNotes`)
draws its text in dark red (0x0000C0 in BGR = red) on white. Same for a step whose window program is not running
right now? NO - keep it to last-run notes only. Self-test via `V23_RowColors`.

## PC check (add to V23-NOTES.md)
1. The list is black text on white, no coloured bars. 2. Playing highlights the running row in yellow.
3. Right-click > "Coloured rows" brings the old look back. 4. After a run with a note, that row's text is red.
