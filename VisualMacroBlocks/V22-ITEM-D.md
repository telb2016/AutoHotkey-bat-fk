# V22 item D - the status bar spells out the selected step

File: `VisualMacroBlocks-makecode-telek-V22-columns.ahk2`. The find blocks are for the file after item C; each
occurs exactly once there (checked with the script that applies them; the result is the committed file).

## 1. Find / replace blocks (in file order)

### Block 1 - in `VMB_BuildGui` (the tree's ItemSelect handler: the same three calls, then the status line)

Find:
```ahk
    s.TV.OnEvent("ItemSelect", (*) => (VMB_SyncWinMatch(), V7_RefreshQuickLookIfOpen(), V13_InspLoad()))
```
Replace with:
```ahk
    s.TV.OnEvent("ItemSelect", (*) => (VMB_SyncWinMatch(), V7_RefreshQuickLookIfOpen(), V13_InspLoad(), V22_ShowDetail()))
```

### Block 2 - V22 section (new functions at its end)

Find:
```ahk
; ============================================================================
; V4 STARTUP / SINGLE-FILE PLAYER EXPORT
```
Replace with:
```ahk
; @summary The whole story of one step in one line for the status bar, only the parts that apply, joined with " · ":
;          "Step 6 · notepad · waits 3.2 s first · <sentence> · list is scrolled back first · ... · last run: <note>".
;          num = the step number ("" leaves it out), app = its Program column, lastNote = its note in the last run.
; @tags macro, gui, columns, v22
V22_Detail(node, app, lastNote, num := "") {
    parts := []
    if num != ""
        parts.Push("Step " . num)
    if app != ""
        parts.Push(app)
    if node.Has("delayMs")
        parts.Push("waits " . V20_Time(node["delayMs"]) . " first (set by hand)")
    else if IsNumber(node.Get("gapMs", 0)) && node.Get("gapMs", 0) >= 300
        parts.Push("waits " . V20_Time(node["gapMs"]) . " first")
    text := V20_StepSentence(node)
    if text = "" {
        sum := VM_StepSummary(node)
        text := Trim(sum[1] . "   " . sum[3])
    }
    parts.Push(text)
    if node.Get("scroll", "") is Map
        parts.Push("list is scrolled back first")
    if (vary := V8_VarySummaryBadge(node)) != ""
        parts.Push(RegExReplace(vary, "^⚡\[(.*)\]$", "$1"))
    if node.Get("winMatch", "") = "active"
        parts.Push("whatever window is active")
    if node.Get("note", "") != ""
        parts.Push("note: " . node["note"])
    if lastNote != ""
        parts.Push("last run: " . V20_Short(RegExReplace(String(lastNote), "^Step #\d+:?\s*"), 120))
    out := ""
    for part in parts
        out .= (A_Index > 1 ? " · " : "") . part
    return out
}

; @summary Tree ItemSelect (after what it already did): the status bar spells out the selected step with V22_Detail.
;          Not while recording or playing (the status bar is in use then), not for blocks, and not again for the
;          same step (the list re-selects it after every change, which would hide that change's own message).
; @tags macro, gui, columns, v22
V22_ShowDetail() {
    static lastNode := 0
    if VM_IsRecording() || VM_IsPlaying()
        return
    s := VMB()
    info := VMB_SelectedInfo()
    if !info || info.Kind != "node" || !VMF_IsStep(info.Node) {
        lastNode := 0
        return
    }
    node := info.Node
    if node == lastNode
        return
    lastNode := node
    num := s.FlatIndex.Get(node, "")
    app := s.ColApp is Map && s.ColApp.Has(node) ? s.ColApp[node] : V22_AppOf(node, s.Macro["settings"])
    VMB_Status(V22_Detail(node, app, s.LastNotes.Get(num, ""), num))
}

; ============================================================================
; V4 STARTUP / SINGLE-FILE PLAYER EXPORT
```

### Block 3 - in `V4_SelfTest`

Find:
```ahk
            "Press Enter (OK / submit / new line) in notepad")
        player := V4_PlayerSource(source, macro)
```
Replace with:
```ahk
            "Press Enter (OK / submit / new line) in notepad")
        check("V22 detail: plain step (no number, no program)", V22_Detail(Map("type", "delay", "ms", 500), "", ""), "Wait 500 ms")
        check("V22 detail: number and program", V22_Detail(Map("type", "keys", "keys", "{Enter}"), "notepad", "", 4),
            "Step 4 · notepad · Press Enter (OK / submit / new line)")
        check("V22 detail: recorded pause", V22_Detail(Map("type", "keys", "keys", "{Enter}", "gapMs", 3200), "notepad", "", 6),
            "Step 6 · notepad · waits 3.2 s first · Press Enter (OK / submit / new line)")
        check("V22 detail: every part", V22_Detail(Map("type", "keys", "keys", "{Enter}", "delayMs", 400, "scroll", Map("v", 1), "varyDX", 5,
            "winMatch", "active", "note", "check it"), "notepad", "Step #6: slow", 6),
            "Step 6 · notepad · waits 400 ms first (set by hand) · Press Enter (OK / submit / new line) · list is scrolled back first · varies: +5px X / round · whatever window is active · note: check it · last run: slow")
        player := V4_PlayerSource(source, macro)
```

## 2. Full text of each new function

```ahk
; @summary The whole story of one step in one line for the status bar, only the parts that apply, joined with " · ":
;          "Step 6 · notepad · waits 3.2 s first · <sentence> · list is scrolled back first · ... · last run: <note>".
;          num = the step number ("" leaves it out), app = its Program column, lastNote = its note in the last run.
; @tags macro, gui, columns, v22
V22_Detail(node, app, lastNote, num := "") {
    parts := []
    if num != ""
        parts.Push("Step " . num)
    if app != ""
        parts.Push(app)
    if node.Has("delayMs")
        parts.Push("waits " . V20_Time(node["delayMs"]) . " first (set by hand)")
    else if IsNumber(node.Get("gapMs", 0)) && node.Get("gapMs", 0) >= 300
        parts.Push("waits " . V20_Time(node["gapMs"]) . " first")
    text := V20_StepSentence(node)
    if text = "" {
        sum := VM_StepSummary(node)
        text := Trim(sum[1] . "   " . sum[3])
    }
    parts.Push(text)
    if node.Get("scroll", "") is Map
        parts.Push("list is scrolled back first")
    if (vary := V8_VarySummaryBadge(node)) != ""
        parts.Push(RegExReplace(vary, "^⚡\[(.*)\]$", "$1"))
    if node.Get("winMatch", "") = "active"
        parts.Push("whatever window is active")
    if node.Get("note", "") != ""
        parts.Push("note: " . node["note"])
    if lastNote != ""
        parts.Push("last run: " . V20_Short(RegExReplace(String(lastNote), "^Step #\d+:?\s*"), 120))
    out := ""
    for part in parts
        out .= (A_Index > 1 ? " · " : "") . part
    return out
}

; @summary Tree ItemSelect (after what it already did): the status bar spells out the selected step with V22_Detail.
;          Not while recording or playing (the status bar is in use then), not for blocks, and not again for the
;          same step (the list re-selects it after every change, which would hide that change's own message).
; @tags macro, gui, columns, v22
V22_ShowDetail() {
    static lastNode := 0
    if VM_IsRecording() || VM_IsPlaying()
        return
    s := VMB()
    info := VMB_SelectedInfo()
    if !info || info.Kind != "node" || !VMF_IsStep(info.Node) {
        lastNode := 0
        return
    }
    node := info.Node
    if node == lastNode
        return
    lastNode := node
    num := s.FlatIndex.Get(node, "")
    app := s.ColApp is Map && s.ColApp.Has(node) ? s.ColApp[node] : V22_AppOf(node, s.Macro["settings"])
    VMB_Status(V22_Detail(node, app, s.LastNotes.Get(num, ""), num))
}
```

## 3. New self-test lines and PASS count

The 4 new `check(...)` lines are in block 3: a plain step (no number, no program: just the sentence); number and
program; a recorded pause ("waits 3.2 s first"); a step with every part (number, program, a wait set by hand,
sentence, scrolled back first, varies, whatever window is active, note, last run). `V22_ShowDetail` needs the real
window, so it is tested there (below). Self-test under Wine: **373 PASS** (after item C: 369; V21: 347),
`Failures: 0`.

## 4. Notes / anything unsure

- **Step number:** `V22_Detail(node, app, lastNote, num := "")` - the plan's three arguments plus an optional
  fourth for the number ("passed in or left out"), so the function stays pure.
- **Wording of the parts:** the plan gives the example line, not every part. A wait set by hand reads
  "waits 500 ms first (set by hand)" (the `*` of the Waits column in words), a recorded pause of 300 ms or more
  "waits 3.2 s first" (the same rule as the Waits column). "Changes each round" uses the Smart Vary text without its
  `⚡[...]` ("varies: +5px X / round"); then "whatever window is active", "note: <note>", "last run: <note>"
  (the "Step #6:" prefix removed, at most 120 characters). Times use `V20_Time`, so 400 ms reads "400 ms".
- **The sentence** is `V20_StepSentence` (the older "name   details" when it has none). With columns on it does not
  name the program (V21_ShowApp is off then), so the program appears once, as its own part.
- **Same step again:** the list re-selects the selected step after every change (Undo, Move up, a commit in the
  inspector ...), and that fires ItemSelect again. To keep the message of that change visible (for example
  "Moved up."), `V22_ShowDetail` does not show the detail again for the step it showed last. Click another row and
  back to see it again. Selecting a block, an ELSE row or an empty placeholder shows nothing new (the status bar
  keeps what it had). This is the one thing I added beyond the plan's wording; it only decides when the status
  text is written.
- The handler still calls `VMB_SyncWinMatch()`, `V7_RefreshQuickLookIfOpen()` and `V13_InspLoad()` first, in the
  same order; the detail comes last. Nothing happens while recording or playing.
- The detail is shown with columns on and off (the plan does not tie it to columns).
- Item C's note (section 3) had the two self-test blocks described the wrong way round; corrected in this commit.

## 5. Tests run (Wine)

- Load check: no errors, no warnings. Self-test: 373 PASS, `Failures: 0`. Brace check: balanced.
- Test macro in the editor: clicking step 7 shows "Step 7 · notepad · waits 300 ms first · Press Ctrl+V (paste)";
  clicking step 17 (inside Count) shows "Step 17 · notepad · Wait 200 ms".
- Notepad record / replay: `KEEP MEhello grokbot` / `line2`, 0 notes (the status bar shows the recording / playing
  messages as before). V18 macro replays as before.
