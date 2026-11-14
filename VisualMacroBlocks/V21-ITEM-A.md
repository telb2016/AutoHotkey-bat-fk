# V21 item A - say the program only when it changes

File: `VisualMacroBlocks-makecode-telek-V21-step-list.ahk2` (made as a copy of
`VisualMacroBlocks-makecode-telek-V20-window-scroll-step-lines.ahk2`; the V20 file is not changed).
Every find block below occurs exactly once in the V20 file and exactly once when it is applied (checked with a
script that applies these blocks to the V20 file and compares the result with the V21 file after item A: identical).

## 1. Find / replace blocks (in file order)

### Block 1 - in `VMB()` (the editor state: the new `AppShow` entry)

Find:
```ahk
        Easy: 1, FullPos: 0, PinHwnd: 0, Lbl: Map(), RecWasEmpty: false}
```
Replace with:
```ahk
        Easy: 1, FullPos: 0, PinHwnd: 0, Lbl: Map(), RecWasEmpty: false, AppShow: 0}
```

### Block 2 - in `VMB_Refresh` (fill the map before any row is made)

Find:
```ahk
    for i, step in VMF_Flatten(s.Macro["blocks"])
        s.FlatIndex[step] := i
    tv.Opt("-Redraw")
```
Replace with:
```ahk
    for i, step in VMF_Flatten(s.Macro["blocks"])
        s.FlatIndex[step] := i
    s.AppShow := V21_AppRuns(VMF_Flatten(s.Macro["blocks"]))     ; V21: say the program only when it changes
    tv.Opt("-Redraw")
```

### Block 3 - in `V13_InspCommit` (the inspector re-labels one row)

Find:
```ahk
        s.TV.Modify(s.NodeItem[owner], , VMB_NodeLabel(owner))
```
Replace with:
```ahk
        s.AppShow := V21_AppRuns(VMF_Flatten(s.Macro["blocks"]))     ; V21: keep the "in <program>" marks up to date
        s.TV.Modify(s.NodeItem[owner], , VMB_NodeLabel(owner))
```

### Block 4 - `V20_InApp` (optional second parameter)

Find:
```ahk
; @summary "in notepad" for a step with a recorded window ("" when unknown).
; @tags macro, explain, v20
V20_InApp(node) {
    win := node.Get("win", "")
    if !(win is Map) || win.Get("exe", "") = ""
        return ""
    return " in " . V20_AppName(win["exe"])
}
```
Replace with:
```ahk
; @summary "in notepad" for a step with a recorded window ("" when unknown). show: true = " in notepad",
;          2 = " → in notepad" (V21: the program changed here), false = "" (V21: same program as the step before).
; @tags macro, explain, v20
V20_InApp(node, show := true) {
    win := node.Get("win", "")
    if !show || !(win is Map) || win.Get("exe", "") = ""
        return ""
    return (show = 2 ? " → in " : " in ") . V20_AppName(win["exe"])
}
```

### Block 5 - in `V20_StepSentence` (drag)

Find:
```ahk
                return held . (btn = "Left" ? "Drag" : btn . "-drag") . (what != "" ? " " . what : "") . V20_InApp(node)
```
Replace with:
```ahk
                return held . (btn = "Left" ? "Drag" : btn . "-drag") . (what != "" ? " " . what : "") . V20_InApp(node, V21_ShowApp(node))
```

### Block 6 - in `V20_StepSentence` (click)

Find:
```ahk
            return verb . (what != "" ? " " . what : "") . V20_InApp(node) . V20_WhereText(node)
```
Replace with:
```ahk
            return verb . (what != "" ? " " . what : "") . V20_InApp(node, V21_ShowApp(node)) . V20_WhereText(node)
```

### Block 7 - in `V20_StepSentence` (wheel)

Find:
```ahk
                . (n = 1 ? " notch" : " notches") . V20_InApp(node)
```
Replace with:
```ahk
                . (n = 1 ? " notch" : " notches") . V20_InApp(node, V21_ShowApp(node))
```

### Block 8 - in `V20_StepSentence` (text)

Find:
```ahk
            return 'Type "' . V20_Short(text) . '"' . (InStr(text, "{{") ? "  (the {{...}} part is filled in each round)" : "") . V20_InApp(node)
```
Replace with:
```ahk
            return 'Type "' . V20_Short(text) . '"' . (InStr(text, "{{") ? "  (the {{...}} part is filled in each round)" : "") . V20_InApp(node, V21_ShowApp(node))
```

### Block 9 - in `V20_StepSentence` (keys)

Find:
```ahk
            return "Press " . V20_KeysText(node.Get("keys", "")) . V20_InApp(node)
```
Replace with:
```ahk
            return "Press " . V20_KeysText(node.Get("keys", "")) . V20_InApp(node, V21_ShowApp(node))
```

### Block 10 - new section directly above `; V4 STARTUP / SINGLE-FILE PLAYER EXPORT`

Find:
```ahk
; ============================================================================
; V4 STARTUP / SINGLE-FILE PLAYER EXPORT
```
Replace with:
```ahk
; ============================================================================
; V21 STEP LIST
; The macro list reads at a glance: the program is named only where it changes, every kind of step and block gets a
; plain sentence, and the steps that had a note in the last run are marked. Nothing here is saved to the macro file.
; ============================================================================

; @summary Which steps should name their program in the macro list. flatSteps = VMF_Flatten(blocks), in order.
; @returns Map step -> 1 (the first step with a program: show " in notepad"), 2 (the program differs from the step
;          before that had one: show " → in notepad") or 0 (same program: do not show it). Steps without a recorded
;          window (no "win" / no "exe") get no entry and do not break a run.
; @tags macro, explain, gui, v21
V21_AppRuns(flatSteps) {
    out := Map(), lastExe := ""
    for step in flatSteps {
        if !(step is Map)
            continue
        win := step.Get("win", "")
        if !(win is Map) || win.Get("exe", "") = ""
            continue
        exe := win["exe"]
        out[step] := lastExe = "" ? 1 : exe != lastExe ? 2 : 0       ; != ignores upper / lower case
        lastExe := exe
    }
    return out
}

; @summary How V20_InApp should name this step's program: the editor's AppShow entry (0, 1 or 2), or true when there
;          is no editor map or no entry (so a loose step, for example in the self-test, always names its program).
; @tags macro, explain, gui, v21
V21_ShowApp(node) {
    appShow := VMB().AppShow
    return appShow is Map ? appShow.Get(node, true) : true
}

; ============================================================================
; V4 STARTUP / SINGLE-FILE PLAYER EXPORT
```

### Block 11 - in `V4_SelfTest` (new checks right before `player := V4_PlayerSource(source, macro)`)

Find:
```ahk
        player := V4_PlayerSource(source, macro)
```
Replace with:
```ahk
        v21A := Map("exe", "notepad.exe"), v21B := Map("exe", "calc.exe")
        v21S := [Map("type", "click", "win", v21A), Map("type", "text", "win", Map("exe", "NOTEPAD.EXE")), Map("type", "keys", "win", v21A)]
        v21R := V21_AppRuns(v21S)
        check("V21 same program all through: named once", v21R[v21S[1]] . v21R[v21S[2]] . v21R[v21S[3]], "100")
        v21S := [Map("type", "click", "win", v21A), Map("type", "keys", "win", v21A), Map("type", "click", "win", v21B),
            Map("type", "text", "win", v21B), Map("type", "keys", "win", v21A)]
        v21R := V21_AppRuns(v21S)
        check("V21 A A B B A: named where it changes", v21R[v21S[1]] . v21R[v21S[2]] . v21R[v21S[3]] . v21R[v21S[4]] . v21R[v21S[5]], "10202")
        v21S := [Map("type", "click", "win", v21A), Map("type", "delay", "ms", 500), Map("type", "det_normalize_win"),
            Map("type", "keys", "win", v21A), Map("type", "click", "win", Map("exe", "")), Map("type", "text", "win", v21B)]
        v21R := V21_AppRuns(v21S)
        check("V21 steps without a window do not break a run", v21R.Get(v21S[1], "-") . v21R.Get(v21S[2], "-") . v21R.Get(v21S[3], "-")
            . v21R.Get(v21S[4], "-") . v21R.Get(v21S[5], "-") . v21R.Get(v21S[6], "-"), "1--0-2")
        check("V21 empty list", V21_AppRuns([]).Count, 0)
        check("V21 a loose step names its program", V21_ShowApp(Map("type", "click")), true)
        check("V21 program shown / changed / hidden", V20_InApp(Map("win", v21A)) . "|" . V20_InApp(Map("win", v21B), 2) . "|" . V20_InApp(Map("win", v21A), 0),
            " in notepad| → in calc|")
        v21S := [Map("type", "keys", "keys", "{Enter}", "win", v21A), Map("type", "keys", "keys", "{Tab}", "win", v21A),
            Map("type", "text", "text", "5", "win", v21B)]
        VMB().AppShow := V21_AppRuns(v21S)
        check("V21 step lines with the editor map", V20_StepLine(v21S[1]) . "|" . V20_StepLine(v21S[2]) . "|" . V20_StepLine(v21S[3]),
            'Press Enter (OK / submit / new line) in notepad|Press Tab (next field)|Type "5" → in calc')
        VMB().AppShow := 0
        player := V4_PlayerSource(source, macro)
```

## 2. Full text of each new function

```ahk
; @summary Which steps should name their program in the macro list. flatSteps = VMF_Flatten(blocks), in order.
; @returns Map step -> 1 (the first step with a program: show " in notepad"), 2 (the program differs from the step
;          before that had one: show " → in notepad") or 0 (same program: do not show it). Steps without a recorded
;          window (no "win" / no "exe") get no entry and do not break a run.
; @tags macro, explain, gui, v21
V21_AppRuns(flatSteps) {
    out := Map(), lastExe := ""
    for step in flatSteps {
        if !(step is Map)
            continue
        win := step.Get("win", "")
        if !(win is Map) || win.Get("exe", "") = ""
            continue
        exe := win["exe"]
        out[step] := lastExe = "" ? 1 : exe != lastExe ? 2 : 0       ; != ignores upper / lower case
        lastExe := exe
    }
    return out
}

; @summary How V20_InApp should name this step's program: the editor's AppShow entry (0, 1 or 2), or true when there
;          is no editor map or no entry (so a loose step, for example in the self-test, always names its program).
; @tags macro, explain, gui, v21
V21_ShowApp(node) {
    appShow := VMB().AppShow
    return appShow is Map ? appShow.Get(node, true) : true
}
```

`V20_InApp` (changed, full text):

```ahk
V20_InApp(node, show := true) {
    win := node.Get("win", "")
    if !show || !(win is Map) || win.Get("exe", "") = ""
        return ""
    return (show = 2 ? " → in " : " in ") . V20_AppName(win["exe"])
}
```

## 3. New self-test lines and PASS count

The 7 `check(...)` lines are in block 11 above. Self-test under Wine: **281 PASS** (V20: 274), `Failures: 0`.
All V20 self-tests pass unchanged.

## 4. Notes / anything unsure

- The plan says `V21_AppRuns` returns `node -> true` for the steps that show their program, and `V21_ShowApp`
  returns `true` when there is no entry. To make both work (and to know which ones CHANGED, for the stronger
  `" → in notepad"`), every step that has a program gets an entry: `1` = first one (AutoHotkey's `true` is 1),
  `2` = changed, `0` = same as before (hidden). Steps with no program get no entry - they show nothing anyway.
- `AppShow: 0` is added to the state object in `VMB()` in this item (the plan lists it under item D) because
  `V21_ShowApp` reads `VMB().AppShow` and the property must exist before the first read (the self-test reads it
  with no editor window). Item D adds only `LastNotes`.
- The plan says there are three `VMB_NodeLabel(` matches: they are the definition, the call in `VMB_AddBody` (used
  by `VMB_Refresh`, map already filled) and the one in `V13_InspCommit`, which now recomputes the map. The
  inspector re-labels only the edited row; the inspector has no field that changes a step's program, so the other
  rows cannot go stale from it.
- Program names are compared with `!=`, which in AutoHotkey ignores upper / lower case, so `notepad.exe` and
  `NOTEPAD.EXE` are the same program.
- Only the step list text changes; playback is not touched. With "Show meaning" off the rows use the older form
  as before (it never named the program as "in notepad").

## 5. Tests run (Wine, AutoHotkey 2.0.27 portable; the file uses nothing newer than 2.0.19)

- Load check (`/validate`, `#Warn All`): no errors, no warnings.
- Self-test: 281 PASS, `Failures: 0`. Brace / bracket balance check: balanced, no duplicate names.
- Notepad record / replay (click, type `hello grokbot`, Enter, type `line2`, stop, Play): Notepad ends with
  `KEEP MEhello grokbot` / `line2`, 0 notes.
- The V18 macro (old format) replays the same as with V20: same text, same window size, 0 notes.
- Screenshot of the step list after recording: `#2 Click a text box in notepad — top middle (596, 21)`, then
  `#3 Type "hello grokbot"`, `#4 Press Enter (OK / submit / new line)`, `#5 Type "line2"` - the program is named once.
