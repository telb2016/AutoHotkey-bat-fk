# Instructions for the AI on the Windows PC: test Visual Macro Blocks V33

You are testing a program on a real Windows PC because the people who built it only had Linux (Wine). Your job is to
run the checks below, write down exactly what happened, and hand back one results file. You are a tester, not a
developer: **do not change the script.** If something fails, record it and go on.

## Safety rules (read first - this is a work computer)
1. Test ONLY against **Notepad** and the small test windows the program opens itself. Never record, click or type in
   Citrix, Edge, an electronic health record, email, or anything holding patient or work data.
2. Never type real names, patient data or passwords. Use the made-up values given below (Smith, Jones, 250 ...).
3. Do not open, play or change the owner's existing macros. Start each check from **New** (an empty macro).
4. If any box asks to save over an existing file, say No / Cancel. Save test macros only into a new folder
   `Documents\VisualMacros\ai-test\`.
5. The emergency stop is **Ctrl+Shift+X** (quits the program). **Esc** stops a running macro.
6. If the mouse or keyboard starts doing something you did not expect, press Esc, then Ctrl+Shift+X, and write it down.

## What you need
- The file `VisualMacroBlocks-makecode-telek-V33-cells.ahk2` (same folder as this document in the repository
  `telb2016/AutoHotkey-bat-fk`, branch `claude/recording-process-consistency-e3nt05`, folder `VisualMacroBlocks`).
  Save a copy as `C:\Temp\vmb\VMB33.ahk` (the `.ahk` ending matters).
- **AutoHotkey v2.0.19 or newer, 64-bit** (`AutoHotkey64.exe`). Write down the exact version and that it is 64-bit.
- `PC-TEST-ALL.md` from the same folder: the detailed hand checks. This document tells you the order and what to report.

## Part 1 - automatic checks (5 minutes, no judgement needed)
1. Self-test. Run:
   `"C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" C:\Temp\vmb\VMB33.ahk --self-test C:\Temp\vmb\selftest.txt`
   Open `selftest.txt`. Report the last line (`Failures: N`), the number of lines starting with `PASS`, and every line
   that does NOT start with `PASS`. Expected: `Failures: 0`, 947 PASS.
2. Start the program normally (double-click `VMB33.ahk`). Report any error or warning box, word for word.
3. Click the **?** button -> **Check this PC**. When the result window appears, click **Copy** and paste the whole text
   into your results file. (Already seen once on this PC: all PASS except a "Fonts" CHECK - that one is known.)

## Part 2 - the one test that matters most: record once, replay the same
Do this slowly, like a person would.
1. Open Notepad. Make its window about half the screen, not maximized.
2. In the program click **New**, then **Record**. (First time only, a notice appears - click OK.)
3. Click inside Notepad's text area. Type `hello`. Press Enter. Type `world`. Double-click the word `hello`. Type `X`.
4. Click the red **REC** bar at the bottom-left of the screen to stop.
5. Write down every row of the **Steps** grid (the columns #, Program, Action, On what, Text / keys). Expected: step 1
   "Window" (puts Notepad back to its size), then Click, Type "hello", Press Enter, Type "world", Double-click, Type "X".
   Enter must appear ONCE, and there must be ONE double-click row (not two clicks).
6. Write down Notepad's text (expected: `X`, new line, `world`).
7. In Notepad select all and delete. **Move the Notepad window somewhere else and change its size.**
8. Click **Play**. Watch. Then write down: did Notepad jump back to its recorded size and spot? Notepad's text
   afterwards (expected: the same as in step 6)? The status bar text at the bottom of the program, word for word?
9. Clear Notepad and press **Play** twice more. Report whether the text was identical all three times.
10. Close Notepad completely. Press **Play**. Expected: a box "Ready to play?" naming notepad; choose **No**. Report
    the box text. Then open Notepad again.
11. Save the macro as `Documents\VisualMacros\ai-test\notepad-test.vmacro.json`.

## Part 3 - scroll position (could never be tested on Linux)
1. Notepad: turn Word Wrap off, paste 300 short lines (`line 1` ... `line 300`), scroll so about line 150 is at the top.
2. **New**, **Record**, click on a visible line, type `X`, stop with the REC bar.
3. Report the grid's **Scroll back** cell for the Click row (expected something like `row 150`; if it says `no`, say so
   and say which Notepad this is: classic or the Windows 11 tabbed one).
4. Undo the `X` in Notepad, scroll Notepad to the top, press **Play**. Report which line got the `X` (expected: the same
   line as when recording) and the status bar text.

## Part 4 - what the grid knows about a click
1. **New**, **Record**. In Notepad: click the **File** menu, click **Save As...**, in the Save dialog click **Cancel**,
   click Notepad's **Maximize** button, click it again to restore. Stop.
2. Report the **On what** cell and the **Window** cell of each Click row. Expected along the lines of: menu "File",
   menu item "Save As...", the "Cancel" button, Maximize button. Write exactly what you see, including `–`.

## Part 5 - the grid as a spreadsheet (use the Part 2 macro: Open `notepad-test`)
For each line write PASS or FAIL and one sentence on what happened.
1. Zoom: hold Ctrl and turn the mouse wheel over the grid; then Ctrl+0. Text gets bigger / smaller / back to 100%.
2. Cell cursor: click a cell - a green border appears on it; arrow keys move it.
3. Edit: double-click the **Waits first** cell of the Type "hello" row, type `2`, Enter. Cell shows `2 s*`. Ctrl+Z puts
   it back.
4. Edit text: double-click the Text cell of the Type "world" row, change it to `there`, Enter. Clear Notepad, Play,
   report Notepad's text. Then Ctrl+Z.
5. Drop-down: double-click a **Clicks** cell, choose 2. The Action cell becomes Double-click. Ctrl+Z.
6. Sort: click the **Action** header - rows group by action; click **Step order** - back to 1, 2, 3 ...
7. Filter: type `type` in the Filter box - only Type rows; **Clear**.
8. Header filter arrow: click the small ▼ at the right end of the **Action** header - a tick list opens; untick Click,
   OK - Click rows disappear; **Clear**.
9. Find: Ctrl+F, type `world`, Enter - the cursor jumps to that cell; Esc.
10. Row move: click a row, Alt+Down - it moves down one; Ctrl+Z.
11. Range: click a Waits cell, Shift+Down twice - three cells shaded, the status bar shows a count; Delete; Ctrl+Z.
12. Right-click a row - a menu with Insert / Duplicate / Delete / Move appears (just close it).
13. Right-click a column header - a list of columns to show / hide appears (just close it).
14. Scroll the grid sideways with the bottom scroll bar - the # and Action columns stay visible on the left.
15. Click **List** (the old tree view), then **Grid** - both show the same steps.
16. Close and restart the program - zoom, column widths and the macro are as you left them.

## Part 6 - repeat for a list (no loop blocks)
1. **New**. Record in Notepad: click in the text area, type `Smith`, press Tab, type `250`, press Enter. Stop.
2. Click the **List** tab. Click **Paste list** after copying these three lines (tab-separated) to the clipboard:
   ```
   Name	Amount
   Smith	250
   Jones	75
   Lee	5
   ```
3. A question offers to use the Name / Amount columns - answer **Yes**. Back on **Steps**, report the two Text cells
   (expected `=Name → "Smith"` and `=Amount → "250"`).
4. Choose **Run: for each row of the List (3 rows)**. Clear Notepad. **Play**.
5. Report Notepad's text (expected three lines: `Smith<tab>250`, `Jones<tab>75`, `Lee<tab>5`), the status bar text, and
   the **Result** column on the List tab.
6. On Steps, in the **Only when** cell of the `=Amount` Type row type `Amount > 100`, Enter. Clear Notepad, Play.
   Report Notepad's text (expected: the amount appears only on the Smith line).

## Part 7 - what you could not do
List every step you skipped or could not perform and why (no mouse control, a box you could not read, and so on).

## The results file
Write `PC-TEST-RESULTS.md` with: date, Windows version, AutoHotkey version and 32 / 64-bit, screen resolution and
scaling (Settings > Display), which Notepad (classic or Windows 11 tabbed), then one section per Part with the reports
asked for above. Quote program messages word for word. Add screenshots of anything that looks wrong (grid drawing,
overlapping controls, empty boxes instead of symbols) - make sure a screenshot shows only Notepad and the program.
Give the file to the owner; if you have write access to the repository, also put it in the `VisualMacroBlocks` folder
on the same branch.
