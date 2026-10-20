# Lecture 3 · Advanced Lab: The Auditors Are Coming

**Mastering Computer Science Technical Competencies** · Lecture 3: The Monday After the 3 AM Page

**Time:** about 2 hours · **On your own laptop** (Part 5 needs Docker) · **Self-checking:** a script tells you when each part is done.

---

## The Scenario

ORD-317 and ORD-361 are fixed and released (that's where your lab branch
starts). Then three messages arrive on the same morning:

> **From:** Grace (Finance)
> **Subject:** Auditors 😬
>
> **ORD-368.** The auditors want **March 2026** re-run with today's code. Tom
> restored the March export from the archive (ORD-366), and the report **crashes**.
>
> **ORD-369.** They also want a **year-to-date** report next month: a dozen
> months in one go. The finance laptop has 8 GB of memory, and last time someone
> tried something like this it ground to a halt. Can the report cope?
>
> — Grace

> **From:** Jordan
>
> **ORD-370.** While you're in the debugger: the team's `launch.json` only has
> two CLI configurations. Add the ones you find yourself needing, so the next person
> doesn't have to work them out again. And when you're done, make sure it all
> works in the **Dev Container**: that's what the auditors' machine will use.

This lab gives you **goals, tools and hints, not steps**. The
[demo guides](../../demo/) cover every basic technique; this lab goes past them.

---

## About This Lab

| Part | Ticket | You'll use | Time |
|---|---|---|---|
| 1 | Get the Lab Branch | Git, the self-check | 5 min |
| 2 | ORD-370: Debug Configurations | `launch.json`: arguments, environment variables, `justMyCode`, attach | 20 min |
| 3 | ORD-368: The March Crash | Exception breakpoints, Call Stack, conditional breakpoints, time zones | 35 min |
| 4 | ORD-369: A Year in 8 GB | `tracemalloc`, generators, a second worktree, hyperfine | 40 min |
| 5 | The Dev Container | Docker, Dev Containers, the same checks in a clean Linux | 20 min |

| Icon | Meaning |
|---|---|
| ✅ | **Checkpoint** |
| ❓ | **Check your understanding** (click *Answer*) |
| 💬 | **Discuss** |
| ⚠️ | **Warning** |
| 💡 | **Tip** |

Shortcuts are written **Windows/Linux · macOS**. On most Mac laptops the
F-keys need **`Fn`**.

---

## Part 1: Get the Lab Branch

```bash
git fetch upstream
```

```bash
git switch -c lab3/advanced upstream/lab3/advanced-start
```

```bash
uv sync
```

- `git fetch upstream` = download the team's new branches (`upstream` is the
  team's repository, added by the set-up script).
- `git switch -c lab3/advanced ...` = create your own branch from the team's lab branch.
- `uv sync` = update `.venv` to match the branch's `uv.lock`. Tom added a
  dependency on this branch (`git log -2` shows which, and why).

```bash
uv run tools/check_lab3.py advanced
```

✅ **Checkpoint:** `lab3/ADVANCED.md` is in the Explorer (your answer sheet:
write each answer after the colon), and the self-check lists what to do.

<details><summary>Error: <code>'upstream' does not appear to be a git repository</code></summary>

```bash
git remote add upstream https://github.com/novastack-hq/novastack-orders.git
```
</details>

---

## Part 2: ORD-370: Debug Configurations

*`.vscode/launch.json` is shared with the team through Git, so a good
configuration helps everyone. It's JSON with comments; VS Code helps you write
it: type `"` inside a configuration to see every property, with its documentation.*

### Goal 2.1: Run the March report under the debugger, with debug logs

Add a configuration that runs:

```bash
uv run novastack report data/orders/2026-03.jsonl
```

…but with the environment variable `NOVASTACK_LOG_LEVEL` set to `DEBUG`
**for that run only**, and with `"justMyCode": false`, so you can step into
library code (for example the standard library's `json`).

<details><summary>Hint: the properties you need</summary>

Copy the **CLI: list the menu** configuration and change `name` and `args`.
Then add `"env": { ... }` (an object of variable names and values) and
`"justMyCode": false`. Hover any property for its documentation.
</details>

### Goal 2.2: Attach to a program that's already running

On a server you can't press `F5`: the program is already running, started by
something else. The Python debugger can **attach** to it, if the program
was started with debugpy listening on a port.

1. Add an **attach** configuration that connects to `localhost`, port `5678`.
   (In `launch.json`, click **Add Configuration…** at the bottom right →
   **Python Debugger** → **Remote Attach**, or write it yourself.)
2. In a terminal, start the report with debugpy listening and waiting:

```bash
uv run --with debugpy python -m debugpy --listen 5678 --wait-for-client -m novastack_orders report data/orders/2026-09.jsonl
```

- `uv run --with debugpy` = run in the project's environment **plus** debugpy,
  just for this command (uv downloads it the first time; nothing is added to the project).
- `python -m debugpy --listen 5678` = start the Python debugger's server on port 5678.
- `--wait-for-client` = don't start the program until a debugger attaches.
- `-m novastack_orders report ...` = the program to run, as usual.

3. Set a breakpoint in `build_report`, choose your attach configuration in
   **Run and Debug**, and press `F5`.

✅ **Checkpoint:** the program in the terminal starts, and VS Code pauses at
your breakpoint. Press `Shift+F5` to **disconnect**: the program carries on
without you.

💡 A warning about *frozen modules* is harmless here.

⚠️ `--listen 5678` only listens on your own machine (`localhost`). Never make a
debugger listen on a public network address: anyone who connects can run any
code they like inside your program.

---

## Part 3: ORD-368: The March Crash

### Goal 3.1: Reproduce it, and stop where it breaks

Run your March configuration (`F5`). It stops on an exception, because VS Code's
**Uncaught Exceptions** breakpoint is on by default (see the **Breakpoints**
section of the Run and Debug view).

Look at the exception, the **Variables** and the **Call Stack**. Fill in **Q1**.

❓ **Check your understanding:** the exception is raised where two times are
**compared**. Is that where the bug is?

<details><summary>Answer</summary>

Probably not: that's where it's *noticed*. Click down the **Call Stack** and ask
where each of the two values came from. One of them is different from the other
in a way that has nothing to do with comparing: follow it back to where it was
created (`load_orders` → `parse_timestamp`).
</details>

### Goal 3.2: Raised vs. Uncaught

In the **Breakpoints** section, also tick **Raised Exceptions**, and run again.

Answer **Q3**: which one stopped first, and why does the other behave
differently? Untick **Raised Exceptions** afterwards. (With `justMyCode: false`
it may also stop inside the standard library on exceptions that are raised and
handled on purpose. That's normal; press Continue.)

### Goal 3.3: Find the first order that's different

The March file has 12,000 orders. Use a **conditional breakpoint** in
`load_orders` with a condition on the raw timestamp `raw["at"]`, to stop at the
**first** order whose time is written differently. Fill in **Q2**.

<details><summary>Hint: what to look for</summary>

Open `data/orders/2026-03.jsonl` and compare a line from early March with one
from the last few days. (`Ctrl+G` · `Ctrl+G` goes to a line number.) An
expression such as `raw["at"].endswith("Z")` makes a good condition.
</details>

### Goal 3.4: Fix it, in the right place

> **Tom:** Ah. On 29 March, the night the clocks went forward, the till got
> firmware 4.2, which writes times in **UTC** (`Z` means UTC). Everything else at
> NovaStack (receipts, opening hours, the student-discount days) uses **UK
> local time**.

**Acceptance criteria** (the self-check tests these):

- `parse_timestamp` **always** returns UK local time, as a datetime **without** a time zone.
- Times without a time zone are already UK local time: unchanged.
- A time in UTC, or with any offset, is converted to UK local time. For example,
  `2026-03-30T11:30:00Z` is **12:30** UK time (British Summer Time, UTC+1), and
  `2026-01-15T12:30:00Z` is **12:30** (GMT, UTC+0).

Use the standard library's `zoneinfo.ZoneInfo("Europe/London")` and
`datetime.astimezone`. (That's why Tom added `tzdata`: Windows has no time zone
database of its own.)

⚠️ Simply removing the time zone (`.replace(tzinfo=None)`) makes the crash go
away, but every UTC time in summer would be an hour wrong. A fix that stops the
crash isn't necessarily correct. That's why the acceptance criteria include a summer example.

✅ **Checkpoint:** the March report runs, and the self-check's *ORD-368* lines pass.

💬 **Discuss:** the night the clocks go **back** (25 October 2026), 01:30 happens
twice. What does that mean for a till that records local times without a time
zone? What would you recommend to Tom?

---

## Part 4: ORD-369: A Year in 8 GB

### Goal 4.1: Measure the memory

`load_orders` reads the **whole** file into a list before the report starts. Save
this as **`tools/peak_memory.py`** (File → New File):

```python
"""Peak memory of the month-end report (ORD-369).

Usage: uv run tools/peak_memory.py data/orders/2026-09.jsonl
"""

import sys
import tracemalloc
from pathlib import Path

from novastack_orders.config import load_settings
from novastack_orders.services.reporting import build_report, load_orders

path = Path(sys.argv[1])
menu = load_settings(env="").menu_path

tracemalloc.start()
orders = load_orders(path)
snapshot = tracemalloc.take_snapshot()  # what's in memory once the orders are loaded
report = build_report(path.stem, orders, menu)
current, peak = tracemalloc.get_traced_memory()

print(f"{report.order_count} orders: peak {peak / 1_000_000:.1f} MB")
print("Biggest allocations after loading:")
for stat in snapshot.statistics("lineno")[:5]:
    print("   ", stat)
```

- `tracemalloc` = Python's built-in memory tracer: it records where every
  allocation was made. `get_traced_memory()` returns the current and **peak** totals.
- `snapshot.statistics("lineno")` = memory grouped by the line that allocated it.

```bash
uv run tools/peak_memory.py data/orders/2026-09.jsonl
```

Fill in **Q4**. Then make a month four times as big and measure again:

```bash
uv run tools/make_sample_orders.py 2026-11 64000 > big.jsonl
```

⚠️ **Windows PowerShell 5** writes `>` files as UTF-16, which the report can't
read. Run it through `cmd` instead:

```powershell
cmd /c "uv run tools/make_sample_orders.py 2026-11 64000 > big.jsonl"
```

Then measure `big.jsonl` the same way.

❓ **Check your understanding:** which line allocates the most, and why so much
for a few decimal numbers? How would the peak grow for a year of orders?

<details><summary>Answer</summary>

`money.py` (creating `Money` objects): every line total, discount and order total
is a separate Python object, with a `Decimal` inside it, each with its own
overhead. That's tens of bytes for a number that's 4 bytes in the file. The
peak grows **in proportion to the number of orders**: about four times bigger
for four times the orders, so a year is about twelve times September.
</details>

### Goal 4.2: Stream the orders

Change the report so it **never holds more than one order at a time**:

1. Add `iter_orders(path)` to `services/reporting.py`: a **generator** that
   `yield`s one `OrderRecord` per line. Keep `load_orders` (other code and the
   tests use it), but make it `return list(iter_orders(path))`.
2. Make `build_report` work in **one pass**, over any iterable of orders, so the
   CLI can give it `iter_orders(path)`. An iterator can only be read once, so
   `first_order_times(orders)` followed by a second loop won't work.
3. Make `cmd_report` use `iter_orders`.

❓ **Check your understanding:** without first finding each customer's earliest
order, how can one pass over an unsorted file get the **customer** and **repeat
order** totals right? (This is **Q6**.)

<details><summary>Hint</summary>

The report only needs the **totals**, not which order was which. Every customer
has exactly one first order. So how many orders are "a customer's first", and how
many are repeats, whatever order the file is in?
</details>

Change `tools/peak_memory.py` to use `iter_orders` (and drop the snapshot,
which no longer means much), and measure again. Fill in **Q5**.

✅ **Checkpoint:** the self-check's *ORD-369* lines pass: the same numbers, with
a peak under 8 MB.

### Goal 4.3: Did it get slower? Compare fairly

Streaming saves memory, but is it slower? To compare the old and new code side
by side, check out the old code in a **second worktree**: a second folder
using the same repository.

```bash
git worktree add ../novastack-before upstream/lab3/advanced-start
```

- `git worktree add ../novastack-before ...` = create the folder `novastack-before`
  next to your project, with the branch's code in it. No second clone needed.

Then time both with hyperfine (install it from [Demo 0](../../demo/Lecture-3-Demo-0-Setup.md) if you haven't):

```bash
hyperfine --warmup 1 "uv run --directory ../novastack-before novastack report data/orders/2026-09.jsonl" "uv run novastack report data/orders/2026-09.jsonl"
```

- `hyperfine "A" "B"` = run each command several times and compare their averages.
- `--warmup 1` = run each once first, untimed (so file caches are warm for both).
- `uv run --directory ../novastack-before ...` = run the command in the other
  folder, with its own `.venv` (uv creates it the first time).

Fill in **Q7**. Then remove the second worktree:

```bash
git worktree remove ../novastack-before
```

…and delete `big.jsonl` (right-click it in the Explorer → **Delete**): it
doesn't belong in the repo.

💬 **Discuss:** you traded a list for a generator. What can the report no longer
do with a single pass? (For example: could it now list each customer's
*first* order, or sort by anything?)

---

## Part 5: The Dev Container

*The auditors' machine will use the team's **Dev Container**: the same Linux,
Python and tools for everyone, defined in `.devcontainer/devcontainer.json`.*

**You need Docker:** [Docker Desktop](https://www.docker.com/products/docker-desktop/)
on Windows or macOS (free for education), or Docker Engine on Linux, and the
**Dev Containers** extension (it's in the team's recommendations). The first
start downloads about 1 GB, so use a good connection.

1. Commit your work first (see *Finish*, below), so nothing is lost.
2. `Ctrl+Shift+P` · `Cmd+Shift+P` → **Dev Containers: Reopen in Container**.
   Wait for the set-up to finish (the first time takes a few minutes).
3. In the container's terminal (it shows a Linux prompt), run:

```bash
uv run tools/check_lab3.py advanced
```

✅ **Checkpoint:** the *Dev Container* line now passes instead of `SKIP`.

4. Time the September report inside the container, and compare with your
   laptop. Fill in **Q8**.

<details><summary>Things that can be different in a container</summary>

- On Windows and macOS, Docker runs Linux inside a small **virtual machine**, so
  there's a layer between the code and your hardware.
- Your project folder is **mounted** into the container from your laptop, and
  reading files across that boundary can be slower. (The team's container keeps
  `.venv` in a Docker **volume** instead, for exactly this reason.)
- The container may be given fewer CPUs or less memory (Docker Desktop →
  Settings → Resources).
</details>

To go back: `Ctrl+Shift+P` · `Cmd+Shift+P` → **Dev Containers: Reopen Folder Locally**.

---

## Finish

```bash
uv run tools/check_lab3.py advanced
```

✅ **Checkpoint:** `All done. Nice work. 🎉` (The *Dev Container* line may say `SKIP` if you run it on your laptop.)

```bash
git add -A
```

```bash
git commit -m "Lecture 3 advanced lab: ORD-368, ORD-369 and ORD-370"
```

Check `big.jsonl` is gone first (Goal 4.3): it doesn't belong in the repo.

---

## Finished Early?

1. **A test for ORD-368.** Write a test for `parse_timestamp` covering the
   acceptance criteria and the night the clocks go back. Use
   `@pytest.mark.parametrize` for the cases.
2. **Profile a running program.** [py-spy](https://github.com/benfred/py-spy) can
   show what an *already running* Python program is doing, without restarting it:
   `py-spy dump --pid <PID>`. On macOS and Linux it needs administrator rights
   (`sudo`), because it reads another program's memory. Why is that a sensible
   restriction?
3. **Where does the time go now?** Profile the streaming report with
   pyinstrument. What's at the top, and is it worth optimising? (Measure first!)
