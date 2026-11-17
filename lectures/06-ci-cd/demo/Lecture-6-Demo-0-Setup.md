# Lecture 6 · Demo 0: Get Ready for the Gate

**Mastering Computer Science Technical Competencies** · Lecture 6: Nobody Breaks It Again

---

## About This Guide

**Do this before the lecture.** It takes about 20 minutes. There's no time to set
up during the lecture. At the end, your fork of the NovaStack menu service is up
to date, Dan's tests run on your laptop, you know you can push, and GitHub is
allowed to run workflows in your fork.

| Step | Title | Time |
|---|---|---|
| 1 | Bring your fork up to date | 5 min |
| 2 | Run Dan's tests | 4 min |
| 3 | Check that you can push | 4 min |
| 4 | Switch on Actions in your fork | 2 min |
| 5 | The GitHub CLI (optional) | 4 min |
| 6 | Know where your pull requests go | 2 min |
| 7 | If you can't work on your laptop: Codespaces | 5 min |
| 8 | If something goes wrong | as needed |

| Icon | Meaning |
|---|---|
| ✅ | **Checkpoint:** what you should see if everything worked |
| ❓ | **Check your understanding:** click *Answer* to reveal it |
| ⚠️ | **Warning:** something that can go wrong |
| 💡 | **Tip:** a useful extra |

Commands are written for macOS and Linux; **PowerShell** equivalents are given
where they differ. On Windows, use **PowerShell**, not Git Bash.

<details><summary><strong>New here? You didn't do Lecture 5 (fork and clone first)</strong></summary>

You need **Git**, **uv** (as in Lecture 3,
[docs.astral.sh/uv](https://docs.astral.sh/uv/getting-started/installation/)),
**VS Code** and a free **GitHub** account. You don't need Docker for this guide.

A **fork** is your own copy of someone else's repository, on GitHub. You can
change your fork freely; the original is untouched. A **clone** is a copy of a
repository on your laptop, linked to the one on GitHub.

1. Go to **[github.com/novastack-hq/novastack-menu](https://github.com/novastack-hq/novastack-menu)**
   and click **Fork**. Leave **Copy the `main` branch only** ticked, then click
   **Create fork**.
2. Clone **your fork** (not `novastack-hq`'s) and open it in VS Code:

```bash
git clone https://github.com/<your-username>/novastack-menu.git
```

- `git clone` copies the repository from GitHub to a new folder on your laptop.
- Replace `<your-username>` with your GitHub username.

```bash
cd novastack-menu
```

- Moves into the new folder.

```bash
code .
```

- Opens the current folder (`.`) in VS Code (set up in Lecture 3).

A fork made today is already up to date, so in Step 1 you can skip Goal 1.1 and
go straight to Goal 1.3.

</details>

---

## Step 1: Bring Your Fork Up to Date

Since Lecture 5, NovaStack has added new files to the menu service: Dan's tests,
saved workflow files and the Lecture 6 labs. **Your fork doesn't get them by
itself.** A fork is a copy taken at one moment; it doesn't follow the original.

Two names to know first:

| Name | What it is |
|---|---|
| **`origin`** | Your fork on GitHub. `git clone` gave it this name. You push here. |
| **`upstream`** | The original, `novastack-hq/novastack-menu`. You only read from it. |

Updating means: bring `upstream`'s new commits into your fork, then into your
laptop's copy. There's a button for the first half, and a command-line way that
does both.

⚠️ **If you changed files on `main` in Lecture 5's labs**, run `git status` in
your `novastack-menu` folder first. Files listed as *untracked* (such as a
`Dockerfile` or `.env` you made) are fine: Git leaves them alone. Files listed as
*modified* may get in the way: if you want to keep them, ask in the lecture
or on Moodle; if you don't, undo them with `git restore <file>`.

### Goal 1.1: The Sync fork button

1. Open **your fork** on GitHub (`github.com/<your-username>/novastack-menu`).
2. Above the list of files, GitHub says something like *This branch is 1 commit
   behind novastack-hq/novastack-menu:main*.
3. Click **Sync fork**, then **Update branch**.

✅ **Checkpoint:** GitHub now says *This branch is up to date with
novastack-hq/novastack-menu:main*, and the file list shows a `tests` folder.

### Goal 1.2: The command-line way (instead of Goal 1.1)

Skip this if you used the button. It's here because it works for every Git host,
not just GitHub, and because the labs use the `upstream` name. Run these in your
`novastack-menu` folder (in VS Code: **Terminal** → **New Terminal**).

```bash
git remote -v
```

- `git remote` lists the **remotes**: the other copies of this repository that
  your clone knows about. `-v` (verbose) shows their addresses.
- You'll see `origin` twice (once for fetch, once for push), pointing at your fork.

```bash
git remote add upstream https://github.com/novastack-hq/novastack-menu.git
```

- `git remote add` gives a name to another copy of the repository.
- `upstream` is the name; the address is the original repository.
- If it says `error: remote upstream already exists`, you added it before: carry on.

```bash
git fetch upstream
```

- `git fetch` downloads the new commits from `upstream` but **doesn't change
  your files**. They're stored as `upstream/main`.

```bash
git switch main
```

- Makes sure you're on your own `main` branch.

```bash
git merge upstream/main
```

- `git merge` brings the commits from `upstream/main` into your `main`. As you
  haven't committed anything new to `main`, Git just moves `main` forward and
  says `Fast-forward`.

```bash
git push
```

- Sends your updated `main` to `origin`, your fork on GitHub.

✅ **Checkpoint:** your fork's page on GitHub says it is up to date with
`novastack-hq/novastack-menu:main`.

### Goal 1.3: Pull the new files to your laptop

If you used the button in Goal 1.1 (or forked today), your fork on GitHub has
the new files but your laptop doesn't yet.

```bash
git switch main
```

- Makes sure you're on `main`.

```bash
git pull
```

- `git pull` = `git fetch` (download the new commits from `origin`) followed by
  `git merge` (bring them into the branch you're on).
- After Goal 1.2 it says `Already up to date.`: that's fine.

✅ **Checkpoint:** in VS Code's Explorer you can see `tests/test_menu.py`,
`requirements-dev.txt`, and `extras/ci.step3.yml`. There is **no**
`.github/workflows` folder: you'll write the workflow yourself in the lecture.

❓ **Check your understanding:** you clicked **Sync fork** on GitHub. Why don't
you see `tests/test_menu.py` in VS Code yet?

<details><summary>Answer</summary>

**Sync fork** updated your fork **on GitHub** (`origin`). Your laptop has a
separate copy, and Git never changes it behind your back. `git pull` brings
`origin`'s new commits down to your laptop.
</details>

---

## Step 2: Run Dan's Tests

The new `tests/test_menu.py` holds five **tests**: small programs that check the
menu service does what it promises. **pytest** is the Python tool that finds and
runs them. It's a **development dependency**: needed by people working on the
code, not by the running service, so it's listed separately in `pyproject.toml`
(a `dev` group) and in `requirements-dev.txt` (for pip).

```bash
uv sync
```

- `uv sync` reads `pyproject.toml` and `uv.lock` and makes `.venv` match them:
  Python 3.12, Flask, and now pytest too. uv installs the `dev` group by default.
- It changes only `.venv`, a folder for this project. Nothing is installed into
  your main Python.

```bash
uv run pytest
```

- `uv run` runs a command with the Python in `.venv`.
- `pytest` finds the files in `tests/` whose names start with `test_`, runs
  every function in them whose name starts with `test_`, and reports.

✅ **Checkpoint:** the last line says `5 passed` (the time will differ):

```text
tests/test_menu.py .....                                                 [100%]

============================== 5 passed in 0.22s ===============================
```

Each `.` is one test that passed. You'll read this properly in Step 1 of the
lecture.

**Without uv (pip):** make a virtual environment, install with its pip, and run
pytest with its Python.

```bash
python -m venv .venv
```

- Creates the `.venv` folder: a private Python for this project.
- On macOS and Linux you may need `python3` instead of `python`.

```bash
.venv/bin/python -m pip install -r requirements-dev.txt
```

- `.venv/bin/python` is the Python inside `.venv`.
- `-m pip install -r requirements-dev.txt` installs every package listed in the
  file; its first line, `-r requirements.txt`, pulls in Flask as well, then it adds pytest.

PowerShell:

```powershell
.venv\Scripts\python -m pip install -r requirements-dev.txt
```

- The same, with the Windows path to `.venv`'s Python.

```bash
.venv/bin/python -m pytest
```

- Runs pytest with `.venv`'s Python.

PowerShell:

```powershell
.venv\Scripts\python -m pytest
```

- The same, with the Windows path to `.venv`'s Python.

❓ **Check your understanding:** the menu service runs fine without pytest. Why
is pytest in `uv.lock` at all?

<details><summary>Answer</summary>

So that **everyone gets the same pytest**: you, your team, and (from Step 3 of the
lecture) the machine GitHub uses to run the tests. A lock file pins every
package to an exact version, so a test can't pass on one laptop and fail on
another because of a different tool version.
</details>

---

## Step 3: Check That You Can Push

In the lecture you'll **push** (send your commits to your fork on GitHub) four
times. If pushing doesn't work, you're stuck at the first one. Check it now,
with a **throw-away branch**: a branch you make only to delete again.

```bash
git switch -c push-test
```

- `git switch` moves you to another branch; `-c` creates it first.
- `push-test` is its name. It starts as an exact copy of `main`.

```bash
git push -u origin push-test
```

- `git push` sends a branch to GitHub.
- `origin` is where to (your fork); `push-test` is which branch.
- `-u` remembers that link, so later a plain `git push` on this branch is enough.

✅ **Checkpoint:** the output ends with lines like

```text
remote: Create a pull request for 'push-test' on GitHub by visiting:
remote:      https://github.com/<your-username>/novastack-menu/pull/new/push-test
...
 * [new branch]      push-test -> push-test
branch 'push-test' set up to track 'origin/push-test'.
```

Now tidy up: delete the branch on GitHub and on your laptop.

```bash
git push origin --delete push-test
```

- Deletes the branch `push-test` from `origin` (your fork on GitHub).

```bash
git switch main
```

- Back to `main` (you can't delete the branch you're on).

```bash
git branch -d push-test
```

- `git branch -d` deletes a branch on your laptop. `-d` refuses if the branch has
  work that isn't merged anywhere; this one has none.

### If the push failed

**HTTPS asks for a username and password, then says `Authentication failed`.**
GitHub stopped accepting account passwords for Git in 2021. You need a
**credential helper**: a small program that signs you in through your browser
once and remembers it.

- **Windows:** Git for Windows includes **Git Credential Manager**. Push again
  and choose **Sign in with your browser** in the window that opens. If no
  window opens, reinstall Git for Windows with the default options.
- **macOS:** Git stores the sign-in in the Keychain, but it still needs a token
  the first time. The easiest way is the GitHub CLI (Step 5): run
  `gh auth login`, choose **GitHub.com**, **HTTPS**, and **Yes** to
  *Authenticate Git with your GitHub credentials*, then push again.
- **Linux:** the same `gh auth login` route as macOS.

**SSH says `Permission denied (publickey)`.** Your clone uses an SSH address
(`git@github.com:...`) but your laptop has no SSH key that GitHub knows. Either
follow GitHub's guide [Connecting to GitHub with SSH](https://docs.github.com/en/authentication/connecting-to-github-with-ssh),
or switch this clone to HTTPS and use the credential helper above:

```bash
git remote set-url origin https://github.com/<your-username>/novastack-menu.git
```

- `git remote set-url` changes the address that the name `origin` points to.
- Replace `<your-username>` with your GitHub username.

⚠️ **Never** paste a GitHub token or password into a chat, an AI prompt, or a
file you commit.

---

## Step 4: Switch On Actions in Your Fork

**GitHub Actions** runs commands on GitHub's own machines when something
happens in your repository, such as a push or a pull request. The instructions
live in files in `.github/workflows/`. In the lecture you'll write one that runs
Dan's tests on every change. Today, you just give GitHub permission.

⚠️ **Forks of a repository that has workflows start with Actions switched off.** A fork copies someone else's
workflow files, and GitHub won't run code you haven't looked at, on its
machines and with access to your repository, until you say so. If you skip this
step, your workflow in the lecture will simply **never run**: no green tick, no
red cross, no error message.

1. Open your fork on GitHub and click the **Actions** tab.
2. **Most likely** you see a page of suggested workflows, headed **Get started
   with GitHub Actions**. `novastack-menu` has no workflow files yet, so GitHub
   has nothing to switch off: Actions is already on, and there's nothing to do.
3. If instead you see a message that workflows aren't being run on this fork,
   click the green button that enables them (its wording is along the lines of
   *I understand my workflows, go ahead and enable them*).

💡 The switch lives in **Settings** → **Actions** → **General** → **Actions
permissions**. Choose **Allow all actions and reusable workflows** if it shows
**Disable actions**.

✅ **Checkpoint:** the **Actions** tab no longer shows a message about workflows
being switched off.

---

## Step 5: The GitHub CLI (Optional)

**`gh`** is GitHub's command-line tool. Everything in the lecture can be done on
the GitHub web site, but `gh` makes pull requests and checks quicker, and some
lab self-checks use it to look at your fork (without it, those checks say
**SKIP**).

Install it:

```bash
brew install gh
```

- macOS, with Homebrew.

```powershell
winget install --id GitHub.cli
```

- Windows, in PowerShell. Open a **new** PowerShell afterwards so it finds `gh`.

On Linux, follow [cli.github.com](https://cli.github.com/) for your distribution.

```bash
gh auth login
```

- Signs `gh` in to GitHub through your browser. Choose **GitHub.com**,
  **HTTPS**, and **Yes** to *Authenticate Git with your GitHub credentials*:
  that also fixes HTTPS pushing (Step 3).

Now the important part. Your clone knows two repositories, `origin` (your fork)
and `upstream` (the original). `gh` has to pick one for pull requests and
checks, and in a fork it may pick the **original**. Tell it to use yours:

```bash
gh repo set-default <your-username>/novastack-menu
```

- `gh repo set-default` chooses the repository `gh` works on from this folder.
- Replace `<your-username>` with your GitHub username.

```bash
gh repo set-default --view
```

- Shows which repository is the default.

✅ **Checkpoint:** it prints `<your-username>/novastack-menu`, not
`novastack-hq/novastack-menu`.

---

## Step 6: Know Where Your Pull Requests Go

A **pull request** asks "please merge my branch into this one". It has a
**base** (where the change should go) and a **compare** branch (your change).
In this course, every pull request goes **inside your own fork**: from your
branch into **your** `main`.

⚠️ **On a fork, GitHub pre-selects the wrong base.** When you open a pull request
in a fork, GitHub assumes you want to send your change back to the original, so
the top of the *Open a pull request* page says:

```text
base repository: novastack-hq/novastack-menu   base: main   ←   head repository: <your-username>/novastack-menu   compare: your-branch
```

Every time, before you click **Create pull request**:

1. Click **base repository: novastack-hq/novastack-menu**.
2. Choose **`<your-username>/novastack-menu`** (your fork).
3. The page reloads and shows just **base: `main`** ← **compare: `your-branch`**.
   That's right: both branches are in your fork.

`novastack-hq` only accepts pull requests from its own team, so if you forget,
GitHub won't let the pull request through. Fix the base and try again.

---

## Step 7: If You Can't Work on Your Laptop: Codespaces

Some laptops (locked-down university or work machines) can't install uv or push
with Git. **GitHub Codespaces** gives you a Linux machine in the cloud, in a
browser tab or in VS Code, already signed in to GitHub, so pushing just works.

1. Do Step 1, Goal 1.1 (the **Sync fork** button) and Step 4 (Actions) on
   GitHub first.
2. On your fork's page, click the green **Code** button → **Codespaces** tab →
   **Create codespace on main**.
3. Wait for it to start, then open a terminal (**Terminal** → **New Terminal**).

The codespace has Git and Docker but not uv. Install uv in it (this is Linux, so
use the Linux installer):

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

- `curl -LsSf` downloads uv's official install script quietly, following
  redirects and stopping on errors.
- `| sh` runs it. It puts `uv` in `~/.local/bin`.

Open a **new** terminal so it finds `uv`, then run Step 2 (`uv sync`,
`uv run pytest`) as on a laptop. If the uv installer doesn't work in your
codespace, use the pip route from Step 2 instead.
<!-- Not rehearsed in a codespace (11 Nov 2026: Codespaces quota). The pip route is the safe fallback. -->


⚠️ **Quota:** GitHub Free gives **120 hours per month** of Codespaces, and a
verified student account gives **180**. A 2-core machine counts double, so you
get about **half as many real hours**. Stop the codespace when you've finished
(**Codespaces** → ⋯ → **Stop**).

---

## Step 8: If Something Goes Wrong

| What you see | Why, and what to do |
|---|---|
| `uv: command not found` / `'uv' is not recognized` | Install uv as in Lecture 3 ([docs.astral.sh/uv](https://docs.astral.sh/uv/getting-started/installation/)) and open a **new** terminal, or use the pip route in Step 2. |
| `error: Failed to spawn: pytest`, or pytest says `no tests ran` | Your laptop doesn't have the new files yet: do Step 1, Goal 1.3 (`git pull`), and check you're in the `novastack-menu` folder. |
| `ModuleNotFoundError: No module named 'flask'` (pip route) | You ran the system's Python, not `.venv`'s. Use `.venv/bin/python -m pytest` (Windows: `.venv\Scripts\python -m pytest`). |
| `error: Your local changes to the following files would be overwritten by merge` | You changed a file on `main` that the update also changes. See the ⚠️ at the start of Step 1. |
| `fatal: not a git repository` | You're not in the `novastack-menu` folder. `cd` into it. |
| `Authentication failed` or `Permission denied (publickey)` | See Step 3, *If the push failed*. |
| `! [rejected] main -> main (fetch first)` | Your fork has commits your laptop hasn't. Run `git pull`, then push again. |
| The **Sync fork** button says *This branch is ahead of* | You committed to `main` in your fork. Ask in the lecture; don't discard anything. |

Still stuck? Bring the output of `git remote -v` and `git status` to the start of
the lecture and ask.

---

## Before the Lecture: Checklist

- [ ] My fork on GitHub says it is up to date with `novastack-hq/novastack-menu:main`.
- [ ] `git pull` on `main` says `Already up to date.`
- [ ] `uv run pytest` (or the pip route) says `5 passed`.
- [ ] I pushed a throw-away branch, and then deleted it.
- [ ] The **Actions** tab of my fork doesn't say workflows are switched off.
- [ ] I know to change **base repository** to my own fork when I open a pull request.
- [ ] Optional: `gh repo set-default --view` prints my own fork.

---

## Try It Yourself

1. Run `git log --oneline -5`. Which commit brought in Dan's tests? Who made it?
2. Run `git branch -a`. What's the difference between `main`, `remotes/origin/main`
   and `remotes/upstream/main` (if you did Goal 1.2)?
3. Open `tests/test_menu.py`. Without running anything, which of the five tests
   would fail if someone gave two menu items the same `sku`?

<details><summary>Answers</summary>

1. The newest commits are at the top. The message and author of the one that
   added `tests/` are there; `git show --stat <hash>` lists the files it added.
2. `main` is your branch on your laptop. `remotes/origin/main` is Git's memory of
   `main` on your fork, as of your last fetch or pull. `remotes/upstream/main` is
   its memory of the original's `main`. Only the first one changes when you commit.
3. `test_skus_are_unique`: it compares the number of SKUs with the number of
   *different* SKUs. A repeated SKU makes the second number smaller.
</details>

---

## Next

[Demo 1: Tests and the Loop](Lecture-6-Demo-1-Tests-and-the-Loop.md): read Dan's
promises, watch one break, then write the promise that would have caught £4.5O.
