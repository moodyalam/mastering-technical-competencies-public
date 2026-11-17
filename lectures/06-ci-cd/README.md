# Lecture 6: Nobody Breaks It Again

**Mastering Computer Science Technical Competencies** · Lecture 6: Tests, Pull Requests, Review and CI/CD

---

## Welcome

Your box runs on staging and Tom is happy. Then, on Tuesday at 08:40, a message
from Dan Hughes, who looks after quality at NovaStack:

> **From:** Dan
> **Subject:** Who checked this? 🔍
>
> At 08:31 Mei added the autumn special to the menu and pushed it straight to
> `main`. Tom rebuilt the box. Staging now shows a price the till can't read:
> **£4.5O**, with a letter O. Morgan Lee has just tried to order one.
>
> Nobody ran the tests, and no test looked at prices anyway.
>
> I asked this three weeks ago: **how do we make sure nobody breaks it again?**
>
> – Dan

Jordan adds: *"Tom has put the old menu back. From today, nothing reaches `main`
without a test, a second pair of eyes and a green tick. Build me the gate."*

Nobody is blaming Mei: she did what the process let her do. The process is what
you fix today. You'll write a **test** that would have caught the bad price, take
every change round **the loop** (branch, commit, push, **pull request**, merge),
get a robot (**GitHub Actions**) to run the tests on every change, let a person
**review** what the robot can't judge, lock `main` so nobody can skip the gate,
and finally have the robot **build and publish** Lecture 5's box by itself. An
**AI** helps three times, as author, reader and reviewer, and the green tick is
the judge.

The team you join will already work like this. In the Stack Overflow Developer
Survey **2023**, **71.93%** of professional developers said their company has
CI/CD and **60.79%** said it has automated testing. In the **2022** survey, the
last that asked, **96.65%** of professional developers used Git. In the **2026**
survey, in a typical week **66.7%** review code, **51.8%** deploy or release and
**51.1%** write or maintain tests. And when 523 developers were asked what holds
them back with CI, the top answer (**50%**) was fixing a failed build (Hilton et
al., 2017): so today, a build fails on purpose and you read its log. GitHub
Actions is just the vehicle: the ideas work the same in GitLab, Jenkins or
whatever your team uses.

---

## What You'll Learn

By the end of this lecture, you'll be able to:

- Explain what a **test** is (a promise a machine can check), run the tests, and read **pytest**'s output, passing and failing.
- Write a **regression test** for a bug, so that bug can't come back unnoticed.
- Take a change round **the loop**: a **branch**, a **commit** of named files, a **push**, a **pull request**, a **merge**, and home again.
- Read a **GitHub Actions workflow** and explain its five ideas: `on`, `jobs`, `runs-on`, `steps`, `uses`/`run`.
- **Read a failed check's log**, find the cause and fix it.
- Say what **code review** finds that tests can't, and lock `main` with a **ruleset**.
- Have a pipeline **build and publish** a Docker image after the tests pass.
- Use an **AI** as author, reader and reviewer, and **prove** each answer with a green tick.

---

## Before the Lecture

**Please do this before the lecture.** There's no time to set up during it. Allow
about 20 minutes.

Full step-by-step instructions: **[Demo 0: Get Ready for the Gate](demo/Lecture-6-Demo-0-Setup.md)**.

1. **Bring your fork of `novastack-menu` up to date** (the **Sync fork** button on GitHub), then `git pull`. New to the menu service? Demo 0 shows how to fork and clone it.
2. **Run the tests:** `uv sync`, then `uv run pytest`.
3. ✅ **Checkpoint:** pytest prints `5 passed`.
4. **Check you can push:** make a throw-away branch, push it, delete it.
5. **Switch on Actions in your fork** (the **Actions** tab): forks start with Actions off.
6. Optional: install the **GitHub CLI** (`gh`) and point it at your own fork.

Can't use your laptop? Use **GitHub Codespaces**: Demo 0, Step 7. Stuck? Bring
the output of `git remote -v` and `git status` to the start of the lecture.

---

## How This Lecture Works

The lecture follows one Tuesday morning, in six short **Steps**. Each Step is one
trip round the loop, so you see it four times.

| Step | Story | Topic | Branch | Demo |
|---|---|---|---|---|
| 1 | "Dan's promises" | Run the tests on your laptop; a test is a promise a machine can check | `main` | [Demo 1](demo/Lecture-6-Demo-1-Tests-and-the-Loop.md) |
| 2 | "The loop" | A regression test for the 4.5O bug, taken round the loop: branch, commit, push, pull request, merge | `price-test` | [Demo 1](demo/Lecture-6-Demo-1-Tests-and-the-Loop.md) |
| 3 | "Ask an AI for a robot" | A workflow file; the five ideas (`on`, `jobs`, `runs-on`, `steps`, `uses`/`run`); the first green tick. AI as **author** | `add-ci` | [Demo 2](demo/Lecture-6-Demo-2-A-Gate-That-Says-No.md) |
| 4 | "Mei's change, again" | The autumn special as a pull request: red cross, read the log, fix, green. AI as **reader** | `autumn-special` | [Demo 2](demo/Lecture-6-Demo-2-A-Gate-That-Says-No.md) |
| 5 | "Two pairs of eyes, then lock the door" | Review finds what the robot can't; a ruleset; a direct push to `main` is refused. AI as **reviewer** | `autumn-special` | [Demo 2](demo/Lecture-6-Demo-2-A-Gate-That-Says-No.md) |
| 6 | "From green to shipped" | After the merge, a second job builds Lecture 5's image and publishes it; Tom pulls it | `ship-it` | [Demo 3](demo/Lecture-6-Demo-3-From-Green-to-Shipped.md) |
| 7, 8 | *(written guide only)* "Habits for pipelines" and "When two changes collide" | Pinning actions, least-privilege `permissions`, secrets, caching, a matrix; a merge conflict fixed in VS Code | | [Demo 3](demo/Lecture-6-Demo-3-From-Green-to-Shipped.md) |

You don't need to type along: watch, ask, discuss. Every demo is written up
step by step so you can repeat it in the labs.

### The Demos

| Guide | What it shows | Time |
|---|---|---|
| [Demo 0: Get Ready for the Gate](demo/Lecture-6-Demo-0-Setup.md) | Syncing your fork, running the tests, checking you can push, switching on Actions, the optional `gh`, the Codespaces fallback. **Do this before the lecture.** | ~20 min |
| [Demo 1: Tests and the Loop](demo/Lecture-6-Demo-1-Tests-and-the-Loop.md) | Steps 1 and 2: running and reading tests, a failing test, a regression test taken round the loop to a merged pull request | ~6 min live |
| [Demo 2: A Gate That Says No](demo/Lecture-6-Demo-2-A-Gate-That-Says-No.md) | Steps 3 to 5: an AI-written workflow, the first green tick, Mei's change going red, reading the log, review, a ruleset | ~19 min live |
| [Demo 3: From Green to Shipped](demo/Lecture-6-Demo-3-From-Green-to-Shipped.md) | Step 6 live; Steps 7 and 8 to do yourself: publishing the image, pipeline habits, merge conflicts | ~3 min live |

### How to read the guides

| Icon | Meaning |
|---|---|
| ✅ | **Checkpoint:** what you should see if everything worked |
| ❓ | **Check your understanding:** a quick question. Click *Answer* to reveal it. |
| 💬 | **Discuss:** a question to talk through with the class or your lab partner |
| ⚠️ | **Warning:** something that can go wrong or cause damage |
| 💡 | **Tip:** a useful extra |

Commands are written for macOS and Linux; **PowerShell** equivalents are given
where they differ. On Windows, use **PowerShell**, not Git Bash. Shortcuts are
written **Windows/Linux · macOS**.

---

## Exercise and Labs

| Activity | Description | Time |
|---|---|---|
| [Exercise: ORD-384](exercise/README.md) | Finish a three-blank workflow, then find out why its first run goes red (in pairs; it is **Part 0 of each lab**) | 10 min |
| [Beginner lab: Your First Green Tick](labs/beginner/README.md) | **Do the lecture yourself.** Run the tests, add the price test round the loop, write the workflow, take Mei's change from red to green, add a ruleset | ~2 h |
| [Intermediate lab: Make It Production-Shaped](labs/intermediate/README.md) | **Fewer hints.** A lint job, caching, a Python version matrix, least-privilege permissions, actions pinned to commit SHAs, a ruleset needing both checks | ~2 h |
| [Advanced lab: Bring CI to Orders](labs/advanced/README.md) | **In `novastack-orders`.** A workflow following the team's own decision record, then fix ORD-317 in a pull request and meet `XPASS(strict)` | ~2 h |

**Choose one level** (or work up through them). Each lab has an answer sheet in
`lab6/` and a **self-check** that tells you when each part is done:

```bash
uv run tools/check_lab6.py beginner
```

- `uv run` runs the script with the project's Python.
- `tools/check_lab6.py` is the self-check; it prints **PASS**, **FAIL** or **SKIP** for each part, with a hint when something isn't done yet.
- `beginner` is the level: use `intermediate` or `advanced` for the others.

---

## Your Set-Up at a Glance

| Tool | Why |
|---|---|
| **Git** and a **GitHub** account | Branches, commits, pushes and pull requests |
| **`novastack-menu`**, your fork | The menu service, Dan's tests, the saved workflows, the lab answer sheets and the self-check |
| **uv** (or `python` and pip) | Installs pytest and runs the tests |
| **VS Code** + **Copilot Chat** | As in Lectures 3 to 5; used to write, read and review workflows |
| **GitHub CLI** (`gh`, optional) | Pull requests and check results from the terminal; some self-checks use it |
| **Docker** (optional today) | Only to pull and run the published image at the end of Step 6, as Tom does |
| **GitHub Codespaces** (fallback) | A Linux machine in the cloud with Git already signed in |

---

## Next

Mei opens a pull request for the winter special. The check goes red on a typo
before anyone else sees it, and she fixes it in a minute. Dan: *"First time a
mistake has cost us one minute instead of one morning."*

Jordan: *"Next: **the data behind the menu**."* A later lecture opens the
database that Lecture 5's Compose stack started, and every change to it will go
through the gate you build today.
