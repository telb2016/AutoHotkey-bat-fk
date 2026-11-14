# V22 section 7 - version text

File: `VisualMacroBlocks-makecode-telek-V22-columns.ahk2`. The find blocks are for the file after item D; each
occurs exactly once there (checked with the script that applies them; the result is the committed file). The ini
file name and the autosave file name are not changed (an old draft is still found).

## 1. Find / replace blocks (in file order)

### Block 1 - line 1 of the file

Find:
```ahk
; VisualMacroBlocks-makecode-telek-V21
; V21 = V20 + a step list you can read at a glance:
```
Replace with:
```ahk
; VisualMacroBlocks-makecode-telek-V22
; V22 = V21 + a step list in fixed columns: every row shows its program, and the columns #, Program, Waits, Marks
;       and What it does line up, with a header line above the list naming them. A switch ("Columns" next to
;       Explain steps, or right-click the list > Show columns) turns the columns off and gives the V21 list back.
; V21 = V20 + a step list you can read at a glance:
```

### Block 2 - in `VMB_BuildGui`

Find:
```ahk
    g := Gui("+Resize +MinSize1270x630", "Visual Macro Blocks V21")
```
Replace with:
```ahk
    g := Gui("+Resize +MinSize1270x630", "Visual Macro Blocks V22")
```

### Block 3 - in `VMB_UpdateTitle`

Find:
```ahk
    s.Gui.Title := "Visual Macro Blocks V21" . (s.Easy ? " Easy" : "") . " - " . name . savedTag . " - " . s.FlatIndex.Count . " steps"
```
Replace with:
```ahk
    s.Gui.Title := "Visual Macro Blocks V22" . (s.Easy ? " Easy" : "") . " - " . name . savedTag . " - " . s.FlatIndex.Count . " steps"
```

## 2. Full text of each new function

None.

## 3. Self-test and tests (Wine)

No new checks. Load check: no errors, no warnings. Self-test: **373 PASS**, `Failures: 0`. Brace check: balanced.
The window title reads "Visual Macro Blocks V22 Easy - Untitled - 24 steps". Notepad record / replay:
`KEEP MEhello grokbot` / `line2`, 0 notes. V18 macro replays as before.
