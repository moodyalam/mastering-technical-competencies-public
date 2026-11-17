# Lecture 6 · Beginner Lab: Your First Green Tick

**Mastering Computer Science Technical Competencies** · Lecture 6: Nobody Breaks It Again

**Time:** about 2 hours · **On your own laptop** · **Self-checking:** a script tells you when each part is done.

---

## The Scenario

In the lecture you watched someone else build the gate. This time, you build it.

> **From:** Dan
> **Subject:** ORD-385: build the gate yourself ✅
>
> Thanks for Tuesday. Now I'd like to see it work in **your** fork, from
> nothing: Dan's tests on your laptop, the price test taken round the loop, a
> robot that runs the tests, Mei's change going **red and then green**, and a
> lock on `main` so nobody (you included) can skip the gate.
>
> Write your answers in `lab6/BEGINNER.md` as you go.
>
> Dan

You can open the [demo guides](../../demo/) for help, but **try each part first
with only the hints here**. That's where the learning happens.

---

## About This Lab

| Part | Title | Lecture step | You'll use | Time |
|---|---|---|---|---|
| 0 | Warm-up: ORD-384 (optional) | 3 | A workflow, the Actions log | 10 min |
| 1 | Get Ready | 1 | Your fork, `uv sync`, `uv run pytest` | 15 min |
| 2 | The Loop | 2 | Branch, commit, push, pull request, merge | 25 min |
| 3 | A Robot That Runs the Tests | 3 | `.github/workflows/ci.yml` | 25 min |
| 4 | Mei's Change, Red Then Green | 4 | The log, the fix | 20 min |
| 5 | Two Pairs of Eyes, Then Lock the Door | 5 | Review, a ruleset, a refused push | 25 min |
| 6 | Check | | The self-check | 10 min |

| Icon | Meaning |
|---|---|
| ✅ | **Checkpoint:** what you should see if everything worked |
| ❓ | **Check your understanding:** click *Answer* to reveal it |
| 💬 | **Discuss:** talk it through with a lab partner |
| ⚠️ | **Warning** |
| 💡 | **Tip** |

**Before you start:** the set-up from [Demo 0](../../demo/Lecture-6-Demo-0-Setup.md):
your `novastack-menu` fork **brought up to date** (it now has `tests/`,
`extras/` and `lab6/`), **Actions switched on** for the fork, and `git push`
working. On Windows use **PowerShell**.

---

## Part 0: Warm-Up: ORD-384 (optional)

Do the [exercise](../../exercise/README.md): finish a three-blank workflow,
push it, and find out why the first run is red.

---

## Part 1: Get Ready

A **test** is a promise a machine can check: a small function that runs some
of your code and says `assert` *this must be true*. `pytest` finds every
function whose name starts with `test_` and runs it. Dan has written five.

1. Open a terminal **in your `novastack-menu` folder** (`code .` opens it in VS Code).
2. Make sure you're on an up-to-date `main` (`git switch main`, then `git pull`).
3. Install what the project needs, then run the tests.

```bash
uv sync
```

- Reads `pyproject.toml` and `uv.lock` and installs Flask **and** pytest (the
  `dev` group) into `.venv/` in this folder.

```bash
uv run pytest
```

- Runs pytest inside that environment. It looks in `tests/` (set in
  `pyproject.toml`).

💡 **pip route** (if you don't use uv): make and activate a virtual
environment as in Lecture 3, then `python -m pip install -r requirements-dev.txt`
and `python -m pytest`.

4. Open `tests/test_menu.py` and read the five tests. Write the number of
   tests that passed on line **B1** of `lab6/BEGINNER.md`.

✅ **Checkpoint:** the last line says how many passed, in green, and nothing
failed. Now run the self-check once (mostly FAIL for now) and read one hint:

```bash
uv run tools/check_lab6.py beginner
```

- `uv run` runs the script; `python tools/check_lab6.py beginner` works too (it
  uses only Python's standard library; on macOS and Linux you may need
  `python3`).

---

## Part 2: The Loop

Nobody writes straight onto `main` in a team. Every change goes **round the
loop**: make a **branch** (your own copy of the history), **commit** on it,
**push** it, open a **pull request** (a request to merge, with a page for
checks and comments), **merge**, then bring `main` home. Dan's 4.5O bug needs
a **regression test**: a test that fails on the bug, so it can never come back
unnoticed.

1. Start the branch:

```bash
git switch -c price-test
```

- `switch -c` creates the branch `price-test` and moves you onto it.

2. In `tests/test_menu.py`, add `import re` at the top (above `import pytest`,
   with a blank line between them), and paste this at the **end** of the file:

```python
MONEY = re.compile(r"\d+\.\d\d")  # two digits after the point: 4.50, 12.00


def test_every_price_is_money():
    for item in MENU:
        assert MONEY.fullmatch(item["price"]), (
            f"{item['sku']} {item['name']}: "
            f"price {item['price']!r} is not money like '4.50'"
        )
```

- `re.compile(...)` makes a pattern: digits, a point, exactly two digits.
- `fullmatch` means the **whole** price must fit the pattern, so `4.5O`,
  `4.5` and `£4.50` all fail.
- The message after the comma is what you'll read in the log when it fails.

3. Run `uv run pytest` again: six should pass. Then look before you add:

```bash
git status
```

- Lists what changed. You should see only `tests/test_menu.py`.

```bash
git add tests/test_menu.py
```

- Stages **that one file**. Naming the file means nothing else sneaks in
  (no `.env`, no stray files). Avoid `git add .` for now.

```bash
git commit -m "test: every price must be money (regression test for ORD-381)"
```

- Records the change on `price-test`. The message says **what** and **why**.

```bash
git push -u origin price-test
```

- Sends the branch to your fork. Git prints a link for a new pull request.

4. Open that link (or your fork's page: GitHub offers **Compare & pull
   request**).

⚠️ **Check the base repository before you click Create.** On a fork, GitHub
pre-selects the **upstream** repository (`novastack-hq/novastack-menu`) as the
base. Change **base repository** to **your own fork**, base branch `main`.
Your pull request belongs in your fork. (The team's repository only accepts
pull requests from its members, so if GitHub refuses, that's why.)

5. Create the pull request, read its page (**Conversation**, **Commits**,
   **Files changed**), then **Merge pull request** and confirm.
6. Come home:

```bash
git switch main
```

- Moves you back to your local `main` (which doesn't have the merge yet).

```bash
git pull
```

- Fetches the merge from your fork and brings your `main` up to date.

✅ **Checkpoint:** on `main`, `uv run pytest` shows six passed, and
`git log --oneline -3` shows the merge.

❓ **Check your understanding:** the test passes today. So what is it for?

<details><summary>Answer</summary>

It's a promise about the **future**. Today every price is money, so it passes.
The day someone types `4.5O` again, it fails, with a message that names the
item. A regression test turns "we'll remember" into "the machine will check".
</details>

💡 Optional, with the GitHub CLI: `gh repo set-default` (choose **your fork**),
then `gh pr create --fill` opens the pull request from the terminal.

---

## Part 3: A Robot That Runs the Tests

A test that nobody runs protects nothing. **Continuous integration (CI)** means
a machine runs the tests on every change, before it is merged. On GitHub this
machine is described by a **workflow**: a YAML file in `.github/workflows/`.
Five ideas carry the whole file:

| Key | Meaning |
|---|---|
| `on:` | **When** to run: here, on every pull request and every push to `main` |
| `jobs:` | **What** to run; each job gets its own fresh machine |
| `runs-on:` | **Which** machine: `ubuntu-latest` is Linux |
| `steps:` | The job's steps, in order |
| `uses:` / `run:` | A step either **uses** someone's ready-made action, or **runs** a command |

1. Start the branch:

```bash
git switch -c add-ci
```

- A new branch for the workflow, made from your up-to-date `main`.

2. **Optional, AI as author.** Ask Copilot Chat (Ask mode): *"Write a GitHub
   Actions workflow for this project. It uses uv and Python 3.12. Run the
   tests with pytest on every pull request and on every push to main. Add a
   comment above every key explaining what it does."* Compare its answer with
   `extras/ci.step3.yml`, line by line. Look hard at the version after
   `astral-sh/setup-uv@`: this action has **no** moving `v10` tag, so it must
   say an exact version such as `v10.3.3`.
3. Use the lecture's file (macOS and Linux):

```bash
mkdir -p .github/workflows
```

- Makes the folder GitHub looks in (no complaint if it exists).

```bash
cp extras/ci.step3.yml .github/workflows/ci.yml
```

- Copies the lecture's workflow to where GitHub will find it.

Windows (PowerShell):

```powershell
New-Item -ItemType Directory -Force .github/workflows
```

```powershell
Copy-Item extras/ci.step3.yml .github/workflows/ci.yml
```

- The same two actions, in PowerShell's words.

4. Read `ci.yml`. Every key has a comment. Find the line that installs Flask
   and pytest on the machine (it's not `pip`).
5. Round the loop:

```bash
git add .github/workflows/ci.yml
```

- Stages the workflow file, by name.

```bash
git commit -m "ci: run the tests on every pull request and push to main"
```

- `ci:` at the start says the change is to the pipeline, not the app.

```bash
git push -u origin add-ci
```

- Sends the branch to your fork. Open the pull request from the link
  (⚠️ base repository = **your fork**).
6. On the pull request, watch the check appear, go yellow (running) and then
   green. It is listed under the workflow's, the job's and the event's names:
   `CI / test (pull_request)`.
7. Click **Details** next to the check, then expand the **Set up job** step.
   Find the **name of the operating system** the machine ran (look near the top
   of that step for the group **Operating System**, and the line under it).
   Write the name on line **B3**. (The version changes as GitHub updates
   `ubuntu-latest`, which is why the check only asks for the name.)

💡 In the **setup-uv** step you'll see `Could not determine uv version from
uv.toml or pyproject.toml. Falling back to latest.` That's harmless: it
installs the newest uv.
8. Merge, then come home (`git switch main`, `git pull`).

✅ **Checkpoint:** your fork's **Actions** tab shows a green run of **CI** on
`main` (the merge is a push to `main`, so it ran again).

❓ **Check your understanding:** why does the workflow need `uv sync --locked`
when you already ran `uv sync` on your laptop?

<details><summary>Answer</summary>

The machine is not your laptop. It starts with Linux and common tools, but
without your packages (Mentimeter Q1). `uv sync --locked` installs exactly what
`uv.lock` lists, and **fails** if `uv.lock` is out of date with
`pyproject.toml`, so CI tests what you really locked.
</details>

💡 `permissions: contents: read` gives the job's token permission to **read**
the code and nothing more. A job that can't write can't be tricked into
writing.

---

## Part 4: Mei's Change, Red Then Green

Now replay Tuesday morning, the way it should have gone: as a pull request,
with the robot watching. (This change is planted. It's not Mei's fault: the
process let it through.)

1. Start the branch:

```bash
git switch -c autumn-special
```

- Creates the branch `autumn-special` from your up-to-date `main` and moves you
  onto it.
2. Open `menu.json` and add this as the **last item** (put a comma after the
   `}` of the item before it):

```json
  {
    "sku": "D05",
    "name": "Pumkin spice latte",
    "category": "drink",
    "price": "4.5O",
    "icon": "🎃"
  }
```

- Copy it exactly, mistakes included: `4.5O` ends in a **letter O**, and
  *Pumkin* is misspelt. Both are planted.

3. **Don't run the tests** (Mei didn't). Round the loop:

```bash
git add menu.json
```

- Stages only the menu.

```bash
git commit -m "feat: add the autumn special (ORD-381)"
```

- `feat:` says it's a new feature; the ticket number links it to the story.

```bash
git push -u origin autumn-special
```

- Sends it to your fork. Open the pull request (⚠️ base = **your fork**).
4. Wait for the **red cross**. Before you open the log, predict: what will it
   say?
5. Click **Details**, open the red step and scroll to the `FAILURES` section.
   Read the line that starts with `E` and `AssertionError`. Write the **name
   of the test** that failed on line **B2** (the word after `::` on the
   `FAILED` line).

⚠️ The `FAILED` summary line is cut at 80 characters in a CI log (it ends `...`). The
whole message is on the `E           AssertionError: ...` line above it.

6. Reproduce it on your laptop with `uv run pytest`: the same test fails with
   the same message. Red on GitHub and red on your laptop: the change is wrong,
   not the machine.
7. Fix the price to `"4.50"` (digits only). Run `uv run pytest` (six pass),
   then:

```bash
git add menu.json
```

- Stages the fixed menu.

```bash
git commit -m "fix: the autumn special costs 4.50"
```

- A second commit on the same branch.

```bash
git push
```

- No `-u` needed now: the branch already knows where to go. The pull request
  picks up the new commit and the check runs again.

✅ **Checkpoint:** the same pull request now shows a green tick. **Don't merge
yet.**

💬 **Discuss:** the check was red. List three different reasons a check can be
red. Which one do you check **first**, and why?

<details><summary>Answer</summary>

The change broke something a test checks (by far the most common); the tests
or the workflow file are wrong; something outside failed (a download, GitHub
itself). Read the log first: a test name and an `AssertionError` mean your
change, while a network error in a set-up step means "re-run it".
</details>

---

## Part 5: Two Pairs of Eyes, Then Lock the Door

The robot checks that it **works**. People check that it is **right**. The
tick is green, yet the menu would say *Pumkin*.

1. On the pull request, open **Files changed** and review it as if it were a
   colleague's. Leave a comment on the line with the problem you find.
2. **Optional, AI as reviewer.** Ask Copilot Chat with the diff: *"Review this
   change. Give me at most three problems, most important first."* Apply
   **one** suggestion, and only one you can justify.
3. Fix the spelling to `"Pumpkin spice latte"`, then:

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

- Sends it to the same pull request. Wait for green.

Now lock `main`, so the gate can't be skipped. A **ruleset** is a set of rules
GitHub enforces on a branch.

4. In your fork: **Settings**, **Rules**, **Rulesets**, **New ruleset**, **New
   branch ruleset**. Name it `protect-main`; **Enforcement status: Active**;
   **Target branches**: add the **default branch**. Tick **Require a pull
   request before merging** (0 required approvals, so you can still merge your
   own) and **Require status checks to pass**, then add the check **`test`**.
   Save.
5. Merge the autumn-special pull request (through the gate), and come home
   (`git switch main`, `git pull`).
6. Try to break in: a tiny commit straight onto `main`.

```bash
git commit --allow-empty -m "chore: just this once"
```

- Makes a commit that changes no files (`--allow-empty`), on `main`.

```bash
git push
```

- Tries to push it straight to `main`. The ruleset should refuse it, with
  `remote: error: GH013: Repository rule violations found for refs/heads/main.`
  followed by the rules you broke: `- Changes must be made through a pull
  request.` and `- Required status check "test" is expected.`, then
  `! [remote rejected] main -> main (push declined due to repository rule
  violations)`.
  Write the code that starts with `GH` on line **B4**, and the check's name
  (from the refusal or your ruleset) on line **B5**.

7. Undo the experiment, so your `main` matches GitHub's again:

```bash
git reset --hard origin/main
```

- Moves your local `main` back to exactly what your fork has (`origin/main`).
- ⚠️ `--hard` also **throws away uncommitted changes** in your files. Here it
  only removes the empty commit, but run `git status` first whenever you use it.

8. On line **B6**, say in one or two sentences why no test caught *Pumkin*.

✅ **Checkpoint:** `git status` says your branch is up to date with
`origin/main`, and the menu on `main` has *Pumpkin spice latte* at `4.50`.

❓ **Check your understanding:** Mentimeter asked what happens when you push
to a locked `main`. Why does **GitHub** refuse it and not **Git**?

<details><summary>Answer</summary>

Git on your laptop made the commit happily: rules live on the **server**.
GitHub checks every push against the rulesets, and `main` now needs a pull
request and a green `test` check. A direct push has neither.
</details>

---

## Part 6: Check

```bash
uv run tools/check_lab6.py beginner
```

- Reads your answer sheet, your `ci.yml`, your branches and what is on `main`.
- **Hidden check:** it copies your `main` to a temporary folder, breaks one
  price, and runs **your** tests: they must fail on the broken copy and pass
  on the real one.
- With the GitHub CLI (`gh`) installed and logged in (`gh auth login`), it also
  reads your fork: a red run followed by a green one, the merged pull
  requests, and the ruleset. Without `gh` those checks say SKIP: look at the
  Actions tab yourself.

✅ **Checkpoint:** no FAIL lines. (SKIP lines are fine.) The check reads your
**facts and history**; B6 is for you, so make it honest.

<details><summary>Answers (after you've tried)</summary>

- B1 is `5`. B2 is `test_every_price_is_money`. B3 is **Ubuntu** (a Linux
  distribution; the version moves over time). B4 is `GH013`. B5 is `test`.
- B6: the tests check that every price looks like money and every item has its
  five fields; no test looks at spelling, and a spelling test would need a
  dictionary of every word on the menu. That's what a reviewer is for.
- The line in `ci.yml` that installs Flask and pytest is `run: uv sync --locked`.
</details>

---

## Finished Early?

- Do the [Intermediate lab](../intermediate/README.md).
- Write a second regression test: every `sku` is a capital letter and two
  digits (`M01`, `D05`). Take it round the loop. Does the gate let it in?
- Break a test on purpose in a pull request, then click **Re-run jobs**. Why
  doesn't re-running fix it, and when **would** re-running be the right move?
- Install the GitHub CLI and repeat one loop with `gh pr create --fill`,
  `gh pr checks` and `gh run view --log-failed`.
