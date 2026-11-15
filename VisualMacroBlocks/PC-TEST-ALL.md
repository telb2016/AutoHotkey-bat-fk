# PC test - one sheet for V19 to V26

File: `VisualMacroBlocks-makecode-telek-V26-pccheck.ahk2`. This replaces the separate V21 / V22 / V23 / V24 / V25 checklists
(those files stay in the folder, but you do not need them). Nothing here was ever run on a real Windows PC yet.

## 1. Press the button (about 20 seconds, no clicking)

Start the V26 file. Click the **?** button (next to "Step grid"), choose **Check this PC...** (or right-click the step list >
Check this PC...). Do not touch the mouse or keyboard for 20 seconds. One result window opens: press **Copy**, then paste it
back to us. Lines say PASS or CHECK. If it offers **Use plain marks**, press it once and restart the program.

## 2. Hand checks the button cannot do (8 at most)

1. Record a click on a dialog button (for example Cancel in Notepad's Save As box) -> the row in the list reads `Click the "Cancel" button ...`.
2. Press Play -> the step that is running is yellow, and the list does not jump around.
3. Close Notepad, then press Play on a macro that uses it -> a "Ready to play?" box says Notepad is not open (and does not stop you if you choose to go on).
4. Play a saved macro 3 times, right-click > Run history... -> 3 lines and a summary line "Last 3 runs: ...".
5. Look at the step list -> black text on white, no coloured bars (right-click > Coloured rows brings the colours back).
6. Put a step inside a Repeat block -> the # / Program / Waits / Marks / What columns still line up for the steps inside it.

## 3. Grid (V27 file: `VisualMacroBlocks-makecode-telek-V27-grid.ahk2`)

Open a macro with steps in at least two programs (and, if you can, a Repeat block). The [Grid] button must be on.

1. The grid shows one row per step, every cell filled (`–` where a cell does not apply), with grid lines. The text is the same size as the rest of the window; A+ / A- make it bigger / smaller.
2. Click the **Program** header: rows group by program and the header shows a small triangle. Click it again: reverse order. Click **Step order** (or the `#` header): back to the macro's order. The status bar says the sort is only a view.
3. Type `click` in the filter box above the grid: only click steps show, and the status bar says `Showing N of M steps`. Try `program:notepad` and two words (`click notepad`). Pick a Program in the first drop-down: only that program's steps show. **Clear** shows everything again.
4. Select a row while it is sorted and filtered, press **Edit** (or double-click the row): the right step opens. Right-click a row: the usual step menu.
5. Press Play with a filter typed: the filter clears, the running row is selected and scrolls into view; after the run the filter is back.
6. Click **Copy table**, paste into Excel: a header row, and each value lands in its own cell. Select one row, press Ctrl+C, paste: that row only.
7. Click **[List]**: the tree is back exactly as before, and the filter row is gone. The step numbers in the grid (they can skip a number where a Repeat / If block has one) are the same as in the list.

## 4. Edit cells (V28 file: `VisualMacroBlocks-makecode-telek-V28-editcells.ahk2`)

Open a macro with a click, a Type step and a Press step. The [Grid] button must be on. Try it at 100% and, if you can, at 125% / 150% screen scaling.

1. Double-click a **Waits first** cell, type `2`, press Enter: the cell shows `2 s*`. Press Ctrl+Z: it is back to what it was. The little box must sit exactly on the cell (same left, top, width and height), also after you scroll the grid sideways.
2. Change a **Type** step's text in the grid, press Play: the new text is typed.
3. Change **Clicks** from 1 to 2 (the box is a drop-down): the Action column changes to Double-click.
4. Type `abc` into an **X** cell and press Enter: nothing changes, the box stays open and the status bar says why. Press Esc.
5. Select a row, press Right until the status bar says `Cell: Program`, press F2: the status bar says the cell is worked out from the step, and double-click on it opens the normal Edit box.
6. Press Tab in an open box: it saves and opens the next cell you can change. Shift+Tab goes back. Enter saves and moves the selection down one row.
7. Sort the grid by Program and type a filter, then edit a cell: the right step changes (check it in [List] view).
8. On a Note cell (or a Waits cell with a value) press Delete: it is cleared. Press Ctrl+D on an empty Waits cell under a row that has a wait: the wait is copied.
9. Select a row on a Waits cell and just type `3`, then Enter: the box opens with `3` already in it and the wait becomes 3 s.
10. While a macro plays or records, double-click a cell: no box opens.
11. Click [List]: everything looks and works as before.
