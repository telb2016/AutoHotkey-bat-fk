# V26 notes - handback

File: `VisualMacroBlocks-makecode-telek-V26-pccheck.ahk2` (new, copied from V25-history; older files untouched).
One commit per item (A, B), this file last.

## Result
- Self-test under Wine (AutoHotkey 2.0.27): **466 PASS, `Failures: 0`** (442 before; +24 item A). Validate: rc 0, no output.
- Notepad record / replay (same as V25 on this harness: `hello grokbot` / `line2`, 0 notes) and replay of an older
  (V18-recorded) macro 3 times (same result, 0 notes, 3 lines in `old.vmacro.runs.csv`).
- Item B is a document only (`PC-TEST-ALL.md`); nothing to run.

## V25 review point
`V25_RecordRun` already wraps all file work (create, append, read, trim) in one `try`, so a read-only / OneDrive / network
folder never raises an error or stops a run. It writes NO note at all (the plan allowed at most one status-bar note), so nothing was changed.
A slow network drive could still make the append itself take a moment - not changeable without a background write.

## Item A (d044ed8a) - Check this PC
- Open from the **?** button (now a small menu: Help / Check this PC...) and the right-click menu (under Run history...).
- Notepad is opened by the check itself and found by comparing the Notepad windows before / after (its hwnd); 300 lines, scrolled to line 150
  (EM_LINESCROLL), then `V19_CaptureScroll`, `V19_ScrollTo` top, `V19_RestoreScroll`, read back -> PASS when back at 150 and it really left 150.
- `V19_SizeTrial` on the same window. Marks `↕ ⚡ ◇ ✎ ⚠ ► ≈` measured against `0` in the tree font (CHECK when more than 1 px off;
  button "Use plain marks" writes `[V22] PlainMarks=1`, needs a restart). Indent from `s.IndentSeen` (CHECK when "not measured yet" - Show columns must have been on once, or when asked and got differ).
  Screen size + scaling (CHECK when not 100 %, just a hint), write test in the macro folder (file written, read, deleted).
- Notepad is closed by its hwnd only (`WinClose ahk_id`); its "modified" flag is cleared first so it does not ask to save. If it stays open, a CHECK line says so; nothing is killed.
- Pure parts with self-tests: `V26_ScrollVerdict`, `V26_SizeVerdict`, `V26_MarksVerdict`, `V26_IndentVerdict`, `V26_ScreenVerdict`, `V26_WriteVerdict`, `V26_BuildText`, `V26_Line`, `V26_CanWrite`.
- Result window: read-only text, **Copy** button (clipboard), Close.

## Item B (92f8dbc5) - one sheet
`PC-TEST-ALL.md`: step 1 = press the button and paste the result; 6 one-line hand checks. The V21 / V22 checklists were left in place (not deleted), the sheet says they are replaced.

## What Wine could not prove
- Scroll test: **Wine's Notepad edit box returns no scroll bar info** (GetScrollInfo fails), so under Wine the scroll line is a CHECK
  ("could not read the scroll position"). The decision code is self-tested and an own Gui Edit under Wine does answer GetScrollInfo, but the real scroll-restore on Windows Notepad is still unproven.
  The newer Windows 11 Notepad may not have a standard "Edit1" box; then the line says CHECK, not PASS.
- Size, fonts, indent, screen, folder write and the close step gave PASS under Wine (fonts: all marks 7 px = `0`, which is Wine's fallback font - not the PC).
- Real look of the result window and the "?" menu on Windows; whether the 20 seconds is right.
- Side effect: Notepad remembers the window spot (120,120, 720x520) the check moved it to (it saves its position on close).

## PC check
1. Start V26, ? > Check this PC..., wait ~20 s, press Copy, paste it back.
2. Then the 6 hand checks in `PC-TEST-ALL.md`.
