# V34 PC retest results (automated driver)

- Date: 2026-11-15
- Windows: 10.0.26200 (Windows 11)
- AutoHotkey: 2.0.19 64-bit (`pharmacy-informatics-CLE-testing\AutoHotkey\v2\AutoHotkey64.exe`)
- Screen: 3840x2160, DPI 96 (100 %)
- Notepad: classic Notepad (`Edit` control)
- Driver: `pc-tests/retest-v34.ahk` (separate AHK process, `SendLevel 1`, `SendEvent`); program started with
  `--data C:\Temp\vmb\data`, so `Documents\VisualMacros` was not touched. All files stayed in `C:\Temp\vmb\`.
- Scope: Part 1 step 1 and retest items 1, 3, 4, 6. Retest items 2 and 5 and Parts 1.2-7 need a person and are NOT done yet.

## Part 1 step 1 - self-test
- `Failures: 0`, 999 PASS lines, exit 0, 12.8 s.
- Only non-PASS lines are the 3 header lines (`Visual Macro Blocks V18 self-test`, `AutoHotkey 2.0.19 | pointer size 8`, `Failures: 0`).
- `Downloads\vmb-selftest` was gone afterwards.

## Retest 1 - record once, replay 10 times: PASS (10 of 10)

Steps grid after recording:

| # | Program | Window | Action | On what | Text / keys | Clicks | Waits first |
|---|---|---|---|---|---|---|---|
| 1 | notepad | – | Window | – | – | – | 0 |
| 2 | notepad | main window | Click | a text box | – | 1 | 300 ms |
| 3 | notepad | main window | Type | – | "hello" | – | 547 ms |
| 4 | notepad | main window | Press | – | Enter (OK / submit / new line) | – | 437 ms |
| 5 | notepad | main window | Type | – | "world" | – | 454 ms |
| 6 | notepad | main window | Double-click | a text box | – | 2 | 1.5 s |
| 7 | notepad | main window | Type | – | "X" | – | 594 ms |

- Enter appears once; one Double-click row. Notepad text after recording: `X\nworld`.
- Before every play the driver cleared Notepad and moved/resized it (4 different spots).

| Play | Identical | Seconds | Notepad back at recorded spot/size | Notepad text | Status bar |
|---|---|---|---|---|---|
| 1 | yes | 5.00 | yes | `X\nworld` | Finished. |
| 2 | yes | 4.91 | yes | `X\nworld` | Finished. |
| 3 | yes | 5.03 | yes | `X\nworld` | Finished. |
| 4 | yes | 5.01 | yes | `X\nworld` | Finished. |
| 5 | yes | 5.05 | yes | `X\nworld` | Finished. |
| 6 | yes | 4.91 | yes | `X\nworld` | Finished. |
| 7 | yes | 4.92 | yes | `X\nworld` | Finished. |
| 8 | yes | 4.95 | yes | `X\nworld` | Finished. |
| 9 | yes | 4.97 | yes | `X\nworld` | Finished. |
| 10 | yes | 4.97 | yes | `X\nworld` | Finished. |

Average 4.97 s per play (measured from Play click until the run bar closed). Two later runs (1 play each) also matched.
Note: the other AutoHotkey scripts on this PC (including Telek-QuickText) were running during the test.

## Retest 3 - Maximize / Restore / Minimize / Close naming: PASS (4 of 4)
Driver clicked the real buttons (spots from `DWMWA_CAPTION_BUTTON_BOUNDS`); after Maximize the Restore button is at the
screen's top-right, so "the same spot" was taken as "the same button".

| # | Program | Window | Action | On what |
|---|---|---|---|---|
| 1 | notepad? | – | Window | – |
| 2 | notepad? | main window | Click | the Maximize button |
| 3 | notepad? | main window | Click | the Restore button |
| 4 | notepad? | main window | Click | the Minimize button |
| 5 | notepad? | main window | Click | the Close button (X) |

Observation: Program shows `notepad?` here (with `?`), but `notepad` in retest 1. Here Notepad was closed by the last
recorded click before recording stopped - maybe the `?` means "program not running now". Please confirm it is intended.

## Retest 4 - fast typing + Enter in a cell: PASS (5 of 5, 5 of 5)
Method: double-click the cell, then `there{Enter}` (or `2{Enter}`) sent as one burst with `SetKeyDelay -1, -1`.

| Try | Cell | Cell after Enter | After Ctrl+Z |
|---|---|---|---|
| 1-5 | Text / keys, row 5 (Type "world") | `"there"` (all 5) | `"world"` (all 5) |
| 1-5 | Waits first, row 3 (Type "hello") | `2 s*` (all 5) | `547 ms` (all 5) |

## Retest 6 - unsaved changes after X + ending the script: PASS (with Auto-save off)
- First try: FAIL as written, because **Auto-save** (on by default, hidden in Easy mode) saved the edit straight into the
  file 1.5 s later (title `retest-notepad.vmacro.json (saved 14:22:02)`, no `*`). After restart: no `*`, status
  `Opened C:\Temp\vmb\retest-notepad.vmacro.json`, but the edit WAS kept (in the file). Nothing lost.
- Second try with Auto-save unticked:
  - after the edit: title `Visual Macro Blocks V34 Easy - retest-notepad.vmacro.json * - 7 steps`
  - X button: editor hidden, no question box
  - after restart: title `Visual Macro Blocks V34 Easy - retest-notepad.vmacro.json * - 7 steps`; status bar
    `Restored your unsaved changes to C:\Temp\vmb\retest-notepad.vmacro.json from the autosave draft (the title shows *). Save to keep them.`;
    Text cell `"there6"`.
- Suggestion: the test instructions should say "Auto-save off" (or expect "(saved hh:mm:ss)" when it is on).

## Findings for the developer
1. **Ctrl+Shift+X did not end the script** in both retest-6 runs (sent ~2.5 s after closing the editor with X, Notepad open,
   tray notice just shown): process still alive after 10 s, the driver killed it. A separate probe (no Notepad, no macro)
   ended in 0.7 s (editor shown) and 0.5 s (after X). Not explained; please check `VMB_PanicExit` / `VMB_OnExit` (e.g.
   `V29_SaveCols`, `V4_Disconnect`) with a macro loaded and the HUD / TrayTip just shown.
2. **ControlClick does not fire "Save &as..."** from another process (nothing happens); `&New`, `&Record`, `&Play`
   worked with ControlClick. `PostMessage BM_CLICK` and Alt+A both open the dialog. Possibly an overlapping control in the
   Easy layout over that button. Harmless for people, but worth a look.
3. Retest 3 `notepad?` program name (see above).

# V34.1 retest (commit beb182cb), 2026-11-16 - automated driver, same PC

## Self-test (V34.1)
- 998 PASS, `Failures: 1`, twice: `FAIL | V20 nothing known under a point of this script's own window`
  (`V20_CaptureWhat(-32000, -32000)` must be "").
- The previous version (4ab7a8c6, `Failures: 0` yesterday) also fails this check today, so it depends on the desktop
  (minimized windows are parked at -32000,-32000), not on the V34.1 change. Please make the check independent of the desktop.

## Retest V34.1 - emergency exit: PASS (7 of 7 under 1 s)
Auto-save off. Each try: start, edit a Text cell (title shows `*`), close with X, wait 2.5 s, Ctrl+Shift+X.

| Try | Situation | Seconds until process gone | Ctrl/Shift stuck after |
|---|---|---|---|
| 1 | edited cell, closed with X | 0.24 | no |
| 2 | edited cell, closed with X | 0.13 | no |
| 3 | edited cell, closed with X | 0.11 | no |
| 4 | edited cell, closed with X | 0.13 | no |
| 5 | edited cell, closed with X | 0.16 | no |
| P | while playing (run bar shown) | 0.11 | no |
| R | while recording | 0.11 | no |

REC bar left on screen afterwards: no. Finding 1 above is fixed.

## Retest 2 - menu positions: PASS (2 of 2)
- Editor at 520,380 (not top-left).
- Right-click on the **Action** title at 1431,611: column menu at 1431,611 (202x609) - under the mouse.
- **?** button at 1186,418 (30x30), mouse parked far away at 3640,1860: menu at 1186,448 (180x50) - just under the button.
  (A first run reported FAIL only because the driver had not closed the column menu yet; fixed in the driver, rerun PASS.)

## Retest 5 - "Ready to play?" with Notepad closed, Easy mode: PASS
- Recorded in Easy mode: Window / Click "a text box" / Type "test" (program `notepad`). Notepad closed, Play pressed.
- Box "Ready to play?": `• notepad is not open - step 2 uses it.` / `Yes = play anyway, No = stop so I can fix it.`
- Answered No. Status bar: `notepad is not open - step 2 uses it.`

## Part 1 step 2-3 - start-up and Check this PC
- No error or warning box at any start (about 12 starts across the runs).
- Check this PC (copied text):

```text
Check this PC (V26) - AutoHotkey 2.0.19 - Windows 10.0.26200
PASS | Scroll (list box): read line 150, scrolled to the top, restored, back at line 150.
PASS | Scroll (text box): read line 150, scrolled to the top, restored, back at line 150.
PASS | Close: the test list window this check opened is closed.
PASS | Size: Notepad took a bigger size and went back to the original size.
PASS | Close: the Notepad this check opened is closed.
CHECK | Fonts: ⚠ ⚡ ✎ is not the same width as 0 (7 px) in the list font - the Marks column may not line up. Use plain marks (PlainMarks=1). ↕=7  ≈=7  ►=7  ◇=8  ⚠=12  ⚡=12  ✎=9.
PASS | Indent: char 7.0 px, asked 21 px, got 21 px, 3 characters.
PASS | Screen: 3840 x 2160, scaling 100 %.
PASS | Folder: can write to C:\Temp\vmb\data (run history works).
1 line(s) to CHECK.
```
(Fonts CHECK is the known one.)

## Part 3 - scroll position: PASS
- Classic Notepad, Word Wrap off, 300 lines pasted, scrolled so line 150 is at the top.
- Recorded: Window / Click "a text box" / Type "X". **Scroll back** cell of the Click row: `row 150`.
- X typed on line 154 when recording. Undo X, scroll Notepad to the top (line 1), Play: Notepad scrolled back to line 150
  and X landed on line 154 again. Status `Finished.`

## Part 4 - what the grid knows about a click: PASS

| Clicked | Action | On what | Window |
|---|---|---|---|
| Edit menu | Click | menu "Edit" | main window |
| Go To... | Click | menu item "Go To..." | menu |
| Cancel (Go To Line box) | Click | the "Cancel" button | dialog |
| Maximize | Click | the Maximize button | main window |
| Restore | Click | the Restore button | main window |

## Part 5 - the grid as a spreadsheet: 13 PASS, 1 FAIL, 1 finding, 1 PASS with a note
Setup: the Part 2 macro re-recorded and saved as `C:\Temp\vmb\part5-notepad.vmacro.json`; editor at 200,150.

| # | Check | Result | What happened |
|---|---|---|---|
| 1 | Zoom | PASS | 100% -> Ctrl+wheel up x2 120% -> wheel down 110% -> Ctrl+0 100% |
| 2 | Cell cursor + arrows | PASS | Name box: `Text / keys · step 3` -> Right `Button · step 3` -> Down `Button · step 4`. Green border colour not checked (needs eyes). |
| 3 | Waits first = 2 | PASS | `2 s*`; Ctrl+Z back to `531 ms` |
| 4 | Text world -> there, Play | PASS | cell `"there"`, Notepad `X\nthere`, `Finished.`, Ctrl+Z back to `"world"` |
| 5 | Clicks drop-down = 2 | PASS | Action became `Double-click`; Ctrl+Z back to `Click` |
| 6 | Sort by Action / Step order | PASS | Click, Double-click, Press, Type, Type, Type, Window; Step order -> # 1..7 |
| 7 | Filter `type` / Clear | PASS | only the 3 Type rows; Clear -> 7 rows |
| 8 | Header filter arrow | **FAIL** | A left click 7 px inside the right edge of the **Action** title (frozen pane) and of the **On what** title (main grid) opened no tick list (watched 1.5 s for any new window). Status stayed `Grid view: all 7 steps, in step order.` The arrow zone is the right 18 px (`V32_HitArrow`). Sorting with a click near the left of the title works. Please check by hand; the Action column now lives in the frozen pane, and `V32_HeaderHit` measures `s.GridLV`'s header. |
| 9 | Find | PASS | Ctrl+F `world` Enter -> `Find: match 1 of 1 - row 5, Text / keys.` |
| 10 | Alt+Down / Ctrl+Z | PASS | hello row 3 -> 4, back to 3 |
| 11 | Range + Delete | **finding** | Shift+Down x2 on Waits first -> status `3 cells   Ctrl+C copies, Ctrl+V pastes, Ctrl+D fills down, Delete clears.` Delete -> `Cleared 0 cells.`; the recorded waits (300 ms / 531 ms / 453 ms) stay. Recorded gaps are not clearable (`V31_Clearable` / `V31_ClearKey`), only hand-set waits. If intended, the status could say why (e.g. "recorded waits cannot be cleared"). |
| 12 | Row right-click menu | PASS | Insert step above / Insert step below / Duplicate row / Delete row / Move up / Move down / Turn off / on / More step actions... |
| 13 | Header right-click menu | PASS | all 25 column names + Freeze # and Action + Reset columns |
| 14 | Sideways scroll | PASS | main grid scrolled (its # column at x=-1174); frozen pane stays at the grid's left (w=140) showing `1 / Window` |
| 15 | List, then Grid | PASS | 7 grid rows = 7 tree items = 7 rows back in Grid |
| 16 | Restart (X, Ctrl+Shift+X, start with --data) | PASS with a note | zoom 110% kept, widths kept (44 242 121 132 121 110 220 242), same macro and same cells except **Last run**: `ok` -> `not run yet` on all 7 rows, although the run history file `data\history\part5-notepad.vmacro-*.runs.csv` exists. Intended? |

## Part 6 - repeat for a list: PASS
- Recorded: Window / Click / Type "Smith" / Press Tab / Type "250" / Press Enter.
- Paste list (Name, Amount; Smith 250, Jones 75, Lee 5) -> question
  `Step 3 types "Smith", which is row 1 of column Name. Use the Name column there? (The same for 1 more step.)` -> Yes.
  Status `2 Type steps now use a list column. Ctrl+Z on the Steps sheet puts the text back.`
- Text cells: `=Name → "Smith"`, `=Amount → "250"`.
- Run: `for each row of the List (3 rows)` -> Notepad `Smith\t250\nJones\t75\nLee\t5\n`; status `3 rows: 3 done.`;
  List sheet Result column `done` / `done` / `done`.
- Only when `Amount > 100` on the =Amount row -> Notepad `Smith\t250\nJones\t\nLee\t\n` (amount only on the Smith line); `3 rows: 3 done.`

## Part 7 - what could not be done
- Colour checks (Part 5.2 green border; any drawing glitches) - the driver reads controls, not colours. No screenshots were taken.
- Part 5.8 header filter arrow - see above; needs one try by hand.
- Part 3 on the Windows 11 tabbed Notepad - this PC uses classic Notepad.
- Method note: all clicks/keys came from a second AutoHotkey process (SendLevel 1); buttons were pressed with BM_CLICK.

## Still open
- Part 5.8 (header filter arrow), Part 5.11 (Delete on recorded waits), Part 5.16 (Last run after restart).
- Findings 2 (ControlClick on "Save &as...") and 3 (`notepad?`) above, and the desktop-dependent self-test check.

## Files created on the PC (all in C:\Temp\vmb)
part1-selftest.ahk, retest-v34.ahk (= pc-tests/retest-v34.ahk), probe-windows.ahk, probe-saveas.ahk, probe-panicexit.ahk,
VMB34.ahk, VMB34-prev.ahk, selftest.txt, selftest-prev.txt, retest-notepad.vmacro.json, part5-notepad.vmacro.json, retest-v34-results*.md,
retest-v34-log.txt, data\ (ini, autosave draft, last-playback.log). `VMB33.ahk` was already there (not made by this test).
