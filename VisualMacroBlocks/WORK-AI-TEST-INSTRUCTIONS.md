# Instructions for the AI on the Windows PC: test Visual Macro Blocks V34

You are testing a program on a real Windows PC because the people who built it only had Linux (Wine). Your job is to
run the checks below, write down exactly what happened, and hand back one results file. You are a tester, not a
developer: **do not change the script.** If something fails, record it and go on.

## Retest after V34 (do these first, then the rest; same folder and safety rules as below)
The first PC test found 8 problems; V34 changes the program for them. Please report:
1. **Part 2 steps 5-10, with TEN replays** (not three): after recording, play the macro ten times, clearing Notepad's text
   before each play. Report "n of 10 identical" (text `X` / `world`), and the exact status text of every play that differs.
   Also note how long one play takes (V34 waits at least 0.12 s between typing / click steps; setting `minStepMs`).
2. **5.13** right-click on a column title (e.g. Action) with the editor window NOT at the top-left of the screen: the column menu must open
   under the mouse. Also click the **?** button: its menu must open just under the button.
3. **Maximize / Restore naming**: record a click on Notepad's Maximize button, then on the same spot again (now Restore). Expected rows
   "the Maximize button" then "the Restore button" (Minimize and Close likewise). Report what the grid says for each.
4. **Fast typing + Enter in a cell**: double-click a Text cell, type `there` and press Enter at once (the harness may send them with no
   pause). The cell must hold `there`; try also a Waits first cell with `2`. Report 5 tries.
5. **"Ready to play?" with Notepad closed in Easy mode**: record a Notepad macro, close Notepad, press Play in Easy mode. The box
   "Ready to play?" must appear and name Notepad. Answer **No** (do not play it).
6. **Unsaved changes**: change a Text cell (title shows `*`), close the editor with the X button (it hides to the tray, nothing is asked),
   end the script (tray menu or Ctrl+Shift+X), start it again. The title should show `*` again and the status bar should say
   "Restored your unsaved changes ...". Report what you saw.


## Where you may write files (the first version of this document got this wrong - follow it exactly)
- EVERYTHING you create goes into ONE local folder: `C:\Temp\vmb\` (create it). That means the script copy, the
  self-test report, test macros, your results file, screenshots, notes, and any helper script you write.
- NEVER write to any other drive or folder: no network or mapped drives (Q:, H:, S: ...), no home drive, no shared
  folders, no OneDrive / Documents, no Desktop, not your own working directory if it is anywhere else.
  If `C:\Temp\vmb\` cannot be created or written, STOP and tell the owner. Do not pick another place.
- NEVER let a Save / Save As / Export dialog save anything, in Notepad or in the program, except when a step below
  tells you to save a test macro - and then type the FULL path starting with `C:\Temp\vmb\` yourself; never accept
  the folder the dialog opens in (it is often a network home drive).
- When Notepad asks "Do you want to save changes?" answer **Don't Save**.
- Do not push or upload anything anywhere. Hand the results file to the owner.
- LAST STEP of the whole test: list every file you created, with its full path, in the results file.

## Safety rules (read first - this is a work computer)
1. Test ONLY against **Notepad** and the small test windows the program opens itself. Never record, click or type in
   Citrix, Edge, an electronic health record, email, or anything holding patient or work data.
2. Never type real names, patient data or passwords. Use the made-up values given below (Smith, Jones, 250 ...).
3. Do not open, play or change the owner's existing macros. Start each check from **New** (an empty macro).
4. If any box asks to save over an existing file, say No / Cancel. Put every test file (script copy, self-test
   output, test macros, results) only in `C:\Users\VHACLETelekB\Downloads\vmb-test\`.
5. Never create, change or delete anything on a mapped or network drive (Q:, H:, any `\\server\` path), in
   Documents/OneDrive, or anywhere outside `Downloads\vmb-test\`. If something already exists there that the tests did
   not make, leave it alone and report it. Exception: the program itself keeps its settings and a quick write check in
   `Documents\VisualMacros\`; that is normal. Do not open, change or delete the macros already in that folder.
6. The emergency stop is **Ctrl+Shift+X** (quits the program). **Esc** stops a running macro.
7. If the mouse or keyboard starts doing something you did not expect, press Esc, then Ctrl+Shift+X, and write it down.

## What you need
- The file `VisualMacroBlocks-makecode-telek-V34-pcfixes.ahk2` (same folder as this document in the repository
  `telb2016/AutoHotkey-bat-fk`, branch `claude/recording-process-consistency-e3nt05`, folder `VisualMacroBlocks`).
  Save a copy as `C:\Users\VHACLETelekB\Downloads\vmb-test\VMB34.ahk` (the `.ahk` ending matters).
- **AutoHotkey v2.0.19 or newer, 64-bit** (`AutoHotkey64.exe`). Write down the exact version and that it is 64-bit.
  On this PC it is NOT in Program Files; use
  `C:\Users\VHACLETelekB\repos\pharmacy-informatics-CLE-testing\AutoHotkey\v2\AutoHotkey64.exe` (2.0.19, 64-bit).
- `PC-TEST-ALL.md` from the same folder: the detailed hand checks. This document tells you the order and what to report.

## Part 1 - automatic checks (5 minutes, no judgement needed)
1. Self-test. Run:
   `"C:\Users\VHACLETelekB\repos\pharmacy-informatics-CLE-testing\AutoHotkey\v2\AutoHotkey64.exe" "C:\Users\VHACLETelekB\Downloads\vmb-test\VMB34.ahk" --self-test "C:\Users\VHACLETelekB\Downloads\vmb-test\selftest.txt"`
   Open `selftest.txt`. Report the last line (`Failures: N`), the number of lines starting with `PASS`, and every line
   that does NOT start with `PASS`. Expected: `Failures: 0`, 999 PASS. The self-test writes only to
   `Downloads\vmb-selftest\` and deletes it at the end; report it if that folder is still there afterwards.
2. Start the program normally (run `VMB34.ahk` with the AutoHotkey64.exe above). Report any error or warning box, word for word.
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
11. Save the macro as `C:\Users\VHACLETelekB\Downloads\vmb-test\notepad-test.vmacro.json`.

## Part 3 - scroll position (could never be tested on Linux)
1. Notepad: turn Word Wrap off, paste 300 short lines (`line 1` ... `line 300`), scroll so about line 150 is at the top.
2. **New**, **Record**, click on a visible line, type `X`, stop with the REC bar.
3. Report the grid's **Scroll back** cell for the Click row (expected something like `row 150`; if it says `no`, say so
   and say which Notepad this is: classic or the Windows 11 tabbed one).
4. Undo the `X` in Notepad, scroll Notepad to the top, press **Play**. Report which line got the `X` (expected: the same
   line as when recording) and the status bar text.

## Part 4 - what the grid knows about a click
1. **New**, **Record**. In Notepad: click the **Edit** menu, click **Go To...** (classic Notepad; in the Windows 11
   Notepad use **Edit > Find**), in the small box that opens click **Cancel** (or its X), click Notepad's **Maximize**
   button, click it again to restore. Stop. Do NOT open any Save, Save As, Open or Print dialog in this part.
2. Report the **On what** cell and the **Window** cell of each Click row. Expected along the lines of: menu "Edit",
   menu item "Go To...", the "Cancel" button, Maximize button. Write exactly what you see, including `–`.

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
16. Close and restart the program (same command with `--data`) - zoom, column widths and the macro are as you left them.

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
Write `C:\Users\VHACLETelekB\Downloads\vmb-test\PC-TEST-RESULTS.md` with: date, Windows version, AutoHotkey version and 32 / 64-bit, screen resolution and
scaling (Settings > Display), which Notepad (classic or Windows 11 tabbed), then one section per Part with the reports
asked for above. Quote program messages word for word. Add screenshots of anything that looks wrong (grid drawing,
overlapping controls, empty boxes instead of symbols) - make sure a screenshot shows only Notepad and the program.
Write it to `C:\Temp\vmb\PC-TEST-RESULTS.md` (screenshots in the same folder) and tell the owner it is there.
Do not put it anywhere else. End the file with the list of every file you created (full paths).
