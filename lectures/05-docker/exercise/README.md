# Lecture 5 · Exercise: ORD-371

**Mastering Computer Science Technical Competencies** · Lecture 5: A Box That Just Runs

**Time:** 10 minutes · **In pairs:** one **driver** (types), one **navigator**
(reads this sheet, suggests, watches). **Swap at the 5-minute mark.**

💡 This exercise is **Part 0 of each lab** (the warm-up). It practises exactly
what the Dockerfile steps of the lecture showed.

---

## The Ticket

> **ORD-371: Package the tea-time special** · P3 · area: platform
>
> Tom wants the staff-room "tea-time special" page on staging too. It's a tiny
> Flask app. Finish the `Dockerfile` (three blanks), build it, run it, and
> check the page loads at <http://localhost:8001>.

You need **Docker Desktop running** (see the set-up guide). The files are in
the **`exercise/` folder of your `novastack-menu` fork**: `app.py`,
`requirements.txt` and an unfinished `Dockerfile`. Open a terminal there
(`cd exercise`) before you start.

---

## Steps

| Minutes | Do this | ✅ You're done when |
|---|---|---|
| **0–3** | Open `Dockerfile`. Replace the three `???` using the comments (**TODO 1, 2, 3**). | No `???` left |
| **3–5** | Build the image. | The build finishes without an error |
| **5–7** | Run it and open <http://localhost:8001>. | You see the page, **or** you don't (that's the point: carry on) |
| **7–10** | If the page won't load: read the container's log, find the line that says where the app is listening, and work out the fix. | The page loads |

To copy:

```bash
docker build -t tea:1.0 .
```

- `build` makes an image from the `Dockerfile` in this folder (`.`).
- `-t tea:1.0` gives it a name and a version tag.

```bash
docker run -d --name tea -p 8001:8001 tea:1.0; echo http://localhost:8001
```

- `-d` runs it in the background; `--name tea` names the container.
- `-p 8001:8001` means *my door 8001 → the box's door 8001* (**host:container**).
- `; echo http://localhost:8001` prints a link you can **Ctrl+click** (macOS: **Cmd+click**).

```bash
docker logs tea
```

- Shows what the app printed. **Look here first.**

When you've finished, clean up:

```bash
docker rm -f tea
```

⚠️ **macOS:** don't use port **5000** here. Flask's default is 5000, but on
recent versions of macOS the **AirPlay Receiver** already uses it, and Docker
will say *"address already in use"*. That's why this exercise uses 8001.

💡 **Windows (PowerShell):** the same commands work as written.

---

## Check Your Understanding

❓ The page didn't load, yet `docker ps` shows the container **running**. So
what is wrong?

<details><summary>Answer</summary>

The container is fine; the **app is only listening to the box's own door**.
`docker logs tea` says `Running on http://127.0.0.1:8001`. Inside a container,
`127.0.0.1` means *this container only*, so a request coming in through your
`-p` mapping can't reach it. The app has to listen on **`0.0.0.0`** ("every
door").
</details>

---

## Finished Early?

- Print the architecture of your image: `docker image inspect tea:1.0 --format "{{.Os}}/{{.Architecture}}"`.
  Is it `arm64` or `amd64`? Why might that matter on a cloud server?
- Edit the text in `app.py`, rebuild and watch which steps say `CACHED`.

<details><summary>Answers to the three blanks (for after the exercise)</summary>

```dockerfile
FROM python:3.12-slim
```

```dockerfile
RUN pip install --no-cache-dir -r requirements.txt
```

```dockerfile
CMD ["flask", "--app", "app", "run", "--host", "0.0.0.0", "--port", "8001"]
```

If you wrote the `CMD` **without** `--host 0.0.0.0`, you met the bug in the
last step: the container starts, but Flask listens on `127.0.0.1` only. Adding
`--host 0.0.0.0` fixes it. (Writing `"--host=0.0.0.0"` as a single item also
works.)
</details>
