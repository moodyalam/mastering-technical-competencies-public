# Lecture 6 · Exercise: ORD-384

**Mastering Computer Science Technical Competencies** · Lecture 6: Nobody Breaks It Again

**Time:** 10 minutes · **In pairs:** one **driver** (types), one **navigator**
(reads this sheet, suggests, watches). **Swap at the 5-minute mark.**

💡 This exercise is **Part 0 of each lab** (the warm-up). It practises exactly
what Step 3 of the lecture showed: a workflow file, a push, and a log to read.

---

## The Ticket

> **ORD-384: A robot for the tea-time tests** · P3 · area: platform
>
> Dan has written two tests for Lecture 5's tea-time special
> (`exercise/test_teatime.py`). Nobody runs them. Finish the workflow in
> `extras/exercise.blank.yml` (three blanks) so GitHub runs them **on every
> push**, push it, and get a **green tick** on the Actions tab.

You need your **`novastack-menu` fork** cloned, with **Actions switched on**
(the set-up guide, [Demo 0](../demo/Lecture-6-Demo-0-Setup.md), shows how). Open a terminal in the
**top folder** of your fork (the one with `app.py`), not in `exercise/`.

---

## Two ideas first

- **A workflow** is a file in `.github/workflows/` that tells GitHub: *when
  this happens* (`on:`), *start this machine* (`runs-on:`), and *run these
  steps* (`steps:`). Each `- run:` line is a command, as if you typed it.
- **The machine starts empty.** It has Linux and common tools, but not your
  code (that's what `actions/checkout` copies in) and not your packages. Sound
  familiar? It's Lecture 5's box again.

---

## Steps

| Minutes | Do this | ✅ You're done when |
|---|---|---|
| **0–3** | Make a branch, copy the blank file into `.github/workflows/`, and replace the three `____` using the comments (**BLANK 1, 2, 3**). | No `____` left after a colon |
| **3–5** | Commit the file and push the branch. Open your fork's **Actions** tab. | A run called **Exercise** appears |
| **5–7** | Watch it finish. Green? **Or red?** (Red is the point: carry on.) Click the run, then the job, then the red step, and read the **last lines** of its log. | You've found the line that says what's missing |
| **7–10** | Fix the workflow with **one new line**, commit, push, and watch again. | A green tick |

To copy:

```bash
git switch -c exercise-384
```

- `git switch -c exercise-384` makes a new branch and moves you onto it, so
  the exercise stays off `main`.

macOS and Linux:

```bash
mkdir -p .github/workflows
```

- Makes the folder GitHub looks in. `-p` means "and don't complain if it's
  already there".

```bash
cp extras/exercise.blank.yml .github/workflows/exercise.yml
```

- Copies the unfinished file to where GitHub will find it.

Windows (PowerShell):

```powershell
New-Item -ItemType Directory -Force .github/workflows
```

- The PowerShell way to make the folder (`-Force`: fine if it exists).

```powershell
Copy-Item extras/exercise.blank.yml .github/workflows/exercise.yml
```

- The PowerShell way to copy the file.

⚠️ **Fill in all three blanks before you commit.** GitHub can't read
`on: ____`, so a half-finished file gives a *workflow error* (the file is
wrong), not a red run (the tests are wrong). Those are different problems.

When the blanks are done:

```bash
git add .github/workflows/exercise.yml
```

- Stages **just this file**. Name the file; don't use `git add .`

```bash
git commit -m "ci: run the tea-time tests (ORD-384)"
```

- Saves the change on your branch, with a message saying why.

```bash
git push -u origin exercise-384
```

- Sends the branch to **your fork** (`origin`). `-u` remembers the link, so
  next time `git push` is enough. The `push` is what starts the workflow.

💡 **Windows (PowerShell):** the three `git` commands work as written.

💡 The **driver** types; the **navigator** has the Actions tab open and reads
the log out loud. Swap at 5 minutes.

---

## Check Your Understanding

❓ `python -m pytest exercise` passes on your laptop. On GitHub the very same
command fails. Which of you is wrong?

<details><summary>Answer</summary>

Neither. Your laptop already has Flask (you installed it for the menu
service). GitHub's machine **starts empty**: the workflow installs Python and
`pytest`, and nothing else. Near the end, the log says
`E   ModuleNotFoundError: No module named 'flask'`, the same error as Lecture 5's
first box. The test file imports `app`, and `app.py` imports Flask.
</details>

**The one sentence you should be able to say:** *"GitHub's machine starts
empty, like the box did, so the workflow has to install everything the tests
import, not just the test tool."*

---

## Finished Early?

- Open `extras/ci.step3.yml` (the lecture's workflow). Which **one line** in
  it does the job of your fix, and why doesn't it need a `requirements.txt`?
- Add `pull_request:` as a second trigger. Open a pull request **inside your
  fork** from `exercise-384` and count the runs you get. Why two?
  ⚠️ On a fork GitHub pre-selects `novastack-hq/novastack-menu` as the **base
  repository**: change it to **your own fork** before you click **Create pull
  request**.

<details><summary>Answers to the three blanks and the fix (for after the exercise)</summary>

```yaml
on: push
```

```yaml
    runs-on: ubuntu-latest
```

```yaml
      - run: python -m pytest exercise
```

The fix is one line, **before** the pytest step:

```yaml
      - run: python -m pip install -r exercise/requirements.txt
```

The finished steps read: check out, set up Python 3.12, install pytest,
install the app's requirements (Flask), run the tests. Two tests pass.

Stretch answers: in `ci.step3.yml`, `uv sync --locked` installs everything in
`uv.lock` (Flask **and** pytest), so no separate install is needed. With
`pull_request:` added, a pull request gets one run for the **push** to the
branch and one for the **pull request** itself.
</details>
