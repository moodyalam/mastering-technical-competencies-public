# Lecture 5 · Beginner Lab: Ship the Menu

**Mastering Computer Science Technical Competencies** · Lecture 5: A Box That Just Runs

**Time:** about 2 hours · **On your own laptop** · **Self-checking:** a script tells you when each part is done.

---

## The Scenario

In the lecture you watched someone else drive. This time, you drive.

> **From:** Tom
> **Subject:** ORD-372: ship the menu 📦
>
> Thanks for the demo. Now do it yourself, on your own laptop, so I know it
> isn't magic: run a few official boxes, then put **our menu service** in a box
> of your own. If you can get it onto Docker Hub, I can pull it straight onto
> staging.
>
> Write your answers in `lab5/BEGINNER.md` as you go.
>
> — Tom

You can open the [demo guides](../../demo/) for help, but **try each part first
with only the hints here**. That's where the learning happens.

---

## About This Lab

| Part | Title | Lecture step | You'll use | Time |
|---|---|---|---|---|
| 0 | Warm-up: ORD-371 (optional) | 4 | Dockerfile, `docker logs` | 10 min |
| 1 | Get Ready | | Docker Desktop, your `novastack-menu` fork | 10 min |
| 2 | Other People's Software | 1 and 2 | `run`, `exec`, `ps`, `logs`, `stop`, `rm` | 25 min |
| 3 | Your Own Box | 3 and 4 | A Dockerfile, `build`, the log | 35 min |
| 4 | Configure and Version It | 7 and 8 | `-e`, `docker tag` | 20 min |
| 5 | Optional: Share It | 8 | Docker Hub | 15 min |
| 6 | Clean Up and Check | | `docker system df`, the self-check | 10 min |

| Icon | Meaning |
|---|---|
| ✅ | **Checkpoint:** what you should see if everything worked |
| ❓ | **Check your understanding:** click *Answer* to reveal it |
| 💬 | **Discuss:** talk it through with a lab partner |
| ⚠️ | **Warning** |
| 💡 | **Tip** |

**Before you start:** the set-up from [Demo 0](../../demo/Lecture-5-Demo-0-Setup.md)
(Docker running, `docker run --rm hello-world` works, your fork of
`novastack-menu` cloned). On Windows use **PowerShell**.

---

## Part 0: Warm-Up: ORD-371 (optional)

Do the [exercise](../../exercise/README.md) (it is also in your `novastack-menu` fork, in the `exercise/` folder: `cd exercise` first): finish a three-blank Dockerfile,
build it, and fix a page that won't load.

---

## Part 1: Get Ready

1. Open a terminal **in your `novastack-menu` folder** (`code .` opens it in VS Code).
2. Run `docker version`. You should see **Client** and **Server**.
3. Open `lab5/BEGINNER.md`. You'll fill in the lines `A1:` to `A6:` as you go.

✅ **Checkpoint:** this runs and prints a list (mostly FAIL for now). Read one hint.

```bash
uv run tools/check_lab5.py beginner
```

- `uv run` runs the script with no set-up. `python tools/check_lab5.py beginner`
  works too (it uses only Python's standard library).

---

## Part 2: Other People's Software

Three official images, from [Docker Hub](https://hub.docker.com/). For each,
run it and write down the answer in `lab5/BEGINNER.md`.

1. **Python.** Run `python -V` inside a `python:3.12-slim` container and remove
   the container afterwards (`--rm`). Write exactly what it prints on line **A1**.
2. **nginx.** Start a web server in the background, named `web`, with your port
   8080 mapped to the container's port 80. Open <http://localhost:8080> and read
   its log with `docker logs`. Then look inside with `docker exec -it web sh`
   and find out **which Linux** it runs (hint: `cat /etc/os-release`). Write the
   distribution's name on line **A2**. Stop and remove `web`.
3. **Postgres.** Without starting a server, ask the `postgres:16` image for its
   exact version (hint: the command inside the container is `postgres --version`).
   Write what it prints on line **A3**.

💡 Stuck on a flag? [Demo 1](../../demo/Lecture-5-Demo-1-Run-Other-Peoples-Software.md)
has every command.

❓ **Check your understanding:** `docker ps` shows nothing, but you're sure you
started a container. What command will find it, and why might it be there?

<details><summary>Answer</summary>

`docker ps -a` lists **stopped** containers too. A container that started and
then exited (crashed, or finished its job) isn't shown by plain `docker ps`.
`docker logs <name>` then says why.
</details>

✅ **Checkpoint:** A1, A2 and A3 are filled in, and `docker ps -a` shows no
`web` container.

---

## Part 3: Your Own Box

Tom needs the menu service in a box. Your fork has `app.py`,
`templates/index.html` (the page), `requirements.txt` and `menu.json`, and some **saved Dockerfiles from the
lecture** (`Dockerfile.step3-saved-draft`, `Dockerfile.step4`,
`Dockerfile.step5`). **Don't copy the last two yet.**

1. **Make the mistake on purpose.** Build and run the lecture's broken draft
   (`Dockerfile.step3-saved-draft`; hint: `docker build -f <file> -t ... .`),
   with the name `menu` and port 8000 mapped. Find the container with
   `docker ps -a`. What **exit code** does it show? Write it on line **A4**.
2. Read `docker logs menu`. On line **A6**, say in one or two sentences **why**
   it stopped, in your own words.
3. **Now write your own `Dockerfile`** (a file called exactly `Dockerfile` in
   the repo's root) that fixes the problem. It must start from
   `python:3.12-slim`, set a working directory, copy the files in (all of them:
   `COPY . .` is fine, and the app needs `templates/` too), **install the
   requirements**, and start `python app.py`.
4. Put a **`# why:` comment** above at least three lines, saying why each is
   there. (Ask Copilot to draft it if you like: *"Write a Dockerfile for this
   Flask app. Use Python 3.12. It listens on port 8000. Add a comment above every instruction explaining what it does."* Then check every line.)
5. Build it as **`novastack-menu:1.0-ready`**, run it as `menu` (remove the old `menu`
   container first) and open <http://localhost:8000/menu>.

⚠️ **Mac:** don't use port 5000 (AirPlay Receiver).

✅ **Checkpoint:** you see the menu page (in a browser, `/menu` shows the cards;
`curl localhost:8000/menu` gives JSON), and `docker ps` shows `menu` running.

💬 **Discuss:** which `Dockerfile` line fixed the problem, and what's the
difference between `RUN` and `CMD`?

<details><summary>Hint: still stuck?</summary>

You need `FROM`, `WORKDIR`, `COPY`, `RUN pip install -r requirements.txt` and
`CMD ["python", "app.py"]`.
[Demo 2](../../demo/Lecture-5-Demo-2-Package-the-Menu.md) shows them in order.
</details>

---

## Part 4: Configure and Version It

1. **Configure it without rebuilding.** `app.py` reads the page title from the
   environment variable `MENU_TITLE`. Run your image as a second container,
   `menu-staging`, on port 8001, with the title **`Staging menu`**, and check
   <http://localhost:8001>. (Hint: `-e NAME=value`, and `-p 8001:8000`.)
2. **Find your image's ID.** Run `docker images novastack-menu`. Copy the first
   12 characters of the **IMAGE ID** of `1.0-ready` into line **A5**.
3. **Give it a second name.** Tag the same image as `novastack-menu:stable`
   (hint: `docker tag`). Do the two tags show the **same image ID**?

❓ **Check your understanding:** why is `novastack-menu:1.0-ready` better than relying on `latest`?

<details><summary>Answer</summary>

`1.0` says exactly which version you're running and lets you go back to the one
before. `latest` is just a name that moves, so you can't tell what's deployed or
roll back. (SFIA's entry-level deployment skill includes "assists in rolling
back deployments".)
</details>

✅ **Checkpoint:** `Staging menu is open` at port 8001, and the title at 8000 is
still the default.

---

## Part 5: Optional: Share It

Tom can't pull from your laptop. Put the image on [Docker Hub](https://hub.docker.com/)
(free account; see [Demo 0, Step 5](../../demo/Lecture-5-Demo-0-Setup.md#step-5-a-free-docker-hub-account-optional)).

1. `docker login`. (Never type a password into an AI chat.)
2. Tag your image as `<your-username>/novastack-menu:1.0-ready` and `docker push` it.
3. Ask a classmate to run it from Docker Hub, on a different kind of laptop if you can.
4. Add `HUB: <your-username>` to `lab5/BEGINNER.md`. (Leave it blank to skip.)

⚠️ Public images are public. Your image has no secrets in it, which is why
"settings at run time" matters.

✅ **Checkpoint:** `https://hub.docker.com/r/<your-username>/novastack-menu` shows tag `1.0-ready`.

---

## Part 6: Clean Up and Check

```bash
docker rm -f menu menu-staging web
```

- Removes your lab containers (it's fine if some don't exist).

```bash
docker system df
```

- Shows how much space Docker uses. **Read** what `docker system prune` lists
  before you say yes.

```bash
uv run tools/check_lab5.py beginner
```

✅ **Checkpoint:** no FAIL lines. (A SKIP for Docker Hub is fine.) The check reads your **facts and numbers**; your explanations (A6) are for you, so make them honest.

<details><summary>Answers (after you've tried)</summary>

- A1 is `Python 3.12.x`. A2 is the distribution (for example `Debian`). A3 is
  `postgres (PostgreSQL) 16.x`. A4 is `1`. A6: Flask was never installed in the box.
- The Dockerfile: `FROM python:3.12-slim`, `WORKDIR /app`, `COPY . .`,
  `RUN pip install -r requirements.txt`, `CMD ["python", "app.py"]`.
- Part 4: `docker run -d --name menu-staging -e MENU_TITLE="Staging menu" -p 8001:8000 novastack-menu:1.0-ready; echo http://localhost:8001`.
</details>

---

## Finished Early?

- Do the [Intermediate lab](../intermediate/README.md).
- Make the build faster by reordering your Dockerfile (Demo 2, Step 5) and time it.
- Ask Copilot to review your Dockerfile: *"At most three problems, most important first."* Which one would you apply, and why?
