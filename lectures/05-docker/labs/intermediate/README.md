# Lecture 5 · Intermediate Lab: Make It Production-Shaped

**Mastering Computer Science Technical Competencies** · Lecture 5: A Box That Just Runs

**Time:** about 2 hours · **On your own laptop** · **Self-checking:** a script tells you when each part is done.

---

## The Scenario

Your box runs on staging. Then a review comment arrives.

> **From:** Tom
> **Subject:** ORD-373: it works, but is it production-shaped?
>
> Good news: staging is happy. Before this goes anywhere near customers, my
> checklist says: **no junk in the image** (`.git`, `.env`), **fast rebuilds**,
> a **small** image, **not running as root**, a quick **vulnerability scan**,
> and **both processor types** (our CI runners and half your team's Macs differ).
>
> Make the changes and tell me **why** you made each one. AI can draft; you must
> be able to justify every line.
>
> — Tom

This lab gives you **goals, tools and hints, not steps**. The
[demo guides](../../demo/) cover the techniques.

Start from your finished Dockerfile from the Beginner lab, or from
`Dockerfile.step5` (copy it to `Dockerfile`). Answers go in `lab5/INTERMEDIATE.md`.

---

## About This Lab

| Part | Title | You'll use | Time |
|---|---|---|---|
| 0 | Warm-up: ORD-371 (optional) | Dockerfile, logs | 10 min |
| 1 | Keep Junk Out | `.dockerignore` | 10 min |
| 2 | Fast Rebuilds | Layer order, build timing | 25 min |
| 3 | A Smaller Box | `-slim` vs the full image, `docker images` | 20 min |
| 4 | Don't Run as Root | `USER`, `id -u` | 15 min |
| 5 | Scan It (optional) | `docker scout quickview` | 15 min |
| 6 | Both Processors | `docker buildx build --platform` | 20 min |
| 7 | Say Why, Then Check | `# why:` comments, the self-check | 15 min |

| Icon | Meaning |
|---|---|
| ✅ | **Checkpoint** |
| ❓ | **Check your understanding** (click *Answer*) |
| 💬 | **Discuss** |
| ⚠️ | **Warning** |
| 💡 | **Tip** |

---

## Part 0: Warm-Up: ORD-371 (optional)

The [exercise](../../exercise/README.md) (also in your fork, in the `exercise/` folder; `cd exercise` first): a three-blank Dockerfile and a page that won't load.

---

## Part 1: Keep Junk Out

`COPY . .` copies **everything** in the folder into the image.

1. Prove it: build your image, then list the files inside it
   (`docker run --rm novastack-menu:1.0-ready ls -a /app`). What shouldn't be there? (Look for `.git`, the saved `Dockerfile.*` files, and `.env` if you've made one.)
2. Create a **`.dockerignore`** that keeps `.git`, `.env`, `__pycache__` and
   `.venv` out. (`extras/dockerignore.example` is a start.)
3. Rebuild and list again.

⚠️ `.env` can hold passwords. An image is a file you hand to other people.

✅ **Checkpoint:** the list inside the image no longer has `.git` or `.env`.

---

## Part 2: Fast Rebuilds

Each Dockerfile instruction makes a **layer**, and Docker reuses a layer from
the last build (`CACHED`) only if that instruction, the files it copies and
everything above it are unchanged ([Demo 2, Step 5](../../demo/Lecture-5-Demo-2-Package-the-Menu.md#first-an-idea-layers-and-the-build-cache)
explains it with a diagram).

1. **Measure the slow way.** Make sure your Dockerfile copies the whole folder
   (`COPY . .`) **before** `pip install`. Build it, then change one line of
   `app.py`, and time the rebuild. Write the seconds on line **T1**.
2. **Reorder** the Dockerfile so changing your code doesn't reinstall Flask.
   Build once, change `app.py` again, time the rebuild. Write the seconds on
   line **T2**.

💡 Time a command: macOS/Linux `time docker build ...`; PowerShell
`Measure-Command { docker build ... | Out-Default }`.

❓ **Check your understanding:** if you add a new dependency to
`requirements.txt`, will the install step be cached next time? Why?

<details><summary>Answer</summary>

No. `COPY requirements.txt .` copies a **changed file**, so that layer and
everything after it (including `pip install`) is rebuilt. That's correct: the
new package has to be installed.
</details>

✅ **Checkpoint:** `T2` is clearly smaller than `T1`, and the build output says
`CACHED` for the `pip install` step.

---

## Part 3: A Smaller Box

Every image starts `FROM` a **base image**, and everything in the base comes
with you: its size, and any security holes in its software. `python:3.12` is a
full Debian Linux with compilers and many libraries; `python:3.12-slim` is the
same Python with most of that left out. If your app doesn't need it, it
shouldn't be in the box.

1. Change the base image to the **full** `python:3.12` (not `-slim`), build it
   as `novastack-menu:full`, and read its size in `docker images` (the **DISK USAGE** column; Docker
   29 also shows a smaller CONTENT SIZE, which we don't use). Write it in MB on
   line **S1**.
2. Switch back to **`python:3.12-slim`** and build it as **`novastack-menu:2.0`**.
   Write its size on line **S2**.

💬 **Discuss:** the full image is several times bigger. What else is in it? Why
does smaller matter (downloads, disk, and the number of things that can have
security holes)?

⚠️ Alpine-based images are even smaller, but some Python packages don't install
on them without extra work. `slim` is the safe default.

✅ **Checkpoint:** S1 is at least twice S2, and `novastack-menu:2.0` is under 300 MB.

---

## Part 4: Don't Run as Root

Unless a Dockerfile says otherwise, the program in a container runs as
**root**, the all-powerful administrator user (user number `0`). The container's
walls limit what root can reach, but containers share your laptop's kernel, so
if an attacker breaks into the app, a normal user can do far less damage. The
`USER` instruction picks who the program runs as.

1. Check who your container runs as (`docker run --rm novastack-menu:2.0 whoami`
   or `id -u`). `0` means **root**.
2. Change the Dockerfile so the app runs as a normal user. (Hint: create a user
   **after** installing packages, then switch to it with `USER` **before** `CMD`.)
   Ask Copilot, then **read** what it gives you.
3. Rebuild as `novastack-menu:2.0` and check again. The page must still work.

❓ **Check your understanding:** why create the user *after* `pip install`?

<details><summary>Answer</summary>

Installing packages needs root permission. Doing it first, as root, and then
switching to a normal user means the app can't change its own files or the
system. (Some people also install into a virtual environment; that's fine too.)
</details>

✅ **Checkpoint:** `id -u` prints something other than `0`, and
<http://localhost:8000/menu> still works.

---

## Part 5: Scan It (optional)

```bash
docker scout quickview novastack-menu:2.0
```

- Docker Scout is built into Docker Desktop. It lists known vulnerabilities
  (CVEs) in the packages inside your image, by severity.

Write the counts on line **V1** (for example `0C 1H 4M 12L`). Then try the same
on `novastack-menu:full`: which image has more?

💡 If the command isn't available, write `V1: skipped`. Scout's older "health
score" view was retired in 2026, so ignore tutorials that mention it.

---

## Part 6: Both Processors

A program is compiled for one **processor architecture**: `arm64` (Apple's
M-series chips, many phones) or `amd64` (most Windows and Linux PCs, and most
cloud servers). An image holds programs, so it has an architecture too. A
**multi-platform** image holds one version for each, and Docker picks the right
one. Running the other kind needs **emulation**: software pretending to be the
other processor, which works but is slower.

M-series Macs build `arm64` images; most cloud servers and CI runners are
`amd64`. Build **one tag that holds both**.

1. Build `novastack-menu:multi` for `linux/amd64` **and** `linux/arm64` with
   `docker buildx build`. (Hint: `--platform` takes a comma-separated list.)
2. Prove each one runs: start the image with `--platform linux/amd64` and with
   `--platform linux/arm64`, printing `uname -m` or
   `python -c "import platform; print(platform.machine())"`.
3. Which did the *other* processor have to **emulate**, and what does that cost?

✅ **Checkpoint:** you saw `x86_64` and `aarch64`.

💡 `docker buildx imagetools inspect` shows the platforms in an image, but only
once it's pushed to a registry. A single-platform image asked for the wrong
platform gives a confusing `pull access denied` message.

---

## Part 7: Say Why, Then Check

1. Make sure at least **five** lines of your `Dockerfile` have a `# why:`
   comment. A line you can't explain gets removed.
2. Fill in `W1` to `W5` in `lab5/INTERMEDIATE.md`: one or two sentences for each
   change (`.dockerignore`, order, slim, non-root, multi-platform).
3. Run the check:

```bash
uv run tools/check_lab5.py intermediate
```

✅ **Checkpoint:** no FAIL lines. The check also **measures your caching
itself**: it edits a throw-away copy of your code and rebuilds, expecting
`pip install` to say `CACHED`.

<details><summary>Answers (after you've tried)</summary>

```dockerfile
# why: start from the slim official Python 3.12 image (small, pinned)
FROM python:3.12-slim
# why: work in /app inside the box
WORKDIR /app
# why: copy only the dependency list first so the install layer can be cached
COPY requirements.txt .
# why: install Flask while building the image, not when running it
RUN pip install --no-cache-dir -r requirements.txt
# why: run as a normal user so a broken-into app has less power
RUN useradd --create-home appuser
# why: now copy the code, which changes most often
COPY . .
USER appuser
# why: start the service when the container starts
CMD ["python", "app.py"]
```

Multi-platform: `docker buildx build --platform linux/amd64,linux/arm64 -t novastack-menu:multi .`
</details>

---

## Finished Early?

- Add a **`HEALTHCHECK`** to the Dockerfile and watch `docker ps` show `(healthy)`.
- Pin the base image by digest. What do you gain, and what do you lose?
- Do the [Advanced lab](../advanced/README.md).
