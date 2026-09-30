; KeyOverlay.ahk - live view of the last keys pressed and the script lines most
; recently executed, shown as a large tooltip-style box or as a normal window.
; Optionally also appends every key to a daily log file.
;
; To watch one of your scripts, put this near the TOP of it (before any Return/Exit):
;     #Include KeyOverlay.ahk
; The "lines executed" panel shows the lines of whatever script includes this file.
; Run on its own, it still shows keys, but the lines panel has nothing useful in it.
;
; Ctrl+Alt+K shows/hides the display (change ToggleKey below).

#Requires AutoHotkey v2.0

KeyOverlay.Start()

class KeyOverlay {
    ; ===== Pick ONE display - comment out the other =====
    static Mode := "overlay"      ; big tooltip-style box: always on top, clicks pass through it
    ;static Mode := "gui"         ; normal window: move, resize, scroll, copy text, pause

    ; ===== Settings =====
    static KeyCount  := 20        ; how many recent keys to show
    static LineCount := 20        ; how many executed lines to show (0 = hide that panel)
    static FontName  := "Consolas"
    static FontSize  := 12
    static RefreshMs := 250       ; how often the display updates
    static LogToFile := true      ; also write keys to LogDir\yyyy-MM-dd.txt
    static LogDir    := A_ScriptDir "\KeyLogs"
    static KeepDays  := 2         ; delete log files older than this
    static ToggleKey := "^!k"     ; Ctrl+Alt+K

    static Keys := [], Buf := "", Last := "", Shown := true
    static Win := "", KeyCtl := "", LineCtl := "", PauseCtl := ""

    static Start() {
        this.ih := InputHook("V L0")          ; V = keys still reach apps, L0 = never fills up/ends
        this.ih.KeyOpt("{All}", "N")
        this.ih.OnKeyDown := ObjBindMethod(this, "OnKey")
        this.ih.Start()

        this.Mode = "gui" ? this.BuildGui() : this.BuildOverlay()
        SetTimer ObjBindMethod(this, "Refresh"), this.RefreshMs
        Hotkey this.ToggleKey, ObjBindMethod(this, "Toggle")

        if this.LogToFile {
            DirCreate this.LogDir
            SetTimer ObjBindMethod(this, "Flush"), 5000
            SetTimer ObjBindMethod(this, "Cleanup"), 3600000
            OnExit ObjBindMethod(this, "Flush")
            this.Cleanup()
        }
        Persistent
    }

    static OnKey(ih, vk, sc) {
        ListLines false               ; keep this logger out of the "lines executed" list
        name := GetKeyName(Format("vk{:x}sc{:x}", vk, sc))
        try title := WinGetTitle("A")
        catch
            title := ""
        t := FormatTime(, "HH:mm:ss")
        this.Keys.Push(Format("{}  {:-10} {}", t, name, SubStr(title, 1, 24)))
        while this.Keys.Length > this.KeyCount
            this.Keys.RemoveAt(1)
        if this.LogToFile
            this.Buf .= t "`t" name "`t" title "`n"
    }

    ; ----- Display -----

    static BuildOverlay() {
        ; -DPIScale so sizes/positions are plain screen pixels; widths are scaled by hand instead.
        g := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20 -DPIScale")   ; E0x20 = click-through
        dpi := A_ScreenDPI / 96
        g.BackColor := "1E1E1E"
        g.MarginX := Round(14 * dpi), g.MarginY := Round(10 * dpi)
        g.SetFont("s" this.FontSize " cE8E8E8", this.FontName)
        ; +0x8C = no word wrap, show "&" literally
        g.AddText("c7FB8FF", "Last " this.KeyCount " keys")
        this.KeyCtl := g.AddText("+0x8C w" Round(this.FontSize * 38 * dpi) " r" this.KeyCount)
        if this.LineCount {
            g.AddText("ym c7FB8FF", "Lines executed")
            this.LineCtl := g.AddText("+0x8C w" Round(this.FontSize * 50 * dpi) " r" this.LineCount)
        }

        g.Show("Hide AutoSize")
        g.GetPos(, , &w, &h)
        MonitorGetWorkArea(, , , &right, &bottom)   ; bottom-right corner of the main screen
        g.Show("NoActivate x" (right - w - 12) " y" (bottom - h - 12))
        WinSetTransparent 225, g                    ; also required for click-through to work
        this.Win := g
    }

    static BuildGui() {
        g := Gui("+Resize +AlwaysOnTop +MinSize400x200", "Key Overlay")
        g.SetFont("s" this.FontSize, this.FontName)
        g.AddText(, "Last " this.KeyCount " keys")
        opts := "ReadOnly -Wrap +HScroll "
        this.KeyCtl := g.AddEdit("xm " opts "w" this.FontSize * 38 " r" this.KeyCount)
        if this.LineCount {
            g.AddText("ym", "Lines executed")
            this.LineCtl := g.AddEdit(opts "w" this.FontSize * 50 " r" this.LineCount)
        }
        this.PauseCtl := g.AddCheckbox("xm", "Pause updates (so you can scroll/copy)")
        g.OnEvent("Size", ObjBindMethod(this, "OnSize"))
        g.OnEvent("Close", (*) => (this.Shown := false))   ; just hide; Ctrl+Alt+K brings it back
        g.Show()
        this.Win := g
    }

    static OnSize(g, minMax, w, h) {
        if minMax = -1
            return
        this.KeyCtl.GetPos(&x, &y, &kw)
        this.PauseCtl.GetPos(, , , &ph)
        editH := h - y - ph - 2 * g.MarginY
        this.KeyCtl.Move(, , , editH)
        if this.LineCtl {
            this.LineCtl.GetPos(&lx)
            this.LineCtl.Move(, , w - lx - g.MarginX, editH)
        }
        this.PauseCtl.Move(, h - ph - g.MarginY)
    }

    static Toggle(*) {
        ListLines false
        this.Shown := !this.Shown
        this.Shown ? this.Win.Show(this.Mode = "gui" ? "" : "NoActivate") : this.Win.Hide()
    }

    static Refresh() {
        ListLines false
        if !this.Shown || (this.PauseCtl && this.PauseCtl.Value)
            return
        keys := ""
        for k in this.Keys
            keys .= (A_Index > 1 ? "`n" : "") k
        lines := this.LineCount ? this.RecentLines() : ""
        if (keys "`n|`n" lines == this.Last)      ; only redraw when something changed
            return
        this.Last := keys "`n|`n" lines
        this.KeyCtl.Value := keys
        if this.LineCtl {
            this.LineCtl.Value := lines
            if this.Mode = "gui"
                SendMessage 0x115, 7, 0, this.LineCtl   ; WM_VSCROLL, SB_BOTTOM
        }
    }

    ; ----- Lines most recently executed -----

    ; Returns the last LineCount lines of what View > "Lines most recently executed" shows.
    static RecentLines() {
        try text := this.ListLinesText()
        catch
            return "(not available - compiled script or main window disabled)"
        out := []
        for line in StrSplit(text, "`n", "`r") {
            if line = "" || SubStr(line, 1, 5) = "---- " || InStr(line, "Press [F5]")
                continue
            out.Push(SubStr(line, 1, 120))
        }
        if !out.Length
            return ""
        ; The newest line's "(seconds)" counts up forever; drop it so the display doesn't redraw constantly.
        out[-1] := RegExReplace(out[-1], " \(\d+\.\d+\)$")
        result := ""
        loop Min(this.LineCount, out.Length)
            result .= out[out.Length - Min(this.LineCount, out.Length) + A_Index] "`n"
        return RTrim(result, "`n")
    }

    ; Asks the script's hidden main window to fill in its ListLines text, then reads it.
    ; ShowWindow/SetForegroundWindow are stubbed out for that one call so the window
    ; doesn't pop up or steal focus (well-known technique; restored immediately after).
    static ListLinesText() {
        static hEdit := 0, pfn := [], bkp := []
        DetectHiddenWindows true
        if !hEdit {
            hEdit := DllCall("GetWindow", "ptr", A_ScriptHwnd, "uint", 5, "ptr")   ; GW_CHILD = main window's Edit
            user32 := DllCall("GetModuleHandle", "str", "user32", "ptr")
            for fn in ["SetForegroundWindow", "ShowWindow"] {
                p := DllCall("GetProcAddress", "ptr", user32, "astr", fn, "ptr")
                DllCall("VirtualProtect", "ptr", p, "ptr", 8, "uint", 0x40, "uint*", &old := 0)
                pfn.Push(p), bkp.Push(NumGet(p, "int64"))
            }
        }
        ; mov eax,1 / ret  (x86 versions pop their 1 and 2 stack args)
        stub := A_PtrSize = 8 ? [0x0000C300000001B8, 0x0000C300000001B8] : [0x0004C200000001B8, 0x0008C200000001B8]
        NumPut "int64", stub[1], pfn[1]
        NumPut "int64", stub[2], pfn[2]
        try SendMessage 0x111, 65406, 0, , A_ScriptHwnd     ; WM_COMMAND, ID_VIEW_LINES
        finally {
            NumPut "int64", bkp[1], pfn[1]
            NumPut "int64", bkp[2], pfn[2]
        }
        return ControlGetText(hEdit)
    }

    ; ----- Log file -----

    static Flush(*) {
        ListLines false
        if this.Buf = ""
            return
        FileAppend this.Buf, this.LogDir "\" FormatTime(, "yyyy-MM-dd") ".txt", "UTF-8"
        this.Buf := ""
    }

    static Cleanup() {
        ListLines false
        loop files this.LogDir "\*.txt"
            if DateDiff(A_Now, A_LoopFileTimeModified, "Days") > this.KeepDays
                FileDelete A_LoopFilePath
    }
}
