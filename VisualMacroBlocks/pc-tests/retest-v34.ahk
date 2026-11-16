#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn All, StdOut
; V34 retest driver: items 1 (ten replays), 4 (fast typing + Enter), 6 (unsaved changes), 3 (caption button names).
; Notepad only. Writes only under C:\Temp\vmb. Esc aborts. Usage: retest-v34.ahk [1] [4] [6] [3] [--plays N]
SetTitleMatchMode(2)
CoordMode("Mouse", "Screen"), CoordMode("Caret", "Screen"), CoordMode("ToolTip", "Screen")
SendMode("Event")
SetKeyDelay(45, 25)
SetMouseDelay(30)
SetControlDelay(40)
SendLevel(1)    ; VMB's recorder hotkeys (#InputLevel 0) ignore AutoHotkey input sent at level 0

global G := {Dir: "C:\Temp\vmb", Vmb: "C:\Temp\vmb\VMB34.ahk", Data: "C:\Temp\vmb\data",
    Results: "C:\Temp\vmb\retest-v34-results-" . FormatTime(, "HHmmss") . ".md", LogFile: "C:\Temp\vmb\retest-v34-log.txt",
    Macro: "C:\Temp\vmb\retest-notepad.vmacro.json", Pid: 0, Np: 0, NpPid: 0, NpKind: "", UseClip: false,
    HaveMacro: false, Plays: 10, Res: "", Done: false}
global COL := Map("num", 1, "app", 3, "window", 4, "action", 6, "target", 7, "text", 8, "clicks", 10, "wait", 16, "when", 18, "scroll", 20)

#InputLevel 2
~Esc:: Abort("Esc pressed")
#InputLevel 0

OnExit(WriteResults)
Main()
ExitApp(0)

Main() {
    items := [], i := 0
    while ++i <= A_Args.Length {
        a := A_Args[i]
        if a = "--plays" && i < A_Args.Length
            G.Plays := Integer(A_Args[++i])
        else if IsInteger(a)
            items.Push(Integer(a))
    }
    if !items.Length
        items := [1, 4, 6, 3]
    if !InStr(FileExist(G.Dir), "D")
        DirCreate(G.Dir)
    Log("===== run start, items " . JoinArr(items) . " =====")
    if !FileExist(G.Vmb)
        return Abort("Missing " . G.Vmb . " - run part1-selftest.ahk first.")
    if WinExist("ahk_exe notepad.exe")
        return Abort("Notepad is already open. Close every Notepad window (save your own work first), then run again.")
    if WinExist("Visual Macro Blocks ahk_class AutoHotkeyGUI")
        return Abort("Visual Macro Blocks is already running. Quit it (tray > Quit Completely), then run again.")
    Res("# V34 retest - automatic driver`n")
    Res("- Date: " . FormatTime(, "yyyy-MM-dd HH:mm") . "`n- Windows: " . A_OSVersion . "`n- AutoHotkey: " . A_AhkVersion
        . (A_PtrSize = 8 ? " 64-bit" : " 32-bit") . "`n- Screen: " . A_ScreenWidth . "x" . A_ScreenHeight . ", DPI " . A_ScreenDPI
        . " (" . Round(A_ScreenDPI / 96 * 100) . "%)`n- Driver: " . A_ScriptFullPath . " (SendLevel 1, SendEvent)`n- Data folder: "
        . G.Data . " (--data, Documents\VisualMacros untouched)`n- Items: " . JoinArr(items) . "`n")
    MsgBox("The V34 retest will now drive the mouse and keyboard (Notepad only).`n`nDo not touch the mouse or keyboard until the "
        . "'done' box appears.`nPress Esc at any time to stop.", "V34 retest", "OK Iconi T8")
    StartVmb()
    NpOpen(true)
    Res("- Notepad: " . G.NpKind . "`n")
    for it in items {
        try {
            switch it {
                case 1: Item1()
                case 4: Item4()
                case 6: Item6()
                case 3: Item3()
                case 2: Item2()
                case 5: Item5()
                case 7: Item7()
                case 8: Item8()
                case 30: Part3()
                case 40: Part4()
                case 50: Part5()
                case 60: Part6()
                default: Log("unknown item " . it)
            }
        } catch as e {
            Log("ITEM " . it . " ERROR: " . e.Message . " (line " . e.Line . ")")
            Res("`n**Item " . it . " stopped by the driver:** " . e.Message . "`n")
            Unexpected("after item " . it . " error")
        }
    }
    Finish()
    G.Done := true
    WriteResults()
    MsgBox("V34 retest done.`nResults: " . G.Results, "V34 retest", "OK Iconi")
}

; ---------------- item 1: record once, replay ten times ----------------
Item1() {
    Res("`n## Retest 1 - record once, replay " . G.Plays . " times`n")
    RecordHelloWorld()
    recText := NpText()
    if recText = "" && !G.UseClip {
        G.UseClip := true
        recText := NpText()
    }
    WinGetPos(&rx, &ry, &rw, &rh, G.Np)
    rows := GridRows()
    Res("`nSteps grid after recording:`n`n" . GridTable(rows) . "`n")
    enters := 0, dbl := 0, clicks := 0
    for r in rows {
        if InStr(r[COL["text"]], "Enter")
            enters++
        if r[COL["action"]] = "Double-click"
            dbl++
        if r[COL["action"]] = "Click"
            clicks++
    }
    Res("- First row action: ``" . (rows.Length ? rows[1][COL["action"]] : "(none)") . "`` (expected Window)`n- Rows with Enter: " . enters
        . " (expected 1); Double-click rows: " . dbl . " (expected 1); plain Click rows: " . clicks . " (expected 1)`n")
    Res("- Notepad text after recording: ``" . Esc(recText) . "`` (expected ``X\nworld``)`n")
    G.HaveMacro := rows.Length > 0
    expect := "X`nworld"
    spots := [[0.40, 0.30, 0.50, 0.55], [0.15, 0.40, 0.35, 0.40], [0.30, 0.05, 0.60, 0.70], [0.55, 0.45, 0.40, 0.45]]
    same := 0, total := 0, secs := []
    Res("`n| Play | Identical | Seconds | Notepad back at recorded spot/size | Notepad text | Status bar |`n|---|---|---|---|---|---|`n")
    loop G.Plays {
        sp := spots[Mod(A_Index - 1, spots.Length) + 1]
        NpClear()
        NpPlace(sp[1], sp[2], sp[3], sp[4])
        p := Play("play " . A_Index)
        txt := NpText()
        WinGetPos(&px, &py, &pw, &ph, G.Np)
        back := Abs(px - rx) <= 10 && Abs(py - ry) <= 10 && Abs(pw - rw) <= 10 && Abs(ph - rh) <= 10
        ok := txt == expect
        same += ok, total++
        secs.Push(p.Secs)
        Res("| " . A_Index . " | " . (ok ? "yes" : "**NO**") . " | " . p.Secs . " | " . (back ? "yes" : "no (" . px . "," . py . " " . pw . "x" . ph
            . " vs " . rx . "," . ry . " " . rw . "x" . rh . ")") . " | ``" . Esc(txt) . "`` | " . Pipe(p.Status) . (p.Note != "" ? " (" . Pipe(p.Note) . ")" : "") . " |`n")
    }
    avg := 0
    for s in secs
        avg += s
    Res("`n**Result: " . same . " of " . total . " identical.** Average play time " . (total ? Round(avg / total, 2) : 0) . " s.`n")
}

; ---------------- item 4: fast typing + Enter in a cell ----------------
Item4() {
    Res("`n## Retest 4 - fast typing + Enter in a cell (5 tries each)`n")
    if !G.HaveMacro
        return Res("Skipped: needs the item 1 macro.`n")
    rWorld := FindRow("Type", "world"), rHello := FindRow("Type", "hello")
    if !rWorld || !rHello
        return Res("Skipped: no Type 'world' / 'hello' row in the grid.`n")
    Res("`n| Try | Cell | Sent | Cell after Enter | Pass | After Ctrl+Z |`n|---|---|---|---|---|---|`n")
    pass := 0
    loop 5 {
        got := EditCellFast(rWorld, "text", "there")
        ok := InStr(got.After, "there") ? 1 : 0
        pass += ok
        Res("| " . A_Index . " | Text / keys, row " . rWorld . " | ``there{Enter}`` | ``" . Esc(got.After) . "`` | " . (ok ? "yes" : "**NO**")
            . " | ``" . Esc(got.Undone) . "`` |`n")
    }
    passW := 0
    loop 5 {
        got := EditCellFast(rHello, "wait", "2")
        ok := RegExMatch(got.After, "^2\s*s") ? 1 : 0
        passW += ok
        Res("| " . A_Index . " | Waits first, row " . rHello . " | ``2{Enter}`` | ``" . Esc(got.After) . "`` | " . (ok ? "yes" : "**NO**")
            . " | ``" . Esc(got.Undone) . "`` |`n")
    }
    Res("`n**Result: Text cell " . pass . " of 5, Waits first cell " . passW . " of 5.** Method: double-click the cell, then ``there{Enter}`` sent as one burst with no key delay.`n")
}

; Double-clicks a cell, sends text + Enter at once, reads the cell, then Ctrl+Z.
EditCellFast(row, key, text) {
    out := {After: "", Undone: ""}
    lv := GridLV()
    rc := CellRect(lv, row, key)
    if !rc
        return (out.After := "(cell not on screen)", out)
    MouseMove(rc.X + rc.W // 2, rc.Y + rc.H // 2), Sleep(300)
    Click(rc.X + rc.W // 2 . " " . rc.Y + rc.H // 2 . " 2"), Sleep(450)
    SetKeyDelay(-1, -1)
    Send(text . "{Enter}")
    SetKeyDelay(45, 25)
    Sleep(700)
    Unexpected("cell edit")
    out.After := GridCell(row, key)
    WinActivate(Editor()), Sleep(150)
    Send("^z"), Sleep(700)
    out.Undone := GridCell(row, key)
    return out
}

; Clicks the row's Text cell (always visible), then Right arrow to the column so the grid scrolls it into view itself.
CellRect(lv, row, key) {
    rc := LvCellScreen(lv, row - 1, COL[key] - 1)
    if rc && OnScreenIn(lv, rc)
        return rc
    SendMessage(0x1014, -10000, 0, lv), Sleep(300)
    rc := LvCellScreen(lv, row - 1, COL[key] - 1)
    if rc && OnScreenIn(lv, rc)
        return rc
    t := LvCellScreen(lv, row - 1, COL["text"] - 1)
    if !t || !OnScreenIn(lv, t)
        return 0
    Click(t.X + t.W // 2 . " " . t.Y + t.H // 2), Sleep(300)
    loop Abs(COL[key] - COL["text"])
        Send(COL[key] > COL["text"] ? "{Right}" : "{Left}"), Sleep(80)
    Sleep(400)
    rc := LvCellScreen(lv, row - 1, COL[key] - 1)
    return rc && OnScreenIn(lv, rc) ? rc : 0
}

; ---------------- item 6: unsaved changes survive a restart ----------------
Item6() {
    Res("`n## Retest 6 - unsaved changes survive closing with X + ending the script`n")
    if !G.HaveMacro
        return Res("Skipped: needs the item 1 macro.`n")
    if !SaveAs(G.Macro)
        return Res("Skipped: could not save the test macro to " . G.Macro . ".`n")
    Res("- Saved test macro: " . G.Macro . "`n- Title after save: ``" . WinGetTitle(Editor()) . "```n")
    for hw in WinGetControlsHwnd(Editor())
        if WinGetClass(hw) = "Button" && ControlGetText(hw) = "Auto-save" {
            if ControlGetChecked(hw)
                PostMessage(0xF5, 0, 0, hw), Sleep(400)
            Res("- Auto-save checkbox (hidden in Easy mode) is now: " . (ControlGetChecked(hw) ? "ON" : "off") . "`n")
        }
    rWorld := FindRow("Type", "world")
    lv := GridLV()
    rc := CellRect(lv, rWorld, "text")
    if !rc
        return Res("Skipped: Text cell not on screen.`n")
    Click(rc.X + rc.W // 2 . " " . rc.Y + rc.H // 2 . " 2"), Sleep(500)
    Send("^a"), Sleep(100)
    Send("there6{Enter}"), Sleep(800)
    title1 := WinGetTitle(Editor()), cell1 := GridCell(rWorld, "text")
    Res("- After editing the Text cell: cell ``" . Esc(cell1) . "``, title ``" . title1 . "`` (expected ``*``)`n")
    WinClose(Editor()), Sleep(2500)
    boxes := VmbBoxes()
    Res("- Closed with the X button: editor visible afterwards = " . (DllCall("IsWindowVisible", "Ptr", WinExist("Visual Macro Blocks V34 ahk_class AutoHotkeyGUI ahk_pid " . G.Pid), "Int") ? "yes" : "no")
        . "; question boxes = " . (boxes = "" ? "none" : boxes) . "`n")
    pid := G.Pid
    Send("^+x")
    if !ProcessWaitClose(pid, 10) {
        ProcessClose(pid)
        Res("- Ctrl+Shift+X did not end the script in 10 s; the driver ended the process.`n")
    } else
        Res("- Ended the script with Ctrl+Shift+X.`n")
    Sleep(800)
    StartVmb()
    Sleep(1500)
    title2 := WinGetTitle(Editor()), status2 := StatusText(), cell2 := GridCell(FindRow("Type", "there6") || rWorld, "text")
    okT := InStr(title2, "*") ? 1 : 0, okS := InStr(status2, "Restored your unsaved changes") ? 1 : 0, okC := InStr(cell2, "there6") ? 1 : 0
    Res("- After restart: title ``" . title2 . "``; status bar ``" . status2 . "``; Text cell ``" . Esc(cell2) . "```n")
    Res("`n**Result: title * " . (okT ? "yes" : "**NO**") . ", status message " . (okS ? "yes" : "**NO**") . ", edit kept " . (okC ? "yes" : "**NO**") . ".**`n")
}

; ---------------- item 3: caption button names ----------------
Item3() {
    Res("`n## Retest 3 - Maximize / Restore / Minimize / Close naming`n")
    NpClose()
    NpOpen(false)
    NpPlace(0.10, 0.15, 0.45, 0.50)
    NewMacro()
    StartRec()
    seq := []
    b := CaptionButtons(G.Np), seq.Push("Maximize")
    ClickAt(b.Max), WaitMinMax(1)
    b := CaptionButtons(G.Np), seq.Push("Restore")
    ClickAt(b.Max), WaitMinMax(0)
    b := CaptionButtons(G.Np), seq.Push("Minimize")
    ClickAt(b.Min), WaitMinMax(-1)
    WinRestore(G.Np), WaitMinMax(0), WinActivate(G.Np), Sleep(800)
    b := CaptionButtons(G.Np), seq.Push("Close")
    ClickAt(b.Close)
    closed := WinWaitClose(G.Np, , 4)
    StopRec()
    if !closed {
        Res("- Notepad did not close after the Close click; a save prompt may be open (answered Don't Save).`n")
        NpForceClose()
    }
    G.Np := 0
    Res("- Caption button spots from: " . b.Src . "`n")
    rows := GridRows()
    Res("`nSteps grid:`n`n" . GridTable(rows) . "`n`n| Clicked | Action | On what | Window |`n|---|---|---|---|`n")
    k := 0, good := 0
    for r in rows {
        if !RegExMatch(r[COL["action"]], "i)click")
            continue
        k++
        want := k <= seq.Length ? seq[k] : "?"
        ok := InStr(r[COL["target"]], want) ? 1 : 0
        good += ok
        Res("| " . want . " | " . Pipe(r[COL["action"]]) . " | " . Pipe(r[COL["target"]]) . (ok ? "" : " **(expected " . want . ")**") . " | " . Pipe(r[COL["window"]]) . " |`n")
    }
    Res("`n**Result: " . good . " of " . seq.Length . " named right** (the driver clicks the real button each time; after Maximize the Restore button sits at the screen's top-right, not the old spot).`n")
}

; ---------------- item 8: Check this PC (Part 1 step 3) ----------------
Item8() {
    Res("`n## Part 1 step 3 - Check this PC`n")
    NpClose()
    help := HelpBtn()
    MouseMove(A_ScreenWidth - 200, A_ScreenHeight - 300)
    PostMessage(0xF5, 0, 0, help)
    if !WinWait("ahk_class #32768", , 3)
        return Res("Skipped: the ? menu did not open.`n")
    Sleep(300)
    Send("{Down 2}{Enter}")
    if !(win := WinWait("Check this PC ahk_class AutoHotkeyGUI ahk_pid " . G.Pid, , 120))
        return Res("FAIL: no Check this PC window within 120 s. Status: ``" . StatusText() . "```n")
    Sleep(500)
    txt := ControlGetText("Edit1", win)
    Res("Result window text (same text the Copy button copies):`n`n``````text`n" . txt . "`n```````n- Status bar: ``" . StatusText() . "```n"
        . "- Notepad left open by the check: " . (WinExist("ahk_exe notepad.exe") ? "yes" : "no") . "`n")
    WinClose(win), Sleep(500)
}

; ---------------- item 2: menu positions ----------------
Item2() {
    Res("`n## Retest 2 - header right-click menu and ? menu positions`n")
    ed := Editor()
    WinActivate(ed), WinMove(520, 380, , , ed), Sleep(800)
    WinGetPos(&ex, &ey, , , ed)
    Res("- Editor moved to " . ex . "," . ey . " (not top-left).`n")
    lv := GridLV(), hdr := 0
    for hw in WinGetControlsHwnd(ed)
        if WinGetClass(hw) = "SysHeader32" && DllCall("GetParent", "Ptr", hw, "Ptr") = lv
            hdr := hw
    cell := LvCellScreen(lv, 0, COL["action"] - 1)
    if !hdr || !cell
        return Res("Skipped: grid header or Action column not found (rows: " . GridRows().Length . ").`n")
    h := Rect(hdr)
    mx := cell.X + cell.W // 2, my := h.Y + h.H // 2
    MouseMove(mx, my), Sleep(400)
    Click("Right")
    m := MenuPos()
    if !m
        Res("- Right-click on the Action title at " . mx . "," . my . ": **no menu opened**.`n")
    else {
        ok := (m.X >= mx - 4 && m.X <= mx + 12 || Abs(m.X + m.W - mx) <= 12) && (m.Y >= my - 4 && m.Y <= my + 12 || Abs(m.Y + m.H - my) <= 12)
        Res("- Right-click on the Action title at " . mx . "," . my . ": menu at " . m.X . "," . m.Y . " (" . m.W . "x" . m.H . "). "
            . (ok ? "**PASS** (under the mouse)" : "**FAIL** (not at the mouse)") . "`n")
        CloseMenus()
    }
    help := HelpBtn(), b := Rect(help)
    MouseMove(A_ScreenWidth - 200, A_ScreenHeight - 300), Sleep(300)
    PostMessage(0xF5, 0, 0, help)
    m := MenuPos()
    if !m
        return Res("- ? button: **no menu opened**.`n")
    ok := Abs(m.Y - (b.Y + b.H)) <= 6 && m.X >= b.X - 230 && m.X <= b.X + 6
    Res("- ? button at " . b.X . "," . b.Y . " (" . b.W . "x" . b.H . "), mouse parked far away at " . (A_ScreenWidth - 200) . "," . (A_ScreenHeight - 300)
        . ": menu at " . m.X . "," . m.Y . " (" . m.W . "x" . m.H . "). " . (ok ? "**PASS** (just under the button)" : "**FAIL**") . "`n")
    CloseMenus()
}

CloseMenus() {
    loop 3 {
        if !WinExist("ahk_class #32768")
            return
        Send("{Esc}"), Sleep(300)
        PostMessage(0x1F, 0, 0, , Editor())     ; WM_CANCELMODE
        WinWaitClose("ahk_class #32768", , 1)
    }
    Res("- (a menu window was still open after 3 tries to close it)`n")
}

MenuPos() {
    if !(hw := WinWait("ahk_class #32768", , 3))
        return 0
    Sleep(300)
    WinGetPos(&x, &y, &w, &h, hw)
    return {X: x, Y: y, W: w, H: h}
}

HelpBtn() {
    for hw in WinGetControlsHwnd(Editor())
        if WinGetClass(hw) = "Button" && ControlGetText(hw) = "?" && ControlGetVisible(hw)
            return hw
    throw Error("? button not found.")
}

; ---------------- item 5: Ready to play? with Notepad closed, Easy mode ----------------
Item5() {
    Res("`n## Retest 5 - Ready to play? with Notepad closed (Easy mode)`n")
    title := WinGetTitle(Editor())
    Res("- Easy mode: " . (InStr(title, " Easy") ? "yes" : "**no**") . " (title ``" . title . "``)`n")
    if !G.Np || !WinExist(G.Np)
        NpOpen(false)
    NpPlace(0.10, 0.15, 0.40, 0.45)
    NpClear()
    NewMacro()
    StartRec()
    ed := NpEditRect()
    MouseMove(ed.X + ed.W // 2, ed.Y + ed.H // 2), Sleep(500)
    Click(), Sleep(400)
    Send("test"), Sleep(600)
    StopRec()
    Res("`nRecorded:`n`n" . GridTable(GridRows()) . "`n")
    NpClose()
    WinActivate(Editor()), Sleep(300)
    Btn("&Play")
    if box := WaitBox("Ready to play?", 6000) {
        txt := WinGetText(box)
        BoxBtn(box, "&No")
        Res("- Box text: ``" . Flat(txt) . "```n- Names Notepad: " . (InStr(txt, "notepad") ? "**PASS**" : "**FAIL**") . ". Answered No.`n")
    } else {
        if WinExist("run bar ahk_pid " . G.Pid)
            Send("{Esc}")
        Res("- **FAIL: no Ready to play? box** (Esc sent if it started). Status: ``" . StatusText() . "```n")
    }
    Sleep(800)
    Res("- Status bar after: ``" . StatusText() . "```n")
}

; ---------------- item 7: emergency exit (V34.1) ----------------
Item7() {
    Res("`n## Retest V34.1 - emergency exit (Ctrl+Shift+X)`n`n| Try | Situation | Title before | Seconds until process gone | Ctrl/Shift stuck after |`n|---|---|---|---|---|`n")
    loop 5 {
        EnsureVmb()
        AutoSaveOff()
        r := FirstTypeRow()
        rc := r ? CellRect(GridLV(), r, "text") : 0
        if rc {
            Click(rc.X + rc.W // 2 . " " . rc.Y + rc.H // 2 . " 2"), Sleep(500)
            Send("^a"), Sleep(100)
            Send("abc" . A_Index . "{Enter}"), Sleep(800)
        }
        title := WinGetTitle(Editor())
        WinClose(Editor()), Sleep(2500)
        p := PanicTime()
        Res("| " . A_Index . " | edited cell, closed with X, 2.5 s | ``" . title . "`` | " . p.Text . " | " . p.Stuck . " |`n")
    }
    EnsureVmb()
    if !G.Np || !WinExist(G.Np)
        NpOpen(false)
    WinActivate(Editor()), Sleep(300)
    Btn("&Play")
    t0 := A_TickCount
    while !WinExist("run bar ahk_pid " . G.Pid) && A_TickCount - t0 < 8000 {
        if box := WinExist("Ready to play? ahk_pid " . G.Pid)
            BoxBtn(box, "&Yes")
        Sleep(50)
    }
    playing := WinExist("run bar ahk_pid " . G.Pid) ? "playing" : "run bar not seen"
    Sleep(1000)
    p := PanicTime()
    Res("| P | while playing (" . playing . ") | - | " . p.Text . " | " . p.Stuck . " |`n")
    EnsureVmb()
    StartRec()
    Sleep(1000)
    p := PanicTime()
    Res("| R | while recording | - | " . p.Text . " | " . p.Stuck . " |`n")
    Sleep(500)
    Res("- REC bar left on screen after: " . (WinExist("Visual Macro Blocks REC") ? "**yes**" : "no") . "`n")
}

PanicTime() {
    pid := G.Pid
    t0 := A_TickCount
    Send("^+x")
    ProcessWaitClose(pid, 10)
    secs := Round((A_TickCount - t0) / 1000, 2)
    alive := ProcessExist(pid)
    if alive
        ProcessClose(pid)
    Sleep(300)
    stuck := (GetKeyState("Ctrl") ? "Ctrl " : "") . (GetKeyState("Shift") ? "Shift" : "")
    return {Text: alive ? "**still running after 10 s** (driver ended it)" : secs . (secs < 1 ? "" : " **(over 1 s)**"), Stuck: stuck = "" ? "no" : "**" . stuck . "**"}
}

EnsureVmb() {
    if !G.Pid || !ProcessExist(G.Pid)
        StartVmb()
    WinActivate(Editor()), Sleep(300)
}

AutoSaveOff() {
    for hw in WinGetControlsHwnd(Editor())
        if WinGetClass(hw) = "Button" && ControlGetText(hw) = "Auto-save" && ControlGetChecked(hw)
            PostMessage(0xF5, 0, 0, hw), Sleep(400)
}

FirstTypeRow() {
    for i, r in GridRows()
        if r[COL["action"]] = "Type"
            return i
    return 0
}

; ---------------- Part 3: scroll position ----------------
Part3() {
    Res("`n## Part 3 - scroll position`n")
    NpClose(), NpOpen(false), NpPlace(0.05, 0.08, 0.40, 0.55)
    Res("- Word Wrap: " . WordWrapOff() . "`n")
    txt := ""
    loop 300
        txt .= "line " . A_Index . "`r`n"
    saved := ClipboardAll()
    A_Clipboard := txt
    ClipWait(2)
    NpClear()
    Send("^v"), Sleep(800)
    A_Clipboard := saved
    e := NpEdit()
    SendMessage(0xB6, 0, -10000, e), SendMessage(0xB6, 0, 149, e), Sleep(300)
    first := SendMessage(0xCE, 0, 0, e) + 1
    Res("- 300 lines pasted; top line before recording: " . first . "`n")
    NewMacro()
    StartRec()
    p := LinePoint(e, first + 3)
    MouseMove(p.X, p.Y), Sleep(500)
    Click(), Sleep(500)
    Send("X"), Sleep(700)
    StopRec()
    recLine := XLine()
    rows := GridRows(), scroll := "(no Click row)"
    for r in rows
        if r[COL["action"]] = "Click"
            scroll := r[COL["scroll"]]
    Res("`n" . GridTable(rows) . "`n- **Scroll back** cell of the Click row: ``" . scroll . "`` (expected like ``row 150``)`n- X typed on: " . recLine . "`n")
    WinActivate(G.Np), Sleep(200)
    Send("^z"), Sleep(400)
    SendMessage(0xB6, 0, -10000, e), Sleep(300)
    Res("- After undo + scroll to top: X present = " . (XLine() = "none" ? "no" : "yes") . ", top line " . (SendMessage(0xCE, 0, 0, e) + 1) . "`n")
    pl := Play("part 3")
    playLine := XLine()
    Res("- After Play: X on " . playLine . "; top line " . (SendMessage(0xCE, 0, 0, e) + 1) . "; status ``" . pl.Status . "``" . (pl.Note != "" ? " (" . pl.Note . ")" : "")
        . "`n`n**Result: " . (playLine = recLine ? "PASS" : "FAIL") . "** (same line as when recording: " . recLine . ")`n")
    NpClear()
}

XLine() {
    for i, l in StrSplit(NpText(), "`n")
        if InStr(l, "X", true)
            return "line " . i . " (``" . l . "``)"
    return "none"
}

LinePoint(e, line0) {
    idx := SendMessage(0xBB, line0, 0, e)
    pos := SendMessage(0xD6, idx, 0, e)
    pt := Buffer(8, 0)
    NumPut("Int", pos & 0xFFFF, pt, 0), NumPut("Int", (pos >> 16) & 0xFFFF, pt, 4)
    DllCall("ClientToScreen", "Ptr", e, "Ptr", pt)
    return {X: NumGet(pt, 0, "Int") + 25, Y: NumGet(pt, 4, "Int") + 7}
}

MenuText(hm, i) {
    buf := Buffer(512, 0)
    DllCall("GetMenuStringW", "Ptr", hm, "UInt", i, "Ptr", buf, "Int", 255, "UInt", 0x400)
    return StrGet(buf, "UTF-16")
}

MenuFind(hm, word) {
    loop DllCall("GetMenuItemCount", "Ptr", hm, "Int")
        if InStr(StrReplace(MenuText(hm, A_Index - 1), "&"), word)
            return A_Index - 1
    return -1
}

WordWrapOff() {
    hm := DllCall("GetMenu", "Ptr", G.Np, "Ptr")
    if !hm || (fi := MenuFind(hm, "Format")) < 0
        return "no Format menu (not changed)"
    sub := DllCall("GetSubMenu", "Ptr", hm, "Int", fi, "Ptr")
    if (wi := MenuFind(sub, "Word Wrap")) < 0
        return "no Word Wrap item (not changed)"
    if DllCall("GetMenuState", "Ptr", sub, "UInt", wi, "UInt", 0x400, "UInt") & 8 {
        MenuSelect(G.Np, , "Format", "Word Wrap"), Sleep(400)
        return "was on, turned off"
    }
    return "off"
}

MenuItemCenter(owner, hm, i) {
    rc := Buffer(16, 0)
    loop 10 {
        if DllCall("GetMenuItemRect", "Ptr", owner, "Ptr", hm, "UInt", i, "Ptr", rc) && NumGet(rc, 8, "Int") > NumGet(rc, 0, "Int")
            return {X: (NumGet(rc, 0, "Int") + NumGet(rc, 8, "Int")) // 2, Y: (NumGet(rc, 4, "Int") + NumGet(rc, 12, "Int")) // 2}
        Sleep(100)
    }
    return 0
}

; ---------------- Part 4: what the grid knows about a click ----------------
Part4() {
    Res("`n## Part 4 - what the grid knows about a click`n")
    NpClose(), NpOpen(false), NpPlace(0.10, 0.15, 0.45, 0.50)
    WordWrapOff()
    NewMacro()
    StartRec()
    done := []
    hm := DllCall("GetMenu", "Ptr", G.Np, "Ptr")
    ei := hm ? MenuFind(hm, "Edit") : -1
    if ei >= 0 && (p := MenuItemCenter(G.Np, hm, ei)) {
        ClickAt(p), done.Push("Edit menu")
        sub := DllCall("GetSubMenu", "Ptr", hm, "Int", ei, "Ptr")
        gi := MenuFind(sub, "Go To")
        if gi >= 0 && WinWait("ahk_class #32768", , 2) && (q := MenuItemCenter(0, sub, gi)) {
            ClickAt(q), done.Push("Go To...")
            if dlg := WinWait("ahk_class #32770 ahk_pid " . G.NpPid, , 4) {
                Sleep(500)
                for hw in WinGetControlsHwnd(dlg)
                    if WinGetClass(hw) = "Button" && ControlGetText(hw) = "Cancel" {
                        r := Rect(hw)
                        ClickAt({X: r.X + r.W // 2, Y: r.Y + r.H // 2}), done.Push("Cancel")
                        break
                    }
                WinWaitClose(dlg, , 3)
            }
        } else
            Send("{Esc}"), Sleep(300)
    }
    b := CaptionButtons(G.Np)
    ClickAt(b.Max), WaitMinMax(1), done.Push("Maximize")
    b := CaptionButtons(G.Np)
    ClickAt(b.Max), WaitMinMax(0), done.Push("Restore")
    StopRec()
    Res("- Clicked, in order: " . JoinArr(done) . "`n`n| Clicked | Action | On what | Window |`n|---|---|---|---|`n")
    k := 0
    for r in GridRows() {
        if !RegExMatch(r[COL["action"]], "i)click")
            continue
        k++
        Res("| " . (k <= done.Length ? done[k] : "?") . " | " . Pipe(r[COL["action"]]) . " | " . Pipe(r[COL["target"]]) . " | " . Pipe(r[COL["window"]]) . " |`n")
    }
}

; ---------------- Part 5: the grid as a spreadsheet ----------------
Part5() {
    Res("`n## Part 5 - the grid as a spreadsheet`n")
    if !G.Np || !WinExist(G.Np)
        NpOpen(false)
    RecordHelloWorld()
    path := "C:\Temp\vmb\part5-notepad.vmacro.json"
    Res("- Setup: re-recorded the Part 2 macro (Click, hello, Enter, world, Double-click, X) and saved it as " . path . ": "
        . (SaveAs(path) ? "saved" : "**save failed**") . "`n`n| # | Check | Result | What happened |`n|---|---|---|---|`n")
    WinActivate(Editor()), WinMove(200, 150, , , Editor()), Sleep(600)
    steps := [P5_Zoom, P5_Cursor, P5_Wait, P5_TextPlay, P5_Clicks, P5_Sort, P5_Filter, P5_HeadFilter, P5_Find, P5_RowMove,
        P5_Range, P5_RowMenu, P5_HeadMenu, P5_Sideways, P5_ListGrid, P5_Restart]
    for i, fn in steps {
        try {
            r := fn()
        } catch as e {
            r := {Ok: false, Name: fn.Name, Text: "driver error: " . e.Message}
            CloseMenus()
            try WinActivate(Editor())
        }
        Res("| " . i . " | " . r.Name . " | " . (r.Ok = "skip" ? "SKIP" : r.Ok ? "PASS" : "**FAIL**") . " | " . Pipe(r.Text) . " |`n")
        Log("Part 5." . i . " " . r.Name . ": " . (r.Ok = "skip" ? "skip" : r.Ok ? "pass" : "FAIL") . " - " . r.Text)
    }
}

RecordHelloWorld() {
    NpPlace(0.05, 0.10, 0.45, 0.50)
    NpClear()
    NewMacro()
    StartRec()
    ed := NpEditRect()
    MouseMove(ed.X + ed.W // 2, ed.Y + ed.H // 2), Sleep(500)
    Click(), Sleep(500)
    hello := {X: ed.X + 22, Y: ed.Y + 14}
    if CaretGetPos(&cx, &cy)
        hello := {X: cx + 14, Y: cy + 8}
    Send("hello"), Sleep(350)
    Send("{Enter}"), Sleep(350)
    Send("world"), Sleep(500)
    MouseMove(hello.X, hello.Y), Sleep(500)
    Click(hello.X . " " . hello.Y . " 2"), Sleep(500)
    Send("X"), Sleep(700)
    StopRec()
}

ClickCell(row, key, count := 1, button := "L") {
    rc := CellRect(GridLV(), row, key)
    if !rc
        throw Error("cell " . key . " of row " . row . " not on screen")
    MouseMove(rc.X + rc.W // 2, rc.Y + rc.H // 2), Sleep(250)
    Click(rc.X + rc.W // 2 . " " . rc.Y + rc.H // 2 . " " . button . " " . count), Sleep(450)
    return rc
}

Undo() {
    WinActivate(Editor()), Sleep(150)
    Send("^z"), Sleep(700)
}

BarCtl(cls, readOnly) {
    gr := Rect(GridLV()), best := 0, bestD := 99999
    for hw in WinGetControlsHwnd(Editor()) {
        if WinGetClass(hw) != cls || !ControlGetVisible(hw) || ((ControlGetStyle(hw) & 0x800) ? 1 : 0) != readOnly
            continue
        r := Rect(hw), d := gr.Y - (r.Y + r.H)
        if d >= -2 && d < 80 && d < bestD
            best := hw, bestD := d
    }
    return best
}

NameBox() {
    hw := BarCtl("Edit", 1)
    return hw ? ControlGetText(hw) : "(no name box)"
}

ZoomText() {
    for hw in WinGetControlsHwnd(Editor())
        if WinGetClass(hw) = "Button" && ControlGetVisible(hw) && RegExMatch(ControlGetText(hw), "^\d+%$")
            return ControlGetText(hw)
    return "(no zoom box)"
}

VisibleLV(cols) {
    for hw in WinGetControlsHwnd(Editor())
        if WinGetClass(hw) = "SysListView32" && ControlGetVisible(hw) && ListViewGetContent("Count Col", hw) = cols
            return hw
    return 0
}

Actions() {
    out := []
    for r in GridRows()
        out.Push(r[COL["action"]])
    return out
}

P5_Zoom() {
    z0 := ZoomText()
    ClickCell(3, "text")
    gr := Rect(GridLV())
    MouseMove(gr.X + gr.W // 2, gr.Y + gr.H // 2), Sleep(200)
    Send("^{WheelUp}"), Sleep(400), Send("^{WheelUp}"), Sleep(600)
    z1 := ZoomText()
    Send("^{WheelDown}"), Sleep(600)
    z2 := ZoomText()
    Send("^0"), Sleep(600)
    z3 := ZoomText()
    return {Name: "Zoom (Ctrl+wheel, Ctrl+0)", Ok: z1 != z0 && z3 = "100%", Text: z0 . " -> 2x Ctrl+wheel up " . z1 . " -> wheel down " . z2 . " -> Ctrl+0 " . z3}
}

P5_Cursor() {
    ClickCell(3, "text")
    n1 := NameBox()
    Send("{Right}"), Sleep(300)
    n2 := NameBox()
    Send("{Down}"), Sleep(300)
    n3 := NameBox()
    return {Name: "Cell cursor + arrow keys", Ok: n1 != n2 && n2 != n3, Text: "Name box: click Text row 3 = '" . n1 . "', Right = '" . n2 . "', Down = '" . n3
        . "'. Green border colour not checked (needs eyes)."}
}

P5_Wait() {
    r := EditCellFast(FindRow("Type", "hello"), "wait", "2")
    return {Name: "Edit Waits first = 2", Ok: RegExMatch(r.After, "^2\s*s\*") && r.Undone != r.After, Text: "after Enter '" . r.After . "', after Ctrl+Z '" . r.Undone . "'"}
}

P5_TextPlay() {
    row := FindRow("Type", "world")
    ClickCell(row, "text", 2)
    Send("^a"), Sleep(100), Send("there{Enter}"), Sleep(700)
    cell := GridCell(row, "text")
    NpClear()
    pl := Play("part 5.4")
    txt := NpText()
    Undo()
    back := GridCell(row, "text")
    return {Name: "Edit Text world -> there, Play", Ok: txt == "X`nthere" && InStr(back, "world"), Text: "cell '" . cell . "', Notepad '" . Esc(txt) . "', status '"
        . Trim(pl.Status) . "', after Ctrl+Z '" . back . "'"}
}

P5_Clicks() {
    row := 0
    for i, r in GridRows()
        if r[COL["action"]] = "Click" && !row
            row := i
    ClickCell(row, "clicks", 2)
    Sleep(300)
    Send("2"), Sleep(200), Send("{Enter}"), Sleep(700)
    act := GridCell(row, "action"), cl := GridCell(row, "clicks")
    Undo()
    back := GridCell(row, "action")
    return {Name: "Clicks drop-down = 2", Ok: act = "Double-click" && back = "Click", Text: "row " . row . ": Clicks '" . cl . "', Action '" . act . "', after Ctrl+Z '" . back . "'"}
}

P5_Sort() {
    lv := GridLV(), hdr := SendMessage(0x101F, 0, 0, lv)
    c := LvCellScreen(lv, 0, COL["action"] - 1), h := Rect(hdr)
    MouseMove(c.X + 15, h.Y + h.H // 2), Sleep(300)
    Click(), Sleep(800)
    a := Actions(), sorted := true
    loop a.Length - 1
        if StrCompare(a[A_Index], a[A_Index + 1]) > 0
            sorted := false
    Btn("Step order"), Sleep(600)
    nums := "", inOrder := true
    for i, r in GridRows()
        nums .= r[1] . " ", inOrder := inOrder && r[1] = i
    return {Name: "Sort by Action, then Step order", Ok: sorted && inOrder, Text: "after header click: " . JoinArr(a) . " | after Step order: # " . Trim(nums)}
}

P5_Filter() {
    f := BarCtl("Edit", 0)
    if !f
        return {Name: "Filter box 'type'", Ok: false, Text: "filter box not found"}
    r := Rect(f)
    ClickAt({X: r.X + r.W // 2, Y: r.Y + r.H // 2})
    Send("type"), Sleep(900)
    a := Actions(), allType := a.Length > 0
    for v in a
        allType := allType && v = "Type"
    Btn("Clear"), Sleep(600)
    n := GridRows().Length
    return {Name: "Filter box 'type', Clear", Ok: allType && n > a.Length, Text: "rows shown: " . JoinArr(a) . " | after Clear: " . n . " rows"}
}

P5_HeadFilter() {
    fz := VisibleLV(2), note := ""
    if fz {
        pop := OpenArrow(fz, 1)
        note := "Action arrow (frozen pane): " . (pop ? "tick list opened" : "**no tick list** (" . G.ArrowNote . ")") . ". "
        if pop
            BoxBtn(pop, "Cancel"), Sleep(400)
    }
    lv := GridLV()
    SendMessage(0x1014, -10000, 0, lv), Sleep(300)
    pop := OpenArrow(lv, COL["target"] - 1)
    if !pop
        return {Name: "Header filter arrow", Ok: false, Text: note . "On what arrow (main grid): no tick list either (" . G.ArrowNote . ")"}
    plv := 0
    for hw in WinGetControlsHwnd(pop)
        if WinGetClass(hw) = "SysListView32"
            plv := hw
    items := StrSplit(ListViewGetContent("", plv), "`n", "`r"), idx := 0, want := "a text box"
    for i, t in items
        if t = want
            idx := i
    if !idx {
        BoxBtn(pop, "Cancel")
        return {Name: "Header filter arrow", Ok: false, Text: note . "On what tick list: " . JoinArr(items) . " (no '" . want . "')"}
    }
    ControlFocus(plv), Sleep(150)
    Send("{Home}"), Sleep(100)
    loop idx - 1
        Send("{Down}"), Sleep(60)
    Send("{Space}"), Sleep(300)
    BoxBtn(pop, "OK"), Sleep(800)
    a := Actions(), gone := true
    for v in a
        gone := gone && !InStr(v, "Click")
    Btn("Clear"), Sleep(600)
    n := GridRows().Length
    return {Name: "Header filter arrow (On what: untick 'a text box')", Ok: gone && n > a.Length, Text: note . "On what tick list: " . JoinArr(items)
        . " | after OK: " . JoinArr(a) . " | after Clear: " . n . " rows"}
}

OpenArrow(lv, col0) {
    hdr := SendMessage(0x101F, 0, 0, lv)
    c := LvCellScreen(lv, 0, col0), h := Rect(hdr)
    if !c
        return 0
    before := WinGetList("ahk_pid " . G.Pid)
    MouseMove(c.X + c.W - 14, h.Y + h.H // 2), Sleep(300)
    Click()
    t0 := A_TickCount
    while A_TickCount - t0 < 1500 {
        for w in WinGetList("ahk_pid " . G.Pid) {
            isNew := true
            for o in before
                isNew := isNew && o != w
            if isNew && WinGetClass(w) != "tooltips_class32"
                return w
        }
        Sleep(50)
    }
    G.ArrowNote := "status after click '" . Trim(StatusText()) . "'"
    return 0
}

P5_Find() {
    ClickCell(1, "text")
    Send("^f"), Sleep(600)
    Send("world"), Sleep(200), Send("{Enter}"), Sleep(700)
    n := NameBox(), st := StatusText()
    Send("{Esc}"), Sleep(400)
    row := FindRow("Type", "world")
    return {Name: "Find (Ctrl+F world Enter, Esc)", Ok: InStr(n, String(row)) > 0, Text: "Name box '" . n . "' (world is row " . row . "), status '" . Trim(st) . "'"}
}

P5_RowMove() {
    row := FindRow("Type", "hello")
    ClickCell(row, "app")
    Send("!{Down}"), Sleep(800)
    moved := InStr(GridCell(row + 1, "text"), "hello")
    Undo()
    back := InStr(GridCell(row, "text"), "hello")
    return {Name: "Alt+Down moves the row, Ctrl+Z", Ok: moved && back, Text: "hello row " . row . " -> " . (moved ? row + 1 : "not moved") . "; after Ctrl+Z back at " . row . ": " . (back ? "yes" : "no")}
}

P5_Range() {
    before := []
    for r in GridRows()
        before.Push(r[COL["wait"]])
    ClickCell(2, "wait")
    Send("+{Down 2}"), Sleep(500)
    st := StatusText()
    Send("{Delete}"), Sleep(700)
    st2 := StatusText()
    mid := GridCell(2, "wait") . "/" . GridCell(3, "wait") . "/" . GridCell(4, "wait")
    orig := before[2] . "/" . before[3] . "/" . before[4]
    if mid = orig {
        Send("{Esc}"), Sleep(300)
        return {Name: "Range Shift+Down x2, Delete, Ctrl+Z", Ok: InStr(st2, "recorded") ? true : false, Text: "status '" . Trim(st) . "'; Waits rows 2-4: " . orig . " -> after Delete unchanged " . mid
            . "; status after Delete '" . Trim(st2) . "' (Ctrl+Z not pressed, so the recording is not undone)"}
    }
    Undo()
    after := GridCell(2, "wait") . "/" . GridCell(3, "wait") . "/" . GridCell(4, "wait")
    return {Name: "Range Shift+Down x2, Delete, Ctrl+Z", Ok: InStr(st, "3") && mid != orig && after = orig, Text: "status '" . Trim(st) . "'; Waits rows 2-4: " . orig . " -> Delete " . mid . " -> Ctrl+Z " . after}
}

P5_RowMenu() {
    ClickCell(3, "app", 1, "R")
    items := MenuItems()
    CloseMenus()
    ok := InStr(items, "Insert") && InStr(items, "Duplicate") && InStr(items, "Delete") && InStr(items, "Move")
    return {Name: "Right-click a row: menu", Ok: ok ? true : false, Text: items = "" ? "no menu" : items}
}

P5_HeadMenu() {
    lv := GridLV(), hdr := SendMessage(0x101F, 0, 0, lv)
    c := LvCellScreen(lv, 0, COL["target"] - 1), h := Rect(hdr)
    MouseMove(c.X + 20, h.Y + h.H // 2), Sleep(300)
    Click("Right"), Sleep(300)
    items := MenuItems()
    CloseMenus()
    return {Name: "Right-click a column title: column list", Ok: InStr(items, "Action") && InStr(items, "Waits first") ? true : false, Text: items = "" ? "no menu" : SubStr(items, 1, 400)}
}

MenuItems() {
    if !(mw := WinWait("ahk_class #32768", , 3))
        return ""
    Sleep(300)
    hm := SendMessage(0x1E1, 0, 0, mw)
    out := ""
    loop DllCall("GetMenuItemCount", "Ptr", hm, "Int") {
        t := MenuText(hm, A_Index - 1)
        if t != ""
            out .= (out = "" ? "" : " / ") . StrReplace(t, "`t", " ")
    }
    return out
}

P5_Sideways() {
    lv := GridLV(), gr := Rect(lv)
    SendMessage(0x1014, 4000, 0, lv), Sleep(700)
    numCell := LvCellScreen(lv, 0, 0) || {X: "?"}
    fz := VisibleLV(2), fr := fz ? Rect(fz) : 0
    content := fz ? StrSplit(ListViewGetContent("", fz), "`n", "`r") : []
    SendMessage(0x1014, -8000, 0, lv), Sleep(500)
    ok := fz && fr.X <= gr.X + 4 && numCell.X < gr.X && content.Length
    return {Name: "Sideways scroll keeps # and Action", Ok: ok ? true : false, Text: "grid scrolled (main # column now at x=" . numCell.X . ", grid left " . gr.X . "); frozen pane "
        . (fz ? "visible at x=" . fr.X . " w=" . fr.W . ", first row '" . (content.Length ? StrReplace(content[1], "`t", " | ") : "") . "'" : "not found")}
}

P5_ListGrid() {
    lb := 0, gb := 0
    for hw in WinGetControlsHwnd(Editor())
        if WinGetClass(hw) = "Button" && ControlGetVisible(hw) && Rect(hw).W < 60 {
            t := ControlGetText(hw)
            lb := t = "List" ? hw : lb, gb := t = "Grid" ? hw : gb
        }
    if !lb || !gb
        return {Name: "List view, then Grid", Ok: false, Text: "List / Grid buttons not found"}
    n := GridRows().Length
    PostMessage(0xF5, 0, 0, lb), Sleep(800)
    tv := 0
    for hw in WinGetControlsHwnd(Editor())
        if WinGetClass(hw) = "SysTreeView32" && ControlGetVisible(hw)
            tv := hw
    cnt := tv ? SendMessage(0x1105, 0, 0, tv) : -1
    PostMessage(0xF5, 0, 0, gb), Sleep(800)
    n2 := GridRows().Length
    return {Name: "List view, then Grid", Ok: tv && cnt = n && n2 = n, Text: "grid rows " . n . "; List view tree items " . cnt . "; back in Grid " . n2 . " rows"}
}

P5_Restart() {
    ClickCell(3, "text")
    Send("^="), Sleep(600)
    z := ZoomText(), lv := GridLV(), w1 := ""
    loop 8
        w1 .= SendMessage(0x101D, A_Index - 1, 0, lv) . " "
    rows1 := ListViewGetContent("", lv)
    WinClose(Editor()), Sleep(2000)
    pid := G.Pid
    Send("^+x")
    ProcessWaitClose(pid, 5)
    if ProcessExist(pid)
        ProcessClose(pid)
    StartVmb()
    WinActivate(Editor()), WinMove(200, 150, , , Editor()), Sleep(800)
    z2 := ZoomText(), lv := GridLV(), w2 := ""
    loop 8
        w2 .= SendMessage(0x101D, A_Index - 1, 0, lv) . " "
    rows2 := ListViewGetContent("", lv), same := rows2 == rows1, diff := ""
    if !same {
        a1 := StrSplit(rows1, "`n", "`r"), a2 := StrSplit(rows2, "`n", "`r")
        loop Min(a1.Length, a2.Length) {
            c1 := StrSplit(a1[A_Index], "`t"), c2 := StrSplit(a2[A_Index], "`t")
            loop Min(c1.Length, c2.Length)
                if c1[A_Index] != c2[A_Index] && StrLen(diff) < 300
                    diff .= " [col " . A_Index . ": '" . c1[A_Index] . "' -> '" . c2[A_Index] . "']"
        }
        diff := " rows " . a1.Length . " -> " . a2.Length . ";" . diff
    }
    ClickCell(3, "text"), Send("^0"), Sleep(500)
    return {Name: "Restart keeps zoom, widths, macro", Ok: z2 = z && w2 = w1 && same, Text: "zoom " . z . " -> " . z2 . "; widths of first 8 columns " . Trim(w1) . " -> " . Trim(w2)
        . "; grid text identical: " . (same ? "yes" : "no:" . diff) . "; title '" . WinGetTitle(Editor()) . "'. (Closed with X, then Ctrl+Shift+X, then started with --data.)"}
}

; ---------------- Part 6: repeat for a list ----------------
Part6() {
    Res("`n## Part 6 - repeat for a list`n")
    if !G.Np || !WinExist(G.Np)
        NpOpen(false)
    NpPlace(0.05, 0.10, 0.45, 0.50)
    NpClear()
    NewMacro()
    StartRec()
    ed := NpEditRect()
    MouseMove(ed.X + ed.W // 2, ed.Y + ed.H // 2), Sleep(500)
    Click(), Sleep(500)
    Send("Smith"), Sleep(350), Send("{Tab}"), Sleep(350), Send("250"), Sleep(350), Send("{Enter}"), Sleep(700)
    StopRec()
    Res("`nRecorded:`n`n" . GridTable(GridRows()) . "`n")
    SheetTab("List")
    saved := ClipboardAll()
    A_Clipboard := "Name`tAmount`r`nSmith`t250`r`nJones`t75`r`nLee`t5`r`n"
    ClipWait(2)
    Btn("Paste list")
    A_Clipboard := saved
    if box := WaitBox("use the list columns", 4000) {
        Res("- Question: ``" . Flat(WinGetText(box)) . "`` -> Yes`n")
        BoxBtn(box, "&Yes")
    } else
        Res("- **No question about the list columns appeared.**`n")
    Sleep(800)
    Res("- Status after paste: ``" . StatusText() . "```n")
    SheetTab("Steps")
    texts := []
    for r in GridRows()
        if r[COL["action"]] = "Type"
            texts.Push(r[COL["text"]])
    Res("- Type rows' Text cells: ``" . JoinArr(texts) . "`` (expected ``=Name → 'Smith'``, ``=Amount → '250'``)`n")
    radio := 0
    for hw in WinGetControlsHwnd(Editor())
        if WinGetClass(hw) = "Button" && ControlGetVisible(hw) && InStr(ControlGetText(hw), "for each row of the List")
            radio := hw
    if !radio
        return Res("- **Run: for each row of the List** not found; stopped here.`n")
    rtext := ControlGetText(radio)
    PostMessage(0xF5, 0, 0, radio), Sleep(600)
    Res("- Run switch: ``" . rtext . "`` chosen = " . (ControlGetChecked(radio) ? "yes" : "**no**") . "`n")
    NpClear()
    pl := Play("part 6 list run")
    t1 := NpText()
    want := "Smith`t250`nJones`t75`nLee`t5`n"
    Res("- Notepad after the list run: ``" . Esc(t1) . "`` (expected ``Smith\t250\nJones\t75\nLee\t5\n``): " . (t1 == want ? "**PASS**" : "**FAIL**")
        . "`n- Status: ``" . Trim(pl.Status) . "``" . (pl.Note != "" ? " (" . pl.Note . ")" : "") . "`n")
    SheetTab("List")
    llv := VisibleLVAny()
    Res("- List sheet after the run (# / Result / Name / Amount):`n`n``````text`n" . (llv ? ListViewGetContent("", llv) : "(list not found)") . "`n```````n")
    SheetTab("Steps")
    row := FindRow("Type", "Amount")
    if !row
        return Res("- No =Amount Type row; Only when not tested.`n")
    ClickCell(row, "when", 2)
    Send("^a"), Sleep(100), Send("Amount > 100{Enter}"), Sleep(800)
    Res("- Only when cell of row " . row . ": ``" . GridCell(row, "when") . "``; status ``" . Trim(StatusText()) . "```n")
    NpClear()
    pl := Play("part 6 only when")
    t2 := NpText()
    want2 := "Smith`t250`nJones`t`nLee`t`n"
    Res("- Notepad after the run with Only when: ``" . Esc(t2) . "`` (expected the amount only on the Smith line): "
        . (t2 == want2 ? "**PASS**" : "check") . "`n- Status: ``" . Trim(pl.Status) . "```n")
    NpClear()
}

SheetTab(name) {
    for hw in WinGetControlsHwnd(Editor())
        if WinGetClass(hw) = "Button" && ControlGetVisible(hw) && Rect(hw).W >= 80 && RegExMatch(ControlGetText(hw), "^" . name . "( \(\d+\))?$") {
            PostMessage(0xF5, 0, 0, hw)
            return Sleep(700)
        }
    throw Error("Sheet tab not found: " . name)
}

VisibleLVAny() {
    for hw in WinGetControlsHwnd(Editor())
        if WinGetClass(hw) = "SysListView32" && ControlGetVisible(hw) && ListViewGetContent("Count Col", hw) != 25 && ListViewGetContent("Count Col", hw) != 2
            return hw
    return 0
}

; ---------------- VMB helpers ----------------
StartVmb() {
    Run('"' . A_AhkPath . '" "' . G.Vmb . '" --data "' . G.Data . '"', G.Dir, , &pid)
    G.Pid := pid
    if !WinWait("Visual Macro Blocks V34 ahk_class AutoHotkeyGUI ahk_pid " . pid, , 30)
        throw Error("The editor window did not open in 30 s.")
    Sleep(1500)
    Unexpected("start")
    Log("VMB started pid " . pid . ": " . WinGetTitle(Editor()))
}

Editor() {
    hw := WinExist("Visual Macro Blocks V34 ahk_class AutoHotkeyGUI ahk_pid " . G.Pid)
    if !hw {
        DetectHiddenWindows(true)
        hw := WinExist("Visual Macro Blocks V34 ahk_class AutoHotkeyGUI ahk_pid " . G.Pid)
        DetectHiddenWindows(false)
        if hw
            WinShow(hw)
    }
    if !hw
        throw Error("Editor window not found.")
    return hw
}

Btn(text) {
    ed := Editor()
    for hw in WinGetControlsHwnd(ed)
        if WinGetClass(hw) = "Button" && ControlGetText(hw) = text && ControlGetVisible(hw) {
            PostMessage(0xF5, 0, 0, hw)     ; BM_CLICK: ControlClick did not fire some VMB buttons on this PC
            return Sleep(400)
        }
    throw Error("Button not found: " . text)
}

BoxBtn(box, text) {
    for hw in WinGetControlsHwnd(box)
        if WinGetClass(hw) = "Button" && ControlGetText(hw) = text {
            PostMessage(0xF5, 0, 0, hw)
            return Sleep(400)
        }
    throw Error("Box button not found: " . text)
}

NewMacro() {
    Btn("&New")
    if box := WaitBox("Visual Macro Blocks", 1500) {
        Log("New asked: " . Flat(WinGetText(box)))
        BoxBtn(box, "&No")
    }
}

StartRec() {
    Btn("&Record")
    if box := WaitBox("Visual Macro Blocks recording", 2500) {
        Log("first-time recording notice: OK")
        BoxBtn(box, "OK")
    }
    if !WinWait("Visual Macro Blocks REC ahk_pid " . G.Pid, , 6) {
        Unexpected("record start")
        throw Error("Recording did not start (no REC bar).")
    }
    Sleep(700)
}

StopRec() {
    bar := WinExist("Visual Macro Blocks REC ahk_pid " . G.Pid)
    if bar
        ControlClick("Static1", bar)
    if bar && !WinWaitClose(bar, , 10)
        throw Error("Recording did not stop after clicking the REC bar.")
    Sleep(1800)
    Unexpected("record stop")
}

; Clicks Play and waits for the run bar to come and go. Answers "Ready to play?" with Yes (Notepad is open here).
Play(label) {
    out := {Secs: 0, Status: "", Note: ""}
    WinActivate(Editor()), Sleep(200)
    Btn("&Play")
    t0 := A_TickCount, seen := false
    while A_TickCount - t0 < 90000 {
        if box := WinExist("Ready to play? ahk_pid " . G.Pid) {
            out.Note := "Ready to play? box: " . Flat(WinGetText(box)) . " -> Yes"
            BoxBtn(box, "&Yes")
            t0 := A_TickCount
            continue
        }
        bar := WinExist("run bar ahk_pid " . G.Pid)
        if bar
            seen := true
        else if seen
            break
        else if A_TickCount - t0 > 6000 && !InStr(StatusText(), "Playing")
            break
        if (b := VmbBoxes()) != "" {
            out.Note .= " box during play: " . b
            WinClose(WinExist("ahk_class #32770 ahk_pid " . G.Pid))
        }
        Sleep(50)
    }
    out.Secs := Round((A_TickCount - t0) / 1000, 2)
    Sleep(500)
    out.Status := StatusText()
    Log(label . ": " . out.Secs . " s, status: " . out.Status)
    return out
}

SaveAs(path) {
    if !RegExMatch(path, "i)^C:\\Temp\\vmb\\")
        throw Error("Refusing to save outside C:\Temp\vmb: " . path)
    if FileExist(path)
        FileDelete(path)
    Btn("Save &as...")
    if !(dlg := WinWait("Save visual macro ahk_class #32770 ahk_pid " . G.Pid, , 10))
        throw Error("Save dialog did not open.")
    Sleep(500)
    ControlSetText(path, "Edit1", dlg), Sleep(300)
    if ControlGetText("Edit1", dlg) != path {
        WinClose(dlg)
        throw Error("Could not put the full path in the Save box; cancelled.")
    }
    ControlSend("{Enter}", "Edit1", dlg)
    if box := WaitBox("Privacy check", 3000) {
        Log("Privacy check: " . Flat(WinGetText(box)) . " -> No (save as they are)")
        BoxBtn(box, "&No")
    }
    t0 := A_TickCount
    while !FileExist(path) && A_TickCount - t0 < 8000
        Sleep(100)
    if WinExist("ahk_id " . dlg) {
        WinClose(dlg)
        return false
    }
    Sleep(500)
    return FileExist(path) ? true : false
}

WaitBox(title, ms) {
    t0 := A_TickCount
    while A_TickCount - t0 < ms {
        if hw := WinExist(title . " ahk_class #32770 ahk_pid " . G.Pid)
            return hw
        Sleep(50)
    }
    return 0
}

VmbBoxes() {
    out := ""
    for hw in WinGetList("ahk_class #32770 ahk_pid " . G.Pid)
        out .= "[" . WinGetTitle(hw) . ": " . Flat(WinGetText(hw)) . "] "
    return Trim(out)
}

Unexpected(where) {
    b := VmbBoxes()
    if b != "" {
        Log("UNEXPECTED box at " . where . ": " . b)
        Res("`n> Unexpected box at " . where . ": " . Pipe(b) . "`n")
    }
}

StatusText() {
    try return StatusBarGetText(1, Editor())
    return ""
}

GridLV() {
    for hw in WinGetControlsHwnd(Editor())
        if WinGetClass(hw) = "SysListView32" && ControlGetVisible(hw) && ListViewGetContent("Count Col", hw) = 25
            return hw
    throw Error("Steps grid not found (is the Grid view on?).")
}

GridRows() {
    rows := []
    txt := ListViewGetContent("", GridLV())
    for line in StrSplit(txt, "`n", "`r")
        if line != ""
            rows.Push(StrSplit(line, "`t"))
    return rows
}

GridCell(row, key) {
    rows := GridRows()
    return row >= 1 && row <= rows.Length ? rows[row][COL[key]] : "(no row " . row . ")"
}

FindRow(action, text) {
    for i, r in GridRows()
        if r[COL["action"]] = action && InStr(r[COL["text"]], text)
            return i
    return 0
}

GridTable(rows) {
    t := "| # | Program | Window | Action | On what | Text / keys | Clicks | Waits first |`n|---|---|---|---|---|---|---|---|`n"
    for r in rows
        t .= "| " . Pipe(r[1]) . " | " . Pipe(r[COL["app"]]) . " | " . Pipe(r[COL["window"]]) . " | " . Pipe(r[COL["action"]]) . " | "
            . Pipe(r[COL["target"]]) . " | " . Pipe(r[COL["text"]]) . " | " . Pipe(r[COL["clicks"]]) . " | " . Pipe(r[COL["wait"]]) . " |`n"
    return t
}

; Screen rect of a ListView cell (LVM_GETSUBITEMRECT through memory in the VMB process).
LvCellScreen(lv, item, sub) {
    pid := WinGetPID(lv)
    hp := DllCall("OpenProcess", "UInt", 0x0438, "Int", 0, "UInt", pid, "Ptr")
    if !hp
        return 0
    rc := Buffer(16, 0)
    try {
        mem := DllCall("VirtualAllocEx", "Ptr", hp, "Ptr", 0, "UPtr", 16, "UInt", 0x1000, "UInt", 4, "Ptr")
        NumPut("Int", sub = 0 ? 2 : 0, rc, 0), NumPut("Int", sub, rc, 4)
        DllCall("WriteProcessMemory", "Ptr", hp, "Ptr", mem, "Ptr", rc, "UPtr", 16, "Ptr", 0)
        ok := SendMessage(0x1038, item, mem, lv)
        DllCall("ReadProcessMemory", "Ptr", hp, "Ptr", mem, "Ptr", rc, "UPtr", 16, "Ptr", 0)
        DllCall("VirtualFreeEx", "Ptr", hp, "Ptr", mem, "UPtr", 0, "UInt", 0x8000)
    } finally DllCall("CloseHandle", "Ptr", hp)
    if !ok
        return 0
    pt := Buffer(8, 0)
    NumPut("Int", NumGet(rc, 0, "Int"), pt, 0), NumPut("Int", NumGet(rc, 4, "Int"), pt, 4)
    DllCall("ClientToScreen", "Ptr", lv, "Ptr", pt)
    return {X: NumGet(pt, 0, "Int"), Y: NumGet(pt, 4, "Int"), W: NumGet(rc, 8, "Int") - NumGet(rc, 0, "Int"), H: NumGet(rc, 12, "Int") - NumGet(rc, 4, "Int")}
}

OnScreenIn(lv, rc) {
    r := Rect(lv)
    return rc.W > 4 && rc.X >= r.X + 150 && rc.X + rc.W // 2 < r.X + r.W - 20 && rc.Y >= r.Y + 2 && rc.Y + rc.H <= r.Y + r.H
}

; ---------------- Notepad helpers ----------------
NpOpen(firstTime) {
    Run("notepad.exe")
    if !(hw := WinWait("ahk_class Notepad ahk_exe notepad.exe", , 15))
        throw Error("Notepad did not open.")
    G.Np := hw, G.NpPid := WinGetPID(hw)
    Sleep(1200)
    e := NpEdit()
    G.NpKind := InStr(WinGetClass(e), "RichEdit") ? "Windows 11 Notepad (" . WinGetClass(e) . ")" : "classic Notepad (" . WinGetClass(e) . ")"
    if firstTime {
        txt := ""
        try txt := ControlGetText(e)
        if txt != "" {
            G.Np := 0
            return Abort("Notepad opened with existing text (a restored tab?). Not touching it. Close that tab yourself, then run again.")
        }
    }
    Log("Notepad open: " . WinGetTitle(hw) . " / " . G.NpKind)
}

NpEdit() {
    for hw in WinGetControlsHwnd(G.Np) {
        c := WinGetClass(hw)
        if (c = "Edit" || InStr(c, "RichEdit")) && ControlGetVisible(hw)
            return hw
    }
    throw Error("Notepad text area not found.")
}

NpEditRect() => Rect(NpEdit())

NpPlace(fx, fy, fw, fh) {
    WinRestore(G.Np)
    WinMove(Round(A_ScreenWidth * fx), Round(A_ScreenHeight * fy), Round(A_ScreenWidth * fw), Round(A_ScreenHeight * fh), G.Np)
    Sleep(400)
}

NpClear() {
    WinActivate(G.Np)
    WinWaitActive(G.Np, , 3)
    ControlFocus(NpEdit()), Sleep(150)
    Send("^a{Delete}"), Sleep(300)
    if NpText() != ""
        Log("WARNING Notepad not empty after clear: " . Esc(NpText()))
}

NpText() {
    if !G.UseClip {
        txt := ""
        try txt := ControlGetText(NpEdit())
        return StrReplace(StrReplace(txt, "`r`n", "`n"), "`r", "`n")
    }
    saved := ClipboardAll()
    A_Clipboard := ""
    WinActivate(G.Np), WinWaitActive(G.Np, , 3)
    Send("^a^c")
    ClipWait(1, 0)
    txt := A_Clipboard
    Send("^{End}")
    A_Clipboard := saved
    return StrReplace(StrReplace(txt, "`r`n", "`n"), "`r", "`n")
}

NpClose() {
    if !G.Np || !WinExist(G.Np)
        return
    NpClear()
    WinClose(G.Np)
    if !WinWaitClose(G.Np, , 3)
        NpForceClose()
    G.Np := 0
}

NpForceClose() {
    if WinExist("ahk_exe notepad.exe") {
        WinActivate("ahk_exe notepad.exe"), Sleep(300)
        Send("!n"), Sleep(1200)      ; "Don't Save"
    }
    if WinExist("ahk_exe notepad.exe") && G.NpPid
        ProcessClose(G.NpPid)
}

CaptionButtons(hw) {
    WinGetPos(&wx, &wy, &ww, &wh, hw)
    rc := Buffer(16, 0)
    if DllCall("dwmapi\DwmGetWindowAttribute", "Ptr", hw, "UInt", 5, "Ptr", rc, "UInt", 16, "Int") = 0 && NumGet(rc, 8, "Int") > NumGet(rc, 0, "Int") {
        l := wx + NumGet(rc, 0, "Int"), t := wy + NumGet(rc, 4, "Int"), r := wx + NumGet(rc, 8, "Int"), b := wy + NumGet(rc, 12, "Int")
        third := (r - l) / 3, cy := Round((t + b) / 2)
        return {Min: {X: Round(l + third / 2), Y: cy}, Max: {X: Round(l + third * 1.5), Y: cy}, Close: {X: Round(l + third * 2.5), Y: cy}, Src: "DWM caption button bounds"}
    }
    s := A_ScreenDPI / 96, right := wx + ww - Round(8 * s), cy := wy + Round(22 * s)
    return {Min: {X: right - Round(115 * s), Y: cy}, Max: {X: right - Round(69 * s), Y: cy}, Close: {X: right - Round(23 * s), Y: cy}, Src: "estimate (DWM bounds unavailable)"}
}

ClickAt(p) {
    MouseMove(p.X, p.Y), Sleep(600)
    Click(), Sleep(300)
}

WaitMinMax(want) {
    t0 := A_TickCount
    while WinGetMinMax(G.Np) != want && A_TickCount - t0 < 4000
        Sleep(50)
    Sleep(900)
}

; ---------------- misc ----------------
Rect(hw) {
    r := Buffer(16, 0)
    DllCall("GetWindowRect", "Ptr", hw, "Ptr", r)
    return {X: NumGet(r, 0, "Int"), Y: NumGet(r, 4, "Int"), W: NumGet(r, 8, "Int") - NumGet(r, 0, "Int"), H: NumGet(r, 12, "Int") - NumGet(r, 4, "Int")}
}

Finish() {
    try NpClose()
    try {
        if G.Pid && ProcessExist(G.Pid) {
            Send("^+x")
            if !ProcessWaitClose(G.Pid, 8)
                ProcessClose(G.Pid)
        }
    }
}

Abort(why) {
    Log("ABORT: " . why)
    Res("`n**Aborted:** " . why . "`n")
    try {
        if G.Pid && ProcessExist(G.Pid)
            ProcessClose(G.Pid)
    }
    MsgBox(why, "V34 retest stopped", "OK Icon! T30")
    ExitApp(1)
}

WriteResults(*) {
    static written := false
    if written
        return
    written := true
    files := ""
    loop files G.Dir . "\*", "FR"
        files .= "- " . A_LoopFileFullPath . "`n"
    try FileDelete(G.Results)
    FileAppend(G.Res . "`n## Files in C:\Temp\vmb`n`n" . files . "- " . G.Results . "`n", G.Results, "UTF-8")
    FileAppend("Results: " . G.Results . "`n", "*")
}

Res(md) => G.Res .= md
Log(msg) => FileAppend(FormatTime(, "HH:mm:ss") . " " . msg . "`n", G.LogFile, "UTF-8")
Esc(s) => StrReplace(StrReplace(StrReplace(s, "``", "'"), "`n", "\n"), "`t", "\t")
Pipe(s) => StrReplace(StrReplace(s, "|", "/"), "`n", " ")
Flat(s) => Trim(RegExReplace(s, "\s+", " "))
JoinArr(a) {
    out := ""
    for v in a
        out .= (out = "" ? "" : ", ") . v
    return out
}
