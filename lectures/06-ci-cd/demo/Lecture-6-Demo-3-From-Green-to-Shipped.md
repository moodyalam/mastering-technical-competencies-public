# Lecture 6 · Demo 3: From Green to Shipped

**Mastering Computer Science Technical Competencies** · Lecture 6: Nobody Breaks It Again

---

## The Scenario So Far

The gate works: nothing reaches `main` without a pull request and a green
`test` check ([Demo 2](Lecture-6-Demo-2-A-Gate-That-Says-No.md)). But Tom still
rebuilds the box by hand:

> **Tom:** "Every time something merges, I clone it, run `docker build`, push the
> image and hope I built the right commit. Can't the robot do that bit too? Only
> for things that passed, mind."

That's the last step of the pipeline: **from green to shipped**.

---

## About This Demo

**Time:** about 3 minutes live (Step 6 of the lecture); Steps 7 and 8 are for
you to do yourself. About 40 minutes in total.

| Step | Title | You'll use |
|---|---|---|
| 6 | From Green to Shipped | A second job, `needs`, `if`, `permissions`, GitHub's registry (`ghcr.io`), `docker pull`, `docker run` |
| 7 | Habits for Pipelines *(written only)* | Pinning to a commit SHA, least privilege, secrets, caching, a matrix, `concurrency`, workflow lockfiles |
| 8 | When Two Changes Collide *(written only)* | A merge conflict on a pull request, `git merge main`, VS Code's merge editor |

You need Demo 2 done: `.github/workflows/ci.yml` on `main` and the
`protect-main` ruleset. For Step 6 you also need **Docker** running (as in
Lecture 5).

### Why this matters

- **Build and deploy is a named skill.** The Level 4 Software Developer
  apprenticeship standard (ST0116) lists building and deploying software, and
  SFIA 9's systems integration and build skill expects builds produced with
  automation tools at level 2.
- **Releasing is weekly work.** In the Stack Overflow Developer Survey 2026,
  51.8% of respondents said deploying or releasing is part of a typical week.
- **Pipelines are a target.** In March 2025 the popular action
  `tj-actions/changed-files` was hijacked; over 23,000 repositories used it.
  Step 7 shows the habits that protect you.
- **Merge conflicts worry people.** In a study of students learning Git, 32%
  found merge conflicts difficult (Isomöttönen & Cochez, ICTERI 2014). Step 8
  makes one on purpose, so the first one you meet at work isn't a surprise.

| Icon | Meaning |
|---|---|
| ✅ | **Checkpoint** |
| ❓ | **Check your understanding** (click *Answer*) |
| 💬 | **Discuss** |
| ⚠️ | **Warning** |
| 💡 | **Tip** |

**Windows (PowerShell) notes**, used in this guide:

| macOS / Linux | Windows (PowerShell) |
|---|---|
| `cp a b` | `Copy-Item a b` |

Every `git`, `uv` and `docker` command is the same on all three systems.

---

## Step 6: From Green to Shipped

*Tom: "Only for things that passed, mind."*

### Goal 6.1: CI and CD in two sentences

**Continuous integration (CI)** checks every change automatically: build it,
run the tests, show a tick or a cross (Demo 2). **Continuous delivery (CD)**
goes one step further: every change that passes and is merged is **packaged
and published automatically**, ready to deploy, so nobody builds a release by
hand.

Lecture 5 made the box; Demo 2 made the gate. Now the robot builds the box,
but **only after the gate says yes**.

### Goal 6.2: Read the `publish` job

The finished workflow is saved as `extras/ci.step6.yml`. It's the Step 3 file
with one more job added under `jobs:`, after `test`:

```yaml
  # Build the box and publish it, but only after the tests pass on main.
  publish:
    needs: test
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    # This job may also write packages (images) to GitHub's registry.
    permissions:
      contents: read
      packages: write
    steps:
      - uses: actions/checkout@v7
      - name: Log in to GitHub's registry (ghcr.io)
        run: |
          echo "${{ secrets.GITHUB_TOKEN }}" |
            docker login ghcr.io -u "${{ github.actor }}" --password-stdin
      - name: Build the image and push it
        run: |
          # The tag is the first 7 characters of the commit.
          IMAGE="ghcr.io/$GITHUB_REPOSITORY:${GITHUB_SHA::7}"
          # Image names must be lower case.
          IMAGE=$(echo "$IMAGE" | tr '[:upper:]' '[:lower:]')
          docker build -f Dockerfile.step5 -t "$IMAGE" .
          docker push "$IMAGE"
          echo "Published $IMAGE" >> "$GITHUB_STEP_SUMMARY"
```

| Line | Means |
|---|---|
| `publish:` | A second job, with its own fresh machine |
| `needs: test` | Wait for the `test` job, and run **only if it passed**. Without this line both jobs would start at once |
| `if: github.event_name == 'push' && ...` | Run only when this run was started by a **push** to **`main`** (a merge). On a pull request, the job is **skipped** |
| `permissions: packages: write` | This job, and only this one, may write **packages** (images) to GitHub's registry. The `test` job still can only read |
| `uses: actions/checkout@v7` | Copy the repository onto this job's machine (each job starts empty) |
| `name:` | A readable name for the step, shown in the log instead of the command |
| `secrets.GITHUB_TOKEN` | A short-lived password GitHub creates for **each run**, limited to the `permissions` above. You never type or store it |
| `run: \|` | A multi-line command: the indented lines below are one script, run in order. A line ending in `\|` carries on to the next line |
| `echo ... \| docker login ghcr.io -u ... --password-stdin` | Log in to **ghcr.io**, GitHub's container registry, as `github.actor` (you, the person whose push started the run). `--password-stdin` reads the token from the pipe, so it never appears on the command line |
| `IMAGE="ghcr.io/$GITHUB_REPOSITORY:${GITHUB_SHA::7}"` | Work out the image's name: `ghcr.io/` + your `owner/repo` + `:` + the first 7 characters of the commit's ID (`${GITHUB_SHA::7}`). GitHub sets both variables on every run |
| `IMAGE=$(echo "$IMAGE" \| tr ...)` | `tr` turns capitals into lower case, because image names must be lower case (and many usernames aren't) |
| `docker build -f Dockerfile.step5 -t "$IMAGE" .` | Lecture 5's command: build from the finished, cached Dockerfile, and tag it |
| `docker push "$IMAGE"` | Lecture 5's command: upload it to the registry |
| `>> "$GITHUB_STEP_SUMMARY"` | Add a line to the run's **summary page**, so the image's name is easy to find |

The `docker` commands are **exactly** the ones you typed in Lecture 5. The only
difference is who types them, and when.

💡 Tagging with the commit (for example `:3f9a1c2`) means every image says
which code it came from. If staging breaks, Tom knows exactly which commit to
look at, and which image to roll back to.

❓ **Check your understanding:** why does `publish` need `if:` when it already
has `needs: test`?

<details><summary>Answer</summary>

`needs: test` only says *"after the tests pass"*. The tests also pass on every
**pull request**, including ones that are never merged, or that haven't been
reviewed yet. Without the `if:`, every green pull request would publish an
image. The `if:` limits publishing to changes that have passed the gate **and**
been merged into `main`.
</details>

### Goal 6.3: Round the loop on `ship-it`

```bash
git switch main
```

- Back to your local `main`.

```bash
git pull
```

- Brings it up to date with your fork (the autumn special is merged).

```bash
git switch -c ship-it
```

- A fresh branch from an up-to-date `main`.

Replace the workflow with the saved one.

macOS / Linux:

```bash
cp extras/ci.step6.yml .github/workflows/ci.yml
```

Windows (PowerShell):

```powershell
Copy-Item extras\ci.step6.yml .github\workflows\ci.yml
```

- Overwrites `ci.yml` with the Step 3 file **plus** the `publish` job.

```bash
git diff
```

- Shows what changed in your files since the last commit.

✅ **Checkpoint:** the diff changes the first comment (now two lines) and adds
the `publish` job at the end (all `+` lines). If it also changes the `test`
job, you edited `ci.yml` in Demo 2: check the differences before you go on.

```bash
git add .github/workflows/ci.yml
```

- Stages the workflow, by name.

```bash
git commit -m "ci: publish the box after the tests pass on main"
```

- `ci:` because only the pipeline changes.

```bash
git push -u origin ship-it
```

- Sends the branch to your fork; `-u` remembers where it goes.

Open the link and create the pull request.

⚠️ **Check the base repository is your own fork**, as in Demo 2.

✅ **Checkpoint:** the pull request shows **two** jobs: `test` runs and goes
green, and `publish` is **skipped**, because this is a pull request, not a push
to `main`. The checks box says **All checks have passed** (*1 skipped, 1
successful checks*): `CI / publish (pull_request)` is greyed out and says
**Skipped**, and `CI / test (pull_request)` has a green tick and a **Required**
label (the ruleset).

Merge it: **Merge pull request**, then **Confirm merge**. The ruleset allows it,
because `test` is green.

### Goal 6.4: Watch it ship

Open your fork's **Actions** tab and click the newest run of `CI` (the push to
`main` made by the merge).

✅ **Checkpoint:** `test` runs first. When it's green, `publish` starts. Open
`publish` and its step **Build the image and push it**: you'll see the same
`docker build` output as on your laptop in Lecture 5, then `docker push`
uploading the layers. Unlike your laptop, the robot has no build cache from
Lecture 5, so it downloads `python:3.12-slim` first. It's still quick: the
whole `publish` job took 13 seconds on a fork when we tried it.

⚠️ If `publish` goes red at `docker push` with a message about permission
being denied, ask in the lab or on Moodle: the fix depends on your account's
package settings. (We tried it on a fork: the fork's own token, with
`packages: write`, logs in with `Login Succeeded` and pushes.)

✅ **Checkpoint:** the run's **Summary** page shows a line like
`Published ghcr.io/<your-username>/novastack-menu:3f9a1c2` (your username and
commit). Copy the image name: Tom needs it.

You can also find the tag on your laptop, after pulling the merge:

```bash
git switch main
```

- Back to `main` (you were on `ship-it`).

```bash
git pull
```

- Brings the merge commit down to your laptop.

```bash
git rev-parse --short=7 HEAD
```

- `rev-parse HEAD` prints the ID of the commit you're on (the merge);
  `--short=7` cuts it to the first 7 characters, as the workflow did.

### Goal 6.5: Find the package

On GitHub, an image in `ghcr.io` is called a **package**. Open your profile
(click your picture, then **Your profile**) and the **Packages** tab, or go to
`github.com/<your-username>?tab=packages`.

✅ **Checkpoint:** a package called `novastack-menu`, with your tag listed under
it.

⚠️ **The package is public.** A package published by a repository's workflow is
**linked** to that repository and takes its visibility. Your fork is public, so
the package page says **Public**: anyone can pull your image, without logging
in. That's what Tom needs, and it's why the image must hold nothing secret
(Lecture 5's `.dockerignore` rule). A public package **can't be made private
again**.

💬 **Discuss:** the robot built the image on a machine that has no `.env`
file. Why not? (Because `.env` was never committed. The robot has only what's
in the repository, which is one more reason secrets stay out of Git.)

### Goal 6.6: Tom's side: pull and run

Now be Tom, on any machine with Docker. Replace `<your-username>` and `<tag>`
with yours (both in **lower case**).

Only if your package says **Private** (for example, a private repository), log
in first. Otherwise skip this:

```bash
docker login ghcr.io -u <your-username>
```

- Log in to GitHub's registry. When it asks for a password, paste a **personal
  access token (classic)** with the `read:packages` scope (GitHub, **Settings**,
  **Developer settings**, **Personal access tokens**). Never your GitHub
  password, and never paste the token into an AI chat.

Make sure nothing else is using port 8000 (for example Lecture 5's stack:
`docker compose down`).

```bash
docker pull --platform linux/amd64 ghcr.io/<your-username>/novastack-menu:<tag>
```

- Download the image the robot built from the registry, as `docker pull nginx`
  did in Lecture 5.
- `--platform linux/amd64`: GitHub's machine is `amd64`, so it built an
  `amd64` image only. On an **Apple-silicon Mac** a plain `docker pull` fails
  with `no matching manifest for linux/arm64/v8 in the manifest list entries`;
  this asks for the `amd64` image instead. On other laptops it changes nothing.

✅ **Checkpoint:** Docker downloads the layers and prints the image's digest.

```bash
docker run -d --name menu -p 8000:8000 --platform linux/amd64 -e IMAGE_NAME=ghcr.io/<your-username>/novastack-menu:<tag> ghcr.io/<your-username>/novastack-menu:<tag>; echo http://localhost:8000
```

- `-d` runs it in the background; `--name menu` names the container so it's
  easy to stop; `-p 8000:8000` maps your port 8000 to the box's.
- `-e IMAGE_NAME=...` tells the app which image it's running from, so the page
  can show it (a container can't see that itself).
- The `echo` after the `;` prints a link to Ctrl+click (macOS: Cmd+click).

✅ **Checkpoint:** <http://localhost:8000> shows the menu with **Pumpkin spice
latte** at **4.50**, and the line **Running on Linux via Docker ·
ghcr.io/&lt;your-username&gt;/novastack-menu:&lt;tag&gt;**. Tom ran it without
cloning anything and without your laptop.

💡 **Apple-silicon Macs:** the image is `amd64` only, so Docker Desktop runs it
with emulation. It works, a little slower. Leave out `--platform linux/amd64`
from `docker run` and Docker still runs it, after `WARNING: The requested
image's platform (linux/amd64) does not match the detected host platform
(linux/arm64/v8) and no specific platform was requested`. Lecture 5, Step 8.3
showed how to build for both.

❓ **Check your understanding:** Mei merges a change that breaks a test. What
happens to the image on `ghcr.io`?

<details><summary>Answer</summary>

**Nothing new is published.** Actually, with the ruleset, her change can't be
merged while the check is red. But even if a broken commit reached `main`,
`test` would fail and `publish` (which `needs: test`) would never run. The last
good image stays in the registry, and Tom keeps running it.
</details>

### Goal 6.7: Clean up

```bash
docker rm -f menu
```

- Stop and delete the container named `menu` (`-f` stops it first).

```bash
docker rmi ghcr.io/<your-username>/novastack-menu:<tag>
```

- Delete the downloaded image from your laptop. It's still safe in the registry.

> **Tom:** "So I just pull the newest tag. I'll take it."

---

## Step 7: Habits for Pipelines *(written only)*

*Not shown in the lecture. Read it, try the examples on a branch, and use them
in the Intermediate lab.*

A workflow runs code from other people (actions), on a machine that can hold
your secrets and publish your software. A few habits keep that safe and fast.

### Goal 7.1: Pin actions to a full commit SHA

`uses: actions/checkout@v7` names a **tag**. A tag is just a label on a commit,
and **whoever controls the action's repository can move it**. A full commit
**SHA** (the 40-character ID of a commit) can't be moved: it always means
exactly the same code.

```yaml
      - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1
      - uses: astral-sh/setup-uv@68559e99cc807c1eb7e9238fd43a15bba460eec2 # v10.3.3
```

- The part after `@` is the commit SHA of that exact release.
- The comment `# v7.0.1` is for **people**: it says which version the SHA is.
  GitHub ignores it.

Why it matters, twice over:

- **tj-actions (March 2025).** Attackers moved the tags of the widely used
  `tj-actions/changed-files` action to a malicious commit that printed the
  workflow's secrets into the build log. Over 23,000 repositories used the
  action; anyone pinned to a SHA ran the old, safe code.
- **Trivy's action (19 March 2026).** Attackers force-pushed 76 of the 77 tags
  of `trivy-action`, a popular security scanner. Workflows that named a tag
  quietly ran code the maintainers never wrote.

This is also why `astral-sh/setup-uv` stopped publishing moving tags such as
`v10` (Demo 2, Goal 3.5).

💡 Find a release's SHA on the action's **Releases** page (the short commit
next to the tag; click it for the full ID). Dependabot can keep pinned SHAs and
their comments up to date for you.

❓ **Check your understanding:** if a SHA is safer, why did the lecture's
workflow use `@v7` and `@v10.3.3`?

<details><summary>Answer</summary>

To be **readable** on a slide while you learn the five ideas. A tag is easier
to read and check than 40 hex characters. Once you know what each line does,
pin to the SHA with the version in a comment: you lose no readability, and you
gain a version nobody can move. The Intermediate lab's checker insists on it.
</details>

### Goal 7.2: Least-privilege `permissions`

Every run gets a `GITHUB_TOKEN`. The `permissions:` key says what that token
may do. Give each job **the least it needs**:

```yaml
permissions:
  contents: read
```

- At the top of the file: every job may only **read** the repository.

```yaml
    permissions:
      contents: read
      packages: write
```

- Inside one job (as in `publish`): that job alone may also write packages.

If a step is ever hijacked (Goal 7.1), a read-only token limits the damage.

💡 One trigger to avoid: `pull_request_target` runs with your repository's
permissions even for pull requests from strangers' forks; GitHub blocks it by
default in public repositories from 2 December 2026.

### Goal 7.3: Secrets

A **secret** is a value the pipeline needs but nobody should read: an API key,
a password for a server. Never write it in the YAML: the YAML is in Git, and
anyone who can read the repository can read it.

Store it in GitHub instead: **Settings** → **Secrets and variables** →
**Actions** → **New repository secret**. Then use it by name:

```yaml
      - name: Tell the till about the new menu
        run: ./notify-till.sh
        env:
          TILL_API_KEY: ${{ secrets.TILL_API_KEY }}
```

- `${{ secrets.TILL_API_KEY }}` is replaced by the secret's value when the job
  runs. (`notify-till.sh` is only an example; the menu repository has no such
  script.)
- Passing it through `env:` gives the script a variable to read, so the value
  isn't pasted into the command itself.

⚠️ **Never print a secret** (`echo $TILL_API_KEY`, or a debug line that dumps
all variables). GitHub hides values it knows are secrets as `***` in the log,
but a changed copy (encoded, split, reversed) slips past. Logs are often public.
That's exactly how the tj-actions attack stole secrets.

❓ **Check your understanding:** `publish` uses `secrets.GITHUB_TOKEN`, but you
never created a secret. Where did it come from?

<details><summary>Answer</summary>

GitHub creates `GITHUB_TOKEN` **automatically for every run**, limited by the
`permissions:` key, and it expires when the job ends. Your own secrets (like
`TILL_API_KEY`) you must add in Settings. That automatic, short-lived,
least-privilege token is why you didn't need to store a password to publish.
</details>

### Goal 7.4: Caching

Every run starts on an empty machine, so it downloads every package again. A
**cache** saves the downloads at the end of one run and restores them at the
start of the next, as Docker's build cache did in Lecture 5.

The uv action does this for you: caching is **on by default** on GitHub's
machines (its `enable-cache` setting defaults to `auto`). To see it, open a
run's log and expand **Run astral-sh/setup-uv...** near the top (it reports
whether a cache was found) and **Post Run astral-sh/setup-uv...** near the
bottom (it saves the cache). On a first run you'll see `No GitHub Actions cache
found for key: setup-uv-2-...` and, at the end, `uv cache saved with key: ...`;
on a later run `Cache hit for: setup-uv-2-...` and `Cache restored
successfully`.

With one dependency (Flask) the saving is small. The Intermediate lab times a
run with and without it.

### Goal 7.5: A matrix: two Pythons at once

The menu says `requires-python = ">=3.12"`. Does it really work on 3.13? A
**matrix** runs the same job once per value:

```yaml
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ["3.12", "3.13"]
    steps:
      - uses: actions/checkout@v7
      - uses: astral-sh/setup-uv@v10.3.3
        with:
          python-version: ${{ matrix.python-version }}
      - run: uv sync --locked
      - run: uv run pytest
```

- `strategy: matrix:` makes **one copy of the job per value**: two jobs, side
  by side, each on its own machine.
- `${{ matrix.python-version }}` is `3.12` in one copy and `3.13` in the other.
- `with: python-version:` tells the uv action which Python that copy should use.

⚠️ The jobs are now named with their value, like `test (3.12)` and
`test (3.13)`, so a ruleset that asks for `test` waits for a check that never
comes. Update the ruleset to ask for the new names.

### Goal 7.6: `concurrency`: don't test old commits

Push three commits quickly and you get three runs, though only the last one
matters. Add this at the top level of the workflow:

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

- `group:` puts runs of the same workflow on the same branch in one group.
- `cancel-in-progress: true` cancels the older run in a group when a newer one
  starts.

💡 Be careful with publishing jobs: you may not want a half-finished publish
cancelled. Many teams use `cancel-in-progress` for pull requests only.

### Goal 7.7: The newest practice: workflow lockfiles

Since 28 October 2026, GitHub supports a **workflow lockfile**,
`.github/workflows/actions.lock`, made with the `gh actions-lock` extension.
Like `uv.lock` for Python packages, it records the exact commit of every action
your workflows use, including actions that *those* actions use, and GitHub
checks it on each run. GitHub's security guidance says a lockfile supersedes
SHA pinning where a project adopts it. It's very new, so you'll still meet SHA
pinning almost everywhere: learn that first (the labs assess it), and know the
lockfile is where things are heading.

### Goal 7.8: Feedback in minutes

DORA's guidance on continuous integration says developers should get feedback
from the build and tests **in minutes, with about ten minutes as the upper
limit**. Beyond that, people stop waiting and start something else, and the
gate becomes a queue. Our `test` job took about 12 seconds on GitHub's
machine (7 to 12 seconds over our rehearsal's runs); caching, `concurrency`
and fast tests keep yours that way.

💬 **Discuss:** your team's test suite grows to 40 minutes. Which habits from
this step would you reach for first, and what would you run on every push
versus only on pull requests? (The Advanced lab does exactly that for
`novastack-orders`.)

---

## Step 8: When Two Changes Collide *(written only)*

*Not shown in the lecture. About 15 minutes.*

### Goal 8.1: What is a merge conflict?

Git merges two branches line by line. If they changed **different** lines, Git
combines them by itself. If they changed **the same lines in different ways**,
Git can't know which you want, so it stops, marks both versions in the file and
asks **you**. That's a **merge conflict**. It isn't an error and nothing is lost:
it's Git being honest that a person must decide.

The story: on the same morning, Priya adds **hot chocolate** and Mei adds
**iced tea**, each on their own branch, each at the end of `menu.json`. Both
pick the next free SKU, `D06`.

### Goal 8.2: Make two branches from the same `main`

```bash
git switch main
```

- Back to your local `main`.

```bash
git pull
```

- Start from an up-to-date `main` (with the autumn special at the end).

**Branch 1 (Priya):**

```bash
git switch -c hot-chocolate
```

- Priya's branch, made from `main`.

Open `menu.json`, add a comma after the last item's `}`, and add this item
before the final `]`:

```json
  {
    "sku": "D06",
    "name": "Hot chocolate",
    "category": "drink",
    "price": "2.70",
    "icon": "🍫"
  }
```

```bash
git add menu.json
```

- Stages the menu, by name.

```bash
git commit -m "feat: add hot chocolate"
```

- Priya's commit.

**Branch 2 (Mei)**, made from `main` **as it was**, before hot chocolate:

```bash
git switch -c iced-tea main
```

- The extra `main` at the end says "start the new branch from `main`", not from
  the branch you're on.

✅ **Checkpoint:** `menu.json` ends with the autumn special again: no hot
chocolate on this branch.

Add a comma after the last `}` and this item before the final `]`:

```json
  {
    "sku": "D06",
    "name": "Iced tea",
    "category": "drink",
    "price": "2.20",
    "icon": "🧊"
  }
```

```bash
git add menu.json
```

- Stages the menu, by name.

```bash
git commit -m "feat: add iced tea"
```

- Mei's commit, on her own branch.

### Goal 8.3: The first one in wins

Push Priya's branch, open its pull request (⚠️ base = your own fork), wait for
the green check and merge it:

```bash
git push -u origin hot-chocolate
```

- Sends Priya's branch to your fork.

Now push Mei's branch and open its pull request (⚠️ base = your own fork again):

```bash
git push -u origin iced-tea
```

- Sends Mei's branch to your fork.

✅ **Checkpoint:** the pull request says **This branch has conflicts that must be
resolved** and names `menu.json`; **Merge pull request** is greyed out. The
check doesn't run at all: the box says *Checks awaiting conflict resolution*
and `test` is **Expected — Waiting for status to be reported**. GitHub tests
what the merge would give, and there is no merge to test until the conflict
is resolved.

❓ **Check your understanding:** both branches only **added** lines. Why is that
a conflict?

<details><summary>Answer</summary>

They added different lines **at the same place**: after the autumn special,
before the final `]`. Git can't tell whether hot chocolate goes first, iced tea
goes first, or only one of them should stay. "Same place, different change"
is a conflict, even if nothing was deleted.
</details>

### Goal 8.4: Bring `main` into your branch

The fix happens on **your** branch, on your laptop, where you can run the
tests. First get the newest `main`:

```bash
git switch main
```

- Back to your local `main`.

```bash
git pull
```

- Brings in Priya's merged hot chocolate.

```bash
git switch iced-tea
```

- Back to Mei's branch.

```bash
git merge main
```

- Merge everything new on `main` (Priya's hot chocolate) **into** your branch.

✅ **Checkpoint:**

```text
Auto-merging menu.json
CONFLICT (content): Merge conflict in menu.json
Automatic merge failed; fix conflicts and then commit the result.
```

Open `menu.json`. The end of the file now holds both versions between markers:

```text
  {
    "sku": "D06",
<<<<<<< HEAD
    "name": "Iced tea",
    "category": "drink",
    "price": "2.20",
    "icon": "🧊"
=======
    "name": "Hot chocolate",
    "category": "drink",
    "price": "2.70",
    "icon": "🍫"
>>>>>>> main
  }
]
```

| Marker | Means |
|---|---|
| `<<<<<<< HEAD` | Start of **your** version (the branch you're on: **Current**) |
| `=======` | The line between the two versions |
| `>>>>>>> main` | End of the version coming **in** from `main` (**Incoming**) |

Notice that Git shared out the lines both sides had in common (`{` and
`"sku": "D06",`) and only marked the lines that differ.

### Goal 8.5: Resolve it in VS Code's merge editor

Click **Resolve in Merge Editor** (bottom right of the editor). You get three
panes: **Incoming** (from `main`, Priya's) and **Current** (yours, Mei's) at the
top, and the **Result** at the bottom: what the file will be.

⚠️ **Don't just click *Accept Incoming* or *Accept Current*.** Either one throws
a teammate's work away. And look hard before accepting **both**: the conflict
is only the lines from `"name"` to `"icon"`, so taking both sides can put
**two names, two prices and two icons inside one item**, not two items.
Python's JSON reader quietly keeps only the last of each, so the tests may
even pass while iced tea vanishes from the menu. A merge tool combines
lines; it doesn't know what they mean.

Build the result yourself. The **Result** pane is an ordinary editor: make the
end of the file read exactly like this (hot chocolate first, because it's
already on `main`; iced tea gets the next SKU, `D07`):

```json
  {
    "sku": "D06",
    "name": "Hot chocolate",
    "category": "drink",
    "price": "2.70",
    "icon": "🍫"
  },
  {
    "sku": "D07",
    "name": "Iced tea",
    "category": "drink",
    "price": "2.20",
    "icon": "🧊"
  }
]
```

- Two separate items, each with its own `{ }`, a comma between them, and
  different SKUs.

Then click **Complete Merge**.

💡 No merge editor? Edit the markers directly in the file: delete the three
marker lines and arrange the rest as above. The markers are just text.

### Goal 8.6: Prove it, then finish the merge

```bash
uv run pytest
```

- Runs the tests on the merged menu, before anything is committed.

✅ **Checkpoint:** `6 passed`. If you kept `D06` for both items,
`test_skus_are_unique` fails: Dan's promise just caught a merge mistake. If
you forgot a comma, the tests can't even load the menu and pytest reports an
error while collecting `tests/test_menu.py`.

```bash
git status
```

- Shows where the merge stands.

✅ **Checkpoint:** `You have unmerged paths.` and `both modified:   menu.json`.
Git doesn't look inside the file to see whether you've fixed it: you tell it,
with `git add`.

```bash
git add menu.json
```

- Tells Git this file's conflict is resolved. Run `git status` again and it
  says `All conflicts fixed but you are still merging.`

```bash
git commit --no-edit
```

- Makes the **merge commit**, with Git's ready-made message
  (`Merge branch 'main' into iced-tea`). `--no-edit` skips opening an editor
  for the message.

```bash
git push
```

- Sends the merge commit to `iced-tea` on your fork; the pull request updates.

✅ **Checkpoint:** the pull request no longer shows a conflict, the check runs
and goes green, and you can merge it. `main` has both drinks.

💬 **Discuss:** Git found the conflict, the tests found the duplicate SKU, but
only a person could decide which drink keeps `D06`, and only a person would
notice if one drink had vanished. Who should make that call on a team? (The
person resolving it, ideally after a quick word with the other author: here,
Priya.)

❓ **Check your understanding:** why merge `main` into your branch on your
laptop, rather than using GitHub's web editor?

<details><summary>Answer</summary>

Either works for a small conflict, and GitHub's **Resolve conflicts** button is
fine for a one-line text change. On your laptop, though, you can **run the
tests before you push** (as you just did), use the merge editor, and check the
page in a browser. For anything more than a line, test it where you can run it.
</details>

---

## Try It Yourself

1. **Pin everything.** On a new branch, pin every `uses:` in `ci.yml` to a full
   commit SHA with the version in a comment (Goal 7.1). Take it round the loop.
   Does the check stay green?
2. **Ship a change.** Change `MENU_TITLE`'s default in `app.py` to
   `"NovaStack café"`, round the loop, then pull and run the **new** tag. How do
   you know you're running the new image and not the old one?
3. **Break the build on `main`?** With the ruleset on, can a commit with a
   failing test ever trigger `publish`? Explain using `needs` and the ruleset.
4. **A conflict you can't merge by combining.** Make two branches that change
   the Flat white's price to different values (`3.10` and `2.50`) and resolve
   the conflict. What's different about this one?

<details><summary>Answers</summary>

1. It should stay green: a SHA names the same code as the tag did, just in a
   way nobody can move. If it goes red at *Set up job*, a SHA was copied wrongly.
2. The tag is the first 7 characters of the merge commit, so a new merge gives a
   new tag; the page shows the image name (from `IMAGE_NAME`) and the new title.
3. No. The ruleset stops a red pull request being merged, so the push to `main`
   never happens; and even if it did, `publish` `needs: test`, so it wouldn't
   run.
4. Here there's no "keep both": one line, two values. Git and the merge editor
   can only show you the choice. **People** decide (here, Grace in Finance),
   then you accept one side. Merge conflicts are often questions for the team,
   not for the tool.
</details>

---

## Next

The Lecture 6 **labs**: *Your First Green Tick* (Beginner), *Make It
Production-Shaped* (Intermediate, where Step 7's habits are checked) and
*Bring CI to Orders* (Advanced). Each starts with the exercise, ORD-384.
