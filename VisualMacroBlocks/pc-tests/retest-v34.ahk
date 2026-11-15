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
global COL := Map("num", 1, "app", 3, "window", 4, "action", 6, "target", 7, "text", 8, "clicks", 10, "wait", 16)

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
    t := LvCellScreen(lv, row - 1, COL["text"] - 1)
    if !t || !OnScreenIn(lv, t)
        return 0
    Click(t.X + t.W // 2 . " " . t.Y + t.H // 2), Sleep(300)
    loop COL[key] - COL["text"]
        Send("{Right}"), Sleep(80)
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
