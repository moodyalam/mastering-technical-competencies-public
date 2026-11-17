# Lecture 5 · Demo 1: Run Other People's Software

**Mastering Computer Science Technical Competencies** · Lecture 5: A Box That Just Runs

---

## The Scenario

Monday, 9:00. A message from Tom Okafor, who looks after NovaStack's platform:

> **From:** Tom
> **Subject:** A box that just runs 📦
>
> Your menu page works great on your laptop. Staging has Python 3.9, no uv, and
> I'm not allowed to change it. I'm not installing your laptop on my server.
>
> Can you give me a box that just runs?
>
> — Tom

Jordan adds: *"Same lesson as the 3 AM Page. Something was **different over
there**. Pack the environment with the code."*

Before you build a box, you need to know how to **use** one. In this demo you
run other people's software, with nothing installed.

---

## About This Demo

**Time:** about 5 minutes live (Steps 1 and 2 of the lecture); about 15 minutes
if you repeat it yourself.

| Step | Title | You'll use |
|---|---|---|
| 1 | Run Someone Else's Software | `docker run`, `docker images`, `docker ps -a` |
| 2 | The Loop | `run -d -p`, `ps`, `logs`, `exec`, `stop`, `rm`, `system df` |

You'll need Docker running ([Demo 0](Lecture-5-Demo-0-Setup.md)).

### Why this matters

- **Docker is the most-used tool in its category.** In the Stack Overflow 2025
  Developer Survey, **73.8% of professional developers** and **52.5% of people
  learning to code** said they use it. (Stack Overflow notes the jump from 2024
  is partly because it merged some technology categories that year.) The gap
  between those two numbers is what this lecture closes.
- **Employers ask for it.** ITJobsWatch counted **2,046 UK permanent job ads**
  mentioning Docker in the six months to 3 November 2026 (median salary
  £67,500). Mostly as "desirable": familiarity is enough for a first job.
- **It matches the standards.** The SFIA skills framework's *Deployment* skill
  at its entry level (Level 2) reads: *"Executes defined deployment processes
  and procedures using deployment tools and techniques."* That's today.

| Icon | Meaning |
|---|---|
| ✅ | **Checkpoint** |
| ❓ | **Check your understanding** (click *Answer*) |
| 💬 | **Discuss** |
| ⚠️ | **Warning** |
| 💡 | **Tip** |

---

## Step 1: Run Someone Else's Software

### Goal 1.1: Check Docker is ready

```bash
docker version
```

- Shows the **Client** (the `docker` command) and the **Server** (the engine).
  Both should appear.

### Goal 1.2: Run an official image

```bash
docker run --rm hello-world
```

- `docker run` = create a container from an **image** and start it.
- `hello-world` = the image's name (from **Docker Hub**, the public library of images).
- `--rm` = delete the container when it stops.

✅ **Checkpoint:** you see `Hello from Docker!`. The first time, Docker also
prints `Unable to find image 'hello-world:latest' locally` and downloads it.

### Goal 1.3: Run Python without installing it

```bash
docker run --rm python:3.12-slim python -V
```

- `python:3.12-slim` = the image: the official Python, version 3.12, the
  `slim` (smaller) variety. The part after the colon is the **tag**.
- `python -V` = the **command to run inside the container**: print Python's
  version.

✅ **Checkpoint:** it prints `Python 3.12.x` (for example `Python 3.12.16`), even
if you have no Python 3.12 on your laptop.

💬 **Discuss:** where did that Python come from, and where did it go afterwards?
(It came from the image; it was never installed on your laptop. The container
disappeared when the command finished, because of `--rm`.)

### Goal 1.4: Look at what's stored

```bash
docker images
```

- Lists the **images** on your laptop: the recipes, each stored once.

```bash
docker ps -a
```

- `ps` lists **containers**; `-a` includes the stopped ones. With `--rm`, the two
  you just ran are already gone.

✅ **Checkpoint:** `docker images` shows `hello-world` and `python`, and
`docker ps -a` doesn't show them.

> **A recipe and a meal.** An **image** is a recipe plus the ingredients, stored
> on disk and never changed. A **container** is one meal being cooked from it.
> You can cook many meals from one recipe, and eating one doesn't change the
> recipe. A **virtual machine** is different again: it brings a whole kitchen.
> A container shares your laptop's kitchen (its operating system kernel), which is why
> it starts in a second, not a minute.

❓ **Check your understanding:** you ran `docker run --rm python:3.12-slim python -V`
twice. How many times was Python downloaded?

<details><summary>Answer</summary>

**Once.** The first run pulled the image and stored it. The second run created a
new container from the stored image, so it started straight away.
</details>

---

## Step 2: The Loop

*Almost everything you do with Docker day to day is one of six commands.*

**An idea first: ports.** A computer runs many network programs at once, so
each one listens on a numbered **port**: a door number on the same address.
Web servers usually use port 80 (or 8000, 8080 for development); your browser
picks the door from the address, as in `localhost:8080`. A container has
**its own** set of doors, closed to the outside by default. **Publishing** a
port (`-p`) connects a door on your laptop to a door on the container.

### Goal 2.1: Start a web server in the background

```bash
docker run -d --name web -p 8080:80 nginx; echo http://localhost:8080
```

- `-d` = **detached**: run in the background and give me my terminal back.
- `--name web` = call this container `web` (otherwise Docker invents a name
  such as `priceless_pike`).
- `-p 8080:80` = **publish a port**: *my laptop's door 8080 → the container's door
  80*. Always **host:container**, in that order.
- `nginx` = the image: a very popular web server.
- `; echo http://localhost:8080` = `docker run -d` prints only the container's long
  ID, so this prints a link under it: **Ctrl+click** (macOS: **Cmd+click**) it to open the page.

⚠️ **Mac:** if you've used port 5000 before, note that recent macOS versions use
it themselves. Ports 8080 and 8000 are fine.

### Goal 2.2: Look at it

```bash
docker ps
```

- Lists **running** containers: the ID, the image, how long it's been up, the
  port mapping and the name.

Open **<http://localhost:8080>** in your browser.

✅ **Checkpoint:** a page that says **Welcome to nginx!**

```bash
docker logs web
```

- Shows what the program inside printed. Reload the browser page and run it
  again: a new line appears for your request.

✅ **Checkpoint:** a line like

```text
192.168.65.1 - - [03/Nov/2026:22:13:38 +0000] "GET / HTTP/1.1" 200 896 "-" "curl/8.9.1" "-"
```

(your address and browser name will differ; `GET / … 200` is the request that succeeded).

💡 **Look here first.** In Lecture 1 you investigated an incident with `grep`
on log files. `docker logs` is the same idea: you can pipe it, for example
`docker logs web | grep GET` (macOS/Linux) or
`docker logs web | Select-String GET` (PowerShell). Logs go to two streams, so
if you pipe and see nothing, add `2>&1` (macOS/Linux) to include both.

### Goal 2.3: Look around inside

```bash
docker exec -it web sh
```

- `exec` = run a command **inside a running container**.
- `-it` = interactive, with a terminal, so you can type.
- `sh` = the command to run: a shell. Your prompt changes: you're now *inside*.

Try:

```bash
ls /usr/share/nginx/html
```

```bash
cat /etc/os-release
```

- The first lists the page you saw in the browser. The second says the box runs
  **Debian Linux**, whatever your laptop runs.

```bash
exit
```

- Leaves the container (and leaves it running).

✅ **Checkpoint:** you listed `50x.html` and `index.html`, then `docker ps` still
shows `web` running.

⚠️ **Windows:** run this in **PowerShell**. Git Bash says
*"the input device is not a TTY"*.

### Goal 2.4: Stop it and clean up

```bash
docker stop web
```

- Politely stops the container. The browser page stops working.

```bash
docker ps -a
```

- `web` is still listed, with status `Exited`: stopped containers hang around.

```bash
docker rm web
```

- Deletes the container. (Use `docker rm -f web` to stop and delete in one go.)

✅ **Checkpoint:** `docker ps -a` no longer lists `web`.

### Goal 2.5: Keep your disk tidy

```bash
docker system df
```

- Shows how much space images, containers, volumes and build cache use.

```bash
docker rmi hello-world
```

- Deletes an **image** (`rmi` = remove image). It fails if a container still
  uses it.

⚠️ `docker system prune` deletes stopped containers, unused networks and
dangling images, in one go. It asks first, but **read what it lists**: if you
have containers you stopped on purpose, they go too. Without extra flags it
leaves volumes alone.

💡 Disk full is the most common problem new Docker users hit. `docker system df`
tells you what's taking the space.

### The six commands

| Command | Means |
|---|---|
| `docker run` | Create a container from an image and start it |
| `docker ps` | What's running? (`-a`: including stopped) |
| `docker logs` | What has it printed? **Look here first.** |
| `docker exec` | Run a command inside it |
| `docker stop` | Stop it |
| `docker rm` | Delete it |

---

## Try It Yourself

1. Start **two** web servers at once: `web` on 8080 and `web2` on 8081
   (`-p 8081:80`). Open both. Stop and remove both.
2. Start a *third* one on 8080 while `web` is still running. Read the error.
   What does it mean?
3. Run `docker run --rm -it python:3.12-slim python`. You're in a Python prompt
   inside a container. Type `import sys; print(sys.platform)`, then `exit()`.
   What does it print, and why?
4. Run `docker run --rm python:3.12-slim cat /etc/hostname`. Run it again. Why does the
   answer change?
5. In [Demo 0](Lecture-5-Demo-0-Setup.md) the menu page said **Running on
   Darwin** (or Windows) **· machine** *your laptop's name*. What do you predict
   it will say when the same code runs inside a container?

<details><summary>Answers</summary>

1. `docker run -d --name web2 -p 8081:80 nginx; echo http://localhost:8081`; stop and remove both with
   `docker rm -f web web2`.
2. `Bind for 0.0.0.0:8080 failed: port is already allocated`. Only one thing on
   your laptop can use a given port, so the second container can't claim 8080.
   Use a different left-hand number.
3. It prints `linux`, even on Windows or macOS: the container runs Linux.
4. Every container gets its own random hostname (the container's ID). Each
   `docker run` creates a **new** container from the same image.
5. **Running on Linux via Docker · container** followed by a 12-character ID like
   the one in question 4: the container's own name. You'll see it in Demo 2, Step 4.
</details>

---

## Next

[Demo 2: Package the Menu](Lecture-5-Demo-2-Package-the-Menu.md): Tom wants *your*
program in a box. You ask an AI to write the box's recipe, and it doesn't quite work.
