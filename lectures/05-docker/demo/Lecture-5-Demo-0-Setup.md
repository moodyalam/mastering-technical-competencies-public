# Lecture 5 · Demo 0: Set Up Docker

**Mastering Computer Science Technical Competencies** · Lecture 5: A Box That Just Runs

---

## About This Guide

**Do this before the lecture.** It takes about 30 minutes, mostly downloads.
There's no time to install during the lecture. At the end, your laptop can run
**containers** (small, portable boxes that hold a program and everything it
needs) on Windows, macOS or Linux, and you'll have the NovaStack menu service
ready to work on.

| Step | Title | Time |
|---|---|---|
| 1 | Install Docker Desktop | 10 min |
| 2 | Check that it works | 3 min |
| 3 | Get the menu service and run it on your laptop | 8 min |
| 4 | Pre-download the images (optional but recommended) | 5 min |
| 5 | A free Docker Hub account (optional) | 3 min |
| 6 | If you can't install Docker: Codespaces | 5 min |
| 7 | If something goes wrong | as needed |

| Icon | Meaning |
|---|---|
| ✅ | **Checkpoint:** what you should see if everything worked |
| ❓ | **Check your understanding:** click *Answer* to reveal it |
| ⚠️ | **Warning:** something that can go wrong |
| 💡 | **Tip:** a useful extra |

---

## Step 1: Install Docker Desktop

**Docker Desktop** is the app that runs containers on your laptop. It is free
for personal use and education. You'll need about **8 GB of RAM** (4 GB is the
minimum on a Mac) and **several GB of free disk space** (Docker stores every
image you download).

### Goal 1.1: Windows

1. Check you're on **Windows 10 22H2 or newer, or Windows 11 23H2 or newer**.
2. In the Task Manager → **Performance** → **CPU** tab, check that
   **Virtualization** says *Enabled*. If it says *Disabled*, it can be switched
   on in your computer's BIOS/UEFI settings (search for your laptop model and
   "enable virtualization").
3. Download **Docker Desktop for Windows** from
   [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop/)
   and run the installer. Leave **Use WSL 2 instead of Hyper-V** ticked (it's
   the default).
4. Restart if it asks you to, then start **Docker Desktop** from the Start menu.

💡 **WSL 2** is Windows Subsystem for Linux: a small, real Linux that Docker
runs inside. Containers are Linux programs, so Docker needs one. If the
installer says WSL needs updating, run this once in **PowerShell as
Administrator**, then restart:

```powershell
wsl --update
```

- `wsl --update` downloads the latest WSL 2 Linux kernel.

⚠️ Windows **Home** and **Education** editions can run Linux containers only.
That's all this course needs.

### Goal 1.2: macOS

1. Download **Docker Desktop for Mac** from
   [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop/).
   Choose **Apple Silicon** (M1, M2, M3…) or **Intel** to match your Mac
   (Apple menu → **About This Mac**).
2. Open the `.dmg`, drag **Docker** into **Applications**, then open it.
3. Accept the licence terms when it asks.

⚠️ If you use port **5000** for anything you try later, note that recent macOS
versions use it for **AirPlay Receiver**. This course uses ports 8000, 8001 and
8080 to avoid that.

### Goal 1.3: Linux

Install **Docker Engine** and the **Compose plugin** for your distribution by
following [docs.docker.com/engine/install](https://docs.docker.com/engine/install/)
(Ubuntu, Debian and Fedora are all covered). Docker Desktop for Linux also
exists and works for this course.

⚠️ The usual post-install step adds you to the `docker` group so you don't need
`sudo`. Be aware that membership of that group is **root-equivalent**: anyone
who can run containers on a machine can read any file on it. That's fine on
your own laptop; don't do it on shared computers.

✅ **Checkpoint:** Docker Desktop is **running** (a whale icon in the menu bar
or system tray, and the app says *Engine running* at the bottom left).

---

## Step 2: Check That It Works

Open a **new** terminal (Windows: **PowerShell**; macOS: **Terminal**; Linux:
your terminal).

⚠️ On Windows, use **PowerShell**, not Git Bash: some Docker commands that need
a keyboard (`-it`) don't work in Git Bash.

```bash
docker version
```

- Prints two parts: **Client** (the `docker` command you type) and **Server**
  (the Docker **engine** that does the work). If you only see *Client*, the
  engine isn't running: start Docker Desktop and wait for it.

```bash
docker run --rm hello-world
```

- `docker run` starts a container. `hello-world` is the **image** (a tiny
  official one). `--rm` deletes the container when it finishes.
- The first time, Docker downloads the image: `Unable to find image
  'hello-world:latest' locally`.

✅ **Checkpoint:** the output includes

```text
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

```bash
docker compose version
```

- Compose starts several containers together (Step 6 of the lecture). It comes
  with Docker Desktop. ✅ It prints a version such as `Docker Compose version v5.x.x`.

❓ **Check your understanding:** `hello-world` printed a message and then
stopped. Did it download anything from the internet?

<details><summary>Answer</summary>

Yes, the **image**, once. The message told you the four things that happened:
the `docker` command contacted the engine, the engine **pulled** the image from
Docker Hub, created a **container** from it and ran it, and streamed the output
back. Run it again and it won't download anything: the image is now stored on
your laptop.
</details>

---

## Step 3: Get the Menu Service

The lecture uses a very small web service, **`novastack-menu`** (one Python file
and one dependency, Flask). You'll fork it, as you did with `novastack-orders`.

### Goal 3.1: Fork and clone it

1. Go to **[github.com/novastack-hq/novastack-menu](https://github.com/novastack-hq/novastack-menu)**
   and click **Fork**. (This time, **leave** "Copy the `main` branch only"
   ticked unless a lab tells you otherwise.)
2. Clone your fork and open it in VS Code:

```bash
git clone https://github.com/<your-username>/novastack-menu.git
cd novastack-menu
code .
```

- Replace `<your-username>` with your GitHub username.
- `code .` opens the folder in VS Code (set up in Lecture 3).

✅ **Checkpoint:** you can see `app.py`, `requirements.txt`, `menu.json`,
`pyproject.toml`, `compose.yaml` and several files called `Dockerfile…` in VS Code.

### Goal 3.2: Run it on your laptop (no Docker yet)

First, prove the service works **without** Docker. You'll use **uv**, the
package manager from Lecture 3. In the VS Code terminal (**Terminal** → **New
Terminal**, so you're in the `novastack-menu` folder):

```bash
uv sync
```

- `uv sync` reads `pyproject.toml` and `uv.lock` and creates a **virtual
  environment**: a folder called `.venv` holding Python 3.12 and Flask for this
  project only. Nothing is installed into your main Python.
- If you don't have Python 3.12, uv downloads it into its own folder.
- Without uv (pip): `python -m venv .venv`, then `.venv/bin/pip install -r requirements.txt`
  (Windows: `.venv\Scripts\pip install -r requirements.txt`).

✅ **Checkpoint:** a `.venv` folder appears in VS Code's Explorer, and the wavy
line under `flask` in `app.py` disappears after a few seconds. (If it doesn't,
click the Python version at the bottom right of VS Code and choose the one in
`.venv`.)

```bash
uv run app.py
```

- `uv run` runs `app.py` with the Python in `.venv`. (Pip route:
  `.venv/bin/python app.py`, or `.venv\Scripts\python app.py` on Windows.)

Open **<http://localhost:8000>** in your browser.

✅ **Checkpoint:** a page with the heading **NovaStack menu is open**, a card
for each item on the menu, and a line such as **Running on Darwin · machine
your-laptop-name** (`Darwin` is macOS; on Windows it says `Windows`). Remember
that line: you'll see it change in the lecture.

Stop the app with **`Ctrl+C`** in the terminal (on a Mac too: `Ctrl`, not `Cmd`).

⚠️ Stop it before the lecture's demos: while it runs, it holds port **8000**,
and Docker will need that port.

❓ **Check your understanding:** Flask is now installed on your laptop. Will a
Docker image built from this folder have Flask?

<details><summary>Answer</summary>

**Not unless the Dockerfile installs it.** Flask is in `.venv`, a folder on your
laptop, built for your laptop's operating system. An image starts from its own
clean base image and contains only what its Dockerfile puts in. You'll see this
go wrong (on purpose) in Step 3 of the lecture.
</details>

💡 The **Container Tools** extension for VS Code (`ms-azuretools.vscode-containers`)
shows your images and containers in a side panel. It's optional; we use the
terminal in the lecture.

---

## Step 4: Pre-Download the Images (Optional, Recommended)

Images are big. Download them now, on a good connection, so the lecture doesn't
wait on campus Wi-Fi.

```bash
docker pull python:3.12-slim
```

```bash
docker pull nginx
```

```bash
docker pull postgres:16
```

- `docker pull` downloads an image without running it.
- Together they're about **1.3 GB** on disk (a Docker image is compressed in
  transit, so the download is smaller).

✅ **Checkpoint:** `docker images` lists `python`, `nginx` and `postgres`.

⚠️ **Why now:** Docker Hub limits how many images one internet address may
download: about **100 pulls per 6 hours without an account**, and 200 with a
free account (Docker's documentation, November 2026). A whole lecture theatre
shares one address on campus Wi-Fi, so downloads can start failing with
`toomanyrequests`. Do this at home, and see Step 5.

---

## Step 5: A Free Docker Hub Account (Optional)

**Docker Hub** is the public library of images, and where you can share your
own. You only need an account to **push** your own image (an optional part of
the Beginner lab) and for the higher download limit.

1. Create a free **Personal** account at [hub.docker.com](https://hub.docker.com/).
2. Sign in from Docker Desktop (**Sign in** at the top right), or in the terminal:

```bash
docker login
```

- Follow the prompts (it opens your browser). **Never type your password into
  an AI chat or paste a Docker token anywhere public.**

✅ **Checkpoint:** `docker login` says `Login Succeeded`.

---

## Step 6: If You Can't Install Docker: Codespaces

Some laptops (locked-down university or work machines, very old hardware) can't
run Docker Desktop. **GitHub Codespaces** gives you a Linux machine in the
cloud with Docker already working, in a browser tab or in VS Code.

1. Open your fork of `novastack-menu` on GitHub.
2. Click the green **Code** button → **Codespaces** tab → **Create codespace on main**.
3. Wait for it to start, then open a terminal (**Terminal** → **New Terminal**)
   and run `docker run --rm hello-world`.

⚠️ **Quota:** GitHub Free gives **120 hours per month** of Codespaces, and a
verified student account gives **180**. A 2-core machine counts double, so you
get about **half as many real hours** (about 60 and 90). Stop the codespace
when you've finished (**Codespaces** → ⋯ → **Stop**). Usage is blocked, not
charged, when the quota runs out.

💡 Ports work differently there: when your container listens on 8000, VS Code
shows it in the **Ports** tab, and you open that link instead of
`localhost:8000`.

---

## Step 7: If Something Goes Wrong

| What you see | Why, and what to do |
|---|---|
| `docker: command not found` / `'docker' is not recognized` | Docker Desktop isn't installed, or you opened the terminal before installing. Close it and open a **new** one. |
| `Cannot connect to the Docker daemon` / `error during connect` | The engine isn't running. Start **Docker Desktop** and wait for *Engine running*. |
| Windows: *WSL 2 installation is incomplete* | Run `wsl --update` in **PowerShell (Administrator)**, restart, start Docker Desktop. |
| Windows: *Virtualization must be enabled* | Switch it on in BIOS/UEFI (Goal 1.1 step 2). |
| `toomanyrequests` when pulling | Docker Hub's limit. Sign in (Step 5) and try again later. |
| `no space left on device` | Docker's files are full. See what's using space with `docker system df`. After checking nothing you need is stopped, `docker system prune` removes stopped containers, unused networks and dangling images (it asks first). |
| `port is already allocated` / `address already in use` | Something else uses that port (is `uv run app.py` still running? Press `Ctrl+C` in its terminal). Use a different left-hand number, e.g. `-p 8081:80`. |
| `uv: command not found` | Install uv as in Lecture 3 ([docs.astral.sh/uv](https://docs.astral.sh/uv/getting-started/installation/)), open a **new** terminal, or use the pip route in Goal 3.2. |
| Very slow on an older laptop | Close other apps; give Docker more memory in Docker Desktop → **Settings** → **Resources**; or use Codespaces (Step 6). |

Still stuck? Bring the output of `docker version` and `docker info` to the
start of the lecture and ask.

---

## Try It Yourself

1. Run `docker run --rm python:3.12-slim python -V`. Do you have Python 3.12 on
   your laptop? Does it matter?
2. Run `docker images` and `docker ps -a`. What do the two lists show, and why
   is `hello-world` in the first but not the second?

<details><summary>Answers</summary>

1. It prints `Python 3.12.x` **whether or not** Python is installed on your
   laptop: the container brings its own.
2. `docker images` lists **images** (recipes) stored on your laptop; `docker ps -a`
   lists **containers** (running or stopped). `hello-world` is in the first
   because the image is still stored; it isn't in the second because `--rm`
   deleted the container when it finished.
</details>
