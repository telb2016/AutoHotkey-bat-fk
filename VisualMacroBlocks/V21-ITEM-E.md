# V21 item E - keep the window on the screen (playback safety, small)

File: `VisualMacroBlocks-makecode-telek-V21-step-list.ahk2`. The find blocks are for the file after item D; each
occurs exactly once there (checked with the script that applies them; the result is the committed file).

## 1. Find / replace blocks (in file order)

### Block 1 - in `V17_NormalizeWindow` (the spot is worked out once; in a Steady macro a spot that is on no screen is moved onto the main screen)

Find:
```ahk
    resizable := V17_IsResizable(WinGetStyle(id))
    try {
        if resizable
            WinMove(left + mx, top + my, wantW, wantH, id)
        else
            WinMove(left + mx, top + my, , , id)
    }
    if resizable                        ; V19: wait until the window has its size, instead of a fixed 250 ms pause
        V19_WaitSize(id, wantW, wantH, ctx)
    else                                ; fixed-size window: only wait until it stops moving
        V19_WaitSize(id, left + mx, top + my, ctx, , true)
```
Replace with:
```ahk
    resizable := V17_IsResizable(WinGetStyle(id))
    x := left + mx, y := top + my
    if V18_Steady(ctx) {                ; V21: keep the window on a screen that exists (a different monitor layout)
        rects := []
        Loop MonitorGetCount() {
            MonitorGet(A_Index, &monL, &monT, &monR, &monB)
            rects.Push([monL, monT, monR, monB])
        }
        if !V21_OnAnyScreen(x + 8, y + 8, rects) {
            V14_FitOnMonitor(&x, &y, wantW, wantH)
            V17_Warn(ctx, "Step #" . ctx.Index . ": the saved window spot is off this screen; moved the window onto the main screen.")
        }
    }
    try {
        if resizable
            WinMove(x, y, wantW, wantH, id)
        else
            WinMove(x, y, , , id)
    }
    if resizable                        ; V19: wait until the window has its size, instead of a fixed 250 ms pause
        V19_WaitSize(id, wantW, wantH, ctx)
    else                                ; fixed-size window: only wait until it stops moving
        V19_WaitSize(id, x, y, ctx, , true)
```

### Block 2 - V21 section (new function at its end, directly above the `; ====` line of `; V4 STARTUP / SINGLE-FILE PLAYER EXPORT`)

Find:
```ahk
; ============================================================================
; V4 STARTUP / SINGLE-FILE PLAYER EXPORT
```
Replace with:
```ahk
; @summary True when the point (x, y) lies on one of the screens. rects = array of [left, top, right, bottom]
;          (as MonitorGet gives them; right and bottom are just outside the screen).
; @tags macro, window, monitor, normalize, v21
V21_OnAnyScreen(x, y, rects) {
    for rect in rects
        if x >= rect[1] && x < rect[3] && y >= rect[2] && y < rect[4]
            return true
    return false
}

; ============================================================================
; V4 STARTUP / SINGLE-FILE PLAYER EXPORT
```

### Block 3 - in `V4_SelfTest` (new checks right before `player := V4_PlayerSource(source, macro)`)

Find:
```ahk
        player := V4_PlayerSource(source, macro)
```
Replace with:
```ahk
        v21Screens := [[0, 0, 1920, 1080], [-1280, 0, 0, 1024]]
        check("V21 a spot on the main screen", V21_OnAnyScreen(8, 8, v21Screens), true)
        check("V21 a spot on a second screen to the left", V21_OnAnyScreen(-500, 100, v21Screens), true)
        check("V21 a spot off every screen", V21_OnAnyScreen(3008, 8, v21Screens) . V21_OnAnyScreen(100, 1100, v21Screens) . V21_OnAnyScreen(-1300, 8, v21Screens), "000")
        check("V21 right and bottom edges are off the screen", V21_OnAnyScreen(1920, 5, [[0, 0, 1920, 1080]]) . V21_OnAnyScreen(5, 1080, [[0, 0, 1920, 1080]]), "00")
        check("V21 no screens", V21_OnAnyScreen(8, 8, []), false)
        player := V4_PlayerSource(source, macro)
```

## 2. Full text of each new function

```ahk
; @summary True when the point (x, y) lies on one of the screens. rects = array of [left, top, right, bottom]
;          (as MonitorGet gives them; right and bottom are just outside the screen).
; @tags macro, window, monitor, normalize, v21
V21_OnAnyScreen(x, y, rects) {
    for rect in rects
        if x >= rect[1] && x < rect[3] && y >= rect[2] && y < rect[4]
            return true
    return false
}
```

## 3. New self-test lines and PASS count

The 5 new `check(...)` lines are in block 3 (main screen, a second screen to the left with negative x, spots off
every screen, the right / bottom edge, no screens). Self-test under Wine: **347 PASS** (after item D: 342;
V20: 274), `Failures: 0`.

## 4. Notes / anything unsure

- Only in a macro with the setting `steady` (`V18_Steady(ctx)`); without it the window goes exactly where it went
  before (the spot is still `left + mx`, `top + my`, now held in `x`, `y`). The maximize path is unchanged.
- A spot whose point `(x + 8, y + 8)` is on any monitor is never changed, so a window partly off an edge stays
  where the user put it.
- `V14_FitOnMonitor` picks the monitor holding `(x + 8, y + 8)` - none here - so it uses the primary monitor's work
  area and shifts the window so `wantW x wantH` fits on it. For a fixed-size window (only moved, never resized)
  the saved width / height are used for that fit, as the plan says; its real size may differ a little.
- `V19_WaitSize` for a fixed-size window compares the position: it now gets the adjusted `x`, `y`.
- One note per Normalize step that had to move the window (`V17_Warn`, so it is also in the log, the status bar and
  item D's ⚠ mark).
- Unsure / not testable here: Wine has one screen, so a real second monitor (negative coordinates, a monitor
  that was unplugged, different DPI per monitor) could not be tried. `MonitorGet` returns the full monitor
  rectangle (taskbar included); a spot on the taskbar area counts as "on a screen" and is left alone.

## 5. Tests run (Wine, one 1600 x 1000 screen)

- Load check: no errors, no warnings. Self-test: 347 PASS, `Failures: 0`. Brace check: balanced.
- Old macro with its Normalize spot changed to x = 3000 (off the screen), Steady on: the window was moved to
  (650, 0) - right edge of the screen - with the note `Step #1: the saved window spot is off this screen; moved the
  window onto the main screen.` and the text landed right (`KEEP MEhello grokbot` / `line2`). The V20 file with the
  same macro left the window at (3000, 0) and the text went to the wrong place.
- Same macro with Steady off: window at (3000, 0), no note - the same as V20 (old behaviour kept).
- Notepad record / replay: `KEEP MEhello grokbot` / `line2`, 0 notes. V18 macro replays as before.
