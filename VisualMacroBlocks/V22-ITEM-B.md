# V22 item B - show the columns in the tree

File: `VisualMacroBlocks-makecode-telek-V22-columns.ahk2`. The find blocks are for the file after item A; each
occurs exactly once there (checked with the script that applies them; the result is the committed file).

## 1. Find / replace blocks (in file order)

### Block 1 - in `VMB()` (state: column mode and its pieces)

Find:
```ahk
        Easy: 1, FullPos: 0, PinHwnd: 0, Lbl: Map(), RecWasEmpty: false, AppShow: 0, LastNotes: Map()}
```
Replace with:
```ahk
        Easy: 1, FullPos: 0, PinHwnd: 0, Lbl: Map(), RecWasEmpty: false, AppShow: 0, LastNotes: Map(),
        Columns: 1, ColApp: 0, ColStarts: 0, IndentChars: 3, IndentSeen: ""}
```

### Block 2 - in `VMB_BuildGui` (read the switch at startup)

Find:
```ahk
    s.ShowMeaning := Integer(IniRead(s.Ini, "V13", "ExplainSteps", 1))
```
Replace with:
```ahk
    s.ShowMeaning := Integer(IniRead(s.Ini, "V13", "ExplainSteps", 1))
    s.Columns := Integer(IniRead(s.Ini, "V22", "Columns", 1)) ? 1 : 0          ; V22: step list in fixed columns
```

### Block 3 - in `VMB_BuildGui` (tree font through one function)

Find:
```ahk
    s.TV.SetFont("s" . s.FontSize)
    V13_BuildInspector(g)
```
Replace with:
```ahk
    V22_ApplyTreeFont(false)            ; V22: Consolas + exact indent in column mode
    V13_BuildInspector(g)
```

### Block 4 - in `VMB_Refresh` (fill the Program column; depth 0 for top-level rows)

Find:
```ahk
    s.AppShow := V21_AppRuns(VMF_Flatten(s.Macro["blocks"]))     ; V21: say the program only when it changes
```
Replace with:
```ahk
    s.AppShow := V21_AppRuns(VMF_Flatten(s.Macro["blocks"]))     ; V21: say the program only when it changes
    r := V22_FillApps(VMF_Flatten(s.Macro["blocks"]), s.Macro["settings"])     ; V22: the Program column, every row
    s.ColApp := r.App, s.ColStarts := r.Starts
```

### Block 5 - in `VMB_AddBody` (pass the tree depth down; ELSE rows start where the step numbers do)

Find:
```ahk
VMB_AddBody(list, parentId, owner, emptyText := "(empty - drag steps here)", off := false) {
    s := VMB()
```
Replace with:
```ahk
VMB_AddBody(list, parentId, owner, emptyText := "(empty - drag steps here)", off := false, depth := 0) {
    s := VMB()
    cols := s.Columns && s.ShowMeaning              ; V22: depth = tree level of the rows added here
```

### Block 6 - in `VMB_AddBody`

Find:
```ahk
        id := s.TV.Add(VMB_NodeLabel(node), parentId, isBox ? "Bold Expand" : "")
```
Replace with:
```ahk
        id := s.TV.Add(VMB_NodeLabel(node, depth), parentId, isBox ? "Bold Expand" : "")
```

### Block 7 - in `VMB_AddBody`

Find:
```ahk
            VMB_AddBody(node["body"], id, node, , nodeOff)
            if node["type"] = "if" {
```
Replace with:
```ahk
            VMB_AddBody(node["body"], id, node, , nodeOff, depth + 1)
            if node["type"] = "if" {
```

### Block 8 - in `VMB_AddBody`

Find:
```ahk
                    label := " ELSE IF " . VMF__CondText(elif)
```
Replace with:
```ahk
                    label := (cols ? V22_Margin(depth + 1, s.IndentChars) : " ") . "ELSE IF " . VMF__CondText(elif)
```

### Block 9 - in `VMB_AddBody`

Find:
```ahk
                    VMB_AddBody(elif["body"], elifId, node, , nodeOff)
```
Replace with:
```ahk
                    VMB_AddBody(elif["body"], elifId, node, , nodeOff, depth + 2)
```

### Block 10 - in `VMB_AddBody`

Find:
```ahk
                elseId := s.TV.Add(" ELSE (when none of the above is true) ", id, "Bold Expand")
```
Replace with:
```ahk
                elseId := s.TV.Add((cols ? V22_Margin(depth + 1, s.IndentChars) : " ") . "ELSE (when none of the above is true) ", id, "Bold Expand")
```

### Block 11 - in `VMB_AddBody`

Find:
```ahk
                VMB_AddBody(node["else"], elseId, node, , nodeOff)
```
Replace with:
```ahk
                VMB_AddBody(node["else"], elseId, node, , nodeOff, depth + 2)
```

### Block 12 - `VMB_NodeLabel` (optional depth; the column row for steps; container rows start at the # column)

Find:
```ahk
VMB_NodeLabel(node) {
    s := VMB()
    off := (node.Get("breakpoint", 0) ? "●  " : "") . (node.Get("disabled", 0) ? "(off)  " : "")
    if VMF_IsStep(node) {
        num := s.FlatIndex.Get(node, "?"), lastNote := s.LastNotes.Get(num, "")      ; V21: a note in the last run
```
Replace with:
```ahk
VMB_NodeLabel(node, depth := unset) {
    s := VMB()
    off := (node.Get("breakpoint", 0) ? "●  " : "") . (node.Get("disabled", 0) ? "(off)  " : "")
    cols := s.Columns && s.ShowMeaning              ; V22: fixed columns
    if cols && !IsSet(depth)
        depth := s.NodeItem.Has(node) ? V22_DepthOf(s.NodeItem[node]) : 0
    if VMF_IsStep(node) {
        num := s.FlatIndex.Get(node, "?"), lastNote := s.LastNotes.Get(num, "")      ; V21: a note in the last run
        if cols
            return V22_Row(num, s.ColApp is Map ? s.ColApp.Get(node, "") : "", s.ColStarts is Map && s.ColStarts.Has(node),
                V22_WaitText(node), V22_Marks(node, lastNote), off . V22_Sentence(node, lastNote), depth, s.IndentChars) . " "
```

### Block 13 - in `VMB_NodeLabel` (container rows)

Find:
```ahk
        text .= "      [image " . VM__TargetText(node) . "]"
    return " " . off . text . " "
}
```
Replace with:
```ahk
        text .= "      [image " . VM__TargetText(node) . "]"
    if cols
        return V22_Margin(depth, s.IndentChars) . off . text . " "
    return " " . off . text . " "
}
```

### Block 14 - in `VMB_Zoom` (tree font through one function)

Find:
```ahk
    s.TV.SetFont("s" . s.FontSize)
    IniWrite(s.FontSize, s.Ini, "Blocks", "FontSize")
```
Replace with:
```ahk
    V22_ApplyTreeFont()                 ; V22: Consolas + exact indent in column mode
    IniWrite(s.FontSize, s.Ini, "Blocks", "FontSize")
```

### Block 15 - in `V13_InspCommit` (the other place that recomputes `s.AppShow`)

Find:
```ahk
        s.AppShow := V21_AppRuns(VMF_Flatten(s.Macro["blocks"]))     ; V21: keep the "in <program>" marks up to date
```
Replace with:
```ahk
        s.AppShow := V21_AppRuns(VMF_Flatten(s.Macro["blocks"]))     ; V21: keep the "in <program>" marks up to date
        r := V22_FillApps(VMF_Flatten(s.Macro["blocks"]), s.Macro["settings"])     ; V22: and the Program column
        s.ColApp := r.App, s.ColStarts := r.Starts
```

### Block 16 - `V21_ShowApp` (column mode: the program is in its own column, not in the sentence)

Find:
```ahk
V21_ShowApp(node) {
    appShow := VMB().AppShow
```
Replace with:
```ahk
V21_ShowApp(node) {
    if VMB().Gui && VMB().Columns       ; V22: column mode in the editor (with no editor: as in V21)
        return false
    appShow := VMB().AppShow
```

### Block 17 - `V22_Marks` (characters from `V22_MarkChars`)

Find:
```ahk
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
```
Replace with:
```ahk
V22_Marks(node, lastNote := "") {
    chars := V22_MarkChars(), out := ""
    if node.Get("scroll", "") is Map
        out .= chars["scroll"]
    if V8_VarySummaryBadge(node) != ""
        out .= chars["vary"]
    if node.Get("winMatch", "") = "active"
        out .= chars["active"]
    if node.Get("note", "") != ""
        out .= chars["note"]
    if lastNote != ""
        out .= chars["warn"]
    return out
}
```

### Block 18 - `V22_Row` (the ► from `V22_MarkChars`)

Find:
```ahk
        numCol := SubStr(numCol, 1, cols[1].W - 1) . "►"
```
Replace with:
```ahk
        numCol := SubStr(numCol, 1, cols[1].W - 1) . V22_MarkChars()["start"]
```

### Block 19 - V22 section (new functions at its end)

Find:
```ahk
; ============================================================================
; V4 STARTUP / SINGLE-FILE PLAYER EXPORT
```
Replace with:
```ahk
; @summary The mark characters of the Marks column and the "►" of the number column, in one place. plain = 1 gives
;          plain ASCII letters instead (for a PC where the symbols show as boxes or are too wide). With no argument the
;          ini value [V22] PlainMarks (default 0) decides; it is read once, so a change needs a restart.
; @tags macro, gui, columns, v22
V22_MarkChars(plain := "") {
    static fromIni := 0
    if plain = "" {
        if !fromIni {
            ini := VMB().Ini
            fromIni := V22_MarkChars(ini != "" && IniRead(ini, "V22", "PlainMarks", 0) = "1" ? 1 : 0)
        }
        return fromIni
    }
    return plain ? Map("scroll", "S", "vary", "V", "active", "A", "note", "N", "warn", "!", "start", ">")
        : Map("scroll", "↕", "vary", "⚡", "active", "◇", "note", "✎", "warn", "⚠", "start", "►")
}

; @summary How deep a tree item is: the number of tree levels above it (0 = top level). ELSE rows and "(empty)"
;          placeholders are tree items too, so this counts tree levels, not block levels.
; @tags macro, gui, columns, v22
V22_DepthOf(item) {
    s := VMB(), depth := 0
    while item && (item := s.TV.GetParent(item))
        depth += 1
    return depth
}

; @summary Sets the macro tree's font - Consolas in column mode, else Segoe UI - and, in column mode, makes the tree's
;          indent exactly s.IndentChars characters wide (raised when Windows will not take an indent that small).
;          Leaving column mode puts the tree's own indent back. refresh = rebuild the rows when IndentChars changed.
; @tags macro, gui, columns, v22
V22_ApplyTreeFont(refresh := true) {
    static defaultIndent := 0
    s := VMB()
    if !s.TV
        return
    if !defaultIndent
        defaultIndent := SendMessage(0x1106, 0, 0, s.TV)                  ; TVM_GETINDENT, before any change
    s.TV.SetFont("s" . s.FontSize, s.Columns ? "Consolas" : "Segoe UI")
    if !s.Columns {
        SendMessage(0x1107, defaultIndent, 0, s.TV)                        ; TVM_SETINDENT
        return
    }
    hFont := SendMessage(0x31, 0, 0, s.TV)                                 ; WM_GETFONT
    hdc := DllCall("GetDC", "Ptr", s.TV.Hwnd, "Ptr")
    oldFont := DllCall("SelectObject", "Ptr", hdc, "Ptr", hFont, "Ptr")
    ext := Buffer(8, 0)
    DllCall("GetTextExtentPoint32W", "Ptr", hdc, "Str", "0000000000", "Int", 10, "Ptr", ext)
    DllCall("SelectObject", "Ptr", hdc, "Ptr", oldFont, "Ptr")
    DllCall("ReleaseDC", "Ptr", s.TV.Hwnd, "Ptr", hdc)
    charW := Max(1, NumGet(ext, 0, "Int") / 10)
    before := s.IndentChars
    want := Round(charW * s.IndentChars)
    SendMessage(0x1107, want, 0, s.TV)
    actual := SendMessage(0x1106, 0, 0, s.TV)
    if actual > want {                                                     ; Windows refused an indent this small
        s.IndentChars := Ceil(actual / charW)
        SendMessage(0x1107, Round(charW * s.IndentChars), 0, s.TV)
    }
    s.IndentSeen := "char " . charW . " px, asked " . want . " px, got " . actual . " px, " . s.IndentChars . " characters"
    if refresh && s.IndentChars != before
        VMB_Refresh()
}

; ============================================================================
; V4 STARTUP / SINGLE-FILE PLAYER EXPORT
```

### Block 20 - in `V4_SelfTest` (new checks right before `player := V4_PlayerSource(source, macro)`)

Find:
```ahk
        player := V4_PlayerSource(source, macro)
```
Replace with:
```ahk
        v22M := V22_MarkChars(0), v22P := V22_MarkChars(1)
        check("V22 mark characters: symbols and plain", v22M["scroll"] . v22M["vary"] . v22M["active"] . v22M["note"] . v22M["warn"] . v22M["start"] . "|"
            . v22P["scroll"] . v22P["vary"] . v22P["active"] . v22P["note"] . v22P["warn"] . v22P["start"], "↕⚡◇✎⚠►|SVAN!>")
        check("V22 marks come from the mark characters", V22_Marks(Map("type", "click", "note", "x"), "Step #1: y"), V22_MarkChars()["note"] . V22_MarkChars()["warn"])
        check("V22 no editor: the program stays in the sentence", V20_StepSentence(Map("type", "keys", "keys", "{Enter}", "win", Map("exe", "notepad.exe"))),
            "Press Enter (OK / submit / new line) in notepad")
        player := V4_PlayerSource(source, macro)
```

## 2. Full text of each new function

```ahk
; @summary The mark characters of the Marks column and the "►" of the number column, in one place. plain = 1 gives
;          plain ASCII letters instead (for a PC where the symbols show as boxes or are too wide). With no argument the
;          ini value [V22] PlainMarks (default 0) decides; it is read once, so a change needs a restart.
; @tags macro, gui, columns, v22
V22_MarkChars(plain := "") {
    static fromIni := 0
    if plain = "" {
        if !fromIni {
            ini := VMB().Ini
            fromIni := V22_MarkChars(ini != "" && IniRead(ini, "V22", "PlainMarks", 0) = "1" ? 1 : 0)
        }
        return fromIni
    }
    return plain ? Map("scroll", "S", "vary", "V", "active", "A", "note", "N", "warn", "!", "start", ">")
        : Map("scroll", "↕", "vary", "⚡", "active", "◇", "note", "✎", "warn", "⚠", "start", "►")
}

; @summary How deep a tree item is: the number of tree levels above it (0 = top level). ELSE rows and "(empty)"
;          placeholders are tree items too, so this counts tree levels, not block levels.
; @tags macro, gui, columns, v22
V22_DepthOf(item) {
    s := VMB(), depth := 0
    while item && (item := s.TV.GetParent(item))
        depth += 1
    return depth
}

; @summary Sets the macro tree's font - Consolas in column mode, else Segoe UI - and, in column mode, makes the tree's
;          indent exactly s.IndentChars characters wide (raised when Windows will not take an indent that small).
;          Leaving column mode puts the tree's own indent back. refresh = rebuild the rows when IndentChars changed.
; @tags macro, gui, columns, v22
V22_ApplyTreeFont(refresh := true) {
    static defaultIndent := 0
    s := VMB()
    if !s.TV
        return
    if !defaultIndent
        defaultIndent := SendMessage(0x1106, 0, 0, s.TV)                  ; TVM_GETINDENT, before any change
    s.TV.SetFont("s" . s.FontSize, s.Columns ? "Consolas" : "Segoe UI")
    if !s.Columns {
        SendMessage(0x1107, defaultIndent, 0, s.TV)                        ; TVM_SETINDENT
        return
    }
    hFont := SendMessage(0x31, 0, 0, s.TV)                                 ; WM_GETFONT
    hdc := DllCall("GetDC", "Ptr", s.TV.Hwnd, "Ptr")
    oldFont := DllCall("SelectObject", "Ptr", hdc, "Ptr", hFont, "Ptr")
    ext := Buffer(8, 0)
    DllCall("GetTextExtentPoint32W", "Ptr", hdc, "Str", "0000000000", "Int", 10, "Ptr", ext)
    DllCall("SelectObject", "Ptr", hdc, "Ptr", oldFont, "Ptr")
    DllCall("ReleaseDC", "Ptr", s.TV.Hwnd, "Ptr", hdc)
    charW := Max(1, NumGet(ext, 0, "Int") / 10)
    before := s.IndentChars
    want := Round(charW * s.IndentChars)
    SendMessage(0x1107, want, 0, s.TV)
    actual := SendMessage(0x1106, 0, 0, s.TV)
    if actual > want {                                                     ; Windows refused an indent this small
        s.IndentChars := Ceil(actual / charW)
        SendMessage(0x1107, Round(charW * s.IndentChars), 0, s.TV)
    }
    s.IndentSeen := "char " . charW . " px, asked " . want . " px, got " . actual . " px, " . s.IndentChars . " characters"
    if refresh && s.IndentChars != before
        VMB_Refresh()
}
```

## 3. New self-test lines and PASS count

The 3 new `check(...)` lines are in block 20 (both mark sets of `V22_MarkChars`; `V22_Marks` takes its characters
from it; with no editor the sentence still names the program, as in V21). `V22_DepthOf` and `V22_ApplyTreeFont`
need a real tree, so they are tested in the window (below), not in the self-test. Self-test under Wine:
**368 PASS** (after item A: 365; V21: 347), `Failures: 0`.

## 4. Notes / anything unsure

- **Tree indent:** with the Consolas stand-in under Wine one character measured 7 px, so 3 characters = 21 px
  were asked for; `TVM_GETINDENT` read back **21** (Wine took it, `IndentChars` stayed 3). The tree's own indent
  before the change was the system default. Real Windows may refuse an indent this small (it has a minimum tied to
  the check box / button size); then the code raises `IndentChars` as the plan says and rebuilds the rows. The
  values it saw are kept in `s.IndentSeen` ("char 7 px, asked 21 px, got 21 px, 3 characters") - please read it on
  the PC if the nested rows are off (PC check 3).
- **Font under Wine:** the test machine has no Consolas. Wine first drew a proportional font (columns did not line
  up). For the test I mapped `Consolas` to DejaVu Sans Mono in the Wine prefix only (`HKCU\Software\Wine\Fonts\
  Replacements`); after that the columns lined up at depth 0, 1 and 2. This proves the padding / indent logic, not
  how Consolas itself draws the mark symbols on Windows.
- Column mode is used for the rows when `s.Columns` AND `s.ShowMeaning` are on (the plan's rule). The font follows
  `s.Columns` only, as the plan says: with "Explain steps" off and columns on, the older rows are drawn in Consolas.
- `VMB_NodeLabel(node, depth := unset)`: when no depth is passed (the inspector's one-row re-label), it takes the
  depth from the tree with `V22_DepthOf`. `VMB_AddBody` passes the TREE level down: the body of a block is +1, the
  bodies under an ELSE IF / ELSE row are +2 (that row is a tree level of its own). ELSE IF / ELSE rows get the same
  margin as the step numbers of their level. "(empty - drag steps here)" placeholders are unchanged.
- In column mode the row does not start with V21's leading space, so the header (item C) can use the same margin.
  The `●` / `(off)` prefixes are put in front of the sentence, so the columns do not shift.
- `V21_ShowApp` returns `false` only when the editor window exists (`VMB().Gui`) and `s.Columns` is on; with no
  editor (self-test) it is as in V21, so all V20 / V21 checks pass unchanged. With columns off the V21 rules apply.
- `V22_MarkChars` reads `[V22] PlainMarks` once (on first use) - a change needs a restart (the plan's PC check 5
  says "and restart").
- `s.IndentSeen` was added to the state object for the note above (display only, not saved).

## 5. Tests run (Wine)

- Load check: no errors, no warnings. Self-test: 368 PASS, `Failures: 0`. Brace check: balanced.
- Test macro in the editor: every step row shows its program (`notepad`, `calc`, `web page`), `►` on the first
  step of a new program (#6 calc, #7 notepad, #8 web page, #11 notepad), Waits `300 ms` / `816 ms`, and the numbers,
  program and sentence of the rows inside Repeat / Count line up with the top-level rows. ELSE lines up with the
  rows of its level.
- Notepad record / replay: `KEEP MEhello grokbot` / `line2`, 0 notes. V18 macro replays as before.
