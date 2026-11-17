# Lecture 1 · Demo 0: Setting Up Your Lab Environment

**Mastering Computer Science Technical Competencies** · Lecture 1: Introduction to the Command Line

---

## About This Guide

Before we can investigate the 3 AM incident, we need a safe place to work. In this guide, we'll set up that place **once**. Every demo in this lecture, and the lab afterwards, uses the environment you build here.

| Guide | What it covers |
|---|---|
| **Demo 0 (this guide)** | Setting up Docker, the incident files and the AI agent |
| [Demo 1](Lecture-1-Demo-1-Script-AI-Plan.md) | One prompt to an AI agent in **plan mode** |
| [Demo 2](Lecture-1-Demo-2-Script-Linux-CLI.md) | Solving the incident with classic CLI commands, by hand |
| [Demo 3](Lecture-1-Demo-3-Script-AI-Individual-Commands.md) | The same steps as Demo 2, as plain-English requests to the AI agent |

**Time:** about 10 minutes the first time, about 1 minute after that.

### What you'll learn

- How to start a ready-made Linux environment with **Docker**.
- How files move between your laptop and a container, using **volumes** and **bind mounts**.
- How to set **permissions** for an AI agent, so it can work freely but must ask before doing anything destructive.

### Before you start

- **Docker Desktop** installed and **running**. Look for the whale icon in your menu bar (macOS) or system tray (Windows).
- A **Google account**, to sign in to the Antigravity AI agent.
- An internet connection. The first run downloads about **730 MB**.

### How to use this guide

| Icon | Meaning |
|---|---|
| ✅ | **Checkpoint:** what you should see if everything worked |
| ❓ | **Check your understanding:** a quick question. Click *Answer* to reveal it. |
| 💬 | **Discuss:** a question to talk through with the class or your lab partner |
| ⚠️ | **Warning:** something that can go wrong or cause damage |
| 💡 | **Tip:** a useful extra |

> 💡 *Directory* and *folder* mean the same thing. You'll hear both.

---

## Step 1: Create a Folder for Your Work

### Goal 1.1: Make a folder on your laptop

We'll start on **your laptop**, in your normal terminal: **Terminal** on macOS or **PowerShell** on Windows. First, let's move to a folder where you keep coursework:

```bash
cd ~/Documents
```

Now let's create a folder to hold everything the demos produce:

```bash
mkdir -p incident-output
```

- `mkdir` = **m**a**k**e **dir**ectory.
- `-p` = don't complain if the folder already exists, and create any missing parent folders too. This makes the command safe to run more than once.

**Why do we need this?** In the next step, we'll share this folder with the container. Anything saved there will appear on your laptop, and it stays there after the container closes.

> 💡 **Windows (PowerShell):** use `mkdir incident-output` (without `-p`).

✅ **Checkpoint:** `ls` lists a folder called `incident-output`.

---

## Step 2: Start the Container

### Goal 2.1: Run the lecture image

Still on **your laptop**, and in the **same folder** as Step 1, run:

```bash
docker run --rm -it \
  -v agy-auth:/root/.gemini \
  -v "$PWD/incident-output":/workspace \
  moodyalam/mastering-cs:lecture01
```

> 💡 **Windows (PowerShell):** PowerShell doesn't understand the `\` line breaks, so use this one-line version:
> ```powershell
> docker run --rm -it -v agy-auth:/root/.gemini -v "${PWD}/incident-output:/workspace" moodyalam/mastering-cs:lecture01
> ```

The first time, Docker downloads the image, so give it a few minutes. Let's break the command down:

- `docker run` = start a new **container** (a small, isolated Linux computer) from an **image** (its blueprint). If the image isn't on your laptop yet, Docker downloads it first.
- `--rm` = delete the container when you exit, so every run starts clean.
- `-it` = **i**nteractive + **t**erminal: connects your keyboard and screen to the container, so you can type commands in it.
- `-v agy-auth:/root/.gemini` = a named Docker **volume** called `agy-auth`. It stores the AI agent's sign-in, settings and generated files. Because of `--rm` the container itself is thrown away when you exit, but this volume is kept, so you only sign in once.
- `-v "$PWD/incident-output":/workspace` = a **bind mount**: your laptop's `incident-output` folder appears inside the container as `/workspace`. `$PWD` means "the folder I'm in right now". Anything saved in `/workspace` is still on your laptop after you exit.
- `moodyalam/mastering-cs:lecture01` = the image to run: a Linux machine with the incident files and the `agy` AI agent already installed.

✅ **Checkpoint:** your prompt changes to something like `root@a1b2c3d4e5f6:/workspace#`. You are now **inside the container**. From here on, every command is typed inside the container unless a guide says otherwise.

❓ **Check your understanding:** you exit the container and start it again with the same command. Which of these survive: (a) a file you saved in `/workspace`, (b) a file you saved in `/tmp`, (c) your `agy` sign-in?

<details><summary>Answer</summary>

(a) and (c) survive. `/workspace` is your laptop's `incident-output` folder, and the sign-in lives in the `agy-auth` volume. (b) is lost, because `/tmp` belongs to the container, and `--rm` deletes the container when you exit.

</details>

---

## Step 3: Sign In to the AI Agent (Once Only)

### Goal 3.1: Sign in to Antigravity

Inside the container, start the agent:

```bash
agy
```

`agy` prints a Google sign-in link. Copy it into the browser **on your laptop**, sign in, copy the authorisation code it shows you, paste it back into the terminal and press **Enter**.

- You have **60 seconds** to finish. If it times out, simply run `agy` again.
- If `agy` asks whether to trust the current folder, choose **Yes**.

When you see the `agy` prompt box, type `/quit` to leave.

✅ **Checkpoint:** running `agy` again goes straight to the prompt box, with no sign-in link. Type `/quit` again.

---

## Step 4: Set the Agent's Permissions

### Goal 4.1: Let the agent work freely, but ask before deleting or stopping anything

AI agents ask for your approval before running commands. That's safe, but clicking "approve" forty times is slow. Instead, let's write some **permission rules**.

Permissions live in a settings file inside the container, at `~/.gemini/antigravity-cli/settings.json`. (`~` means your home folder; inside the container that's `/root`.) Each rule has the form `action(target)`, and rules sit in three lists:

- `allow` = do it without asking.
- `ask` = pause and ask me first.
- `deny` = never do it.

If two rules conflict, the stricter one wins: **deny > ask > allow**.

This short Python script adds our rules to the settings file, and keeps any other settings already there (such as your chosen model):

```bash
python3 - <<'PY'
import json, os
p = os.path.expanduser("~/.gemini/antigravity-cli/settings.json")
os.makedirs(os.path.dirname(p), exist_ok=True)
s = json.load(open(p)) if os.path.exists(p) else {}
s["permissions"] = {
    "allow": ["command(*)", "read_file(*)", "write_file(*)", "read_url(*)"],
    "ask":   ["command(rm)", "command(rmdir)", "command(unlink)", "command(shred)",
              "command(kill)", "command(pkill)"],
}
json.dump(s, open(p, "w"), indent=2)
PY
```

- `python3 - <<'PY' ... PY` = run the Python code between the two `PY` markers. This is called a **here document**.
- `allow`: run any command, read or write any file, and read any web page without asking.
- `ask`: still ask before **deleting** (`rm`, `rmdir`, `unlink`, `shred`) or **stopping processes** (`kill`, `pkill`). Because *ask beats allow*, these override `command(*)`.

> 💡 To **block** these actions completely instead of asking, change `"ask"` to `"deny"`. The agent will then tell you it can't do them, and you run those commands yourself.

> ⚠️ **A guardrail, not a security wall.** A determined agent could still delete a file in other ways, for example `find -delete` or a Python one-liner. **The real safety boundary is the container:** the agent can only touch the container's own files and the folders you mounted into it.

### Goal 4.2: Check the permissions

```bash
cat ~/.gemini/antigravity-cli/settings.json
```

✅ **Checkpoint:** you see a `"permissions"` block containing the `allow` and `ask` lists above.

Because this file lives in the `agy-auth` volume, you only need to do this once.

---

## Step 5: Getting Around Inside `agy`

You'll use these in Demos 1 and 3. There's no need to try them all now.

| What you type | Where | What it does |
|---|---|---|
| `agy` | Container shell | Start a conversation. The agent can run commands and edit files. |
| `agy --mode plan` | Container shell | Start in **plan mode**: the agent writes a plan and changes nothing until you approve it. |
| `agy -p "..."` | Container shell | **Print mode:** run one prompt, print the answer and exit, like any other command. |
| `agy -c` | Container shell | Continue your most recent conversation. |
| `!` | Inside `agy` | Switch to **shell mode** to run commands such as `cat` or `ls` without leaving `agy`. Press `!` again or `Esc` to go back. |
| `Shift+Tab` | Inside `agy` | Cycle between execution modes (for example, normal and plan). |
| `/quit` | Inside `agy` | Leave `agy` and return to the container shell. |

> ⚠️ Shell mode (`!`) doesn't support **Tab** completion. If you need it, open a second terminal on your laptop and run `docker ps` to find the container's name, then `docker exec -it <name> bash` to get a full shell in the same container.

---

## Step 6: Reset the Incident Between Demos

Each demo changes the incident files. Demo 2, for example, makes the restart script executable and stops the rogue process. If you then start Demo 3 without resetting, there's nothing left to solve. **Reset before each demo.**

### Goal 6.1: Full reset (recommended)

1. Inside the container, type `exit`.
2. On your laptop, delete the `incident-output/checkout-incident` folder.
3. Start the container again with the command from Step 2.

> ⚠️ Why delete the folder? Each time the container starts, it copies the incident files into `/workspace` again. But it **doesn't remove** files from earlier runs, and some earlier fixes survive. For example, a script you made executable stays executable.

### Goal 6.2: Quick reset (without leaving the container)

```bash
cd /workspace && rm -rf checkout-incident && cp -r /opt/demo-assets/checkout-incident . \
  && (pgrep -f leak-simulator >/dev/null || nohup python3 /opt/demo-assets/leak-simulator.py >/dev/null 2>&1 &) \
  && cd checkout-incident
```

- `rm -rf checkout-incident` = delete the old incident folder and everything in it.
- `cp -r /opt/demo-assets/checkout-incident .` = copy a fresh one from the image's original files.
- `pgrep ... || nohup python3 ... &` = if the rogue process isn't running, start it again in the background.

> ⚠️ The quick reset doesn't undo changes **outside** the incident folder, such as a `PATH` change in your current shell or a shortcut the agent created in `/usr/local/bin`. If in doubt, use the full reset.

✅ **Checkpoint:** `ls` in `/workspace/checkout-incident` shows `README.txt`, `bin`, `logs`, `notes.tmp`, `old_backup_DO_NOT_USE.log` and `scripts`.

---

## Step 7: Leaving and Coming Back

- To leave the container, type `exit`. Your files in `incident-output` and your `agy` sign-in are kept.
- To come back, `cd` to the folder containing `incident-output`, then run the command from Step 2 again.

> ⚠️ Keep **one** container open at a time. If two are running from different folders, files will appear in a different `incident-output` folder from the one you're looking at.

---

## What's Next

You're ready. Head to **[Demo 1](Lecture-1-Demo-1-Script-AI-Plan.md)**, where an AI agent plans the whole investigation from a single prompt.

---

## Troubleshooting

| Problem | Likely cause | Fix |
|---|---|---|
| `docker: command not found` or `Cannot connect to the Docker daemon` | Docker Desktop isn't installed or isn't running | Start Docker Desktop, wait until it says it's running, then try again. |
| Errors about `\` or unexpected arguments on Windows | PowerShell doesn't understand `\` at the end of a line | Use the one-line PowerShell command in Step 2. |
| Warning: *requested image's platform (linux/amd64) does not match the detected host platform* | You're on an Apple Silicon Mac, and the image is built for Intel/AMD | Harmless: Docker runs the image under emulation. |
| Everything is very slow on a Mac | Emulating Intel/AMD on Apple Silicon | In Docker Desktop, go to **Settings → General**, enable **"Use Rosetta for x86_64/amd64 emulation on Apple Silicon"**, then restart Docker. |
| `No such file or directory` for `/workspace`, or `agy: command not found` | You typed the command on your **laptop**, not in the container | Check your prompt. It should look like `root@…:/workspace#`. If not, run Step 2. |
| A sign-in link appears every time | The container was started without the `agy-auth` volume | Include `-v agy-auth:/root/.gemini` in your `docker run` command. |
| *authentication failed or timed out* | Sign-in took longer than 60 seconds | Run `agy` again and finish the sign-in more quickly. |
| University Google account can't sign in | Your organisation may block this app | Sign in with a personal Google account. |
| The agent asks for approval for everything | The permission rules are missing, or the settings file isn't valid JSON | Run Goal 4.2. Check the file with `python3 -m json.tool ~/.gemini/antigravity-cli/settings.json`. If it reports an error, run Goal 4.1 again. |
| Files saved in `/workspace` aren't on your laptop | Started without the `incident-output` mount, started from a different folder (so `$PWD` pointed elsewhere), or several containers are open | On your laptop, run `docker ps`. Exit any extra containers, then start again from the folder that contains `incident-output`. |
| Quota or rate-limit errors from `agy` | You've reached the free usage limit | Wait a minute and try again, or choose another model with `/model`. |
