# V19 item D - scroll position: remember it with each click, put it back before clicking

File: `VisualMacroBlocks-makecode-telek-V19-window-scroll.ahk2`. The find blocks below are for the file state
after item C (commit "V19 item C"). Each one occurs exactly once there. Blocks 1-5, 7 (the help line) and 9 also
occur exactly once in the V18 file; block 6 changes the V19 section header added in item A, and blocks 8 / 10
are the same lines items A-C used. Applying them to the item-C file gives exactly the item-D file (checked with a
script).

## 1. Find / replace blocks (in file order)

### Block 1 - in `VMF_NewMacro` (D6)

Find:
```ahk
            "defaultFind", "spot", "lockWindowSize", 1, "steady", 1), "blocks", [])
```
Replace with:
```ahk
            "defaultFind", "spot", "lockWindowSize", 1, "steady", 1, "restoreScroll", 1), "blocks", [])
```

### Block 2 - in `V4_DesktopStep`, case `"click", "drag"` (D4: after the spot is worked out, before the picture check)

Find:
```ahk
                point := V4_Spot(node, runner, hwnd)
                if steady               ; V18: wait until the screen at the spot looks like the recording
```
Replace with:
```ahk
                point := V4_Spot(node, runner, hwnd)
                if steady && node.Get("scroll", "") is Map      ; V19: scroll the list back first, then check the picture
                    V19_RestoreScroll(node, point, runner)
                if steady               ; V18: wait until the screen at the spot looks like the recording
```

### Block 3 - in `V4_DesktopStep`, case `"wheel"` (D4: right after its `MouseMove`)

Find:
```ahk
                    MouseMove(point.X, point.Y, 0)
                    runner.Sleep(30)
```
Replace with:
```ahk
                    MouseMove(point.X, point.Y, 0)
                    if V18_Steady(runner) && node.Get("scroll", "") is Map     ; V19: same scroll start as recorded
                        V19_RestoreScroll(node, point, runner)
                    runner.Sleep(30)
```

### Block 4 - in `V4_RecordMouse`, the `isDown` branch (D3)

Find:
```ahk
            step := VM_CaptureClickStep(x, y, button)
            V18_UsePreShot(step, x, y)
```
Replace with:
```ahk
            step := VM_CaptureClickStep(x, y, button)
            scroll := V19_CaptureScroll(x, y)       ; V19: where the list under the click was scrolled to
            if scroll is Map
                step["scroll"] := scroll
            V18_UsePreShot(step, x, y)
```

### Block 5 - in `V18_WheelStep` (D3: before returning)

Find:
```ahk
            step["win"] := win, step["geo"] := geo
        }
    }
    return step
```
Replace with:
```ahk
            step["win"] := win, step["geo"] := geo
        }
    }
    scroll := V19_CaptureScroll(x, y)               ; V19: the scroll position before this wheel notch
    if scroll is Map
        step["scroll"] := scroll
    return step
```

### Block 6 - V19 section header (added in item A)

Find:
```ahk
; V19 WINDOW SIZE + SCROLL
; A Normalize step waits until the window really has its size (no fixed pause).
```
Replace with:
```ahk
; V19 WINDOW SIZE + SCROLL
; A Normalize step waits until the window really has its size (no fixed pause). When recording stops, each new
; window's size is tested once (a window that snaps to its own sizes gets the size it settles at). Setting
; sizeMismatch "stop" stops the run when a window can't take its size. Each recorded click / wheel step remembers
; the scroll position of the standard Windows list or box under it ("scroll"); Steady playback puts it back first.
```

### Block 7 - in `V17_EasyHelp` (D6)

Find:
```ahk
        . "`nIf a window can't reach its saved size, the run keeps going and the status bar tells you."
```
Replace with:
```ahk
        . "`nIf a window can't reach its saved size, the run keeps going and the status bar tells you."
        . "`nLists and pages are scrolled back to where they were when you recorded, before each click (standard"
        . "`nWindows lists and boxes only - not web pages, Citrix or Remote Desktop). For those, start each run from the"
        . "`nsame screen and scroll with the keyboard (Ctrl+Home, PgDn) while recording: key presses replay the same way every time."
```

### Block 8 - new functions, at the end of the V19 section (directly above `; V4 STARTUP / SINGLE-FILE PLAYER EXPORT`)

Find:
```ahk
; ============================================================================
; V4 STARTUP / SINGLE-FILE PLAYER EXPORT
```
Replace with:
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

; @summary True when a scroll bar (V19_ScrollInfo result, or 0) can actually scroll: the content is longer than a page.
; @tags macro, scroll, v19
V19_CanScroll(info) => IsObject(info) && info.Max > info.Min && info.Max - info.Min + 1 > info.Page

; @summary The scroll position read back from a control, or "" when it has no such scroll bar.
; @tags macro, scroll, v19
V19_ScrollPos(hwnd, bar) {
    info := V19_ScrollInfo(hwnd, bar)
    return IsObject(info) ? info.Pos : ""
}

; @summary The list / box / pane under a screen point that has a scroll bar that can scroll (the control itself or
;          up to 7 parents). Never a window of this script.
; @returns its hwnd, or 0 when nothing there scrolls
; @tags macro, scroll, v19
V19_ScrollPane(x, y) {
    x := Round(x), y := Round(y)
    h := DllCall("WindowFromPoint", "Int64", (y << 32) | (x & 0xFFFFFFFF), "Ptr")
    desk := DllCall("GetDesktopWindow", "Ptr")
    loop 8 {
        if !h || h = desk || V18_OwnWindow(h)
            return 0
        if V19_CanScroll(V19_ScrollInfo(h, 1)) || V19_CanScroll(V19_ScrollInfo(h, 0))
            return h
        h := DllCall("GetAncestor", "Ptr", h, "UInt", 1, "Ptr")     ; GA_PARENT
    }
    return 0
}

; @summary Recording: the scroll position of the pane under a click / wheel spot.
; @returns Map("cls", class, and per bar that can scroll "v" / "vMax" / "vPage" or "h" / "hMax" / "hPage"), or ""
; @tags macro, scroll, record, v19
V19_CaptureScroll(x, y) {
    try {
        pane := V19_ScrollPane(x, y)
        if !pane
            return ""
        out := Map("cls", WinGetClass("ahk_id " . pane))
        for pair in [["v", 1], ["h", 0]] {
            info := V19_ScrollInfo(pane, pair[2])
            if V19_CanScroll(info)
                out[pair[1]] := info.Pos, out[pair[1] . "Max"] := info.Max, out[pair[1] . "Page"] := info.Page
        }
        return out
    }
    return ""
}

; @summary A wanted scroll position kept inside what the bar allows: lo (Min) .. hi (Max) - page + 1 (page 0 counts as 1).
; @tags macro, scroll, v19
V19_ClampScroll(want, lo, hi, page) => VF_Clamp(want, lo, Max(lo, hi - Max(page, 1) + 1))

; @summary What to send next to step a scroll bar from pos towards want. far (a page or more away, page > 1) =
;          page up / down, else line up / down. Done after 2 flips (stepped over the target twice) or at the target.
; @returns {Code: 0 line up | 1 line down | 2 page up | 3 page down | 8 end (when Done), Done}
; @tags macro, scroll, v19
V19_ScrollStep(pos, want, page, flips) {
    delta := want - pos
    if delta = 0 || flips >= 2
        return {Code: 8, Done: true}
    far := page > 1 && Abs(delta) >= page
    return {Code: delta > 0 ? (far ? 3 : 1) : (far ? 2 : 0), Done: false}
}

; @summary Scrolls one bar of a pane to a position: first a jump (SB_THUMBPOSITION), then line / page steps, reading
;          the position back after each. Every message has a 500 ms timeout so a hung program can't hang the macro.
; @returns true when the bar ends exactly at want (after clamping)
; @tags macro, scroll, playback, v19
V19_ScrollTo(pane, bar, want, runner) {
    msg := bar = 1 ? 0x115 : 0x114            ; WM_VSCROLL / WM_HSCROLL
    info := V19_ScrollInfo(pane, bar)
    if !IsObject(info)
        return false
    want := V19_ClampScroll(want, info.Min, info.Max, info.Page)
    pos := info.Pos
    if pos = want
        return true
    if want >= 0 && want <= 65535 {           ; way 1: jump
        try SendMessage(msg, (want << 16) | 4, 0, pane, , , , , 500)     ; SB_THUMBPOSITION
        try SendMessage(msg, 8, 0, pane, , , , , 500)                    ; SB_ENDSCROLL
        pos := V19_ScrollPos(pane, bar)
        if pos = want
            return true
        if pos = ""
            return false
    }
    flips := 0, lastSign := 0                 ; way 2: step
    loop 600 {
        next := V19_ScrollStep(pos, want, info.Page, flips)
        if next.Done
            break
        try SendMessage(msg, next.Code, 0, pane, , , , , 500)
        now := V19_ScrollPos(pane, bar)
        if now = "" || now = pos
            break
        sign := now < want ? 1 : now > want ? -1 : 0
        if sign && lastSign && sign != lastSign
            flips += 1
        if sign
            lastSign := sign
        pos := now
        if Mod(A_Index, 50) = 0
            runner.Sleep(1)
    }
    try SendMessage(msg, 8, 0, pane, , , , , 500)                        ; SB_ENDSCROLL
    return pos = want                         ; way 3: give up (the caller notes it); the spot is never shifted
}

; @summary Steady playback, before a click / wheel step with a recorded "scroll": scrolls the list or box under the spot
;          back to where it was when recording. Skipped when the macro setting restoreScroll is 0.
; @returns true when the pane is where it was; false after a note (the step still clicks). Throws instead of the
;          "could not scroll" note when the macro setting sizeMismatch is "stop".
; @tags macro, scroll, playback, steady, v19
V19_RestoreScroll(node, point, runner) {
    if !runner.Settings.Get("restoreScroll", 1)
        return false
    rec := node["scroll"], isWheel := node.Get("type", "") = "wheel"
    V5_HideOverlays(point.X, point.Y)          ; the run bar must not hide the list from WindowFromPoint
    pane := V19_ScrollPane(point.X, point.Y), cls := ""
    if pane
        try cls := WinGetClass("ahk_id " . pane)
    if !pane || cls != rec.Get("cls", "") {
        V17_Warn(runner, "Step #" . runner.Index . ": the list that was scrolled when recording was not found at the "
            . (isWheel ? "mouse spot. Scrolled anyway." : "click spot. Clicked anyway."))
        return false
    }
    changed := false, missed := "", longer := false
    for pair in [["v", 1], ["h", 0]] {
        key := pair[1]
        if !rec.Has(key)
            continue
        want := rec[key], info := V19_ScrollInfo(pane, pair[2])
        if IsObject(info) && info.Pos = want
            continue
        if IsObject(info) && rec.Has(key . "Max") && info.Max != rec[key . "Max"]
            longer := true
        changed := true
        if !V19_ScrollTo(pane, pair[2], want, runner) {
            now := V19_ScrollPos(pane, pair[2])
            missed .= (missed = "" ? "" : "; ") . "now at " . (now = "" ? "?" : now) . ", recorded " . want
        }
    }
    if missed != "" {
        text := "Step #" . runner.Index . ": could not scroll the list back to where it was (" . missed . ")"
            . (longer ? " (the list is a different length than when it was recorded)" : "") . "."
        if runner.Settings.Get("sizeMismatch", "") = "stop"
            throw Error(text . " Scroll it back by hand, then retry this step.")
        V17_Warn(runner, text . (isWheel ? " Scrolled anyway." : " Clicked anyway."))
        return false
    }
    if changed
        runner.Sleep(80)                       ; let the pane re-draw before the picture check
    return true
}

; ============================================================================
; V4 STARTUP / SINGLE-FILE PLAYER EXPORT
```

### Block 9 - in `V4_Help` (D6)

Find:
```ahk
    MsgBox("NEW IN V18 (one-click Record + Steady playback):"
```
Replace with:
```ahk
    MsgBox("NEW IN V19 (window size + scroll):"
        . "`n• Lists and pages are scrolled back to where they were when you recorded, before each click (standard Windows lists"
        . "  and boxes only - not web pages, Citrix or Remote Desktop). For those, start each run from the same screen and scroll"
        . "  with the keyboard (Ctrl+Home, PgDn) while recording, because key presses replay the same way every time."
        . "`n`nNEW IN V18 (one-click Record + Steady playback):"
```

### Block 10 - in `V4_SelfTest`, right before `player := V4_PlayerSource(source, macro)` (after the item A-C lines)

Find:
```ahk
        player := V4_PlayerSource(source, macro)
```
Replace with:
```ahk
        check("V19 scroll: no scroll bar cannot scroll", V19_CanScroll(0), false)
        check("V19 scroll: a long list can scroll", V19_CanScroll({Min: 0, Max: 299, Page: 30, Pos: 0}), true)
        check("V19 scroll: a list that fits on one page cannot", V19_CanScroll({Min: 0, Max: 29, Page: 30, Pos: 0}), false)
        check("V19 scroll: an empty bar cannot", V19_CanScroll({Min: 0, Max: 0, Page: 0, Pos: 0}), false)
        check("V19 scroll: a wanted spot inside the range is kept", V19_ClampScroll(150, 0, 299, 30), 150)
        check("V19 scroll: beyond the end is clamped to the last page", V19_ClampScroll(500, 0, 299, 30), 270)
        check("V19 scroll: before the start is clamped to the top", V19_ClampScroll(-5, 0, 299, 30), 0)
        check("V19 scroll: page 0 counts as 1", V19_ClampScroll(500, 0, 299, 0), 299)
        v19S := V19_ScrollStep(40, 40, 30, 0)
        check("V19 scroll step: already there", v19S.Done . "|" . v19S.Code, "1|8")
        v19S := V19_ScrollStep(40, 41, 30, 0)
        check("V19 scroll step: one line down", v19S.Done . "|" . v19S.Code, "0|1")
        check("V19 scroll step: one line up", V19_ScrollStep(41, 40, 30, 0).Code, 0)
        check("V19 scroll step: several pages down", V19_ScrollStep(0, 150, 30, 0).Code, 3)
        check("V19 scroll step: several pages up", V19_ScrollStep(150, 0, 30, 0).Code, 2)
        check("V19 scroll step: page 1 always steps by line", V19_ScrollStep(0, 150, 1, 0).Code, 1)
        check("V19 scroll step: stops after stepping over twice", V19_ScrollStep(10, 12, 30, 2).Done, 1)
        check("V19 scroll: a window without scroll bars reads 0", V19_ScrollInfo(0, 1), 0)
        check("V19 scroll: nothing off the screen scrolls", V19_CaptureScroll(-32000, -32000), "")
        check("V19 new macros restore the scroll position", VMF_NewMacro()["settings"].Get("restoreScroll", 0), 1)
        v19Run := V4Runner(Map("settings", Map("steady", 1, "restoreScroll", 0), "blocks", []), {})
        check("V19 restoreScroll = 0 skips it without a note",
            V19_RestoreScroll(Map("type", "click", "scroll", Map("cls", "Edit", "v", 5)), {X: -32000, Y: -32000}, v19Run) . "|" . v19Run.Warnings.Length, "0|0")
        v19Run := V4Runner(Map("settings", Map("steady", 1), "blocks", []), {})
        check("V19 a list that is not at the spot is noted",
            V19_RestoreScroll(Map("type", "click", "scroll", Map("cls", "Edit", "v", 5)), {X: -32000, Y: -32000}, v19Run) . "|" . v19Run.Warnings.Length, "0|1")
        player := V4_PlayerSource(source, macro)
```

## 2. Full text of each new function

`V19_ScrollInfo` (as given in the plan, D1), `V19_CanScroll`, `V19_ScrollPos`, `V19_ScrollPane`,
`V19_CaptureScroll`, `V19_ClampScroll`, `V19_ScrollStep`, `V19_ScrollTo`, `V19_RestoreScroll` - exactly as in
Block 8 above.

## 3. New self-test lines

The 20 `check("V19 scroll ...")` / `check("V19 ...")` lines in Block 10. Self-test now: 242 PASS, 0 FAIL,
`Failures: 0`.

## 4. What I could not be sure about

- Recording reads the scroll position when the mouse button goes down. The plan says the program has not reacted
  yet at that moment; I could not prove that on Windows. A list that scrolls on the press itself (for example
  clicking a half-visible last row in some lists) might store the position after that scroll.
- `GetScrollInfo` on another program's control, and `WM_VSCROLL` / `WM_HSCROLL` with `SB_THUMBPOSITION`, are
  assumed to work for standard controls as the plan describes. Under Wine they worked for Notepad's edit box.
  Some programs ignore `SB_THUMBPOSITION`; then the line / page steps are used.
- The picture search mode ("find" not "spot") is not changed: there the click spot comes from the picture search,
  and the plan puts the scroll step after the spot and before `V18_VerifySpot`, which only exists in spot mode.
  So scroll restore only runs for steps that click the recorded spot (the default, and every Easy-mode recording).
- Small wording choices: for a wheel step the notes say "mouse spot" / "Scrolled anyway." instead of
  "click spot" / "Clicked anyway.". When the run stops instead (`sizeMismatch` = "stop"), the message ends with
  "Scroll it back by hand, then retry this step." instead of "Clicked anyway." (which would not be true).
- `V19_RestoreScroll` hides the run bar at the spot first (`V5_HideOverlays`, the same call the click uses
  later), so the run bar can't be mistaken for the list.
- `V19_ClampScroll(want, lo, hi, page)`: the plan calls the middle parameters `min` / `max`, but AutoHotkey names are
  not case-sensitive, so those would hide the built-in `Min()` / `Max()` (plan rule 5).
- `V19_ScrollStep` returns code 8 (end) when it is done; the plan only lists 0-3.
- Only steady playback and only steps recorded in V19 (they have `scroll`) use this, so old macros are untouched.

## 5. Test by hand on a PC

1. Open Notepad, paste 300 numbered lines, Format > Word Wrap off. Scroll so that about line 150 is at the top.
2. Press Record, click at the start of a line (note its number), type `X`, stop.
3. Scroll back to the top (Ctrl+Home).
4. Press Play. The list must jump back to about line 150 and the `X` must land on the same line as before.
5. `Documents\VisualMacros\last-playback.log` must contain no "could not scroll" note.

## Test results (Wine 10 on Linux, AutoHotkey 2.0.27)

- `/validate`: exit code 0, no output.
- `--self-test`: 242 PASS, 0 FAIL, `Failures: 0`.
- Brace / duplicate-name check: OK.
- Notepad record + replay (the standard test): text ends `KEEP MEhello grokbot\nline2`, 0 notes.
- Old macro recorded with the V18 file: same result, 0 notes (no `scroll` field, so nothing new runs).

**The plan's Notepad scroll test could not be proved under Wine.** I ran it (300 lines, scrolled to line 150,
recorded a click + `X`, scrolled to the top, played). Under Wine, `GetScrollInfo` returns nothing for a window
that belongs to *another* program (Wine keeps scroll bar numbers inside each program, Windows keeps them in the
system). So the click was recorded without `scroll`, playback did not scroll, and the `X` landed on line 10
instead of line 159 - exactly the V18 behaviour, and the reason this item exists. On a real PC `GetScrollInfo`
does read other programs' standard scroll bars, so this needs the owner's 5-line PC test above.

What Wine *could* prove, with the V19 functions copied unchanged into a small test script whose own window holds
the lists (same program, so Wine answers `GetScrollInfo`):

| Pane | Recorded | Scrolled to top, then restore | Line / page steps only (way 2) |
|---|---|---|---|
| Edit box (300 lines) | v=280, Max 300, Page 21 | back to 280, 0 notes, 82 ms | reached 150 in 10 messages |
| ListBox (300 rows) | v=149, Max 299, Page 22 | back to 149, 0 notes, 82 ms | reached 150 in 24 messages |
| ListView (300 rows) | v=181, Max 299, Page 18 | back to 181, 0 notes, 90 ms | reached 150 in 14 messages |
| Window with a scroll bar that ignores WM_VSCROLL | v=150 | note "could not scroll the list back to where it was (now at 0, recorded 150). Clicked anyway." | - |
| Same, with `sizeMismatch` = "stop" | v=150 | stops: "... (now at 0, recorded 150). Scroll it back by hand, then retry this step." | - |
| A different control at the spot | cls ListBox | note "the list that was scrolled when recording was not found at the click spot. Clicked anyway." | - |

And in the real script: a Notepad macro with a `scroll` field added by hand played with the note "the list that
was scrolled when recording was not found at the click spot. Clicked anyway." (Wine can't read Notepad's scroll
bar), then clicked and typed as normal - so the playback call is wired in and never blocks the click.
