# Lecture 6 · Demo 2: A Gate That Says No

**Mastering Computer Science Technical Competencies** · Lecture 6: Nobody Breaks It Again

---

## The Scenario So Far

Dan's promises are tests now, and the price test went round the loop
([Demo 1](Lecture-6-Demo-1-Tests-and-the-Loop.md)). But a test only helps if
someone **runs** it, and at 08:31 on Tuesday nobody did.

> **ORD-382 · The gate**
>
> **Reporter:** Jordan · **Priority:** High
>
> From today, nothing reaches `main` without a test, a second pair of eyes and a
> green tick. Build me the gate.

Today you'll build it in three trips round the loop. Each trip uses an AI in a
different role: **author** (it writes the robot), **reader** (it reads a failed
log with you) and **reviewer** (it reads a change before a person does). Each
time, something other than the AI is the judge.

> **Jordan:** "Don't tell me it works. Show me the tick."

---

## About This Demo

**Time:** about 19 minutes live (Steps 3 to 5 of the lecture, with two
Mentimeter questions); about 45 minutes if you repeat it yourself.

| Step | Title | AI role | You'll use |
|---|---|---|---|
| 3 | Ask an AI for a Robot | Author | A workflow file, `.github/workflows/ci.yml`, the Actions tab, a check on a pull request |
| 4 | Mei's Change, Again | Reader | A red cross, the job log, `uv run pytest`, `git diff` |
| 5 | Two Pairs of Eyes, then Lock the Door | Reviewer | Review on the pull request page, a ruleset, a refused push, `git reset` |

You'll need your fork of `novastack-menu` with **Actions enabled**
([Demo 0](Lecture-6-Demo-0-Setup.md)) and Step 2 done, so `main` has **six**
tests including `test_every_price_is_money`
([Demo 1](Lecture-6-Demo-1-Tests-and-the-Loop.md)). Open a terminal **in your
fork's folder**.

### Why this matters

- **Reading a failed build is the hard part.** In a survey of 523 developers,
  troubleshooting a failed CI build was the top barrier to using CI, named by
  50% (Hilton et al., ESEC/FSE 2017). So today a build fails on purpose, and you
  read the log.
- **The team you join will have it.** In the Stack Overflow Developer Survey
  2023, 71.93% of professional developers said their company has CI/CD and
  60.79% said it has automated testing.
- **Review is everyday work.** In the Stack Overflow Developer Survey 2026,
  66.7% of respondents said reviewing code is part of a typical week.
- **AI makes the judge matter more.** DORA's 2024 report estimated that for
  every 25% rise in AI adoption, delivery stability fell 7.2%. And before using
  an AI answer, 76.5% of developers run it locally first (Stack Overflow 2026).
  Today, CI runs it for you.

| Icon | Meaning |
|---|---|
| ✅ | **Checkpoint** |
| ❓ | **Check your understanding** (click *Answer*) |
| 💬 | **Discuss** |
| ⚠️ | **Warning** |
| 💡 | **Tip** |

**Windows (PowerShell) notes**, used in this guide:

| macOS / Linux | Windows (PowerShell) |
|---|---|
| `mkdir -p .github/workflows` | `New-Item -ItemType Directory -Force .github\workflows` |
| `cp a b` | `Copy-Item a b` |

Every `git`, `uv` and `gh` command is the same on all three systems.

---

## Step 3: Ask an AI for a Robot

*Jordan: "Nobody has to remember to run the tests. A machine does it, every
time."*

### Goal 3.1: What is CI, and why?

**Continuous integration (CI)** means: every time anyone proposes a change,
**a fresh machine** downloads the code, installs what it needs and **runs the
tests**. If any test fails, the change gets a **red cross** and everyone can
see it. If they all pass, it gets a **green tick**.

It answers Dan's question. Mei didn't skip the tests out of laziness: nothing
made her run them, and nothing stopped the change. CI makes running the tests
**something that happens**, not something somebody has to remember.

![The pipeline: a developer pushes a branch and opens a pull request; GitHub starts a fresh machine that checks out the code, installs uv and the locked packages, and runs pytest; the result is a green tick or a red cross on the pull request; only a green change is merged into main, and after the merge a second job builds the image and publishes it.](../slides/img/pipeline.svg)

The tool we use is **GitHub Actions**, because your code is already on GitHub.
It's the vehicle, not the point: GitLab CI, Jenkins and others work the same
way, and UK job adverts name "CI/CD" far more often than any one tool.

❓ **Check your understanding (Mentimeter Q1):** GitHub starts a fresh machine
to run your tests. What is already on it?

<details><summary>Answer</summary>

**An operating system and common tools, but not your code or its packages.**
It's like the container in Lecture 5: it starts empty of *your* things. So the
robot's instructions must say *copy my code onto the machine, install what it
needs, then run the tests*. Anything you don't write down won't be there.
</details>

### Goal 3.2: Five ideas before any YAML

A GitHub Actions **workflow** is a text file in the folder
`.github/workflows/` of your repository. It's written in **YAML**: `key: value`
lines, where **indentation (spaces, never tabs) shows what belongs to what**
and a line starting with `-` is one item in a list.

You only need five ideas to read one:

| Idea | Question it answers | In our file |
|---|---|---|
| **`on`** | *When* does the robot run? | On every pull request, and on every push to `main` |
| **`jobs`** | *What* jobs are there? Each job gets its own fresh machine | One job, called `test` |
| **`runs-on`** | *Which kind* of machine? | `ubuntu-latest`: a fresh Linux machine from GitHub, kept up to date by GitHub |
| **`steps`** | *In what order*? The job's to-do list, top to bottom; the first step that fails stops the job | Copy the code, install uv, install the packages, run the tests |
| **`uses`** and **`run`** | *How* is each step done? | `uses:` borrows a ready-made **action** someone else wrote (like an import); `run:` types a command in the machine's terminal |

💡 `run:` steps are exactly the commands you typed on your laptop in Step 1.
The robot just types them for you, on a machine that has nothing of yours on it.

### Goal 3.3: Ask the AI (author)

Open **Copilot Chat** (`Ctrl+Alt+I` · `Ctrl+Cmd+I`) in **Ask** mode. Attach
`pyproject.toml` and `tests/test_menu.py` with **Add Context** (the paperclip),
then send:

```text
Write a GitHub Actions workflow for this project. It uses uv and Python 3.12. Run the tests with pytest on every pull request and on every push to main. Add a comment above every key explaining what it does.
```

- **What** you want (a GitHub Actions workflow) and **for what** (the attached
  files).
- The facts it can't guess: the package manager (uv), the Python version, the
  test tool and **when** to run.
- **How** you want it: a comment above every key, so you can check each line.

A typical answer has the same shape as ours: `on` with `pull_request` and a
`push` to `main`, one job on `ubuntu-latest`, `actions/checkout`, a step that
installs uv (often `astral-sh/setup-uv`), then `uv sync` and `uv run pytest`.
Some answers use `actions/setup-python` and `pip` instead; that works too.
**Yours may differ: check your own, line by line.**

### Goal 3.4: Read it line by line

So that everyone sees the same file, we use one saved earlier,
`extras/ci.step3.yml`. Open it in VS Code next to your AI's answer:

```yaml
# Runs Dan's tests on every pull request and on every push to main.
name: CI

# When to run.
on:
  pull_request:
  push:
    branches: [main]

# What the job may do with the repository: read it, nothing more.
permissions:
  contents: read

jobs:
  # One job, called "test". Its name is what a ruleset asks for.
  test:
    # A fresh Linux machine from GitHub. It starts empty, like a container.
    runs-on: ubuntu-latest
    steps:
      # Copy the repository onto the machine.
      - uses: actions/checkout@v7
      # Install uv. This action has no moving "v10" tag,
      # so pin the exact version.
      - uses: astral-sh/setup-uv@v10.3.3
      # Install exactly what uv.lock lists, pytest included.
      - run: uv sync --locked
      # Run the tests. One failing test fails the whole job.
      - run: uv run pytest
```

| Line | Means |
|---|---|
| `name: CI` | The workflow's name, shown in the Actions tab and on the pull request |
| `on: pull_request:` | Run when a pull request is opened or gets new commits |
| `push: branches: [main]` | Also run when anything lands on `main` (for example, a merge) |
| `permissions: contents: read` | The robot may **read** the repository and nothing else. Give a robot the least power it needs |
| `jobs: test:` | One job, named `test`. You'll ask for this name in Step 5 |
| `runs-on: ubuntu-latest` | Start a fresh GitHub-hosted Linux machine for it |
| `uses: actions/checkout@v7` | A ready-made action that copies your repository onto the machine. `@v7` is its version |
| `uses: astral-sh/setup-uv@v10.3.3` | A ready-made action that installs uv, pinned to an **exact** version |
| `run: uv sync --locked` | Install exactly what `uv.lock` lists (pytest is in the `dev` group, installed by default). `--locked` **fails** if `uv.lock` is out of date, instead of quietly changing it |
| `run: uv run pytest` | Run the tests. If one fails, pytest exits with an error, the step fails and the job is red |

Now compare. For each line of **your** AI's answer, ask the course question:
**can I explain it?** If a line isn't in the table above, find out what it does
before you keep it.

💬 **Discuss:** the AI never saw your repository's settings or GitHub's list of
actions today. What can it **not** know? (Which versions of each action exist
*now*; whether your fork has Actions switched on; that the team wants a check
called `test`.)

### Goal 3.5: The slip to look for: action versions

Every `uses:` line names a version after the `@`. An AI writes the versions it
saw in its training data, and those may be old, or may never have existed.

The likely one here is uv's action. Many projects have a **moving tag** such as
`@v7`, which always points at the newest 7.x. `astral-sh/setup-uv` stopped
publishing moving tags in 2026 (for safety: Step 7 of Demo 3 explains why), so
**there is no `@v10` tag**: you must name an exact release such as `v10.3.3`.

If your AI wrote `astral-sh/setup-uv@v10`, that's a real slip, not one we
planted. How would you spot it?

- **Before you push:** open the action's page
  ([github.com/astral-sh/setup-uv](https://github.com/astral-sh/setup-uv)) and
  look at **Releases** and the README's own example. Check the version exists.
- **After you push:** the job fails at the **start**, in *Set up job*, within
  a few seconds and before any test runs, with:

```text
Unable to resolve action `astral-sh/setup-uv@v10`, unable to find version `v10`
```

If your AI wrote an older version that does exist (for example `@v5`), it will
probably work, but it's out of date. Use the version the action's page shows.

❓ **Check your understanding:** your AI's file has `uv sync` without
`--locked`. Does that matter in CI?

<details><summary>Answer</summary>

It still runs, but if `uv.lock` doesn't match `pyproject.toml`, plain `uv sync`
quietly **updates** the lock on the robot's machine and carries on, so the
robot tests something slightly different from what's committed. With
`--locked` it **stops** with an error instead, and you find out. In CI you want
it to stop.
</details>

### Goal 3.6: Save it as the workflow, on a branch

Start from an up-to-date `main`:

```bash
git switch main
```

- Go back to `main`.

```bash
git pull
```

- Bring in what's on GitHub (your merged price test from Step 2).

```bash
git switch -c add-ci
```

- `switch -c` = **c**reate a new branch called `add-ci` and move onto it.

GitHub only looks for workflows in one place, `.github/workflows/`. Make the
folder.

macOS / Linux:

```bash
mkdir -p .github/workflows
```

- `mkdir` makes a folder; `-p` makes the parent `.github` too, and doesn't
  complain if it already exists.

Windows (PowerShell):

```powershell
New-Item -ItemType Directory -Force .github\workflows
```

- `New-Item -ItemType Directory` makes a folder; `-Force` makes the parents and
  doesn't complain if it exists.

Copy the saved file into it, named `ci.yml`.

macOS / Linux:

```bash
cp extras/ci.step3.yml .github/workflows/ci.yml
```

Windows (PowerShell):

```powershell
Copy-Item extras\ci.step3.yml .github\workflows\ci.yml
```

- The source is the saved file; the destination is where GitHub looks. The file
  name `ci.yml` is up to you, but the folder is not.

💡 The **GitHub Actions** extension for VS Code (published by GitHub) underlines
mistakes in workflow files as you type.

### Goal 3.7: Round the loop

```bash
git status
```

- Lists what has changed; look before you add.

✅ **Checkpoint:** one untracked folder, `.github/`, holding
`.github/workflows/ci.yml`. Nothing else.

```bash
git add .github/workflows/ci.yml
```

- Stage **that one file** by name (never `git add .` when you aren't sure what's
  in the folder).

```bash
git commit -m "ci: run the tests on every pull request and push to main"
```

- `ci:` says what kind of change this is, as in Step 2.

```bash
git push -u origin add-ci
```

- Upload the branch to your fork; `-u` remembers that `add-ci` goes to
  `origin/add-ci`, so next time a plain `git push` is enough.

✅ **Checkpoint:** the output ends with a link to create a pull request
(Ctrl+click · Cmd+click to open it).

Open the link and create the pull request.

⚠️ **Check the base repository.** On a fork, GitHub pre-selects the
**upstream** repository (`novastack-hq/novastack-menu`) as the base. Change
**base repository** to **your own fork**, base branch `main`. (The upstream
only accepts pull requests from collaborators, so a wrong base won't land, but
it won't run your check either.)

💡 With `gh`: run `gh repo set-default` once and pick **your fork**, then
`gh pr create --fill` makes the pull request from the commit message.

### Goal 3.8: Watch the robot

Notice that pushing the branch did **not** start the robot: `on:` says *pull
requests* and *pushes to `main`*. **Opening the pull request** started it.

On the pull request page, scroll down to the checks box. It shows your check,
named after the workflow, the job and the event: **`CI / test (pull_request)`**,
with a yellow dot while it runs.

Click **Details** next to it, or open the **Actions** tab of your fork and
click the run. You'll see the job `test` and, inside it, one line per step:

| Step in the log | From the file |
|---|---|
| Set up job | GitHub starting the fresh machine |
| Run actions/checkout@v7 | `uses: actions/checkout@v7` |
| Run astral-sh/setup-uv@v10.3.3 | `uses: astral-sh/setup-uv@v10.3.3` |
| Run uv sync --locked | `run: uv sync --locked` |
| Run uv run pytest | `run: uv run pytest` |

Click **Run uv run pytest** to open it.

✅ **Checkpoint:** the same pytest output as on your laptop, ending
`6 passed`, and a green tick next to the job. The whole run takes well under
a minute (11 seconds on a fork when we tried it).

✅ **Checkpoint:** back on the pull request, the checks box says **All checks
have passed** (*1 successful check*), and `CI / test (pull_request)` has a
**green tick** and *Successful in* a few seconds.

❓ **Check your understanding:** the robot printed `6 passed`, just like your
laptop. So what did it prove that your laptop couldn't?

<details><summary>Answer</summary>

That the tests pass on a machine that has **only what the repository says**:
the committed code, `uv.lock` and the steps in `ci.yml`. Nothing left over on
your laptop (an old package, an uncommitted file, a different Python) can make
it pass by accident. And it ran without anyone remembering to run it.
</details>

### Goal 3.9: Merge, and come home

On the pull request page, click **Merge pull request**, then **Confirm merge**.

✅ **Checkpoint:** the Actions tab shows a **second** run of `CI`, this time
for the **push to `main`** that the merge made. It goes green too.

Back on your laptop:

```bash
git switch main
```

- Back to your local `main`.

```bash
git pull
```

- Brings in the merge. Your local `main` now has `.github/workflows/ci.yml`.

---

## Step 4: Mei's Change, Again

*Last lecture's lesson, again: give an AI **evidence**, not a guess. Read the
evidence yourself first.*

### Goal 4.1: Replay Tuesday morning, as a pull request

This is **Mei's change from Dan's message**, replayed on purpose: it is
**planted**, and we know what's wrong with it. The difference from Tuesday is
that it now goes through a pull request, so the robot sees it first. (No blame
for Mei: the process failed, not her.)

```bash
git switch -c autumn-special
```

- A new branch for ticket ORD-381.

Open `menu.json`. Go to the **last** item (`N02`, Flapjack). Add a comma after
its closing `}`, then paste Mei's item before the final `]`:

```json
  {
    "sku": "D05",
    "name": "Pumkin spice latte",
    "category": "drink",
    "price": "4.5O",
    "icon": "🎃"
  }
```

- One new menu item, in the same five fields as every other item.
- Look closely if you like. Like Mei, we **don't** run the tests before
  pushing this time.

```bash
git add menu.json
```

- Stages only the menu, by name.

```bash
git commit -m "feat: add the autumn special (ORD-381)"
```

- `feat:` = a new feature for the user; the ticket number links it to the story.

```bash
git push -u origin autumn-special
```

- Sends the branch to your fork; `-u` remembers where it goes.

Open the link, and create the pull request **into your own fork's `main`**
(⚠️ check the base repository, as in Goal 3.7).

### Goal 4.2: The red cross

Wait for the check.

✅ **Checkpoint:** the check gets a **red cross**, and the checks box says
**All checks have failed** (*1 failing check*: `CI / test (pull_request)`,
*Failing after* a few seconds). The **Merge**
button is still there for now (Step 5 fixes that), but everyone can see the
change is broken.

❓ **Check your understanding (Mentimeter Q2):** the check is red. What is the
most likely cause?

<details><summary>Answer</summary>

**The change broke something a test checks.** It's the only thing that changed
since the last green run: the same workflow passed on `main` a few minutes ago.
GitHub's machine being broken, the tests being wrong or the network dropping
can all happen, but they're much rarer, and the log will tell you which it is.
Start from what changed.
</details>

### Goal 4.3: From the cross to the log

Three clicks:

1. On the pull request, click **Details** next to the failed check. You land on
   the job's log.
2. Find the step with the **red cross**: here, **Run uv run pytest**. The steps
   above it are green, so the machine, uv and the packages were fine. Click it
   to expand it if it isn't open already.
3. Scroll to the bottom of that step, to pytest's **short test summary**. Look
   for the line starting `FAILED`, then go **up** to the lines starting `E`.

✅ **Checkpoint:** near the bottom, the log says

```text
FAILED tests/test_menu.py::test_every_price_is_money - AssertionError: D05 Pumkin spice latte: price '4.5O' is not money like '4.50'
========================= 1 failed, 5 passed in 0.30s ==========================
```

(your time will differ). The same message is a little higher up, in the
**FAILURES** section, on the line starting `E`:

```text
E           AssertionError: D05 Pumkin spice latte: price '4.5O' is not money like '4.50'
```

💡 On your **laptop**, pytest cuts the `FAILED` line to the width of your
terminal (`... D05 Pu...` in a narrow one). On GitHub it prints the whole line,
because pytest notices it is running in CI. The `E` line is always whole: read
that one.

| Part of the log | Tells you |
|---|---|
| `FAILED` | A test ran and its promise was broken (not a crash in the robot) |
| `tests/test_menu.py::test_every_price_is_money` | **Which** promise: the file, then the test |
| `AssertionError` | The test's `assert` was false |
| `E ... D05 Pumkin spice latte: price '4.5O' ...` | The message **you** wrote in Step 2: which item, and what's wrong |
| `1 failed, 5 passed` | Only one promise broke; the other five still hold |

💡 Lines starting `E` are pytest's **error** lines, and the line starting `>`
just above them is the line of the test that failed. Read those first.

💡 With `gh`: `gh pr checks` lists the checks and their state, and
`gh run view --log-failed` prints only the failed steps' log in your terminal.

### Goal 4.4: Read it yourself first, and predict

Before you ask anyone, write one sentence: *"I think the problem is ___, and the
fix is ___."* Look at `'4.5O'` closely. Compare it with the `'4.50'` the message
asks for.

### Goal 4.5: Reproduce it on your laptop

A red cross on a robot you can't touch is hard to work with. Make it happen
where you can poke at it:

```bash
uv run pytest
```

- The same command the robot ran, on the same branch.

pip route (if you set up with pip in Demo 0), macOS and Linux:

```bash
.venv/bin/python -m pytest
```

- Runs pytest with the Python inside `.venv`.

PowerShell:

```powershell
.venv\Scripts\python -m pytest
```

- The same, with the Windows path to `.venv`'s Python.

✅ **Checkpoint:** the same failure as in the log: `1 failed, 5 passed`, and the
same `E           AssertionError: D05 Pumkin spice latte: ...` line. (In a wide
terminal the `FAILED` line is whole; in a narrow one it's cut, as on GitHub.)
Same code, same promise, same result. That's how you know it's the change, not
the robot.

💡 `uv run pytest -vv` prints every message in full, whatever the width.

### Goal 4.6: What "red" can mean

A red cross means **"stop and look"**, not always **"your code is wrong"**.
There are two kinds:

| | **Your change broke a promise** | **The pipeline itself is broken** |
|---|---|---|
| Which step is red | The **test** step (`Run uv run pytest`) | An **earlier** step: *Set up job*, checkout, installing uv, `uv sync`; or the workflow doesn't start at all |
| What the log says | `FAILED tests/...` with an assertion | Can't find an action or version, a package won't install, `uv.lock` is out of date, a YAML error |
| On your laptop | `uv run pytest` fails the same way | `uv run pytest` passes |
| On `main` | The same workflow is green on `main` | Often red on `main` too, or red only since the workflow file changed |
| Who fixes it | Whoever made the change | Whoever owns the workflow (here, also you) |

Here every check points the same way: the test step is red, the log names a
test, and your laptop agrees. **Your change broke a promise.**

❓ **Check your understanding:** a pull request that changes only `README.md`
goes red at the step **Run uv sync --locked**. Which kind of red is it?

<details><summary>Answer</summary>

**The pipeline is broken.** A README change can't break a test, and the job
never reached the tests: it failed while installing packages. Likely causes:
`uv.lock` is out of date with `pyproject.toml` (someone changed one without
the other), or a package download failed. Check whether `main` is red too, and
read that step's log.
</details>

### Goal 4.7: Now ask the AI (reader)

The AI can only read what you give it, and **attaching a file doesn't attach
GitHub's log**. Give it both pieces of evidence.

1. Copy the failing part of the log: on the job page, select from the
   `FAILURES` heading down to the summary line `1 failed, 5 passed` and copy it
   (`Ctrl+C` · `Cmd+C`). That includes the whole `E` line, not just the cut
   `FAILED` line.
2. Get the change itself, the **diff**:

```bash
git diff main
```

- Shows every line this branch changes compared with your local `main`: `+`
  lines added, `-` lines removed. (The pull request's **Files changed** tab
  shows the same thing.)

3. Start a **new** chat in Copilot Chat (**Ask** mode). Copy this prompt into
   the chat box:

```text
This check failed. Here are the log and the diff. What is wrong, and what is the smallest change that fixes it?

Log:

Diff:
```

4. Paste the log after `Log:` and the diff after `Diff:`, then send.

- The **log** is the symptom, the **diff** is what changed: together they're
  the evidence.
- "The smallest change" asks for a fix, not a rewrite.

✅ **Checkpoint:** the answer **quotes the evidence** (the price `4.5O`, a
letter O where a zero should be). If it says it can't see a log or a diff, they
didn't reach it: paste them and ask again.

Compare its answer with your sentence from Goal 4.4. Then decide, because you
can check.

💬 **Discuss:** you predicted before you asked. Why bother, if the AI would
have told you anyway? (Because you can only judge an answer you could have
reached yourself. If your prediction and the AI disagree, that's the moment to
look harder, not to pick the more confident one.)

### Goal 4.8: The one-line fix

In `menu.json`, change Mei's price to a zero:

```json
    "price": "4.50",
```

- `4.50`, with the digit zero. That's the whole fix: one character.

Prove it on your laptop first:

```bash
uv run pytest
```

- All six tests, on the fixed menu.

✅ **Checkpoint:** `6 passed`.

```bash
git add menu.json
```

- Stages the fixed menu, by name.

```bash
git commit -m "fix: the autumn special costs 4.50"
```

- `fix:` says it repairs a bug; the message says what the fix is.

```bash
git push
```

- No `-u` this time: the branch already knows where it goes.

✅ **Checkpoint:** the pull request shows **both** commits, a new run starts by
itself, and the check turns **green**. Don't merge yet: Step 5 isn't finished
with this change.

---

## Step 5: Two Pairs of Eyes, then Lock the Door

*The tick is green. Is the change ready?*

### Goal 5.1: What is review for?

The robot checks **that it works**: every promise you wrote down as a test.
People check **that it's right for the team**: is it what the ticket asked for,
does it read well, will the next person understand it, is there something no
test covers? Code review is a teammate reading your change before it's merged.

What the research says about review in practice:

- **At Google**, a study of 9 million reviewed changes found review is used for
  education, keeping the team's norms, gatekeeping and preventing accidents.
  The **median change was 24 lines**, and most had one reviewer (Sadowski et
  al., ICSE-SEIP 2018).
- **At Microsoft**, finding defects was the top reason programmers gave for
  review, but of 570 review comments studied only **14% were about defects**;
  29% were improvements to the code (Bacchelli & Bird, ICSE 2013). Review does
  more than catch bugs.
- **Keep changes small.** A study of 2,500 reviews at Cisco (SmartBear, 2006)
  advises keeping a review under 200 to 400 lines: beyond that, reviewers find
  less.

### Goal 5.2: Ask the AI (reviewer)

Get the diff again (it now includes the price fix):

```bash
git diff main
```

- Every line this branch changes compared with your local `main`.

Start a **new** chat (**Ask** mode). Copy this prompt into the chat box, then
paste the diff on the line after it:

```text
Review this change. Give me at most three problems, most important first.
```

- "At most three, most important first" stops a long list of nitpicks.

Typical answers include: **"Pumkin" is misspelled; it should be "Pumpkin"**;
whether a seasonal item needs an end date; the order of items or the choice of
SKU. The order varies. **Check your own answer**, and don't apply what you
can't explain.

We apply **one**: the spelling. It's the one that matters to Morgan Lee, who
will see it on the till.

❓ **Check your understanding:** every test was green. Why didn't a test catch
"Pumkin"?

<details><summary>Answer</summary>

**No promise said anything about spelling.** The tests check that each item has
five fields, unique SKUs and a price that looks like money. "Pumkin" is a
perfectly valid string. You could add a spell-checker, but a machine can't know
that "Pumkin" isn't a brand name: that needs someone who knows what the menu is
*for*. The machine checks that it works; people check that it's right.
</details>

### Goal 5.3: Fix it, prove it's still green

In `menu.json`, change the name:

```json
    "name": "Pumpkin spice latte",
```

```bash
uv run pytest
```

- Prove it on your laptop first.

✅ **Checkpoint:** `6 passed`. (The tests didn't care before and don't now.)

```bash
git add menu.json
```

- Stages the menu, by name.

```bash
git commit -m "fix: spell pumpkin correctly"
```

- The review fix, as its own commit.

```bash
git push
```

- Sends it; the pull request picks up the new commit and the check runs again.

✅ **Checkpoint:** a new run, and the check stays **green**.

### Goal 5.4: How a person reviews on GitHub

An AI in your editor is one pair of eyes. On a team, a **person** reviews on
the pull request page. Open your pull request and click **Files changed**:

1. Hover over a line and click the **+** that appears to write a comment on that
   line. Choose **Start a review** to collect several comments before sending.
2. Click **Submit review** (top right; older pages call it **Review
   changes**). A box called **Finish your review** opens: pick one:

| Choice | Means |
|---|---|
| **Comment** | General feedback, neither yes nor no |
| **Approve** | "I've read it; it's good to merge" |
| **Request changes** | "Not yet": the author must respond before merging (when the team requires approval) |

3. Click **Submit review**.

⚠️ **You can't approve your own pull request.** On your own pull request
**Approve** and **Request changes** are greyed out, with *Pull request authors
can't approve their own pull requests.* A review is a **second** pair of eyes, by definition. On your own fork, try a
**Comment** review on your own change to see how it works.

💡 Good review comments are about the code, not the person, and say *why*:
"Customers see this name on the till; it should be 'Pumpkin'" beats "typo".

💡 **Copilot code review** on the pull request page (add Copilot as a reviewer)
is included in Copilot Student but not Copilot Free; it gives comments like
the ones from Chat, and by default its review does **not** count as an
approval. Treat it as one more pair of eyes, never the last.

💬 **Discuss:** Google's median change is 24 lines. Why would a team **prefer**
ten small pull requests to one big one, even though it means ten reviews?
(Each is quick to read and easy to undo; a reviewer finds less in a long one;
and a red cross points at a small change.)

### Goal 5.5: Lock the door: a ruleset

Right now **anyone with push access** (you) can still push straight to `main`,
as Mei did, and the robot would only complain afterwards. A **ruleset** makes
GitHub **refuse** changes to `main` unless the rules are met.

The check must have run at least once before GitHub offers it in the list; it
has (Step 3). On **your fork** on GitHub:

1. **Settings** → **Rulesets** (left sidebar) → **New ruleset** → **New branch
   ruleset**.
2. **Ruleset name:** `protect-main`.
3. **Enforcement status:** **Active**.
4. **Target branches:** **Add target** → **Include default branch**.
5. Tick **Require a pull request before merging**, and leave **Required
   approvals** at **0**. (On a team you'd set 1 or more. On your own fork
   nobody else can approve, so 0 lets you still merge, and you still need a
   pull request.)
6. Tick **Require status checks to pass**, click **Add checks**, type `test`
   and choose it. This is the job name from `ci.yml`.
7. Leave the **Bypass list** empty: nobody, not even you, skips the rules.
8. Click **Create**. GitHub may ask you to **Confirm access** (a passkey, your
   authenticator app or your password) before it changes a setting like this:
   that's normal.

✅ **Checkpoint:** **Rulesets** lists `protect-main` as **Active**.

💡 Scripts (and the lab checker) can do the same with
`gh api repos/OWNER/REPO/rulesets`; you don't need that today.

### Goal 5.6: Try to break in

Mei's habit, one more time: a commit straight on `main`. Go to `main`:

```bash
git switch main
```

- Moves you to your local `main`.

```bash
git commit --allow-empty -m "chore: just this once"
```

- `--allow-empty` makes a commit that changes **no files**: harmless, but it's
  still a new commit for `main`.

❓ **Check your understanding (Mentimeter Q3):** `main` now needs a pull request
and a green check. You push this commit straight to `main`. What happens?
Predict, then run it.

```bash
git push
```

- Send your local `main`'s new commit to your fork's `main`.

<details><summary>Answer</summary>

**GitHub refuses the push.** Git made the commit happily on your laptop (Git
has no idea about GitHub's rules), but when it reaches GitHub the ruleset
checks it: no pull request, no check, so it's turned away. Nothing reaches
`main`.
</details>

✅ **Checkpoint:** the push is rejected:

```text
remote: error: GH013: Repository rule violations found for refs/heads/main.
remote: Review all repository rules at https://github.com/<your-username>/novastack-menu/rules?ref=refs%2Fheads%2Fmain
remote:
remote: - Changes must be made through a pull request.
remote:
remote: - Required status check "test" is expected.
remote:
To github.com:<your-username>/novastack-menu.git
 ! [remote rejected] main -> main (push declined due to repository rule violations)
error: failed to push some refs to 'github.com:<your-username>/novastack-menu.git'
```

- `GH013` is GitHub's code for "a rule said no".
- The two `-` lines name the rules it broke: a pull request is required, and
  the check `test` is expected.
- `[remote rejected]`: nothing reached `main` on GitHub.

Read the refusal: it tells you exactly what's missing. The door is locked.

### Goal 5.7: Undo the experiment

Your local `main` now has a commit that GitHub's `main` will never accept. Put
your local `main` back to match GitHub's:

```bash
git reset --hard origin/main
```

- `reset` moves your current branch (`main`) to another commit.
- `origin/main` is your laptop's record of where `main` is **on GitHub**.
- `--hard` also makes your files match that commit.

⚠️ `git reset --hard` **throws away** local commits that aren't on GitHub, and
**any uncommitted changes** in your files, with no undo. It's safe here because
the only thing lost is the empty "just this once" commit. Run `git status`
first if you're ever unsure, and never use it on a branch others share.

```bash
git status
```

- Checks that your `main` matches GitHub's again.

✅ **Checkpoint:** `Your branch is up to date with 'origin/main'` and nothing
to commit.

### Goal 5.8: Merge the autumn special, through the gate

Back on the `autumn-special` pull request: it has a pull request (of course)
and a green `test` check, so the ruleset lets it through. Click **Merge pull
request**, then **Confirm merge**.

✅ **Checkpoint:** the merge runs `CI` on `main` once more, and it's green. On
your laptop:

```bash
git pull
```

- Brings the merge down to your local `main`.

✅ **Checkpoint:** `menu.json` on `main` has **Pumpkin spice latte** at
**4.50**. Run `uv run app.py` and open <http://localhost:8000> if you want to
see it on the page (stop it with `Ctrl+C`).

> **Dan:** "A test, a second pair of eyes and a green tick. That's the gate."

---

## Try It Yourself

1. **Break the pipeline, not the code.** On a new branch, change the uv step in
   `.github/workflows/ci.yml` to `astral-sh/setup-uv@v10` and open a pull
   request. Which step goes red? Use the table in Goal 4.6 to say which kind of
   red it is. Then close the pull request without merging.
2. **Write a new promise.** Add a test that every item's `category` is one of
   `main`, `side`, `drink`, `dessert`, `snack`. Take it round the loop. Then, on
   another branch, add an item with category `"drinks"` and watch the check go
   red.
3. **Push past the rule?** With the ruleset active, try to merge a pull request
   whose check is still running (yellow). What does the merge button say?
4. Why does the ruleset name the check `test` and not `CI`?

<details><summary>Answers</summary>

1. The job fails at its **start** (*Set up job*), before any test runs, because
   GitHub can't find that version of the action (`v10` isn't a tag of it). Every test would have passed: it's
   the **pipeline** that's broken, and `uv run pytest` on your laptop still
   passes.
2. For example:
   `assert item["category"] in {"main", "side", "drink", "dessert", "snack"}, item`
   inside a loop over `MENU`. The `"drinks"` item fails it, with the item
   printed in the message.
3. It won't merge yet: the button is greyed out (or offers only a bypass, if
   you're on the bypass list, which you aren't) until the required check
   passes.
4. A ruleset asks for **checks**, and a check is a **job**. `CI` is the name of
   the workflow, which can hold several jobs (Demo 3 adds a second one,
   `publish`). Naming the job says exactly which result must be green.
</details>

---

## Next

[Demo 3: From Green to Shipped](Lecture-6-Demo-3-From-Green-to-Shipped.md):
after the merge, a second job builds Lecture 5's image and publishes it, so Tom
can pull it without your laptop. Then habits for safe pipelines, and what to do
when two changes collide.
