# Lecture 5 · Advanced Lab: App and Database with Compose

**Mastering Computer Science Technical Competencies** · Lecture 5: A Box That Just Runs

**Time:** about 2 hours · **On your own laptop** · **Self-checking:** a script tells you when each part is done.

---

## The Scenario

> **From:** Grace (Finance)
> **Subject:** ORD-374: how many orders failed?
>
> After the checkout incident I want a number I can trust: **how many orders
> failed**, straight from the database. Tom says you can have the whole thing
> running on any laptop with one command.
>
> **From:** Tom
>
> The service and the order data are in `advanced/`. The one thing missing is
> `compose.yaml`: a database that **keeps its data**, a service that **waits
> for it**, and **no passwords in Git**. Lecture 6 (SQL) will start from what
> you build here, so every student has the same database.
>
> — Tom

This lab gives you **goals, tools and hints, not steps**. The
[demo guides](../../demo/) (especially [Demo 3](../../demo/Lecture-5-Demo-3-Ship-It-and-Add-a-Database.md))
cover the techniques.

---

## About This Lab

| Part | Title | You'll use | Time |
|---|---|---|---|
| 0 | Warm-up: ORD-371 (optional) | Dockerfile, logs | 10 min |
| 1 | Look at the Starter | `advanced/` | 10 min |
| 2 | Secrets Stay Out of Git | `.env`, `.gitignore` | 10 min |
| 3 | Write `compose.yaml` | Services, volumes, healthchecks | 35 min |
| 4 | Ask the Database | `docker compose exec`, `psql` | 15 min |
| 5 | What Survives? | `down` vs `down -v` | 20 min |
| 6 | Explain, Then Check | Your words, the self-check | 15 min |
| 7 | Stretch | Adminer, a CI smoke test | optional |

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

## Part 1: Look at the Starter

Open the `advanced/` folder in your fork of `novastack-menu`.

| File | What it is |
|---|---|
| `app.py`, `requirements.txt` | A Flask service. `/orders/count` counts the rows in the `orders` table. It reads its database address from the environment variable **`DATABASE_URL`** |
| `Dockerfile` | Already written (the cached version from the lecture) |
| `db/init/01_schema.sql` | Creates the `orders` table and inserts **200 checkout orders**, some of them failed |
| `.env.example` | A template: user, password and database name |
| `.gitignore`, `.dockerignore` | Already list `.env` |

Read `app.py` and answer in your head: **where does the app get its database
address, and what will go wrong if that address says `localhost`?**

<details><summary>Answer</summary>

From the environment (`DATABASE_URL`), so the same image works anywhere. Inside
a Compose network, `localhost` means the **app's own container**, not the
database. The app must use the database service's **name**.
</details>

---

## Part 2: Secrets Stay Out of Git

1. Create `advanced/.env` from the example and **choose your own password**: at least 8 **letters and digits only** (it goes into a URL, so characters like `@`, `/` and `:` break it).
2. Prove Git ignores it: `git status` must not list `.env`.
3. Check that `.env.example` still holds only a placeholder.

⚠️ Never commit a real password, and never paste a `.env` file into an AI chat.

✅ **Checkpoint:** `advanced/.env` exists, Git doesn't show it, and the password isn't `change-me`.

---

## Part 3: Write `compose.yaml`

💡 New to **services, networks, volumes and health checks**? Read
[Demo 3, Goal 6.1](../../demo/Lecture-5-Demo-3-Ship-It-and-Add-a-Database.md#goal-61-why-do-we-need-compose)
first: it explains each one and shows the `docker run` commands Compose replaces.

Create **`advanced/compose.yaml`** with **two services named exactly `app` and
`db`**:

**`db`**
- the **official `postgres:16`** image;
- its settings (user, password, database name) read from `.env`;
- a **named volume** so the data outlives the container, mounted where Postgres
  keeps its data (`/var/lib/postgresql/data` for version 16);
- `./db/init` mounted (read-only) at `/docker-entrypoint-initdb.d`, so the seed
  script runs the first time;
- a **healthcheck** that asks Postgres if it's ready (hint: `pg_isready`).

**`app`**
- **built** from the `Dockerfile` in this folder;
- port **8000** published to your laptop's 8000;
- `DATABASE_URL` set to `postgresql://USER:PASSWORD@db:5432/DBNAME`, using the
  values from `.env` (hint: `${NAME}` substitution), and **never the password
  written out**;
- starts only once `db` reports **healthy** (hint: `depends_on` with a condition).

At the bottom, declare the named volume.

⚠️ Don't add a `version:` line: Compose ignores it and warns.

💡 In a `healthcheck` test, a dollar sign for a variable that should be read
**inside the container** is written `$$`.

<details><summary>Hint: the skeleton</summary>

```yaml
services:
  app:
    build: .
    ports:
      - "8000:8000"
    environment:
      DATABASE_URL: ...
    depends_on:
      db:
        condition: ...

  db:
    image: postgres:16
    env_file: ...
    volumes:
      - ...
      - ...
    healthcheck:
      test: [...]
      interval: 3s
      timeout: 3s
      retries: 10

volumes:
  ...
```
</details>

---

## Part 4: Ask the Database

From the `advanced/` folder:

```bash
docker compose up -d; echo http://localhost:8000
```

1. `docker compose ps`: both services up, `db` healthy. Open
   <http://localhost:8000/orders/count>. It should say **200**.
2. Use `docker compose exec db psql -U <user> -d <dbname>` with `-c` and **one
   SQL query** to find **how many orders have the status `'failed'`**. Write the
   number on line **D2** of `lab5/ADVANCED.md`. (This is the only SQL you need
   today: Lecture 6 teaches the rest.)
3. Ask the container which Postgres it runs (`postgres --version`) and write it
   on **D5**.
4. Which hostname does the app use to reach the database? Write it on **D1**.

❓ **Check your understanding:** `docker compose up` starts the app and the
database "at the same time". How does the app avoid trying to connect before
the database is ready?

<details><summary>Answer</summary>

`depends_on` with `condition: service_healthy` makes Compose wait until the
database's **healthcheck** (`pg_isready`) passes before it starts the app.
Without it, the app can start first and fail to connect.
</details>

---

## Part 5: What Survives?

An experiment. You'll **add an order**, then take the stack down in two ways.

1. Insert order **201** with `psql` (for example
   `INSERT INTO orders VALUES (201, 'C001', 1.00, 'paid', now());`). Check the
   endpoint says 201.
2. `docker compose down`, then `docker compose up -d`. What does
   `/orders/count` say now? Write it on **D3**.
3. `docker compose down -v`, then `docker compose up -d`. What does it say now?
   Write it on **D4**.

💬 **Discuss:** in step 3 the 201st order has gone, but the 200 seeded ones are
back. Why? (Hint: when does the seed script run?)

<details><summary>Answer</summary>

`down` removes the containers but keeps the **named volume**, so the data
(including order 201) survives (D3 = 201). `down -v` also deletes the volume, so
the database is created **empty** again; Postgres runs the seed script because
the data folder is empty, giving the original 200 rows (D4 = 200).
</details>

⚠️ `down -v` is how people lose a real database by accident. Know what it does
before you type it.

---

## Part 6: Explain, Then Check

1. On lines **W1** and **W2** of `lab5/ADVANCED.md`, explain in your words: why
   does the app use that hostname, and why does `down -v` lose the data?
2. Run the check (stop your own stack first with `docker compose down`, so the
   check can use the same ports):

```bash
uv run tools/check_lab5.py advanced
```

✅ **Checkpoint:** no FAIL lines. The check builds **its own copy** of your
stack, then inserts a row, takes it down and up, and wipes the volume, to make
sure your volume and seed really behave.

<details><summary>Answers (after you've tried)</summary>

```yaml
# The containers that make up the application. Each name below is one service.
services:
  # Service 1: our Flask app.
  app:
    # Build the image from the Dockerfile in this folder.
    build: .
    # Publish a port, as docker run -p does: host port 8000 -> container port 8000.
    ports:
      - "8000:8000"
    # Environment variables for the app. DATABASE_URL tells it where the database is:
    # the host name "db" is the other service, found on the network Compose creates.
    # The ${...} values are read from your .env file, so no password is written here.
    environment:
      DATABASE_URL: postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@db:5432/${POSTGRES_DB}
    # Start this service only after "db" reports it is healthy (ready for connections).
    depends_on:
      db:
        condition: service_healthy

  # Service 2: the database.
  db:
    # Use the official ready-made Postgres 16 image (nothing to build).
    image: postgres:16
    # Read the database user, password and name from the .env file (never committed).
    env_file: .env
    volumes:
      # A named volume (declared at the bottom): the data survives the container being removed.
      - pgdata:/var/lib/postgresql/data
      # Put the files from db/init where Postgres looks for start-up scripts (:ro = read-only).
      - ./db/init:/docker-entrypoint-initdb.d:ro
    # How Compose asks the database "are you ready?"
    healthcheck:
      # pg_isready succeeds once Postgres accepts connections. $$ stops Compose
      # substituting the variable, so the shell inside the container reads it.
      test: ["CMD-SHELL", "pg_isready -U $${POSTGRES_USER} -d $${POSTGRES_DB}"]
      # Check every 3 seconds, give each check 3 seconds, and give up after 10 failures.
      interval: 3s
      timeout: 3s
      retries: 10

# Declare the named volume used by the db service above.
volumes:
  pgdata:
```

D1 `db` · D2 `25` · D3 `201` · D4 `200` · D5 `postgres (PostgreSQL) 16.x`.
</details>

---

## Part 7: Stretch (optional)

- Add a third service, **Adminer** (`image: adminer`), on port 8080, and look at
  your tables in a browser. What server name do you type into it?
- Add a GitHub Actions job that runs `docker compose up -d --wait` and then
  `curl`s `/orders/count`: a preview of the CI/CD lecture.
- Change the image to `postgres:18` and read the image's documentation. Does
  your volume line still keep the data? (It doesn't: Postgres 18 and later keep
  data in a different folder. Check before you change major versions.)
