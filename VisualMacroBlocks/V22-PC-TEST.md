# V22 - checks for the owner's PC (one time)

File: `VisualMacroBlocks-makecode-telek-V22-columns.ahk2`. These could not be done on the test machine (Wine on
Linux: no Consolas font - a look-alike was put in its place for the test - no real Windows tree control, one screen
at 96 dpi). Tick each one off.

## 0. Self-test first

`AutoHotkey64.exe VisualMacroBlocks-makecode-telek-V22-columns.ahk2 --self-test C:\temp\report.txt`
must end with `Failures: 0` and have **388** PASS lines (V22 had 373, V21 had 347). Use the AutoHotkey version on the PC (the
file is written for v2.0.19; Wine used 2.0.27).

## From the plan, section 8

1. [ ] **Every row has a program:** open a recorded macro. Every step row shows a program in the Program column
   (a Delay or a key step without a window of its own shows the program of the step before it), and the columns
   `#`, `Program`, `Waits`, `Marks`, `What it does` line up under the header line.
2. [ ] **Change of program:** record a task that uses two programs (for example Notepad, then Paint). The first step
   in the second program has `►` in the `#` column (and so has the first step back in Notepad).
3. [ ] **Inside a block:** put two steps inside a Repeat block (select them, "Into block above"). Their number,
   program and sentence still line up with the rows outside the block. If they are off by a constant amount, say by
   how many characters (and by how much per level, if you nest a block inside a block). This is the one thing Wine
   could not prove: Windows may refuse the small tree indent the columns ask for; the program then widens it by
   whole characters itself, so the rows should still line up.
   If the rows inside a block are out of line, press ? and read me the 'Column check' line.
4. [ ] **Zoom:** make the list bigger and smaller (A+ / A-, or Ctrl + / Ctrl - in the list). Columns and header still
   line up. The header text may start a hair (about 2 px) left of the row text - that is expected; tell if it is
   off by a whole character or more, or if the header letters are cut off at the bottom at a big size.
5. [ ] **Marks:** a step with a note shows `✎`, a step scrolled back first `↕`, a step that varies `⚡`, "whatever
   window is active" `◇`, a note from the last run `⚠`. If the marks (or `►`) show as boxes or push the columns out
   of line, set `PlainMarks=1` under `[V22]` in `Documents\VisualMacros\VisualMacroBlocksV10.ini` and restart:
   they become `S V A N !` and `>`.
6. [ ] **Switch off:** right-click the list, untick "Show columns" (or untick "Columns" next to Explain steps in the
   Step settings panel): the list looks like V21 again (Segoe UI, `#1  sentence ...`), the header line is gone. It
   stays off after a restart; tick it again to get the columns back.
7. [ ] **Status bar:** click a step row: the status bar shows the whole story, for example
   `Step 6 · notepad · waits 3.2 s first · Click a text box — top-left (120, 60) · list is scrolled back first`.
   Click a different row and back to see it again after a change (on purpose it does not repeat for the same row,
   so messages like "Moved up." stay visible).
8. [ ] **Still open from the V21 checklist:** items 1-6 of `V21-PC-TEST.md` (scroll restore, what was clicked,
   button caption, title bar buttons, icons, size test at Record-stop), and V21 items 7-13 if not done yet.

## Also worth a look

9. [ ] **Easy layout:** switch to Easy mode and back: the header line moves with the list in both layouts.
10. [ ] **Display scaling:** if the PC uses 125 % / 150 % scaling, check that the header is still over the columns
    (the header position is converted from screen pixels to the window's units; Wine only ran at 100 %).
11. [ ] **Old macros:** open a macro made with V18 - V21 and Play it: it must behave exactly as before (V22 only
    changes how the list looks).
