# V21 item C - container rows in the same plain style

File: `VisualMacroBlocks-makecode-telek-V21-step-list.ahk2`. The find blocks are for the file after item B; each
occurs exactly once there (checked with the script that applies them; the result is the committed file).

## 1. Find / replace blocks (in file order)

### Block 1 - in `VMB_NodeLabel` (container / control rows)

Find:
```ahk
    text := VMF_BlockText(node)
    t := node.Get("type", "")
```
Replace with:
```ahk
    text := s.ShowMeaning ? V21_BlockLine(node) : VMF_BlockText(node)      ; V21: same plain style as the step lines
    t := node.Get("type", "")
```

### Block 2 - V21 section (new functions at its end, directly above the `; ====` line of `; V4 STARTUP / SINGLE-FILE PLAYER EXPORT`)

Find:
```ahk
; ============================================================================
; V4 STARTUP / SINGLE-FILE PLAYER EXPORT
```
Replace with:
```ahk
; @summary A condition in plain words for the macro list. For a variable: "amount is 250", "amount is not 250",
;          "name contains x", "name is empty", "name is not empty" ...; other conditions use VMF__CondText.
; @tags macro, explain, gui, v21
V21_CondText(node) {
    static ops := Map("=", "is", "!=", "is not", "<", "is less than", ">", "is more than", "<=", "is at most",
        ">=", "is at least", "contains", "contains")
    if node.Get("cond", "image") != "var"
        return VMF__CondText(node)
    name := node.Get("name", "?"), op := node.Get("op", "=")
    if op = "empty" || op = "notempty"
        return name . (op = "empty" ? " is empty" : " is not empty")
    return name . " " . ops.Get(op, op) . " " . node.Get("value", "")
}

; @summary The text of a container / control row in the macro list, in the same plain style as the step lines
;          ("Repeat 5 times  (4 steps inside)", "If amount is 250", "Leave the loop" ...), with the "  // note" suffix.
;          Kinds it does not know use VMF_BlockText. VMF_BlockText itself is unchanged (code view, saved text).
; @tags macro, explain, gui, v21
V21_BlockLine(node) {
    static stops := Map("break", "Leave the loop", "continue", "Go on with the next round of the loop",
        "nextrow", "Skip this data row (it counts as failed)", "endrun", "End the run here (it counts as done)",
        "stop", "Stop the run")
    t := node.Get("type", "")
    inside := ""
    if VMF_IsContainer(node) {
        n := VMF_CountSteps(VMF_Children(node)[1])
        inside := n = 0 ? "  (no steps inside yet)" : "  (" . n . (n = 1 ? " step" : " steps") . " inside)"
    }
    switch t {
        case "repeat":
            count := node.Get("count", 1)
            line := "Repeat " . count . (count = 1 ? " time" : " times") . inside
        case "foreach":
            line := "For each row of the list" . inside
        case "for":
            stepBy := node.Get("step", 1)
            line := "Count " . node.Get("name", "i") . " from " . node.Get("from", 1) . " to " . node.Get("to", 10)
                . (stepBy = 1 ? "" : " in steps of " . stepBy) . inside
        case "until":
            line := "Repeat until " . V21_CondText(node) . (node.Get("check", "") = "after" ? ", checked after each round" : "")
                . "  (at most " . node.Get("max", 100) . " times)"
        case "if":
            line := "If " . V21_CondText(node)
        case "set":
            name := node.Get("name", "?"), value := node.Get("value", "")
            line := node.Get("ask", 0) ? "Ask me for " . name . (value = "" ? "" : ' (suggests "' . V20_Short(value, 40) . '")')
                : 'Remember "' . V20_Short(value, 40) . '" as ' . name
        case "change":
            name := node.Get("name", "?"), by := node.Get("by", 1)
            line := IsNumber(by) && by < 0 ? "Take " . Abs(by) . " from " . name : "Add " . by . " to " . name
        case "ask":
            line := "Ask me: " . node.Get("prompt", "")
        case "stop":
            action := node.Get("action", "break")
            line := stops.Get(action, action)
        case "call":
            line := "Run the macro " . RegExReplace(node.Get("path", ""), ".*[\\/]")
        default:
            return VMF_BlockText(node)
    }
    return line . (node.Get("note", "") = "" ? "" : "  // " . node["note"])
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
        v21Body := [Map("type", "delay", "ms", 1), Map("type", "delay", "ms", 2), Map("type", "repeat", "count", 2,
            "body", [Map("type", "delay", "ms", 3)])]
        check("V21 repeat row", V21_BlockLine(Map("type", "repeat", "count", 5, "body", v21Body)), "Repeat 5 times  (4 steps inside)")
        check("V21 empty repeat row", V21_BlockLine(Map("type", "repeat", "count", 1, "body", [])), "Repeat 1 time  (no steps inside yet)")
        check("V21 for each row", V21_BlockLine(Map("type", "foreach", "body", v21Body)), "For each row of the list  (4 steps inside)")
        check("V21 count row", V21_BlockLine(Map("type", "for", "name", "i", "from", 1, "to", 10, "step", 1, "body", v21Body)),
            "Count i from 1 to 10  (4 steps inside)")
        check("V21 count row in steps of 2", V21_BlockLine(Map("type", "for", "name", "i", "from", 1, "to", 10, "step", 2, "body", [v21Body[1]])),
            "Count i from 1 to 10 in steps of 2  (1 step inside)")
        check("V21 repeat until row", V21_BlockLine(Map("type", "until", "cond", "var", "name", "count", "op", ">=", "value", 3, "max", 100, "body", [])),
            "Repeat until count is at least 3  (at most 100 times)")
        check("V21 do ... until row", V21_BlockLine(Map("type", "until", "cond", "image", "appear", 1, "check", "after", "max", 20, "body", [])),
            "Repeat until image appears, checked after each round  (at most 20 times)")
        check("V21 if rows", V21_BlockLine(Map("type", "if", "cond", "var", "name", "amount", "op", "=", "value", 250, "body", [], "else", []))
            . "|" . V21_BlockLine(Map("type", "if", "cond", "image", "appear", 0, "body", [], "else", [])),
            "If amount is 250|If image is absent")
        check("V21 conditions in words", V21_CondText(Map("cond", "var", "name", "a", "op", "!=", "value", 1)) . "|"
            . V21_CondText(Map("cond", "var", "name", "a", "op", "contains", "value", "x")) . "|" . V21_CondText(Map("cond", "var", "name", "a", "op", "empty"))
            . "|" . V21_CondText(Map("cond", "var", "name", "a", "op", "notempty")) . "|" . V21_CondText(Map("cond", "var", "name", "a", "op", "<", "value", 2)),
            "a is not 1|a contains x|a is empty|a is not empty|a is less than 2")
        check("V21 web condition reuses the old text", V21_CondText(V4_CreateNode("web_if")), VMF__CondText(V4_CreateNode("web_if")))
        check("V21 set rows", V21_BlockLine(Map("type", "set", "name", "amount", "value", "250")) . "|"
            . V21_BlockLine(Map("type", "set", "name", "amount", "value", "250", "ask", 1)), 'Remember "250" as amount|Ask me for amount (suggests "250")')
        check("V21 change rows", V21_BlockLine(Map("type", "change", "name", "count", "by", 1)) . "|" . V21_BlockLine(Map("type", "change", "name", "count", "by", -2)),
            "Add 1 to count|Take 2 from count")
        check("V21 ask row", V21_BlockLine(Map("type", "ask", "prompt", "Check the screen. Continue?")), "Ask me: Check the screen. Continue?")
        check("V21 stop rows", V21_BlockLine(Map("type", "stop", "action", "break")) . "|" . V21_BlockLine(Map("type", "stop", "action", "continue"))
            . "|" . V21_BlockLine(Map("type", "stop", "action", "nextrow")) . "|" . V21_BlockLine(Map("type", "stop", "action", "endrun"))
            . "|" . V21_BlockLine(Map("type", "stop", "action", "stop")),
            "Leave the loop|Go on with the next round of the loop|Skip this data row (it counts as failed)|End the run here (it counts as done)|Stop the run")
        check("V21 run macro row", V21_BlockLine(Map("type", "call", "path", "C:\macros\orders.vmacro.json")), "Run the macro orders.vmacro.json")
        check("V21 note kept on block rows", V21_BlockLine(Map("type", "repeat", "count", 2, "body", [], "note", "twice")), "Repeat 2 times  (no steps inside yet)  // twice")
        check("V21 other blocks keep the older text", V21_BlockLine(Map("type", "ndc", "name", "ndc", "source", "")), VMF_BlockText(Map("type", "ndc", "name", "ndc", "source", "")))
        player := V4_PlayerSource(source, macro)
```

## 2. Full text of each new function

```ahk
; @summary A condition in plain words for the macro list. For a variable: "amount is 250", "amount is not 250",
;          "name contains x", "name is empty", "name is not empty" ...; other conditions use VMF__CondText.
; @tags macro, explain, gui, v21
V21_CondText(node) {
    static ops := Map("=", "is", "!=", "is not", "<", "is less than", ">", "is more than", "<=", "is at most",
        ">=", "is at least", "contains", "contains")
    if node.Get("cond", "image") != "var"
        return VMF__CondText(node)
    name := node.Get("name", "?"), op := node.Get("op", "=")
    if op = "empty" || op = "notempty"
        return name . (op = "empty" ? " is empty" : " is not empty")
    return name . " " . ops.Get(op, op) . " " . node.Get("value", "")
}

; @summary The text of a container / control row in the macro list, in the same plain style as the step lines
;          ("Repeat 5 times  (4 steps inside)", "If amount is 250", "Leave the loop" ...), with the "  // note" suffix.
;          Kinds it does not know use VMF_BlockText. VMF_BlockText itself is unchanged (code view, saved text).
; @tags macro, explain, gui, v21
V21_BlockLine(node) {
    static stops := Map("break", "Leave the loop", "continue", "Go on with the next round of the loop",
        "nextrow", "Skip this data row (it counts as failed)", "endrun", "End the run here (it counts as done)",
        "stop", "Stop the run")
    t := node.Get("type", "")
    inside := ""
    if VMF_IsContainer(node) {
        n := VMF_CountSteps(VMF_Children(node)[1])
        inside := n = 0 ? "  (no steps inside yet)" : "  (" . n . (n = 1 ? " step" : " steps") . " inside)"
    }
    switch t {
        case "repeat":
            count := node.Get("count", 1)
            line := "Repeat " . count . (count = 1 ? " time" : " times") . inside
        case "foreach":
            line := "For each row of the list" . inside
        case "for":
            stepBy := node.Get("step", 1)
            line := "Count " . node.Get("name", "i") . " from " . node.Get("from", 1) . " to " . node.Get("to", 10)
                . (stepBy = 1 ? "" : " in steps of " . stepBy) . inside
        case "until":
            line := "Repeat until " . V21_CondText(node) . (node.Get("check", "") = "after" ? ", checked after each round" : "")
                . "  (at most " . node.Get("max", 100) . " times)"
        case "if":
            line := "If " . V21_CondText(node)
        case "set":
            name := node.Get("name", "?"), value := node.Get("value", "")
            line := node.Get("ask", 0) ? "Ask me for " . name . (value = "" ? "" : ' (suggests "' . V20_Short(value, 40) . '")')
                : 'Remember "' . V20_Short(value, 40) . '" as ' . name
        case "change":
            name := node.Get("name", "?"), by := node.Get("by", 1)
            line := IsNumber(by) && by < 0 ? "Take " . Abs(by) . " from " . name : "Add " . by . " to " . name
        case "ask":
            line := "Ask me: " . node.Get("prompt", "")
        case "stop":
            action := node.Get("action", "break")
            line := stops.Get(action, action)
        case "call":
            line := "Run the macro " . RegExReplace(node.Get("path", ""), ".*[\\/]")
        default:
            return VMF_BlockText(node)
    }
    return line . (node.Get("note", "") = "" ? "" : "  // " . node["note"])
}
```

## 3. New self-test lines and PASS count

The 17 new `check(...)` lines are in block 3 (each kind: repeat, empty repeat, for each, count, count in steps of 2,
repeat until, do ... until, if, the condition words, web condition, set, change, ask, stop, run macro, note,
a kind left as before). Self-test under Wine: **338 PASS** (after item B: 321; V20: 274), `Failures: 0`.

## 4. Notes / anything unsure

- Used only when "Show meaning" is on (`s.ShowMeaning`), like the step sentences; otherwise the rows are as before.
  `VMF_BlockText` is unchanged (code view, saved text). The `(choose a data file above!)` and `[image ...]` suffixes
  that `VMB_NodeLabel` adds are kept.
- The ELSE row and the ELSE IF rows (made in `VMB_AddBody`, not by `VMB_NodeLabel`) are unchanged.
- Step count = `VMF_CountSteps(VMF_Children(node)[1])`, the same as `V13_Explain`: it counts everything inside the
  first branch, nested blocks included (a REPEAT with 2 steps plus a REPEAT holding 1 step = 4). An empty block says
  `(no steps inside yet)`; one step says `(1 step inside)`; `Repeat 1 time` is singular.
- `until` with "check after" (DO ... UNTIL) adds `, checked after each round` so it still differs from REPEAT UNTIL.
- `set` with "ask me" reads `Ask me for amount (suggests "250")`; `change` with a negative number reads
  `Take 2 from count`.
- The five stop actions read: `Leave the loop`, `Go on with the next round of the loop`,
  `Skip this data row (it counts as failed)`, `End the run here (it counts as done)`, `Stop the run` (taken from the
  edit box's own descriptions).
- Kinds the plan does not list (`ndc`, `pickdata`) keep `VMF_BlockText`.
- Image / web / pixel conditions reuse `VMF__CondText` ("image appears", "web element #x exists", ...).

## 5. Tests run (Wine)

- Load check: no errors, no warnings. Self-test: 338 PASS, `Failures: 0`. Brace check: balanced.
- Notepad record / replay: `KEEP MEhello grokbot` / `line2`, 0 notes. V18 macro replays as before.
- Screenshot of the test macro (`/workspace/v21work/steplist.png` on the test machine): `Repeat 5 times  (2 steps inside)`,
  `Count i from 1 to 10 in steps of 2  (1 step inside)`, `If amount is not 250`, `Remember "250" as amount`,
  `Add 1 to count`, `Repeat until count is at least 3  (at most 100 times)`, `Leave the loop`,
  `Ask me: Check the screen. Continue?  // look first`, `Run the macro other.vmacro.json`.
