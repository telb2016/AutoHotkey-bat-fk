# V22 item A - the column text (pure functions, no GUI yet)

File: `VisualMacroBlocks-makecode-telek-V22-columns.ahk2` (made as a copy of `VisualMacroBlocks-makecode-telek-V21-step-list.ahk2`; the V21 file is not changed). The find blocks are for the V21 file; each
occurs exactly once there (checked with the script that applies them; the result is the committed file).

## 1. Find / replace blocks (in file order)

### Block 1 - new section directly above `; V4 STARTUP / SINGLE-FILE PLAYER EXPORT`

Find:
```ahk
; ============================================================================
; V4 STARTUP / SINGLE-FILE PLAYER EXPORT
```
Replace with:
```ahk
; ============================================================================
; V22 COLUMNS
; The step list in fixed columns: number, program (on every row), waits, marks, then the sentence. The tree uses a
; monospace font and each column is padded with spaces; deeper rows give back the tree's own indent so the columns
; line up at every depth. Display only - nothing here is saved to the macro file or changes playback.
; ============================================================================

; @summary Exactly width characters: text padded with spaces, or cut to width - 1 characters plus "…".
;          Every character counts as one column (StrLen).
; @tags macro, gui, columns, v22
V22_Pad(text, width) {
    text := String(text)
    if width < 1
        return ""
    if StrLen(text) > width
        return SubStr(text, 1, width - 1) . "…"
    return Format("{:-" . width . "}", text)
}

; @summary The column layout of the step list: number, program, waits, marks (widths in characters). The gap
;          between columns is always 1 space; the sentence follows after the last column.
; @tags macro, gui, columns, v22
V22_Cols() {
    static cols := [{Key: "num", W: 5}, {Key: "app", W: 14}, {Key: "wait", W: 9}, {Key: "marks", W: 7}]
    return cols
}

; @summary The spaces in front of a row: 8 * indentChars for a top-level row, depth * indentChars fewer for a
;          deeper row (the tree's own indent makes up the difference), never fewer than none.
; @tags macro, gui, columns, v22
V22_Margin(depth, indentChars) {
    n := Max(0, (8 - Max(0, depth)) * indentChars)
    return n ? Format("{:" . n . "}", "") : ""
}

; @summary The program of one step for the Program column ("" when the step itself has none): the recorded
;          window's program; for det_* / input_* steps with a "target" field the program of that target, or of the
;          Macro window (settings "defaultTarget") when it is blank; "web page" for web steps.
; @tags macro, gui, columns, v22
V22_AppOf(node, settings := 0) {
    win := node.Get("win", "")
    if win is Map && win.Get("exe", "") != ""
        return V20_AppName(win["exe"])
    t := node.Get("type", "")
    if SubStr(t, 1, 4) = "web_"
        return "web page"
    if (SubStr(t, 1, 4) = "det_" || SubStr(t, 1, 6) = "input_") && node.Has("target") {
        target := Trim(node["target"])
        if target = "" && settings is Map
            target := Trim(settings.Get("defaultTarget", ""))
        return target = "" ? "" : V20_TargetName(target)
    }
    return ""
}

; @summary The Program column for every step: a step with no program of its own (a Delay ...) takes the program of
;          the nearest earlier step that had one. flatSteps = VMF_Flatten(blocks); blocks that are not steps are skipped.
; @returns {App: Map step -> program text, Starts: Map step -> true for the first step and each step whose program
;          differs (upper / lower case ignored) from the step before}
; @tags macro, gui, columns, v22
V22_FillApps(flatSteps, settings := 0) {
    apps := Map(), starts := Map(), prevApp := "", isFirst := true
    for step in flatSteps {
        if !(step is Map) || !VMF_IsStep(step)
            continue
        own := V22_AppOf(step, settings)
        filled := own != "" ? own : prevApp
        apps[step] := filled
        if isFirst || filled != prevApp
            starts[step] := true
        isFirst := false, prevApp := filled
    }
    return {App: apps, Starts: starts}
}

; @summary The Waits column: a wait set by hand ("delayMs") as "500 ms*", else a recorded pause of 300 ms or more
;          ("2.4 s"), else "".
; @tags macro, gui, columns, v22
V22_WaitText(node) {
    if node.Has("delayMs")
        return V20_Time(node["delayMs"]) . "*"
    gap := node.Get("gapMs", 0)
    return IsNumber(gap) && gap >= 300 ? V20_Time(gap) : ""
}

; @summary The Marks column, one character each, in this order and only when it applies: list scrolled back first,
;          changes each round, whatever window is active, has a note, had a note in the last run.
; @tags macro, gui, columns, v22
V22_Marks(node, lastNote := "") {
    out := ""
    if node.Get("scroll", "") is Map
        out .= "↕"
    if V8_VarySummaryBadge(node) != ""
        out .= "⚡"
    if node.Get("winMatch", "") = "active"
        out .= "◇"
    if node.Get("note", "") != ""
        out .= "✎"
    if lastNote != ""
        out .= "⚠"
    return out
}

; @summary The sentence at the end of a step row: V20_StepSentence (or the older "name   details" when it has
;          none), then "   // <note>", then the last-run note tag.
; @tags macro, gui, columns, v22
V22_Sentence(node, lastNote := "") {
    text := V20_StepSentence(node)
    if text = "" {
        sum := VM_StepSummary(node)
        text := sum[1] . "   " . sum[3]
    }
    return text . (node.Get("note", "") != "" ? "   // " . node["note"] : "") . (lastNote != "" ? V21_NoteTag(lastNote) : "")
}

; @summary One whole step row in fixed columns: margin, number (with "►" in its last character when the task
;          moves to another program here, not on step 1), program, waits, marks, then the sentence.
; @tags macro, gui, columns, v22
V22_Row(num, app, startsApp, wait, marks, sentence, depth, indentChars) {
    cols := V22_Cols()
    numCol := V22_Pad(num, cols[1].W)
    if startsApp && num != 1
        numCol := SubStr(numCol, 1, cols[1].W - 1) . "►"
    return V22_Margin(depth, indentChars) . numCol . " " . V22_Pad(app, cols[2].W) . " " . V22_Pad(wait, cols[3].W)
        . " " . V22_Pad(marks, cols[4].W) . " " . sentence
}

; @summary The column names, built with the same margin and widths as a top-level row.
; @tags macro, gui, columns, v22
V22_Header(indentChars) {
    cols := V22_Cols()
    return V22_Margin(0, indentChars) . V22_Pad("#", cols[1].W) . " " . V22_Pad("Program", cols[2].W) . " "
        . V22_Pad("Waits", cols[3].W) . " " . V22_Pad("Marks", cols[4].W) . " What it does"
}

; ============================================================================
; V4 STARTUP / SINGLE-FILE PLAYER EXPORT
```

### Block 2 - in `V4_SelfTest` (new checks right before `player := V4_PlayerSource(source, macro)`)

Find:
```ahk
        player := V4_PlayerSource(source, macro)
```
Replace with:
```ahk
        check("V22 pad short / exact / too long / empty", V22_Pad("ab", 5) . "|" . V22_Pad("abcde", 5) . "|" . V22_Pad("abcdefgh", 5) . "|" . V22_Pad("", 3) . "|",
            "ab   |abcde|abcd…|   |")
        v22Set := Map("defaultTarget", "ahk_class Notepad ahk_exe notepad.exe")
        check("V22 program of a recorded step", V22_AppOf(Map("type", "click", "win", Map("exe", "msedge.exe"))), "msedge")
        check("V22 program of Use Window", V22_AppOf(Map("type", "det_use_window", "target", "ahk_exe calc.exe"), v22Set) . "|"
            . V22_AppOf(Map("type", "det_use_window", "target", ""), v22Set), "calc|notepad")
        check("V22 program of Normalize / input steps", V22_AppOf(Map("type", "det_normalize_win", "target", ""), v22Set) . "|"
            . V22_AppOf(Map("type", "input_send", "target", "ahk_exe wfica32.exe"), v22Set) . "|" . V22_AppOf(Map("type", "det_normalize_win", "target", "")), "notepad|wfica32|")
        check("V22 program of web and delay steps", V22_AppOf(Map("type", "web_click", "selector", "#a")) . "|" . V22_AppOf(Map("type", "delay", "ms", 5), v22Set), "web page|")
        v22A := Map("exe", "notepad.exe"), v22B := Map("exe", "calc.exe")
        v22S := [Map("type", "click", "win", v22A), Map("type", "keys", "win", v22A), Map("type", "click", "win", v22B),
            Map("type", "text", "win", v22B), Map("type", "keys", "win", Map("exe", "NOTEPAD.EXE"))]
        v22R := V22_FillApps(v22S)
        check("V22 fill A A B B A", v22R.App[v22S[1]] . "," . v22R.App[v22S[2]] . "," . v22R.App[v22S[3]] . "," . v22R.App[v22S[4]] . "," . v22R.App[v22S[5]],
            "notepad,notepad,calc,calc,NOTEPAD")
        check("V22 starts A A B B A", v22R.Starts.Has(v22S[1]) . v22R.Starts.Has(v22S[2]) . v22R.Starts.Has(v22S[3]) . v22R.Starts.Has(v22S[4]) . v22R.Starts.Has(v22S[5]), "10101")
        v22S := [Map("type", "click", "win", v22A), Map("type", "delay", "ms", 500), Map("type", "repeat", "count", 2, "body", []), Map("type", "keys", "win", v22A)]
        v22R := V22_FillApps(v22S)
        check("V22 a Delay takes the program before it", v22R.App[v22S[2]] . "|" . v22R.Starts.Has(v22S[2]) . v22R.Starts.Has(v22S[4]) . "|" . v22R.App.Has(v22S[3]) . "|" . v22R.App.Count,
            "notepad|00|0|3")
        v22S := [Map("type", "delay", "ms", 1), Map("type", "delay", "ms", 2)]
        v22R := V22_FillApps(v22S)
        check("V22 no program at all", v22R.App[v22S[1]] . v22R.App[v22S[2]] . "|" . v22R.Starts.Count, "|1")
        check("V22 waits: fixed / recorded / small gap", V22_WaitText(Map("delayMs", 500, "gapMs", 3000)) . "|" . V22_WaitText(Map("gapMs", 2440)) . "|"
            . V22_WaitText(Map("gapMs", 120)) . "|" . V22_WaitText(Map()), "500 ms*|2.4 s||")
        check("V22 marks: none", V22_Marks(Map("type", "click")), "")
        check("V22 marks: all five in order", V22_Marks(Map("type", "click", "note", "x", "winMatch", "active", "varyDX", 5, "scroll", Map("v", 1)), "Step #1: x"), "↕⚡◇✎⚠")
        check("V22 marks: order kept with some", V22_Marks(Map("type", "click", "note", "x", "scroll", Map("v", 1))), "↕✎")
        v22R0 := V22_Row(1, "notepad", true, "", "", "Click", 0, 3), v22R1 := V22_Row(12, "notepad", true, "2.4 s", "↕", "Type", 1, 3)
        v22R2 := V22_Row(7, "calc", false, "", "", "Press", 2, 3)
        check("V22 Program column lines up at depth 0, 1 and 2", (InStr(v22R0, "notepad") + 0 * 3) . "," . (InStr(v22R1, "notepad") + 1 * 3) . "," . (InStr(v22R2, "calc") + 2 * 3), "31,31,31")
        check("V22 row text", v22R0 . "|" . SubStr(v22R1, 22), Format("{:24}", "") . "1     notepad                          Click|12  ► notepad        2.4 s     ↕       Type")
        check("V22 header starts Program at the same place", InStr(V22_Header(3), "Program") . "|" . SubStr(V22_Header(3), 25),
            "31|#     Program        Waits     Marks   What it does")
        check("V22 rows deeper than 8 levels keep no margin", InStr(V22_Row(3, "x", false, "", "", "", 9, 3), "3"), 1)
        check("V22 sentence: no older form needed / older form / note and last run", V22_Sentence(Map("type", "delay", "ms", 500)) . "|"
            . V22_Sentence(Map("type", "input_keydelay", "delay", 30, "duration", 30)) . "|"
            . V22_Sentence(Map("type", "delay", "ms", 500, "note", "wait"), "Step #3: slow"),
            "Wait 500 ms|" . VM_StepSummary(Map("type", "input_keydelay", "delay", 30, "duration", 30))[1] . "   " . VM_StepSummary(Map("type", "input_keydelay", "delay", 30, "duration", 30))[3]
            . "|Wait 500 ms   // wait   ⚠ last run: slow")
        player := V4_PlayerSource(source, macro)
```

## 2. Full text of each new function

```ahk
; @summary Exactly width characters: text padded with spaces, or cut to width - 1 characters plus "…".
;          Every character counts as one column (StrLen).
; @tags macro, gui, columns, v22
V22_Pad(text, width) {
    text := String(text)
    if width < 1
        return ""
    if StrLen(text) > width
        return SubStr(text, 1, width - 1) . "…"
    return Format("{:-" . width . "}", text)
}

; @summary The column layout of the step list: number, program, waits, marks (widths in characters). The gap
;          between columns is always 1 space; the sentence follows after the last column.
; @tags macro, gui, columns, v22
V22_Cols() {
    static cols := [{Key: "num", W: 5}, {Key: "app", W: 14}, {Key: "wait", W: 9}, {Key: "marks", W: 7}]
    return cols
}

; @summary The spaces in front of a row: 8 * indentChars for a top-level row, depth * indentChars fewer for a
;          deeper row (the tree's own indent makes up the difference), never fewer than none.
; @tags macro, gui, columns, v22
V22_Margin(depth, indentChars) {
    n := Max(0, (8 - Max(0, depth)) * indentChars)
    return n ? Format("{:" . n . "}", "") : ""
}

; @summary The program of one step for the Program column ("" when the step itself has none): the recorded
;          window's program; for det_* / input_* steps with a "target" field the program of that target, or of the
;          Macro window (settings "defaultTarget") when it is blank; "web page" for web steps.
; @tags macro, gui, columns, v22
V22_AppOf(node, settings := 0) {
    win := node.Get("win", "")
    if win is Map && win.Get("exe", "") != ""
        return V20_AppName(win["exe"])
    t := node.Get("type", "")
    if SubStr(t, 1, 4) = "web_"
        return "web page"
    if (SubStr(t, 1, 4) = "det_" || SubStr(t, 1, 6) = "input_") && node.Has("target") {
        target := Trim(node["target"])
        if target = "" && settings is Map
            target := Trim(settings.Get("defaultTarget", ""))
        return target = "" ? "" : V20_TargetName(target)
    }
    return ""
}

; @summary The Program column for every step: a step with no program of its own (a Delay ...) takes the program of
;          the nearest earlier step that had one. flatSteps = VMF_Flatten(blocks); blocks that are not steps are skipped.
; @returns {App: Map step -> program text, Starts: Map step -> true for the first step and each step whose program
;          differs (upper / lower case ignored) from the step before}
; @tags macro, gui, columns, v22
V22_FillApps(flatSteps, settings := 0) {
    apps := Map(), starts := Map(), prevApp := "", isFirst := true
    for step in flatSteps {
        if !(step is Map) || !VMF_IsStep(step)
            continue
        own := V22_AppOf(step, settings)
        filled := own != "" ? own : prevApp
        apps[step] := filled
        if isFirst || filled != prevApp
            starts[step] := true
        isFirst := false, prevApp := filled
    }
    return {App: apps, Starts: starts}
}

; @summary The Waits column: a wait set by hand ("delayMs") as "500 ms*", else a recorded pause of 300 ms or more
;          ("2.4 s"), else "".
; @tags macro, gui, columns, v22
V22_WaitText(node) {
    if node.Has("delayMs")
        return V20_Time(node["delayMs"]) . "*"
    gap := node.Get("gapMs", 0)
    return IsNumber(gap) && gap >= 300 ? V20_Time(gap) : ""
}

; @summary The Marks column, one character each, in this order and only when it applies: list scrolled back first,
;          changes each round, whatever window is active, has a note, had a note in the last run.
; @tags macro, gui, columns, v22
V22_Marks(node, lastNote := "") {
    out := ""
    if node.Get("scroll", "") is Map
        out .= "↕"
    if V8_VarySummaryBadge(node) != ""
        out .= "⚡"
    if node.Get("winMatch", "") = "active"
        out .= "◇"
    if node.Get("note", "") != ""
        out .= "✎"
    if lastNote != ""
        out .= "⚠"
    return out
}

; @summary The sentence at the end of a step row: V20_StepSentence (or the older "name   details" when it has
;          none), then "   // <note>", then the last-run note tag.
; @tags macro, gui, columns, v22
V22_Sentence(node, lastNote := "") {
    text := V20_StepSentence(node)
    if text = "" {
        sum := VM_StepSummary(node)
        text := sum[1] . "   " . sum[3]
    }
    return text . (node.Get("note", "") != "" ? "   // " . node["note"] : "") . (lastNote != "" ? V21_NoteTag(lastNote) : "")
}

; @summary One whole step row in fixed columns: margin, number (with "►" in its last character when the task
;          moves to another program here, not on step 1), program, waits, marks, then the sentence.
; @tags macro, gui, columns, v22
V22_Row(num, app, startsApp, wait, marks, sentence, depth, indentChars) {
    cols := V22_Cols()
    numCol := V22_Pad(num, cols[1].W)
    if startsApp && num != 1
        numCol := SubStr(numCol, 1, cols[1].W - 1) . "►"
    return V22_Margin(depth, indentChars) . numCol . " " . V22_Pad(app, cols[2].W) . " " . V22_Pad(wait, cols[3].W)
        . " " . V22_Pad(marks, cols[4].W) . " " . sentence
}

; @summary The column names, built with the same margin and widths as a top-level row.
; @tags macro, gui, columns, v22
V22_Header(indentChars) {
    cols := V22_Cols()
    return V22_Margin(0, indentChars) . V22_Pad("#", cols[1].W) . " " . V22_Pad("Program", cols[2].W) . " "
        . V22_Pad("Waits", cols[3].W) . " " . V22_Pad("Marks", cols[4].W) . " What it does"
}
```

## 3. New self-test lines and PASS count

The 18 new `check(...)` lines are in block 2 (`V22_Pad`; `V22_AppOf` for each kind; `V22_FillApps` A A B B A,
Delay between, no program at all, `Starts`; `V22_WaitText`; `V22_Marks` none / all five / order; `V22_Row` at depth
0, 1, 2 - the Program column position plus `depth * indentChars` is 31 for all three; `V22_Header` starts `Program`
at 31; deeper than 8 levels; `V22_Sentence`). Self-test under Wine: **365 PASS** (V21: 347), `Failures: 0`.
All V20 / V21 checks pass unchanged.

## 4. Notes / anything unsure

- Nothing calls these functions yet (item B puts them in the tree), so the editor looks exactly like V21.
- Two small helpers the plan did not name: `V22_Margin(depth, indentChars)` (the leading spaces, shared by
  `V22_Row`, `V22_Header` and item B's block rows) and `V22_Sentence(node, lastNote)` (the plan's "Sentence:" rule
  in one place). Both are pure and self-tested.
- `V22_FillApps` gives entries only to steps (`VMF_IsStep`); Repeat / If rows have no Program column. The program
  text keeps the case of the exe (`NOTEPAD.EXE` -> `NOTEPAD`) but the start check ignores case.
- The Waits column uses `V20_Time` as the rules say, so a 400 ms pause reads `400 ms`, not `0.4 s` as in the plan's
  picture. Every recorded click has a pause of at least 300 ms (the first step is capped at 300), so most click rows
  show a time.
- `V22_AppOf` for a `det_*` / `input_*` step with a blank target uses the Macro window, as the plan says. At play
  time such a step actually uses the window of the last "Use Window From Here On" block, if there was one; the
  column does not follow that. Unsure whether the owner wants that; it would be a small change.
- The plan's ► rule uses `num != 1`; a top-level row always gets a 24-space margin (8 x 3), so the list starts with
  some empty space on the left - that is the plan's chosen way to line up nested rows.

## 5. Tests run (Wine)

- Load check: no errors, no warnings. Self-test: 365 PASS, `Failures: 0`. Brace check: balanced.
- Notepad record / replay: `KEEP MEhello grokbot` / `line2`, 0 notes. V18 macro replays as before.
