# V19 item B - test the window size while recording, not only at playback

File: `VisualMacroBlocks-makecode-telek-V19-window-scroll.ahk2`. The find blocks below are for the file state
after item A (commit "V19 item A"). Each one occurs exactly once there, and blocks 1-5 also occur exactly once in
the V18 file (block 6 and block 7 are the same lines item A also used). Applying them to the item-A file gives
exactly the item-B file (checked with a script).

## 1. Find / replace blocks (in file order)

### Block 1 - in `V17_RecWin`

Find:
```ahk
    static r := {On: false, Last: 0, Seen: Map(), MacroHwnd: 0, AutoPick: false, AutoTarget: "", AutoGeo: 0}
```
Replace with:
```ahk
    static r := {On: false, Last: 0, Seen: Map(), MacroHwnd: 0, AutoPick: false, AutoTarget: "", AutoGeo: 0, Trial: []}
```

### Block 2 - in `V17_RecWinStart`

Find:
```ahk
    r.Seen := Map(), r.Last := 0, r.MacroHwnd := 0
```
Replace with:
```ahk
    r.Seen := Map(), r.Last := 0, r.MacroHwnd := 0, r.Trial := []
```

### Block 3 - in `V17_RecNoteWindow` (the auto-pick branch)

Find:
```ahk
                r.AutoTarget := target, r.MacroHwnd := hwnd, r.Seen[hwnd] := 1, r.Last := hwnd
                return
```
Replace with:
```ahk
                r.AutoTarget := target, r.MacroHwnd := hwnd, r.Seen[hwnd] := 1, r.Last := hwnd
                r.Trial.Push({Hwnd: hwnd, Node: 0})     ; V19: its Normalize step is made when recording stops
                return
```

### Block 4 - in `V17_RecNoteWindow` (a new window got a Normalize step)

Find:
```ahk
    for node in V17_SwitchSteps(selector, geo)
        V4_RecordAdd(node)
    r.Seen[hwnd] := 1
```
Replace with:
```ahk
    for node in V17_SwitchSteps(selector, geo) {
        V4_RecordAdd(node)
        if node.Get("type", "") = "det_normalize_win"      ; V19: its size is tested when recording stops
            r.Trial.Push({Hwnd: hwnd, Node: node})
    }
    r.Seen[hwnd] := 1
```

### Block 5 - in `V18_FinishRecording`

Find:
```ahk
        norm["target"] := ""
        note := "  Macro window: " . r.AutoTarget . " - step #1 puts it back to " . V17_NormText(norm) . "."
    }
    r.AutoTarget := "", r.AutoGeo := 0, r.AutoPick := false
```
Replace with:
```ahk
        norm["target"] := ""
        for trial in r.Trial                    ; V19: the auto-picked window's Normalize step exists only now
            if trial.Hwnd = r.MacroHwnd && !IsObject(trial.Node)
                trial.Node := norm
        trialNote := V19_RunSizeTrials(r.Trial)    ; first, so the size in the note below is the saved one
        r.Trial := []
        note := "  Macro window: " . r.AutoTarget . " - step #1 puts it back to " . V17_NormText(norm) . "." . trialNote
    }
    note .= V19_RunSizeTrials(r.Trial)          ; V19: windows that got a Normalize step while recording
    r.Trial := []
    r.AutoTarget := "", r.AutoGeo := 0, r.AutoPick := false
```

### Block 6 - new functions, at the end of the V19 section (directly above `; V4 STARTUP / SINGLE-FILE PLAYER EXPORT`)

Find:
```ahk
; ============================================================================
; V4 STARTUP / SINGLE-FILE PLAYER EXPORT
```
Replace with:
```ahk
; @summary Result of a size trial: does the window go back to its recorded size after being made bigger?
; @returns {Holds (back within 1 px of the recorded size), W, H (the size it went back to), CanGrow}
; @tags macro, window, normalize, record, v19
V19_TrialResult(recW, recH, grewW, grewH, backW, backH) {
    return {Holds: Abs(backW - recW) <= 1 && Abs(backH - recH) <= 1, W: backW, H: backH,
        CanGrow: grewW > recW || grewH > recH}
}

; @summary Recording stopped: makes the window 60 px bigger, then puts it back, and reads which size it takes.
;          Always ends by moving the window back to where it was. Any error = {Holds: true} (never blocks the user).
; @returns V19_TrialResult object
; @tags macro, window, normalize, record, v19
V19_SizeTrial(hwnd) {
    id := "ahk_id " . hwnd, res := {Holds: true}, read := false
    try {
        WinGetPos(&wx, &wy, &ww, &wh, id)
        read := true
        WinMove(wx, wy, ww + 60, wh + 60, id)
        V19_WaitSize(id, ww + 60, wh + 60, 0)
        WinGetPos(, , &grewW, &grewH, id)
        WinMove(wx, wy, ww, wh, id)
        V19_WaitSize(id, ww, wh, 0)
        WinGetPos(, , &backW, &backH, id)
        res := V19_TrialResult(ww, wh, grewW, grewH, backW, backH)
    }
    if read
        try WinMove(wx, wy, ww, wh, id)
    return res
}

; @summary Recording stopped: runs the size trial once for each window that got a Normalize step and is still open,
;          resizable and not maximized (not this script's windows). A window that snaps to its own sizes gets the
;          size it settles at saved in its Normalize step.
; @returns a note for the status bar, or ""
; @tags macro, window, normalize, record, v19
V19_RunSizeTrials(trials) {
    snapped := false
    for trial in trials {
        node := trial.Node
        if !IsObject(node) || node.Get("sizeChecked", 0) || V4_Bool(node.Get("maximize", 0))
            continue
        open := false
        try {
            id := "ahk_id " . trial.Hwnd
            if WinExist(id) && !V18_OwnWindow(trial.Hwnd) && WinGetMinMax(id) = 0 && V17_IsResizable(WinGetStyle(id)) {
                WinGetPos(, , &curW, &curH, id)
                open := true
            }
        }
        if !open || Abs(curW - node.Get("width", 0)) > 1 || Abs(curH - node.Get("height", 0)) > 1
            continue        ; closed, fixed-size, maximized - or resized after its step was recorded
        res := V19_SizeTrial(trial.Hwnd)
        node["sizeChecked"] := 1
        if !res.Holds {
            node["width"] := res.W, node["height"] := res.H
            snapped := true
        }
    }
    return snapped ? "  This window only takes certain sizes. Saved the size it settles at." : ""
}

; ============================================================================
; V4 STARTUP / SINGLE-FILE PLAYER EXPORT
```

### Block 7 - in `V4_SelfTest`, right before `player := V4_PlayerSource(source, macro)` (after the item-A lines)

Find:
```ahk
        player := V4_PlayerSource(source, macro)
```
Replace with:
```ahk
        v19T := V19_TrialResult(800, 600, 860, 660, 800, 600)
        check("V19 size trial: a window that goes back holds", v19T.Holds . "|" . v19T.W . "x" . v19T.H . "|" . v19T.CanGrow, "1|800x600|1")
        check("V19 size trial: within 1 px still holds", V19_TrialResult(800, 600, 860, 660, 801, 599).Holds, 1)
        v19T := V19_TrialResult(803, 610, 900, 700, 800, 600)
        check("V19 size trial: a window that snaps does not hold", v19T.Holds . "|" . v19T.W . "x" . v19T.H, "0|800x600")
        check("V19 size trial: a window at its biggest size cannot grow", V19_TrialResult(800, 600, 800, 600, 800, 600).CanGrow, 0)
        check("V19 size trial: a window that is gone never blocks", V19_SizeTrial(0x7FFFFFF0).Holds, 1)
        v19N := Map("type", "det_normalize_win", "width", 800, "height", 600, "maximize", 0)
        check("V19 size trial: a closed window is skipped", V19_RunSizeTrials([{Hwnd: 0x7FFFFFF0, Node: v19N}]) . "|" . v19N.Get("sizeChecked", 0), "|0")
        check("V19 size trial: a maximized step is skipped", V19_RunSizeTrials([{Hwnd: 0, Node: Map("maximize", 1)}]), "")
        check("V19 size trial: an auto-picked window without a step is skipped", V19_RunSizeTrials([{Hwnd: 0, Node: 0}]), "")
        player := V4_PlayerSource(source, macro)
```

## 2. Full text of each new function

`V19_TrialResult`, `V19_SizeTrial` and `V19_RunSizeTrials` - exactly as in Block 6 above.
(`V19_RunSizeTrials` is the loop of plan step 3, put in its own function so `V18_FinishRecording` stays short.)

## 3. New self-test lines

The 8 `check("V19 size trial: ...")` lines in Block 7. Self-test now: 219 PASS, 0 FAIL, `Failures: 0`.

## 4. What I could not be sure about

- I added one guard the plan does not spell out: the trial is skipped when the window's size at Stop is not the
  size its Normalize step saved (the user resized it during recording). Otherwise the trial would test - and might
  save - a size that has nothing to do with the step.
- Windows that got their Normalize step from "📐 Pick window" (before Record) are not tested; the plan only names
  the auto-pick branch and `V17_RecNoteWindow`.
- When a window snaps, only `width` / `height` are changed, not the position.
- A program might react to the trial resize (re-layout, save its window size). The window is always put back.
- Tested under Wine (Notepad and a small test window that snaps to multiples of 100 px), not on Windows.

## 5. Test by hand on a PC

1. Start with an empty macro, press Record, click in Notepad and type `hi`, click the red REC bar to stop.
2. Notepad must grow a little and go back once (about half a second). The status bar must NOT say "only takes certain sizes".
3. Do the same with a program that only takes certain sizes (for example Windows Terminal or a console window).
4. Its status bar note must say "This window only takes certain sizes. Saved the size it settles at."
5. Press Play from another window size: no "stayed ... instead of ..." note in `Documents\VisualMacros\last-playback.log`.

## Test results (Wine 10 on Linux, AutoHotkey 2.0.27)

- `/validate`: exit code 0, no output.
- `--self-test`: 219 PASS, 0 FAIL, `Failures: 0`.
- Brace / duplicate-name check: OK.
- Notepad record + replay: text ends `KEEP MEhello grokbot\nline2`. Notepad's step #1 got `sizeChecked: 1`,
  size unchanged (950x712), no "certain sizes" note.
- Old macro (recorded with the V18 file) played in V19: same result, 0 notes.
- Second window that refuses to get smaller again (a small AutoHotkey test window, 408x334): recorded a click in
  it after Notepad. At Stop it got "Use Window" + Normalize, the trial ran, the status bar said "This window only
  takes certain sizes. Saved the size it settles at.", and its Normalize step was saved as 468x394
  (`sizeChecked: 1`) - the size the window really stayed at.
- Found and fixed while testing: in AutoHotkey v2 a failed `WinGetPos(&x, ...)` leaves `x` unset, so the code
  uses a separate "read" / "open" flag instead of checking `x`.
