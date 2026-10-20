# Lecture 3 · Demo 0: Set Up Your Laptop

**Mastering Computer Science Technical Competencies** · Lecture 3: The Monday After the 3 AM Page

---

## About This Guide

**Do this before the lecture.** It takes about 30 minutes, most of it
downloads. In the lecture we'll work on NovaStack's real ordering code, and
there won't be time to set up then. At the end, your laptop is set up the way NovaStack's developers set
theirs up, on Windows, macOS or Linux:

- **VS Code** with the team's extensions;
- **uv**, **Python 3.12** and the project's exact tool versions;
- an **SSH key** that lets Git talk to GitHub securely, without passwords;
- your own **fork** of the team's repository, cloned and ready.

You install VS Code and Git yourself, then **one script** does the rest. It
explains every step before it runs it and asks before it changes anything
outside the project folder.

| Step | Title | Time |
|---|---|---|
| 1 | Install VS Code and Git | 10 min |
| 2 | Get the GitHub accounts ready | 5 min |
| 3 | Fork the team's repository | 2 min |
| 4 | Clone your fork and run the set-up script | 10 min |
| 5 | Open the project in VS Code | 3 min |
| 6 | If something goes wrong | as needed |

| Icon | Meaning |
|---|---|
| ✅ | **Checkpoint:** what you should see if everything worked |
| ❓ | **Check your understanding:** click *Answer* to reveal it |
| ⚠️ | **Warning:** something that can go wrong |
| 💡 | **Tip:** a useful extra |

---

## Step 1: Install VS Code and Git

### Goal 1.1: Install VS Code

Download it from [code.visualstudio.com](https://code.visualstudio.com/) and install it.

- **Windows:** in the installer, tick **"Add to PATH"** and **"Add 'Open with Code' action"**.
- **macOS:** drag VS Code into **Applications**. Then open it, press `Cmd+Shift+P`,
  type **`shell command`** and choose **Shell Command: Install 'code' command in PATH**.
- **Linux:** use the `.deb` or `.rpm` package from the download page, or your
  distribution's package manager.

✅ **Checkpoint:** in a **new** terminal, `code --version` prints a version number.

### Goal 1.2: Install Git

- **Windows:** install **Git for Windows** from [git-scm.com/downloads](https://git-scm.com/downloads). Accept the defaults.
- **macOS:** run this in Terminal. If Git isn't installed, macOS offers to
  install the Command Line Tools: accept.

  ```bash
  git --version
  ```
- **Linux:** `sudo apt install git` (Debian/Ubuntu) or `sudo dnf install git` (Fedora).

✅ **Checkpoint:** `git --version` prints `git version 2.34` or newer.

### Goal 1.3 (optional): Install hyperfine

In the profiling part of the lecture we compare two versions of a program with
**hyperfine**, a benchmarking tool. You only need it to repeat that step yourself.

- **macOS:** `brew install hyperfine` (needs [Homebrew](https://brew.sh/))
- **Windows:** `winget install hyperfine`
- **Linux:** `sudo apt install hyperfine` (Debian/Ubuntu) or `sudo dnf install hyperfine` (Fedora)

💡 No luck? Skip it: Python's built-in `timeit` does a similar job, and the
profilers we use are installed by the set-up script.

---

## Step 2: Get the GitHub Accounts Ready

You created a GitHub account in Lecture 1.

1. **Apply for GitHub Education** at [education.github.com/students](https://education.github.com/students)
   with your university email. Verified students get the **Copilot Student**
   plan free. Verification can take a few days, so do it now.
2. Until it's approved, you can use **Copilot Free**, which needs no
   application and no card.

💡 GitHub changed its Copilot plans several times in 2026. The details are on
[GitHub's student page](https://docs.github.com/en/copilot/how-tos/copilot-on-github/set-up-copilot/enable-copilot/set-up-for-students).

---

## Step 3: Fork the Team's Repository

A **fork** is your own copy of a repository on GitHub. You can push to it; you
can't push to the team's original.

1. Go to **[github.com/novastack-hq/novastack-orders](https://github.com/novastack-hq/novastack-orders)**.
2. Click **Fork** (top right).
3. ⚠️ **Untick "Copy the `main` branch only".** The exercise and labs start from
   other branches, and they're only copied if this box is unticked. (If you
   forget, the set-up script can copy them for you.)
4. Click **Create fork**.

✅ **Checkpoint:** you're on `github.com/<your-username>/novastack-orders`, and
the branch menu lists `exercise/ORD-318` and the other course branches, not just `main`.

❓ **Check your understanding:** why fork instead of using "Use this template"?

<details><summary>Answer</summary>

A fork keeps the repository's full **history** and **branches**. You'll use
the history to find out who changed what and why (GitLens blame), and the
branches as starting points for the exercise and labs. A template copy starts
again with a single commit and only one branch.
</details>

---

## Step 4: Clone Your Fork and Run the Set-Up Script

### Goal 4.1: Clone your fork

Open a terminal (Windows: **PowerShell**; macOS: **Terminal**; Linux: your
terminal) and go to the folder where you keep your code, then:

```bash
git clone https://github.com/<your-username>/novastack-orders.git
cd novastack-orders
```

Replace `<your-username>` with your GitHub username.

⚠️ If Git says `repository not found`, your fork doesn't exist yet (Step 3), or
the username is misspelled. Check that
`github.com/<your-username>/novastack-orders` opens in your browser first.

💡 We clone over **HTTPS** this once, because your fork is public and you don't
have an SSH key yet. The script switches it to SSH at the end.

### Goal 4.2: Run the set-up script

macOS / Linux:

```bash
./scripts/setup.sh
```

Windows (PowerShell):

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\setup.ps1
```

💡 Want to see what it would do first? Add `--dry-run`: it shows every step
without changing anything.

The script works through nine steps. Here's what to expect:

| Step | What happens | What you do |
|---|---|---|
| 1. Git | Checks Git; sets your name and email for commits if they're missing | Type your name, and the email on your GitHub account |
| 2. uv sync | Installs uv (if needed), Python 3.12 and the project's tools into `.venv` | Wait |
| 3. SSH key | Uses your existing `id_ed25519` key, or creates one | **Choose a passphrase** (you won't see it as you type) |
| 4. SSH agent | Loads the key so you type the passphrase once. **Windows:** a Windows prompt asks for permission to start the SSH agent service | Approve the prompt; type your passphrase |
| 5. GitHub | Copies your **public** key and opens GitHub's "Add SSH key" page | Title: your laptop's name. Key type: **Authentication Key**. Paste. **Add SSH key**. Press Enter in the terminal |
| 6. Test | Connects to GitHub over SSH; if your network blocks port 22, tries port 443 and offers to remember that | Answer `y` if asked |
| 7. Remotes | Points your clone at your fork over SSH; adds the team's repo as `upstream`; fetches the branches | Answer `y` if it offers to copy missing branches |
| 8. Extensions | Installs the VS Code extensions the team uses | Wait |
| 9. Check | Runs `tools/check_setup.py` | Read the results |

✅ **Checkpoint:** the script ends with every line `[PASS]` (a `[WARN]` about
the `code` command is fine) and **All done.**

❓ **Check your understanding:** the script created two files, `id_ed25519`
and `id_ed25519.pub`. Which one did you paste into GitHub, and which must never
leave your laptop?

<details><summary>Answer</summary>

You pasted the **public** key, `id_ed25519.pub`. Anyone can see it; it only
lets GitHub recognise you. `id_ed25519` is the **private** key: never share
it, never commit it, and never paste it into an AI chat. If a laptop is lost,
delete its key from GitHub's settings.
</details>

---

## Step 5: Open the Project in VS Code

1. In the `novastack-orders` folder, run this (or use **File > Open Folder…** and choose `novastack-orders`):

   ```bash
   code .
   ```

   ⚠️ **Open the project folder itself**, the one that contains `pyproject.toml`
   and `.vscode/`, not a folder above it. VS Code only reads the team's
   `.vscode/settings.json` and `.vscode/extensions.json` from the top folder you
   open. If you open a parent folder, you get no recommended extensions, none of
   the team's settings, and a lot of red squiggles. Check: the title bar and the top
   of the Explorer should say `novastack-orders`.

2. If VS Code asks **"Do you trust the authors of the files in this folder?"**,
   choose **Yes, I trust the authors**: this is your own fork.
3. If it offers to **install the recommended extensions**, click **Install**.
4. Open any `.py` file (e.g. `src/novastack_orders/cli.py`), then look at the
   **bottom-right of the status bar**: it should show a Python version with
   **`.venv`**. (The Python version only appears while a Python file is open.) If it doesn't, press `Ctrl+Shift+P` · `Cmd+Shift+P`,
   run **Python: Select Interpreter** and choose the one in `.venv`.
   💡 If Pylance asks you to **choose a type-checking mode**, pick **Standard**.
   (The team's `.vscode/settings.json` sets `standard` anyway, and workspace
   settings override yours.) *Strict* flags every value it can't fully type,
   which buries the real problems in red.
5. Click the **beaker icon** (Testing) in the left bar.
6. **Sign in to GitHub Copilot:** click the Copilot icon in the title bar (or
   the Chat view) and sign in with your GitHub account.

✅ **Checkpoint:** the Testing panel shows a tree of tests under `tests/`, and
the status bar shows the `.venv` interpreter.

💡 Run the checks again any time:

```bash
uv run tools/check_setup.py
```

---

## Step 6: If Something Goes Wrong

Run the script again: it's safe to re-run, and it skips what's already done.
If it still fails, find your problem below, or bring `setup-report.txt` to the
set-up clinic.

| Problem | Most likely on | Fix |
|---|---|---|
| `Permission denied` running `./scripts/setup.sh` | macOS / Linux | Run it with bash instead: `bash scripts/setup.sh` |
| `running scripts is disabled on this system` | Windows | Use exactly the command above: `powershell -ExecutionPolicy Bypass -File .\scripts\setup.ps1` |
| `uv: command not found` after it installed | All | Close the terminal, open a new one, run the script again |
| `Permission denied (publickey)` | All | The key isn't on GitHub yet: re-run, and add it in step 5. Check [github.com/settings/keys](https://github.com/settings/keys) |
| SSH hangs, or `Connection timed out` | Campus or public Wi-Fi | Port 22 is blocked: the script's port-443 option fixes it (step 6). See [GitHub's guide](https://docs.github.com/en/authentication/troubleshooting-ssh/using-ssh-over-the-https-port) |
| Git still asks for your passphrase every time | Windows | Re-run and accept "Tell Git to use Windows' OpenSSH" |
| `Course branches: missing ...` | All | You forked with "main only". Re-run and accept "Copy them from upstream" |
| Testing panel empty, or `Import could not be resolved` | All | Wrong interpreter: **Python: Select Interpreter** → `.venv` |
| `code` not found | macOS | VS Code: `Cmd+Shift+P` → **Shell Command: Install 'code' command in PATH** |
| You're on Windows and use **WSL** | Windows | Pick one side: WSL and Windows have separate `~/.ssh` folders. Run the macOS/Linux command inside WSL if you work there |

Commands from the table, to copy:

```bash
bash scripts/setup.sh
```

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\setup.ps1
```

### Setting up by hand instead

If you'd rather not run a script, follow
[docs/onboarding.md](https://github.com/novastack-hq/novastack-orders/blob/main/docs/onboarding.md#setting-up-by-hand)
in the repository. It lists each step, with pip equivalents for every uv command.

### Optional: the Dev Container

The repository also includes a **Dev Container**: the same tools inside Docker.
We'll show it briefly in the lecture, and it's a fallback if Python won't
install on your laptop: open the folder in VS Code and choose **Dev Containers:
Reopen in Container** (Docker Desktop must be running). It does **not** fix SSH
problems, because your key stays on your laptop.
