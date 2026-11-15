# V27 notes (partial round: item 0 and Item A only)

File: VisualMacroBlocks-makecode-telek-V27-grid.ahk2 (copy of V26-pccheck).
Self-test: `Failures: 0`, **524 PASS** (V26 had 466).

## Item 0 - V26 review fixes
- "Check this PC" scroll test now runs in a separate helper program (`V27_ScrollTests`): a 300-row list box
  and a 300-line text box, started with `A_AhkPath` from a temp .ahk, closed by PID, temp file deleted.
  Both controls are tested (`V27_ScrollOne`); result lines say "Scroll (list box)" / "Scroll (text box)".
- Notepad is used only for the size test (`V26_NotepadTests`). Its position and size are read when found and
  put back (WinMove) before it is closed.
- Not verified: under Wine the helper's scroll bars report no range (GetScrollRange 0..0, GetScrollInfo 0), so the
  scroll read could not be checked here. The self-test does not cover it. Needs a check on the PC.
- If the owner runs a compiled .exe, `A_AhkPath` is the exe and the helper will not start; both scroll lines then
  show CHECK "could not open the test list window".

## Item A - cell data (pure)
- `V27_Columns` (22 columns), `V27_Cells(node, ctx)` (every key filled, "–" when not applicable), `V27_Rows(blocks,
  settings, state)` (walks like VMF_Flatten; "#" is the tree's number; Inside chain from the container labels).
- Choices that differ from or extend the plan:
  - Rows: every non-container block gets a row (set, ask, stop, call too), not only steps. Their Action is "Other".
  - Scroll back shows `row N` as stored position + 1 (the stored position is 0-based, as in V19).
  - Checks picture also says "no" when the step has `noVerify` set.
  - ctx and state are Maps (not objects). Each row Map also has `.Node` (the step's node) for the grid in Item B.
  - No `Starts` in ctx (no column uses it yet).
  - Main-window class is taken as "AutoHotkeyGUI" (the class of every AutoHotkey Gui).
- Self-tests: one check per column kind (click, double/right click with geo, typed text, ask text, keys, wheel,
  Normalize, waits, disabled, window kinds, Inside chain, last run, shaky, scroll, held keys, checks picture),
  and rows: nested Inside, numbering, node kept, no empty cell.

## Not done (out of this run's scope)
- Items B, C, D, E of V27, Part 2 (V28), help text / version. Line 1 and the window title still say V26.
