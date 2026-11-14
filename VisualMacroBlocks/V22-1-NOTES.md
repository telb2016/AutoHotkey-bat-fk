# V22.1 notes (answers round) - handback

File: `VisualMacroBlocks-makecode-telek-V22-columns.ahk2`, edited in place (no new file), one added header line
`; V22.1 = answers round: see GROK-PLAN-V22-answers.md`. One commit per change (1-5), this file last.

## Result

- Self-test under Wine (AutoHotkey 2.0.27): **388 PASS, `Failures: 0`** (was 373: +1 change 1, +4 change 2,
  +8 change 3, +1 change 4, +1 change 5; the existing `NOTEPAD` expectation was changed to `notepad`). Validate: rc 0, no output.
- Wine window tests after every change: Notepad record / replay (`KEEP MEhello grokbot` / `line2`, 0 notes) and replay of
  an older (V18-recorded) macro in V22.1 (same result, 0 notes). Screenshots after change 3 and 4: nested macro rows, Program
  column and header line up at depth 0 / 1 / 2 in Easy and Full layout, at size 9 and size 13 (A+ four times); the header
  is not clipped and the tree and the Step settings panel start below it.
- PC-TEST.md: check 3 got the "press ? and read me the 'Column check' line" sentence (plan change 5). I also changed the
  expected PASS count in check 0 from 373 to 388 (stale otherwise).

## The changes (diff of the .ahk2 per commit, zero context)

```diff
=== 22687068 V22.1 change 1: Program column in lower case
@@ -1,0 +2 @@
+; V22.1 = answers round: see GROK-PLAN-V22-answers.md
@@ -14360 +14361 @@ V22_AppOf(node, settings := 0) {
-        return V20_AppName(win["exe"])
+        return StrLower(V20_AppName(win["exe"]))        ; V22.1: lower case for the column only
@@ -14368 +14369 @@ V22_AppOf(node, settings := 0) {
-        return target = "" ? "" : V20_TargetName(target)
+        return target = "" ? "" : StrLower(V20_TargetName(target))     ; V22.1: lower case for the column only
@@ -15565 +15566,3 @@ V4_SelfTest(path) {
-            "notepad,notepad,calc,calc,NOTEPAD")
+            "notepad,notepad,calc,calc,notepad")
+        check("V22.1 program names in lower case, web page unchanged", V22_AppOf(Map("type", "click", "win", Map("exe", "NOTEPAD.EXE"))) . "|"
+            . V22_AppOf(Map("type", "det_use_window", "target", "ahk_exe CALC.EXE")) . "|" . V22_AppOf(Map("type", "web_click", "selector", "#a")), "notepad|calc|web page")
=== d2af1ded V22.1 change 2: Program column follows Use Window From Here On
@@ -14375 +14375,2 @@ V22_AppOf(node, settings := 0) {
-;          the nearest earlier step that had one. flatSteps = VMF_Flatten(blocks); blocks that are not steps are skipped.
+;          the nearest earlier step that had one. V22.1: a det_* / input_* step with a blank or missing target shows the
+;          program of the last "Use Window From Here On" before it (blank = the Macro window), in list order. flatSteps = VMF_Flatten(blocks); blocks that are not steps are skipped.
@@ -14380 +14381 @@ V22_FillApps(flatSteps, settings := 0) {
-    apps := Map(), starts := Map(), prevApp := "", isFirst := true
+    apps := Map(), starts := Map(), prevApp := "", isFirst := true, useTarget := ""
@@ -14384,0 +14386,9 @@ V22_FillApps(flatSteps, settings := 0) {
+        t := step.Get("type", "")
+        if t = "det_use_window"                          ; V22.1: later blank-target steps follow this window (display only,
+            useTarget := Trim(String(step.Get("target", "")))        ; the same rule as V16_FallbackTarget at play time)
+        else if (SubStr(t, 1, 4) = "det_" || SubStr(t, 1, 6) = "input_") && Trim(String(step.Get("target", ""))) = ""
+            && !(step.Get("win", "") is Map && step["win"].Get("exe", "") != "") {
+            follow := useTarget != "" ? useTarget : (settings is Map ? Trim(settings.Get("defaultTarget", "")) : "")
+            if follow != ""
+                own := StrLower(V20_TargetName(follow))
+        }
@@ -15573,0 +15584,12 @@ V4_SelfTest(path) {
+        v22S := [Map("type", "det_use_window", "target", "ahk_exe b.exe"), Map("type", "det_normalize_win", "target", ""), Map("type", "input_send")]
+        v22R := V22_FillApps(v22S, v22Set)
+        check("V22.1 Use Window B, then blank-target steps -> b", v22R.App[v22S[1]] . "," . v22R.App[v22S[2]] . "," . v22R.App[v22S[3]], "b,b,b")
+        v22S := [Map("type", "det_use_window", "target", "ahk_exe b.exe"), Map("type", "det_use_window", "target", ""), Map("type", "det_normalize_win", "target", "")]
+        v22R := V22_FillApps(v22S, v22Set)
+        check("V22.1 Use Window blank, then Normalize -> the Macro window's program", v22R.App[v22S[1]] . "," . v22R.App[v22S[2]] . "," . v22R.App[v22S[3]], "b,notepad,notepad")
+        v22S := [Map("type", "det_normalize_win", "target", ""), Map("type", "input_send", "target", " "), Map("type", "det_normalize_win", "target", "ahk_exe c.exe")]
+        v22R := V22_FillApps(v22S, v22Set)
+        check("V22.1 no Use Window at all -> the Macro window's program; own target kept", v22R.App[v22S[1]] . "," . v22R.App[v22S[2]] . "," . v22R.App[v22S[3]], "notepad,notepad,c")
+        v22S := [Map("type", "det_use_window", "target", "ahk_exe b.exe"), Map("type", "det_normalize_win", "target", "ahk_exe c.exe"), Map("type", "click", "win", Map("exe", "d.exe")), Map("type", "det_normalize_win", "target", "")]
+        v22R := V22_FillApps(v22S, v22Set)
+        check("V22.1 steps with their own window / target are unchanged", v22R.App[v22S[2]] . "," . v22R.App[v22S[3]] . "," . v22R.App[v22S[4]], "c,d,b")
=== e01223e5 V22.1 change 3: left margin sized to the macro (s.MaxDepth)
@@ -223 +223 @@ VMB() {
-        Columns: 1, ColApp: 0, ColStarts: 0, IndentChars: 3, IndentSeen: ""}
+        Columns: 1, ColApp: 0, ColStarts: 0, IndentChars: 3, IndentSeen: "", MaxDepth: 0}
@@ -661,0 +662 @@ VMB_Refresh(selectNode := "") {
+    s.MaxDepth := V22_MaxDepth(s.Macro["blocks"])               ; V22.1: the left margin is sized to the deepest row
@@ -701 +702 @@ VMB_AddBody(list, parentId, owner, emptyText := "(empty - drag steps here)", off
-                    label := (cols ? V22_Margin(depth + 1, s.IndentChars) : " ") . "ELSE IF " . VMF__CondText(elif)
+                    label := (cols ? V22_Margin(depth + 1, s.IndentChars, s.MaxDepth) : " ") . "ELSE IF " . VMF__CondText(elif)
@@ -710 +711 @@ VMB_AddBody(list, parentId, owner, emptyText := "(empty - drag steps here)", off
-                elseId := s.TV.Add((cols ? V22_Margin(depth + 1, s.IndentChars) : " ") . "ELSE (when none of the above is true) ", id, "Bold Expand")
+                elseId := s.TV.Add((cols ? V22_Margin(depth + 1, s.IndentChars, s.MaxDepth) : " ") . "ELSE (when none of the above is true) ", id, "Bold Expand")
@@ -731 +732 @@ VMB_NodeLabel(node, depth := unset) {
-                V22_WaitText(node), V22_Marks(node, lastNote), off . V22_Sentence(node, lastNote), depth, s.IndentChars) . " "
+                V22_WaitText(node), V22_Marks(node, lastNote), off . V22_Sentence(node, lastNote), depth, s.IndentChars, s.MaxDepth) . " "
@@ -749 +750 @@ VMB_NodeLabel(node, depth := unset) {
-        return V22_Margin(depth, s.IndentChars) . off . text . " "
+        return V22_Margin(depth, s.IndentChars, s.MaxDepth) . off . text . " "
@@ -14346,2 +14347,3 @@ V22_Cols() {
-; @summary The spaces in front of a row: 8 * indentChars for a top-level row, depth * indentChars fewer for a
-;          deeper row (the tree's own indent makes up the difference), never fewer than none.
+; @summary The spaces in front of a row: maxDepth * indentChars for a top-level row, depth * indentChars fewer for a
+;          deeper row (the tree's own indent makes up the difference), never fewer than none. V22.1: maxDepth is the
+;          deepest tree level of the current macro (s.MaxDepth); the default 8 is the old fixed value.
@@ -14349,2 +14351,2 @@ V22_Cols() {
-V22_Margin(depth, indentChars) {
-    n := Max(0, (8 - Max(0, depth)) * indentChars)
+V22_Margin(depth, indentChars, maxDepth := 8) {
+    n := Max(0, (maxDepth - Max(0, depth)) * indentChars)
@@ -14447 +14449 @@ V22_Sentence(node, lastNote := "") {
-V22_Row(num, app, startsApp, wait, marks, sentence, depth, indentChars) {
+V22_Row(num, app, startsApp, wait, marks, sentence, depth, indentChars, maxDepth := 8) {
@@ -14452 +14454 @@ V22_Row(num, app, startsApp, wait, marks, sentence, depth, indentChars) {
-    return V22_Margin(depth, indentChars) . numCol . " " . V22_Pad(app, cols[2].W) . " " . V22_Pad(wait, cols[3].W)
+    return V22_Margin(depth, indentChars, maxDepth) . numCol . " " . V22_Pad(app, cols[2].W) . " " . V22_Pad(wait, cols[3].W)
@@ -14458 +14460 @@ V22_Row(num, app, startsApp, wait, marks, sentence, depth, indentChars) {
-V22_Header(indentChars) {
+V22_Header(indentChars, maxDepth := 8) {
@@ -14460 +14462 @@ V22_Header(indentChars) {
-    return V22_Margin(0, indentChars) . V22_Pad("#", cols[1].W) . " " . V22_Pad("Program", cols[2].W) . " "
+    return V22_Margin(0, indentChars, maxDepth) . V22_Pad("#", cols[1].W) . " " . V22_Pad("Program", cols[2].W) . " "
@@ -14480,0 +14483,21 @@ V22_MarkChars(plain := "") {
+; @summary V22.1: the deepest TREE level that will hold a row for this block list (0 = nothing nested). Counted the way
+;          VMB_AddBody adds rows: the rows of a list sit at its depth; a container's body is one level deeper; an IF adds an
+;          ELSE IF row per elif and one ELSE row at depth + 1 with their bodies at depth + 2; an empty list adds one
+;          "(empty ...)" placeholder row at its own depth. list = the macro's blocks, depth = the level of that list.
+; @tags macro, gui, columns, v22
+V22_MaxDepth(list, depth := 0) {
+    deepest := depth
+    for node in list {
+        if !(node is Map) || !VMF_IsContainer(node)
+            continue
+        VMF_Children(node)                              ; makes sure body / elifs / else are lists, like VMB_AddBody
+        deepest := Max(deepest, V22_MaxDepth(node["body"], depth + 1))
+        if node["type"] = "if" {
+            for elif in VMF_Elifs(node)
+                deepest := Max(deepest, depth + 1, V22_MaxDepth(elif["body"], depth + 2))
+            deepest := Max(deepest, depth + 1, V22_MaxDepth(node["else"], depth + 2))
+        }
+    }
+    return deepest
+}
+
@@ -14542 +14565 @@ V22_PlaceHeader() {
-        head.Text := V22_Header(s.IndentChars)
+        head.Text := V22_Header(s.IndentChars, s.MaxDepth)
@@ -15609,0 +15633,16 @@ V4_SelfTest(path) {
+        v22Rm0 := V22_Row(1, "notepad", true, "", "", "Click", 0, 3, 0)
+        check("V22.1 maxDepth 0: a depth-0 row has no leading spaces", InStr(v22Rm0, "1") . "|" . InStr(V22_Header(3, 0), "#") . "|" . V22_Margin(0, 3, 0) . "|", "1|1||")
+        v22Rm1 := V22_Row(2, "notepad", true, "", "", "Click", 1, 3, 2), v22Rm2 := V22_Row(3, "calc", false, "", "", "Press", 2, 3, 2)
+        v22Rm0 := V22_Row(1, "notepad", true, "", "", "Click", 0, 3, 2)
+        check("V22.1 maxDepth 2: Program lines up at depth 0, 1 and 2, and so does the header",
+            (InStr(v22Rm0, "notepad") + 0) . "," . (InStr(v22Rm1, "notepad") + 3) . "," . (InStr(v22Rm2, "calc") + 6) . "," . InStr(V22_Header(3, 2), "Program"), "13,13,13,13")
+        check("V22.1 margin = (maxDepth - depth) * indent, never negative", StrLen(V22_Margin(0, 3, 2)) . "," . StrLen(V22_Margin(1, 3, 2)) . "," . StrLen(V22_Margin(2, 3, 2)) . "," . StrLen(V22_Margin(5, 3, 2)), "6,3,0,0")
+        v22Rep := Map("type", "repeat", "count", 2, "body", [Map("type", "click")])
+        v22If := Map("type", "if", "cond", "var", "name", "", "op", "=", "value", "", "body", [Map("type", "click")], "else", [])
+        v22IfE := Map("type", "if", "cond", "var", "name", "", "op", "=", "value", "", "body", [], "else", [Map("type", "click")],
+            "elifs", [Map("type", "elif", "cond", "var", "body", [Map("type", "repeat", "count", 1, "body", [Map("type", "click")])])])
+        check("V22.1 maxDepth: nothing nested / flat steps / empty macro", V22_MaxDepth([]) . V22_MaxDepth([Map("type", "click"), Map("type", "delay", "ms", 1)]), "00")
+        check("V22.1 maxDepth: a Repeat with a step / an empty Repeat", V22_MaxDepth([v22Rep]) . V22_MaxDepth([Map("type", "repeat", "count", 1, "body", [])]), "11")
+        check("V22.1 maxDepth: IF counts its ELSE row and the empty ELSE placeholder", V22_MaxDepth([v22If]), 2)
+        check("V22.1 maxDepth: ELSE IF body holding a Repeat is three levels", V22_MaxDepth([v22IfE]), 3)
+        check("V22.1 maxDepth: a Repeat inside a Repeat", V22_MaxDepth([Map("type", "repeat", "count", 1, "body", [v22Rep])]), 2)
=== a1eaffd3 V22.1 change 4: column header height follows the font
@@ -223 +223 @@ VMB() {
-        Columns: 1, ColApp: 0, ColStarts: 0, IndentChars: 3, IndentSeen: "", MaxDepth: 0}
+        Columns: 1, ColApp: 0, ColStarts: 0, IndentChars: 3, IndentSeen: "", MaxDepth: 0, CharH: 0}
@@ -14539,0 +14540 @@ V22_ApplyTreeFont(refresh := true) {
+    s.CharH := NumGet(ext, 4, "Int")                                       ; V22.1: text height in pixels, for the header line
@@ -14552,0 +14554,7 @@ V22_ApplyTreeFont(refresh := true) {
+; @summary V22.1: height of the header line in the window's 96-dpi units: the tree font's text height in pixels
+;          (s.CharH) + 2, converted from screen pixels; 16 when the height is not known (charH < 1).
+; @tags macro, gui, columns, v22
+V22_HeaderHeight(charH, dpi := A_ScreenDPI) {
+    return charH < 1 ? 16 : Round((charH + 2) * 96 / dpi)
+}
+
@@ -14572 +14580,10 @@ V22_PlaceHeader() {
-            s.TV.GetPos(&tx, &ty, &tw)
+            s.TV.GetPos(&tx, &ty, &tw, &th)
+            head.GetPos(, &hy)
+            hh := V22_HeaderHeight(s.CharH)                                ; V22.1: the header follows the font height
+            if ty - hy != hh {                                             ; the tree starts hh below the header: move its top
+                shift := hh - (ty - hy)                                    ; and height by the same amount (bottom stays)
+                s.TV.Move(, ty + shift, , Max(80, th - shift))
+                ty += shift, th -= shift
+                if s.Insp
+                    V13_InspLayout(tx + tw + 10, ty, s.Insp.Width, th)     ; the Step settings panel follows the tree
+            }
@@ -14574 +14591 @@ V22_PlaceHeader() {
-            head.Move(hx, ty - 16, Max(50, tx + tw - hx), 16)
+            head.Move(hx, hy, Max(50, tx + tw - hx), hh)
@@ -15648,0 +15666 @@ V4_SelfTest(path) {
+        check("V22.1 header height = text height + 2 (96 dpi / 144 dpi / unknown)", V22_HeaderHeight(16, 96) . "," . V22_HeaderHeight(30, 96) . "," . V22_HeaderHeight(20, 144) . "," . V22_HeaderHeight(0, 96), "18,32,15,16")
=== d58a6298 V22.1 change 5: Column check line in both help texts, PC checklist
@@ -12550 +12550 @@ V17_EasyHelp(*) {
-        . "`nEmergency exit: Ctrl+Shift+X.", "Visual Macro Blocks V18 - Easy mode", "Iconi")
+        . "`nEmergency exit: Ctrl+Shift+X." . V22_ColumnCheckLine(VMB().IndentSeen), "Visual Macro Blocks V18 - Easy mode", "Iconi")
@@ -14553,0 +14554,7 @@ V22_ApplyTreeFont(refresh := true) {
+; @summary V22.1: the last line of the two help texts, "`nColumn check: " + the indent values the list measured
+;          (s.IndentSeen); "" when that is not a non-empty string (columns never switched on yet).
+; @tags macro, gui, columns, v22
+V22_ColumnCheckLine(seen) {
+    return seen is String && seen != "" ? "`nColumn check: " . seen : ""
+}
+
@@ -14836 +14843 @@ V4_Help(*) {
-        . "  dynamic key repetition, or counter/column variables.",
+        . "  dynamic key repetition, or counter/column variables." . V22_ColumnCheckLine(VMB().IndentSeen),
@@ -15666,0 +15674,2 @@ V4_SelfTest(path) {
+        check("V22.1 column check line: text / empty / not a string", V22_ColumnCheckLine("char 7 px, asked 21 px, got 21 px, 3 characters") . "|" . V22_ColumnCheckLine("") . "|" . V22_ColumnCheckLine(0) . "|",
+            "`nColumn check: char 7 px, asked 21 px, got 21 px, 3 characters|||")
```

## Notes the plan asked for

- **How `MaxDepth` matches the add function:** `V22_MaxDepth(list, depth)` mirrors `VMB_AddBody`. A list's rows sit at its
  `depth`; a container's body is added at `depth + 1`; for an IF each ELSE IF row and the ELSE row sit at `depth + 1` and
  their bodies at `depth + 2` (the ELSE row always exists, so an IF at depth d gives at least d + 1; an empty ELSE gives
  an "(empty)" placeholder at d + 2). An empty list returns its own `depth` (the placeholder level). It calls
  `VMF_Children(node)` first, as the add function does, so body / elifs / else are lists. `s.MaxDepth` is set once per
  `VMB_Refresh`, before rows are built; single-row re-labels (`VMB_NodeLabel` from the edit code) use the stored value.
  Checked on a nested macro in the Wine window and by 5 self-test lines (flat 0, Repeat 1, empty Repeat 1, IF 2, ELSE IF with a Repeat 3, Repeat in Repeat 2).
- **Use Window inside an IF:** the Program-column walk is in list order, so a "Use Window From Here On" inside an IF
  branch also colours the blank-target rows after the IF (even if that branch did not run). Display only; accepted by the plan.
- **Change 2 detail:** a det_* / input_* step with a missing `target` (not just a blank one) also follows `useTarget`,
  or the Macro window's program (`defaultTarget`) when there is no Use Window. With no `defaultTarget` either, the old
  rule (program of the step before) still applies. Steps with their own `win.exe` are untouched.
- **Change 4 detail:** `s.CharH` = text height from `GetTextExtentPoint32W` in `V22_ApplyTreeFont`; header height =
  `V22_HeaderHeight(s.CharH)` = (CharH + 2) converted from screen pixels to the window's 96-dpi units (16 when unknown).
  `V22_PlaceHeader` compares the gap between header top and tree top with that height; if different it moves the tree
  top down and shrinks its height by the same amount (bottom stays), re-lays the Step settings panel to the tree, then
  sizes the header. Layouts (Full / Easy) reset the gap to 16 and call `VMB_OnSize` -> `V22_PlaceHeader`, so it is redone
  after a layout change, window resize and zoom (A+ / A-, Ctrl +/-).

## Not proven by Wine / unsure

- Real Consolas and the real tree control on Windows (Wine used a mapped stand-in font); whether Windows takes the small
  indent - the new `Column check` line in `?` shows the measured values.
- Mixing GetPos / Move units at 125 % / 150 % scaling (the existing code already treats Move as 96-dpi units; I kept that
  and converted the new header height the same way). Wine ran at 96 dpi only. PC-TEST check 10 covers it.
- Header height at large zoom on a real PC: please look for clipped header letters (check 4).
- `s.MaxDepth` is not recomputed by a single-row re-label; the plan says any nesting change goes through `VMB_Refresh`.
