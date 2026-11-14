# Work plan: Visual Macro Blocks V22 (step list in fixed columns)

Work on: `VisualMacroBlocks-makecode-telek-V21-step-list.ahk2`
Save as: `VisualMacroBlocks-makecode-telek-V22-columns.ahk2`
One commit per item (A to D), with a short `V22-ITEM-x.md` note each, like before.

## 0. What the owner asked for (his words, shortened)

"You show the timer and how long it pauses, but what program is it? The first click says MS Edge and
then nothing after that. That is really important to know. Can't you have columns, a fixed size instead
of a random length for each row? One column is the program, the next is the pause, and so on."

So: **every row shows its program, always, in the same place.** V21 item A (program only when it
changes) is undone by this round. Rows become fixed columns that line up down the whole list, with the
free-length sentence LAST so nothing has to be cut off.

Target look (monospace font, columns line up):

```
  #    Program       Waits    Marks  What it does
  1    msedge                        Put the window back to 1200 × 800 at (40, 40)
  2    msedge        0.4 s           Click the "Search" button — top-right (1010, 62)
  3    msedge        2.1 s    ↕      Click a list — middle-left (80, 300)
  4    msedge                        Type "aspirin"
  5    msedge                        Press Enter (OK / submit / new line)
  6  ► notepad       3.2 s    ⚠      Click a text box — top-left (120, 60)
  7    notepad                       Type "done"
```

## 1. Rules (unchanged - see `GROK-PLAN-V19-window-scroll.md` section 1 and the V21 plan section 0)

Short version: one AutoHotkey v2.0.19 file; find / replace edits; new functions prefixed `V22_` in one
new section above the `; ====` line before `; V4 STARTUP / SINGLE-FILE PLAYER EXPORT`; `; @summary` and
`; @tags` on each; old macros load and play the same (this round changes DISPLAY only); do not touch
picture code; `#Warn All` clean; a quote inside a string is `` `" ``; every pure function gets
`V4_SelfTest` checks before `player := V4_PlayerSource(source, macro)`. V21 has 347 PASS lines; yours
must have more and `Failures: 0`.

## 2. Why this design (do not change the approach without saying so)

The step list is a Windows **TreeView** (`s.TV`). A TreeView has no real columns. Replacing it with a
ListView would break drag and drop, tick boxes, nesting, colours and about 40 functions. So:

- Use a **monospace font** (Consolas) in the tree only, and **pad each column with spaces** to a fixed
  number of characters. Fixed-width columns come first, the sentence last.
- Nested rows (inside Repeat / If) are pushed right by the tree's own indent. Make that indent an exact
  number of characters and remove that many spaces from the row's first column, so columns still line
  up at every depth.
- A one-line header label above the tree, in the same font, names the columns.

All text building is pure functions, so it is fully covered by the self-test.

## 3. Item A - the column text (pure functions, no GUI yet)

New functions:

- `V22_Pad(text, width)` - returns exactly `width` characters: pads with spaces, or cuts to
  `width - 1` characters plus `…`. Treat every character as one column wide (count with `StrLen`).
- `V22_Cols()` - the column layout in one place:
  `[{Key: "num", W: 5}, {Key: "app", W: 14}, {Key: "wait", W: 9}, {Key: "marks", W: 7}]`
  and the gap between columns is always 1 space. The sentence follows after the last column.
- `V22_AppOf(node)` - program for the Program column:
  - a step with `win` (a `Map`) and a non-empty `exe`: `V20_AppName(exe)` (e.g. `msedge`);
  - `det_use_window` with a target: `V20_TargetName(target)`; blank target: the Macro window's program,
    `V20_TargetName(settings defaultTarget)` (pass the settings `Map` in as a second parameter so the
    function stays pure: `V22_AppOf(node, settings := 0)`);
  - `det_normalize_win` and any other `det_*` / `input_*` step with a `target` field: same as above;
  - web steps (`web_*`): `web page`;
  - `delay` and anything else with no program: `""`.
- `V22_FillApps(flatSteps, settings)` - returns `Map` node -> program text for EVERY step: a step whose
  own program is `""` (for example a Delay) takes the program of the nearest earlier step that had one.
  This is what makes the column complete. Also returns which steps START a new program (first step,
  and each step whose program differs, case-insensitive, from the previous step's filled program):
  return `{App: Map, Starts: Map}`.
- `V22_WaitText(node)` - the Waits column: `delayMs` set -> `V20_Time(delayMs)` followed by `*`
  (fixed by the user); else `gapMs` >= 300 -> `V20_Time(gapMs)`; else `""`. Explain the `*` in the help.
- `V22_Marks(node, lastNote)` - up to 5 single-character marks, in this order, each only when it
  applies: `↕` step has `scroll` (a `Map`); `⚡` `V8_VarySummaryBadge(node) != ""`; `◇` `winMatch` is
  `"active"`; `✎` step has a `note`; `⚠` `lastNote != ""`. Joined without spaces.
- `V22_Row(num, app, startsApp, wait, marks, sentence, depth, indentChars)` - one whole row:
  - number column: `V22_Pad(num, 5)`, but remove `depth * indentChars` characters from the LEFT of the
    padded row start so deeper rows line up (never remove more than the leading spaces available; when
    there are not enough, just remove what there is). Easiest: build the full row for depth 0 with a
    leading margin of `8 * indentChars` spaces, then drop `depth * indentChars` of them. Rows deeper
    than 8 levels simply stop lining up - acceptable.
  - put `►` in the last character of the number column when `startsApp` is true and it is not step 1;
  - then `app`, `wait`, `marks` each through `V22_Pad` with a 1-space gap, then the sentence.
- `V22_Header(indentChars)` - the header text built with the same widths:
  `#`, `Program`, `Waits`, `Marks`, `What it does`.
- Sentence: `V20_StepSentence(node)` (NOT `V20_StepLine` - the tags are now columns), then the note
  text when there is one: `   // <note>`, then V21's last-run note tag (`V21_NoteTag(lastNote)`).
  When `V20_StepSentence` returns `""`, use the older text: `sum := VM_StepSummary(node)`,
  `sum[1] . "   " . sum[3]`.
- The sentence must NOT repeat the program. `V20_InApp(node, show)` already takes a `show` flag: make
  the column mode pass `false`. Do this with one switch in the editor state, `s.Columns` (1 = column
  mode, the default; 0 = V21 sentence mode), read through the existing helper `V21_ShowApp(node)`:
  when `s.Columns` is 1 it returns `false`. With no editor (self-test on loose nodes) behaviour must
  stay exactly as in V21 so the existing V20 / V21 checks pass unchanged.

Self-tests (all pure): `V22_Pad` (short, exact, too long, empty); `V22_AppOf` for each kind above;
`V22_FillApps` (A A B B A; Delay between; no program at all; `Starts` map); `V22_WaitText` (fixed,
recorded 2440 -> `2.4 s`, small gap -> empty); `V22_Marks` (none, all five, order); `V22_Row` at depth
0, 1 and 2 - check that the position of the Program column in the string PLUS `depth * indentChars`
is the same number for all three; `V22_Header` starts its `Program` label at that same position.

## 4. Item B - show it in the tree

- State: add `Columns: 1, ColApp: 0, ColStarts: 0, IndentChars: 3` to the object in `VMB()`.
  Read `Columns` from the ini at startup: `IniRead(s.Ini, "V22", "Columns", 1)`.
- `VMB_Refresh`: where V21 fills `s.AppShow`, also fill
  `r := V22_FillApps(VMF_Flatten(s.Macro["blocks"]), s.Macro["settings"])`, `s.ColApp := r.App`,
  `s.ColStarts := r.Starts`. Do the same at the other place(s) where V21 recomputes `s.AppShow`.
- Depth of a row: `VMB_NodeLabel(node)` does not know it. Add an optional parameter
  `VMB_NodeLabel(node, depth := unset)`. In `VMB_Refresh` the recursive add function knows the parent;
  pass the depth down (0 for top-level). For the single-row re-label call sites, compute depth from the
  tree: count parents with `s.TV.GetParent(item)` until 0. Put that in `V22_DepthOf(item)`.
  IMPORTANT: in this tree some parent rows are not blocks (the "ELSE" rows and "(empty)" placeholders
  are tree items too). Count tree levels, not block levels - the indent is per tree level.
- In `VMB_NodeLabel`, for steps when `s.Columns` and `s.ShowMeaning` are both on, return
  `V22_Row(...)` using the pieces above (keep the `●` breakpoint and `(off)` prefixes: put them at the
  start of the SENTENCE, not in front of the row, so columns do not shift).
- Container rows (Repeat, If, ELSE ...): keep V21's `V21_BlockLine(node)` text, but start it at the
  same character position as the `#` column (same leading-margin rule), so the block name lines up
  with the step numbers.
- Font: in column mode set the tree font to Consolas:
  `s.TV.SetFont("s" . s.FontSize, "Consolas")`; otherwise `"Segoe UI"`. There are two places that set
  the tree font today (`VMB_BuildGui` and `VMB_Zoom`); route both through one new function
  `V22_ApplyTreeFont()`.
- Tree indent = exactly `s.IndentChars` characters wide. In `V22_ApplyTreeFont()`, after setting the
  font: measure one character (`W`) with the tree's font - get the font handle with
  `SendMessage(0x31, 0, 0, s.TV)` (WM_GETFONT), select it into the tree's DC
  (`GetDC` / `SelectObject` / `GetTextExtentPoint32W` on the text `"0000000000"`, divide the width by
  10, `SelectObject` back, `ReleaseDC`) - then `SendMessage(0x1107, charW * s.IndentChars, 0, s.TV)`
  (TVM_SETINDENT). Windows may refuse an indent that is too small: read it back with
  `SendMessage(0x1106, 0, 0, s.TV)` (TVM_GETINDENT); if it is larger than requested, raise
  `s.IndentChars` to `Ceil(actual / charW)`, set the indent to `charW * s.IndentChars`, and note in
  your item note what value you saw. Call `VMB_Refresh()` after a change so rows are rebuilt with the
  new `IndentChars`.
- Marks are single characters from Segoe-style symbols; Consolas may draw `↕ ⚡ ◇ ✎ ⚠ ►` wider than
  one column or as boxes. Put the mark characters in ONE function `V22_MarkChars()` returning a `Map`
  (`"scroll"`, `"vary"`, `"active"`, `"note"`, `"warn"`, `"start"`), with a second set of plain ASCII
  fallbacks (`S`, `V`, `A`, `N`, `!`, `>`), chosen by the ini value `[V22] PlainMarks` (default 0).
  The owner will switch it if the symbols look wrong on his PC. Say this in the PC checklist.

## 5. Item C - the header line and the on/off switch

- Header: a Text control `c["ColHead"]` created right above the tree in `VMB_BuildGui`, font Consolas
  at the tree's size, grey (`c606060`). Its text is `V22_Header(s.IndentChars)`.
  Its left edge must sit where row text starts: after `VMB_Refresh` (when the tree has at least one
  row), ask the tree for the text rectangle of the first row: `TVM_GETITEMRECT` (0x1104) with
  `wParam = 1` and `lParam` = a 16-byte buffer whose first pointer-sized value is the item handle
  (`NumPut("Ptr", firstItem, rc)`); the result's `left` (first Int of the buffer after the call) is the
  x inside the tree. Header x = tree x + that left, MINUS the pixel width of the leading margin that
  depth-0 rows carry... simpler: give the header the same leading margin text as a depth-0 row, and
  place its x exactly at tree x + `left`. Hide the header when the tree is empty or column mode is off.
  Put this in `V22_PlaceHeader()` and call it at the end of `VMB_Refresh`, in `VMB_OnSize` and after
  zoom.
- The tree already sits directly under the "Blocks / Your macro" label row; make room by moving the
  tree down and shortening it by the header's height (about 16 px) - in BOTH layouts: the full layout
  (`VMB_BuildGui`) and the Easy layout (`V17_EasyLayout`, which lists the controls Easy mode shows:
  add `"ColHead"` there, and the Easy-layout self-test that counts shown controls goes from its
  current number to one more - update that expected number and say so in the item note).
- Switch: a checkbox `c["ColToggle"]` "Columns" next to the existing "Explain steps" checkbox in the
  Step settings panel (search for `ShowMeaning` / `V13_ToggleExplain` to find it), plus a tree
  right-click menu entry "Show columns" (see `VMB_TreeMenu`). Toggling writes the ini value, calls
  `V22_ApplyTreeFont()` and `VMB_Refresh()`. With columns off, rows and font are exactly V21's.
  Easy mode has no Step settings panel: the right-click entry is the way there.
- `V4_Help` / `V17_EasyHelp`: a short "NEW IN V22" paragraph that explains each column and each mark:
  `►` task moves to another program, `↕` list is scrolled back first, `⚡` changes each round,
  `◇` uses whatever window is active, `✎` has your note, `⚠` had a note in the last run,
  `*` after a time = a wait you set by hand.

## 6. Item D - status bar shows the full story for the selected row

Columns are compact; the selected row should spell everything out.

- New pure function `V22_Detail(node, app, lastNote)` returning one line:
  `Step 6 · notepad · waits 3.2 s first · Click a text box — top-left (120, 60) · list is scrolled back first · last run: <note>`
  (only the parts that apply; the step number is passed in or left out - keep it pure).
- In the tree's `ItemSelect` handler (set up in `VMB_BuildGui`:
  `s.TV.OnEvent("ItemSelect", ...)`), also call `VMB_Status(V22_Detail(...))` for a step row. Do not
  change what the handler already does. Do nothing while recording or playing
  (`VM_IsRecording()` / `VM_IsPlaying()`), because the status bar is in use then.
- Self-test `V22_Detail` with: plain step; step with every part.

## 7. Version text
- Line 1: `V21` -> `V22` plus a 3-line block: every row shows its program, fixed columns
  (#, Program, Waits, Marks, What it does), header line, switch to turn columns off.
- Window title: both places `"Visual Macro Blocks V21"` -> `"Visual Macro Blocks V22"`.

## 8. PC checklist to hand to the owner (put it in `V22-PC-TEST.md`)
1. Open a recorded macro. Every step row shows a program in the Program column; columns line up.
2. Record a task that uses two programs. The first step in the second program has `►`.
3. Put two steps inside a Repeat block (select them, "Into block above"). Their columns still line up
   with the rows outside the block. If they are off by a constant amount, report by how many characters.
4. Zoom the list with A+ / A-. Columns and header still line up.
5. If the marks show as boxes or push columns out of line, set `PlainMarks=1` under `[V22]` in
   `Documents\VisualMacros\VisualMacroBlocksV10.ini` and restart.
6. Right-click the list, untick "Show columns": the list looks like V21 again.
7. Click a row: the status bar shows the full sentence with program and wait.
8. Still open from the V21 checklist: items 1-6 there (scroll restore, captions, title bar buttons).

## 9. Hand back after each item
Find / replace blocks in file order with the function each is in; full text of each new function; the
new self-test lines and PASS count; anything you were unsure about (especially: the tree indent value
Windows actually accepted, and whether the header x needed a correction).
