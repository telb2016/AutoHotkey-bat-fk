# V33 review (bug hunt on V29 - V33 code)

Areas 1 (playback), 2 (save / load), 3 (editing safety), 4 (hotkeys / messages / timer) and 5 (performance) were all reached. Area 3 and 4 were by
reading plus direct-call fuzzing, not by real mouse / key presses. Real Windows, 32-bit AutoHotkey and mouse paths were not tested.

## Proven and fixed
- A rule that compares a number with a text (`Amount > 100` on `20 mg` or `N/A`) was decided by text order, so the wrong branch ran. V31_TestPart now says false when one side is a number and the other is not. Proof: new check "V33 rule: a number against a text has no order" failed on the old code (Failures: 1), passes now (945 PASS).
- Renaming a List column or a Value left the Only when rules with the old name; the grid preview showed `"Status" is not a name I know` and the run stopped at the first row, after earlier steps had already typed. New `V33_RenameInRules` (longest known name wins) is called from both rename paths. Proof: live Wine harness before = rules still `Status = On`, run stops with the sentence; after = `State = On`, run gives `out=aC`, Ctrl+Z restores the rules. 2 new checks (947 PASS).

## Suspected, unproven (no code changed)
- Steps numbers in sentences and `last run` notes ("Step #N") of list / times runs are the built run macro's numbers, one more than the grid for repeating steps (known from V30). The failing row IS selected correctly.
- A Value shadows a Set / Change variable of the same name (lookup order row, Value, variable): `Set tot = 99` then `{{tot}}` types the Value. By design, but silent.
- Ctrl+V on a List that already has rows now pastes at the cell instead of replacing the list; a shorter new list leaves old rows behind, which then run. Documented, but a pharmacy hazard.
- `Skip this row` at the top level of a once run (no list) ends the run with "Finished." A skipped-on-purpose row neither counts nor resets the 3-bad-rows streak (bad, bad, skipped, bad stops with "3 rows in a row").
- `otherwise` directly below a once-at-start step that has a rule: the grid shows a chain, the runner (head and loop body are separate lists) stops with "otherwise needs a step...". A rule naming a column on a once step reads the empty row (`Status` falls back to "On").
- Custom draw code from V29 on (cell frame, range, header, frozen pane) uses fixed 64-bit struct offsets (the older tree code handles 32-bit). With AutoHotkey32.exe the drawing would silently not happen. Not run (no permitted way found to run 32-bit here).
- The PHI scan covers steps only; List rows (possible patient data) are saved in the macro file, drafts and exported player.
- Not seen: the header custom draw / selected-row look on real Windows themes, DPI above 96.

## Looked at and fine
- Playback (headless, 25 scenarios): once steps run once; a failing once step stops the run; rules inside If blocks and hand-made repeat; disabled steps inside chains; counts-up (times, list, once, once-step, rule on a count); per-step skip / skip row / stop / retry 3 (list), skip row outside a row stops; old macros (no runMode / when / values) take the old path; 3 bad rows stops at the third; saved macro never gains foreach / repeat / run fields (build leaves it unchanged).
- Save / load: all new fields, kinds (Wait until window, Skip this row, Stop the run, Remember), settings.list / values / runMode / runTimes round trip equal, types equal (Integer stays Integer), VM_Validate accepts them.
- Editing: sorted paste goes to the shown rows; one Ctrl+Z undoes a multi-cell paste; band rows (select all + paste / delete / move / duplicate / delete) keep nesting; V32_Run removes ticks in a finally; stale ranges are node-based or clamped; 60+ handlers called on empty / 1-row / stale / List / Values states threw nothing; Undo only stores blocks (no List data loss).
- Hotkeys: all context hotkeys require own window active AND the control's HWND focused (GetFocus), not playing / recording; globals are only the old Ctrl+Shift+R/P/M/H/K/D/X; Ctrl+C/V/D/F/A, Alt+Up/Down, F2, F3, Delete, Enter, Tab are never global. OnMessage handlers return nothing unless the HWND is theirs (wheel handlers return 0 only over the grid / pane). Frozen-pane timer returns at once when the grid is not visible (hidden / tray / other sheet).

## Timings (Wine + Xvfb, 600 steps, list + rules, grid view)
- VMB_Refresh 620 ms (V27_Rows 230 ms of it; about 410 ms with no list, so V29-V33 add ~200 ms): over 300 ms, not fixed (no small safe fix).
- V27_FillGrid 350 ms; filter keystroke (V27_Refill) 100-140 ms; sort click 170-190 ms; Shift+Down range step 10 ms; V33_Live 0 ms.
- Frozen-pane tick 0-10 ms (refill of 600 rows 10 ms).
- Multi-cell paste of 21 cells about 1.0 s (it ends in a VMB_Refresh); Ctrl+A copy of 15000 cells 1.0 s; Ctrl+A paste 3.2 s; Undo 0.85 s; VMB_Snapshot 54 ms.
