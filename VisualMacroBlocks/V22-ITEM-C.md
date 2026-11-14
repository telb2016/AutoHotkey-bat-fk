# V22 item C - the header line and the on/off switch

File: `VisualMacroBlocks-makecode-telek-V22-columns.ahk2`. The find blocks are for the file after item B; each
occurs exactly once there (checked with the script that applies them; the result is the committed file).

## 1. Find / replace blocks (in file order)

### Block 1 - in `VMB_BuildGui` (the header line above the tree; the tree moves down and gets shorter by its height)

Find:
```ahk
    s.Pal := g.AddTreeView("xm y+4 w230 h372")
    s.TV := g.AddTreeView("x" . (sx + 240) . " y" . sy . " w940 h400 Checked")
```
Replace with:
```ahk
    s.Pal := g.AddTreeView("xm y+4 w230 h372")
    c["ColHead"] := g.AddText("x" . (sx + 240) . " y" . sy . " w940 h16 c606060", "")     ; V22: column names above the tree
    s.TV := g.AddTreeView("x" . (sx + 240) . " y" . (sy + 16) . " w940 h384 Checked")
```

### Block 2 - end of `VMB_OnSize`

Find:
```ahk
    for ctl in s.Bottom {
        ctl.GetPos(&cx)
        ctl.Move(cx, bottomY)
    }
}
```
Replace with:
```ahk
    for ctl in s.Bottom {
        ctl.GetPos(&cx)
        ctl.Move(cx, bottomY)
    }
    V22_PlaceHeader()
}
```

### Block 3 - end of `VMB_Refresh`

Find:
```ahk
    V13_InspLoad()
    V17_UpdateWinInfo()
}
```
Replace with:
```ahk
    V13_InspLoad()
    V17_UpdateWinInfo()
    V22_PlaceHeader()
}
```

### Block 4 - in `VMB_TreeMenu` (the switch, also in Easy mode)

Find:
```ahk
    m.Add("Step grid (edit Window / Find by / Wait for many steps)...", VMB_StepGrid)
```
Replace with:
```ahk
    m.Add("Step grid (edit Window / Find by / Wait for many steps)...", VMB_StepGrid)
    m.Add("Show columns", V22_ToggleColumns)        ; V22: step list in fixed columns on / off
    if VMB().Columns
        m.Check("Show columns")
```

### Block 5 - in `VMB_Zoom` (header follows the new size)

Find:
```ahk
    V22_ApplyTreeFont()                 ; V22: Consolas + exact indent in column mode
```
Replace with:
```ahk
    V22_ApplyTreeFont()                 ; V22: Consolas + exact indent in column mode
    V22_PlaceHeader()
```

### Block 6 - in `V13_BuildInspector` (the Columns tick box next to Explain steps)

Find:
```ahk
    p.Explain.Value := s.ShowMeaning
```
Replace with:
```ahk
    p.Explain.Value := s.ShowMeaning
    p.Columns := g.AddCheckbox("x0 y0 w10 h20 Hidden", "Columns")         ; V22: step list in fixed columns
    p.Columns.Value := s.Columns
    p.Columns.OnEvent("Click", V22_ToggleColumns)
```

### Block 7 - in `V13_InspLayout`

Find:
```ahk
    p.Explain.Move(ix, footTop + 68, iw, 20)
```
Replace with:
```ahk
    p.Explain.Move(ix, footTop + 68, iw - 84, 20)
    p.Columns.Move(ix + iw - 80, footTop + 68, 80, 20)
```

### Block 8 - in `V13_InspArrange`

Find:
```ahk
    for ctl in [p.Box, p.Title, p.Meaning, p.Hint, p.BtnAll, p.BtnTest, p.BtnLook, p.Explain]
```
Replace with:
```ahk
    for ctl in [p.Box, p.Title, p.Meaning, p.Hint, p.BtnAll, p.BtnTest, p.BtnLook, p.Explain, p.Columns]
```

### Block 9 - in `V17_EasyLayout` (the header moves up with the tree)

Find:
```ahk
    for name in ["lbl:HdrBlocks", "lbl:HdrMacro", "Undo", "Redo", "Search", "Pal", "TV"] {
```
Replace with:
```ahk
    for name in ["lbl:HdrBlocks", "lbl:HdrMacro", "Undo", "Redo", "Search", "Pal", "TV", "ColHead"] {
```

### Block 10 - in `V17_EasyHelp` (NEW IN V22)

Find:
```ahk
        . "`n`nNeed CSV rows, web pages, pictures or anything else? Click 'More features ▸' (Ctrl+Shift+E)."
```
Replace with:
```ahk
        . "`n`nNEW IN V22 - THE STEP LIST IN COLUMNS"
        . "`n• Every step row has fixed columns:  #   Program   Waits   Marks   What it does. The Program column is filled on"
        . "  every row (a Wait step shows the program of the step before it)."
        . "`n• Waits = the pause before the step. A * after the time (500 ms*) = a wait you set by hand."
        . "`n• Marks: ► the task moves to another program here, ↕ the list is scrolled back first, ⚡ changes each round,"
        . "  ◇ uses whatever window is active, ✎ has your note, ⚠ had a note in the last run."
        . "`n• Right-click the list -> Show columns (or the Columns tick box in the Step settings panel) for the V21 lines."
        . "`n`nNeed CSV rows, web pages, pictures or anything else? Click 'More features ▸' (Ctrl+Shift+E)."
```

### Block 11 - `V22_ApplyTreeFont` (columns off: Segoe UI, with a fallback when it is missing)

Find:
```ahk
    s.TV.SetFont("s" . s.FontSize, s.Columns ? "Consolas" : "Segoe UI")
```
Replace with:
```ahk
    s.TV.SetFont("s" . s.FontSize, s.Columns ? "Consolas" : "MS Shell Dlg 2")     ; a font name that is missing keeps
    if !s.Columns                                                                  ; the old font, so Segoe UI comes second
        s.TV.SetFont(, "Segoe UI")
```

### Block 12 - V22 section (new functions at its end)

Find:
```ahk
; ============================================================================
; V4 STARTUP / SINGLE-FILE PLAYER EXPORT
```
Replace with:
```ahk
; @summary Puts the column-name line right above the macro tree, its left edge where the first row's text starts
;          (TVM_GETITEMRECT, text part), in the tree's font and size. Hidden when the macro is empty or columns are off.
; @tags macro, gui, columns, v22
V22_PlaceHeader() {
    s := VMB()
    if !s.TV || !s.Gui || !s.Ctl.Has("ColHead") || !(s.Macro is Map)
        return
    head := s.Ctl["ColHead"]
    first := s.TV.GetNext()
    show := s.Columns && first && s.Macro["blocks"].Length
    if show {
        head.SetFont("s" . s.FontSize, "Consolas")
        head.Text := V22_Header(s.IndentChars)
        rc := Buffer(16, 0)
        NumPut("Ptr", first, rc)
        if SendMessage(0x1104, 1, rc.Ptr, s.TV) {                         ; TVM_GETITEMRECT, wParam 1 = text only
            pt := Buffer(8, 0)
            NumPut("Int", NumGet(rc, 0, "Int"), "Int", 0, pt)
            DllCall("MapWindowPoints", "Ptr", s.TV.Hwnd, "Ptr", s.Gui.Hwnd, "Ptr", pt, "UInt", 1)     ; tree -> window
            s.TV.GetPos(&tx, &ty, &tw)
            hx := Round(NumGet(pt, 0, "Int") * 96 / A_ScreenDPI)           ; the window's controls use 96-dpi units
            head.Move(hx, ty - 16, Max(50, tx + tw - hx), 16)
        }
    }
    head.Visible := show
}

; @summary "Columns" tick box / "Show columns" menu entry: step list in fixed columns on or off (remembered).
; @tags macro, gui, columns, v22
V22_ToggleColumns(*) {
    s := VMB()
    if VM_IsRecording() || VM_IsPlaying()
        return
    s.Columns := s.Columns ? 0 : 1
    IniWrite(s.Columns, s.Ini, "V22", "Columns")
    if s.Insp && s.Insp.HasOwnProp("Columns")
        s.Insp.Columns.Value := s.Columns
    V22_ApplyTreeFont(false)
    VMB_Refresh()
}

; ============================================================================
; V4 STARTUP / SINGLE-FILE PLAYER EXPORT
```

### Block 13 - in `V4_Help` (NEW IN V22 above NEW IN V21)

Find:
```ahk
    MsgBox("NEW IN V21 (a step list you can read at a glance):"
```
Replace with:
```ahk
    MsgBox("NEW IN V22 (step list in columns):"
        . "`n• Every step row has fixed columns:  #   Program   Waits   Marks   What it does. The Program column is filled on"
        . "  every row (a Wait step shows the program of the step before it)."
        . "`n• Waits = the pause before the step. A * after the time (500 ms*) = a wait you set by hand."
        . "`n• Marks: ► the task moves to another program here, ↕ the list is scrolled back first, ⚡ changes each round,"
        . "  ◇ uses whatever window is active, ✎ has your note, ⚠ had a note in the last run."
        . "`n• Right-click the list -> Show columns (or the Columns tick box in the Step settings panel) for the V21 lines."
        . "`n`nNEW IN V21 (a step list you can read at a glance):"
```

### Block 14 - in `V4_SelfTest` (the Easy-layout test: the header is one more control)

Find:
```ahk
            "WinInfo", "lbl:HdrBlocks", "lbl:HdrMacro", "Undo", "Redo", "Search", "Pal", "TV", "Edit", "Delete", "Up", "Down", "In", "Out"]
```
Replace with:
```ahk
            "WinInfo", "lbl:HdrBlocks", "lbl:HdrMacro", "Undo", "Redo", "Search", "Pal", "TV", "ColHead", "Edit", "Delete", "Up", "Down", "In", "Out"]
```

### Block 15 - in `V4_SelfTest`

Find:
```ahk
        check("V17 Easy layout shows 26 controls", v17L.Count, 26)
```
Replace with:
```ahk
        check("V17 Easy layout shows 27 controls (V22: + the column header)", v17L.Count, 27)
        check("V22 Easy layout moves the column header up with the tree", v17L["ColHead"][2], 500 - (200 - (50 + 26 + 14)))
```

## 2. Full text of each new function

```ahk
; @summary Puts the column-name line right above the macro tree, its left edge where the first row's text starts
;          (TVM_GETITEMRECT, text part), in the tree's font and size. Hidden when the macro is empty or columns are off.
; @tags macro, gui, columns, v22
V22_PlaceHeader() {
    s := VMB()
    if !s.TV || !s.Gui || !s.Ctl.Has("ColHead") || !(s.Macro is Map)
        return
    head := s.Ctl["ColHead"]
    first := s.TV.GetNext()
    show := s.Columns && first && s.Macro["blocks"].Length
    if show {
        head.SetFont("s" . s.FontSize, "Consolas")
        head.Text := V22_Header(s.IndentChars)
        rc := Buffer(16, 0)
        NumPut("Ptr", first, rc)
        if SendMessage(0x1104, 1, rc.Ptr, s.TV) {                         ; TVM_GETITEMRECT, wParam 1 = text only
            pt := Buffer(8, 0)
            NumPut("Int", NumGet(rc, 0, "Int"), "Int", 0, pt)
            DllCall("MapWindowPoints", "Ptr", s.TV.Hwnd, "Ptr", s.Gui.Hwnd, "Ptr", pt, "UInt", 1)     ; tree -> window
            s.TV.GetPos(&tx, &ty, &tw)
            hx := Round(NumGet(pt, 0, "Int") * 96 / A_ScreenDPI)           ; the window's controls use 96-dpi units
            head.Move(hx, ty - 16, Max(50, tx + tw - hx), 16)
        }
    }
    head.Visible := show
}

; @summary "Columns" tick box / "Show columns" menu entry: step list in fixed columns on or off (remembered).
; @tags macro, gui, columns, v22
V22_ToggleColumns(*) {
    s := VMB()
    if VM_IsRecording() || VM_IsPlaying()
        return
    s.Columns := s.Columns ? 0 : 1
    IniWrite(s.Columns, s.Ini, "V22", "Columns")
    if s.Insp && s.Insp.HasOwnProp("Columns")
        s.Insp.Columns.Value := s.Columns
    V22_ApplyTreeFont(false)
    VMB_Refresh()
}
```

## 3. New self-test lines and PASS count

Block 14 adds `"ColHead"` to the name list of the existing Easy-layout check; block 15 changes its count from 26
to **27** ("V17 Easy layout shows 27 controls (V22: + the column header)") and adds 1 check: in Easy layout the
header moves up with the tree (its y is the tree's y minus 16).
`V22_PlaceHeader` and `V22_ToggleColumns` need the real window, so they are tested there (below).
Self-test under Wine: **369 PASS** (after item B: 368; V21: 347), `Failures: 0`.

## 4. Notes / anything unsure

- **Header x:** placed exactly at "tree x + left of the first row's text rectangle" (TVM_GETITEMRECT with
  wParam TRUE), mapped to the window with MapWindowPoints and converted back to the Gui's 96-dpi units
  (x * 96 / A_ScreenDPI). Under Wine the header text starts about **2 px left** of the row text (the tree draws its
  text with a small inset inside that rectangle). I did **not** add a correction, as the plan says; 2 px is less than
  a third of a character, so the columns still read correctly. If on the PC it is off by more, that is PC check 4.
- **Header height:** 16 px (the plan's number). At a large zoom (A+ several times) the Consolas letters can be taller
  than 16 px and the bottom can be clipped; under Wine at size 11 it still fitted.
- **The on/off tick box:** the plan names it `c["ColToggle"]` next to "Explain steps". "Explain steps" is not in
  `s.Ctl` - it is the inspector's `p.Explain`, and controls in `s.Ctl` are moved / hidden by `V17_ApplyMode`. So the
  tick box is `p.Columns` ("Columns"), on the same line as "Explain steps" (which is 84 px narrower), moved by
  `V13_InspLayout` and listed in `V13_InspArrange`. Same behaviour as the plan, different place in the code.
- The tree's right-click menu has "Show columns" (ticked when on), also in Easy mode. Both switches call
  `V22_ToggleColumns`: it does nothing while recording or playing, flips the setting, writes `[V22] Columns` to the
  ini, syncs the tick box, re-applies the tree font / indent and rebuilds the list.
- **Fix in `V22_ApplyTreeFont` (from item B):** with columns off it asked for "Segoe UI". AutoHotkey keeps the OLD
  font when a font name does not exist, so under Wine (no Segoe UI) the list stayed in Consolas after switching
  off. Now it first sets "MS Shell Dlg 2" and then "Segoe UI": on Windows the result is Segoe UI as in V21, on a
  machine without it the normal dialog font. Found by the toggle test below.
- The tree is 16 px lower and 16 px shorter in both layouts (normal: in `VMB_BuildGui` and `VMB_OnSize`; Easy:
  `V17_EasyLayout` moves the header with the tree).

## 5. Tests run (Wine)

- Load check: no errors, no warnings. Self-test: 369 PASS, `Failures: 0`. Brace check: balanced.
- Test macro in the editor: header "#  Program  Waits  Marks  What it does" sits above the columns and lines up
  (about 2 px left, see above). After A+ A+ (size 11) rows and header still line up; the tree indent read back 27 px
  (9 px character x 3).
- Right-click > "Show columns" (ticked) > click: the list goes back to the V21 rows (sentence, `[app]` tag rules,
  proportional font), the header is hidden, the ini has `[V22] Columns=0`. Clicking it again brings columns and
  header back.
- Notepad record / replay: `KEEP MEhello grokbot` / `line2`, 0 notes. V18 macro replays as before.
