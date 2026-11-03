# Lecture 3 · Demo 4: Why Is the Month-End Report So Slow?

**Mastering Computer Science Technical Competencies** · Lecture 3: The Monday After the 3 AM Page

---

## The Scenario

ORD-317 is fixed on your laptop ([Demo 3](Lecture-3-Demo-3-Debugging.md)). On Wednesday morning:

> **From:** Grace Adeyemi (Finance)
> **Subject:** month-end report 😩
>
> The month-end sales report used to take a couple of seconds. Now it takes
> ages, and I need September's numbers for the board on Friday. Help?
>
> I run: `uv run novastack report data/orders/2026-09.jsonl`

Your instinct is to open the code and start "optimising". Jordan stops you:

> **Jordan:** Measure first. Programmers are terrible at guessing where the time goes.

---

## About This Demo

**Time:** about 7 minutes.

| Step | Title | You'll use |
|---|---|---|
| 1 | Is It Computing or Waiting? | `time` (or `Measure-Command`), a resource monitor |
| 2 | Where Does the Time Go? | `cProfile` (built into Python) |
| 3 | See It as a Picture | pyinstrument, flame graphs |
| 4 | Fix the Biggest Hot Spot | The fix; GitLens for context |
| 5 | Measure Again: the Next Hot Spot | Re-profiling |
| 6 | Prove It Fairly | `hyperfine`; checking the output didn't change |

| Icon | Meaning |
|---|---|
| ✅ | **Checkpoint** |
| ❓ | **Check your understanding** (click *Answer*) |
| 💬 | **Discuss** |
| ⚠️ | **Warning** |
| 💡 | **Tip** |

⚠️ Timings depend on your laptop. Yours will differ from the numbers here; the
*proportions* won't.

---

## Step 1: Is It Computing or Waiting?

macOS / Linux:

```bash
time uv run novastack report data/orders/2026-09.jsonl
```

Windows (PowerShell):

```powershell
Measure-Command { uv run novastack report data/orders/2026-09.jsonl }
```

- `time` (macOS/Linux) = run the command after it, then report how long it took.
  `Measure-Command { … }` is PowerShell's version (it reports the total time only).
- `novastack report` = Finance's month-end report (`src/novastack_orders/services/reporting.py`,
  ticket [ORD-361](https://github.com/novastack-hq/novastack-orders/issues/7)).
- `data/orders/2026-09.jsonl` = every order the tills recorded in September:
  16,000 lines, one order per line in **JSON Lines** format. Open it: each line
  is one order with its customer, time, items, discounts and total.

✅ **Checkpoint:** the report (16,000 orders, 2,660 customers, 13,340 repeat
orders) and timings like:

```text
4.54s user 1.00s system 93% cpu 5.906 total
```

| Number | Means |
|---|---|
| **real / total** | Wall-clock time: what Grace waits for |
| **user** | CPU time spent running *our* code |
| **sys** | CPU time spent in the operating system *for* us (files, network) |

💬 **Discuss:** user + sys ≈ real, so the program is busy **computing**, not
waiting for a disk or network. And a whole second of `sys` is a lot for a
program that reads one file. (Remember that clue.)

💡 Open **Activity Monitor** (macOS), **Task Manager** (Windows) or `htop`
(Linux) while it runs: one CPU core at 100%. A single-threaded program that's
busy computing.

---

## Step 2: Where Does the Time Go?

`cProfile` is Python's built-in profiler. It records **every function call**.

macOS / Linux:

```bash
uv run python -m cProfile -s cumtime -m novastack_orders report data/orders/2026-09.jsonl | head -50
```

Windows (PowerShell):

```powershell
uv run python -m cProfile -s cumtime -m novastack_orders report data/orders/2026-09.jsonl | Select-Object -First 50
```

- `python -m cProfile` = run Python's built-in profiler, which wraps the program that follows.
- `-s cumtime` = **s**ort the results by *cumulative* time (most expensive first).
- `-m novastack_orders report …` = the program to profile: the same report as
  `uv run novastack report …`, started as a Python module so the profiler can wrap it.
- `| head -50` / `| Select-Object -First 50` = keep only the first 50 lines of output (the report itself, then the profile).

✅ **Checkpoint:** below the report, the most expensive functions:

```text
   ncalls  tottime  percall  cumtime  percall filename:lineno(function)
        1    0.122    0.122   12.287   12.287 reporting.py:97(build_report)
    16000    0.012    0.000    7.295    0.000 reporting.py:89(is_returning_customer)
    16004    3.290    0.000    7.281    0.000 {built-in method builtins.any}
    38824    0.071    0.000    4.696    0.000 reporting.py:83(category_of)
 70820463    3.994    0.000    3.994    0.000 reporting.py:91(<genexpr>)
    38824    1.106    0.000    2.867    0.000 menu.py:70(from_records)
```

| Column | Means |
|---|---|
| `ncalls` | How many times it was called |
| `tottime` | Time in the function **itself** |
| `cumtime` | Time in the function **and everything it called** |

❓ **Check your understanding:** what's alarming about `<genexpr>` in `is_returning_customer`?

<details><summary>Answer</summary>

It ran **70.8 million** times for 16,000 orders. For each order,
`is_returning_customer` scans the *whole month* of orders looking for an
earlier one by the same customer: work that grows with the **square** of the
number of orders. Twice the orders, four times the work.
</details>

💡 The whole run took about 12 s under cProfile instead of about 6 s.
Recording every call slows the program down. That's why the next tool
*samples* instead.

---

## Step 3: See It as a Picture

**pyinstrument** is a *sampling* profiler: it checks what the program is doing
about a thousand times a second, so it's cheaper, and it shows a tree.

```bash
uv run pyinstrument -m novastack_orders report data/orders/2026-09.jsonl
```

- `pyinstrument` = a *sampling* profiler (installed by the set-up script as one of the team's dev tools).
- `-m novastack_orders report …` = the program to profile, as with cProfile.
- The output is a **tree**: each line is a function, with the time spent in it
  and in everything it called, indented under its caller.

✅ **Checkpoint:** the tree points straight at two hot spots:

```text
build_report  novastack_orders/services/reporting.py
├─ is_returning_customer  ...  (about two-thirds of the time)
│  └─ <genexpr>
└─ category_of  ...  (about one-third)
   ├─ Menu.from_records
   ├─ PosixPath.read_text
   └─ loads  json
```

For an interactive version you can click through in the browser:

```bash
uv run pyinstrument -r html -o profile.html -m novastack_orders report data/orders/2026-09.jsonl
```

- `-r html` = **r**ender the result as an interactive web page.
- `-o profile.html` = write it to this **o**utput file.

Then open `profile.html` in your browser.

**Flame graphs.** Save a profile in Speedscope format and drop the file onto
[speedscope.app](https://www.speedscope.app/), which runs in your browser:

```bash
uv run pyinstrument -r speedscope -o profile.speedscope.json -m novastack_orders report data/orders/2026-09.jsonl
```

- `-r speedscope` = save the profile in Speedscope's format instead of printing it.

In a flame graph, **width is time**: the widest bars are where the time goes,
and bars stacked on top are the functions they called.

---

## Step 4: Fix the Biggest Hot Spot

### Goal 4.1: Context before code

Open `services/reporting.py` and look at `is_returning_customer` with
**GitLens**: *Mei Lin, 29 September: "feat(reports): new customers and repeat
orders (ORD-355)"*. That's after Grace's report last "took a couple of seconds".

```python
def is_returning_customer(order: OrderRecord, orders: list[OrderRecord]) -> bool:
    """True if the customer had already ordered earlier in the month (ORD-355)."""
    return any(
        other.customer_id == order.customer_id and other.placed_at < order.placed_at
        for other in orders
    )
```

💬 **Discuss:** the code is correct and easy to read. Why is it a problem? (It's
fine for 50 orders in a test, and quadratic for 16,000 in production.)

### Goal 4.2: Work out each customer's first order once

Replace `is_returning_customer` with a function that walks the orders **once**:

```python
def first_order_times(orders: list[OrderRecord]) -> dict[str, datetime]:
    """When each customer first ordered this month, in one pass (ORD-355)."""
    first: dict[str, datetime] = {}
    for order in orders:
        if order.customer_id not in first or order.placed_at < first[order.customer_id]:
            first[order.customer_id] = order.placed_at
    return first
```

and in `build_report`:

```python
    report = MonthlyReport(month=month)
    first_order = first_order_times(orders)
    for order in orders:
        ...
        if order.placed_at > first_order[order.customer_id]:
            report.returning_customers += 1
        else:
            report.new_customers += 1
```

Then run Step 1's `time` command again.

✅ **Checkpoint:** about **3.5 s** instead of about 6 s, with the same numbers in the report.

---

## Step 5: Measure Again: the Next Hot Spot

Run pyinstrument again (Step 3).

✅ **Checkpoint:** the tree now has one big branch: `category_of`, with
`Menu.from_records`, `read_text` and `json.loads` underneath.

```python
def category_of(sku: str, menu_path: Path) -> Category:
    """The menu category a SKU belongs to."""
    menu = Menu.from_records(json.loads(menu_path.read_text(encoding="utf-8")))
    return menu.get(sku).category
```

💬 **Discuss:** what does this do for each of the 38,824 order lines? (Opens the
menu file, parses the JSON and builds a whole `Menu`, to look up one category.
That's Step 1's mysterious second of `sys` time: tens of thousands of file reads.)

**Fix:** read the menu **once** and keep a dictionary:

```python
def load_categories(menu_path: Path) -> dict[str, Category]:
    """Every SKU's menu category, read from the menu file once."""
    menu = Menu.from_records(json.loads(menu_path.read_text(encoding="utf-8")))
    return {item.sku: item.category for item in menu}
```

In `build_report`, call `categories = load_categories(menu_path)` before the loop
and use `categories[line.sku]` instead of `category_of(line.sku, menu_path)`.

✅ **Checkpoint:** `time` now reports about **0.5 s**.

| Version | Time (one laptop) |
|---|---|
| Grace's report | about 6 s |
| After fixing the biggest hot spot | about 3.5 s |
| After re-profiling and fixing the next one | about 0.5 s |

---

## Step 6: Prove It Fairly

One timing can be a fluke: other programs, caches, a busy laptop. **hyperfine**
runs a command several times, warms up first, and reports the spread.

```bash
hyperfine --warmup 1 --runs 5 'uv run novastack report data/orders/2026-09.jsonl'
```

- `hyperfine` = a benchmarking tool (optional install: [Demo 0, Goal 1.3](Lecture-3-Demo-0-Setup.md#goal-13-optional-install-hyperfine)).
- `--warmup 1` = run once first without timing it, so caches are warm.
- `--runs 5` = then time five runs and report the mean ± standard deviation.
- `'…'` = the command to benchmark, in quotes.

Run it **before** and **after** your fixes (`git stash` / `git stash pop` lets you
switch between the two), and compare the *mean ± standard deviation*.

💡 No hyperfine? Run the `time` command five times and compare the middle values.

⚠️ **Faster but wrong is worse than slow.** Check the report's numbers didn't
change:

```bash
uv run novastack report data/orders/2026-09.jsonl > after.txt
git stash
uv run novastack report data/orders/2026-09.jsonl > before.txt
git stash pop
```

- `> after.txt` = save the report's output to a file instead of printing it.
- `git stash` = put your uncommitted changes aside, so the files are back to the
  last commit: the **slow** version.
- `git stash pop` = bring your changes (the fixes) back.

Then compare `before.txt` and `after.txt` (in VS Code: select both in the
Explorer → right-click → **Compare Selected**).

✅ **Checkpoint:** the two reports are identical.

> **Grace:** 0.5 seconds?! I'll take it. 🎉

---

## Beyond Python: the Wider Toolbox

Python profilers see Python functions. When the problem is lower down (the
operating system, memory, the network), professionals reach for:

| Tool | Answers |
|---|---|
| `htop`, `btop`, Activity Monitor, Task Manager | What's using the CPU, memory and disk right now? |
| `py-spy` | Profile an **already running** Python program (needs admin rights on macOS/Linux) |
| `tracemalloc` (built in), `memory-profiler` | Where is memory being allocated? |
| `perf`, flame graphs | Where does a native (C, C++, Rust) program spend its time? |
| `strace`, `bpftrace`, `tcpdump` | What is a program asking the operating system, or sending over the network? |

---

## Try It Yourself (lab practice)

1. Profile `uv run novastack quote data/samples/team_order.json --at 2026-10-07T12:30`.
   Is there anything worth optimising? (Measure first!)
2. Use `tracemalloc` to find which function allocates the most memory while the
   report runs.
3. Generate a bigger month (`uv run tools/make_sample_orders.py 2026-10 32000 > october.jsonl`).
   Time the slow and fast versions on both months. What happens to each when the data doubles?

<details><summary>What to look for</summary>

1. It finishes in a fraction of a second, and most of that is Python starting
   up. Not worth optimising: that's the point of measuring first.
2. Start with `tracemalloc.start()`, then `tracemalloc.take_snapshot().statistics("lineno")[:10]`
   after building the report.
3. The fast version takes **under twice** as long (linear: twice the data,
   twice the work, plus a fixed start-up time that doesn't grow). The slow version takes nearly **three times** as long,
   because its returning-customer part grows about **fourfold** (quadratic)
   while the menu-reading part only doubles.
</details>
