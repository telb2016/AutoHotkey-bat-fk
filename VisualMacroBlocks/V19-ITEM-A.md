# V19 item A - wait for the window size instead of a fixed pause

File: `VisualMacroBlocks-makecode-telek-V19-window-scroll.ahk2` (made as a copy of
`VisualMacroBlocks-makecode-telek-V18-claude-window-specialist.ahk2`; the V18 file is not changed).
Every find block below occurs exactly once in the V18 file (checked with a script that applies these
blocks to the V18 file and compares the result with the V19 file after item A: identical).

## 1. Find / replace blocks (in file order)

### Block 1 - in `V17_NormalizeWindow` (the `ctx.Sleep(250)` after `WinMove`; the pauses after maximize / restore are unchanged)

Find:
```ahk
        else
            WinMove(left + mx, top + my, , , id)
    }
    ctx.Sleep(250)
```
Replace with:
```ahk
        else
            WinMove(left + mx, top + my, , , id)
    }
    if resizable                        ; V19: wait until the window has its size, instead of a fixed 250 ms pause
        V19_WaitSize(id, wantW, wantH, ctx)
    else                                ; fixed-size window: only wait until it stops moving
        V19_WaitSize(id, left + mx, top + my, ctx, , true)
    ctx.Sleep(120)                      ; let the program re-draw its controls
```

### Block 2 - new section directly above `; V4 STARTUP / SINGLE-FILE PLAYER EXPORT`

Find:
```ahk
; ============================================================================
; V4 STARTUP / SINGLE-FILE PLAYER EXPORT
```
Replace with:
```ahk
; ============================================================================
; V19 WINDOW SIZE + SCROLL
; A Normalize step waits until the window really has its size (no fixed pause).
; ============================================================================

; @summary Decides when to stop waiting for a window size. samples = array of [tickMs, w, h], oldest first.
; @returns "ok" (within 1 px of the wanted size on the last two reads), "stuck" (the size has not changed for
;          300 ms and is not the wanted size: the program refused it), or "" (keep waiting)
; @tags macro, window, normalize, v19
V19_SizeVerdict(samples, wantW, wantH) {
    n := samples.Length
    if !n
        return ""
    last := samples[n]
    lastOk := Abs(last[2] - wantW) <= 1 && Abs(last[3] - wantH) <= 1
    if lastOk && n >= 2 && Abs(samples[n - 1][2] - wantW) <= 1 && Abs(samples[n - 1][3] - wantH) <= 1
        return "ok"
    if lastOk
        return ""
    first := n
    while first > 1 && samples[first - 1][2] = last[2] && samples[first - 1][3] = last[3]
        first -= 1
    return last[1] - samples[first][1] >= 300 ? "stuck" : ""
}

; @summary Waits until a window has the wanted size: reads it every 50 ms (Esc-stoppable when ctx is a runner,
;          a plain Sleep when ctx is 0). byPos = true compares the position (x, y) instead, for a fixed-size window.
; @returns "ok", "stuck" (the program refused the size) or "timeout" (after maxMs, or the window is gone)
; @tags macro, window, normalize, v19
V19_WaitSize(id, wantW, wantH, ctx, maxMs := 2000, byPos := false) {
    samples := [], start := A_TickCount
    loop {
        try WinGetPos(&wx, &wy, &ww, &wh, id)
        catch
            return "timeout"
        samples.Push(byPos ? [A_TickCount, wx, wy] : [A_TickCount, ww, wh])
        verdict := V19_SizeVerdict(samples, wantW, wantH)
        if verdict != ""
            return verdict
        if A_TickCount - start >= maxMs
            return "timeout"
        if IsObject(ctx)
            ctx.Sleep(50)
        else
            Sleep(50)
    }
}

; ============================================================================
; V4 STARTUP / SINGLE-FILE PLAYER EXPORT
```

### Block 3 - in `V4_SelfTest`, right before `player := V4_PlayerSource(source, macro)`

Find:
```ahk
        player := V4_PlayerSource(source, macro)
```
Replace with:
```ahk
        check("V19 size wait: reaches the size", V19_SizeVerdict([[0, 800, 600], [50, 850, 650], [100, 900, 700], [150, 900, 700]], 900, 700), "ok")
        check("V19 size wait: within 1 px counts", V19_SizeVerdict([[0, 800, 600], [50, 899, 701], [100, 900, 700]], 900, 700), "ok")
        check("V19 size wait: never moves = stuck", V19_SizeVerdict([[0, 800, 600], [100, 800, 600], [200, 800, 600], [300, 800, 600]], 900, 700), "stuck")
        check("V19 size wait: not moving for under 300 ms keeps waiting", V19_SizeVerdict([[0, 800, 600], [100, 800, 600], [250, 800, 600]], 900, 700), "")
        check("V19 size wait: moves then stops short = stuck",
            V19_SizeVerdict([[0, 800, 600], [50, 850, 650], [100, 880, 690], [200, 880, 690], [300, 880, 690], [400, 880, 690]], 900, 700), "stuck")
        check("V19 size wait: reaches the size on the last read only keeps waiting", V19_SizeVerdict([[0, 800, 600], [50, 850, 650], [100, 900, 700]], 900, 700), "")
        check("V19 size wait: no reads yet keeps waiting", V19_SizeVerdict([], 900, 700), "")
        check("V19 size wait: a window that is gone times out", V19_WaitSize("ahk_id 0x7FFFFFF0", 900, 700, 0, 200), "timeout")
        player := V4_PlayerSource(source, macro)
```

## 2. Full text of each new function

`V19_SizeVerdict` and `V19_WaitSize` - exactly as in Block 2 above (the new section).

## 3. New self-test lines

The 8 `check("V19 size wait: ...")` lines in Block 3. Self-test now: 211 PASS, 0 FAIL, `Failures: 0`
(V18 had 203).

## 4. What I could not be sure about

- "Size has not changed for 300 ms" is read literally: a program that does not start resizing within 300 ms of
  the `WinMove` is called "stuck". Nothing stops because of that - the existing "size is off" note decides, as
  before. I have not seen a program that slow, but a real PC test would show it.
- For a fixed-size window the same loop waits for the wanted position (x, y). If Windows keeps the window
  somewhere else (for example to keep it on the screen), the wait ends as "stuck" after 300 ms.
- This change affects every Normalize step (old macros too), as the plan asks: only the waiting time changes,
  not where the window goes. A fast program now waits about 50 + 120 ms instead of 250 ms; a slow one up to 2 s.
- Tested under Wine on Linux (AutoHotkey 2.0.27), not on Windows. Nothing newer than v2.0.19 is used.
- `V19_WaitSize` has one extra optional parameter (`byPos`) beyond the plan's signature, for the fixed-size case.

## 5. Test by hand on a PC

1. Open Notepad, make it small, press Record in Visual Macro Blocks, click in Notepad, type `hi`, stop.
2. Drag Notepad much bigger, then press Play.
3. Notepad must jump back to the recorded size right away (no visible wait) and `hi` is typed again.
4. `Documents\VisualMacros\last-playback.log` must have no "stayed ... instead of ..." note.
5. Run `AutoHotkey64.exe VisualMacroBlocks-makecode-telek-V19-window-scroll.ahk2 --self-test C:\temp\report.txt`: it must end with `Failures: 0`.

## Test results (Wine 10 on Linux, AutoHotkey 2.0.27)

- `/validate`: exit code 0, no output.
- `--self-test`: 211 PASS, 0 FAIL, `Failures: 0`.
- Brace / duplicate-name check: OK.
- Notepad record + replay (new recording): text ends `KEEP MEhello grokbot\nline2`, window back to 950x712.
- Old macro (recorded with the V18 file) played in V19: same result, 0 notes.
- `V19_WaitSize` against a real Notepad window: 900x700 -> "ok" in about 155 ms; 640x480 -> "ok";
  50x20 (below Notepad's minimum) -> "stuck" in about 410 ms (window stayed 119x34); position-only wait -> "ok".
