# V21 section 7 - version text

File: `VisualMacroBlocks-makecode-telek-V21-step-list.ahk2`. The find blocks are for the file after item E; each
occurs exactly once there (checked with the script that applies them; the result is the committed file). The ini
file name and the autosave file name are not changed (an old draft is still found).

## 1. Find / replace blocks (in file order)

### Block 1 - line 1 of the file

Find:
```ahk
; VisualMacroBlocks-makecode-telek-V20
; V20 = V19 + step lines you can read at a glance.
```
Replace with:
```ahk
; VisualMacroBlocks-makecode-telek-V21
; V21 = V20 + a step list you can read at a glance: the program is named only where it changes, web / input /
;       measuring steps and REPEAT / IF / FOR rows get plain sentences too, steps that had a note in the last run
;       are marked ⚠, and in Steady playback a window whose saved spot is off every screen is put on the main screen.
; V20 = V19 + step lines you can read at a glance.
```

### Block 2 - in `VMB_BuildGui`

Find:
```ahk
    g := Gui("+Resize +MinSize1270x630", "Visual Macro Blocks V20")
```
Replace with:
```ahk
    g := Gui("+Resize +MinSize1270x630", "Visual Macro Blocks V21")
```

### Block 3 - in `VMB_UpdateTitle`

Find:
```ahk
    s.Gui.Title := "Visual Macro Blocks V20" . (s.Easy ? " Easy" : "") . " - " . name . savedTag . " - " . s.FlatIndex.Count . " steps"
```
Replace with:
```ahk
    s.Gui.Title := "Visual Macro Blocks V21" . (s.Easy ? " Easy" : "") . " - " . name . savedTag . " - " . s.FlatIndex.Count . " steps"
```

### Block 4 - in `V4_Help` (a NEW IN V21 paragraph above NEW IN V20)

Find:
```ahk
    MsgBox("NEW IN V20 (step lines you can read at a glance):"
```
Replace with:
```ahk
    MsgBox("NEW IN V21 (a step list you can read at a glance):"
        . "`n• The program is named only where the task moves to another one:  Type `"5`" → in calc."
        . "`n• Web, basic-input and measuring steps read as sentences too (Web: click `"submit`"), and so do REPEAT, FOR, IF,"
        . "  SET and the other blocks (Repeat 5 times  (4 steps inside), If amount is 250)."
        . "`n• After a run, the steps that had a note are marked ⚠ with the note at the end of the line, so you do not have to"
        . "  open the log. The marks go away when you change the macro."
        . "`n• Steady playback: if a window's saved spot is off every screen (another monitor layout), it is put on the main"
        . "  screen instead, with a note."
        . "`n`nNEW IN V20 (step lines you can read at a glance):"
```
## 2. Full text of each new function

None.

## 3. New self-test lines and PASS count

None new. Self-test under Wine: **347 PASS** (V20: 274), `Failures: 0`.

## 4. Notes / anything unsure

- The run bar's own title (`V5RunBar("Visual Macro Blocks V16", ...)`) was not in the plan's list and is unchanged.
- The help text was only checked by loading the file (string quotes / escapes); Easy mode's `?` button shows the
  Easy help, so the `V4_Help` box itself was not opened under Wine.

## 5. Tests run (Wine)

- Load check: no errors, no warnings. Self-test: 347 PASS, `Failures: 0`. Brace check: balanced.
- The window title reads `Visual Macro Blocks V21 Easy - Untitled - 0 steps`.
- Notepad record / replay: `KEEP MEhello grokbot` / `line2`. V18 macro replays as before (0 notes).
