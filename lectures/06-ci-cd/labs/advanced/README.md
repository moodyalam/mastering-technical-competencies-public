# Lecture 6 · Advanced Lab: Bring CI to Orders

**Mastering Computer Science Technical Competencies** · Lecture 6: Nobody Breaks It Again

**Time:** about 2 hours · **On your own laptop** · **Self-checking:** a script tells you when each part is done.

---

## The Scenario

> **From:** Dan
> **Subject:** ORD-387: the Orders service still has no gate
>
> The menu has a gate now. The Orders service (the one you debugged in Lecture
> 3) has 218 tests and **no CI at all**: `.github/workflows/` holds only a
> README. We agreed how it should work months ago, in **ADR 0004**: the smoke
> tier on every push, the full suite on pull requests.
>
> And while you're there: my test for ORD-317 is still marked
> `xfail(strict=True)`. Fix the bug **in a pull request**, and watch what my
> marker does to your check.
>
> Dan
>
> **From:** Tom
>
> Optional, if you have time: make the menu's pipeline **publish** the box
> after the tests pass on `main`, so I can pull it.

This lab gives you **goals, tools and hints, not steps**. Design the workflow
yourself; the [demo guides](../../demo/) cover every technique you need.
Answers go in `lab6/ADVANCED.md` **in your `novastack-menu` folder** (that's
where the self-check lives).

---

## About This Lab

| Part | Title | You'll use | Time |
|---|---|---|---|
| 0 | Warm-up: ORD-384 (optional) | A workflow, the log | 10 min |
| 1 | Orders on Your Laptop | A fresh clone, `uv run pytest -m smoke` | 15 min |
| 2 | Design From ADR 0004 | Events, jobs, `if:` | 15 min |
| 3 | Write It and Prove It | `.github/workflows/ci.yml`, a pull request | 25 min |
| 4 | Fix ORD-317, Meet `XPASS(strict)` | A pull request that goes red | 20 min |
| 5 | Make It Green, Merge | Remove the marker | 10 min |
| 6 | Explain, Then Check | Your words, the self-check | 15 min |
| 7 | Optional: Ship the Menu | `extras/ci.step6.yml`, `ghcr.io` | 20 min |

| Icon | Meaning |
|---|---|
| ✅ | **Checkpoint** |
| ❓ | **Check your understanding** (click *Answer*) |
| 💬 | **Discuss** |
| ⚠️ | **Warning** |
| 💡 | **Tip** |

---

## Part 0: Warm-Up: ORD-384 (optional)

The [exercise](../../exercise/README.md), in your `novastack-menu` fork: a
three-blank workflow, and a first run that is red for a familiar reason.

---

## Part 1: Orders on Your Laptop

You forked `novastack-hq/novastack-orders` in Lecture 3. Your old clone may
still hold Lecture 3 work (Demo 3's fix, a refactoring), so **clone your fork
again, into a new folder**, next to your `novastack-menu` folder. Run this in
the folder that **contains** `novastack-menu`:

```bash
git clone https://github.com/<your-username>/novastack-orders.git novastack-orders-ci
```

- Copies **your fork** (not `novastack-hq`'s) into a new folder,
  `novastack-orders-ci`. Replace `<your-username>`.

```bash
cd novastack-orders-ci
```

- Moves into it. Every command until Part 6 runs here.

Then, in your fork on GitHub, open the **Actions** tab and switch workflows on
(forks start with Actions off; [Demo 0](../../demo/Lecture-6-Demo-0-Setup.md)
shows the button).

1. Install, then run the two tiers that ADR 0004 (`docs/adr/0004-test-tiers.md`)
   describes:

```bash
uv sync
```

- Installs the dev tools (pytest, Ruff, mypy) from `uv.lock` into `.venv/`.

```bash
uv run pytest -m smoke
```

- `-m smoke` runs only the tests marked `@pytest.mark.smoke` (the **smoke
  tier**: fast, critical-path checks).

```bash
uv run pytest
```

- No `-m`: the **full suite**, smoke and integration tests included.

On the lecturer's laptop (10 Nov 2026, Python 3.12, pytest 9.2.0) they printed:

```text
........x.........                                                       [100%]
17 passed, 200 deselected, 1 xfailed in 0.17s
```

```text
........................................................................ [ 33%]
.....................................................x.................. [ 66%]
........................................................................ [ 99%]
..                                                                       [100%]
217 passed, 1 xfailed in 0.34s
```

2. On line **O1**, write how many tests the smoke tier **selects** (passed and
   xfailed; *deselected* means "not chosen"). On line **O3**, how many the full
   suite has.

❓ **Check your understanding:** what is the `x`, and why doesn't it make the
run fail?

<details><summary>Answer</summary>

`x` is an **xfail**: a test marked "expected to fail". It's Dan's test for
ORD-317 (`tests/unit/pricing/test_calculator.py`), marked
`@pytest.mark.xfail(reason="ORD-317: remove when fixed", strict=True)`. It
documents a **known bug**: the test is right, the code is wrong. It fails, as
expected, so the run passes. `strict=True` matters in Part 4.
</details>

💡 If the full suite says `218 passed` and no `xfailed`, your fork's `main`
already has a fix for ORD-317 (from Lecture 3). Put the team's two files back
**with a new commit** (no history is rewritten, so nothing needs a force-push):

```bash
git remote add upstream https://github.com/novastack-hq/novastack-orders.git
```

- Names the team's repository `upstream` (if it says the remote already
  exists, carry on).

```bash
git fetch upstream
```

- Downloads the team's commits as `upstream/main`, without changing your files.

```bash
git restore --source upstream/main -- src/novastack_orders/pricing/calculator.py tests/unit/pricing/test_calculator.py
```

- `--source upstream/main` takes the two files as they are on the team's
  `main`: the ORD-317 bug and Dan's `xfail` marker, both back.

```bash
git add src/novastack_orders/pricing/calculator.py tests/unit/pricing/test_calculator.py
```

- Stages the two files, by name.

```bash
git commit -m "chore: put ORD-317 back as the team has it, for Lecture 6"
```

- Records the two files as a new commit on your `main`.

```bash
git push
```

- An ordinary push: your fork's `main` gains one commit.

✅ **Checkpoint:** `uv run pytest` ends `217 passed, 1 xfailed` again.

⚠️ Never force-push (`git push --force` or `--force-with-lease`) a branch that
other people use, such as a team's `main`: it rewrites history under them.

---

## Part 2: Design From ADR 0004

Read `docs/adr/0004-test-tiers.md` and `.github/workflows/README.md`. Then
design the workflow **on paper** before you write any YAML. Answer:

1. **Which events?** "Every push" means a push to **any** branch, not just
   `main`. Pull requests are a second event.
2. **Which jobs?** One for the smoke tier, one for the full suite. What will
   you call them? (The names appear on every pull request.)
3. **How do you stop a plain push running the full suite?** A job can carry an
   `if:`, a condition GitHub checks before starting it. `github.event_name` is
   the event that started the run: `push` or `pull_request`.
4. **What does each job need?** The menu's `ci.yml` (Lecture 6, Step 3) is a
   good model: check out, set up uv, `uv sync --locked`, then the tier's
   pytest command.

💬 **Discuss:** a pull request **inside your fork** starts **two** runs: one
for the push to the branch, one for the pull request. With your design, which
jobs run in each, and which show as **skipped**? Is that a problem?

<details><summary>A design that works (open after you've drawn yours)</summary>

`on:` with `push:` (no branch filter) and `pull_request:`; top-level
`permissions: contents: read`; two jobs, each with the four steps above:

- `smoke`, with `if: github.event_name == 'push'`, running
  `uv run pytest -m smoke`;
- `full-suite`, with `if: github.event_name == 'pull_request'`, running
  `uv run pytest`.

A pull request then shows `smoke` from the push run and `full-suite` from the
pull-request run, plus one skipped job from each. Skipped jobs are harmless
here, but remember them if you later require checks in a ruleset: a skipped
job counts as passing.
</details>

---

## Part 3: Write It and Prove It

1. Make a branch, `add-ci`, and write `.github/workflows/ci.yml` from your
   design. Copy the step lines from the menu's `extras/ci.step3.yml` if you
   like (`actions/checkout@v7`, `astral-sh/setup-uv@v10.3.3`).
2. Update `.github/workflows/README.md` while you're there: it still says CI
   "arrives in Lecture 3".
3. Round the loop: add the two files **by name**, commit with
   `ci: smoke tier on every push, full suite on pull requests`, push, and open
   a pull request (⚠️ **base repository = your fork**: GitHub pre-selects
   `novastack-hq/novastack-orders`).

✅ **Checkpoint:** the pull request shows a green `smoke` check and a green
`full-suite` check. Open the `full-suite` log: the summary line ends with
`1 xfailed`, and the job is still green.

4. Merge, and come home (`git switch main`, `git pull`).

---

## Part 4: Fix ORD-317, Meet `XPASS(strict)`

Grace's bug from Lecture 3: the loyalty discount is applied **once per
category** instead of once on the promoted total. The fix moves it out of the
loop. (If you did Lecture 3's Demo 3, this is its Step 8.)

1. Make a branch, `fix-ord-317`.
2. In `src/novastack_orders/pricing/calculator.py`, in `calculate`, delete the
   comment `# Category subtotals and the loyalty discount in a single pass (ORD-301).`,
   delete the two loyalty lines **inside** the `for category, lines` loop, and
   add them back **after** the promotions loop:

```python
        for rule in self._promotions:
            if rule.applies(ctx):
                running = self._apply(rule, ctx, running, applied)

        # Loyalty applies once, to the whole promoted total (ORD-317).
        if self._loyalty.applies(ctx):
            running = self._apply(self._loyalty, ctx, running, applied)
```

- The first three lines are already there (the promotions, such as the meal
  deal). The new lines go straight after them, before the student discount.

3. **Leave Dan's marker alone for now.** Run the smoke tier:

```bash
uv run pytest -m smoke
```

- The bug is fixed, so Dan's test now **passes**, and the run fails. On the
  lecturer's laptop:

```text
........F.........                                                       [100%]
=================================== FAILURES ===================================
______________________ test_loyalty_discount_applied_once ______________________
[XPASS(strict)] ORD-317: remove when fixed
=========================== short test summary info ============================
FAILED tests/unit/pricing/test_calculator.py::test_loyalty_discount_applied_once
1 failed, 17 passed, 200 deselected in 0.16s
```

(The full suite says `1 failed, 217 passed`.) Write the word in square
brackets on line **O2**.

4. Commit **only** `calculator.py`, push, and open the pull request (⚠️ base
   repository = **your fork**: GitHub pre-selects
   `novastack-hq/novastack-orders`):

```bash
git add src/novastack_orders/pricing/calculator.py
```

- Stages the fix, by name. Dan's test file stays as it is.

```bash
git commit -m "fix: apply the loyalty discount once (ORD-317)"
```

- The fix alone, as its own commit.

```bash
git push -u origin fix-ord-317
```

- Sends the branch to your fork; open the pull request from the link it prints.


✅ **Checkpoint:** the pull request is **red**: `full-suite` fails, and so does
`smoke` (Dan's test is in the smoke tier too). The log shows the same
`[XPASS(strict)]` line as your laptop.

❓ **Check your understanding:** the code is now **right**, and the check is
red. Is the check wrong?

<details><summary>Answer</summary>

No: it's doing its job. `xfail(strict=True)` means "this test must fail
**until someone fixes ORD-317**". An unexpected pass (XPASS) is reported as a
failure, so the person who fixes the bug **has** to remove the marker. Without
`strict`, the test would show as `xpassed`, the run would stay green, and the
marker would stay forever: the test would never guard against the bug coming
back.
</details>

---

## Part 5: Make It Green, Merge

1. In `tests/unit/pricing/test_calculator.py`, delete the line
   `@pytest.mark.xfail(reason="ORD-317: remove when fixed", strict=True)`.
   **Keep the test** (and its `@pytest.mark.smoke`).
2. Run both tiers again. On the lecturer's laptop:

```text
..................                                                       [100%]
18 passed, 200 deselected in 0.15s
```

```text
218 passed in 0.29s
```

3. Commit the test file, push, watch the pull request go green, merge, and
   come home (`git switch main`, `git pull`):

```bash
git add tests/unit/pricing/test_calculator.py
```

- Stages the test file, by name.

```bash
git commit -m "test: ORD-317 is fixed, remove the xfail marker"
```

- The marker's removal, as a second commit.

```bash
git push
```

- The pull request picks up the commit and the checks run again.


✅ **Checkpoint:** the Actions tab of your Orders fork shows a red run
followed by a green one on `fix-ord-317`, and a green `smoke` run on `main`.

💬 **Discuss:** why two commits (fix, then marker) and not one? What does the
red run in between prove?

---

## Part 6: Explain, Then Check

1. In your **`novastack-menu`** folder, fill in `lab6/ADVANCED.md`: O1, O2, O3,
   and W1 to W3 in your own words.
2. Run the check from the `novastack-menu` folder, pointing it at your Orders
   clone:

```bash
uv run tools/check_lab6.py advanced --repo ../novastack-orders-ci
```

- `--repo` is the path to your Orders clone (here, a folder next to
  `novastack-menu`). PowerShell accepts the same `../` path.
- It reads your workflow files: the smoke tier on every push, the full suite on
  pull requests, and not the full suite on a plain push.
- **Hidden checks:** it copies your Orders `main` to a temporary folder, runs
  the full suite (it must pass with **nothing** xfailed), and adds two tests
  of its own: Grace's basket for a Silver **and** a Gold customer.
- With `gh` logged in, it also reads your Orders fork's run history and merged
  pull requests. Without `gh` those checks SKIP.

✅ **Checkpoint:** no FAIL lines.

<details><summary>Answers (after you've tried)</summary>

```yaml
# ADR 0004: the smoke tier on every push, the full suite on pull requests.
name: CI

on:
  push:
  pull_request:

permissions:
  contents: read

jobs:
  smoke:
    if: github.event_name == 'push'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - uses: astral-sh/setup-uv@v10.3.3
      - run: uv sync --locked
      - run: uv run pytest -m smoke

  full-suite:
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - uses: astral-sh/setup-uv@v10.3.3
      - run: uv sync --locked
      - run: uv run pytest
```

- O1 is `18` (17 passed and 1 xfailed). O2 is `XPASS(strict)`. O3 is `218`.
- Grace's basket (main, side, two drinks: £10.70, meal deal −£2.60 = £8.10):
  Silver 10% → **£7.29**; Gold 15% → **£6.88** (£1.215 rounds up to £1.22).
- W3: the integration tier is slower and touches SQLite; ADR 0004 runs it on
  pull requests to `main` and nightly. A nightly run is a `schedule:` event
  with a `cron:` time and `uv run pytest -m integration`.
</details>

---

## Part 7: Optional: Ship the Menu

Back in your **`novastack-menu`** fork: after the tests pass on `main`, a
second job builds Lecture 5's image and **publishes** it to GitHub's container
registry, `ghcr.io`, so Tom can `docker pull` it.

1. Read `extras/ci.step6.yml` ([Demo 3](../../demo/Lecture-6-Demo-3-From-Green-to-Shipped.md)
   explains it). Add its `publish` job to **your** `ci.yml` (if you did the
   Intermediate lab, keep your lint, matrix and pins, and pin this job's
   `actions/checkout` too).
2. Note `needs: test` (publish only after the tests pass), the `if:` (only for
   a push to `main`), and `permissions: packages: write` (this one job may
   write packages; everything else stays read-only).
3. Round the loop on a branch `ship-it`; merge; watch the `publish` job on
   `main`. Its summary says `Published ghcr.io/...`. (A fork's own token may
   publish to its owner's `ghcr.io`: we tried it.) If `docker push` is refused
   with a permission error, say so in the lab or on Moodle.
4. Find the package on your GitHub profile, **Packages** tab. It is **Public**:
   a package published by a public repository's workflow is linked to that
   repository and takes its visibility, so anyone can pull it. That's why
   the image must hold nothing secret.
5. Be Tom:

```bash
docker pull --platform linux/amd64 ghcr.io/<your-username>/novastack-menu:<first-7-characters-of-the-commit>
```

- The tag is the commit's short SHA, as the `publish` job printed it. Image
  names on `ghcr.io` are lower case.
- `--platform linux/amd64`: GitHub built the image for `amd64` only. On an
  Apple-silicon Mac a plain `docker pull` fails with `no matching manifest for
  linux/arm64/v8`; this asks for the `amd64` image, which Docker runs with
  emulation. On other laptops it changes nothing.

```bash
docker run -d --name shipped -p 8000:8000 --platform linux/amd64 ghcr.io/<your-username>/novastack-menu:<tag>; echo http://localhost:8000
```

- Runs the published box, as in Lecture 5; open the link, then
  `docker rm -f shipped`.

6. Write `PUBLISH: yes` in `lab6/ADVANCED.md`. The self-check then looks for
   the job and, with `gh`, for the package (it may ask you to run
   `gh auth refresh -s read:packages`).

---

## Going Further

- **The integration tier, nightly.** Add a third job on a `schedule:` event
  that runs `uv run pytest -m integration`. Why isn't a nightly run enough on
  its own?
- **Lint and types.** Orders already has Ruff and mypy in its dev group, and
  both pass today (`uv run ruff check .`, `uv run mypy`). Add them as jobs.
- **A gate for Orders.** A `protect-main` ruleset that requires
  `full-suite`. Then think about the skipped `full-suite` in push runs: does it
  matter here?
- **SHA pins** for Orders (the Intermediate lab, Part 5).
