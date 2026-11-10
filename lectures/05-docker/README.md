# Lecture 5: A Box That Just Runs

**Mastering Computer Science Technical Competencies** · Lecture 5: Docker and Containers

---

## Welcome

The Orders team is happy with you. Then, on Monday at 9:00, a message from Tom
Okafor, who looks after NovaStack's platform:

> **From:** Tom
> **Subject:** A box that just runs 📦
>
> Your menu page works great on your laptop. Staging has Python 3.9, no uv, and
> I'm not allowed to change it. I'm not installing your laptop on my server.
>
> Can you give me **a box that just runs**?
>
> — Tom

Jordan adds: *"Same lesson as the 3 AM Page. Something was different over
there. Pack the environment **with** the code."*

Today you'll do exactly that with **Docker**: run other people's software with
nothing installed, build a box of your own for NovaStack's menu service, start it
together with a database using one command, and use an **AI** to draft, explain
and review the recipe, with Docker as the judge.

Docker is used by **73.8% of professional developers** and **52.5% of people
learning to code** (Stack Overflow Developer Survey, 2025), and **2,046** UK
permanent job ads mentioned it in the six months to 3 November 2026
(ITJobsWatch). It is also an entry-level skill in the SFIA framework
(*Deployment*, Level 2). The gap between those two survey figures is what this
lecture closes.

---

## What You'll Learn

By the end of this lecture, you'll be able to:

- Explain **image**, **container** and how a container differs from a **virtual machine**.
- **Run, inspect, stop and clean up** containers: `run`, `ps`, `logs`, `exec`, `stop`, `rm`.
- Read and write a **Dockerfile** for a Python service, and say why its **order** matters (layers and the build cache).
- Use a **log** to find out why a container won't start.
- Start an app **and its database** with one **Docker Compose** command, and know what survives `down` and what doesn't.
- Keep **secrets and settings** out of images, and **tag** versions.
- Use an **AI** to draft, explain and review a Dockerfile, and **prove** every answer by building and running it.

---

## Before the Lecture

**Please do this today, before the lecture.** There's no time to set up during
it. Allow about 25 minutes, mostly downloads.

Full step-by-step instructions: **[Demo 0: Set Up Docker](demo/Lecture-5-Demo-0-Setup.md)**.

1. **Install Docker Desktop** (Windows, macOS) or Docker Engine (Linux).
2. ✅ **Checkpoint:** `docker run --rm hello-world` prints *Hello from Docker!*
3. **Fork** [novastack-hq/novastack-menu](https://github.com/novastack-hq/novastack-menu) and clone your fork.
4. **Run it on your laptop:** `uv sync`, then `uv run app.py`, and open <http://localhost:8000>. Stop it with `Ctrl+C`.
5. **Pre-download the images** (`python:3.12-slim`, `nginx`, `postgres:16`) at home: a whole lecture theatre shares one internet address, and Docker Hub limits downloads per address.
6. Optional: a free Docker Hub account (`docker login`).

Can't install Docker (a locked-down laptop)? Use **GitHub Codespaces**: Demo 0,
Step 6. Stuck? Bring the output of `docker version` and `docker info` to the
start of the lecture.

---

## How This Lecture Works

The lecture follows one Monday morning, in six short **Steps**.

| Step | Story | Topic | Demo |
|---|---|---|---|
| 1 | "Try someone else's box" | Images and containers | [Demo 1](demo/Lecture-5-Demo-1-Run-Other-Peoples-Software.md) |
| 2 | "The loop" | `run`, `ps`, `logs`, `exec`, `stop`, `rm` | [Demo 1](demo/Lecture-5-Demo-1-Run-Other-Peoples-Software.md) |
| 3 | "Ask an AI for the recipe… and it stops" | Dockerfiles, `docker logs` | [Demo 2](demo/Lecture-5-Demo-2-Package-the-Menu.md) |
| 4 | "Read the log, fix the box" | Evidence, `RUN pip install` | [Demo 2](demo/Lecture-5-Demo-2-Package-the-Menu.md) |
| 5 | "Now make it quick" | Layers, the build cache, `.dockerignore` | [Demo 2](demo/Lecture-5-Demo-2-Package-the-Menu.md) |
| 6 | "The whole kitchen" | Docker Compose, volumes | [Demo 3](demo/Lecture-5-Demo-3-Ship-It-and-Add-a-Database.md) |
| 7, 8 | *(written guide only)* Settings, tags, Docker Hub, `arm64` vs `amd64` | | [Demo 3](demo/Lecture-5-Demo-3-Ship-It-and-Add-a-Database.md) |

You don't need to type along: watch, ask, discuss. Every demo is written up
step by step so you can repeat it in the labs.

### The Demos

| Guide | What it shows | Time |
|---|---|---|
| [Demo 0: Set Up Docker](demo/Lecture-5-Demo-0-Setup.md) | Docker Desktop on Windows, macOS or Linux, the menu repository, running the menu on your laptop, pre-downloads, Codespaces fallback. **Do this before the lecture.** | ~30 min |
| [Demo 1: Run Other People's Software](demo/Lecture-5-Demo-1-Run-Other-Peoples-Software.md) | Steps 1 and 2: official images, the six everyday commands, cleaning up | ~5 min live |
| [Demo 2: Package the Menu](demo/Lecture-5-Demo-2-Package-the-Menu.md) | Steps 3 to 5: an AI-drafted Dockerfile that fails, reading the log, the fix, caching, `.dockerignore` | ~10 min live |
| [Demo 3: Ship It and Add a Database](demo/Lecture-5-Demo-3-Ship-It-and-Add-a-Database.md) | Step 6 live; Steps 7 and 8 to do yourself: Compose, volumes, settings, secrets, tags, Docker Hub, `arm64` | ~3 min live |

### How to read the guides

| Icon | Meaning |
|---|---|
| ✅ | **Checkpoint:** what you should see if everything worked |
| ❓ | **Check your understanding:** a quick question. Click *Answer* to reveal it. |
| 💬 | **Discuss:** a question to talk through with the class or your lab partner |
| ⚠️ | **Warning:** something that can go wrong or cause damage |
| 💡 | **Tip:** a useful extra |

Commands are written for macOS and Linux; **PowerShell** equivalents are given
where they differ. On Windows, use **PowerShell**, not Git Bash.

---

## Exercise and Labs

| Activity | Description | Time |
|---|---|---|
| [Exercise: ORD-371](exercise/README.md) | Finish a three-blank Dockerfile, then find out why the page won't load (in pairs; it is **Part 0 of each lab**) | 10 min |
| [Beginner lab: Ship the Menu](labs/beginner/README.md) | **Do the lecture yourself.** Run three official images, write your own Dockerfile, configure and tag it, optionally push to Docker Hub | ~2 h |
| [Intermediate lab: Make It Production-Shaped](labs/intermediate/README.md) | **Fewer hints.** `.dockerignore`, fast rebuilds, a smaller image, a non-root user, Docker Scout, both processor types | ~2 h |
| [Advanced lab: App and Database with Compose](labs/advanced/README.md) | **Write `compose.yaml`:** Postgres 16 with a volume, a healthcheck and a seed script, secrets kept out of Git. **Lecture 6 (SQL) starts from this.** | ~2 h |

**Choose one level** (or work up through them). Each lab has an answer sheet in
`lab5/` and a **self-check** that tells you when each part is done:

```bash
uv run tools/check_lab5.py beginner
```

---

## Your Set-Up at a Glance

| Tool | Why |
|---|---|
| **Docker Desktop** (or Docker Engine on Linux) | Runs containers; includes Docker Compose and Docker Scout |
| **`novastack-menu`**, your fork | The tiny menu service, the lab starters and the self-check |
| **VS Code** + **Copilot Chat** | As in Lectures 3 and 4; used for drafting Dockerfiles |
| **uv** (or `python`) | Runs the self-check script |
| A free **Docker Hub** account (optional) | Download limits, and sharing your image |
| **GitHub Codespaces** (fallback) | A Linux machine in the cloud with Docker already working |

---

## Next

Lecture 6 starts from **the database you start in Step 6** (the Advanced lab
has you write a Compose file like it yourself): everyone gets the same Postgres,
whatever laptop they use. Your box runs on staging;
making sure nobody breaks it again (tests, review and CI) comes after that.
