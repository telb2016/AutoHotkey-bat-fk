# V19 item C - "Stop if a window can't take its size" choice

File: `VisualMacroBlocks-makecode-telek-V19-window-scroll.ahk2`. The find blocks below are for the file state
after item B (commit "V19 item B"). Each one occurs exactly once there and also exactly once in the V18 file.
Applying them to the item-B file gives exactly the item-C file (checked with a script).

## 1. Find / replace blocks (in file order)

### Block 1 - in `VMB_BuildGui` (the new checkbox right after `c["Steady"]`)

Find:
```ahk
    c["Steady"] := g.AddCheckbox("x+10 yp", "Steady playback")
```
Replace with:
```ahk
    c["Steady"] := g.AddCheckbox("x+10 yp", "Steady playback")
    c["SizeStop"] := g.AddCheckbox("x+10 yp", "Stop if a window can't take its size")
```

### Block 2 - in `VMB_BuildGui` (events)

Find:
```ahk
    c["Steady"].OnEvent("Click", VMB_OnSettingChanged)
```
Replace with:
```ahk
    c["Steady"].OnEvent("Click", VMB_OnSettingChanged)
    c["SizeStop"].OnEvent("Click", VMB_OnSettingChanged)
```

### Block 3 - in `VMB_SettingsToControls`

Find:
```ahk
    s.Ctl["Steady"].Value := m.Get("steady", 0) ? 1 : 0
```
Replace with:
```ahk
    s.Ctl["Steady"].Value := m.Get("steady", 0) ? 1 : 0
    s.Ctl["SizeStop"].Value := m.Get("sizeMismatch", "") = "stop" ? 1 : 0
```

### Block 4 - in `VMB_ControlsToSettings`

Find:
```ahk
    VM__SetOrDelete(m, "steady", s.Ctl["Steady"].Value ? 1 : "")
```
Replace with:
```ahk
    VM__SetOrDelete(m, "steady", s.Ctl["Steady"].Value ? 1 : "")
    VM__SetOrDelete(m, "sizeMismatch", s.Ctl["SizeStop"].Value ? "stop" : "")
```

### Block 5 - in `V17_NormalizeWindow`

Find:
```ahk
        try exe := WinGetProcessName(id)
        V17_Warn(ctx, "Step #" . ctx.Index . " (" . exe . ") " . msg)
```
Replace with:
```ahk
        try exe := WinGetProcessName(id)
        if ctx.HasOwnProp("Settings") && ctx.Settings.Get("sizeMismatch", "") = "stop"     ; V19: stop instead of a note
            throw Error("The window " . V19_MismatchText(msg) . " Fix the window, then retry this step.")
        V17_Warn(ctx, "Step #" . ctx.Index . " (" . exe . ") " . msg)
```

### Block 6 - new function, at the end of the V19 section (directly above `; V4 STARTUP / SINGLE-FILE PLAYER EXPORT`)

Find:
```ahk
; ============================================================================
; V4 STARTUP / SINGLE-FILE PLAYER EXPORT
```
Replace with:
```ahk
; @summary The "size is off" note without its trailing " Kept going." (for the message when the run stops instead).
; @tags macro, window, normalize, v19
V19_MismatchText(msg) => SubStr(msg, -12) = " Kept going." ? SubStr(msg, 1, -12) : msg

; ============================================================================
; V4 STARTUP / SINGLE-FILE PLAYER EXPORT
```

### Block 7 - in `V4_SelfTest`, right before `player := V4_PlayerSource(source, macro)` (after the item-A and item-B lines)

Find:
```ahk
        player := V4_PlayerSource(source, macro)
```
Replace with:
```ahk
        check("V19 size stop: the note loses 'Kept going.'",
            V19_MismatchText(V17_SizeNote(900, 700, 640, 480, true)), "stayed 640x480 instead of 900x700 (it has a maximum size or does not fit the screen, or the display scaling is different).")
        check("V19 size stop: other text is kept as it is", V19_MismatchText("stayed 1x1."), "stayed 1x1.")
        check("V19 size stop: new macros keep going (off by default)", VMF_NewMacro()["settings"].Get("sizeMismatch", ""), "")
        player := V4_PlayerSource(source, macro)
```

## 2. Full text of each new function

`V19_MismatchText` - exactly as in Block 6 above (one line).

## 3. New self-test lines

The 3 `check("V19 size stop: ...")` lines in Block 7. Self-test now: 222 PASS, 0 FAIL, `Failures: 0`.
The existing "V17 Easy layout shows 26 controls" check still passes (the new checkbox is Full mode only).

## 4. What I could not be sure about

- The new checkbox sits on the same row as "Steady playback" (options `"x+10 yp"` as the plan says). Under Wine
  at 1600 px wide, the end of its text ("...its size") was cut off by the window edge, and the grey info text that
  used to follow "Steady playback" is pushed out of view. Widening the window shows it. On a PC with other fonts or
  scaling it may look different; if it is cut off there, it could move to its own row.
- When the run stops, what happens next is the existing failure handling ("When a step fails": ask / skip / stop).
  With "ask" (the default) the run pauses with Retry / Skip / Stop.
- Tested under Wine, not on Windows.

## 5. Test by hand on a PC

1. In Full mode ("More features ▸"), tick "Stop if a window can't take its size", and save the macro.
2. Edit step #1 (Normalize Window Geometry) to a size the program can't take, for example width 50, height 20.
3. Press Play. The run must stop at step #1 with "The window stayed ... instead of 50x20 (...). Fix the window, then retry this step."
4. Untick the checkbox and press Play again: the run keeps going and the log has the old "... Kept going." note.
5. Close and reopen the macro: the checkbox must show what you saved.

## Test results (Wine 10 on Linux, AutoHotkey 2.0.27)

- `/validate`: exit code 0, no output.
- `--self-test`: 222 PASS, 0 FAIL, `Failures: 0` (Easy layout still 26 controls).
- Brace / duplicate-name check: OK.
- Notepad record + replay: text ends `KEEP MEhello grokbot\nline2`. Old V18 macro: same, 0 notes.
- Macro with step #1 set to 60x60 (Notepad's minimum width is 119):
  - setting missing: note "Step #1 (notepad.exe) stayed 119x60 instead of 60x60 (...). Kept going." and the run finished.
  - `sizeMismatch: "stop"`: the run paused at step #1 with "The window stayed 119x60 instead of 60x60 (it has a
    minimum size, or the display scaling is different). Fix the window, then retry this step." (Try again / Skip / Stop).
- Full mode: the checkbox shows ticked for the "stop" macro; Easy mode hides it. Unticking it and pressing Play
  went back to the "Kept going" note.
