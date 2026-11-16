# V34 notes - fixes from the first PC test (V33 -> V34)

File: `VisualMacroBlocks-makecode-telek-V34-pcfixes.ahk2` (all new code is in the `V34 ... END` section above "V4 STARTUP"; helpers are `V34_*`).
Wine self-test: Failures 0, 999 PASS (V33 had 951). Everything marked "PC" could not be proven under Wine.

## Safety (finding 1 rule)
No self-test or harness check touches a drive other than C:. Grep `"[A-BD-Z]:\` in the V34 file: only 2 lines match
(V25 runs-path tests, `X:\m\order.vmacro.json` / `X:\a\x.json`). They are pure string hashing passed to `V25_RunsPath`; nothing is created or tested on disk
(the history folder given is `C:\h` and is not touched).

## Finding 3 - replay not identical
- Cause: not proven. Wine plays the macro 10 of 10 times correctly with the V33 code too, so the loss is timing / environment on the PC.
  Facts from the report: Enter came 0 ms after a Type step; with the Enter lost, "hello" and "world" are one word, so the double-click
  selecting a word still gives `X` (play 2 was probably NOT a lost double-click, only the lost Enter; the picture note on step 6 follows
  from the changed text). Suspects: the target program had not yet taken the typed text in (`SendText` returns when the keys are queued),
  and a second AutoHotkey script on that PC (QuickText) that hooks the keyboard and can swallow an Enter that follows typed text.
  State carried between runs: nothing found (runner is new per play; `VM_ReleaseStuckModifiers` only releases keys the logical state holds
  but the keyboard does not; the picture cache only holds decoded pictures).
- Fix (Steady macros only; old macros untouched): a floor of `minStepMs` (default 120, 0 = off) between consecutive keys / text / click /
  drag / wheel steps even when the recorded or hand-set wait is smaller (`V4Runner.V34Settle`, `V34_FloorMs`, `V34_FloorWait`);
  after text and keys steps wait until the focused window answers WM_NULL (500 ms cap, `V34_WaitIdle`); keys steps use at least 30 ms
  delay / 30 ms press (`V34_KeyDelays`); a click with count 2+ is sent as explicit down / hold / up / gap / down presses at the same spot,
  press-to-press time under half the system double-click time (`V34_DblPlan`, `V34_MultiClick`).
- Tested: self-test checks for the pure functions; Wine harness (Notepad, Click / hello / Enter(0 ms) / world / Double-click / X, 10 plays):
  V33 10 of 10, 3.71 s per play; V34 10 of 10, 4.13 s per play (about 0.42 s, 11 %, more for this 6-step macro). Not reproduced under Wine, so
  the benefit is untested.
- PC: ten replays of the same macro; report n of 10 and status text of any difference. If an Enter is still lost, raise `minStepMs` in the
  macro's settings (e.g. 300) and check whether another script is hooking the keyboard.

## Finding 2 (and 8) - header right-click menu
- Cause: ContextMenu x, y are client coordinates of the GUI; `V29_OnHeader` compares with screen rectangles, `V29_ColMenu` shows at "Screen" coordinates.
- Fix: `V27_OnMenu` / `V29_OnGuiMenu` convert with `V34_EventToScreen` (ClientToScreen) first. Other menus (row, cell, text, tree, list, values) call
  `Menu.Show()` with no position (mouse pointer) and use the hit test from `GetCursorPos`, so they were not affected. The "?" menu now opens under its button (`V34_ShowUnder`).
- Tested: Wine harness with the editor at 200,150: old test with raw client coordinates = false, converted = true. Pure helpers in the self-test.
  Not testable under Wine: the menu itself (Menu.Show blocks).

## Finding 5 - Ready to play?
- Cause: gate also required the Steady setting, which Easy mode hides. Fix: `V34_PreflightGate(onlySelected, startMode, preflightOn)`. Self-tested as a pure function. PC: Easy mode, Notepad closed, Play.

## Finding 6 - Enter loses the last characters
- Cause (likely): a hotkey's message is queued ahead of keyboard messages still waiting, so Enter read the edit box before its last keys arrived.
  Not reproduced under Wine (10 of 10 before and after).
- Fix: Enter / NumpadEnter / Tab / Shift+Tab in the Steps, List and Values cell editors call `V34_Later(...)`, which runs the work from a 1 ms timer (after queued key
  messages), only if the editor still has the focus. PC: fast typing + Enter, 5 tries.

## Finding 4 - caption button names
- Cause: WM_NCHITTEST on Windows 11 often says HTCAPTION for DWM-drawn buttons (and wrong codes when maximized); the y part of lParam was also not masked to 16 bits (fixed).
- Fix: when the hit is title bar / Minimize / Maximize / Close and the point lies in the `DWMWA_CAPTION_BUTTON_BOUNDS` (5) strip, the strip is split in thirds:
  Minimize / Maximize or Restore (window maximized) / Close (`V34_CaptionPart`, `V34_CaptionFallback`). A window with neither min nor max box has only Close.
  "Restore button" is a new name. Cannot be verified under Wine (no DWM): PC test needed.

## Finding 7 - closing with unsaved changes
- What happens: the X button (and WinClose) only hides the editor to the tray (HUD), after an autosave of the draft; nothing is lost, so no question is asked
  (a tray notice says so once). Tray "Quit Completely" asks to save. Ctrl+Shift+X exits at once (unchanged).
- What was wrong: after the script was ended another way and restarted, start-up opened the last saved file and ignored the newer autosave draft, so the
  unsaved edits vanished and the title had no `*`.
- Fix: the draft remembers its file (ini V34 / DraftFor); at start `V34_MaybeRestoreDraft` loads the draft over that file when it is newer and different
  (`V34_UseDraft`), marks the macro unsaved and says so in the status bar. Tested under Wine with a file + newer draft: text restored, title `*`, status message.
- PC: change a cell, close with X, end the script, start again.

## Other
Title bars and help say V34. WORK-AI-TEST-INSTRUCTIONS.md has a "Retest after V34" list. Setting `minStepMs` has no editor control (edit the macro JSON).

## V34.2 - PC test round 2 (made and tested on the Windows PC)
- **Header filter arrow (Part 5.8).** The mark (▼) is drawn right after the title (`V33_OnWmNotify`, left + 6), but
  `V32_HitArrow` only accepted the right 18 px, whose last pixels are the column divider (a resize, no click). Now
  `V34_ArrowHit` also accepts from the drawn mark (`V34_HeadMarkX`) to the right edge; the title text still sorts.
  The frozen pane had plain titles and no ColClick handler, so the Action arrow there did nothing: it now copies the grid's titles
  (`V34_FreezeTitles`) and forwards clicks (`V34_OnFreezeColClick` -> `V27_OnColClick(..., hitLv, hitIdx)`; `V32_HeaderHit`,
  `V32_HeaderClick`, `V32_OpenPopup` take the list / index that was clicked).
- **Delete on recorded waits (5.11).** Only a typed wait (`delayMs`) can be cleared; a recorded pause (`gapMs`) stays. Behaviour kept,
  the status now says so (`V34_EmptyNote`, `V28_DeleteCell`).
- **Last run after a restart (5.16).** Opening a macro reset Last run to "not run yet". `V34_LastRunFromHistory` (called from
  `VMB_SetMacro`) takes the newest history run when its step count matches (`V34_LastRunState`): `ok`, or a note on the steps that had
  one / where it failed.
- **Self-test** `V20 nothing known ...` used -32000,-32000, where Windows parks minimized windows; now a point far outside the virtual screen.
- `notepad?` in the Program column is by design (`V24_MarkApps`: program not running).
- Verified on the PC: self-test 1004 PASS / 0 failures; driver Part 5 16 of 16; regression retest 1, 2 and V34.1 exit all pass.
