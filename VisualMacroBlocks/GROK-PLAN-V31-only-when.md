# Work plan: V31 - "if / else if / else", error handling and variables, the Excel way (no blocks)

Do this AFTER V30. Work on the newest version file (`...-V30-listsheet.ahk2`), save as `VisualMacroBlocks-makecode-telek-V31-onlywhen.ahk2`.
Same rules as earlier plans (V19 plan section 1). Prefix `V31_`. Self-test `Failures: 0`, more PASS than V30. One commit per item + `V31-NOTES.md`.

## Idea
The owner thinks in Excel, not in code. V30 replaced loops with a List sheet and a Run switch. Do the same for the other
programming ideas - each becomes a COLUMN he fills in, never a block he nests:

| Programming idea | What he sees |
|---|---|
| if | column **Only when** on a step: `Status = On` |
| else if / else | the same column on the next steps: another rule, or `otherwise` |
| try / catch / retry | column **If it fails**: `stop` / `skip step` / `skip row` / `try 3 times` |
| variable | sheet **Values**: a name and a value, used in cells as `=name` |
| input | a Value marked `ask at start` |
| continue / break | two tiny step kinds: **Skip this row**, **Stop the run** (used with Only when) |
| wait until | step kind **Wait until window ... is open** |

Underneath, everything runs on the existing runner. Old macros and hand-made If blocks keep working unchanged.

## Item A - "Only when" (if)
- New Steps-grid column **Only when**, editable (V28 editor). Blank = always (shown as `always`).
- What he can type (pure parser `V31_ParseRule(text, names)` -> rule Map or an error sentence; `names` = list columns +
  Values names + `#`):
  `Status = On` · `Amount > 100` · `Amount >= 100` · `Name is empty` · `Name is not empty` · `Name contains Smith` ·
  `Status is not On` (same as `<>` / `!=`) · `# > 1` (round number) · `window Save As is open` / `window Save As is not open`
  (title contains, any program). Text compare ignores case; numbers compare as numbers when both sides are numbers.
  Quotes around the value are optional. Two rules joined by `and` / `or` (one level, no brackets).
- Right-click the cell -> a small builder: pick the name, pick the comparison, type the value (for people who do not want to type rules).
- Stored on the node as `when` (the text) - parsed again at run time. Pure `V31_Test(rule, lookupFn, windowOpenFn)`.
- Runner: in `V4Runner.Run`, before a step with `when` runs: evaluate; false -> skip it (counts as "skipped by rule", NOT a
  failure, no note). Values come from the current list row, then Values, then the runner's variables (`this.Lookup`).
- Grid: a step that will be skipped for the Preview row (V30) is shown greyed with `skipped for row 2` in the Last run /
  status area - so he can flip through preview rows and SEE which steps run for which row.

## Item B - "otherwise" (else if / else)
- In **Only when**, the word `otherwise` means: run only if the step(s) directly above with a rule did not run.
  `otherwise, Amount > 50` = else-if. A chain is: consecutive steps where the first has a rule and the following have
  `otherwise...`; several consecutive steps with the SAME rule text belong to the same branch (so a branch can be many steps).
- Pure `V31_Chains(steps)` marks for every step: its chain id and branch number; pure `V31_Decide(chainState, branch, ruleResult)`.
  Self-test: if only; if + otherwise; if + else-if + otherwise; two-step branches; a plain step ends the chain; `otherwise`
  with nothing above is refused with a plain sentence when typed.
- Grid look: steps of one chain get a thin coloured bar at the left of the Only-when cell, same colour per chain, so the eye
  groups them (custom draw is already used for the cell cursor).

## Item C - "If it fails" (try / catch / retry)
- New column **If it fails**, drop-down: `ask me` (macro default) / `stop` / `skip this step` / `skip this row` / `try 3 times, then stop`
  / `try 3 times, then skip row`. Stored as `onFailStep`. Blank = use the macro's setting.
- Runner: `V4Runner.OnFailure` consults the step's `onFailStep` first. Retries wait 1 s between tries and re-run only that step.
  Pure `V31_FailPlan(stepChoice, macroPolicy, triesDone)` -> `retry` / `stop` / `skip` / `nextrow` / `ask`; self-test all.

## Item D - Values sheet (variables and input)
- Third tab: **[Steps] [List] [Values]**. Rows: Name | Value | When (`fixed` / `ask at start` / `today's date` / `counts up`).
  Stored in `settings["values"]`. Names: letters, digits, underscore; must not clash with a list column (refuse with a sentence).
- Use in a Type cell as `=name` (same as list columns, V30). `ask at start`: one small form before step 1 with every such
  value (Enter = keep shown value). `counts up`: starts at Value, +1 each round. `today's date`: Value is the format (`MM/dd/yyyy`).
- New step kind **Remember** (Action `Remember`): `Remember clipboard as name` / `Remember "text" as name` - sets a Value during the
  run (reuses the existing `set` block underneath; show it in the grid as one plain row).

## Item E - Skip this row / Stop the run / Wait until window
- Two step kinds addable from the grid's right-click menu "Add step ▸": **Skip this row** and **Stop the run** (the existing
  `stop` block with action continue / endrun underneath - check `V4Runner.Node` case "stop" for the exact action words).
  Meant to be used with Only when: `Only when: Status = Off` -> `Skip this row`.
- **Wait until window ... is open / closed** (title contains, timeout seconds; fails after the timeout, so "If it fails" applies).
- "Add step ▸" also offers: Type text, Press keys, Wait (seconds), Remember - inserted below the current row.

## Help (top of `V17_EasyHelp`, plain words)
"Only when: type a rule such as  Status = On  to do a step only for some rows. Type  otherwise  on the next step for the
other rows. If it fails: choose what happens when a step cannot be done. Values: names you can type as =name."

## Live check (Wine) and PC check
Live, against Notepad with a 4-row list (Name, Status, Amount): steps = Type =Name; Type " big" Only when `Amount > 100`;
Type " small" `otherwise`; Skip this row Only when `Status = Off` (placed first); Press Enter. Expected text exactly:
rows with Status Off absent, others `Name big` / `Name small`. Check preview-row greying, a retry step that fails twice
then works (use a Wait-until-window on a window the harness opens late), `ask at start` form (answer by `SendEvent`),
`counts up`. Screenshot of the grid with Only when / If it fails columns and a chain's colour bar -> `V31-preview.png`.
PC-TEST-ALL.md new section "Rules".

## Later (do NOT do now)
"Repeat until <rule>" in the Run switch · rules on picture / pixel checks · a "Why was this skipped?" line per step in the
run history · sub-macros as named sheets.
