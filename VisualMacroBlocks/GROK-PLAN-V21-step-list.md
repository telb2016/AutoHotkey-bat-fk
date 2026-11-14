# Work plan: Visual Macro Blocks V21 (step list you can read at a glance)

Work on this file (same folder, same branch):
`VisualMacroBlocks-makecode-telek-V20-window-scroll-step-lines.ahk2`

Save the result as `VisualMacroBlocks-makecode-telek-V21-step-list.ahk2`.
Do items A to E in order, one commit each, with a short `V21-ITEM-x.md` note per item like last time.

## 0. Rules (same as the V19 plan - read `GROK-PLAN-V19-window-scroll.md` section 1 again)

- One AutoHotkey v2.0.19 file, no `#Include`, no libraries.
- Find / replace edits only; do not reformat. New functions use the prefix `V21_`, go in ONE new section
  directly above the `; ====` line that precedes `; V4 STARTUP / SINGLE-FILE PLAYER EXPORT`, and each has a
  `; @summary` and `; @tags` comment.
- Old macros must load and play exactly as before. This round changes only what the step list SHOWS,
  plus item D (opt-in by a field old steps do not have).
- Do not touch picture code (`V4_FindImage`, `ImageSearch`, `V18_VerifySpot`, `V18_PixelsMatch`,
  `V18_LocatePatch`, `V18_PreShot*`).
- `#Warn All` is on: assign before use; never name a variable after a function (`run`, `click`, `log`,
  `file`, `index` have all caused errors here).
- Inside a double-quoted AutoHotkey string a quote is written `` `" `` (backtick quote), never `\"`.
- Durations in text: use `V20_Time(ms)` ("500 ms", "1.5 s"), not `V13_Ms`.
- Every pure function gets checks in `V4_SelfTest`, placed right before
  `player := V4_PlayerSource(source, macro)`. The V20 file has 274 PASS lines; yours must have more and
  `Failures: 0`. Run: `AutoHotkey64.exe file.ahk --self-test C:\temp\report.txt`
- If you are unsure how Windows behaves, say so in the item note. Do not guess silently.

## 1. How the step list is built today (V20)

| Name | What it does |
|---|---|
| `VMB_Refresh(selectNode)` | rebuilds the whole tree; calls `VMB_NodeLabel(node)` for each row |
| `VMB_NodeLabel(node)` | text of one row. For steps: `" " . off . "#" . number . "    " . V20_StepLine(node)`; when `V20_StepLine` returns `""` it falls back to the older form |
| `V20_StepLine(node)` | `V20_StepSentence(node) . V20_StepTags(node)`, or `""` |
| `V20_StepSentence(node)` | the sentence. Handles `click`, `drag`, `wheel`, `text`, `keys`, `delay`, `wait`, `check`, `det_normalize_win`, `det_use_window`, `det_citrix_fill`. Returns `""` for everything else |
| `V20_StepTags(node)` | tags: pause, scroll, vary, active window, note |
| `V20_InApp(node)` | `" in notepad"` from the step's `win` |
| `V20_WhatText(node)` | `the "OK" button` / `a text box` from the step's `what` Map |
| `V20_CaptureWhat(x, y)` | at recording: what is under the mouse |
| `VMF_BlockText(node)` | text of container rows (REPEAT, IF, FOR ...) |
| `V4_WebDefs()`, `V4_InputDefs()`, `V10_DetDefs()` | definitions (label, fields, defaults) of web / input / measuring blocks |
| `s := VMB()` | editor state: `s.Macro`, `s.TV` (tree), `s.NodeItem` (node -> tree item), `s.FlatIndex` (node -> step number), `s.ShowMeaning` |
| `VMB_Play` | Play button; after the run `result.Warnings` is an array of note texts, each starting `"Step #<n>"` |

Example rows today:
```
#2   Click a text box in notepad — top-left (120, 60)
#3   Type "hello" in notepad
#4   Press Enter (OK / submit / new line) in notepad
#5   Type "world" in notepad   ⏱ after a 2 s pause
```

## 2. Item A - say the program only when it changes

**Problem:** "in notepad" on every row is noise; the eye should catch the moment the task moves to
another program.

**Change:**
- New pure function `V21_AppRuns(flatSteps)`: takes the flat list of steps in order
  (`VMF_Flatten(blocks)`) and returns a `Map` node -> `true` for the steps that should SHOW their
  program: the first step that has a `win` with an `exe`, and every step whose `exe` differs
  (case-insensitive) from the previous step that had one. Steps without `win` do not break a run.
- Store it in the editor state (`s.AppShow`), filled at the start of `VMB_Refresh` before rows are
  made, and also wherever a single row is re-labelled (search for `VMB_NodeLabel(` - there are three
  call sites; the one in the inspector re-labels one row, so recompute the map there too or the row
  could go stale).
- `V20_InApp(node)` gets an optional second parameter `show := true`; `V20_StepSentence` passes
  `VMB().AppShow.Get(node, true)` - but keep `V20_StepSentence` usable with no editor: wrap the lookup
  in a tiny helper `V21_ShowApp(node)` that returns `true` when `VMB().AppShow` is not a `Map` or has
  no entry. The existing V20 self-tests call `V20_StepLine` on loose nodes and must still pass
  unchanged.
- When the program is shown because it CHANGED (not the first one), write it stronger:
  `" → in notepad"`.

Self-test `V21_AppRuns` with: all same program; A A B B A; steps without `win` in between; empty list.

## 3. Item B - sentences for the remaining kinds

`V20_StepSentence` returns `""` for web blocks, basic-input blocks and the measuring blocks, so those
rows still look like `Web click   #submit`. Give each a sentence. Read the block's fields from its
definition before writing the sentence - do not assume field names.

- New function `V21_MoreSentence(node)`; `V20_StepSentence`'s final `return ""` becomes
  `return V21_MoreSentence(node)`.
- Web blocks (`web_*`, see `V4_WebDefs`): start with the verb, then the element, then the page part.
  Show a short, readable element name with `V21_SelectorName(selector)` (pure, self-test it):
  `#submit` -> `"submit"`; `[name="email"]` -> `email`; `[aria-label="Search"]` -> `Search`;
  `[data-testid="save-btn"]` -> `save-btn`; `form#login button.primary` -> `button.primary in #login`
  (last simple part, plus the nearest `#id` to its left when there is one); anything longer than 40
  characters is shortened with `V20_Short(text, 40)`.
  Examples: `Web: click "submit"`, `Web: type "{{Name}}" into email`, `Web: go to example.com/orders`
  (host + path only, no query string), `Web: wait for "results" to appear (up to 10 s)`.
  A fill step with `ask` set must never show its text: `Web: type what you answer when asked into password`.
- Basic-input blocks (`input_*`, see `V4_InputDefs`): `Send keys: Ctrl+A (select all)` using
  `V20_KeysText`; `Type "..."`; `Hold Shift down`; `Let go of Shift`.
- Measuring blocks (`det_*` other than the three already handled, see `V10_DetDefs` and
  `V10_DetStepInfo`): `det_wait_settled` -> `Wait until the area (x1, y1)–(x2, y2) stops changing`;
  `det_wait_pixel` -> `Wait until the dot at (x, y) is <colour mode>`; `det_anchor_click` ->
  `Click <n> px from the <bottom centre / top right ...> of the window`; `det_human_click` ->
  `Click at (x, y) with a human-like move`; `det_predict_row` -> `Pick "<item>" in the list (row is worked out)`.
- Any kind you do not recognise still returns `""` so the old form shows.

Self-test one line per kind above. Build the nodes with `V4_CreateNode(kind)` so the defaults are real.

## 4. Item C - container rows in the same plain style

`VMF_BlockText` gives `REPEAT 5 times`, `FOR i = 1 to 10 step 1`, `IF image appears`. Add
`V21_BlockLine(node)` and use it in `VMB_NodeLabel` for non-step rows when `s.ShowMeaning` is on
(keep `VMF_BlockText` itself unchanged: it is also used for the code view and for saving text).

- `repeat` -> `Repeat 5 times  (4 steps inside)`
- `foreach` -> `For each row of the list  (4 steps inside)`
- `for` -> `Count i from 1 to 10  (4 steps inside)` (add `in steps of 2` only when step is not 1)
- `until` -> `Repeat until <condition>  (at most 100 times)`
- `if` -> `If <condition>` ; ELSE rows unchanged
- `set` / `change` / `ask` / `stop` / `call` -> one short sentence each
  (`Remember "250" as amount`, `Add 1 to count`, `Ask me: <prompt>`, `Leave the loop`, `Run the macro <file name only>`).
- Conditions: reuse `VMF__CondText`, but for `cond = "var"` write `amount = 250` as
  `amount is 250`, `!=` as `is not`, `contains`, `is empty`, `is not empty`.
- Step count: `VMF_CountSteps(VMF_Children(node)[1])` (already used in `V13_Explain`).
- Keep the note suffix `  // note`.

Self-test each kind.

## 5. Item D - mark the steps that had a note in the last run

**Problem:** after a run the status bar says "⚠ Step #7 ... (+2 more)" and the user must open the log
to find which steps were shaky.

**Change:**
- Pure function `V21_NoteSteps(warnings)`: array of note texts -> `Map` step number -> first note
  text for that step (parse `^Step #(\d+)`; ignore texts that do not start that way). Self-test it.
- In `VMB_Play`, after the run: `s.LastNotes := V21_NoteSteps(result.Warnings)` when the WHOLE macro
  was played (`onlySelected` false); otherwise leave it alone. Clear it (`s.LastNotes := Map()`) when
  recording stops, when a macro is opened or New is pressed, and when a step is added, deleted or
  moved (step numbers shift) - the simplest safe place is inside `VMB_Snapshot()`, which every edit
  already calls. Check that `VMB_Play` itself calls `VMB_Snapshot()` BEFORE the run, so setting
  `LastNotes` after the run is not wiped.
- In `VMB_NodeLabel`, for a step whose number is in `s.LastNotes`, put `⚠ ` right after the
  `#number` and append the tag `   ⚠ last run: <note text without its "Step #n: " prefix, shortened to 70>`.
- Add `LastNotes: Map()` and `AppShow: 0` to the state object in `VMB()`.
- Nothing is saved to the macro file.

## 6. Item E - keep the window on the screen (playback safety, small)

`V17_NormalizeWindow` moves the window to its saved spot even when that spot is outside the current
screens (different monitor layout). A function already exists that fixes this for the per-click
size lock: `V14_FitOnMonitor(&x, &y, w, h)`.

- In `V17_NormalizeWindow`, compute `x := left + mx`, `y := top + my`, then - only when the macro has
  the setting `steady` (use `V18_Steady(ctx)`) - check whether the point `(x + 8, y + 8)` lies on any
  monitor (loop `MonitorGetCount()` / `MonitorGet`). If it lies on none, call
  `V14_FitOnMonitor(&x, &y, wantW, wantH)` and add one note with `V17_Warn`:
  `"Step #n: the saved window spot is off this screen; moved the window onto the main screen."`
- A spot that IS on a monitor is never changed (a window partly hanging off an edge was the user's
  choice).
- Pure helper `V21_OnAnyScreen(x, y, rects)` with `rects` = array of `[l, t, r, b]`; self-test it.
- The `V19_WaitSize` call for a fixed-size window compares the position: pass the adjusted x, y.

## 7. Version text
- Line 1: `V20` -> `V21`, and a 3-line block under it describing items A-E in plain words.
- Window title: the two places with `"Visual Macro Blocks V20"` -> `"Visual Macro Blocks V21"`.
- `V4_Help`: add a `NEW IN V21` paragraph above `NEW IN V20`.

## 8. PC test the owner should do once (also covers what could not be tested for V19 / V20)

Nobody has run V19 or V20 on real Windows yet. The checks below could not be done on the test machine.
List them in your final note so the owner can tick them off:

1. Scroll restore: Notepad, 300 lines, Word Wrap off, scroll to about line 150, Record, click a line,
   type `X`, stop, scroll to the top, Play. `X` must land on the same line and the step must show
   `↕ list scrolled back first`.
2. What was clicked: Record, click **File** in Notepad's menu bar, click **Save As...**, press Esc,
   stop. The rows should read `Click menu "File" ...` and `Click menu item "Save As..." ...`.
3. Button caption: record a click on any dialog button (for example **Cancel** in the Save As box).
   The row should read `Click the "Cancel" button ...`.
4. Title bar buttons: record a click on a window's Maximize button. The row should say so.
5. The tag icons (⏱ ↕ ⚠ ◇) should show as icons, not empty boxes. If they show as boxes on the
   owner's PC, replace them with plain text tags in `V20_StepTags` (`[pause 2 s]`, `[scrolls back]`).
6. Size test at Record-stop: the window should flicker once and return to its exact size.

## 9. Hand back after each item
1. The find / replace blocks in file order, with the function each is in.
2. Full text of each new function.
3. The new self-test lines and the PASS count.
4. Anything you were unsure about.
