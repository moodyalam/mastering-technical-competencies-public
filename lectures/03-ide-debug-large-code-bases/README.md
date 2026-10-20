# Lecture 3: The Monday After the 3 AM Page

**Mastering Computer Science Technical Competencies** · Lecture 3: Your IDE as a Professional Tool

---

## Welcome

Two weeks ago, NovaStack's checkout service went down at 3 AM, and you worked
out what happened with nothing but a terminal. NovaStack noticed. This morning
you've been moved onto **the Orders team**: the team that owns the code behind
checkout.

It's Monday, 9:00, and Jordan has sent you a message:

> **From:** Jordan
> **Subject:** Welcome to Orders 👋
>
> Hey! Glad you're on the team after the 3 AM fun.
>
> Three things for your first week:
>
> 1. **Set up your laptop the team's way.** Don't improvise. Tom's set-up does it
>    for you, and VS Code will tell you what it needs.
> 2. **Ticket ORD-317 is yours.** Grace in Finance found we've been
>    *undercharging loyalty customers* since the last release. Finance is not happy.
> 3. When that's done, Grace has another one: the **month-end sales report** has
>    become painfully slow.
>
> The codebase is big and you didn't write it. That's normal. Use the tools.
>
> — Jordan

Today you'll do Jordan's three things with the tool you'll spend most of your
working life in: the **IDE** (integrated development environment). We use **VS
Code**, the most-used development environment in the Stack Overflow 2025
Developer Survey, with Python.

Studies of new graduates find the same thing again and again: they can write
code, but they struggle to **find their way around a large codebase someone else
wrote**, rarely use the tools that make changes safe, and **debug by trial and
error**. Even experienced developers seldom use the debugger's best features.
Today is about closing that gap.

---

## What You'll Learn

By the end of this lecture, you'll be able to:

- Describe the main kinds of **development environment** and what each is good for.
- **Set up a professional Python environment** in VS Code: interpreter, virtual
  environment (uv), team settings and **extensions**.
- Explain what a **language server** does, and **navigate a large codebase by meaning**:
  Go to Definition, Find All References, Go to Implementations.
- **Refactor safely** with Rename Symbol and Extract Variable/Method.
- Use **AI assistance** (autocomplete, inline chat, chat) and **check what it produces**.
- **Debug systematically**: logging, breakpoints, conditional breakpoints,
  logpoints, the Debug Console, and `pdb` for when there's no IDE.
- **Profile** a slow program: `time`, `cProfile`, pyinstrument and flame graphs,
  and compare fairly with `hyperfine`.

---

## Before the Lecture

**Please do this today, before the lecture.** There's no time to set up during
it. Allow about 30 minutes.

Full step-by-step instructions: **[Demo 0: Set Up Your Laptop](demo/Lecture-3-Demo-0-Setup.md)**.

1. **Install VS Code** from [code.visualstudio.com](https://code.visualstudio.com/) and **Git** from [git-scm.com](https://git-scm.com/downloads) (Windows: Git for Windows).
2. **Apply for GitHub Education** at [education.github.com/students](https://education.github.com/students) if you haven't already: it gives you **Copilot Student** free. Until it's approved, **Copilot Free** works.
3. **Fork** [novastack-hq/novastack-orders](https://github.com/novastack-hq/novastack-orders) on GitHub. ⚠️ **Untick** *"Copy the `main` branch only"*.
4. **Clone your fork and run the set-up script.** It installs uv and Python, creates your SSH key, connects you to GitHub and installs the VS Code extensions.
5. ✅ **Checkpoint:** the script ends with every check `PASS`.

Stuck? Bring the `setup-report.txt` file the script writes (it contains no
passwords or keys) and ask at the start of the lecture.

---

## How This Lecture Works

The lecture follows your first week on the Orders team, in seven short acts.

| Act | Story | Topic | Demo |
|---|---|---|---|
| 1 | "What does everyone actually use?" | Development environments | Slides |
| 2 | "Set up your laptop the team's way" | Python set-up and extensions | [Demo 1](demo/Lecture-3-Demo-1-Setup-and-Navigation.md) |
| 3 | "Find your way around code you didn't write" | Language servers | [Demo 1](demo/Lecture-3-Demo-1-Setup-and-Navigation.md) |
| 4 | "Leave it better than you found it" | Refactoring | [Demo 2](demo/Lecture-3-Demo-2-Refactoring-and-AI.md) |
| 5 | "Get a pair programmer" | AI-powered development | [Demo 2](demo/Lecture-3-Demo-2-Refactoring-and-AI.md) |
| 6 | "Why are loyalty customers undercharged?" | Debugging | [Demo 3](demo/Lecture-3-Demo-3-Debugging.md) |
| 7 | "Why is the month-end report so slow?" | Profiling | [Demo 4](demo/Lecture-3-Demo-4-Profiling.md) |

You don't need to type along: watch, ask, discuss. Every demo is written up
step by step so you can repeat it afterwards, in the labs.

### The Demos

| Guide | What it shows | Time |
|---|---|---|
| [Demo 0: Set Up Your Laptop](demo/Lecture-3-Demo-0-Setup.md) | One script sets up uv, Python, SSH and VS Code on Windows, macOS or Linux. **Do this before the lecture.** | ~30 min |
| [Demo 1: Set Up and Find Your Way Around](demo/Lecture-3-Demo-1-Setup-and-Navigation.md) | Opening a project for the first time; interpreter, `.venv` and team settings; extensions; language servers and code navigation | ~12 min |
| [Demo 2: Refactor, Then Pair With an AI](demo/Lecture-3-Demo-2-Refactoring-and-AI.md) | Rename Symbol across files; Extract Variable/Method; AI autocomplete, inline chat and chat, and checking what it says | ~11 min |
| [Demo 3: Why Are Loyalty Customers Undercharged?](demo/Lecture-3-Demo-3-Debugging.md) | Logging; breakpoints, conditional breakpoints, logpoints, the Debug Console; `pdb`; AI for debugging; the fix | ~10 min |
| [Demo 4: Why Is the Month-End Report So Slow?](demo/Lecture-3-Demo-4-Profiling.md) | `time`; `cProfile`; pyinstrument and flame graphs; fixing hot spots; `hyperfine` | ~7 min |

### How to read the guides

| Icon | Meaning |
|---|---|
| ✅ | **Checkpoint:** what you should see if everything worked |
| ❓ | **Check your understanding:** a quick question. Click *Answer* to reveal it. |
| 💬 | **Discuss:** a question to talk through with the class or your lab partner |
| ⚠️ | **Warning:** something that can go wrong or cause damage |
| 💡 | **Tip:** a useful extra |

Keyboard shortcuts are written **Windows/Linux · macOS**, for example
`Ctrl+P` · `Cmd+P`. On many Mac laptops the F-keys need `Fn`.

---

## Exercise and Labs

| Activity | Description | Time |
|---|---|---|
| [Exercise: ORD-318](exercise/README.md) | A student-discount bug, found with the debugger (in pairs, if there's time in the lecture; otherwise a lab warm-up) | 10 min |
| [Beginner lab](labs/beginner/README.md) | **Do the lecture yourself.** Find your way around, rename and extract, pair with an AI, fix ORD-317 with the debugger and make the report fast again (ORD-361) | ~2 h |
| [Intermediate lab](labs/intermediate/README.md) | **New tickets, fewer hints.** Customers counted twice (logpoints, conditional breakpoints, `pdb`), the report slow again (profiling), and a refactor to make the report testable | ~2 h |
| [Advanced lab](labs/advanced/README.md) | **The auditors are coming.** Team debug configurations (including attach), a time-zone crash, a report that streams a year of orders in a few MB (`tracemalloc`), and the Dev Container | ~2 h |

**Choose one level** (or work up through them). Each lab starts from its own
branch in the team's repository and has an answer sheet and a **self-check**
script that tells you when each part is done:

```bash
uv run tools/check_lab3.py beginner
```

---

## Your Set-Up at a Glance

Everything runs **on your own laptop**: no Docker needed (the Dev Container is optional).

| Tool | Why |
|---|---|
| **VS Code** + Python, Pylance, Python Debugger, Ruff, GitLens, Copilot Chat extensions | The IDE and its team-standard extensions |
| **uv** | Installs Python 3.12 and the project's exact tool versions from `uv.lock` |
| **Git + SSH key** | Clone and (next lecture) push to GitHub securely |
| **pyinstrument**, **cProfile** | Profilers (installed by the set-up script; `cProfile` is built into Python) |
| **hyperfine** (optional) | Benchmarking two versions of a command fairly |
| **GitHub Copilot** (Free or Student plan) | The AI assistant built into VS Code |

### uv and pip

The team uses **uv**. You'll still meet **pip** everywhere, so here's the translation:

| Task | uv | pip / venv equivalent |
|---|---|---|
| Set up a cloned project exactly | `uv sync` | `python -m venv .venv`, activate it, `pip install -e . --group dev` |
| Run a command in the environment | `uv run pytest` | activate the venv, then `pytest` |
| Add a dependency | `uv add requests` | `pip install requests`, then edit `pyproject.toml` |
| Install a Python version | `uv python install 3.12` | python.org installer, Homebrew or pyenv |
| Run a one-off tool | `uvx ruff check .` | `pipx run ruff check .` |

Activating a venv: macOS/Linux `source .venv/bin/activate`; Windows PowerShell
`.venv\Scripts\Activate.ps1`. With uv you rarely need to.

---

## Using AI in This Module

Use AI assistants freely in the demos and labs, with two rules:

1. **AI is a lead, not an oracle.** Read what it suggests, check it against the
   code, and prove it (with the debugger, a profiler, or by running it).
2. **Never paste secrets** (passwords, private keys, tokens) into an AI tool, and
   follow the module's rules on AI for assessed work.

---

## Next Week

By Friday your fixes work **on your laptop**. But on NovaStack's team, nothing
reaches customers without **tests**, a **review** and **CI**. Lecture 4 picks up
exactly there.

---

## Slides

The slides will appear in [`slides/`](slides/) after the lecture.

## Further Reading

- VS Code: [Python in VS Code](https://code.visualstudio.com/docs/languages/python) · [Code navigation](https://code.visualstudio.com/docs/editing/editingevolved) · [Python editing and refactoring](https://code.visualstudio.com/docs/python/editing) · [Python debugging](https://code.visualstudio.com/docs/python/debugging) · [Extensions](https://code.visualstudio.com/docs/configure/extensions/extension-marketplace) · [Copilot](https://code.visualstudio.com/docs/copilot/overview)
- Python: [The Python profilers (cProfile)](https://docs.python.org/3/library/profile.html) · [pdb](https://docs.python.org/3/library/pdb.html) · [logging HOWTO](https://docs.python.org/3/howto/logging.html) · [pyinstrument](https://pyinstrument.readthedocs.io/)
- uv: [Getting started](https://docs.astral.sh/uv/getting-started/) · [Moving from pip to a uv project](https://docs.astral.sh/uv/guides/migration/pip-to-project/)
- The module's independent study pages on Moodle: *Getting Started*, *Core Skills* and *Agentic Coding*.
