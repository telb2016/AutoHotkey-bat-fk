# Work plan: Visual Macro Blocks V19 (window + scroll)

Paste this whole document to the bot together with the attached file
`VisualMacroBlocks-makecode-telek-V18-claude-window-specialist.ahk2`.

## 0. Who you are helping and what "done" means

The owner records a task once in a Windows program and replays it many times. He only has a phone
right now, so he cannot debug. Every change must be small, exact, and safe.

Goal of this round: the replay must click the same thing every time even when
(a) the window cannot take the recorded size, and (b) a list or page is scrolled differently than
when it was recorded. Four work items, in this order: A, B, C, D. Finish and deliver one before
starting the next.

The file is one AutoHotkey **v2.0.19** script, about 14,000 lines / 645 KB. No `#Include`, no
libraries, no external tools. Keep it that way.

## 1. Rules (do not break these)

1. Do not rewrite or reformat the file. Deliver each change as **find / replace blocks**: the exact
   existing text to find (must occur once), and the text to put in its place. New functions go in
   one new section placed directly above the line
   `; V4 STARTUP / SINGLE-FILE PLAYER EXPORT` (that line has a `; ====` line above it).
2. New functions use the prefix `V19_`. Put a `; @summary` and `; @tags` comment above each one,
   like the existing code.
3. Old macros must play exactly as before. Anything that changes playback must be controlled by a
   macro setting that old macros do not have, or by a field that only newly recorded steps have.
4. Do not touch picture / image code: `V4_FindImage`, `ImageSearch`, `V18_VerifySpot`,
   `V18_PixelsMatch`, `V18_LocatePatch`, `V18_PreShot*`.
5. The script starts with `#Warn All, StdOut`. Every variable must be assigned before use; a local
   must not share a name with a global function. Do not name a variable `log`, `file`, `index`.
6. User-facing text is plain English, short sentences, no jargon.
7. AutoHotkey v2 syntax only: `:=` for assignment, `Map()` with `m["key"]`, objects with `o.Prop`,
   `try` / `catch as err`, functions called with parentheses.
8. For every pure function you add (no windows, no mouse), add checks to `V4_SelfTest`, right
   before the line `player := V4_PlayerSource(source, macro)`. Use the existing helpers:
   `check("name", actual, expected)` and `rejects("name", () => call())`.
9. If you are not sure a Windows message or API behaves as described here, say so in your answer
   instead of guessing. The owner will test on a real PC later.

How the owner runs the self-test on a PC (must print `Failures: 0`):
`AutoHotkey64.exe yourfile.ahk --self-test C:\temp\report.txt`
The current file has 203 PASS lines. Your version must have more, and no FAIL.

## 2. Map of the file (search for these names)

| Name | What it does |
|---|---|
| `VMB_ToggleRecord`, `VMB_StartRecording`, `VMB_StopRecording` | Record button flow |
| `VM_RecordStart`, `VM_RecordStop` | installs / removes the input hooks |
| `V4_RecordMouse(button, isDown, *)` | called on every mouse press / release while recording |
| `VM_CaptureClickStep(x, y, button, count)` | builds one recorded click step (a `Map`) |
| `V18_WheelStep` | builds one recorded wheel step |
| `V14_CaptureGeo(hwnd, x, y)` | stores the click spot relative to the window + edge anchors |
| `V14_ResolvePoint(src, hwnd)` | turns that back into a screen point at playback |
| `V14_LockWindow(node, hwnd, runner)` | before each click: puts the window back to its recorded size |
| `V17_WindowGeometry(hwnd)` | reads size / spot of a window for a Normalize step |
| `V17_NormalizeWindow(node, hwnd, ctx)` | runs a "Normalize Window Geometry" step |
| `V17_SizeNote(wantW, wantH, actualW, actualH, resizable)` | text of the "size is off" note |
| `V17_Warn(ctx, msg)` | note that does not stop the run (status bar + `last-playback.log`) |
| `V17_RecNoteWindow`, `V17_SwitchSteps`, `V18_FinishRecording` | windows seen while recording |
| `V4_DesktopStep(node, runner)` | plays click / drag / wheel / text / keys steps |
| `V18_Steady(runner)` | true when the macro has setting `steady` = 1 |
| `V18_Window`, `V18_Activate`, `V18_WaitTarget` | wait for / activate the step's window |
| `class V4Runner` | the player; `runner.Settings` is the macro's settings `Map`, `runner.Sleep(ms)` is the Esc-stoppable sleep, `runner.Index` is the step number, `runner.Changed := true` marks the macro as corrected during the run |
| `VMF_NewMacro()` | default settings for a new macro |
| `VMB_SettingsToControls`, `VMB_ControlsToSettings` | checkbox / dropdown <-> macro settings |
| `VMB_BuildGui` | creates the controls; the "Steady playback" checkbox is `c["Steady"]` |
| `V4_Help`, `V17_EasyHelp` | help text |
| `V4_SelfTest` | built-in tests |

A recorded click step looks like this (a `Map`):
`type "click"`, `button`, `count`, `scrX`, `scrY`, `win` (`Map` with `exe`, `cls`, `title`),
`geo` (`Map` with `cx`, `cy`, `cw`, `ch`, `ww`, `wh`, `max`, `ax`, `ay`), `pattern`, `offsetX`,
`offsetY`, `gapMs`, optional `mods`.

## 3. Item A - wait for the size instead of a fixed pause

**Today:** `V17_NormalizeWindow` calls `WinMove`, then `ctx.Sleep(250)`, then reads the size once.
A slow program may still be resizing; a fast one wastes time.

**Change:** add `V19_WaitSize(id, wantW, wantH, ctx, maxMs := 2000)` and use it in place of the
`ctx.Sleep(250)` that follows the `WinMove` (not the ones after maximize / restore).

Behaviour:
- Read `WinGetPos(, , &w, &h, id)` every 50 ms (use `ctx.Sleep(50)` so Esc works).
- Return `"ok"` as soon as the size is within 1 px of the wanted size on two reads in a row.
- Return `"stuck"` when the size has not changed for 300 ms and is not the wanted size
  (the program refused: minimum / maximum size).
- Return `"timeout"` after `maxMs`.
- After it returns, `ctx.Sleep(120)` once so the program can re-draw its controls.
- For a window that is not resizable, only wait until the position stops changing (same loop,
  compare x and y).

Put the stop decision in a pure function so it can be tested:
`V19_SizeVerdict(samples, wantW, wantH)` where `samples` is an array of `[tickMs, w, h]`;
returns `""` (keep waiting), `"ok"` or `"stuck"`. Self-test it with made-up sample lists:
reaches size; never moves; moves then stops short; reaches size on the last sample only.

## 4. Item B - check the size while recording, not only at playback

**Today:** the Normalize step stores whatever size the window has. Nothing checks that the window
can be *put back* to that size from another size.

**Change:** when recording stops, test it once for each window that got a Normalize step and is
still open and resizable and not maximized.

1. In `V17_RecNoteWindow` and in the auto-pick branch, remember each normalized window:
   push `{Hwnd: hwnd, Node: normNode}` onto a new array `r.Trial` in `V17_RecWin()`
   (for the auto-picked Macro window the node does not exist yet; store the hwnd and attach the
   node in `V18_FinishRecording` after `V17_TopNormalize` returns it).
2. New function `V19_SizeTrial(hwnd)`:
   - read position and size (x, y, w, h);
   - `WinMove(x, y, w + 60, h + 60)`, wait with `V19_WaitSize` logic (a plain `Sleep` loop, there
     is no runner here), read size -> `grew`;
   - `WinMove(x, y, w, h)`, wait, read size -> `back`;
   - return `{Holds: back = recorded size (within 1 px), W: backW, H: backH, CanGrow: grew > recorded}`.
   - Wrap everything in `try`; on any error return `{Holds: true}` (never block the user).
   - Always finish by moving the window back to x, y, w, h.
3. In `V18_FinishRecording`, run the trial for each remembered window:
   - `Holds` true -> set `node["sizeChecked"] := 1`.
   - `Holds` false -> the program snaps to its own sizes. Set the node's `width` / `height` to the
     size it actually returned to (`W`, `H`), set `node["sizeChecked"] := 1`, and add to the
     status-bar note: "This window only takes certain sizes. Saved the size it settles at."
4. The trial makes the window flicker once for about half a second. That is acceptable. Do not run
   it for fixed-size dialogs, maximized windows, or windows of this script.

Pure part to self-test: `V19_TrialResult(recW, recH, grewW, grewH, backW, backH)` returning the
object above.

## 5. Item C - "stop if the size is wrong" choice

**Today:** when the size is off by more than 4 px, `V17_NormalizeWindow` only notes it and goes on.

**Change:** new macro setting `sizeMismatch`: missing or `"continue"` = today's behaviour;
`"stop"` = stop the step with the same message.

- In `V17_NormalizeWindow`, where `msg != ""`: if `ctx.Settings.Get("sizeMismatch", "") = "stop"`
  then `throw Error("The window " . msg_without_"Kept going." . " Fix the window, then retry this step.")`.
  The existing failure handling then pauses the run and lets the user retry or skip. Check
  `ctx.HasOwnProp("Settings")` first.
- Add a pure helper `V19_MismatchText(msg)` that strips the trailing " Kept going." and self-test it.
- GUI: add a checkbox `c["SizeStop"]` with the text "Stop if a window can't take its size",
  created right after `c["Steady"]` in `VMB_BuildGui` with the options `"x+10 yp"`. Wire it exactly
  like `c["Steady"]` (search for every line that mentions `"Steady"` and add the matching line):
  in `VMB_SettingsToControls` set `.Value := m.Get("sizeMismatch", "") = "stop" ? 1 : 0`;
  in `VMB_ControlsToSettings` use
  `VM__SetOrDelete(m, "sizeMismatch", s.Ctl["SizeStop"].Value ? "stop" : "")`;
  add `c["SizeStop"].OnEvent("Click", VMB_OnSettingChanged)`.
- Do not turn it on by default.
- The Easy-mode layout test in `V4_SelfTest` counts the controls Easy mode shows (26). The new
  checkbox is Full-mode only, so that number must not change.

## 6. Item D - scroll position (the important one)

### The problem
A click is stored relative to the window. If the list or page inside the window is scrolled
differently at playback, the same spot shows a different row. Window size does not fix this.

### The design: remember the scroll position with each click, put it back before clicking
Standard Windows controls (list boxes, edit boxes, tree views, list views, Delphi / VB / MFC panes,
most classic line-of-business programs) keep their scroll position in a scroll bar that any
program can read with `GetScrollInfo` and move with `WM_VSCROLL` / `WM_HSCROLL`. No pictures, no
text reading, exact numbers.

Programs that draw everything themselves (web browsers, Electron, WPF, Java, anything inside
Citrix or Remote Desktop) do not answer `GetScrollInfo`. For those, nothing is stored and playback
behaves exactly as today. Say this plainly in the help text. Do NOT attempt UI Automation in this
round.

### D1. Read a scroll bar (works across programs)

```ahk
; @summary Scroll bar numbers of a control. bar: 0 = horizontal, 1 = vertical.
; @returns {Min, Max, Page, Pos}, or 0 when the control has no such scroll bar
; @tags macro, scroll, v19
V19_ScrollInfo(hwnd, bar) {
    si := Buffer(28, 0)
    NumPut("UInt", 28, "UInt", 0x17, si)        ; cbSize, SIF_ALL
    if !DllCall("GetScrollInfo", "Ptr", hwnd, "Int", bar, "Ptr", si)
        return 0
    return {Min: NumGet(si, 8, "Int"), Max: NumGet(si, 12, "Int"),
        Page: NumGet(si, 16, "UInt"), Pos: NumGet(si, 20, "Int")}
}
```

A bar "can scroll" when `Max > Min` and `Max - Min + 1 > Page`. Pure helper:
`V19_CanScroll(info)` -> true / false (`info` may be 0). Self-test it.

### D2. Find the scrolling pane under a screen point

`V19_ScrollPane(x, y)`:
- `h := DllCall("WindowFromPoint", "Int64", (y << 32) | (x & 0xFFFFFFFF), "Ptr")`
- Loop at most 8 times: if `V19_CanScroll(V19_ScrollInfo(h, 1))` or the same for bar 0, return `h`.
  Otherwise `h := DllCall("GetAncestor", "Ptr", h, "UInt", 1, "Ptr")` (GA_PARENT); stop when `h`
  is 0 or is the desktop (`DllCall("GetDesktopWindow", "Ptr")`).
- Return 0 when nothing scrolls.
- Never return a window of this script (`V18_OwnWindow(h)`).

### D3. Record it
In `V4_RecordMouse`, in the `isDown` branch right after `step := VM_CaptureClickStep(x, y, button)`,
and in `V18_WheelStep` before returning:

```ahk
scroll := V19_CaptureScroll(x, y)
if scroll is Map
    step["scroll"] := scroll
```

`V19_CaptureScroll(x, y)` returns `""` when `V19_ScrollPane` finds nothing, else a `Map`:
`"cls"` = `WinGetClass("ahk_id " . pane)`, and for each bar that can scroll:
`"v"` / `"h"` = Pos, `"vMax"` / `"hMax"` = Max, `"vPage"` / `"hPage"` = Page.
Wrap in `try`; on error return `""`.

The press is recorded before the program reacts to it, so the numbers are the position the user
saw when he clicked. For a wheel step they are the position before that wheel notch.

### D4. Put it back at playback
In `V4_DesktopStep`, case `"click", "drag"`: after `V14_LockWindow(node, hwnd, runner)` and after
`point` has been worked out, but BEFORE the `if steady` picture check
(`V18_VerifySpot`) - the picture must be compared after the scroll is restored. Add:

```ahk
if steady && node.Get("scroll", "") is Map
    V19_RestoreScroll(node, point, runner)
```

Same call in case `"wheel"` right after its `MouseMove`. Only in steady mode, only when the step
has `scroll`, so old macros are untouched. Skip when the macro setting `restoreScroll` is 0.

`V19_RestoreScroll(node, point, runner)`:
1. `pane := V19_ScrollPane(point.X, point.Y)`. If 0, or its class is not the recorded `cls`:
   `V17_Warn(runner, "Step #" . runner.Index . ": the list that was scrolled when recording was not found at the click spot. Clicked anyway.")` and return false.
2. For bar 1 (keys `v`, `vMax`) and bar 0 (keys `h`, `hMax`), when the step has that key:
   - read current info; if `info.Pos = want`, nothing to do;
   - if `info.Max != recorded Max`: the content has a different length now. Still try, and add to
     the note "(the list is a different length than when it was recorded)";
   - call `V19_ScrollTo(pane, bar, want, runner)`.
3. If any bar could not be set: `V17_Warn(...)` "could not scroll the list back to where it was
   (now at N, recorded M). Clicked anyway." - or, when the macro setting `sizeMismatch` is `"stop"`,
   `throw Error(...)` with the same text so the run pauses. Return false.
4. After a successful change `runner.Sleep(80)` so the pane re-draws before the picture check.

`V19_ScrollTo(pane, bar, want, runner)` - try three ways, reading the position back after each:
```
msg := bar = 1 ? 0x115 : 0x114            ; WM_VSCROLL / WM_HSCROLL
want := clamp(want, info.Min, info.Max - Max(info.Page, 1) + 1)

Way 1 (jump):  if want is between 0 and 65535:
    SendMessage(msg, (want << 16) | 4, 0, pane)     ; SB_THUMBPOSITION
    SendMessage(msg, 8, 0, pane)                    ; SB_ENDSCROLL
    if position = want -> done

Way 2 (step):  loop at most 600 times:
    delta := want - position
    if delta = 0 -> done
    far := info.Page > 1 && Abs(delta) >= info.Page
    code := delta > 0 ? (far ? 3 : 1) : (far ? 2 : 0)  ; SB_PAGEDOWN 3, SB_LINEDOWN 1, SB_PAGEUP 2, SB_LINEUP 0
    SendMessage(msg, code, 0, pane)
    read position; if it did not change -> stop trying
    if the sign of delta flipped twice (stepping over the target) -> stop trying
    every 50 loops: runner.Sleep(1) so Esc works

Way 3: give up, return false (caller notes it).
```
Use `SendMessage(msg, wParam, 0, pane)` with a `try` around it and a timeout
(`SendMessage(msg, wParam, 0, pane, , , , , 500)`); a hung program must not hang the macro.

Put the "what to send next" decision in a pure function so it can be self-tested without a window:
`V19_ScrollStep(pos, want, page, flips)` -> `{Code: 0|1|2|3, Done: bool}`. Test: already there;
one line down; several pages down; several pages up; `want` beyond the end is clamped by
`V19_ClampScroll(want, min, max, page)` (test that too, including `page = 0`).

### D5. When the pane overshoots (line step bigger than 1 unit)
Some panes count in pixels and move 16+ units per line, so Way 2 can end a few units away. If
Way 1 failed and Way 2 ended within one line step of the target, do NOT shift the click point to
compensate (the unit is unknown). Report it as "could not scroll back exactly" (step 3 above).
The existing picture check at the spot will then also flag it.

### D6. Settings, help, visibility
- `VMF_NewMacro()`: add `"restoreScroll", 1`. Read it with `.Get("restoreScroll", 1)`; since the
  feature needs both steady mode and a recorded `scroll` field, old macros are not affected.
- No new checkbox is needed. Mention in `V17_EasyHelp` and `V4_Help`, 2-3 lines:
  "Lists and pages are scrolled back to where they were when you recorded, before each click
  (standard Windows lists and boxes only - not web pages, Citrix or Remote Desktop).
  For those, start each run from the same screen and scroll with the keyboard (Ctrl+Home, PgDn)
  while recording, because key presses replay the same way every time."
- In the tree label for a click that has `scroll`, nothing needs to change.

### D7. What cannot be solved this way (tell the owner, do not hide it)
- Web / Electron / WPF / Java / Citrix / RDP: no scroll numbers. Advice in D6 applies.
- A list whose content changed (more or fewer rows): the scroll position is restored, but the row
  under the spot may be a different record. Only the picture check notices that.
- Tree views that expand / collapse differently: same as above.

## 7. Version text
- Line 1 of the file: change `V18` to `V19` and add a short block under it:
  `; V19 = V18 + window size is waited for and tested at recording, optional stop when a window`
  `;       can't take its size, and standard lists / boxes are scrolled back before each click.`
- Window title: the two places with `"Visual Macro Blocks V18"` in `VMB_BuildGui` and
  `VMB_UpdateTitle` -> `"Visual Macro Blocks V19"`. Leave the ini file name and the autosave file
  name alone.
- Save the result as `VisualMacroBlocks-makecode-telek-V19-window-scroll.ahk2`.

## 8. What to hand back after each item
1. The find / replace blocks, in file order, each with the function name it is in.
2. The full text of each new function.
3. The new self-test lines.
4. A list of anything you could not be sure about (Windows behaviour you assumed).
5. A 5-line test the owner can do by hand on a PC. Suggested for item D: open Notepad, paste 300
   lines, set Word Wrap off, scroll to about line 150, press Record, click on a line, type `X`,
   stop. Scroll to the top. Press Play. The `X` must land on the same line, and
   `Documents\VisualMacros\last-playback.log` must contain no "could not scroll" note.

## 9. Known facts about this file that will save you time
- Every "Normalize Window Geometry" step used to also clear the focused field and press Tab. That
  is already fixed in this file (`case "det_citrix_fill":` in `V10_DetExecute`). Do not undo it.
- Enter / Tab / Esc used to be recorded twice. Already fixed in `V4_RecordChar`. Do not undo it.
- `V17_Warn(ctx, msg)` is safe to call with any runner; it never throws.
- `VM__SetOrDelete(map, key, value)` deletes the key when value is `""`.
- `VF_Clamp(n, lo, hi)` exists.
- Coordinates are screen coordinates everywhere at playback (`CoordMode("Mouse", "Screen")`).
