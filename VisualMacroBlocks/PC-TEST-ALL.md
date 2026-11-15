# PC test - one sheet for V19 to V33

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

## 5. Excel feel (V29 file: `VisualMacroBlocks-makecode-telek-V29-excel.ahk2`)

Open a macro with a click, a Type step and a Press step. The [Grid] button must be on. Try it at 100% and, if you can, at 125% / 150% screen scaling.

1. Hold **Ctrl** and turn the mouse wheel over the grid: it zooms in steps (50 70 80 90 100 110 120 130 150 175 200 %), the text and the column widths grow and shrink together, and the percent at the right end of the filter row follows. Ctrl + plus, Ctrl + minus and Ctrl + 0 (100 %) do the same while the grid has the focus. The wheel without Ctrl still scrolls. The list's A+ / A- does not change the grid.
2. Zoom to 150 %, double-click a **Waits first** cell: the little edit box sits exactly on the cell and uses the same big text.
3. A **green frame** marks the current cell. Click another cell: the frame jumps there and the box left of the filter names it (`Waits first · step 7`). Arrow keys, **Home** / **End** (first / last column), **Ctrl+Home** / **Ctrl+End**, **Tab** / **Shift+Tab** (next / previous cell, on to the next row at the end) move it. If the frame is hard to see, say so.
4. On a **Waits first** cell press **Ctrl+C**, select a Type step's Waits cell, press **Ctrl+V**: the wait is pasted; Ctrl+Z undoes it. Paste into Excel also gives the text. **Shift+Ctrl+C** copies the whole row. Ctrl+V on a worked-out cell (Program) says it cannot; Ctrl+X on a Note cell copies and clears it.
5. **Drag a column title** to another place: the column moves, and Right / Left follow the new order.
6. **Right-click a column title**: a menu with every column ticked. Untick one: it disappears and the cursor skips it. Right-click > **Reset columns** brings everything back.
7. Zoom, move and hide something, close the editor window, open it again: zoom, widths, order and hidden columns are as you left them.
8. Click **[List]**: the list looks and works as before; Ctrl + wheel / Ctrl + plus there still behave as before (the list zoom).
9. While a macro plays or records, none of these keys do anything in the grid.

## 6. List (V30 file: `VisualMacroBlocks-makecode-telek-V30-listsheet.ahk2`)

Use a real program with a form (for example a web form or an app with two text boxes). The four steps are the same as in the help ("To do the same thing for many items").

1. **Record it once** for the first item (for example type `Smith`, press Tab, type `250`, press Enter). In the grid the Type steps show `Smith` and `250`.
2. In Excel copy three rows with column names in the first row (`Name`, `Amount`; `Smith 250`, `Jones 75`, `Lee 5`). In the macro click the **List** tab under the grid, then press **Ctrl+V** (or **Paste list**). The three rows appear, the column names are the header.
3. A question asks whether the Type steps that typed `Smith` / `250` should use the list columns. Answer **Yes**. Click the **Steps** tab: the cells now read `=Name → "Smith"` and `=Amount → "250"`. Change **Preview row** (above the grid, right side): the quoted values change to row 2, row 3.
4. Above the grid choose **for each row of the List (3 rows)** and press **Play**. The program gets Smith / 250, Jones / 75, Lee / 5, one after the other. The status bar says `3 rows: 3 done.`; the List tab shows `done` in the Result column.
5. Save the macro and open the file in a text editor: it has a `list` and `runMode`, and **no** `foreach` / `repeat` block.
6. Make one row fail (for example close the program for one row, or give a step something that cannot work): that row is skipped, the run goes on, the status bar says `... 1 skipped (row N).` and Result says `skipped: ...`.
7. Choose **N times** with 3, put `=#` in a Type step (right-click the cell -> Use list column -> `# (the round number)`) and Play: it types 1, 2, 3.
8. On the List tab double-click a cell, type, press Enter / Tab / Esc; Ctrl+Z undoes it; click a column name to rename it (Type steps that used the old name follow). Right-click the Text cell of a Type step: the menu offers *Use list column*, *Type fixed text...*.
9. Open an old macro (no List): nothing looks different; the Run line says **once**. A macro with its own Repeat / For each blocks shows the note *This macro has its own loop blocks (see List view)* instead of the choices. Easy mode shows the Run line and the tabs too.
10. Look at the **Repeats** column (to the right of Waits first): the first window steps say *once at start*, the rest *yes*. Try setting step 5 to *once at start* while step 4 says *yes*: a sentence refuses it.

## 7. Rules (V31 file: `VisualMacroBlocks-makecode-telek-V31-onlywhen.ahk2`)

Use Notepad. Make a list with the columns `Name`, `Status`, `Amount` and four rows: `Anna On 150`, `Bob Off 500`, `Cy On 20`, `Di On 100`. Steps: Use Window (Notepad), then a Type step `=Name`, a Type step ` big`, a Type step ` small`, a Press `{Enter}` step. Choose **for each row of the List**.

1. Click the **Only when** cell of the ` big` step (it says `always`), press **F2**, type `Amount > 100`, Enter. Do the same on the ` small` step with `otherwise`. The two cells get a thin coloured bar at the left (same colour = one chain).
2. Right-click a Type step -> **Add step** -> **Skip this row**. A row `Skip this row` appears below it. Move it up to the first step after Use Window (or add it there) and give it the rule `Status = Off`. Play. Notepad must read exactly: `Anna big` / `Cy small` / `Di small` (Bob is absent). The status bar says `4 rows: 4 done.`
3. Change **Preview row** to 2, then 3: steps that would be left out for that row turn grey and their Only when cell says `skipped for row N`.
4. Type a rule with a name that does not exist (`Colour = red`): a sentence refuses it and says which names you can use. Type `otherwise` on the first step: a sentence says it needs a step with a rule right above it.
5. Right-click an Only when cell -> **Build a rule...**: pick a name, a comparison and type a value; OK puts the rule in the cell. Ctrl+Z undoes it.
6. Add **Add step -> Wait until window...**, double-click its Text cell and type `Save As is open within 5 s`. Play with no such window open: the run stops after 5 s with a sentence. Set its **If it fails** cell to `try 3 times, then stop`; open the window during the tries: the run goes on. The other choices (`skip this step`, `skip this row`, `stop`, `ask me`) do what they say.
7. Make three rows in a row fail (for example give a step a window that is not there with `skip this row`): the run stops after the third with `3 rows in a row could not be done - stopped so the rest are not skipped too.`
8. Open an old macro: the two new columns show `always` and `macro setting`, nothing is greyed, and it plays as before. In **Easy** mode the Blocks toolbox on the left is plain black on white; right-click the step list -> **Coloured rows** brings the colours back in the list and the toolbox.
9. **Values** (V31.1). Click the **Values** tab (next to Steps and List). Click **Add value**, type `greeting`, Tab, `Hello`, Enter. Add `n` = `10` and set its **When** to `counts up`; add `who` = `friend` with **When** `ask at start`; add `d` with **When** `today's date` (Value becomes `MM/dd/yyyy`). Names may have letters, digits and `_` only: try `Name` (a list column), `n` again, `#` and `my name` - each is refused with a plain sentence and the editor stays open.
10. On the Steps sheet make Type steps `=greeting`, a space, `=Name`, a space, `=n`, a space, `=who`, then Press Enter (type the `=` names in the Text cell; the cell then reads `=greeting → "Hello"`, `=n → "10"` ... and follows the Preview row: `=n` shows 10, 11, 12). Add a last Type step `!` and give it the rule `n > 10`. Choose **for each row of the List** and press **Play**. A small form `Values for this run` appears **before step 1** with one box (`who`, showing `friend`): type `Zed`, Enter. Notepad must read exactly `Hello Anna 10 Zed` / `Hello Bob 11 Zed!` / `Hello Cy 12 Zed!`. Play again and press **Cancel**: nothing is typed and the status bar says `Stopped before step 1`.
11. Right-click a row -> **Add step** -> **Remember clipboard as...**, copy some text, double-click its Text cell and type `clipboard as total` (or `"Bye" as total`; a new name makes its row on the Values sheet). A later Type step `=total` types it. The Action column says **Remember**.
12. **Exported player**: use Export (one-file player) for a macro with an `ask at start` value and run the exported file: it asks the small form before step 1 and counts up / today's date work the same. An old macro (no Values) shows no Values rows and plays as before.

## 8. Rows, filters, Find (V32 file: `VisualMacroBlocks-makecode-telek-V32-rows.ahk2`)

Open a macro with at least 6 steps (Type steps with different texts are easiest) in Grid view, Steps sheet, Step order, no filter.

1. Click row 3, press **Alt+Down**: the row moves one place down (check the order in the # / Text columns). **Alt+Up** moves it back. **Ctrl+Z** undoes each move. Same row stays selected and the green cell cursor stays in its column.
2. Press **Shift+Down** twice: three rows are shaded light blue (the last one in the normal blue). **Alt+Down** moves all three together; **Ctrl+Shift+D** duplicates all three (copies appear below them); **Ctrl+Z** undoes. Click a single row: the shading goes.
3. Press **Shift+Delete** on one row: one box asks (only the first time since the program started), Yes deletes it. Do it again on another row: no box. **Ctrl+Z** brings both back. Shift+click a second row to extend the range (mouse - not tested under Wine) and delete the range.
4. **Ctrl+Shift+plus** (Ctrl+Shift+= on most keyboards): a new Type step `text` appears below the selected row. Press F2 on its Text cell and type something. **Ctrl+Z** twice removes it.
5. Right-click a row: Insert step above / below (the Add step kinds), Duplicate row, Delete row, Move up, Move down, Turn off / on, More step actions... Try each once. Right-click a Type **Text** cell or an **Only when** cell: the small menu now also has **Row actions...**.
6. Click a column title (sort), then press Alt+Down on a row: the status bar says `Sort and filter are on: switch to Step order to move rows.` and nothing moves. Press **Step order** and it works again. Same with the filter box and the two drop-downs.
7. **Filter arrows**: every column title ends with `▼` in V33 (`▾` in V32; an empty box means a missing glyph - set `[V22] PlainMarks=1` in the ini to get `v` instead). Click the **right end** of the Program title (not the middle): a small list opens under the title with a search box, **(Select all)** and the values. Untick one program, press **OK**: only the other rows show, the title now ends with `▼=`, the status bar says `Header filter on Program`. Do the same on **Action**: both filters work together. Clicking the middle of a title still sorts.
8. With a header filter on, type in the filter box too: all of them work together. **Clear** removes all of them. Start a run with a filter on: the filter is off while it runs and comes back after.
9. **Find**: click the grid, press **Ctrl+F**. A Find bar opens above the grid. Type part of a text: the cell cursor jumps to the first match and the bar says `1 of N`. **Enter** or **F3** = next, **Shift+Enter** or **Shift+F3** = previous, it wraps round. **Esc** closes the bar. No row is hidden. Do it on the **List** and **Values** tabs too.
10. Make a macro in List view (not the grid) with a **Repeat 3 times** block with two steps inside. Switch to Grid: a shaded band row `Repeat 3 times` and its two steps indented under it. F2 or typing on the band row does nothing but say it cannot be edited. Click a title to sort: the band rows disappear; **#** or **Step order** brings them back. Alt+Down on a step moves it inside its block only.
11. **List view** (the tree) is unchanged: Alt+Down, Shift+Delete and Ctrl+F do nothing there; the old Delete / Move buttons work as before. An old macro with no loop blocks looks and plays exactly as in V31.
12. Windows scaling 125 % / 150 %: the arrow zone of a title is 18 px (scaled); check that a click at the arrow end opens the list and not the sort, and that the list opens right under the title. Also check the light-blue range shading and the band row colours are easy to read.

## 9. Cell ranges and Excel look (V33 file: `VisualMacroBlocks-makecode-telek-V33-cells.ahk2`)

Open a macro with at least 6 steps in Grid view, Steps sheet, Step order, no filter. Give three of them a wait (double-click their **Waits first** cell, type `2`, `1.5`, `500ms`) and leave the others automatic.

1. **Select a block.** Click a **Waits first** cell, press **Shift+Down** twice and **Shift+Right** once: a light-blue rectangle of 3 rows x 2 columns, the green frame on the cell where you ended. The status bar starts with `6 cells`. Shift+Left shrinks it. **Ctrl+Shift+Down** goes to the last row, **Ctrl+Shift+Right** to the last shown column, **Ctrl+A** selects every cell (`N cells`). A plain arrow key or a plain click goes back to one cell. **Shift+click** another cell (mouse - not tested under Wine) grows the block to it.
2. **Summary.** Select only cells of the **Waits first** column that all have a time (`2 s`, `1.5 s`, `500 ms`): the status bar says `3 cells · Waits first: total 4 s`. Include a cell that says `auto`: it says only `4 cells`. Select a **Text / keys** block: only the count.
3. **Copy to Excel.** Select a block (for example Waits first and Note, 3 rows), **Ctrl+C**, paste into Excel: the same cells, one Excel cell each. In the other direction copy 2 x 2 cells in Excel (a time and a text per row) and put the grid's cursor on a **Waits first** cell whose right neighbour in the shown order is **Note**: **Ctrl+V** fills all four cells; the status bar says `Pasted 4 cells.` One **Ctrl+Z** puts all four back.
4. **A cell that refuses.** Paste `5` / `abc` into two Waits first cells: the status bar says `Pasted 1 cell, 1 could not take the value.` and the good one is changed. Paste one value (`2 s`) with a block of Waits cells selected: all of them get it. Paste a block that is longer than the sheet: the rows that do not exist are dropped and counted.
5. **Fill.** Type a note in the first of 4 selected Note cells, press **Ctrl+D**: the rest get it (one Ctrl+Z undoes all). **Ctrl+R** copies the left cell of each row into the rest (try Waits first into Note). One cell selected: **Ctrl+D** still copies the cell above (V28).
6. **Delete / cut.** Select Waits first and Note for 3 rows, press **Delete**: both are cleared (cells worked out from the step are left alone and counted). **Ctrl+X** copies the block and clears the same cells. One Ctrl+Z each.
7. **List and Values sheets.** On the **List** sheet: Shift+arrows select a block, Ctrl+C copies it, **Ctrl+V** in the middle of a filled list pastes from the cell (a paste past the last row adds rows and says so), Ctrl+D / Ctrl+R fill, Delete empties, Ctrl+Z (on that sheet) undoes the whole paste. A column of numbers selected: `4 cells · Sum: 125`. An empty List: Ctrl+V still pastes the whole list as before. On **Values**: the Value and When columns take pastes and fills, a Name is never changed by a paste (counted).
8. **Undo keeps your row.** Change a cell in row 5 (any cell), press Ctrl+Z: row 5 is selected again and the green frame is in the same column (before V33 the first row was selected).
9. **Frozen # and Action.** With the grid wider than the window, scroll sideways with the bar or the wheel (Shift+wheel) until the `#` column is out of view: a narrow pane with **#** and **Action** appears at the left, its rows line up with the grid's rows. Scroll down: both scroll together. Click a pane row: that row is selected in the grid. Scroll back to the left edge: the pane goes. Right-click a column title -> **Freeze # and Action** (ticked) turns it off (and back on). While you edit a cell the pane is hidden. Try Windows scaling 125 % / 150 % and a very long list (500+ steps): the pane must keep its rows in line.
10. **Excel look.** Column titles are light grey with a thin line below, the `#` column is grey like Excel's row numbers, the selected row is light grey-green (text stays black), the range is light blue, the active sheet tab is bold. In the ini `[V33]` set `ExcelLook=0` and restart: the V32 look is back (blue selected row, plain titles). The colours are all in the function `V33_Look` if you want to change them.
11. **Nothing else changed.** List view (the tree) behaves as in V32. V32's row keys (Alt+Up / Alt+Down, Shift+Delete, Ctrl+Shift+D) and V28's single-cell edit (F2, Enter, typing) work as before on a single cell and on a row range. An old macro looks and plays exactly as before.
