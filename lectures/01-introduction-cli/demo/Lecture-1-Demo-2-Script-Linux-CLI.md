# Lecture 1 · Demo 2: The 3 AM Page, Solved by Hand With the CLI

**Mastering Computer Science Technical Competencies** · Lecture 1: Introduction to the Command Line

---

## The Scenario: The 3 AM Page

It's your first day at **NovaStack**. At 3:12 AM last night, the checkout service went down. Jordan, last night's on-call engineer, patched it enough to limp through the morning, then went home to sleep and left you a note. Let's find out what actually happened.

**README.txt (Jordan's note):**

> Hey, whoever's on call today.
> Checkout died around 3AM. I patched it enough to limp along but didn't have time to dig into the actual cause. Logs are in logs/.
> I know there was a script to restart the service but I can't find it for the life of me, in this new repo.
> Also, novastack-diag stopped working (don't know why or where it is) so diagnostics are out of whack.
> Good luck.
> — Jordan

---

## About This Demo

In this lecture, we'll solve the same incident in three different ways:

| Guide | Approach | What it shows |
|---|---|---|
| [Demo 0](Lecture-1-Demo-0-Setup.md) | Setup | Preparing Docker, the incident files and the AI agent |
| [Demo 1](Lecture-1-Demo-1-Script-AI-Plan.md) | One prompt to an AI agent in **plan mode** | How an AI agent reasons about a problem before acting |
| **Demo 2 (this one)** | Classic CLI commands, typed by hand | The skills you need to do the work, and to check the AI's work |
| [Demo 3](Lecture-1-Demo-3-Script-AI-Individual-Commands.md) | The same steps as Demo 2, as plain-English requests to the AI agent | How each command maps to a natural-language request |

> **This is the demo that makes the other two safe.** In Demo 1, an AI agent planned the investigation. Here, we do every step ourselves. These are the commands that let you read what an agent does, decide whether to approve it, and check whether it's right.

**Time:** about 25 minutes.

| Step | Title | Commands you'll use |
|---|---|---|
| 1 | Arrive at the Scene | `pwd`, `ls`, `tree`, `cd`, `cat` |
| 2 | Clean Up the Workspace | `mkdir`, `mv`, `rm` |
| 3 | Read the Evidence | `cat`, `less`, `wc`, `head`, `tail` |
| 4 | Find the Smoking Gun | `find`, `grep` |
| 5 | Spot the Pattern | `\|`, `sed`, `sort`, `uniq`, `touch`, `>` |
| 6 | Get Help | `--help`, `less`, `man` |
| 7 | The Locked Door | `ls -l`, `./`, `chmod` |
| 8 | The Missing Tool | `echo`, `$PATH`, `tr`, `find`, `$( )`, `dirname`, `export`, `which` |
| 9 | The Rogue Process | `ps aux`, `grep`, `kill`, `pkill`, `pgrep` |
| 10 | Case Closed | `echo`, `>>`, `cat` |

### What you'll learn

- How to **navigate** and **manage files** from the command line.
- How to **search** and **analyse** large log files by chaining small commands with **pipes**.
- How **permissions**, the **`PATH`** and **processes** work, and how to fix common problems with each.

### Before you start

- Complete **[Demo 0: Setup](Lecture-1-Demo-0-Setup.md)**: the container is running.
- Start from a **fresh incident** (see [Demo 0, Step 6](Lecture-1-Demo-0-Setup.md#step-6-reset-the-incident-between-demos)).
- Check you're **inside the container**: your prompt looks like `root@a1b2c3d4e5f6:/workspace#`.

### How to use this script

| Icon | Meaning |
|---|---|
| ✅ | **Checkpoint:** what you should see if everything worked |
| ❓ | **Check your understanding:** a quick question. Click *Answer* to reveal it. |
| 💬 | **Discuss:** a question to talk through with the class or your lab partner |
| ⚠️ | **Warning:** something that can go wrong or cause damage |
| 💡 | **Tip:** a useful extra |

> 💡 Every command in this demo is typed **inside the container**.

---

## Step 1: Arrive at the Scene

*You've just logged in. Let's find out where we are, see what's here, and read Jordan's note.*

### Goal 1.1: Find out where you are

```bash
pwd
```

- `pwd` = **p**rint **w**orking **d**irectory: shows the full path of the folder you're in.

✅ **Checkpoint:** `/workspace`

### Goal 1.2: List everything here, with details

```bash
ls -la
```

- `ls` = list the contents of a folder.
- `-l` = long format: shows permissions, owner, size and date.
- `-a` = all files, including hidden ones whose names start with `.`

You'll see a line like this:

```
drwxr-xr-x 5 root root 4096 Oct  3 16:44 checkout-incident
```

Let's read it from left to right:

| Part | Meaning |
|---|---|
| `d` | The type: `d` = directory, `-` = regular file, `l` = link (shortcut) |
| `rwx` | What the **owner** can do: **r**ead, **w**rite, e**x**ecute |
| `r-x` | What the **group** can do (`-` means "not allowed") |
| `r-x` | What **everyone else** can do |
| `root root` | The owner and the group |
| `4096` | The size in bytes |
| `Oct  3 16:44` | When it was last changed |
| `checkout-incident` | The name |

The `.` and `..` lines are special: `.` means "this folder" and `..` means "the folder above".

### Goal 1.3: See the whole structure as a tree

```bash
tree
```

- `tree` = show folders and files as a tree, so you can see the whole layout at once.

✅ **Checkpoint:** you see `checkout-incident` containing `README.txt`, `bin`, `logs`, `notes.tmp`, `old_backup_DO_NOT_USE.log` and `scripts`.

### Goal 1.4: Move into the incident folder

```bash
cd checkout-incident
```

- `cd` = **c**hange **d**irectory.

### Goal 1.5: Read Jordan's note

```bash
cat README.txt
```

- `cat` = print a file's contents to the screen. (The name comes from con**cat**enate, because it can join files together.)

✅ **Checkpoint:** you see Jordan's note from the scenario.

💬 **Discuss:** Jordan's note gives us three leads. What are they? (They're the logs, the missing restart script and the broken diagnostic tool. We'll follow all three.)

---

## Step 2: Clean Up the Workspace

*Before digging into the logs, let's tidy up so we don't trip over junk files later. Real engineers clean their workspace first.*

### Goal 2.1: Create an archive folder

```bash
mkdir archive
```

- `mkdir` = **m**a**k**e **dir**ectory.

### Goal 2.2: Move the old backup into the archive

```bash
mv old_backup_DO_NOT_USE.log archive/
```

- `mv` = **m**o**v**e (it also renames files).
- The first argument is the **source** (what to move); the second is the **destination** (where to put it).

💬 **Discuss:** why archive the backup instead of deleting it? "Do not use" isn't the same as "delete": it might be the only copy of something important. In Demo 1, the AI agent wanted to delete it.

### Goal 2.3: Check, then delete, the scratch notes

Let's look before we delete:

```bash
cat notes.tmp
```

It says `scratch notes, ignore`. Safe to remove:

```bash
rm notes.tmp
```

- `rm` = **r**e**m**ove (delete) a file.

> ⚠️ **`rm` is permanent.** There's no Recycle Bin or Trash on the command line. Always check what you're deleting first, as we just did.

✅ **Checkpoint:** `ls` shows `README.txt`, `archive`, `bin`, `logs` and `scripts`, with no `notes.tmp` or backup file.

---

## Step 3: Read the Evidence

*Nobody reads three thousand lines of logs from top to bottom. Let's use tools to see the shape of the file.*

### Goal 3.1: Move into the logs folder

```bash
cd logs
```

```bash
ls
```

✅ **Checkpoint:** two files: `checkout.log` and `payment-worker.log`.

### Goal 3.2: Try printing the whole log

```bash
cat checkout.log
```

Notice what happens: thousands of lines fly past, and only the last screen is left. That's why we need a better tool.

### Goal 3.3: Browse it one screen at a time

```bash
less checkout.log
```

- `less` = a **pager**: shows a file one screen at a time.
- `Space` = next page, `b` = back a page, `j` / `k` = down / up one line.
- `/word` = search for "word", then `n` for the next match.
- `q` = quit.

### Goal 3.4: Count the lines

```bash
wc -l checkout.log
```

- `wc` = **w**ord **c**ount. With `-l`, it counts **l**ines instead.

✅ **Checkpoint:** `2950 checkout.log`

### Goal 3.5: Look at the beginning and the end

```bash
head -20 checkout.log
```

```bash
tail -20 checkout.log
```

- `head -20` = show the first 20 lines.
- `tail -20` = show the last 20 lines.

✅ **Checkpoint:** the log starts at `02:00:01` and ends at `02:49:10`. Every line says `INFO ... request processed successfully`.

💬 **Discuss:** the checkout log stops at 02:49:10, but the outage was at 3:12. Is that a clue? In this practice environment, the log was **generated by a script** that simply ran out of lines at 02:49:10. In Demo 1, the AI agent treated this gap as meaningful. A real engineer asks: *what else could explain it?*

---

## Step 4: Find the Smoking Gun

*Jordan said the logs hold the clue. Let's search for the worst messages first ("FATAL"), then all the errors.*

### Goal 4.1: Find all the log files

```bash
find . -name "*.log"
```

- `find` = search for files by name, type, size and more.
- `.` = start searching here, including every folder below.
- `-name "*.log"` = match names ending in `.log`. The `*` is a **wildcard** meaning "any characters".

✅ **Checkpoint:** `./checkout.log` and `./payment-worker.log`

💡 `find .. -name "*.log"` searches from the folder **above**, so it also finds `../archive/old_backup_DO_NOT_USE.log`.

### Goal 4.2: Search for fatal errors

```bash
grep -i "fatal" *.log
```

- `grep` = search inside files for lines that match a pattern.
- `-i` = case-**i**nsensitive: matches `fatal`, `Fatal` and `FATAL`.
- `*.log` = search every file ending in `.log`.

✅ **Checkpoint:**

```
payment-worker.log:03:12:04 FATAL payment-worker: connection pool exhausted, shutting down
```

Because we searched more than one file, `grep` starts each line with the file name, then a colon.

### Goal 4.3: Search for all errors

```bash
grep -i "error" *.log
```

Lots of lines, all from `payment-worker.log`. How many exactly? Let's count per file:

```bash
grep -ic "error" *.log
```

- `-c` = **c**ount matching lines instead of printing them.

✅ **Checkpoint:** `checkout.log:0` and `payment-worker.log:47`

---

## Step 5: Spot the Pattern

*Forty-seven errors are too many to read one by one. Let's join small commands together with **pipes** to summarise them.*

### Goal 5.1: Count each type of error

We'll build one command step by step, adding one stage at a time. Run each stage and watch how the output changes.

**Stage 1: find all the error lines**

```bash
grep -i "error" *.log
```

**Stage 2: remove the file name and timestamp**

```bash
grep -i "error" *.log | sed 's/[^ ]* //'
```

- `|` = a **pipe**: send the output of the command on the left into the command on the right.
- `sed` = **s**tream **ed**itor: edits text as it flows through.
- `s/[^ ]* //` = **s**ubstitute: replace the first word (the file name and timestamp, e.g. `payment-worker.log:03:11:11`) and the space after it with nothing.
- `[^ ]*` = "any run of characters that aren't spaces".

Now each line is just the message, such as `ERROR payment-worker: connection refused (payment-gateway:5432)`. Without the timestamps, identical messages really are identical.

**Stage 3: sort the lines so identical ones sit together**

```bash
grep -i "error" *.log | sed 's/[^ ]* //' | sort
```

**Stage 4: count each group of identical lines**

```bash
grep -i "error" *.log | sed 's/[^ ]* //' | sort | uniq -c
```

- `uniq -c` = merge identical lines **that sit next to each other**, and put a **c**ount in front.

**Stage 5: put the most common first**

```bash
grep -i "error" *.log | sed 's/[^ ]* //' | sort | uniq -c | sort -rn
```

- `sort -rn` = sort **n**umerically (by the count), in **r**everse order (highest first).

✅ **Checkpoint:**

```
     20 ERROR payment-worker: connection timeout (payment-gateway:5432)
     18 ERROR payment-worker: connection refused (payment-gateway:5432)
      9 ERROR payment-worker: request queued but gateway unresponsive
```

❓ **Check your understanding:** why do we need the first `sort` (Stage 3) before `uniq -c`?

<details><summary>Answer</summary>

`uniq` only merges identical lines that are **next to each other**. Try this:

```bash
printf "a\nb\na\n" | uniq -c
```

You get three lines (1 a, 1 b, 1 a), because the two `a` lines aren't together. Sorting first puts identical lines side by side. Our log happens to be in order already, so skipping `sort` would work here by luck, but not on real, mixed-up logs. `sort | uniq -c | sort -rn` is a pattern you'll use again and again.

</details>

💬 **Discuss:** reading the counts in time order (refused, then timeouts, then "queued but unresponsive", then FATAL), what story do they tell about the payment gateway?

### Goal 5.2: Start the incident report

Let's save our key finding into a report file in the folder above (`..`):

```bash
touch ../incident-report.md
```

- `touch` = create an empty file (or update the date on an existing one).

```bash
grep -i "fatal" *.log > ../incident-report.md
```

- `>` = **redirect**: save the output to a file instead of printing it. If the file already exists, it is **overwritten**.

💡 `>` creates the file if it doesn't exist, so the `touch` wasn't strictly needed. We used it to show what `touch` does.

### Goal 5.3: Read the report

```bash
cat ../incident-report.md
```

✅ **Checkpoint:**

```
payment-worker.log:03:12:04 FATAL payment-worker: connection pool exhausted, shutting down
```

---

## Step 6: Get Help

*Mid-investigation, you can't remember the exact option for `uniq`. Rather than guess, let's check the built-in documentation.*

### Goal 6.1: Quick help with `--help`

```bash
uniq --help
```

Most commands print a short summary of their options with `--help`. If it's too long for the screen, send it through the pager:

```bash
uniq --help | less
```

Press `q` to quit.

### Goal 6.2: The full manual with `man`

```bash
man uniq
```

- `man` = show the full **man**ual page for a command.
- `Space` = next page, `/word` = search, `n` = next match, `q` = quit.

### Goal 6.3: Find a specific option

Which option shows **only** the lines that are repeated? Inside `man uniq`, type `/repeated` and press **Enter**. Or search the help text with `grep`:

```bash
uniq --help | grep -- "-d"
```

- `--` = "no more options for `grep`", so `grep` searches for `-d` instead of treating it as one of its own options.

✅ **Checkpoint:** `-d, --repeated        only print duplicate lines, one for each group`

💬 **Discuss:** `man` and `--help` describe the exact version installed on *this* machine. In Demo 3, we'll ask an AI the same question. Which source would you trust more, and why?

---

## Step 7: The Locked Door

*Jordan mentioned a restart script, but said it won't run. Let's find out why.*

### Goal 7.1: Go to the scripts folder

```bash
cd ../scripts
```

- `..` = the folder above (`checkout-incident`), then into `scripts`.

### Goal 7.2: Check the permissions

```bash
ls -l
```

✅ **Checkpoint:**

```
-rw-r--r-- 1 root root 90 Oct  3 16:44 restart-service.sh
```

Look at the permissions: `rw-` for the owner, and **no `x`** for anyone. The file can be read and edited, but not **executed** (run).

### Goal 7.3: Try to run it

```bash
./restart-service.sh
```

- `./` = "run this file from the current folder".

✅ **Checkpoint:** `Permission denied`. That's expected.

### Goal 7.4: Unlock it

```bash
chmod +x restart-service.sh
```

- `chmod` = **ch**ange **mod**e (change permissions).
- `+x` = add e**x**ecute permission.

```bash
ls -l
```

✅ **Checkpoint:** the permissions now read `-rwxr-xr-x`: everyone can execute it.

### Goal 7.5: Run it again

```bash
./restart-service.sh
```

✅ **Checkpoint:**

```
Restarting checkout service...
Service restarted. Uptime reset.
```

---

## Step 8: The Missing Tool

*Jordan said `novastack-diag` stopped working. Let's find out why the shell can't find it, and fix that.*

### Goal 8.1: Try to run it

```bash
cd /workspace
```

```bash
novastack-diag
```

✅ **Checkpoint:** `novastack-diag: command not found`

### Goal 8.2: See where the shell looks for commands

When you type a command name, the shell searches a list of folders called the **`PATH`**, in order, and runs the first match.

```bash
echo $PATH
```

- `echo` = print text.
- `$PATH` = the value of the `PATH` **environment variable**. The `$` means "the value of".

The folders are separated by colons, which is hard to read. Let's put each one on its own line:

```bash
echo $PATH | tr ':' '\n'
```

- `tr ':' '\n'` = **tr**anslate every `:` into a new line (`\n`).

✅ **Checkpoint:** a list of folders including `/usr/local/bin`, `/usr/bin` and `/bin`, but nothing inside `/workspace`.

### Goal 8.3: Find the tool

```bash
find . -name "novastack-diag"
```

✅ **Checkpoint:** `./checkout-incident/bin/novastack-diag`

That's a **relative** path (it starts from `.`). To add the folder to `PATH`, we want the **full** path. Let's give `find` the full path of where we are:

```bash
find $(pwd) -name "novastack-diag"
```

- `$( )` = **command substitution**: run the command inside first, and put its output here. So `$(pwd)` becomes `/workspace`.

✅ **Checkpoint:** `/workspace/checkout-incident/bin/novastack-diag`

### Goal 8.4: Keep just the folder

```bash
dirname $(find $(pwd) -name "novastack-diag")
```

- `dirname` = remove the last part of a path, leaving only the folder.

✅ **Checkpoint:** `/workspace/checkout-incident/bin`

### Goal 8.5: Add the folder to `PATH`

```bash
export PATH=$(dirname $(find $(pwd) -name "novastack-diag")):$PATH
```

Let's read this from the inside out:

1. `$(pwd)` becomes `/workspace`.
2. `$(find /workspace -name "novastack-diag")` becomes `/workspace/checkout-incident/bin/novastack-diag`.
3. `$(dirname ...)` becomes `/workspace/checkout-incident/bin`.
4. `PATH=/workspace/checkout-incident/bin:$PATH` puts that folder at the **front** of the existing `PATH`.
5. `export` makes the new `PATH` available to this shell and every program it starts.

💡 If you already know the folder, this simpler version does the same thing. Use it **instead of** the command above, not as well, or the folder appears in `PATH` twice:

```bash
export PATH=/workspace/checkout-incident/bin:$PATH
```

### Goal 8.6: Check that it worked

```bash
echo $PATH | tr ':' '\n'
```

✅ **Checkpoint:** `/workspace/checkout-incident/bin` is now the **first** line.

```bash
which novastack-diag
```

- `which` = show which file the shell will run for a command name.

✅ **Checkpoint:** `/workspace/checkout-incident/bin/novastack-diag`

```bash
novastack-diag
```

✅ **Checkpoint:**

```
NovaStack diagnostic tool v1
Checking known process leaks...
FOUND: orphaned leak-simulator process still running
```

The tool works, and it has found something. That's our next lead.

> ⚠️ **This change is temporary.** `export` only changes the `PATH` for this shell and the programs it starts. If you exit the container, or open a second shell with `docker exec`, `novastack-diag` won't be found again.

❓ **Check your understanding:** in Demo 3, an AI agent runs `export PATH=...` for you, then exits. Will `novastack-diag` work in *your* shell afterwards?

<details><summary>Answer</summary>

No. The agent runs its commands in its own **child** shell. Environment variables pass from a parent to its children, never back from a child to its parent. When the agent's shell exits, its `PATH` change disappears with it.

</details>

---

## Step 9: The Rogue Process

*`novastack-diag` says an orphaned `leak-simulator` process is still running. Let's find it and stop it.*

### Goal 9.1: List running processes

```bash
ps aux | grep python
```

- `ps aux` = list **all** running processes, with details. `a` = all users, `u` = show the user and CPU/memory use, `x` = include background processes.
- `| grep python` = keep only the lines containing "python".

✅ **Checkpoint:** two lines, similar to this:

```
root     9  0.0  0.1 ...  python3 /opt/demo-assets/leak-simulator.py
root    75  0.0  0.0 ...  grep python
```

The second column is the **PID** (process ID). The second line is our own `grep` command, which also contains the word "python".

💡 `ps aux | grep [p]ython` hides the `grep` line. The pattern `[p]ython` still matches "python", but the `grep` command's own text now reads `[p]ython`, which doesn't match.

> ⚠️ **Your PID will be different.** Use the number from **your** output, not the one above.

### Goal 9.2: Stop the process

Either stop it by its PID (replace `9` with yours):

```bash
kill 9
```

or by matching its name:

```bash
pkill -f leak-simulator
```

- `kill <PID>` = ask the process with that ID to stop.
- `pkill -f leak-simulator` = stop every process whose full command line (`-f`) contains `leak-simulator`.

> ⚠️ `pkill -f` stops **every** match. Run `pgrep -f leak-simulator` first to see what would be stopped.

### Goal 9.3: Check that it's gone

```bash
pgrep -f leak-simulator
```

- `pgrep` = print the PIDs of matching processes.

✅ **Checkpoint:** no output, because nothing matches any more.

```bash
novastack-diag
```

✅ **Checkpoint:** `No process leaks detected.`

---

## Step 10: Case Closed

*We've followed all three leads. Let's record our conclusion and look at the final report.*

### Goal 10.1: Go back to the incident folder

```bash
cd /workspace/checkout-incident
```

### Goal 10.2: Add the root cause to the report

```bash
echo "Root cause: orphaned leak-simulator.py exhausted the connection pool to payment-gateway." >> incident-report.md
```

- `>>` = **append**: add to the end of the file, keeping what's already there.

❓ **Check your understanding:** what would have happened if we'd used `>` instead of `>>`?

<details><summary>Answer</summary>

`>` **overwrites** the file. The FATAL line we saved in Step 5 would be lost, and the report would contain only the root-cause line.

</details>

### Goal 10.3: Read the final report

```bash
cat incident-report.md
```

✅ **Checkpoint:**

```
payment-worker.log:03:12:04 FATAL payment-worker: connection pool exhausted, shutting down
Root cause: orphaned leak-simulator.py exhausted the connection pool to payment-gateway.
```

💬 **Discuss: is our root cause actually proven?** We just wrote that `leak-simulator.py` caused the outage. In Demo 1, the AI agent concluded something different: the **payment gateway failing** (refused connections, then timeouts, then the connection pool running out). Look at the evidence we gathered:

- Is there anything in the logs that mentions `leak-simulator`?
- Is there anything that links it to `payment-gateway:5432`?
- What *does* the evidence directly show?

**Both humans and AI can jump to conclusions. Always ask: what's the evidence?**

---

## Key Takeaways

1. **Navigation and files** (`pwd`, `ls`, `cd`, `mkdir`, `mv`, `rm`): know where you are, and check before you delete.
2. **Pipes join small tools** (`|`): each command does one job well, and `sort | uniq -c | sort -rn` turns noise into a summary.
3. **Redirection saves your work** (`>` overwrites, `>>` appends).
4. **Permissions control what can run** (`ls -l`, `chmod +x`).
5. **`PATH` decides which commands the shell can find** (`echo $PATH`, `export`, `which`), and `export` lasts only for the current shell.
6. **Processes can be found and stopped** (`ps aux`, `pgrep`, `kill`, `pkill`).
7. **Evidence beats assumptions.** Check your conclusions as carefully as you'd check an AI's.

---

## What's Next

In **[Demo 3](Lecture-1-Demo-3-Script-AI-Individual-Commands.md)**, we'll repeat these same ten steps by asking an AI agent in plain English, and use today's commands to check every answer it gives.

---

## Try It Yourself (Lab)

Reset the incident first if you've changed it (see [Demo 0, Step 6](Lecture-1-Demo-0-Setup.md#step-6-reset-the-incident-between-demos)), or carry on from where Step 10 left off.

### Challenge 1: Count requests in a time window

How many checkout requests were processed between **02:10** and **02:19**?

💡 Every line starts with its time. In a `grep` pattern, `^` means "at the start of the line".

<details><summary>Answer</summary>

```bash
grep -c "^02:1" /workspace/checkout-incident/logs/checkout.log
```

**600.** `^02:1` matches lines starting with `02:10` up to `02:19`, and `-c` counts them.

</details>

### Challenge 2: What changed most recently?

Which item in `/workspace/checkout-incident` was changed most recently?

💡 `ls` can sort by time. Check `ls --help`.

<details><summary>Answer</summary>

```bash
ls -lt /workspace/checkout-incident
```

`-t` sorts by modification time, newest first. If you've finished Step 10, `incident-report.md` is at the top.

</details>

### Challenge 3: Add the error summary to the report

Append the three error counts from Step 5 to the end of `incident-report.md`, without overwriting it.

<details><summary>Answer</summary>

```bash
cd /workspace/checkout-incident
grep -i "error" logs/*.log | sed 's/[^ ]* //' | sort | uniq -c | sort -rn >> incident-report.md
cat incident-report.md
```

We're now in `checkout-incident`, so the log path becomes `logs/*.log`. The `sed` still removes the first word, which now begins `logs/payment-worker.log:`.

</details>

### Challenge 4: Make `novastack-diag` available in every shell

The `export` in Step 8 only lasts for one shell. Make `novastack-diag` work in every new shell, until the container stops.

💡 In Demo 1, the AI agent suggested a **symlink** (a shortcut) in a folder that's already on `PATH`. Look up `ln` with `man ln`.

<details><summary>Answer</summary>

```bash
ln -s /workspace/checkout-incident/bin/novastack-diag /usr/local/bin/novastack-diag
ls -l /usr/local/bin/novastack-diag
```

`ln -s` creates a **s**ymbolic link. The listing shows `novastack-diag -> /workspace/checkout-incident/bin/novastack-diag`. Because `/usr/local/bin` is already on `PATH`, every shell finds it. It disappears when the container stops, because `/usr/local/bin` belongs to the container.

</details>

---

## Troubleshooting

For problems with Docker or the container, see **[Demo 0: Troubleshooting](Lecture-1-Demo-0-Setup.md#troubleshooting)**.

| Problem | Likely cause | Fix |
|---|---|---|
| `No such file or directory` | You're in a different folder from the one the step expects | Run `pwd` to check. Each step starts with a `cd` command. Go back to it. |
| `mkdir: cannot create directory 'archive': File exists`, or `mv: cannot stat 'old_backup_DO_NOT_USE.log'` | You (or an earlier demo) already did Step 2 | Carry on, or reset the incident for a clean run. |
| The screen is stuck after `less` or `man` | You're still inside the pager | Press `q`. |
| `cat checkout.log` floods the screen | Expected: that's the point of Goal 3.2 | Use `less`, `head` or `tail` instead. |
| `restart-service.sh` runs **before** you use `chmod` | Leftover from an earlier run (permissions survive a restart unless you delete the folder) | Do a full reset (Demo 0, Goal 6.1). |
| `novastack-diag: command not found` after Goal 8.5 | A typo in the `export` line, or you're in a new shell | Run `echo $PATH \| tr ':' '\n'` to check, then run Goal 8.5 again. |
| `ps aux \| grep python` shows only the `grep` line | The leak simulator was already stopped (for example by an earlier demo) | Reset the incident (Demo 0, Step 6). |
| `kill: (9) - No such process` | You used the PID from this script, not your own | Use the PID from **your** `ps aux` output, or use `pkill -f leak-simulator`. |
| `incident-report.md` has only one line | You used `>` instead of `>>` in Step 10 | Re-run Goal 5.2, then Goal 10.2 with `>>`. |
