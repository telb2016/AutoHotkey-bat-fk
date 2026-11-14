# V21 item B - sentences for the remaining kinds

File: `VisualMacroBlocks-makecode-telek-V21-step-list.ahk2`. The find blocks are for the file after item A; each
occurs exactly once there (checked with the script that applies them; the result is the committed file).

## 1. Find / replace blocks (in file order)

### Block 1 - `V20_StepSentence` (its @summary: the web / input / measuring kinds now get a sentence too)

Find:
```ahk
; @summary The main sentence of a step line - what the step does, in plain words. "" for kinds that keep the
;          older "Name   details" form (web blocks, basic-input blocks, the measuring blocks).
```
Replace with:
```ahk
; @summary The main sentence of a step line - what the step does, in plain words. V21: web blocks, basic-input blocks
;          and the measuring blocks get theirs from V21_MoreSentence; "" for kinds that keep the older form.
```

### Block 2 - end of `V20_StepSentence` (its final `return ""`)

Find:
```ahk
                . (V4_Bool(node.Get("pressTab", 1)) ? ", press Tab" : "")
    }
    return ""
}
```
Replace with:
```ahk
                . (V4_Bool(node.Get("pressTab", 1)) ? ", press Tab" : "")
    }
    return V21_MoreSentence(node)
}
```

### Block 3 - V21 section (new functions at its end, directly above the `; ====` line of `; V4 STARTUP / SINGLE-FILE PLAYER EXPORT`)

Find:
```ahk
; ============================================================================
; V4 STARTUP / SINGLE-FILE PLAYER EXPORT
```
Replace with:
```ahk
; @summary A short, readable name for a web element from its CSS selector, for a step line: "#submit" -> "submit" in
;          quotes; [name="email"], [aria-label="Search"], [data-testid="save-btn"] -> the value; otherwise the last
;          simple part, plus the nearest "#id" to its left ("form#login button.primary" -> "button.primary in #login").
;          At most 40 characters (V20_Short). "" for a blank selector.
; @tags macro, explain, web, v21
V21_SelectorName(selector) {
    sel := Trim(String(selector))
    if sel = ""
        return ""
    parts := [], part := "", depth := 0, quote := ""
    Loop Parse, sel {
        ch := A_LoopField
        if quote != "" {                        ; inside a quoted attribute value: spaces and > do not split
            part .= ch
            if ch = quote
                quote := ""
            continue
        }
        if ch = '"' || ch = "'" {
            quote := ch, part .= ch
            continue
        }
        if ch = "[" || ch = "("
            depth += 1
        else if ch = "]" || ch = ")"
            depth := Max(0, depth - 1)
        if depth = 0 && (ch = " " || ch = "`t" || ch = ">" || ch = "+" || ch = "~") {
            if part != ""
                parts.Push(part)
            part := ""
            continue
        }
        part .= ch
    }
    if part != ""
        parts.Push(part)
    if !parts.Length
        return V20_Short(sel, 40)
    lastPart := parts[parts.Length]
    if RegExMatch(lastPart, "^#([\w-]+)$", &m)
        return V20_Short('"' . m[1] . '"', 40)
    if RegExMatch(lastPart, "i)^[\w-]*\[(?:name|aria-label|data-testid)\s*=\s*([`"']?)(.*?)\1\s*\]$", &m)
        name := m[2]
    else
        name := lastPart
    loop parts.Length - 1 {
        if RegExMatch(parts[parts.Length - A_Index], "#([\w-]+)", &m) {
            name .= " in #" . m[1]
            break
        }
    }
    return V20_Short(name, 40)
}

; @summary A web address for a step line: host + path only, no "https://", no query string or #part
;          ("https://example.com/orders?id=5" -> "example.com/orders").
; @tags macro, explain, web, v21
V21_UrlText(url) {
    url := RegExReplace(Trim(String(url)), "[?#].*$")
    url := RegExReplace(url, "i)^[a-z][a-z0-9+.\-]*://")
    return RegExReplace(url, "(?<=.)/$")
}

; @summary The sentence of a step that V20_StepSentence does not handle: web blocks, basic-input blocks and the
;          measuring blocks. Reads the fields named in V4_WebDefs / V4_InputDefs / V10_DetDefs. "" for any other kind
;          (the older "Name   details" form is shown then).
; @tags macro, explain, web, v21
V21_MoreSentence(node) {
    static colours := Map("DiscernYellow", "yellow (the active box)", "CernerDoorBlue", "the door-icon blue",
        "HighlightBlue", "the selection blue", "DisabledGrey", "greyed out", "WhiteReady", "white (ready)")
    static places := Map("TopLeft", "top left", "BottomCenter", "bottom centre", "TopRight", "top right",
        "BottomRight", "bottom right", "BottomLeft", "bottom left", "Center", "centre")
    t := node.Get("type", "")
    el := V21_SelectorName(node.Get("selector", ""))
    el := el = "" ? "the element" : el
    frame := Trim(node.Get("frame", ""))
    inFrame := frame = "" ? "" : "  (inside frame " . V21_SelectorName(frame) . ")"
    keep := Trim(node.Get("variable", ""))
    keepText := keep = "" ? "" : ", remember it as " . keep
    btn := node.Get("button", "Left"), count := node.Get("count", 1)
    clickVerb := (btn = "Left" ? "" : StrLower(btn) . "-") . (count = 2 ? "double-click" : "click")
    switch t {
        case "web_launch":
            browser := RegExReplace(RegExReplace(node.Get("browser", "Edge"), ".*[\\/]"), "i)\.exe$")
            return "Web: open the " . browser . " browser for the macro (port " . node.Get("port", 9222) . ")"
        case "web_connect", "web_tab":
            match := node.Get("match", "")
            if match = ""
                return t = "web_connect" ? "Web: connect to the only open tab" : "Web: switch to the other tab"
            return (t = "web_connect" ? "Web: connect to the tab" : "Web: switch to the tab") . " whose " . node.Get("by", "url")
                . (node.Get("mode", "contains") = "exact" ? " is " : " contains ") . '"' . V20_Short(match, 40) . '"'
        case "web_navigate":
            return "Web: go to " . V21_UrlText(node.Get("url", ""))
        case "web_newtab":
            url := V21_UrlText(node.Get("url", "about:blank"))
            return url = "" || url = "about:blank" ? "Web: open a new empty tab" : "Web: open a new tab at " . url
        case "web_back": return "Web: go back a page"
        case "web_forward": return "Web: go forward a page"
        case "web_reload": return "Web: reload the page"
        case "web_close": return "Web: close the tab"
        case "web_disconnect": return "Web: let go of the browser (it stays open)"
        case "web_wait":
            cond := node.Get("condition", "visible")
            how := cond = "present" ? "be on the page" : cond = "hidden" ? "be hidden" : cond = "absent" ? "go away"
                : cond = "text" ? 'show "' . V20_Short(node.Get("value", ""), 30) . '"' : "appear"
            return "Web: wait for " . el . " to " . how . " (up to " . V20_Time(node.Get("timeoutMs", 10000)) . ")" . inFrame
        case "web_click":
            return "Web: " . clickVerb . " " . el . inFrame
        case "web_fill":
            if V4_Bool(node.Get("ask", 0))              ; asked each run: never show the text
                return "Web: type what you answer when asked into " . el . inFrame
            return 'Web: type "' . V20_Short(node.Get("value", ""), 40) . '" into ' . el . inFrame
        case "web_select":
            return 'Web: pick "' . V20_Short(node.Get("value", ""), 40) . '" in ' . el . inFrame
        case "web_check":
            return "Web: " . (V4_Bool(node.Get("checked", 1)) ? "tick " : "untick ") . el . inFrame
        case "web_read":
            attr := node.Get("attribute", "textContent")
            return "Web: read " . (RegExMatch(attr, "i)^(textContent|innerText)$") ? "the text" : "the " . attr) . " of " . el
                . keepText . inFrame
        case "web_count":
            return "Web: count how many " . el . " there are" . keepText . inFrame
        case "web_exists":
            return "Web: check whether " . el . " is there" . keepText . inFrame
        case "web_focus":
            return "Web: put the cursor in " . el . inFrame
        case "web_scroll":
            return "Web: scroll " . el . " into view" . inFrame
        case "web_keys":
            return "Web: press " . node.Get("key", "Enter") . (Trim(node.Get("selector", "")) = "" ? "" : " in " . el) . inFrame
        case "web_screenshot":
            return "Web: save a picture of the page as " . RegExReplace(node.Get("path", ""), ".*[\\/]")
        case "web_eval":
            return 'Web: run the script "' . V20_Short(node.Get("expression", ""), 40) . '"' . keepText
        case "web_cdp":
            return "Web: send the browser command " . node.Get("method", "") . keepText
        case "input_send", "input_sendinput", "input_sendevent":
            if V4_Bool(node.Get("ask", 0))
                return "Send keys: what you answer when asked (each run)"
            return "Send keys: " . V20_KeysText(node.Get("value", ""))
        case "input_sendtext":
            if V4_Bool(node.Get("ask", 0))
                return "Type what you answer when asked (each run)"
            return 'Type "' . V20_Short(node.Get("value", "")) . '"'
        case "input_keydown":
            return "Hold " . node.Get("key", "Ctrl") . " down"
        case "input_keyup":
            return "Let go of " . node.Get("key", "Ctrl")
        case "det_wait_settled":
            return "Wait until the area (" . node.Get("x1", 0) . ", " . node.Get("y1", 0) . ")–(" . node.Get("x2", 0) . ", "
                . node.Get("y2", 0) . ") stops changing"
        case "det_wait_pixel":
            mode := node.Get("colorMode", "DiscernYellow")
            colour := mode = "NearHex" ? "close to #" . node.Get("colorHex", "") : colours.Get(mode, mode)
            return "Wait until the dot at (" . node.Get("x", 0) . ", " . node.Get("y", 0) . ") is "
                . (V4_Bool(node.Get("appear", 1)) ? "" : "no longer ") . colour
        case "det_anchor_click":
            clickVerb := StrUpper(SubStr(clickVerb, 1, 1)) . SubStr(clickVerb, 2)
            anchor := node.Get("anchor", "BottomCenter")
            if anchor = "ProportionalPct"
                return clickVerb . " at " . node.Get("pctX", 50) . "% across and " . node.Get("pctY", 50) . "% down the window"
            place := places.Get(anchor, anchor)
            dx := node.Get("dx", 0), dy := node.Get("dy", 0)
            dx := IsNumber(dx) ? Number(dx) : 0, dy := IsNumber(dy) ? Number(dy) : 0
            move := (dx ? Abs(dx) . " px " . (dx > 0 ? "right" : "left") : "") . (dx && dy ? " and " : "")
                . (dy ? Abs(dy) . " px " . (dy > 0 ? "down" : "up") : "")
            return clickVerb . " " . (move = "" ? "at the " : move . " from the ") . place . " of the window"
        case "det_human_click":
            clickVerb := StrUpper(SubStr(clickVerb, 1, 1)) . SubStr(clickVerb, 2)
            return clickVerb . " at (" . node.Get("x", 0) . ", " . node.Get("y", 0) . ")" . (node.Get("coordRel", "Window") = "Screen" ? " on the screen" : "")
                . (node.Get("profile", "MinimumJerk") = "Instant" ? "" : " with a human-like move")
        case "det_predict_row":
            item := V20_Short(node.Get("wantItem", ""), 40)
            if node.Get("selectMethod", "CheckboxClick") = "StoreRowOnly"
                return 'Work out which row "' . item . '" is in the list (no click)'
            return 'Pick "' . item . '" in the list (row is worked out)'
    }
    return ""
}

; ============================================================================
; V4 STARTUP / SINGLE-FILE PLAYER EXPORT
```

### Block 4 - in `V4_SelfTest` (a V20 check that said web blocks have no sentence; now they have one)

Find:
```ahk
        check("V20 web blocks keep their older line", V20_StepLine(Map("type", "web_click", "selector", "#go")), "")
```
Replace with:
```ahk
        check("V20 web blocks keep their older line (V21: they get a sentence)", V20_StepLine(Map("type", "web_click", "selector", "#go")), 'Web: click "go"')
```

### Block 5 - in `V4_SelfTest` (new checks right before `player := V4_PlayerSource(source, macro)`)

Find:
```ahk
        player := V4_PlayerSource(source, macro)
```
Replace with:
```ahk
        check("V21 selector names", V21_SelectorName("#submit") . "|" . V21_SelectorName('[name="email"]') . "|" . V21_SelectorName('[aria-label="Search"]')
            . "|" . V21_SelectorName('[data-testid="save-btn"]') . "|" . V21_SelectorName("form#login button.primary") . "|" . V21_SelectorName(""),
            '"submit"|email|Search|save-btn|button.primary in #login|')
        check("V21 selector name keeps a quoted space and a child step", V21_SelectorName('div.panel > input[aria-label="Last name"]'), "Last name")
        check("V21 long selector name shortened to 40", StrLen(V21_SelectorName("div.a-very-long-class-name-for-a-button-that-goes-on-and-on")), 40)
        check("V21 web address without query", V21_UrlText("https://example.com/orders?id=5#top") . "|" . V21_UrlText("about:blank")
            . "|" . V21_UrlText("http://example.com/"), "example.com/orders|about:blank|example.com")
        v21N := V4_CreateNode("web_click"), v21N["selector"] := "#submit"
        check("V21 web click line", V20_StepLine(v21N), 'Web: click "submit"')
        v21N := V4_CreateNode("web_fill"), v21N["selector"] := '[name="email"]', v21N["value"] := "{{Name}}"
        check("V21 web fill line", V20_StepLine(v21N), 'Web: type "{{Name}}" into email')
        v21N := V4_CreateNode("web_fill"), v21N["selector"] := "#password", v21N["value"] := "secret", v21N["ask"] := 1
        check("V21 asked web fill never shows its text", V20_StepLine(v21N), 'Web: type what you answer when asked into "password"')
        v21N := V4_CreateNode("web_navigate"), v21N["url"] := "https://example.com/orders?page=2"
        check("V21 web go to line", V20_StepLine(v21N), "Web: go to example.com/orders")
        v21N := V4_CreateNode("web_wait"), v21N["selector"] := "#results"
        check("V21 web wait line", V20_StepLine(v21N), 'Web: wait for "results" to appear (up to 10 s)')
        v21N := V4_CreateNode("web_launch")
        check("V21 web launch line", V20_StepLine(v21N), "Web: open the Edge browser for the macro (port 9222)")
        v21N := V4_CreateNode("web_connect"), v21N["match"] := "orders"
        check("V21 web connect line", V20_StepLine(v21N), 'Web: connect to the tab whose url contains "orders"')
        v21N := V4_CreateNode("web_tab"), v21N["match"] := "Inbox", v21N["by"] := "title", v21N["mode"] := "exact"
        check("V21 web tab line", V20_StepLine(v21N), 'Web: switch to the tab whose title is "Inbox"')
        check("V21 web new tab line", V20_StepLine(V4_CreateNode("web_newtab")), "Web: open a new empty tab")
        check("V21 web back / forward / reload / close / disconnect lines", V20_StepLine(V4_CreateNode("web_back")) . "|" . V20_StepLine(V4_CreateNode("web_forward"))
            . "|" . V20_StepLine(V4_CreateNode("web_reload")) . "|" . V20_StepLine(V4_CreateNode("web_close")) . "|" . V20_StepLine(V4_CreateNode("web_disconnect")),
            "Web: go back a page|Web: go forward a page|Web: reload the page|Web: close the tab|Web: let go of the browser (it stays open)")
        v21N := V4_CreateNode("web_select"), v21N["selector"] := "#state", v21N["value"] := "Ohio"
        check("V21 web select line", V20_StepLine(v21N), 'Web: pick "Ohio" in "state"')
        v21N := V4_CreateNode("web_check"), v21N["selector"] := '[name="agree"]'
        check("V21 web tick line", V20_StepLine(v21N), "Web: tick agree")
        v21N := V4_CreateNode("web_read"), v21N["selector"] := "#total"
        check("V21 web read line", V20_StepLine(v21N), 'Web: read the text of "total", remember it as result')
        v21N := V4_CreateNode("web_count"), v21N["selector"] := "tr.row"
        check("V21 web count line", V20_StepLine(v21N), "Web: count how many tr.row there are, remember it as count")
        v21N := V4_CreateNode("web_exists"), v21N["selector"] := "#error"
        check("V21 web exists line", V20_StepLine(v21N), 'Web: check whether "error" is there, remember it as exists')
        v21N := V4_CreateNode("web_focus"), v21N["selector"] := "#q"
        check("V21 web focus line", V20_StepLine(v21N), 'Web: put the cursor in "q"')
        v21N := V4_CreateNode("web_scroll"), v21N["selector"] := "#footer", v21N["frame"] := "iframe#main"
        check("V21 web scroll line inside a frame", V20_StepLine(v21N), 'Web: scroll "footer" into view  (inside frame iframe#main)')
        check("V21 web keys line", V20_StepLine(V4_CreateNode("web_keys")), "Web: press Enter")
        check("V21 web screenshot line", V20_StepLine(V4_CreateNode("web_screenshot")), "Web: save a picture of the page as browser-V4.png")
        check("V21 web script line", V20_StepLine(V4_CreateNode("web_eval")), 'Web: run the script "document.title", remember it as result')
        check("V21 web command line", V20_StepLine(V4_CreateNode("web_cdp")), "Web: send the browser command Runtime.evaluate, remember it as cdp")
        v21N := V4_CreateNode("input_send"), v21N["value"] := "^a"
        check("V21 send keys line", V20_StepLine(v21N), "Send keys: Ctrl+A (select all)")
        v21N["ask"] := 1
        check("V21 asked send keys never shows the keys", V20_StepLine(v21N), "Send keys: what you answer when asked (each run)")
        check("V21 SendInput / SendEvent lines", V20_StepLine(V4_CreateNode("input_sendinput")) . "|" . V20_StepLine(V4_CreateNode("input_sendevent")),
            "Send keys: Enter (OK / submit / new line)|Send keys: Enter (OK / submit / new line)")
        check("V21 SendText line", V20_StepLine(V4_CreateNode("input_sendtext")), 'Type "Hello"')
        v21N := V4_CreateNode("input_keydown"), v21N["key"] := "Shift"
        check("V21 hold key line", V20_StepLine(v21N), "Hold Shift down")
        v21N := V4_CreateNode("input_keyup"), v21N["key"] := "Shift"
        check("V21 let go of key line", V20_StepLine(v21N), "Let go of Shift")
        check("V21 settings blocks keep their older line", V20_StepLine(V4_CreateNode("input_keydelay")) . V20_StepLine(V4_CreateNode("input_sendmode")), "")
        check("V21 wait settled line", V20_StepLine(V4_CreateNode("det_wait_settled")), "Wait until the area (165, 95)–(660, 190) stops changing")
        check("V21 wait pixel line", V20_StepLine(V4_CreateNode("det_wait_pixel")), "Wait until the dot at (300, 76) is yellow (the active box)")
        v21N := V4_CreateNode("det_wait_pixel"), v21N["colorMode"] := "NearHex", v21N["appear"] := 0
        check("V21 wait pixel gone line", V20_StepLine(v21N), "Wait until the dot at (300, 76) is no longer close to #FFFF80")
        check("V21 anchor click line", V20_StepLine(V4_CreateNode("det_anchor_click")), "Click 41 px left and 60 px up from the bottom centre of the window")
        v21N := V4_CreateNode("det_anchor_click"), v21N["anchor"] := "ProportionalPct", v21N["button"] := "Right"
        check("V21 anchor click by percent line", V20_StepLine(v21N), "Right-click at 50% across and 50% down the window")
        check("V21 human click line", V20_StepLine(V4_CreateNode("det_human_click")), "Click at (300, 200) with a human-like move")
        check("V21 predict row line", V20_StepLine(V4_CreateNode("det_predict_row")), 'Pick "{{Product}}" in the list (row is worked out)')
        check("V21 unknown kind keeps the older line", V20_StepLine(Map("type", "mystery")), "")
        player := V4_PlayerSource(source, macro)
```

## 2. Full text of each new function

```ahk
; @summary A short, readable name for a web element from its CSS selector, for a step line: "#submit" -> "submit" in
;          quotes; [name="email"], [aria-label="Search"], [data-testid="save-btn"] -> the value; otherwise the last
;          simple part, plus the nearest "#id" to its left ("form#login button.primary" -> "button.primary in #login").
;          At most 40 characters (V20_Short). "" for a blank selector.
; @tags macro, explain, web, v21
V21_SelectorName(selector) {
    sel := Trim(String(selector))
    if sel = ""
        return ""
    parts := [], part := "", depth := 0, quote := ""
    Loop Parse, sel {
        ch := A_LoopField
        if quote != "" {                        ; inside a quoted attribute value: spaces and > do not split
            part .= ch
            if ch = quote
                quote := ""
            continue
        }
        if ch = '"' || ch = "'" {
            quote := ch, part .= ch
            continue
        }
        if ch = "[" || ch = "("
            depth += 1
        else if ch = "]" || ch = ")"
            depth := Max(0, depth - 1)
        if depth = 0 && (ch = " " || ch = "`t" || ch = ">" || ch = "+" || ch = "~") {
            if part != ""
                parts.Push(part)
            part := ""
            continue
        }
        part .= ch
    }
    if part != ""
        parts.Push(part)
    if !parts.Length
        return V20_Short(sel, 40)
    lastPart := parts[parts.Length]
    if RegExMatch(lastPart, "^#([\w-]+)$", &m)
        return V20_Short('"' . m[1] . '"', 40)
    if RegExMatch(lastPart, "i)^[\w-]*\[(?:name|aria-label|data-testid)\s*=\s*([`"']?)(.*?)\1\s*\]$", &m)
        name := m[2]
    else
        name := lastPart
    loop parts.Length - 1 {
        if RegExMatch(parts[parts.Length - A_Index], "#([\w-]+)", &m) {
            name .= " in #" . m[1]
            break
        }
    }
    return V20_Short(name, 40)
}

; @summary A web address for a step line: host + path only, no "https://", no query string or #part
;          ("https://example.com/orders?id=5" -> "example.com/orders").
; @tags macro, explain, web, v21
V21_UrlText(url) {
    url := RegExReplace(Trim(String(url)), "[?#].*$")
    url := RegExReplace(url, "i)^[a-z][a-z0-9+.\-]*://")
    return RegExReplace(url, "(?<=.)/$")
}

; @summary The sentence of a step that V20_StepSentence does not handle: web blocks, basic-input blocks and the
;          measuring blocks. Reads the fields named in V4_WebDefs / V4_InputDefs / V10_DetDefs. "" for any other kind
;          (the older "Name   details" form is shown then).
; @tags macro, explain, web, v21
V21_MoreSentence(node) {
    static colours := Map("DiscernYellow", "yellow (the active box)", "CernerDoorBlue", "the door-icon blue",
        "HighlightBlue", "the selection blue", "DisabledGrey", "greyed out", "WhiteReady", "white (ready)")
    static places := Map("TopLeft", "top left", "BottomCenter", "bottom centre", "TopRight", "top right",
        "BottomRight", "bottom right", "BottomLeft", "bottom left", "Center", "centre")
    t := node.Get("type", "")
    el := V21_SelectorName(node.Get("selector", ""))
    el := el = "" ? "the element" : el
    frame := Trim(node.Get("frame", ""))
    inFrame := frame = "" ? "" : "  (inside frame " . V21_SelectorName(frame) . ")"
    keep := Trim(node.Get("variable", ""))
    keepText := keep = "" ? "" : ", remember it as " . keep
    btn := node.Get("button", "Left"), count := node.Get("count", 1)
    clickVerb := (btn = "Left" ? "" : StrLower(btn) . "-") . (count = 2 ? "double-click" : "click")
    switch t {
        case "web_launch":
            browser := RegExReplace(RegExReplace(node.Get("browser", "Edge"), ".*[\\/]"), "i)\.exe$")
            return "Web: open the " . browser . " browser for the macro (port " . node.Get("port", 9222) . ")"
        case "web_connect", "web_tab":
            match := node.Get("match", "")
            if match = ""
                return t = "web_connect" ? "Web: connect to the only open tab" : "Web: switch to the other tab"
            return (t = "web_connect" ? "Web: connect to the tab" : "Web: switch to the tab") . " whose " . node.Get("by", "url")
                . (node.Get("mode", "contains") = "exact" ? " is " : " contains ") . '"' . V20_Short(match, 40) . '"'
        case "web_navigate":
            return "Web: go to " . V21_UrlText(node.Get("url", ""))
        case "web_newtab":
            url := V21_UrlText(node.Get("url", "about:blank"))
            return url = "" || url = "about:blank" ? "Web: open a new empty tab" : "Web: open a new tab at " . url
        case "web_back": return "Web: go back a page"
        case "web_forward": return "Web: go forward a page"
        case "web_reload": return "Web: reload the page"
        case "web_close": return "Web: close the tab"
        case "web_disconnect": return "Web: let go of the browser (it stays open)"
        case "web_wait":
            cond := node.Get("condition", "visible")
            how := cond = "present" ? "be on the page" : cond = "hidden" ? "be hidden" : cond = "absent" ? "go away"
                : cond = "text" ? 'show "' . V20_Short(node.Get("value", ""), 30) . '"' : "appear"
            return "Web: wait for " . el . " to " . how . " (up to " . V20_Time(node.Get("timeoutMs", 10000)) . ")" . inFrame
        case "web_click":
            return "Web: " . clickVerb . " " . el . inFrame
        case "web_fill":
            if V4_Bool(node.Get("ask", 0))              ; asked each run: never show the text
                return "Web: type what you answer when asked into " . el . inFrame
            return 'Web: type "' . V20_Short(node.Get("value", ""), 40) . '" into ' . el . inFrame
        case "web_select":
            return 'Web: pick "' . V20_Short(node.Get("value", ""), 40) . '" in ' . el . inFrame
        case "web_check":
            return "Web: " . (V4_Bool(node.Get("checked", 1)) ? "tick " : "untick ") . el . inFrame
        case "web_read":
            attr := node.Get("attribute", "textContent")
            return "Web: read " . (RegExMatch(attr, "i)^(textContent|innerText)$") ? "the text" : "the " . attr) . " of " . el
                . keepText . inFrame
        case "web_count":
            return "Web: count how many " . el . " there are" . keepText . inFrame
        case "web_exists":
            return "Web: check whether " . el . " is there" . keepText . inFrame
        case "web_focus":
            return "Web: put the cursor in " . el . inFrame
        case "web_scroll":
            return "Web: scroll " . el . " into view" . inFrame
        case "web_keys":
            return "Web: press " . node.Get("key", "Enter") . (Trim(node.Get("selector", "")) = "" ? "" : " in " . el) . inFrame
        case "web_screenshot":
            return "Web: save a picture of the page as " . RegExReplace(node.Get("path", ""), ".*[\\/]")
        case "web_eval":
            return 'Web: run the script "' . V20_Short(node.Get("expression", ""), 40) . '"' . keepText
        case "web_cdp":
            return "Web: send the browser command " . node.Get("method", "") . keepText
        case "input_send", "input_sendinput", "input_sendevent":
            if V4_Bool(node.Get("ask", 0))
                return "Send keys: what you answer when asked (each run)"
            return "Send keys: " . V20_KeysText(node.Get("value", ""))
        case "input_sendtext":
            if V4_Bool(node.Get("ask", 0))
                return "Type what you answer when asked (each run)"
            return 'Type "' . V20_Short(node.Get("value", "")) . '"'
        case "input_keydown":
            return "Hold " . node.Get("key", "Ctrl") . " down"
        case "input_keyup":
            return "Let go of " . node.Get("key", "Ctrl")
        case "det_wait_settled":
            return "Wait until the area (" . node.Get("x1", 0) . ", " . node.Get("y1", 0) . ")–(" . node.Get("x2", 0) . ", "
                . node.Get("y2", 0) . ") stops changing"
        case "det_wait_pixel":
            mode := node.Get("colorMode", "DiscernYellow")
            colour := mode = "NearHex" ? "close to #" . node.Get("colorHex", "") : colours.Get(mode, mode)
            return "Wait until the dot at (" . node.Get("x", 0) . ", " . node.Get("y", 0) . ") is "
                . (V4_Bool(node.Get("appear", 1)) ? "" : "no longer ") . colour
        case "det_anchor_click":
            clickVerb := StrUpper(SubStr(clickVerb, 1, 1)) . SubStr(clickVerb, 2)
            anchor := node.Get("anchor", "BottomCenter")
            if anchor = "ProportionalPct"
                return clickVerb . " at " . node.Get("pctX", 50) . "% across and " . node.Get("pctY", 50) . "% down the window"
            place := places.Get(anchor, anchor)
            dx := node.Get("dx", 0), dy := node.Get("dy", 0)
            dx := IsNumber(dx) ? Number(dx) : 0, dy := IsNumber(dy) ? Number(dy) : 0
            move := (dx ? Abs(dx) . " px " . (dx > 0 ? "right" : "left") : "") . (dx && dy ? " and " : "")
                . (dy ? Abs(dy) . " px " . (dy > 0 ? "down" : "up") : "")
            return clickVerb . " " . (move = "" ? "at the " : move . " from the ") . place . " of the window"
        case "det_human_click":
            clickVerb := StrUpper(SubStr(clickVerb, 1, 1)) . SubStr(clickVerb, 2)
            return clickVerb . " at (" . node.Get("x", 0) . ", " . node.Get("y", 0) . ")" . (node.Get("coordRel", "Window") = "Screen" ? " on the screen" : "")
                . (node.Get("profile", "MinimumJerk") = "Instant" ? "" : " with a human-like move")
        case "det_predict_row":
            item := V20_Short(node.Get("wantItem", ""), 40)
            if node.Get("selectMethod", "CheckboxClick") = "StoreRowOnly"
                return 'Work out which row "' . item . '" is in the list (no click)'
            return 'Pick "' . item . '" in the list (row is worked out)'
    }
    return ""
}
```

## 3. New self-test lines and PASS count

The 40 new `check(...)` lines are in block 5 (one or more per kind: every web block, every basic-input block, the
five measuring blocks, the selector names, the web address, and "an unknown kind keeps the older line").
One existing V20 line had to change (block 4): `"V20 web blocks keep their older line"` expected `""` for a web
click; it now expects `Web: click "go"`. Self-test under Wine: **321 PASS** (after item A: 281; V20: 274),
`Failures: 0`.

## 4. Notes / anything unsure

- Field names were read from `V4_WebDefs`, `V4_InputDefs` and `V10_DetDefs`; the test nodes are made with
  `V4_CreateNode(kind)`, so the defaults are the real ones.
- "the page part" in the plan is read as the block's `frame` field (a same-origin iframe): when it is set the line
  ends with `  (inside frame <name>)`. Blocks without a selector (launch, connect, tab, go to, new tab, back,
  forward, reload, close, disconnect, screenshot, script, browser command) get a sentence of their own.
- `web_keys` adds ` in <element>` only when it has a selector.
- Text that is asked for each run is never shown: `web_fill` with `ask`, and `input_send*` / `input_sendtext` with
  `ask` (`Send keys: what you answer when asked (each run)`, `Type what you answer when asked (each run)`).
- `det_anchor_click` has two offsets, so the line reads `Click 41 px left and 60 px up from the bottom centre of
  the window` (the plan's `<n> px from the ...` with both numbers). With anchor `ProportionalPct`:
  `Click at 50% across and 50% down the window`. Right / double clicks say `Right-click` / `Double-click`.
- `det_human_click` with the `Instant` profile drops "with a human-like move" (it does not move like a hand);
  `Screen` coordinates add "on the screen".
- `det_predict_row` with `selectMethod = StoreRowOnly` does not click, so it reads
  `Work out which row "<item>" is in the list (no click)` instead of `Pick ...`.
- Colour states in words: DiscernYellow = "yellow (the active box)", NearHex = "close to #RRGGBB",
  CernerDoorBlue = "the door-icon blue", HighlightBlue = "the selection blue", DisabledGrey = "greyed out",
  WhiteReady = "white (ready)". A wait with `appear` off says "is no longer ...".
- `input_keydelay` and `input_sendmode` (settings, not actions) are not in the plan's list, so they keep the older
  form (checked by a self-test line).
- Only the step list text changes; playback is not touched.

## 5. Tests run (Wine)

- Load check: no errors, no warnings. Self-test: 321 PASS, `Failures: 0`. Brace check: balanced.
- Notepad record / replay: `KEEP MEhello grokbot` / `line2`, 0 notes. V18 macro replays as before (same text and
  window size, 0 notes).
- Screenshot of a test macro with web, input and measuring steps: `#8 Web: click "submit"`,
  `#9 Web: type "{{Name}}" into email`, `#10 Web: go to example.com/orders`, `#11 Send keys: Ctrl+A (select all)`,
  `#12 Wait until the dot at (300, 76) is yellow (the active box)`.
- Wine's font shows `→` (item A's "→ in calc") as an empty box. That is the same question as PC check 5 (tag icons).
