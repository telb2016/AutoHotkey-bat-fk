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
