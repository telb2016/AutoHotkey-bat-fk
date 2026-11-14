# V21 item D - mark the steps that had a note in the last run

File: `VisualMacroBlocks-makecode-telek-V21-step-list.ahk2`. The find blocks are for the file after item C; each
occurs exactly once there (checked with the script that applies them; the result is the committed file).

## 1. Find / replace blocks (in file order)

### Block 1 - in `VMB()` (the editor state: `LastNotes`)

Find:
```ahk
        Easy: 1, FullPos: 0, PinHwnd: 0, Lbl: Map(), RecWasEmpty: false, AppShow: 0}
```
Replace with:
```ahk
        Easy: 1, FullPos: 0, PinHwnd: 0, Lbl: Map(), RecWasEmpty: false, AppShow: 0, LastNotes: Map()}
```

### Block 2 - in `VMB_NodeLabel` (step rows: ⚠ after the number, and the tag at the end)

Find:
```ahk
    if VMF_IsStep(node) {
        line := s.ShowMeaning ? V20_StepLine(node) : ""        ; V20: one plain sentence per step
        if line != ""
            return " " . off . "#" . s.FlatIndex.Get(node, "?") . "    " . line . " "
        sum := VM_StepSummary(node)
        meaning := s.ShowMeaning ? V13_StepMeaning(node) : ""
        return " " . off . "#" . s.FlatIndex.Get(node, "?") . "    " . sum[1] . (sum[3] != "" ? "   " . sum[3] : "")
            . (meaning != "" ? "   → " . meaning : "")
            . (sum[2] != "" ? "      [" . sum[2] . "]" : "") . (s.ShowMeaning ? V13_StepBadges(node) : "") . " "
```
Replace with:
```ahk
    if VMF_IsStep(node) {
        num := s.FlatIndex.Get(node, "?"), lastNote := s.LastNotes.Get(num, "")      ; V21: a note in the last run
        mark := lastNote = "" ? "" : " ⚠", noteTag := lastNote = "" ? "" : V21_NoteTag(lastNote)
        line := s.ShowMeaning ? V20_StepLine(node) : ""        ; V20: one plain sentence per step
        if line != ""
            return " " . off . "#" . num . mark . "    " . line . noteTag . " "
        sum := VM_StepSummary(node)
        meaning := s.ShowMeaning ? V13_StepMeaning(node) : ""
        return " " . off . "#" . num . mark . "    " . sum[1] . (sum[3] != "" ? "   " . sum[3] : "")
            . (meaning != "" ? "   → " . meaning : "")
            . (sum[2] != "" ? "      [" . sum[2] . "]" : "") . (s.ShowMeaning ? V13_StepBadges(node) : "") . noteTag . " "
```

### Block 3 - in `VMB_Snapshot` (every edit: step numbers may shift)

Find:
```ahk
    s.Redo := []
    V7_ScheduleAutoSave()
```
Replace with:
```ahk
    s.Redo := []
    s.LastNotes := Map()            ; V21: step numbers may shift, so the last run's notes no longer fit
    V7_ScheduleAutoSave()
```

### Block 4 - in `VMB_StopRecording` (also when nothing was recorded)

Find:
```ahk
    s.RecSteps := 0
    markedStep := 0
```
Replace with:
```ahk
    s.RecSteps := 0
    s.LastNotes := Map()                ; V21: forget the last run's notes
    markedStep := 0
```

### Block 5 - in `VMB_Play` (before the run: keep the notes for a run of only the selected steps)

Find:
```ahk
    wasDirty := s.Dirty
    VMB_Snapshot()
```
Replace with:
```ahk
    wasDirty := s.Dirty
    keptNotes := s.LastNotes        ; V21: VMB_Snapshot clears them; a run of only the selected steps leaves them as they were
    VMB_Snapshot()
```

### Block 6 - in `VMB_Play` (after the run, before the tree is rebuilt)

Find:
```ahk
    played := VMF_Flatten(macro["blocks"])
```
Replace with:
```ahk
    s.LastNotes := onlySelected ? keptNotes : V21_NoteSteps(result.HasOwnProp("Warnings") ? result.Warnings : [])
    played := VMF_Flatten(macro["blocks"])
```

### Block 7 - in `VMB_SetMacro` (New and Open)

Find:
```ahk
    s.Undo := [], s.Redo := []
    s.Checked := Map()
```
Replace with:
```ahk
    s.Undo := [], s.Redo := []
    s.LastNotes := Map()            ; V21: a new or opened macro has no notes from a run
    s.Checked := Map()
```

### Block 8 - in `V13_InspCommit` (the inspector's VMB_Snapshot clears the notes: re-label every row, not only this one)

Find:
```ahk
    VMB_Snapshot()
    keys := Map()
```
Replace with:
```ahk
    hadNotes := s.LastNotes.Count       ; V21: VMB_Snapshot clears them, so the other rows' ⚠ must go too
    VMB_Snapshot()
    keys := Map()
```

### Block 9 - in `V13_InspCommit`

Find:
```ahk
    if onChanged || p.Info.Kind = "elif" {
```
Replace with:
```ahk
    if onChanged || p.Info.Kind = "elif" || hadNotes {
```

### Block 10 - V21 section (new functions at its end, directly above the `; ====` line of `; V4 STARTUP / SINGLE-FILE PLAYER EXPORT`)

Find:
```ahk
; ============================================================================
; V4 STARTUP / SINGLE-FILE PLAYER EXPORT
```
Replace with:
```ahk
; @summary Which steps had a note in a run: result.Warnings (note texts, each "Step #<n> ...") -> Map step number ->
;          the first note text for that step. Texts that do not start with "Step #<n>" are left out.
; @tags macro, playback, gui, v21
V21_NoteSteps(warnings) {
    out := Map()
    if !(warnings is Array)
        return out
    for text in warnings {
        if RegExMatch(String(text), "^Step #(\d+)", &m) && !out.Has(Integer(m[1]))
            out[Integer(m[1])] := String(text)
    }
    return out
}

; @summary The tag a step row gets when the step had a note in the last run: "   ⚠ last run: <note>", the note
;          without its "Step #n: " start and at most 70 characters.
; @tags macro, playback, gui, v21
V21_NoteTag(text) => "   ⚠ last run: " . V20_Short(RegExReplace(String(text), "^Step #\d+:?\s*"), 70)

; ============================================================================
; V4 STARTUP / SINGLE-FILE PLAYER EXPORT
```

### Block 11 - in `V4_SelfTest` (new checks right before `player := V4_PlayerSource(source, macro)`)

Find:
```ahk
        player := V4_PlayerSource(source, macro)
```
Replace with:
```ahk
        v21Notes := V21_NoteSteps(["Step #7 (notepad.exe) stayed 900x600 instead of 950x712 (it has a size limit). Kept going.",
            "Step #3: could not scroll the list back to where it was (Edit). Clicked anyway.", "Step #7: a second note",
            "Playback was slow", "step #2 written in lower case", "Step #12: last one"])
        check("V21 notes by step number", v21Notes.Count . "|" . v21Notes.Has(7) . v21Notes.Has(3) . v21Notes.Has(12) . v21Notes.Has(2)
            . "|" . SubStr(v21Notes[7], 1, 23), "3|1110|Step #7 (notepad.exe) s")
        check("V21 no notes", V21_NoteSteps([]).Count . V21_NoteSteps("").Count, "00")
        check("V21 note tag drops the step number", V21_NoteTag("Step #3: could not scroll the list back.") . "|"
            . V21_NoteTag("Step #7 (notepad.exe) stayed small."), "   ⚠ last run: could not scroll the list back.|   ⚠ last run: (notepad.exe) stayed small.")
        check("V21 note tag shortened to 70", StrLen(V21_NoteTag("Step #1: " . StrReplace(Format("{:100}", ""), " ", "x"))), StrLen("   ⚠ last run: ") + 70)
        player := V4_PlayerSource(source, macro)
```

## 2. Full text of each new function

```ahk
; @summary Which steps had a note in a run: result.Warnings (note texts, each "Step #<n> ...") -> Map step number ->
;          the first note text for that step. Texts that do not start with "Step #<n>" are left out.
; @tags macro, playback, gui, v21
V21_NoteSteps(warnings) {
    out := Map()
    if !(warnings is Array)
        return out
    for text in warnings {
        if RegExMatch(String(text), "^Step #(\d+)", &m) && !out.Has(Integer(m[1]))
            out[Integer(m[1])] := String(text)
    }
    return out
}

; @summary The tag a step row gets when the step had a note in the last run: "   ⚠ last run: <note>", the note
;          without its "Step #n: " start and at most 70 characters.
; @tags macro, playback, gui, v21
V21_NoteTag(text) => "   ⚠ last run: " . V20_Short(RegExReplace(String(text), "^Step #\d+:?\s*"), 70)
```

## 3. New self-test lines and PASS count

The 4 new `check(...)` lines are in block 11 (several notes for one step - the first is kept; texts that do not
start with `Step #<n>` are left out; no notes; the tag drops the step number; the tag is shortened to 70).
Self-test under Wine: **342 PASS** (after item C: 338; V20: 274), `Failures: 0`.

## 4. Notes / anything unsure

- `VMB_Play` does call `VMB_Snapshot()` BEFORE the run (`; corrections made while it plays can be undone`), and that
  now clears `LastNotes`. So `LastNotes` is set AFTER the run, right before the tree is rebuilt, and is not wiped.
  To "leave it alone" for a run of only the selected steps, `VMB_Play` keeps the old map in `keptNotes` before the
  snapshot and puts it back after that run.
- Cleared: in `VMB_Snapshot` (every add / delete / move / paste / inspector edit, and also recording that added
  steps), in `VMB_StopRecording` (also when nothing was recorded), and in `VMB_SetMacro` (New and Open both go
  through it). Undo / Redo do not call `VMB_Snapshot`; by then the notes were already cleared by the edit being
  undone (Undo right after a run with corrections puts back the macro from before the run, same step numbers).
- One addition the plan did not spell out: the inspector (`V13_InspCommit`) calls `VMB_Snapshot` (so the notes are
  cleared) but re-labels only the edited row, which would leave a stale ⚠ on the other rows. When there were notes,
  it now rebuilds the whole tree instead (`|| hadNotes`), as it already does for an on / off change.
- Both row forms get the mark ("Show meaning" on: the sentence; off: the older form).
- Step numbers in the notes are the runner's flat step numbers (`Step #` . `runner.Index`), the same numbering as
  `s.FlatIndex` when the whole macro is played. Inside loops / data rows the same step can get notes in several
  rounds; the first note is shown.
- Nothing is saved to the macro file (`LastNotes` lives only in the editor state).
- Wine's font shows `⚠` as an empty box (the status bar's existing `⚠` too) - PC check 5.

## 5. Tests run (Wine)

- Load check: no errors, no warnings. Self-test: 342 PASS, `Failures: 0`. Brace check: balanced.
- Played a macro whose Normalize step asks for 60 x 60 (Notepad stays 119 x 60, one note). After the run step #1
  read `#1 ⚠    Put the window back to 60 × 60 at (0, 0)   ⚠ last run: (notepad.exe) stayed 119x60 instead of 60x60
  (it has a minimum ...`; the other rows had no mark. Deleting a step afterwards removed the mark.
- Notepad record / replay: `KEEP MEhello grokbot` / `line2`, 0 notes. V18 macro replays as before.
