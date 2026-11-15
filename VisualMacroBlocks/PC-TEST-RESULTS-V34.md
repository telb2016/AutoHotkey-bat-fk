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

## Not done (needs a person)
Retest 2 (menu positions), retest 5 (Ready to play? with Notepad closed in Easy mode), Part 1 steps 2-3, Parts 2-7.
