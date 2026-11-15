# Work plan: V26 - one PC test sheet + a built-in "check this PC" button (planner's pick)

Work on `VisualMacroBlocks-makecode-telek-V25-history.ahk2`, save as `VisualMacroBlocks-makecode-telek-V26-pccheck.ahk2`.
Same rules as earlier plans (V19 plan section 1). Self-test `Failures: 0`, more than 442 PASS. One commit per item + `V26-NOTES.md`.

## V25 review
Accepted: 442 PASS, 0 failures. Open points need a real PC. A run-history file that cannot be written (OneDrive,
network drive, read-only) must never stop or slow a run: check `V25_RecordRun` wraps the write in `try` and only
puts one note in the status bar; fix it if not.

## Why this round
V19 to V25 were built and tested only under Wine. Nothing new should be added until the owner has run them once
on his Windows PC. The owner only has a phone right now and little time, so make that test as short as possible.

## Item A - "Check this PC" (Help menu / ? button and right-click menu)
Runs automatically, no clicking needed by the owner, ~20 seconds, and shows ONE result window with PASS / CHECK lines:
1. Opens Notepad, puts 300 lines in it, scrolls to line 150, then runs the V19 scroll-capture and scroll-restore
   functions on it (read position, scroll to top, restore, read back) -> PASS when back at 150.
2. Size test: moves / resizes that Notepad with `V19_SizeTrial` -> PASS when it holds.
3. Fonts: measures `0` and each mark character (`↕ ⚡ ◇ ✎ ⚠ ► ≈`) in the tree font; CHECK when a mark is not the
   same width as `0` (then suggest PlainMarks=1, and offer a button "Use plain marks" that sets it).
4. Tree indent: reports `s.IndentSeen`; CHECK when nested rows would not line up.
5. Screen: resolution and scaling.
6. Can write to the macro folder (run history): PASS / CHECK.
7. Closes the Notepad it opened (only that window - by its hwnd, never by name).
Result window has a "Copy" button that copies all lines, so the owner can paste them back to us.
Pure parts (deciding PASS/CHECK from numbers, building the text) go in functions with self-tests.

## Item B - one test sheet
Replace the separate V21..V25 PC-TEST/NOTES checklists with ONE file `PC-TEST-ALL.md`: step 1 = press "Check this PC"
and paste the result; then at most 8 hand checks that the button cannot do (record a click on a button and read its
caption in the list, Play highlights in yellow, "Ready to play?" box with Notepad closed, Run history shows runs,
colours plain, columns line up inside a Repeat block). Each check one line: what to do -> what you should see.
