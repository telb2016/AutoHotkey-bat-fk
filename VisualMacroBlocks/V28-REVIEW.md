# V28 review (bug hunt on V27 / V28 code)

## Proven and fixed
- Cell edit that changes only letter case (abc -> ABC) was dropped: V28_Commit (and Ctrl+D copy-above) compared with `=`, which ignores case. Shown: `"abc" = "ABC"` is 1 in AutoHotkey 2.0.19 under Wine; fix `V28_SameText` (`==`); 2 new self-test checks (633 PASS, 0 failures).

## Suspected, unproven
- Click count 3 is offered in the grid, while the old Edit box accepts only 1 or 2. Playback (`Click(x, y, button, 3)`) and validation (only Repeat is checked) do not refuse it; no harm shown.
- Editing X / Y on a step with a Follows anchor (`ax` / `ay`) leaves the anchor alone; not tried live whether the result is what the user expects.
- Every VMB_Refresh and every filter keystroke rebuilds ListView rows (22 cells per step); not timed on a 500+ step macro.
- If V18_WaitModsUp / VMB_SetBusyUi throw between V27_RunStart and the try around VM_Play, the filter is not restored (nothing in the code path is known to throw).
- Not exercised live: real mouse paths, DPI above 96, Windows-only behaviour.

## Looked at and fine
- `V27_GridFocused` / `V28_EditorFocused` test the focused control's HWND (GetFocus, which is NULL when another program has focus) AND WinActive of this window, not playing, not recording, view = grid; false in list view.
- OnMessage(0x100 / 0x20A) handlers return nothing, act only for the grid / editor HWNDs, and are registered only in V28_Build (not in player / --self-test).
- V27_RunStart / V27_RunEnd: VM_Play errors are caught, so RunEnd always runs; Esc stop returns normally; RunStart closes the cell editor; VMB_StartRecording and V27_SetView do too.
- Number storage: count, delayMs, geo cx / cy, scrX / scrY, width / height, scroll.v are written as Integers; mods only "^", "+", "^+" or deleted; `disabled` deleted or 1.
- Edits use s.GridNodes[row] (the node shown), so sort / filter hit the right step; each edit takes VMB_Snapshot first (Ctrl+Z).
- Early-startup use of GridLV / GridBar / GridRows is guarded (V27_PlaceGrid, V27_ApplyGridFont, V27_FillGrid check for 0).
- List view: VMB_Refresh, PlayStatus, Zoom, PlaceHeader behave as V26 except for the added grid calls.
