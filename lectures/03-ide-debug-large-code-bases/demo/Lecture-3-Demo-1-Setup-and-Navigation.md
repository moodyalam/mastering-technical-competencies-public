# Lecture 3 · Demo 1: Set Up and Find Your Way Around

**Mastering Computer Science Technical Competencies** · Lecture 3: The Monday After the 3 AM Page

---

## The Scenario

It's Monday, 9:00, your first morning on NovaStack's **Orders team**. Jordan's
message says: set up the team's way, then take ticket **ORD-317**:

> **ORD-317: Loyalty customers undercharged on meal deal orders** · P2 · pricing
>
> Reported by Grace Adeyemi (Finance): *"Sam Patel (Silver card) bought a chicken
> wrap, fries, a cola and an orange juice on Wednesday 7 October and paid
> **£5.95**. By my maths it should be **£7.29**. It's happening on lots of orders
> since 14 September."*

The codebase, **NovaStack Orders**, has 45 modules, about 220 tests and five
months of history from four developers. You've never seen it before.

---

## About This Demo

| Guide | What it shows |
|---|---|
| [Demo 0](Lecture-3-Demo-0-Setup.md) | Setting up your laptop (before the lecture) |
| **Demo 1 (this one)** | Acts 1–3: development environments, the team's Python set-up and extensions, language servers |
| [Demo 2](Lecture-3-Demo-2-Refactoring-and-AI.md) | Acts 4–5: refactoring, and working with an AI assistant |
| [Demo 3](Lecture-3-Demo-3-Debugging.md) | Act 6: debugging ORD-317 |
| [Demo 4](Lecture-3-Demo-4-Profiling.md) | Act 7: profiling the month-end report |

**Time:** about 12 minutes (after 4 minutes of slides for Act 1).

| Step | Act | Title | You'll use |
|---|---|---|---|
| 1 | 1 | Three Kinds of Development Environment | (slides) |
| 2 | 2 | Open the Project the Team's Way | Workspace Trust, recommended extensions, the status bar |
| 3 | 2 | The Python Set-Up | Python: Select Interpreter, `.venv`, uv, workspace settings, Ruff on save |
| 4 | 2 | Extensions | The Extensions view, `extensions.json`, Profiles, the Dev Container |
| 5 | 3 | Where the Intelligence Comes From | Language servers, Pylance |
| 6 | 3 | Navigate by Meaning | Go to Symbol, Go to Definition, Peek, Find All References, Go to Implementations |
| 7 | 3 | Ask the History | GitLens inline blame |

| Icon | Meaning |
|---|---|
| ✅ | **Checkpoint** |
| ❓ | **Check your understanding** (click *Answer*) |
| 💬 | **Discuss** |
| ⚠️ | **Warning** |
| 💡 | **Tip** |

Shortcuts are written **Windows/Linux · macOS**.

---

## Step 1: Three Kinds of Development Environment (Act 1)

*A development environment is everything you use to write, run, check and debug code. The editor is only part of it.*

| Kind | Example | Good for |
|---|---|---|
| **Terminal-based** | tmux with Vim, a shell and a running server side by side (Jordan at 3 AM) | Remote servers over SSH; very lightweight; the only option when there's no graphical desktop |
| **Graphical IDE** | VS Code, with editing, language support, Git, debugger, terminal and AI in one window | Most day-to-day development; best AI integration |
| **Containerised or cloud** | The same VS Code, with the tools running in a Dev Container or GitHub Codespaces | Everyone gets an *identical* environment; nothing to install locally |

💡 **Vim** is a keyboard-driven editing style you'll find almost everywhere,
including VS Code (the *Vim* extension). Worth learning one day; not today.

💬 **Discuss:** Jordan fixed the 3 AM outage in a terminal. Why didn't they open
an IDE? (They were on a production server over SSH, at 3 AM. Terminal tools are
always there. On your own laptop, an IDE does far more for you.)

---

## Step 2: Open the Project the Team's Way (Act 2)

*Tom's advice: "Don't hand-craft a set-up. Open the repo and accept what VS Code offers. The team's settings are in the repo."*

### Goal 2.1: Open the folder

1. In VS Code: **File → Open Folder…** and choose your `novastack-orders` clone.

   ⚠️ **Open the project folder itself**, the one that contains `pyproject.toml`
   and `.vscode/`, not a folder above it. VS Code only reads the team's
   `.vscode/settings.json` and `.vscode/extensions.json` from the top folder you
   open. If you open a parent folder, you get no recommended extensions, none of
   the team's settings, and a lot of red squiggles. Check: the title bar and the top
   of the Explorer should say `novastack-orders`.

2. **"Do you trust the authors of the files in this folder?"** → **Yes, I trust the authors**.

💡 That's **Workspace Trust**. A project folder can contain settings and tasks
that run code. Until you trust it, VS Code opens it in *Restricted Mode*. Only
trust folders you know, like your own fork.

### Goal 2.2: Accept the team's extensions

Because you opened the **`novastack-orders` folder itself**, VS Code finds the
team's `.vscode/extensions.json` and shows two prompts (bottom-right):

| Prompt | Choose | Why |
|---|---|---|
| **"Do you want to install the recommended extensions…?"** | **Install** | Installs the team's extensions (Python, Pylance, Ruff, …) |
| **"Folder contains a Dev Container configuration file. Reopen folder to develop in a container?"** | **Not now** (close it) | We work locally first; Goal 4.2 tries the container on purpose |

💡 Opened a folder *above* `novastack-orders` by mistake? You'll get neither
prompt. **File → Open Folder…** and choose `novastack-orders` itself.

✅ **Checkpoint:** the Extensions view (`Ctrl+Shift+X` · `Cmd+Shift+X`) shows
Python, Pylance, Python Debugger, Ruff, EditorConfig, GitLens, GitHub Copilot
Chat and Dev Containers as installed.

<details><summary>Missed the prompt, or it disappeared?</summary>

Nothing installs the team's extensions until you accept them. Open the
Extensions view, type this in the search box:

```text
@recommended
```

and under
**Workspace Recommendations** click the cloud icon (**Install Workspace
Recommended Extensions**), or **Install** on each one.
</details>

---

## Step 3: The Python Set-Up (Act 2)

### Goal 3.1: Which Python?

1. Open any Python file, e.g. `src/novastack_orders/cli.py` (`Ctrl+P` · `Cmd+P`, type `cli.py`).
2. Look at the **bottom-right of the status bar**: it shows the Python
   interpreter VS Code is using.
3. Press `Ctrl+Shift+P` · `Cmd+Shift+P` → **Python: Select Interpreter**. The list
   shows every Python on the laptop. Choose the one marked **`.venv`**.

✅ **Checkpoint:** the status bar shows Python 3.12 with `.venv`.

💡 Still red squiggles under the `novastack_orders` imports? Run this in the
terminal, then `Ctrl+Shift+P` · `Cmd+Shift+P` → **Python: Restart Language Server**:

```bash
uv sync
```

❓ **Check your understanding:** what goes wrong if VS Code uses the laptop's system Python instead?

<details><summary>Answer</summary>

The project's packages (pytest, Ruff, mypy, pyinstrument, and the project
itself) are installed in `.venv`, not in the system Python. So imports such as
`import pytest` are underlined as unresolved, the Testing panel finds nothing,
and the debugger runs the wrong Python. Most "VS Code isn't working" problems
are the wrong interpreter.
</details>

### Goal 3.2: Where did `.venv` come from?

The set-up script ran **`uv sync`**: uv read `.python-version` (3.12) and
`uv.lock` (the exact version of every package) and built `.venv`. Everyone on
the team has the same versions.

| File | What it's for |
|---|---|
| `pyproject.toml` | The project: name, Python version, dependencies, and settings for Ruff, pytest and mypy |
| `uv.lock` | The exact version of every package, for every OS (generated: never edit by hand) |
| `.python-version` | The Python version uv installs |
| `.vscode/settings.json` | The team's VS Code settings for this project |
| `.vscode/extensions.json` | The extensions VS Code offers to install |

⚠️ A virtual environment remembers its exact location on disk. If you **move or
rename the project folder**, `.venv` breaks: delete the `.venv` folder and run
`uv sync` again (the command above).

### Goal 3.3: User settings versus team settings

1. Open **Settings** (`Ctrl+,` · `Cmd+,`) and switch between the **User** and **Workspace** tabs.
2. Open `.vscode/settings.json` and read the comments.

| User settings | Workspace settings (`.vscode/settings.json`) |
|---|---|
| Yours, on every project: theme, font size, keybindings | The team's, for this project only; committed to Git |
| "I like 16-point text" | "Ruff formats Python on save; lines are 88 characters; pytest is the test runner" |

3. In `cli.py`, mess up some spacing on a new line inside a function, for example:

   ```python
   x=1+2
   ```

   and **save**.

✅ **Checkpoint:** Ruff fixes the spacing as you save. Undo your change
(`Ctrl+Z` · `Cmd+Z`) and save again.

💬 **Discuss:** why does a team put formatting rules in the repository instead
of arguing about them in code review?

---

## Step 4: Extensions (Act 2)

*Almost everything VS Code knows about Python comes from extensions.*

### Goal 4.1: Look at what's installed, and why

1. Open the Extensions view and type `@recommended` in the search box (as in
   Goal 2.2): the team's list.
2. Click **Pylance**. Note the **publisher** (Microsoft, with a verified badge)
   and the install count.

| Extension | What it does for you |
|---|---|
| Python + **Pylance** | Running Python, IntelliSense, navigation, type checking (Step 5) |
| **Python Debugger** | Breakpoints and stepping (Demo 3) |
| **Ruff** | Formatting and linting on save |
| **GitLens** | Who changed each line, and why (Step 7) |
| **GitHub Copilot Chat** | AI assistance (Demo 2) |
| **Dev Containers** | Run everything inside a container (Goal 4.2) |
| Also useful | **Remote - SSH** (edit code on a server), **Live Share** (edit together in real time), **Error Lens** (errors shown inline) |

⚠️ Extensions run with **your** permissions: they can read your files and run
programs. Install from publishers you can verify, and be wary of look-alike
names.

💡 **Profiles** (`Ctrl+Shift+P` · `Cmd+Shift+P` → *Profiles: Create Profile*) keep
separate sets of extensions and settings, e.g. a "Course" profile and your
personal one.

### Goal 4.2: The same project in a container

You need **Docker Desktop running** and the **Dev Containers** extension (it's in
the team's recommended list: Goal 2.2). Without the extension, the command
below doesn't exist.

1. `Ctrl+Shift+P` · `Cmd+Shift+P` → **Dev Containers: Reopen in Container**.
2. The status bar now says **Dev Container: NovaStack Orders**; the terminal is Linux.
3. **Dev Containers: Reopen Folder Locally** to go back.

💡 The first time, this downloads Microsoft's Python image (a few hundred MB).
The configuration is `.devcontainer/devcontainer.json`: same tools, same
versions, for everyone.

---

## Step 5: Where the Intelligence Comes From (Act 3)

*How does VS Code know what `PriceCalculator` is, which methods it has, or that you passed the wrong type? It asks a **language server**.*

| Without a protocol | With the Language Server Protocol (LSP) |
|---|---|
| Every editor writes its own support for every language: M editors × N languages | Each editor speaks LSP once, each language has one server: M + N |

For Python, the language server is **Pylance**. It powers completion, hover
documentation, navigation, rename, and errors as you type.

### Goal 5.1: See it work

1. In `cli.py`, on a new line inside any function, type the following and look at the completion list:

   ```python
   Money.
   ```
2. Hover over `PriceCalculator` anywhere: its docstring appears.
3. On a new line inside a function, type:

   ```python
   Money.of(1.5)
   ```

✅ **Checkpoint:** a red squiggle. Hover: a `float` isn't accepted
(`str | int | Decimal`). The team never uses floats for money (see
`docs/adr/0002-money-as-decimal.md`). Delete the line.

💡 How strict the type checking is comes from `python.analysis.typeCheckingMode`
in the team settings:

| Mode | Reports | Suits |
|---|---|---|
| `off` | Syntax errors and unresolved imports only | Quick scripts |
| `basic` | Plus clear type errors | Untyped or legacy code |
| **`standard`** | Plus most real type mistakes, without nagging about missing annotations | **Most teams (NovaStack uses this)** |
| `strict` | Everything, including any value it can't fully type | Fully typed libraries; overwhelming elsewhere |

If Pylance asked you to choose a mode when it first started, the team's
`standard` overrides your choice in this project. The money-critical
`pricing/` code is also checked strictly by **mypy** (`uv run mypy`).

---

## Step 6: Navigate by Meaning (Act 3)

*Don't scroll and don't search text. Ask the language server.*

| Move | Windows/Linux | macOS | Or right-click → |
|---|---|---|---|
| Go to Symbol in Workspace | `Ctrl+T` | `Cmd+T` | (Command Palette: *Go to Symbol in Workspace*) |
| Go to Definition | `F12` | `F12` (`Fn+F12` on most Mac laptops) | **Go to Definition** |
| Peek Definition | `Alt+F12` | `Opt+F12` (`Fn+Opt+F12`) | **Peek → Peek Definition** |
| Find All References | `Shift+F12` | `Shift+F12` (`Fn+Shift+F12`) | **Find All References** |
| Go to Implementations | `Ctrl+F12` | `Cmd+F12` (`Fn+Cmd+F12`) | **Go to Implementations** |
| Go back | `Alt+←` | `Ctrl+-` | |

💡 **Why `Fn` on a Mac?** On Mac laptops the top row of keys controls
brightness and volume by default, so `F12` turns the volume up. Hold `Fn` to
get the real F-key, or switch the default in **System Settings → Keyboard →
Keyboard Shortcuts… → Function Keys → "Use F1, F2, etc. keys as standard
function keys"**. The right-click menu always works.

### Goal 6.1: Reproduce the ticket first

*Never fix a bug you haven't seen. Reproduce it with the exact data from the ticket:
[ORD-317 on the team's board](https://github.com/novastack-hq/novastack-orders/issues/1).*

In the terminal (`` Ctrl+` ``):

```bash
uv run novastack quote data/samples/meal_deal_plus_drink.json --at 2026-10-07T12:30
```

- `uv run` = run a command inside the project's `.venv`, with the team's exact package versions.
- `novastack` = the team's command-line app (`src/novastack_orders/cli.py`).
- `quote` = price a basket **without** taking payment (`checkout` would also charge a card).
- `data/samples/meal_deal_plus_drink.json` = Sam's basket from the ticket: a chicken wrap,
  fries, a cola and an orange juice, for customer `C002`, Sam Patel (Silver card). Open the
  file to see it; the customers are in `data/customers.json`.
- `--at 2026-10-07T12:30` = pretend it's Wednesday 7 October, 12:30, when Sam ordered. Some
  discounts depend on the day, so a bug report needs the time as well as the basket.

✅ **Checkpoint:** the same wrong total Grace reported:

```text
Quote for Sam Patel (silver) at Wed 07 Oct 12:30
Subtotal                         £10.70
Loyalty card discount            -£0.52
Loyalty card discount            -£0.68
Loyalty card discount            -£0.95
Meal deal (main + side + drink)  -£2.60
TOTAL                             £5.95
```

💬 **Discuss:** what's odd? (The **loyalty** discount appears **three** times. A
Silver card is 10% off, once.)

💡 `uv run novastack --help` lists every command; `uv run novastack quote --help`
explains the options.

### Goal 6.2: Find where a basket is priced

*Where would you start? Not by opening files at random. The team's
`docs/architecture.md` says pricing happens in `PriceCalculator.calculate`, and
lists its steps: subtotal → promotions → loyalty **once** → student → round.*

1. `Ctrl+T` · `Cmd+T` → type `calculate` → choose **`PriceCalculator.calculate`**
   (in `src/novastack_orders/pricing/calculator.py`).
2. Look at the **breadcrumbs** above the editor (`src › novastack_orders › pricing ›
   calculator.py › PriceCalculator › calculate`) and the **Outline** view in the
   Explorer: they tell you where you are.
3. Read `calculate` from the top. Each discount is applied by the same helper,
   `self._apply(...)`. Put the cursor on **`_apply`** and press **Find All References**.

✅ **Checkpoint:** the References panel lists the `def _apply` line and three
calls: one for **promotions** (the meal deal), one for the **student** discount,
and one for **loyalty**, which sits **inside** a loop:

```python
for category, lines in basket.by_category().items():
    ...
    if self._loyalty.applies(ctx):
        running = self._apply(self._loyalty, ctx, running, applied)
```

### Goal 6.3: What is that loop looping over?

1. Put the cursor on **`by_category`** and press **Go to Definition**.

✅ **Checkpoint:** you jump to `Basket.by_category` in `src/novastack_orders/domain/basket.py`.
Its docstring says it **groups the basket's lines by category, in menu order**.

2. Press **Go back** to return to `calculate`.

So the loop runs **once per category in the basket**: for Sam's basket, once for
`main`, once for `side`, once for `drink`. Why is there a loop at all? It
computes `category_subtotals`, a total per category, which the breakdown
reports (Step 7 shows who added it, and why).

❓ **Check your understanding:** the architecture doc says loyalty is applied
**once**. In Sam's basket (a main, a side and two drinks), how many times does
the line `running = self._apply(self._loyalty, ctx, running, applied)` run, and
why?

<details><summary>Answer</summary>

**Three times**: once per *category*, not once per basket and not once per
item. The loyalty call is inside the loop over `basket.by_category()`, which
yields three groups (main, side, drink; both drinks are in one group). That
matches the three "Loyalty card discount" lines on the receipt. It's a strong
suspicion, not yet proof: Demo 3 proves it with the debugger.
</details>

### Goal 6.4: From an interface to its implementations

The loyalty, meal-deal and student discounts all follow one interface,
`DiscountRule`. Which classes implement it?

1. Open `src/novastack_orders/pricing/discounts/base.py` (`Ctrl+P` · `Cmd+P`, type `base.py`).
2. Put the cursor on **`DiscountRule`** and use **Go to Implementations**.

✅ **Checkpoint:** three implementations: `LoyaltyDiscount`, `MealDeal` and `StudentDiscount`.

---

## Step 7: Ask the History (Act 3)

*Code you didn't write was written by someone, for a reason. Find the reason before you change it.*

1. Click on the line `for category, lines in basket.by_category().items():`.
2. **GitLens** shows who last changed it at the end of the line. Hover over it.

✅ **Checkpoint:** *Priya Shah, 10 September 2026: "perf(pricing): category
subtotals and loyalty in one pass (ORD-301)"*. That shipped in release 1.3.0 on
14 September, exactly when Grace's problem started.

💬 **Discuss:** Priya is on holiday this week. Is GitLens for blaming people?
(No. It's for **context**: what was this change trying to do? Priya wanted
speed and accidentally changed behaviour. Without her, the history is how you
find that out.)

---

## Try It Yourself (lab practice)

1. Find every module that imports `Money`, without searching text.
2. Find the class that stores orders in SQLite. How many classes implement `OrderRepository`?
3. Who added the month-end report, and in which ticket?

<details><summary>Answers</summary>

1. Put the cursor on `class Money` in `domain/money.py` and press `Shift+F12`; the results are grouped by file.
2. `Ctrl+F12` · `Cmd+F12` on `OrderRepository` in `adapters/repositories/base.py`: `InMemoryOrderRepository` and `SqliteOrderRepository`, so two.
3. Open `services/reporting.py` and use GitLens or the Timeline view: Tom Okafor, **ORD-344** (12 August). Mei Lin extended it in **ORD-355** (29 September).
</details>
