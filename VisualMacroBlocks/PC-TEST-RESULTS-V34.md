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

## Still open
- Findings 2 (ControlClick on "Save &as...") and 3 (`notepad?`) above, and the desktop-dependent self-test check.
- Not done yet: Parts 3-7 of WORK-AI-TEST-INSTRUCTIONS.md (Part 2 was covered by retest 1).

## Files created on the PC (all in C:\Temp\vmb)
part1-selftest.ahk, retest-v34.ahk (= pc-tests/retest-v34.ahk), probe-windows.ahk, probe-saveas.ahk, probe-panicexit.ahk,
VMB34.ahk, VMB34-prev.ahk, selftest.txt, selftest-prev.txt, retest-notepad.vmacro.json, retest-v34-results*.md,
retest-v34-log.txt, data\ (ini, autosave draft, last-playback.log). `VMB33.ahk` was already there (not made by this test).
