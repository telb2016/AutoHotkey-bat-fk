# V21 - checks for the owner's PC (one time)

File: `VisualMacroBlocks-makecode-telek-V21-step-list.ahk2`. These could not be done on the test machine (Wine on
Linux: one screen, no real Windows controls, fonts without the icon characters). Tick each one off.

## 0. Self-test first

`AutoHotkey64.exe VisualMacroBlocks-makecode-telek-V21-step-list.ahk2 --self-test C:\temp\report.txt`
must end with `Failures: 0` and have **347** PASS lines (V20 had 274). Use the AutoHotkey version on the PC (the
file is written for v2.0.19; Wine used 2.0.27).

## From the plan, section 8 (V19 / V20 were never run on real Windows)

1. [ ] **Scroll restore:** Notepad, 300 lines, Word Wrap off, scroll to about line 150, Record, click a line, type
   `X`, stop, scroll to the top, Play. `X` must land on the same line and the step must show
   `↕ list scrolled back first`.
2. [ ] **What was clicked:** Record, click **File** in Notepad's menu bar, click **Save As...**, press Esc, stop.
   The rows should read `Click menu "File" ...` and `Click menu item "Save As..." ...`.
3. [ ] **Button caption:** record a click on any dialog button (for example **Cancel** in the Save As box). The row
   should read `Click the "Cancel" button ...`.
4. [ ] **Title bar buttons:** record a click on a window's Maximize button. The row should say so.
5. [ ] **Icons:** the tags `⏱ ↕ ⚠ ◇` - and in V21 also the arrow in `→ in calc` and the `⚠` after a step number -
   should show as icons, not empty boxes (under Wine they are empty boxes). If they are boxes on the PC, they need
   plain-text tags instead (`[pause 2 s]`, `[scrolls back]`, ...) - tell Grok Bot / Claude.
6. [ ] **Size test at Record-stop:** the window should flicker once and return to its exact size.

## V21 checks Wine could not prove

7. [ ] **Item A - program named only where it changes:** Record: click in Notepad, type a word, click in
   Calculator, press a key, click back in Notepad, type, stop. Only the first Notepad row says `in notepad`, the
   Calculator row says `→ in calc...` (the name comes from its exe, e.g. `CalculatorApp`), the next Notepad row says
   `→ in notepad`, the rest name no program.
8. [ ] **Item B - web rows:** in a macro with web steps (recorded with the browser, or dragged in from the Web
   blocks), the rows read like `Web: click "submit"`, `Web: type "..." into email`, `Web: go to example.com/orders`.
   A Fill step with "Ask for this text each time" must NOT show its text.
9. [ ] **Item C - block rows:** REPEAT / FOR / IF / REPEAT UNTIL / SET / Change / Ask me / Flow control / Run macro
   rows read like `Repeat 5 times  (4 steps inside)`, `If amount is 250`, `Leave the loop`. Untick "Explain steps"
   (Step settings panel): the old `REPEAT 5 times` rows come back.
10. [ ] **Item D - marks after a run:** make a run that gives a note (for example set a Normalize step to 60 x 60, or
    use the scroll test above with a shorter file). After the run the step shows `#1 ⚠` and ends with
    `⚠ last run: ...`. Play only one selected step: the marks stay. Change anything (move / delete a step, edit a
    field in the inspector): every mark goes away. New / Open: no marks.
11. [ ] **Item E - window kept on a screen (needs two monitors, or one changed layout):** with Steady playback on,
    record a macro with the window on the second monitor, then unplug it (or move it to the other side in Display
    settings) and Play. The window must come onto the main screen with the note
    `Step #1: the saved window spot is off this screen; moved the window onto the main screen.`
    Also check: a window recorded partly hanging off an edge (but still on a screen) is NOT moved; a second monitor
    to the LEFT of the main one (negative x) still counts as a screen; a macro without Steady is not changed.
    Unsure: monitors with different display scaling (DPI) - say what happens.
12. [ ] **Help box:** More features ▸, then `?` (or the Help menu): the box starts with `NEW IN V21`.
13. [ ] **Old macros:** open a macro made with V18 / V19 / V20 and Play it: it must behave exactly as before (only the
    step list text looks different).
