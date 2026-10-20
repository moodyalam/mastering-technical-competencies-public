# Lecture 3 · Intermediate Lab: Your Second Week

**Mastering Computer Science Technical Competencies** · Lecture 3: The Monday After the 3 AM Page

**Time:** about 2 hours · **On your own laptop** · **Self-checking:** a script tells you when each part is done.

---

## The Scenario

It's your second Monday on the Orders team. ORD-317 and ORD-361 are fixed and
released (that's where your lab branch starts). Since then, three things have
been merged: Tom simplified the report's first-order lookup (ORD-363), Mei added
a **Top customers** section (ORD-362), and the new **mobile app**'s orders are
now in the export (ORD-359).

Your inbox:

> **From:** Grace (Finance)
> **Subject:** October so far: something's off
>
> 1. **ORD-364.** The month-to-date report says **2,168 customers** ordered in
>    October. Our CRM says only **1,696** different customers ordered between 1 and
>    18 October. You can't have more customers than customers! And *Repeat
>    orders* looks low.
> 2. **ORD-365.** The report is slow again. Five seconds! You fixed this last week…
>
> — Grace

> **From:** Mei
>
> And when you've done those, **ORD-367**, please: `new_customers` is a terrible
> name (it counts *customers*), and the printing code in `cmd_report` can't be
> tested. Could you rename the fields to match what Grace sees, and move the
> printing into a function that returns the text? 🙏

This lab gives you **less step-by-step help** than the Beginner lab: goals,
tools and hints, and you decide the steps. The
[demo guides](../../demo/) and the [Beginner lab](../beginner/README.md) show
every technique used here.

---

## About This Lab

| Part | Ticket | Lecture act | You'll use | Time |
|---|---|---|---|---|
| 1 | Get the Lab Branch | 2 | Git, the self-check | 5 min |
| 2 | ORD-364: Customers Counted Twice | 5, 6 | AI (Ask mode), a launch configuration, breakpoints, Debug Console, logpoints, `pdb`, GitLens | 50 min |
| 3 | ORD-365: Slow Again | 7 | `cProfile`, pyinstrument (HTML report), Compare Selected, hyperfine | 30 min |
| 4 | ORD-367: Clearer Names, Testable Report | 4 | Rename Symbol, Extract Method, Move Symbol | 30 min |
| 5 | Finish | | The self-check, Git | 5 min |

| Icon | Meaning |
|---|---|
| ✅ | **Checkpoint** |
| ❓ | **Check your understanding** (click *Answer*) |
| 💬 | **Discuss** |
| ⚠️ | **Warning** |
| 💡 | **Tip** |

Shortcuts are written **Windows/Linux · macOS**. On most Mac laptops the
F-keys need **`Fn`** (`F5` is `Fn+F5`).

---

## Part 1: Get the Lab Branch

In your `novastack-orders` folder in VS Code, in the terminal:

```bash
git fetch upstream
```

```bash
git switch -c lab3/intermediate upstream/lab3/intermediate-start
```

- `git fetch upstream` = download the team's new branches (`upstream` is the
  team's repository; your fork is `origin`).
- `git switch -c lab3/intermediate ...` = **c**reate your own branch, starting
  from the team's lab branch.

Then run the self-check once, to see the to-do list:

```bash
uv run tools/check_lab3.py intermediate
```

✅ **Checkpoint:** the status bar shows `lab3/intermediate`, the Explorer has
**`lab3/INTERMEDIATE.md`** (your answer sheet: write each answer after the
colon), and the self-check shows several `FAIL`s.

<details><summary>Error: <code>'upstream' does not appear to be a git repository</code></summary>

```bash
git remote add upstream https://github.com/novastack-hq/novastack-orders.git
```

Then run the two commands above again.
</details>

---

## Part 2: ORD-364: Customers Counted Twice

### Goal 2.1: Reproduce it

```bash
uv run novastack report data/orders/2026-10-mtd.jsonl
```

- `data/orders/2026-10-mtd.jsonl` = October **m**onth-**t**o-**d**ate: 1 to 18
  October, one order per line (JSON Lines). Open it and scroll to line 8,001:
  what changes?

✅ **Checkpoint:** *Customers 2168*. Start **Q1**.

### Goal 2.2: Ask the AI first, and write down what it says

Before you debug, open the Chat view (`Ctrl+Alt+I` · `Ctrl+Cmd+I`), choose
**Ask** mode, and ask about the symptom in your own words. Write your question
in **A1** and its answer in **A2**. Don't act on it yet: you'll check it against
the evidence in Goal 2.5.

### Goal 2.3: A debug configuration for the report

The team's `.vscode/launch.json` has configurations for `quote` and `menu`,
but not `report`. Add one:

1. Open `.vscode/launch.json`.
2. Copy the whole **CLI: list the menu** block (from `{` to `},`) and paste it
   below itself.
3. Change the copy's `name` and `args`:

```json
"name": "CLI: October month-to-date report",
```

```json
"args": ["report", "data/orders/2026-10-mtd.jsonl"],
```

✅ **Checkpoint:** the new configuration appears in the drop-down at the top of
the **Run and Debug** view (`Ctrl+Shift+D` · `Cmd+Shift+D`).

### Goal 2.4: Pause where the counting happens, and ask questions

1. In `services/reporting.py`, set a breakpoint (`F9`) on the first line of the
   `for order in orders:` loop in `build_report`, **after** `first_order` has
   been worked out.
2. Run your new configuration (`F5`).
3. In the **Debug Console**, test your ideas, **one expression at a time**. For example:

```python
len(orders)
```

```python
len({o.customer_id for o in orders})
```

```python
len(first_order)
```

❓ **Check your understanding:** `first_order` has an entry for every customer,
and the right number of them. So why can the report still count 2,168
customers? What would have to be true for an order to be counted as a "new
customer" when it isn't the customer's first?

<details><summary>Hint</summary>

Look at the `if` in the loop: an order counts as a repeat only if it's *later*
than the customer's "first" order. What if `first_order` holds the wrong time?
Try this in the Debug Console. It lists orders that are **earlier** than their
customer's "first" order, which should be impossible:

```python
[(o.order_id, o.customer_id, o.placed_at) for o in orders if o.placed_at < first_order[o.customer_id]][:5]
```
</details>

Choose one customer from that list for **Q2**. Stop debugging (`Shift+F5`) and
remove the breakpoint.

### Goal 2.5: Watch it happen

**With a logpoint.** A logpoint prints a message without stopping the program,
and without editing the code.

1. Right-click the margin next to `report.new_customers += 1` → **Add Logpoint…**
   and type (with your own customer's ID if you like):

```text
new customer {order.customer_id} {order.order_id} at {order.placed_at}
```

2. Run your configuration again (`F5`). The Debug Console fills with 2,168 lines.
3. Type your customer's ID (for example `C1004`) into the Debug Console's
   **Filter** box (top right of the panel).

✅ **Checkpoint:** your customer is a "new customer" **at least twice**: for an
`ORD-` (till) order **and** for an earlier `APP-` (app) order.

**With a conditional breakpoint.** Now watch `first_order_times` build the wrong answer:

1. Remove the logpoint. In `first_order_times`, add a **conditional breakpoint**
   on the `first.setdefault(...)` line, with an expression such as:

```python
order.customer_id == "C1004"
```

2. Run (`F5`). Each time it pauses, look at `order.placed_at` and
   `first.get(order.customer_id)` (add them to **Watch**), then **Continue** (`F5`).

✅ **Checkpoint:** you can explain, with values you saw, why your customer's
"first" order isn't their first. Now fill in **A3**: was the AI right?

### Goal 2.6: Do it again without an IDE

At 3 AM on a server there's no VS Code. Python's built-in debugger, `pdb`, can
do the same, including the condition:

```bash
uv run python -m pdb -m novastack_orders report data/orders/2026-10-mtd.jsonl
```

- `python -m pdb` = run a program under **pdb**. It stops before the first line
  and waits at a `(Pdb)` prompt.
- `-m novastack_orders report ...` = the program and its arguments, as before.

At the `(Pdb)` prompt, type these one at a time. Use the line number of
`first.setdefault(...)` from the VS Code gutter (on the starting code it's 98):

```text
b novastack_orders/services/reporting.py:98, order.customer_id == "C1004"
```

```text
c
```

```text
p order.order_id, order.placed_at, first.get(order.customer_id)
```

| Command | Does |
|---|---|
| `b file:line, condition` | Set a **b**reakpoint that stops only when the condition is true |
| `c` | **C**ontinue to the next stop |
| `p expr` | **P**rint a value |
| `n` / `s` | **N**ext line / **s**tep into a call |
| `l` | **L**ist the code around here |
| `q` | **Q**uit |

It stops once for each of the customer's orders (C1004 has 8). Repeat `c` and
`p` until you see an order **earlier** than `first`, then `q`.
Write the commands you used in **Q4**.

### Goal 2.7: Who assumed what?

Use GitLens's inline blame on the `first.setdefault(...)` line, and on the
data file's history (**Timeline** at the bottom of the Explorer, with the data
file open). Read both commit messages. Then answer **Q3**.

### Goal 2.8: Fix it

Make `first_order_times` return each customer's **earliest** order, whatever
order the file is in. Don't sort the whole file just to do this. Fix the docstring
too: it's now wrong.

✅ **Checkpoint:** the month-to-date report shows **1,696** customers and **8,704**
repeat orders, and the September report hasn't changed. Run the self-check.

💬 **Discuss:** ORD-363 was a refactor. Was it wrong when Tom wrote it? Whose
job was it to notice that ORD-359 broke its assumption? What would have caught it?
(Lecture 4 has one answer.)

---

## Part 3: ORD-365: Slow Again

### Goal 3.1: Measure first

1. Save the September report's output so you can prove later that nothing changed:

```bash
uv run novastack report data/orders/2026-09.jsonl > before.txt
```

2. Time it (`time ...` on macOS/Linux, `Measure-Command { ... }` in PowerShell,
   or hyperfine if you have it). Note the time for **Q5**.

### Goal 3.2: Find the hot spot

Profile it with `cProfile` **and** pyinstrument (the commands are in
[Demo 4](../../demo/Lecture-3-Demo-4-Profiling.md), Steps 2 and 3). This time,
open the result as an interactive page:

```bash
uv run pyinstrument -r html -o profile.html -m novastack_orders report data/orders/2026-09.jsonl
```

- `-r html` = **r**ender the profile as a web page.
- `-o profile.html` = write it to this **o**utput file. Open it in your browser
  (in VS Code: right-click it in the Explorer → **Reveal in File Explorer/Finder**, then double-click it).

❓ **Check your understanding:** September has **2,660** customers. In
`cProfile`'s output, how many times was the hot function called? Why that many?

<details><summary>Answer</summary>

`customer_spend` is called **16,000** times, once per *order*, not once per
customer: the dictionary comprehension in `top_customers` loops over `orders`,
so a customer with ten orders has their spend worked out ten times (each one
overwrites the last). And each call scans **all 16,000 orders**: 16,000 ×
16,000 = 256 million comparisons. Double the orders and it takes four times as long.
</details>

### Goal 3.3: Fix it, and prove it

Make `top_customers` add up every customer's spend in **one pass** over the
orders. Keep its result exactly the same: the same five customers, in the same
order, ties broken by customer ID. Then:

1. Run the report again into `after.txt` and **Compare Selected** with
   `before.txt` (select both in the Explorer, right-click).
2. Time it again. Fill in **Q5** and **Q6**.

✅ **Checkpoint:** the files are identical, the report takes well under a second,
and the self-check's *ORD-365* lines pass. **Keep `before.txt`** for Part 4;
delete `after.txt` and `profile.html`.

---

## Part 4: ORD-367: Clearer Names, Testable Report

### Goal 4.1: Rename the fields

`MonthlyReport.new_customers` counts customers, and `returning_customers` counts
repeat orders. Rename them to match the report's labels:

| From | To |
|---|---|
| `new_customers` | `customers` |
| `returning_customers` | `repeat_orders` |

Use **Rename Symbol** (`F2`, then `Shift+Enter` to preview) on each field where
it's declared in `MonthlyReport`.

⚠️ **Read the preview.** Did it find the uses in `tests/unit/services/test_reporting.py`?

<details><summary>If the tests weren't in the preview</summary>

In the tests, `report` is a pytest **fixture** parameter with no type hint, so
the language server may not know it's a `MonthlyReport`, and can't be sure
`report.new_customers` is the same field. Rename can only change what it can
prove. Two fixes:

- add the type hint, `def test_customers_and_repeat_orders(report: MonthlyReport):`
  (and import `MonthlyReport`), then rename again; or
- fix the remaining uses by hand, then run the tests to prove you got them all.

This is why typed code is easier to change safely.
</details>

### Goal 4.2: Extract the printing into `render_report`

`cmd_report` in `cli.py` **prints** the report line by line, so the only way to
test the report's text is to capture the program's output. Mei wants a function
that **returns** the text instead:

```python
def render_report(report: MonthlyReport) -> str:
```

1. In `cmd_report`, select everything from `print(f"Month-end sales report: ...")`
   down to (not including) `return 0`.
2. **`Ctrl+.`** · **`Cmd+.`** → **Extract method**, named `render_report`.
3. The extracted function still *prints*. Change it to **build and return** the
   text, and make `cmd_report` do `print(render_report(report))`.
4. Move `render_report` into `services/reporting.py`, next to `MonthlyReport`:
   put the cursor on its name, **`Ctrl+.`** · **`Cmd+.`** → **Move symbol to…**
   and choose the file. (If your version doesn't offer it, cut and paste, and fix
   the imports: Pylance's quick fixes add missing ones.)

<details><summary>Hint: turning prints into a returned string</summary>

`print(a)` followed by `print(b)` outputs `a`, a newline, `b`, a newline. So
collect the pieces in a list and join them:

```python
sections = [f"Month-end sales report: {report.month}", format_table(...), "\nDiscounts given", ...]
return "\n".join(sections)
```

`print(render_report(report))` then adds the final newline.
</details>

✅ **Checkpoint:** the report's output is **exactly** the same as `before.txt`
(save a new `after.txt` and Compare Selected again: every line, every blank
line), and the self-check's *ORD-367* lines pass. Then delete both files.

---

## Part 5: Finish

```bash
uv run tools/check_lab3.py intermediate
```

✅ **Checkpoint:** `All done. Nice work. 🎉`

Then commit your work on your lab branch:

```bash
git add -A
```

```bash
git commit -m "Lecture 3 intermediate lab: ORD-364, ORD-365 and ORD-367"
```

---

## Finished Early?

1. **A test that would have caught ORD-364.** In `tests/unit/services/test_reporting.py`,
   write a test with orders **out of time order** (like the self-check's: a
   customer whose earliest order comes last in the list). Check that it fails on
   the starting code and passes on yours. To run it against the starting
   `reporting.py` only: `git restore --source upstream/lab3/intermediate-start src/novastack_orders/services/reporting.py`,
   run the test, then `git restore src/novastack_orders/services/reporting.py`
   to get yours back (after committing it in Part 5).
   (Lecture 4 is all about tests like this.)
2. **Now that `render_report` returns a string**, write a test for it: the
   first line, and the *Top customers* section, for `tests/fixtures/orders_small.jsonl`.
3. **How does it scale?** Make a bigger month and time the report before and
   after your ORD-365 fix:

```bash
uv run tools/make_sample_orders.py 2026-11 32000 > november.jsonl
```

   ⚠️ **Windows PowerShell 5** writes `>` files as UTF-16, which the report
   can't read. Run it through `cmd` instead:
   `cmd /c "uv run tools/make_sample_orders.py 2026-11 32000 > november.jsonl"`

   Twice the orders: how much longer does each version take, and why?
4. Ready for more? Try the [Advanced lab](../advanced/README.md).
