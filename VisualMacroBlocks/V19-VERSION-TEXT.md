# V19 section 7 - version text

File: `VisualMacroBlocks-makecode-telek-V19-window-scroll.ahk2`. The find blocks below are for the file state
after item D. Each one occurs exactly once there and exactly once in the V18 file. Applying them to the item-D
file gives exactly the final V19 file (checked with a script). The ini file name and the autosave file name are
not changed.

## 1. Find / replace blocks (in file order)

### Block 1 - line 1 of the file

Find:
```ahk
; VisualMacroBlocks-makecode-telek-V18
; V18 = V17 + one-click Record and Steady playback.
```
Replace with:
```ahk
; VisualMacroBlocks-makecode-telek-V19
; V19 = V18 + window size is waited for and tested at recording, optional stop when a window
;       can't take its size, and standard lists / boxes are scrolled back before each click.
; V18 = V17 + one-click Record and Steady playback.
```

### Block 2 - in `VMB_BuildGui`

Find:
```ahk
    g := Gui("+Resize +MinSize1270x630", "Visual Macro Blocks V18")
```
Replace with:
```ahk
    g := Gui("+Resize +MinSize1270x630", "Visual Macro Blocks V19")
```

### Block 3 - in `VMB_UpdateTitle`

Find:
```ahk
    s.Gui.Title := "Visual Macro Blocks V18" . (s.Easy ? " Easy" : "") . " - " . name . savedTag . " - " . s.FlatIndex.Count . " steps"
```
Replace with:
```ahk
    s.Gui.Title := "Visual Macro Blocks V19" . (s.Easy ? " Easy" : "") . " - " . name . savedTag . " - " . s.FlatIndex.Count . " steps"
```

## 2. Full text of each new function

None.

## 3. New self-test lines

None. Self-test: 242 PASS, 0 FAIL, `Failures: 0`.

## 4. What I could not be sure about

- Only the places the plan names were changed. Other texts still say V18: the tray tip ("Visual Macro Blocks V18
  (click to show)"), the Easy help box title, the help box title, and the first line of the self-test report
  ("Visual Macro Blocks V18 self-test"). Say if those should change too.

## 5. Test by hand on a PC

1. Start the V19 file.
2. The window title must read "Visual Macro Blocks V19 Easy - ...".
3. Click "More features ▸": the title must read "Visual Macro Blocks V19 - ...".
4. Your last unsaved draft from V18 must still be restored (same autosave file).
5. Run the self-test: `Failures: 0`.

## Test results for the final file (Wine 10 on Linux, AutoHotkey 2.0.27)

- `/validate`: exit code 0, no output. `--self-test`: 242 PASS (V18: 203), 0 FAIL, `Failures: 0`.
- Window title shows "Visual Macro Blocks V19 Easy - ...".
- Notepad record + replay: text ends `KEEP MEhello grokbot\nline2`, 0 notes. Old V18 macro: same, 0 notes.
- Applying the blocks of items A, B, C, D and this file to the V18 file, in that order, gives exactly the final
  V19 file. The V18 file is unchanged.
