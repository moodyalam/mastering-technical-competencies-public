# Lecture 3 · Beginner Lab: Your First Week, Hands On

**Mastering Computer Science Technical Competencies** · Lecture 3: The Monday After the 3 AM Page

**Time:** about 2 hours · **On your own laptop** · **Self-checking:** a script tells you when each part is done.

---

## The Scenario

In the lecture you watched someone else drive. This week, you drive.

> **From:** Jordan
> **Subject:** Your turn 🚗
>
> You saw how it's done on Monday. Now do it yourself, on your own copy:
> find your way around, tidy up `calc` for Mei, fix **ORD-317** for Grace and
> make the month-end report fast again (**ORD-361**).
>
> Write your answers in `lab3/BEGINNER.md` as you go. The self-check tells you
> what's done. And remember: *"Great. Now prove it."*
>
> — Jordan

The code on your lab branch is exactly the code from the lecture, bugs and all.
You can open the [demo guides](../../demo/) for help, but **try each part first
with only the hints here**. That's where the learning happens.

---

## About This Lab

| Part | Title | Lecture act | You'll use | Time |
|---|---|---|---|---|
| 0 | Warm-up: ORD-318 (optional) | 6 | The debugger | 10 min |
| 1 | Get the Lab Branch | 2 | Git, uv, the status bar | 10 min |
| 2 | Find Your Way Around | 3 | Go to Definition, Find All References, Go to Implementations, GitLens | 20 min |
| 3 | Refactor for Mei | 4 | Rename Symbol, Extract Method, the smoke tests | 15 min |
| 4 | Pair With an AI | 5 | Copilot autocomplete and inline chat, Pylance | 15 min |
| 5 | Debug and Fix ORD-317 | 6 | Hit count breakpoints, Variables, Debug Console | 25 min |
| 6 | Profile and Fix ORD-361 | 7 | `time`, `cProfile`, pyinstrument | 30 min |
| 7 | Finish | | The self-check | 5 min |

| Icon | Meaning |
|---|---|
| ✅ | **Checkpoint:** what you should see if everything worked |
| ❓ | **Check your understanding:** click *Answer* to reveal it |
| 💬 | **Discuss:** talk it through with a lab partner, if you have one |
| ⚠️ | **Warning** |
| 💡 | **Tip** |

Shortcuts are written **Windows/Linux · macOS**. On most Mac laptops the
F-keys need **`Fn`**: `F12` is `Fn+F12`, `F2` is `Fn+F2`, `F5` is `Fn+F5`.

**Before you start:** you need the set-up from
[Demo 0](../../demo/Lecture-3-Demo-0-Setup.md) (your fork, cloned, with the
set-up script's checks all `PASS`).

---

## Part 0: Warm-Up: ORD-318 (optional)

If you didn't do the [ORD-318 exercise](../../exercise/README.md) in the
lecture, do it now: 10 minutes, a student-discount bug, found with the debugger.
It's the gentlest way into Part 5.

---

## Part 1: Get the Lab Branch

The lab's starting code is on a branch in **the team's** repository
(`upstream`), added after you forked. Get it like this.

### Goal 1.1: Fetch the team's new branches

1. Open your project in VS Code: **File → Open Folder…** and choose the
   `novastack-orders` folder itself (not the folder above it).
2. Open a terminal in VS Code: **Terminal → New Terminal** (`` Ctrl+` `` · `` Cmd+` ``).
3. Download the team's latest branches:

```bash
git fetch upstream
```

- `git fetch` = download new commits and branches from another copy of the
  repo, without changing your files.
- `upstream` = the team's repository, `novastack-hq/novastack-orders`. The
  set-up script added it for you. (Your own fork is `origin`.)

✅ **Checkpoint:** the output includes `* [new branch] lab3/beginner-start -> upstream/lab3/beginner-start`.

<details><summary>Error: <code>'upstream' does not appear to be a git repository</code></summary>

Your clone has no `upstream` remote (perhaps you didn't run the set-up
script). Add it, then run `git fetch upstream` again:

```bash
git remote add upstream https://github.com/novastack-hq/novastack-orders.git
```
</details>

### Goal 1.2: Make your own lab branch

```bash
git switch -c lab3/beginner upstream/lab3/beginner-start
```

- `git switch` = change to another branch.
- `-c lab3/beginner` = **c**reate a new branch with this name: yours, to commit to.
- `upstream/lab3/beginner-start` = start it from the team's lab branch.

✅ **Checkpoint:** the status bar (bottom left) shows `lab3/beginner`, and the
Explorer has a new folder **`lab3`** with **`BEGINNER.md`** in it: your answer sheet.

### Goal 1.3: Check the set-up, and run the self-check once

1. Open any `.py` file. The status bar (bottom right) should show the
   interpreter: **`3.12.x ('.venv': venv)`**. If not: `Ctrl+Shift+P` ·
   `Cmd+Shift+P` → **Python: Select Interpreter** → the one in `.venv`.
2. Run the self-check:

```bash
uv run tools/check_lab3.py beginner
```

- `uv run` = run inside the project's environment (`.venv`).
- `tools/check_lab3.py` = the lab's self-check script. It only reads your work
  and runs the code; it never changes anything.
- `beginner` = which lab to check.

✅ **Checkpoint:** two `PASS` lines under *Part 1*, and lots of `FAIL`s. That's
expected: the `FAIL`s are this lab's to-do list. Run it again after each part.

💡 Some checks time the code on a big made-up month. Those take up to 15
seconds each until you've done Part 6.

---

## Part 2: Find Your Way Around

*You'll spend far more of your career **reading** code than writing it. The
language server (Pylance) lets you navigate by meaning, not by searching text.*

Answer **Q1 to Q5** in `lab3/BEGINNER.md`, writing each answer after the colon.
Each question has a tool that answers it in seconds. **Use that tool**, not
search (`Ctrl+Shift+F`).

| Q | Question | Tool to use |
|---|---|---|
| **Q1** | What is `STANDARD_RATE` (the VAT rate), and which file is it defined in? | Open `PriceCalculator` with **Go to Symbol in Workspace** (`Ctrl+T` · `Cmd+T`, type `PriceCalculator`), find where `__init__` uses `STANDARD_RATE`, then **Go to Definition** (`F12`, or `Ctrl`/`Cmd`+click). |
| **Q2** | Which two files in `src/` call `points_earned`? | `Ctrl+T` · `Cmd+T` → `points_earned`. Right-click the name → **Find All References** (`Shift+F12`). Ignore `tests/`. |
| **Q3** | Which class implements `EmailSender`? | `Ctrl+T` · `Cmd+T` → `EmailSender`. Right-click the class name → **Go to Implementations** (`Ctrl+F12` · `Cmd+F12`). |
| **Q4** | Who added the category loop in `PriceCalculator.calculate`, and in which ticket? | Open `pricing/calculator.py`, click on the line `for category, lines in basket.by_category().items():` and read **GitLens**'s grey inline blame at the end of the line. Hover it for the full commit. |
| **Q5** | Which function does `novastack report` call to add up the month? | Open `cli.py`, find `cmd_report` (`Ctrl+Shift+O` · `Cmd+Shift+O` lists the file's symbols), and **Go to Definition** on what it calls. |

💡 After a jump, **Go Back** with `Alt+←` (Windows/Linux) · `Ctrl+-` (macOS).
You'll use it constantly.

❓ **Check your understanding:** in Q2, why is Find All References better than
searching for the text `points_earned`?

<details><summary>Answer</summary>

Text search also finds `points_earned` in comments, in strings, in the
`points_earned` **field** of `Order` (a different thing with the same name), and
inside other words. Find All References asks the language server for uses of
*this function* only.
</details>

✅ **Checkpoint:** run the self-check. Part 2 is all `PASS`.

---

## Part 3: Refactor for Mei

> **Mei:** While you're in there, *please* rename `calc`. Nobody knows what it calculates. 🙏

### Goal 3.1: Rename `calc` everywhere, safely

1. Open `domain/basket.py` and put the cursor on `calc` in `def calc(line: BasketLine)`.
2. Press **`F2`** (Rename Symbol), type the new name, and press
   **`Shift+Enter`** to **preview** the change instead of applying it straight away:

```text
calculate_line_total
```

3. Read the Refactor Preview, then click **Apply**.

✅ **Checkpoint:** the preview listed **5 files**, including the `import` lines
and a test. Nothing called `calculator` or `calculate` was touched.

### Goal 3.2: Extract the receipt header into a function

1. Open `services/receipts.py`. In `render_receipt`, select the whole
   `header = [ ... ]` statement (all five lines).
2. Press **`Ctrl+.`** · **`Cmd+.`** → **Extract method**, and name it:

```text
receipt_header
```

✅ **Checkpoint:** a new function `receipt_header(order)` returns the three
header lines, and `render_receipt` now has `header = receipt_header(order)`.

💡 If Extract method isn't offered, check you selected whole lines, starting at
`header` and ending at the closing `]`.

### Goal 3.3: Prove nothing changed

A refactor must not change behaviour. Run the team's fast tests:

```bash
uv run pytest -m smoke
```

- `pytest` = the test runner; it runs the tests in `tests/`.
- `-m smoke` = only the tests **m**arked as the quick "smoke" tier.

✅ **Checkpoint:** `17 passed, 200 deselected, 1 xfailed`. (The *xfailed* one is
ORD-317: you'll fix it in Part 5.)

---

## Part 4: Pair With an AI

*AI is a lead, not an oracle. Read what it suggests, and check it.*

### Goal 4.1: Let autocomplete write a function from a precise start

1. At the **end** of `services/receipts.py`, type this, then press `Enter`:

```python
def discount_summary(order: Order) -> str:
    """One line per discount, e.g. "LOYALTY -£0.81", in the order applied."""
```

2. Wait for the grey suggestion and press `Tab` to accept it
   (`Alt+]` · `Opt+]` shows other suggestions).
3. **Read it.** Is anything underlined in red? Hover over it.

### Goal 4.2: Change it with inline chat

1. Select the whole function and press `Ctrl+I` · `Cmd+I`. Type:

```text
If the order has no discounts, return 'No discounts'.
```

2. Read the diff, then **Keep** or **Undo**.

✅ **Checkpoint:** the self-check's *Part 4* line passes. It tests your function
on Sam's order (two discounts) and an order with none.

<details><summary>Stuck, or the AI keeps getting it wrong? A correct version</summary>

```python
def discount_summary(order: Order) -> str:
    """One line per discount, e.g. "LOYALTY -£0.81", in the order applied."""
    if not order.discounts:
        return "No discounts"
    return "\n".join(f"{d.code} {format_price(-d.amount)}" for d in order.discounts)
```
</details>

Write **R1** now, while you remember: one thing an AI suggestion got wrong, or
that you had to check, and how you checked it. (No AI access? Write what you'd
check in a suggestion like this one.)

⚠️ Never paste secrets (passwords, keys, tokens) into an AI tool.

---

## Part 5: Debug and Fix ORD-317

> **ORD-317: Loyalty customers undercharged on meal deal orders** · P1 · reported by Grace (Finance)
>
> Sam Patel (Silver loyalty, 10%) paid **£5.95** for a chicken wrap, fries, a
> cola and an orange juice on Wednesday 7 October. Finance thinks it should be more.

### Goal 5.1: Reproduce it

```bash
uv run novastack quote data/samples/meal_deal_plus_drink.json --at 2026-10-07T12:30
```

- `novastack quote` = price a basket without paying (see `cli.py`, `cmd_quote`).
- `data/samples/meal_deal_plus_drink.json` = the basket: Sam's four items.
- `--at 2026-10-07T12:30` = pretend it's Wednesday lunchtime, so the result
  doesn't depend on today's date.

✅ **Checkpoint:** `TOTAL £5.95`, and **Loyalty card discount** appears **three times**.

❓ **Check your understanding:** before using the debugger, work out by hand what
Sam *should* pay. The items cost £10.70, the meal deal takes £2.60 off, and
Silver gives 10% off what's left, **once**.

<details><summary>Answer</summary>

£10.70 − £2.60 = £8.10. 10% of £8.10 is £0.81. £8.10 − £0.81 = **£7.29**.
</details>

### Goal 5.2: Pause on the second category

The loyalty discount is applied inside a loop over the basket's categories
(you found who added it in Q4). Pause on the loop's **second** pass.

1. Open `pricing/calculator.py` and find the line `if self._loyalty.applies(ctx):` inside the loop.
2. **Right-click** the margin left of its line number → **Add Conditional Breakpoint…** →
   change *Expression* to **Hit Count** → type `2` → `Enter`.
3. Open **Run and Debug** (`Ctrl+Shift+D` · `Cmd+Shift+D`), choose
   **CLI: quote the sample meal deal**, and press **`F5`**.

✅ **Checkpoint:** the program pauses on your line. Look at `category` in
**Variables**: that's **Q6**.

### Goal 5.3: Ask questions while paused

In the **Debug Console** (it opens at the bottom), type each of these and press
`Enter`, **one at a time**:

```python
running.amount
```

```python
[d.code for d in applied]
```

```python
category_subtotals
```

❓ **Check your understanding:** what do these tell you? Where should the loyalty discount be applied instead?

<details><summary>Answer</summary>

Already on the second pass, `applied` holds a `LOYALTY` discount, taken from
the first category's subtotal alone. It's applied once **per category**.
`docs/architecture.md` ("Pricing pipeline") and the docstring at the top of
`calculator.py` say it should be applied **once**, to the whole total **after**
the promotions (the meal deal).
</details>

Press `Shift+F5` to stop debugging, and **remove the breakpoint** (click the red dot).

### Goal 5.4: Fix it

Move the loyalty discount **out of the loop**, so it's applied once, after the
promotions and before the student discount. Then run the quote command from
Goal 5.1 again.

✅ **Checkpoint:** `TOTAL £7.29`, with **Loyalty card discount** once (−£0.81). Write it in **Q7**.

<details><summary>Hint: what the code should look like</summary>

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
</details>

### Goal 5.5: Dan's test

Dan wrote a test for ORD-317 before anyone fixed it, marked as an *expected
failure*. Run all the tests:

```bash
uv run pytest
```

✅ **Checkpoint:** one failure, **`XPASS(strict)`**: Dan's test now *passes*, and
the team set it up so that an expected failure that passes is an error. Its
reason says what to do: `ORD-317: remove when fixed`. Open
`tests/unit/pricing/test_calculator.py`, delete **only** that one
`@pytest.mark.xfail(...)` line, and run `uv run pytest` again: all green.

❓ **Check your understanding:** why does the team want a passing *expected
failure* to be an error?

<details><summary>Answer</summary>

So the marker can't be forgotten. Without `strict=True`, the bug could be fixed
(or come back!) and nobody would notice that the test's label was wrong. Strict
means the test suite tells you the moment its status changes.
</details>

---

## Part 6: Profile and Fix ORD-361

> **ORD-361: Month-end sales report has become very slow** · reported by Grace
>
> It used to take half a second. Now it's several seconds, and the export grows every month.

### Goal 6.1: Save the output and time it

Save the report's output, so you can prove later that your speed-up changed nothing:

```bash
uv run novastack report data/orders/2026-09.jsonl > before.txt
```

- `novastack report` = the month-end report (see `cmd_report` in `cli.py`).
- `> before.txt` = write the output into a file instead of the terminal.

Then time it. **macOS/Linux:**

```bash
time uv run novastack report data/orders/2026-09.jsonl
```

**Windows PowerShell:**

```powershell
Measure-Command { uv run novastack report data/orders/2026-09.jsonl }
```

✅ **Checkpoint:** several seconds. Note it down for **Q9**.

### Goal 6.2: Find where the time goes

**macOS/Linux:**

```bash
uv run python -m cProfile -s cumtime -m novastack_orders report data/orders/2026-09.jsonl | head -50
```

**Windows PowerShell:**

```powershell
uv run python -m cProfile -s cumtime -m novastack_orders report data/orders/2026-09.jsonl | Select-Object -First 50
```

- `python -m cProfile` = run a program under Python's built-in profiler.
- `-s cumtime` = **s**ort by *cumulative* time: a function's own time plus
  everything it calls.
- `-m novastack_orders report ...` = the program to profile (the same as `novastack report ...`).
- `| head -50` = show only the first 50 lines: the report's own output, then the profile.

The top lines contain *everything*, so skip them: Python starting the program
(`exec`, `run_module`, `_run_code`, `<module>`), then `main`,
`cmd_report` and `build_report`. The next function from `reporting.py` is **Q8**.

Now see the same thing as a tree:

```bash
uv run pyinstrument -m novastack_orders report data/orders/2026-09.jsonl
```

❓ **Check your understanding:** pyinstrument shows **two** hot spots under
`build_report`. What does each one do too often?

<details><summary>Answer</summary>

1. `is_returning_customer` searches the month's orders, for **every** order:
   about 71 million checks for 16,000 orders (cProfile's `<genexpr>` row). That's
   *quadratic*: double the orders and it takes about four times as long.
2. `category_of` **reads and parses `menu.json` again** for every basket line:
   about 39,000 times, for a file that doesn't change.
</details>

### Goal 6.3: Fix the biggest hot spot

Work out each customer's **first order time once**, before the loop, then use
it for every order. Write a function `first_order_times(orders)` that returns a
dictionary from customer ID to their earliest `placed_at`, and use it in
`build_report` instead of `is_returning_customer`.

<details><summary>Hint: the new function</summary>

```python
def first_order_times(orders: list[OrderRecord]) -> dict[str, datetime]:
    """When each customer first ordered this month, in one pass (ORD-355)."""
    first: dict[str, datetime] = {}
    for order in orders:
        if order.customer_id not in first or order.placed_at < first[order.customer_id]:
            first[order.customer_id] = order.placed_at
    return first
```

In `build_report`, before the loop: `first_order = first_order_times(orders)`.
In the loop: `if order.placed_at > first_order[order.customer_id]:` instead of
`if is_returning_customer(order, orders):`. Then delete `is_returning_customer`.
</details>

Time it again (Goal 6.1) and profile it again (Goal 6.2). **Measure, don't guess.**

### Goal 6.4: Fix the next hot spot

Now `category_of` is at the top. Read the menu **once**, before the loop, into a
dictionary from SKU to category, and look categories up in it.

<details><summary>Hint: the new function</summary>

```python
def load_categories(menu_path: Path) -> dict[str, Category]:
    """Every SKU's menu category, read from the menu file once."""
    menu = Menu.from_records(json.loads(menu_path.read_text(encoding="utf-8")))
    return {item.sku: item.category for item in menu}
```

In `build_report`, before the loop: `categories = load_categories(menu_path)`.
In the loop: `category = categories[line.sku]`. Then delete `category_of`.
</details>

### Goal 6.5: Prove it's the same, and faster

```bash
uv run novastack report data/orders/2026-09.jsonl > after.txt
```

In the Explorer, select `before.txt` and `after.txt` (`Ctrl`/`Cmd`+click both),
right-click → **Compare Selected**.

✅ **Checkpoint:** VS Code says the files are identical, and the report takes
well under a second. Fill in **Q9** (before, after the first fix, after both).

💡 If you installed **hyperfine** in Demo 0, it times a command several times
and gives you the average, which is fairer than a single run:

```bash
hyperfine --warmup 1 --runs 5 "uv run novastack report data/orders/2026-09.jsonl"
```

Delete `before.txt` and `after.txt` when you're done; they don't belong in the repo.

---

## Part 7: Finish

```bash
uv run tools/check_lab3.py beginner
```

✅ **Checkpoint:** `All done. Nice work. 🎉`

Then save your work in Git, on your lab branch:

```bash
git add -A
```

```bash
git commit -m "Lecture 3 beginner lab: ORD-317, ORD-361 and a tidier calc"
```

- `git add -A` = stage **a**ll your changes for the next commit.
- `git commit -m "..."` = save them as one commit, with a message.

💡 Pushing to GitHub, pull requests, reviews and CI are **Lecture 4**. For now
your work is safe in your local repository.

---

## Finished Early?

1. Try the **Try It Yourself** sections at the end of
   [Demo 2](../../demo/Lecture-3-Demo-2-Refactoring-and-AI.md),
   [Demo 3](../../demo/Lecture-3-Demo-3-Debugging.md) and
   [Demo 4](../../demo/Lecture-3-Demo-4-Profiling.md).
2. Debug ORD-317 again **without VS Code**. Go back to the unfixed code with
   `git switch --detach upstream/lab3/beginner-start`, put `breakpoint()` inside
   the loop, run the quote command, and use `p`, `n`, `c` and `q` at the
   `(Pdb)` prompt. Then undo it with `git restore .` and return to your work with
   `git switch lab3/beginner`.
3. Ready for more? Try the [Intermediate lab](../intermediate/README.md).
