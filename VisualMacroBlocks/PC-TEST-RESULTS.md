# PC test results - Visual Macro Blocks V33 (cells)

- **Date:** 2026-11-15, 08:00-08:41
- **Windows:** Windows 11 Enterprise 10.0.26200 (build 26200)
- **AutoHotkey:** 2.0.19, 64-bit (pointer size 8), run from
  `repos\pharmacy-informatics-CLE-testing\AutoHotkey\v2\AutoHotkey64.exe`
- **Screen:** 3840 x 2160, scaling 100 % (96 dpi)
- **Notepad:** classic Win32 Notepad 10.0.26100.8457 (it shows the banner "A new version of Notepad is available")
- **Tester:** an AI (Copilot). Part 1 was done by hand through Computer Use. Parts 2-6 were done by a local AutoHotkey
  harness (`Downloads\vmb-test\VMB33_Harness.ahk`) that moves the real mouse and presses real keys
  (`Click` / `Send` at `SendLevel 1`). Raw logs: `Downloads\vmb-test\harness-log-*.txt`.
- **Script:** V33 with one change, commit 621ed5c1 (the self-test no longer writes to `Q:`, see Part 1).

## Summary

| Part | Result |
|---|---|
| 1 Automatic checks | PASS after the Q: fix (948 PASS, 0 failures). Check this PC: all PASS except the known Fonts CHECK. |
| 2 Record once, replay | Recording PASS. Replay passed on plays 1 and 3; play 2 came out different. "Ready to play?" not tested. |
| 3 Scroll position | PASS: Scroll back = `row 150`, X typed on the same line (155) after playback. |
| 4 What the grid knows | Menu, menu item and Cancel PASS. Maximize / Restore clicks are named wrong. |
| 5 Grid as a spreadsheet | 14 of 16 PASS. 5.4 replay wrong (same problem as Part 2). 5.13 header right-click menu never opens (bug). |
| 6 Repeat for a list | PASS (all 6 steps). |

## Bugs and findings for the developer

1. **Self-test wrote to a real network share (fixed in 621ed5c1).** `V26 can write: a folder that cannot exist` used
   `Q:\no\such\drive\x`. On this PC `Q:` is a mapped share (`\\VHACLECCAPYXCCE.v10.med.va.gov\McK`), so
   `V26_CanWrite` (`DirCreate`) made the empty folders `Q:\no\such\drive\x` there and the check failed. The self-test
   now writes only to `Downloads\vmb-selftest` (removed at the end) and uses an illegal folder name (`bad|name`).
   Never use a drive letter as "a folder that cannot exist".
2. **Header right-click menu never opens (5.13).** `V27_OnMenu` and `V29_OnGuiMenu` pass the ContextMenu event's
   `x, y` to `V29_OnHeader`, which compares them with `GetWindowRect` (screen coordinates). AutoHotkey gives
   ContextMenu `x, y` relative to the GUI client area, so the test only succeeds when the editor window is at the
   top-left of the screen (as it probably was under Wine). The editor here was at 1092,636: no menu appeared.
   `V29_ColMenu(x, y)` then shows the menu with `CoordMode("Menu", "Screen")`, which has the same mix-up.
3. **Replay sometimes loses the Enter and turns the Double-click into a single click.** Notepad macro: Click, Type
   "hello", Press Enter, Type "world", Double-click "hello", Type "X". Play 1 and play 3 gave `X` / `world` (correct).
   Play 2 gave `X` only, with the status note `⚠ Step #6: the screen at the click spot did not look like the
   recording (waited 1.5 s); clicked the recorded spot anyway.` In 5.4 (Text cell changed to "there") both plays gave
   `Xhellothere`: no new line, and X inserted before "hello" instead of replacing it. `last-playback.log` only
   repeats the step 6 note. The Press Enter step (Waits first `0`) comes right after a Type step.
4. **Caption buttons are named wrong (Part 4).** A click on Notepad's Maximize button was recorded as
   `the title bar`; the next click on the same spot (now the Restore button, window maximized) was recorded as
   `the Minimize button`. The harness clicked the centre of the button rectangles that UI Automation reports.
5. **"Ready to play?" needs Steady playback (2.10).** `VMB_Play` runs `V24_ReadyToPlay` only when
   `s.Preflight && settings.Get("steady", 0)`. The Steady playback checkbox is not shown in Easy mode, so in Easy mode
   the box never appears and the macro would play with Notepad closed. Not tested for safety (see Part 7).
6. **Fast typing in a grid cell loses its last characters.** When the harness typed `there` and pressed Enter at
   once, the cell saved `the` or `ther`, and a typed `2` was lost completely. With a 0.4 s pause before Enter it
   always worked. The Enter hotkey seems to read the box before the last keys arrive. A person typing will not see
   this, but a barcode scanner or text expander could.
7. **Closing the editor with unsaved changes did not ask (5.16).** The title showed
   `notepad-test.vmacro.json * - 7 steps`, `WinClose` closed it with no "Save changes?" question, and after the
   restart the title had no `*`. Zoom, column widths and the open macro were kept. Check whether this is intended.
8. The **?** button's menu opens at the mouse pointer (`Menu.Show()` with no position).

## Part 1 - automatic checks
1. **Self-test, original script:** `Failures: 1`, 946 PASS. The only non-PASS line was
   `FAIL | V26 can write: a folder that cannot exist` (finding 1).
   **Self-test, fixed script:** `Failures: 0`, 948 PASS (one new check: `V26 can write: bad folder not created`).
   No non-PASS lines. `Downloads\vmb-selftest` was gone afterwards.
2. **Normal start:** no error or warning box. It reopened the owner's last macro ("outpatient flex on just ON and
   rxmain top option and then execute and prompt.vmacro.json - 29 steps"); it was not played.
3. **Check this PC:**
```
Check this PC (V26) - AutoHotkey 2.0.19 - Windows 10.0.26200
PASS | Scroll (list box): read line 150, scrolled to the top, restored, back at line 150.
PASS | Scroll (text box): read line 150, scrolled to the top, restored, back at line 150.
PASS | Close: the test list window this check opened is closed.
PASS | Size: Notepad took a bigger size and went back to the original size.
PASS | Close: the Notepad this check opened is closed.
CHECK | Fonts: ⚠ ⚡ ✎ is not the same width as 0 (7 px) in the list font - the Marks column may not line up. Use plain marks (PlainMarks=1). ↕=7  ≈=7  ►=7  ◇=8  ⚠=12  ⚡=12  ✎=9.
PASS | Indent: char 7.0 px, asked 21 px, got 21 px, 3 characters.
PASS | Screen: 3840 x 2160, scaling 100 %.
PASS | Folder: can write to C:\Users\VHACLETelekB\OneDrive - Department of Veterans Affairs\Documents\VisualMacros (run history works).
1 line(s) to CHECK.
```

## Part 2 - record once, replay the same
- No first-time notice appeared (already seen before on this PC).
- REC bar: `● REC   7 steps   •   CLICK HERE (or Ctrl+Shift+R) to stop   •   Alt+Click / F7 = varying step`
- Status after stop: `Recorded 6 steps (1 double-click / wheel repeats joined).  Macro window: ahk_class Notepad
  ahk_exe notepad.exe - step #1 puts it back to 1200x900 at (200, 160).  Press Play (F5) to repeat it.`
- **Step 5, Steps grid - PASS** (Enter once, one Double-click row, Window first):

| # | Program | Window | Window size | Action | On what | Text / keys | Clicks | Waits first | Scroll back |
|---|---|---|---|---|---|---|---|---|---|
| 1 | notepad | – | 1200 × 900 | Window | – | – | – | 0 | – |
| 2 | notepad | main window | 1200 × 900 | Click | a text box | – | 1 | 300 ms | no |
| 3 | notepad | main window | 1200 × 900 | Type | – | "hello" | – | 594 ms | – |
| 4 | notepad | main window | 1200 × 900 | Press | – | Enter (OK / submit / new line) | – | 0 | – |
| 5 | notepad | main window | 1200 × 900 | Type | – | "world" | – | 0 | – |
| 6 | notepad | main window | 1200 × 900 | Double-click | a text box | – | 2 | 1.4 s | no |
| 7 | notepad | main window | 1200 × 900 | Type | – | "X" | – | 594 ms | – |

- **Step 6:** Notepad text `X` / `world` - PASS.
- **Steps 7-8:** Notepad was moved and resized to 1700,500 900x600. After Play it was back at 200,200 1200x900 -
  PASS. Text `X` / `world` - PASS. Status: `Finished.`
- **Step 9:** play 2 gave `X` (status `Finished.   ⚠ Step #6: the screen at the click spot did not look like the
  recording (waited 1.5 s); clicked the recorded spot anyway.  - see last-playback.log (F1)`); play 3 gave `X` /
  `world` (`Finished.`). **Not identical - FAIL** (finding 3).
- **Step 10:** skipped (finding 5, Part 7).
- **Step 11:** saved as `Downloads\vmb-test\notepad-test.vmacro.json` (dialog title "Save visual macro"). Title
  afterwards: `Visual Macro Blocks V33 Easy - notepad-test.vmacro.json (saved 08:23:01) - 7 steps`.

## Part 3 - scroll position (classic Notepad)
- Word wrap off; 300 lines; Notepad top line 150. Clicked line 155, typed X.
- Status: `Recorded 2 steps. ...`. Grid: 1 Window, 2 Click `a text box` with **Scroll back `row 150`**, 3 Type "X".
- Undo, Notepad scrolled to line 1, Play: **X typed into line 155 (the same line) - PASS**. Status: `Finished.`

## Part 4 - what the grid knows about a click

| # | Program | Window | Action | On what |
|---|---|---|---|---|
| 1 | notepad | – | Window | – |
| 2 | notepad | main window | Click | menu "File" |
| 3 | notepad | menu | Click | menu item "Save As..." |
| 4 | notepad | dialog | Window | – |
| 5 | notepad | – | Window | – |
| 6 | notepad | dialog | Click | the "Cancel" button |
| 7 | notepad | – | Window | – |
| 8 | notepad | main window | Click | the title bar  ← this was the Maximize button |
| 9 | notepad | main window | Click | the Minimize button  ← this was the Restore button |

The menu, menu item and Cancel rows are as expected. Rows 8-9 are wrong (finding 4). The extra Window rows (4, 5, 7)
come from the Save As dialog opening and closing.

## Part 5 - the grid as a spreadsheet (notepad-test)
1. **Zoom - PASS.** 100% → Ctrl+wheel up x2 → 120% → down x3 → 90% → Ctrl+0 → 100%.
2. **Cell cursor - PASS.** The name box followed: `Action · step 2` → Right → `On what · step 2` → Down →
   `On what · step 3`. The green border was not checked by eye.
3. **Edit Waits first - PASS.** Double-click on step 3, typed `2`, Enter: `594 ms` → `2 s*`; Ctrl+Z → `594 ms`.
   (The first runs lost the `2`: finding 6.)
4. **Edit text - FAIL (replay).** Double-click, `there`, Enter: the cell showed `"there"`. Play: Notepad
   `Xhellothere` (expected `X` / `there`), status with the step 6 note (finding 3). Ctrl+Z → `"world"`.
5. **Drop-down - PASS.** Clicks set to 2 → Action `Double-click`; Ctrl+Z → `Click`.
6. **Sort - PASS.** Action header: `Click, Double-click, Press, Type, Type, Type, Window`; Step order: 1-7.
7. **Filter - PASS.** `type` → 3 rows, all Type; Clear → 7 of 7.
8. **Header filter arrow - PASS.** The list showed `(Select all), Click, Double-click, Press, Type, Window`;
   unticked Click, OK → 6 rows, no Click; Clear. (It must be clicked well inside the last 18 px; a click 6 px from
   the edge hits the column-resize zone and does nothing.)
9. **Find - PASS.** Ctrl+F, `world`, Enter → name box `Text / keys · step 5`, status
   `Find: match 1 of 1 - row 5, Text / keys.`; Esc.
10. **Row move - PASS.** Alt+Down moved row 3 to row 4; Ctrl+Z put it back.
11. **Range - PASS.** Shift+Down x2 → status `3 cells   Ctrl+C copies, Ctrl+V pastes, Ctrl+D fills down, Delete
    clears.` Delete → `Cleared 0 cells.` (the recorded waits are not "set" waits); Ctrl+Z → unchanged.
12. **Row menu - PASS.** `Insert step above ; Insert step below Ctrl+Shift++ ; Duplicate row Ctrl+Shift+D ;
    Delete row Shift+Delete ; Move up Alt+Up ; Move down Alt+Down ; Turn off / on ; More step actions...`
13. **Header menu - FAIL.** No menu appeared after a right-click on the Action title (finding 2).
14. **Frozen # and Action - PASS.** After 4 clicks on the scroll bar's page-right area a 140 px pane showed
    `#` / `Action` for all 7 rows (`1 → Window` first).
15. **List then Grid - PASS.** Grid 7 rows, List (tree) 7 items, back in Grid 7 rows.
16. **Restart - PASS (with finding 7).** Before: 110 %, widths `44,242,121,177,121,110,220,242,77,66,110,66`.
    After restart: 110 %, the same widths, and `notepad-test.vmacro.json` open again. Zoom was then set back to 100 %.

## Part 6 - repeat for a list
1. Recorded: Window, Click `a text box`, Type "Smith", Press Tab, Type "250", Press Enter.
2-3. Paste list → question `Visual Macro Blocks - use the list columns?`:
   `Step 3 types "Smith", which is row 1 of column Name. Use the Name column there?  (The same for 1 more step.)` →
   Yes. Text cells: **`=Name → "Smith"`** and **`=Amount → "250"`** - PASS.
4. Run choice: `for each row of the List (3 rows)`.
5. **PASS.** Notepad: `Smith<tab>250` / `Jones<tab>75` / `Lee<tab>5`. Status `3 rows: 3 done.` List sheet Result
   column: `done` on all three rows.
6. **PASS.** Only when of the `=Amount` row → `Amount > 100`. Notepad: `Smith<tab>250` / `Jones<tab>` / `Lee<tab>`.
   Status `3 rows: 3 done.`

## Part 7 - what could not be done
- **2.10 "Ready to play?" with Notepad closed: skipped.** In Easy mode the box cannot appear (finding 5). Playing
  without it would click wherever Notepad used to be, which on this PC is the Windows 365 work desktop.
- **Visual checks not done:** green border colour, grid drawing, the Excel look and the Fonts CHECK marks were not
  judged by eye. No screenshots were taken.
- **A first try with Computer Use did not work.** The recorder takes a click's window from the real mouse pointer and
  only records typing in the active window. Computer Use sends input in the background, so the recording came out
  as 3 clicks on the Windows 365 window and no typing. It was not played or saved. All Part 2-6 results above come
  from the AutoHotkey harness with real input.
- The harness types plain text at SendLevel 0 so that other running AutoHotkey scripts (QuickText) do not react to
  it. Clicks and shortcut keys use SendLevel 1, because the recorder's `~*LButton` hotkeys ignore level-0 AutoHotkey
  input.
