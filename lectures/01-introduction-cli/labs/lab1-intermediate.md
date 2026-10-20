# Lab 1 (Intermediate): Redirection, Pipes and Permissions

**Time:** about 35 minutes · **Work:** individually · **Setup:** see the [README](README.md) first

## Scenario

You are investigating a server log and preparing a deployment script for release. You will capture command output, filter the log with pipelines, and make the script executable.

## Learning outcomes

By the end of this lab you can:

- Redirect command output and errors to files, and combine commands with pipes.
- Filter and summarise text with `grep`, `sort`, `head` and `wc`.
- Interpret file permissions, and change them in symbolic and numeric mode.

## Before you start

Complete the setup in the [README](README.md). Then make sure the working folder exists (this does nothing if you already created it in the Beginner lab):

```bash
mkdir -p ~/linux-lab/workspace
cd ~/linux-lab/workspace
```

Try each task first, opening **Hint** if you are stuck, then open **Solution** to check.

---

## Step 1: Redirection

*Every command has three streams: input (stdin), normal output (stdout) and errors (stderr).*

### Task 1.1: Save a long listing of `workspace` into `listing.txt` and print the file

<details><summary>Hint</summary>

`>` sends output to a file.

</details>

<details><summary>Solution</summary>

```bash
ls -la > listing.txt
cat listing.txt
```

`>` writes the output to the file instead of the screen. If the file already exists it is **overwritten**.

</details>

### Task 1.2: Add the line `extra line` to the **end** of `listing.txt` without losing what is there

<details><summary>Hint</summary>

`echo` prints text. `>>` appends.

</details>

<details><summary>Solution</summary>

```bash
echo "extra line" >> listing.txt
cat listing.txt
```

`>>` appends to the end of the file. The earlier content is kept.

</details>

### Task 1.3: Predict, then test: what happens if you run `ls -la > listing.txt` again? And `echo "extra line" > listing.txt`?

<details><summary>Solution</summary>

```bash
ls -la > listing.txt
cat listing.txt
echo "extra line" > listing.txt
cat listing.txt
```

Each `>` replaces the whole file: the first run replaces the old listing with a new one, and the second leaves only `extra line`. Using `>` where you meant `>>` is a common way to lose data.

</details>

### Task 1.4: Run `ls listing.txt nonexistent-file`. Then run it again so only the error message goes into `errors.txt`, and print the file

<details><summary>Hint</summary>

stderr is stream number 2: `2>`.

</details>

<details><summary>Solution</summary>

```bash
ls listing.txt nonexistent-file
ls listing.txt nonexistent-file 2> errors.txt
cat errors.txt
```

The first command prints two lines: an error for the missing file, and `listing.txt` for the one that exists. Both look the same on screen, but they travel on different streams.

The second command prints only `listing.txt`: the normal output (stdout) still goes to the screen, while the error (stderr) went to the file. Expected from `cat`: `ls: cannot access 'nonexistent-file': No such file or directory` (wording differs slightly on macOS).

`>` only redirects stdout (stream 1); `2>` redirects stderr (stream 2). Try `ls listing.txt nonexistent-file > output.txt` to see the reverse: the error stays on screen and `listing.txt` goes into the file.

</details>

---

## Step 2: Pipes and text tools

*A pipe `|` sends the output of one command into the next as its input. Small tools, composed.*

The next tasks use `server.log` (120 lines: date, time, level, service, message) and `team.txt` (unsorted names). Work from `~/linux-lab`:

```bash
cd ~/linux-lab
```

### Task 2.1: How many lines does `server.log` have?

<details><summary>Hint</summary>

Run `wc --help` to see its options. `-l` counts lines.

</details>

<details><summary>Solution</summary>

```bash
wc -l server.log
```

Expected: `120 server.log`. `wc` = word count; `-l` counts lines.

</details>

### Task 2.2: Show only the `ERROR` lines, and count them

<details><summary>Hint</summary>

`grep` filters lines. Then pipe into `wc -l`.

</details>

<details><summary>Solution</summary>

```bash
grep ERROR server.log
grep ERROR server.log | wc -l
```

Expected: 12 lines, then `12`. `grep` prints the lines that contain a pattern; the pipe passes them into `wc -l` to be counted.

</details>

### Task 2.3: Show only the first 3 `ERROR` lines

<details><summary>Hint</summary>

Run `head --help`. `-n 3` (or the shorthand `-3`) shows the first 3 lines of its input.

</details>

<details><summary>Solution</summary>

```bash
grep ERROR server.log | head -3
```

Expected:

```
2026-10-05 09:03:00 ERROR db: timeout waiting for reply
2026-10-05 09:08:00 ERROR auth: timeout waiting for reply
2026-10-05 09:13:00 ERROR db: timeout waiting for reply
```

</details>

### Task 2.4: How many `ERROR` lines come from the `auth` service? Use two `grep`s in one pipeline

<details><summary>Hint</summary>

`grep ... | grep ... | wc -l`.

</details>

<details><summary>Solution</summary>

```bash
grep ERROR server.log | grep "auth:" | wc -l
```

Expected: `6`. Each stage narrows the result: all lines, then errors, then `auth` errors, then a count.

</details>

### Task 2.5: Print `team.txt` sorted alphabetically, then only the first 3 names of the sorted list

<details><summary>Hint</summary>

`sort`, then `head`.

</details>

<details><summary>Solution</summary>

```bash
sort team.txt
sort team.txt | head -3
```

Expected from the second command: `Alice`, `Bianca`, `Chen`.

</details>

### Task 2.6: Count how many entries are in `/usr/bin`, then list only the ones containing `python`

<details><summary>Hint</summary>

`ls /usr/bin | ...`

</details>

<details><summary>Solution</summary>

```bash
ls /usr/bin | wc -l
ls /usr/bin | grep python
```

The count varies between machines (typically a few thousand). The same pipeline idea, with a larger input, is how engineers process production logs.

</details>

### Task 2.7: Save the last 3 `ERROR` lines from the `db` service into a file called `db-errors.log` in `~/linux-lab/workspace`

<details><summary>Hint</summary>

Build the pipeline as in Tasks 2.3 and 2.4, then add `>` at the end. `tail` is the counterpart of `head` (see `tail --help`).

</details>

<details><summary>Solution</summary>

```bash
grep ERROR server.log | grep "db:" | tail -3 > workspace/db-errors.log
cat workspace/db-errors.log
```

Expected:

```
2026-10-05 09:33:00 ERROR db: timeout waiting for reply
2026-10-05 09:43:00 ERROR db: timeout waiting for reply
2026-10-05 09:53:00 ERROR db: timeout waiting for reply
```

Nothing appears on screen when the pipeline runs: `>` captures the output of the **last** stage. Redirection and pipes combine freely.

</details>

---

## Step 3: The permission model

### Task 3.1: Create `script.sh` in `workspace` and read its permissions

<details><summary>Hint</summary>

Use the long-listing option of `ls` (`ls --help` lists it): `-l`.

</details>

<details><summary>Solution</summary>

```bash
cd workspace
touch script.sh
ls -l script.sh
```

Expected, similar to:

```
-rw-r--r-- 1 you you 0 Oct  5 09:00 script.sh
```

</details>

### Task 3.2: Read the ten-character string `-rw-r--r--` field by field. Who can do what?

<details><summary>Solution</summary>

| Characters | Meaning |
|---|---|
| `-` | File type: `-` regular file, `d` directory, `l` link |
| `rw-` | **Owner**: read and write, no execute |
| `r--` | **Group**: read only |
| `r--` | **Everyone else**: read only |

`r` = read, `w` = write, `x` = execute, `-` = not allowed. The owner and group names appear after the permissions.

</details>


---

## Step 4: Changing permissions

*The deployment script `deploy.sh` has been handed to you. It does not run yet.*

### Task 4.1: Go to `~/linux-lab` and check the permissions of `deploy.sh`. Then try to run it

<details><summary>Hint</summary>

`./deploy.sh` runs a file from the current folder.

</details>

<details><summary>Solution</summary>

```bash
cd ..
ls -l deploy.sh
./deploy.sh
```

Expected: `-rw-r--r--` (no `x` anywhere) and `Permission denied`. The file can be read and edited, but not executed.

</details>

### Task 4.2: Add execute permission, check the result, and run the script

<details><summary>Hint</summary>

Run `chmod --help` (or `man chmod` for the full description of modes). `+x` adds execute permission.

</details>

<details><summary>Solution</summary>

```bash
chmod +x deploy.sh
ls -l deploy.sh
./deploy.sh
```

Permissions now read `-rwxr-xr-x`, and the script prints `Deploying release 1.0...` and `Done.`

`chmod` = change mode. `+x` adds execute for everyone.

</details>

### Task 4.3: Use **symbolic** mode to remove execute from the owner only, then give it back

<details><summary>Hint</summary>

`man chmod` describes symbolic modes: `u` = owner (user), `g` = group, `o` = others; `-x` removes execute, `+x` adds it.

</details>

<details><summary>Solution</summary>

```bash
chmod u-x deploy.sh
ls -l deploy.sh
chmod u+x deploy.sh
ls -l deploy.sh
```

After `u-x` the string is `-rw-r-xr-x` (the owner keeps read and write). After `u+x` it is `-rwxr-xr-x` again. Letters can combine: `chmod go-w file` removes write from group and others.

</details>

### Task 4.4: Use **numeric** mode to set `-rw-r--r--`, then `-rwxr-xr-x`

<details><summary>Hint</summary>

`man chmod` describes numeric (octal) modes: read = 4, write = 2, execute = 1, added up for each of owner, group and others.

</details>

<details><summary>Solution</summary>

```bash
chmod 644 deploy.sh
ls -l deploy.sh
chmod 755 deploy.sh
ls -l deploy.sh
```

- `6` = 4+2 = `rw-`, `4` = `r--`, so `644` = `rw-r--r--`.
- `7` = 4+2+1 = `rwx`, `5` = 4+1 = `r-x`, so `755` = `rwxr-xr-x`.

Give a file the **minimum** permissions it needs (least privilege): `755` suits a script, `644` suits a document. Misconfigured permissions are a recurring finding in cloud security audits.

</details>


---

## Reflection

1. What is the difference between `>`, `>>` and `2>`?
2. Why give a script `755` and a document `644` rather than `777` for both?

<details><summary>Notes</summary>

1. `>` writes stdout to a file and overwrites it; `>>` appends stdout; `2>` writes stderr (error messages) to a file.
2. Least privilege: a file should have only the permissions its task needs. `755` lets everyone run the script but only the owner change it; a document needs no execute bit.

</details>

---

## Troubleshooting

| Problem | Likely cause | Fix |
|---|---|---|
| `No such file or directory` | You are in a different folder from the one the step expects | Run `pwd`, then `cd` to the folder the task names. |
| `grep: server.log: No such file or directory` | You are not in `~/linux-lab` | `cd ~/linux-lab`, then repeat. |
| `./deploy.sh: Permission denied` after `chmod` | The `chmod` was run on a different folder or file, or `linux-lab` is on a Windows drive (`/mnt/c`) | Run `ls -l deploy.sh` to check, use `cd ~/linux-lab` first, and move the folder into your WSL home. |
| `deploy.sh` runs **before** `chmod` in Task 4.1 | The unzip tool kept or set the execute bit | Run `chmod 644 deploy.sh`, then continue. |
| The file is empty after redirecting | You used `>` on a file you meant to append to, or the command printed nothing | Check the command, and use `>>` to append. |

