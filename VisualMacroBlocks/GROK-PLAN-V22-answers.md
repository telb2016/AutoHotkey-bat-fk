# V22: answers to the bots' open questions, and one small follow-up round

Work on `VisualMacroBlocks-makecode-telek-V22-columns.ahk2` and keep the same file name (this is V22.1,
not a new version; add one line under the V22 header block: `; V22.1 = answers round: see GROK-PLAN-V22-answers.md`).
Same rules as before. Self-test must stay at `Failures: 0` with more than 373 PASS lines.
One commit per numbered change, one short `V22-1-NOTES.md` at the end.

## Answers (decisions - no more questions needed on these)

| Your question | Decision |
|---|---|
| A: helpers `V22_Margin`, `V22_Sentence` not named in the plan | Good. Keep. |
| A: Repeat / If rows have no Program column | Correct. Keep. |
| A: program keeps the exe's case (`NOTEPAD`) | Change: show it lower-case. See change 1. |
| A: `400 ms` instead of `0.4 s` | Keep `V20_Time`. `400 ms` is fine. |
| A: blank-target step shows the Macro window, but at play time it uses the last "Use Window From Here On" | Change: the column must follow the last Use Window. See change 2. |
| A: every row starts with 24 spaces of margin | Change: size the margin to the macro. See change 3. |
| B: Windows may refuse a small tree indent | The fallback you wrote is right. Keep. Also show `s.IndentSeen` to the owner: see change 5. |
| B: no Consolas under Wine, mapped a stand-in font | Fine for testing. Nothing to change. |
| C: header text about 2 px left of the row text | Leave it. No correction. |
| C: header may clip at large zoom (fixed 16 px) | Change: height follows the font. See change 4. |
| C: tick box is `p.Columns` in the inspector, not `c["ColToggle"]` | Good. Keep. |
| D: optional 4th parameter `num`, wording of the parts | Good. Keep. |
| D: re-select after an edit must not overwrite that edit's status message | Good. Keep. |

## Changes

### 1. Program names in lower case
In `V22_AppOf` (or where it calls `V20_AppName` / `V20_TargetName`) apply `StrLower` to the result for the
column only. Do not change `V20_AppName` itself (V20 / V21 checks depend on it). Self-test:
`NOTEPAD.EXE` -> `notepad`; `web page` unchanged.

### 2. Program column follows "Use Window From Here On"
`V22_FillApps(flatSteps, settings)` walks the steps in order. Keep a variable `useTarget := ""`:
- a `det_use_window` step sets `useTarget` to its (trimmed) `target` (blank = back to the Macro window);
  its own Program is that target's program, or the Macro window's program when blank;
- any `det_*` / `input_*` step with a blank or missing `target` shows: `useTarget`'s program when
  `useTarget != ""`, else the Macro window's program (`settings` `defaultTarget`);
- steps with their own `win` / `exe` are unchanged.
This mirrors `V16_FallbackTarget` at play time. It is a display rule only.
Limit to state in the notes: the walk is in list order, so a Use Window inside an IF branch also colours
the rows after the IF. That is acceptable.
Self-test: Use Window B, then a blank-target Normalize -> `b`; Use Window blank, then Normalize -> the
Macro window's program; no Use Window at all -> the Macro window's program.

### 3. Left margin sized to the macro (no more 24 empty spaces)
Today depth-0 rows carry `8 * indentChars` leading spaces. Make it `maxDepth * indentChars`, where
`maxDepth` is the deepest TREE level that holds a row in the current macro (0 when nothing is nested).
- `V22_Margin(depth, indentChars, maxDepth := 8)` - add the third parameter with the old value as default,
  so existing checks still pass; result is `Max(0, maxDepth - depth) * indentChars` spaces.
- Pass it through `V22_Row`, `V22_Header` and the block-row code the same way (optional last parameter).
- Compute `s.MaxDepth` once per `VMB_Refresh`, before rows are built. Count tree levels exactly the way
  `V22_DepthOf` / the recursive add function count them (ELSE rows and "(empty)" placeholders are levels
  too). Simplest: a small recursive function over the block list that returns the deepest level at which
  a row will be added; say in the notes how you matched it to the add function.
- The single-row re-label call sites use the stored `s.MaxDepth`. An edit that changes nesting already
  goes through `VMB_Refresh`, which recomputes it.
- Self-test: with `maxDepth` 0 a depth-0 row has no leading spaces; with `maxDepth` 2 the Program column
  position plus `depth * indentChars` is equal for depth 0, 1 and 2; the header matches.

### 4. Header height follows the font
In `V22_PlaceHeader()` set the header's height from the tree font instead of a fixed 16 px: use the text
height you already can measure (`GetTextExtentPoint32W` gives width and height; reuse the measuring code
from `V22_ApplyTreeFont`, or keep the measured character height in `s.CharH`) plus 2 px. The tree's top
and height must move by the same amount, in both layouts, and again after zoom (A+ / A-).

### 5. Let the owner read the indent values without opening a file
Add one line to the end of the `V4_Help` text (Full mode help) and of `V17_EasyHelp`:
`"Column check: " . VMB().IndentSeen` (guard: only when it is a non-empty string).
Add to `V22-PC-TEST.md`, check 3: "If the rows inside a block are out of line, press ? and read me the
'Column check' line."

## Hand back
The usual: find / replace blocks, new function text, new self-test lines and the PASS count, and anything
you were unsure about.
