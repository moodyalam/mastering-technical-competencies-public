# Lecture 3 · Demo 3: Why Are Loyalty Customers Undercharged?

**Mastering Computer Science Technical Competencies** · Lecture 3: The Monday After the 3 AM Page

---

## The Scenario So Far

Ticket **ORD-317**: Sam Patel (Silver card) paid **£5.95** for a chicken wrap,
fries, a cola and an orange juice. Grace in Finance says it should be **£7.29**.

You've reproduced it (the loyalty discount appears three times), you suspect a
loop that Priya added in ORD-301 ([Demo 1](Lecture-3-Demo-1-Setup-and-Navigation.md)),
you've tidied the code ([Demo 2](Lecture-3-Demo-2-Refactoring-and-AI.md)), and
Copilot has offered a confident explanation. Jordan's reply: **"Great. Now prove it."**

> *"The most effective debugging tool is still careful thought, coupled with
> judiciously placed print statements."* (Brian Kernighan, co-author of *The C
> Programming Language*)
>
> Today we'll see what comes after the print statements.

---

## About This Demo

**Time:** about 10 minutes.

| Step | Title | You'll use |
|---|---|---|
| 1 | A Routine, Not Luck | Reproduce → hypothesise → observe → fix → verify |
| 2 | Ask the Logs First | Python `logging`, log levels, `NOVASTACK_LOG_LEVEL` |
| 3 | Stop at the Right Moment | The Run and Debug view, a launch configuration, a conditional breakpoint, Variables, Watch, Call Stack |
| 4 | Ask Questions While Paused | The Debug Console, stepping |
| 5 | Log Without Editing Code | Logpoints |
| 6 | When There's No IDE | `breakpoint()` and `pdb` |
| 7 | AI as a Debugging Partner | Explaining evidence, not guessing |
| 8 | Fix It and Verify | The fix; the log and the CLI agree |

### Why this matters

- Professional developers use IDE debuggers **less than expected**, still rely
  on print debugging, and rarely know the advanced features (Beller et al.,
  *ICSE* 2018, 176 developers surveyed and 458 observed).
- Novices are better at *fixing* bugs than *finding* them (Fitzgerald et al., 2008).
  The tools below are all about finding.

| Icon | Meaning |
|---|---|
| ✅ | **Checkpoint** |
| ❓ | **Check your understanding** (click *Answer*) |
| 💬 | **Discuss** |
| ⚠️ | **Warning** |
| 💡 | **Tip** |

---

## Step 1: A Routine, Not Luck

| Stage | Question | Today |
|---|---|---|
| **Reproduce** | Can I make it happen on demand? | ✅ the CLI quote shows £5.95 |
| **Hypothesise** | What could cause exactly this? | The loyalty discount runs once per category |
| **Observe** | What is the program *actually* doing? | Logs, then the debugger |
| **Fix** | Smallest change that removes the cause | Move the discount out of the loop |
| **Verify** | Is it fixed, and nothing else broken? | The CLI says £7.29 |

---

## Step 2: Ask the Logs First

*Logging is print debugging that stays in the code, with levels, so you can turn the detail up when you need it.*

| Level | Used for |
|---|---|
| `DEBUG` | Detail for developers: every discount applied |
| `INFO` | Normal events: an order placed |
| `WARNING` | Something odd, but handled |
| `ERROR` / `CRITICAL` | Something failed |

NovaStack logs at `WARNING` by default. Turn it up for one run.

macOS / Linux:

```bash
NOVASTACK_LOG_LEVEL=DEBUG uv run novastack quote data/samples/meal_deal_plus_drink.json --at 2026-10-07T12:30
```

Windows (PowerShell):

```powershell
$env:NOVASTACK_LOG_LEVEL = "DEBUG"; uv run novastack quote data/samples/meal_deal_plus_drink.json --at 2026-10-07T12:30; Remove-Item Env:NOVASTACK_LOG_LEVEL
```

- `NOVASTACK_LOG_LEVEL=DEBUG` = set an **environment variable** for this one
  command. NovaStack's `config.py` reads it and shows log messages from
  `DEBUG` upwards (`src/novastack_orders/logging_config.py` sets this up).
  On Windows, `$env:…` sets it, and `Remove-Item Env:…` removes it again afterwards.
- `uv run novastack quote … --at …` = the same reproduction as in
  [Demo 1](Lecture-3-Demo-1-Setup-and-Navigation.md#goal-61-reproduce-the-ticket-first):
  Sam's basket, Wednesday lunchtime.
- The log lines come from `log.debug(...)` in `PriceCalculator._apply`
  (`src/novastack_orders/pricing/calculator.py`): one line per discount applied.

✅ **Checkpoint:** before the receipt, the log shows each discount being applied:

```text
DEBUG   novastack_orders.pricing.calculator: applied LOYALTY: -0.52 (running total 5.20 -> 4.68)
DEBUG   novastack_orders.pricing.calculator: applied LOYALTY: -0.68 (running total 6.78 -> 6.10)
DEBUG   novastack_orders.pricing.calculator: applied LOYALTY: -0.95 (running total 9.50 -> 8.55)
DEBUG   novastack_orders.pricing.calculator: applied MEALDEAL: -2.60 (running total 8.55 -> 5.95)
```

💬 **Discuss:** two things are wrong here. What are they? (Loyalty is applied
**three times**, and it's applied **before** the meal deal. The architecture doc,
`docs/architecture.md`, says: promotions first, then loyalty **once**.)

💡 A good habit: when a `print()` helps you find a bug, turn it into a log
statement before you delete it. Next time, the evidence is already there.

---

## Step 3: Stop at the Right Moment

*Logs tell you what happened. A debugger lets you pause the program and look at everything, at exactly the moment you choose.*

### Goal 3.1: Set a conditional breakpoint

1. Open `src/novastack_orders/pricing/calculator.py` (`Ctrl+P` · `Cmd+P`).
2. In `calculate`, find the line inside the loop: `if self._loyalty.applies(ctx):`.
3. **Right-click** in the margin left of the line number → **Add Conditional Breakpoint…**
   → **Expression** → type this, then press `Enter`:

```python
category == "drink"
```

✅ **Checkpoint:** a red dot with an `=` sign appears in the margin.

💡 A plain breakpoint (`F9`, or click the margin) would stop on *every*
category. The condition stops only on the third pass, the one you care about.

### Goal 3.2: Run the CLI under the debugger

1. Open the **Run and Debug** view (`Ctrl+Shift+D` · `Cmd+Shift+D`).
2. At the top, choose the configuration **CLI: quote the sample meal deal**.
   (The team keeps it in `.vscode/launch.json`: it runs exactly the command from Step 2.)
3. Press **`F5`**.

✅ **Checkpoint:** the program pauses on your line. In **Variables** → *Locals*:

| Variable | Value |
|---|---|
| `category` | `<Category.DRINK: 'drink'>` |
| `running` | `Money(amount=Decimal('9.50'), currency='GBP')` |
| `applied` | a list of **2** `AppliedDiscount`s, both `LOYALTY` |

4. In **Watch**, click **+** and add these two expressions, one at a time:

   ```python
   running.amount
   ```

   ```python
   len(applied)
   ```
5. In **Call Stack**, click `cmd_quote` to see the CLI's variables (the basket,
   the customer), then click `calculate` again.

💬 **Discuss:** does this confirm the hypothesis? (Yes. We're on the third
category and the loyalty discount has already been applied twice. When we
continue, it will be applied a third time.)

---

## Step 4: Ask Questions While Paused

*The **Debug Console** runs Python **inside the paused program**, using its
variables. Use it to test an idea ("how many discounts so far?") without
changing the code or re-running.*

Keep the program paused at the breakpoint from Step 3 (if it finished, press
`F5` again).

1. Open the **Debug Console**: the **Debug Console** tab in the bottom panel,
   or `Ctrl+Shift+Y` · `Cmd+Shift+Y`.
2. Click in the **input line at the very bottom** of the panel (it starts with `>`).
3. Type (or paste) **one expression at a time** and press `Enter` after each.
   The answer appears straight underneath.

⚠️ Paste **one line at a time**. If you paste several lines at once, the
console treats them as one block of code and shows no answers.

| Type this | It asks | Answer you should see |
|---|---|---|
| `running.amount` | What's the running total right now? | `Decimal('9.50')` |
| `len(applied)` | How many discounts have been applied so far? | `2` |
| `[d.code for d in applied]` | Which discounts? | `['LOYALTY', 'LOYALTY']` |
| `[str(d.amount.amount) for d in applied]` | How much was each? | `['0.52', '0.68']` |
| `ctx.customer.tier` | What tier is the customer? | `<LoyaltyTier.SILVER: 'silver'>` |
| `basket.subtotal()` | The basket before discounts? | `Money(amount=Decimal('10.70'), currency='GBP')` |

To copy them one by one:

```python
running.amount
```

```python
len(applied)
```

```python
[d.code for d in applied]
```

```python
[str(d.amount.amount) for d in applied]
```

```python
ctx.customer.tier
```

```python
basket.subtotal()
```

✅ **Checkpoint:** two LOYALTY discounts (£0.52 and £0.68) have *already* been
applied, and we're only on the third category. That's the evidence.

### Goal 4.2: Step through the next lines

| Key | Action |
|---|---|
| `F10` | Step over (run this line) |
| `F11` | Step into (go inside the function called on this line) |
| `Shift+F11` | Step out (finish this function) |
| `F5` | Continue to the next breakpoint |
| `Shift+F5` | Stop |

💡 On most Mac laptops, hold **`Fn`** for these keys (`Fn+F5`, `Fn+F10`, …), or
use the buttons on the debug toolbar at the top of the editor.

1. Press `F10` once: the yellow line moves to `running = self._apply(...)`.
2. Press `F10` again: the loyalty discount is applied a **third** time. In
   **Variables**, `running` drops from £9.50 to **£8.55** and `applied` now has 3 items.
3. Press `Shift+F5` to stop.

---

## Step 5: Log Without Editing Code

*Sometimes you want to see every iteration, not stop in one. A **logpoint** is a print statement you never have to delete, because it was never in the code.*

1. Right-click the breakpoint → **Remove Breakpoint**. (VS Code allows one breakpoint per line.)
2. Right-click the same margin → **Add Logpoint…** and type, with expressions in curly braces:

```text
{category}: running £{running.amount}, {len(applied)} discounts so far
```

3. `F5` again.

✅ **Checkpoint:** the program doesn't pause, and the Debug Console shows:

```text
main: running £5.20, 0 discounts so far
side: running £6.78, 1 discounts so far
drink: running £9.50, 2 discounts so far
```

4. Remove the logpoint.

❓ **Check your understanding:** why does `side` show £6.78 and not £5.20 + £2.10 = £7.30?

<details><summary>Answer</summary>

After the main (£5.20), 10% loyalty was taken off: £4.68. Then the side was
added: £4.68 + £2.10 = £6.78. The main has already been discounted, and it will
be discounted again on the next pass. That's the bug.
</details>

---

## Step 6: When There's No IDE

On a server over SSH (like Jordan at 3 AM) there's no VS Code, but Python has a
debugger built in.

1. Temporarily add this as the first line inside the loop in `calculate`:

   ```python
   breakpoint()
   ```
2. Run the Step 2 command in the terminal (without the log level).
3. At the `(Pdb)` prompt:

| Command | Does |
|---|---|
| `p category, running.amount` | Print values |
| `n` | Next line |
| `c` | Continue to the next `breakpoint()` |
| `l` | List the code around here |
| `q` | Quit |

4. **Remove the `breakpoint()` line.**

⚠️ Never commit a `breakpoint()`: the program would freeze in production,
waiting for someone to type at a `(Pdb)` prompt.

---

## Step 7: AI as a Debugging Partner

Copy the four `DEBUG` log lines from Step 2 into Copilot Chat:

```text
These are debug logs from our pricing calculator for one order. The loyalty
discount should be applied once, after promotions. What is the code doing
instead, and where in calculator.py should I look?
```

💬 **Discuss:** compare its answer with what the debugger showed you. In
practice, AI is **very good at finding** bugs from evidence (logs, stack
traces, cryptic errors) and **less good at fixing** them. Give it evidence, not
just "it's broken"; then verify what it says.

---

## Step 8: Fix It and Verify

### Goal 8.1: Move the loyalty discount out of the loop

In `calculate`, change the loop and the lines after it so that loyalty is
applied **once**, after promotions:

```python
        for category, lines in basket.by_category().items():
            category_total = total([calculate_line_total(line) for line in lines])
            category_subtotals[category] = category_total
            running = running + category_total

        for rule in self._promotions:
            if rule.applies(ctx):
                running = self._apply(rule, ctx, running, applied)

        # Loyalty applies once, to the whole promoted total (ORD-317).
        if self._loyalty.applies(ctx):
            running = self._apply(self._loyalty, ctx, running, applied)
```

Also delete the comment above the loop, `# Category subtotals and the loyalty discount in a single pass (ORD-301).`

(If you extracted a variable in Demo 2, use your variable name in the first line.)

### Goal 8.2: Verify with the same evidence

Run the Step 2 command again.

✅ **Checkpoint:** the log and the receipt now agree with Grace:

```text
DEBUG   novastack_orders.pricing.calculator: applied MEALDEAL: -2.60 (running total 10.70 -> 8.10)
DEBUG   novastack_orders.pricing.calculator: applied LOYALTY: -0.81 (running total 8.10 -> 7.29)
...
Subtotal                         £10.70
Meal deal (main + side + drink)  -£2.60
Loyalty card discount            -£0.81
TOTAL                             £7.29
```

### Goal 8.3: A loose end for next week

Run the team's fast tests again (the same command as in
[Demo 2, Step 4](Lecture-3-Demo-2-Refactoring-and-AI.md#step-4-tidy-and-check-act-4)):

```bash
uv run pytest -m smoke
```

✅ **Checkpoint:** `1 failed, 17 passed`, with the reason `[XPASS(strict)] ORD-317: remove when fixed`.

💬 **Discuss:** we *fixed* the bug and a test *failed*. Why? (Dan had written a
test that reproduces ORD-317 and marked it "expected to fail" with
`strict=True`, so it fails loudly the moment someone fixes the bug and forgets
to update it. Tests, and how teams use them to stop bugs coming back, are
**Lecture 4**.)

---

## Try It Yourself (lab practice)

1. On the unfixed code, set a **hit count** breakpoint on the `if
   self._loyalty.applies(ctx):` line so it pauses the **second** time. What's `category`?
2. While paused in `calculate`, call `self._loyalty.amount(ctx, running)` in the
   Debug Console. Is it safe to call functions from the Debug Console?
3. Quote the same basket for a **Gold** customer (`--customer C003`) before and
   after the fix. Work out the right total by hand first.

<details><summary>Answers</summary>

1. Right-click the margin → **Add Conditional Breakpoint…** → **Hit Count** → `2`: `category` is `Category.SIDE`.
2. It returns 10% of the running total (Silver). It's safe because `amount` only
   calculates. Calling something that saves to a database or sends an email from
   the Debug Console *would do it for real*.
3. Subtotal £10.70 → meal deal −£2.60 = £8.10 → Gold 15% (−£1.22, since £1.215 rounds up) = **£6.88**.
</details>
