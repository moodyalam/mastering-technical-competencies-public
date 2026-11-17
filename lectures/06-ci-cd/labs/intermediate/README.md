# Lecture 6 · Intermediate Lab: Make It Production-Shaped

**Mastering Computer Science Technical Competencies** · Lecture 6: Nobody Breaks It Again

**Time:** about 2 hours · **On your own laptop** · **Self-checking:** a script tells you when each part is done.

---

## The Scenario

The gate works. Then Tom reads your workflow.

> **From:** Tom
> **Subject:** ORD-386: it's green, but is it production-shaped?
>
> Nice gate. Before the whole team relies on it, my checklist says: a **lint**
> check as well as the tests, **fast** repeat runs, **both** the Python we ship
> and the next one, the **least** permission the jobs need, every action
> **pinned** so nobody can swap its code under us, and no queue of stale runs
> when someone pushes three times in a minute. Oh, and the lock on `main` must
> ask for **all** of it.
>
> Tell me **why** you made each change. AI can draft; you must be able to
> justify every line.
>
> Tom

This lab gives you **goals, tools and hints, not steps**. The
[demo guides](../../demo/) (especially [Demo 3](../../demo/Lecture-6-Demo-3-From-Green-to-Shipped.md),
"Habits for pipelines") cover the ideas. Answers go in `lab6/INTERMEDIATE.md`.

---

## About This Lab

| Part | Title | You'll use | Time |
|---|---|---|---|
| 0 | Warm-up: ORD-384 (optional) | A workflow, the log | 10 min |
| 1 | Start From Green | Your `ci.yml`, one branch | 10 min |
| 2 | A Lint Job | Ruff, `uv add --dev` | 20 min |
| 3 | The Cache | setup-uv's cache, the job timings | 15 min |
| 4 | A Matrix | `strategy: matrix:`, Python 3.12 and 3.13 | 15 min |
| 5 | Least Privilege, and Pin Every Action | `permissions:`, full commit SHAs | 25 min |
| 6 | No Stale Runs | `concurrency:` | 10 min |
| 7 | A Gate With Two Checks | The ruleset | 10 min |
| 8 | Say Why, Then Check | `# why:` comments, the self-check | 15 min |

| Icon | Meaning |
|---|---|
| ✅ | **Checkpoint** |
| ❓ | **Check your understanding** (click *Answer*) |
| 💬 | **Discuss** |
| ⚠️ | **Warning** |
| 💡 | **Tip** |

---

## Part 0: Warm-Up: ORD-384 (optional)

The [exercise](../../exercise/README.md): a three-blank workflow, and a first
run that is red for a reason you've met before.

---

## Part 1: Start From Green

You need the Beginner lab's result: `.github/workflows/ci.yml` on `main`, a
green run, and (if you made it) the `protect-main` ruleset. If you skipped the
Beginner lab, copy `extras/ci.step3.yml` to `.github/workflows/ci.yml` and take
it round the loop first (Beginner lab, Part 3).

Do this whole lab on **one branch** with **one pull request** (⚠️ base
repository = **your fork**). Push after each part: every push is a new run to
look at.

```bash
git switch main
```

- Starts from your `main`.

```bash
git pull
```

- Makes sure it matches your fork.

```bash
git switch -c production-shaped
```

- The branch for the whole lab.

✅ **Checkpoint:** `git status` says `On branch production-shaped`, and
`uv run pytest` passes.

---

## Part 2: A Lint Job

A **linter** reads code without running it and flags likely bugs and messy
style: an unused import, a variable that's never used, a name that's never
defined. **Ruff** is a fast Python linter. Tests check what the code **does**;
a linter checks how it's **written**. A separate job means a separate check,
so a red cross tells you which kind of problem you have.

1. Add Ruff as a **development** tool, so its version is locked like pytest's:

```bash
uv add --dev ruff
```

- Adds `ruff` to the `dev` group in `pyproject.toml` **and** updates
  `uv.lock`. Commit **both** files: `uv sync --locked` in CI fails if
  `uv.lock` is out of date.

💡 **pip route:** add `ruff` to `requirements-dev.txt` and
`python -m pip install -r requirements-dev.txt`. The workflow in this lab uses
uv.

2. Run it on the service and its tests:

```bash
uv run ruff check app.py tests
```

- `ruff check` lints the files and folders you name. We lint the service
  (`app.py`) and its tests; the course's self-check scripts in `tools/` are
  written for teaching, not to Ruff's taste.

3. Add a second job, `lint`, to `ci.yml`, next to `test`: the same first
   steps (check out, set up uv, `uv sync --locked`), then the Ruff command
   above. Commit the three files by name, push, and open the pull request
   (⚠️ base repository = **your fork**):

```bash
git add pyproject.toml uv.lock .github/workflows/ci.yml
```

- Stages exactly the three files you changed: the dev group, the lock and the
  workflow. `git commit` and `git push -u origin production-shaped` follow, as
  in the lecture.

✅ **Checkpoint:** the pull request shows **two** checks, `lint` and `test`,
both green.

❓ **Check your understanding:** why not just add `uv run ruff check` as one
more step at the end of the `test` job?

<details><summary>Answer</summary>

It would work, but one red cross would then mean "tests or style", and you'd
have to open the log to find out which. Separate jobs run **at the same time**
(each on its own machine), report separately, and can be required separately
by the ruleset.
</details>

---

## Part 3: The Cache

Every run starts on an empty machine, so every run downloads uv's packages
again, unless they are **cached**: saved at the end of one run and restored at
the start of the next. The uv action does this **by default** on GitHub's
machines (its `enable-cache` setting defaults to `auto`). The cache's key
includes a fingerprint of `uv.lock`, so a new `uv.lock` means a new cache.

1. Your push in Part 2 changed `uv.lock`, so that run started **without** a
   cache. Open it: click the `test` job, expand the **setup-uv** step and find
   the line about the cache. Write the job's time (seconds, from the run's
   summary page) on line **T1**.
2. Run it again with nothing changed: on the run's page, **Re-run jobs**, **Re-run all jobs**.
   Open the new attempt's `test` job, write its time on line **T2**, and paste
   the setup-uv line about the cache on line **C1**.

Look for these lines (the key after them is long; `setup-uv-2-...` is enough):

| Run | In **Run astral-sh/setup-uv@v10.3.3** | In **Post Run astral-sh/setup-uv@v10.3.3** |
|---|---|---|
| First (nothing saved yet) | `No GitHub Actions cache found for key: setup-uv-2-...` | `uv cache saved with key: setup-uv-2-...` |
| Re-run | `Cache hit for: setup-uv-2-...`, then `cache restored from GitHub Actions cache with key: ...` | `Cache hit occurred on key ..., not saving cache.` |

💡 A cache saved by a pull request's run is kept for that pull request; the
first run on `main` after it starts with no cache again.

💬 **Discuss:** T2 may be only a little faster than T1, or not faster at all.
Why? (Look at how many packages this project has, and how fast uv installs
them, compared with starting the machine and checking out the code.) When
would the cache matter a lot?

---

## Part 4: A Matrix

A **matrix** runs the same job several times with one value changed each time.
The menu ships on Python 3.12; you want to know **before** an upgrade whether
3.13 breaks anything.

1. Try it on your laptop first:

macOS and Linux:

```bash
UV_PYTHON=3.13 uv run pytest
```

- `UV_PYTHON=3.13` tells uv which Python to use for this one command (uv
  downloads 3.13 if you don't have it). It overrides `.python-version`.

Windows (PowerShell):

```powershell
$env:UV_PYTHON = "3.13"; uv run pytest; Remove-Item Env:UV_PYTHON
```

- Sets the variable, runs the tests, then removes the variable again.

💡 uv rebuilds `.venv` for 3.13; the next plain `uv run` rebuilds it for 3.12.
That's expected.

2. In the `test` job, add a `strategy:` with a `matrix:` called
   `python-version` holding `"3.12"` and `"3.13"` (quote them: unquoted `3.10`
   would become the number `3.1`). Pass it to the uv step:

```yaml
      - uses: astral-sh/setup-uv@v10.3.3
        with:
          python-version: ${{ matrix.python-version }}
```

- `with:` gives the action an input. setup-uv's `python-version` input sets
  `UV_PYTHON` for the rest of the job, exactly as you just did by hand.
- `${{ matrix.python-version }}` is replaced by `3.12` in one job and `3.13`
  in the other.

3. Push. Write on line **M1** how many test jobs the matrix made.

✅ **Checkpoint:** the pull request now shows `lint`, `test (3.12)` and
`test (3.13)`, all green.

⚠️ **If you made `protect-main` in the Beginner lab:** it requires a check
called `test`, and that name no longer exists (the jobs are now
`test (3.12)` and `test (3.13)`). The pull request will wait for `test`
forever. The checks box says *Some checks haven't completed yet* (*1 expected,
2 successful checks*), lists `test` as **Expected — Waiting for status to be
reported** with a **Required** label, and **Merge pull request** is greyed out.
You fix this in Part 7, before merging.

---

## Part 5: Least Privilege, and Pin Every Action

**Least privilege:** each job gets a token (`GITHUB_TOKEN`) for the
repository, and `permissions:` says what it may do. These jobs only **read**
the code. If a step were ever tricked into misbehaving, a read-only token
can't push code or publish anything.

1. Check that `ci.yml` has `permissions:` with `contents: read` at the top,
   and that **no** job asks for `write`.

**Pinning:** `uses: actions/checkout@v7` runs whatever code the tag `v7` points
at **today**. Tags can be moved. In March 2025 the tags of a popular action,
`tj-actions/changed-files`, were moved to malicious code, affecting over 23,000
repositories. A full **commit SHA** (40 hexadecimal characters) names one
exact version of the code and can't be moved.

2. Find the commit SHA of each action's release. On the action's GitHub page:
   **Tags** (or **Releases**), click the tag, and copy the full commit SHA.
   With the GitHub CLI:

```bash
gh api repos/actions/checkout/commits/v7.0.1 --jq .sha
```

- `gh api` asks GitHub's API; `commits/v7.0.1` turns the tag into the commit
  it points at; `--jq .sha` prints only the SHA.

```bash
gh api repos/astral-sh/setup-uv/commits/v10.3.3 --jq .sha
```

- The same for the uv action (`v10.3.3` is the version the lecture used).

3. Replace **every** `uses:` line, in both jobs, with the SHA and the version
   as a comment:

```yaml
      - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1
```

- The SHA is what GitHub runs; `# v7.0.1` is for humans (and for tools such as
  Dependabot, which can update pins for you).

4. Copy the SHA you used for `actions/checkout` onto line **S1**. Push.

✅ **Checkpoint:** all three checks are still green, and no `uses:` line in
`ci.yml` has an `@v` straight after the action's name.

💡 GitHub announced **workflow lockfiles** (`.github/workflows/actions.lock`)
on 28 Oct 2026: a file that records the exact commit of every action, like
`uv.lock` does for packages. Where a team adopts them they replace hand-written
SHAs. Pinning by SHA is still the habit to know, and the one this lab checks.

❓ **Check your understanding:** `uv.lock` and SHA pins solve the same problem
for different things. What problem?

<details><summary>Answer</summary>

"The same file gives a different result next week." `uv.lock` fixes the exact
versions of your **packages**; SHA pins fix the exact code of the **actions**
that build and test them. Both make a run repeatable, and both mean nobody can
change what you run without a commit you can see.
</details>

---

## Part 6: No Stale Runs

Push three commits in a minute and you get three runs, though only the last
one matters. **`concurrency:`** puts runs in a group; with
`cancel-in-progress: true`, a new run in the group **cancels** the older one.

1. At the top level of `ci.yml` (next to `permissions:`), add a `concurrency:`
   whose `group:` is `${{ github.workflow }}-${{ github.ref }}` (one group per
   workflow and branch) and `cancel-in-progress: true`.
2. Test it: push, then quickly make a second small commit (a comment) and
   push again.

✅ **Checkpoint:** on the Actions tab, the first of the two runs shows as
**cancelled**, and the second runs to green.

💡 Some teams cancel only on pull requests, so every commit on `main` is still
tested: `cancel-in-progress: ${{ github.event_name == 'pull_request' }}`.

---

## Part 7: A Gate With Two Checks

1. In your fork: **Settings**, **Rules**, **Rulesets**. Edit `protect-main`
   (or create it as in the Beginner lab, Part 5): **Require status checks to
   pass** with **`lint`**, **`test (3.12)`** and **`test (3.13)`**. Remove the
   old `test` if it's there. (A check is offered only after it has run once,
   which is why you pushed first.)
2. Write the checks you required on line **R1**.
3. Merge the pull request through the gate, and come home
   (`git switch main`, `git pull`).

✅ **Checkpoint:** the merged pull request shows three green checks, and the
run on `main` is green.

---

## Part 8: Say Why, Then Check

1. Put a `# why:` comment in `ci.yml` above each change you made (at least
   **five**): the lint job, the cache, the matrix, `permissions:`, the pins,
   `concurrency:`. A line you can't explain gets removed. Take it round the
   loop.
2. Fill in **W1** to **W6** in `lab6/INTERMEDIATE.md`: one or two sentences
   each.
3. Run the check:

```bash
uv run tools/check_lab6.py intermediate
```

- Reads `ci.yml` and your answer sheet. **Hidden checks:** every `uses:` must
  be pinned to a 40-character SHA, and it runs your Ruff command on a copy of
  your `main`.
- With `gh` logged in, it also reads your fork: the latest run on `main`, its
  jobs, the ruleset's checks, and whether each pinned SHA really is a commit of
  that action. Without `gh` those checks SKIP.

✅ **Checkpoint:** no FAIL lines.

<details><summary>Answers (after you've tried)</summary>

```yaml
# Runs Ruff and Dan's tests on every pull request and on every push to main.
name: CI

on:
  pull_request:
  push:
    branches: [main]

# why: least privilege; the jobs only read the code, so a leaked token can't write
permissions:
  contents: read

# why: a newer push to the same branch cancels the older run and saves minutes
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  # why: style and simple bugs get their own check, so a red cross says which
  lint:
    runs-on: ubuntu-latest
    steps:
      # why: a full commit SHA can't be moved to new code, a tag can
      - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1
      - uses: astral-sh/setup-uv@68559e99cc807c1eb7e9238fd43a15bba460eec2 # v10.3.3
      - run: uv sync --locked
      - run: uv run ruff check app.py tests

  test:
    runs-on: ubuntu-latest
    strategy:
      # why: the Python we ship (3.12) and the next one (3.13), side by side
      matrix:
        python-version: ["3.12", "3.13"]
    steps:
      - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1
      # why: setup-uv caches uv's downloads by default; python-version sets UV_PYTHON
      - uses: astral-sh/setup-uv@68559e99cc807c1eb7e9238fd43a15bba460eec2 # v10.3.3
        with:
          python-version: ${{ matrix.python-version }}
      - run: uv sync --locked
      - run: uv run pytest
```

- M1 is `2`. R1 is `lint, test (3.12), test (3.13)`. S1 is
  `3d3c42e5aac5ba805825da76410c181273ba90b1` (for v7.0.1).
- T1 and T2 are yours. For a project this small the cache saves little: most
  of a run is starting the machine and checking out. It matters when there
  are hundreds of packages, or big ones (a machine-learning library).
</details>

---

## Finished Early?

- Add **Dependabot** for actions (`.github/dependabot.yml` with
  `package-ecosystem: "github-actions"`): it opens pull requests that move your
  SHA pins to new releases. Which gate do those pull requests have to pass?
- Try the `gh actions-lock` extension on a copy of your workflow and read the
  `actions.lock` file it makes. What does it record that your `# v7.0.1`
  comment doesn't?
- Add `fail-fast: false` to the matrix, break a test only on 3.13 (hint:
  `sys.version_info`), and compare with `fail-fast` left on.
- Do the [Advanced lab](../advanced/README.md).
