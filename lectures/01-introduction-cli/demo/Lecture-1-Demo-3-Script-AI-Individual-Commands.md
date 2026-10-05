# Lecture 1 · Demo 3: The 3 AM Page, Step by Step With an AI Agent

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
| [Demo 2](Lecture-1-Demo-2-Script-Linux-CLI.md) | Classic CLI commands, typed by hand | The skills you need to do the work, and to check the AI's work |
| **Demo 3 (this one)** | The same steps as Demo 2, as plain-English requests to the AI agent | How each command maps to a natural-language request |

> **Same ten steps, new way of working.** Each step here matches the same step in Demo 2. We ask the AI agent in plain English, then **check its answer with the Demo 2 commands**. The agent is fast, but you still read what it ran, approve its risky actions and verify its claims, and all three need the skills from Demo 2.

**Time:** about 20 minutes.

| Step | Title | What we ask the agent | Check it with (Demo 2) |
|---|---|---|---|
| 1 | Arrive at the Scene | Where am I, and what does the note say? | `pwd`, `tree`, `cat` |
| 2 | Clean Up the Workspace | Archive the backup, delete the scratch file | `ls -la` |
| 3 | Read the Evidence | Summarise a large log file | `wc -l`, `head`, `tail`, `grep -v` |
| 4 | Find the Smoking Gun | Find every error and fatal message | `find`, `grep` |
| 5 | Spot the Pattern | Group and count the errors, then save a summary to a file | `sed \| sort \| uniq -c \| sort -rn` |
| 6 | Get Help | Which option do I need? What does this command do? | `--help`, `man` |
| 7 | The Locked Door | Find out why the script won't run, and fix it | `ls -l` |
| 8 | The Missing Tool | Make `novastack-diag` work, then spot the trap | `which`, `echo $PATH` |
| 9 | The Rogue Process | Find and stop the suspicious process | `ps aux`, `pgrep` |
| 10 | Case Closed | Write the report, then challenge it | `cat` |

### What you'll learn

- Two ways to use an AI CLI: **print mode** (`agy -p`, one question and one answer) and **interactive mode** (`agy`, a conversation where the agent acts).
- How to combine an AI agent with the shell: feed it data with **command substitution** and save its answers with **redirection**.
- How to **verify** every AI answer with deterministic commands, and why that matters.

### Before you start

- Complete **[Demo 0: Setup](Lecture-1-Demo-0-Setup.md)**: the container is running, you're signed in to `agy`, and the permissions are set.
- Start from a **fresh incident**. This matters most here: Demo 2 fixed everything, so without a reset there's nothing left to solve (see [Demo 0, Step 6](Lecture-1-Demo-0-Setup.md#step-6-reset-the-incident-between-demos)).
- Check you're **inside the container**: your prompt looks like `root@a1b2c3d4e5f6:/workspace#`.

### How to use this script

| Icon | Meaning |
|---|---|
| ✅ | **Checkpoint:** what you should see if everything worked |
| ❓ | **Check your understanding:** a quick question. Click *Answer* to reveal it. |
| 💬 | **Discuss:** a question to talk through with the class or your lab partner |
| ⚠️ | **Warning:** something that can go wrong or cause damage |
| 💡 | **Tip:** a useful extra |

> ⚠️ **AI output changes from run to run.** The prompts in this script are fixed, but the agent's answers are not. Expect different wording each time, and occasionally a wrong answer. That's exactly why every step ends with a check.

**Two ways we'll call the agent:**

- `agy -p "..."` = **print mode**: one question, one answer, then back to the shell, just like `grep` or `wc`. We use it for questions and summaries.
- `agy` = **interactive mode**: a conversation where the agent can run commands and change files. We use it whenever the agent needs to *act*, because only interactive mode can stop and ask you to approve a risky command. Type `/quit` to leave.

---

## Step 1: Arrive at the Scene

*Same 3 AM page. This time, instead of exploring with five commands, let's just ask.*

### Goal 1.1: Ask where you are and what's going on

```bash
cd /workspace/checkout-incident
```

```bash
agy -p "Where am I? Show me the folder structure here, then summarise README.txt in three bullet points: what broke, what's missing, and what I should do first."
```

Notice that one sentence replaced `pwd`, `ls -la`, `tree` and `cat`. Behind the scenes, the agent ran commands like those to find the answer.

💬 **Discuss:** which commands do you think the agent ran? Look at its output for clues.

### Goal 1.2: Check it with Demo 2 commands

```bash
pwd && tree && cat README.txt
```

- `&&` = run the next command only if the previous one succeeded.

✅ **Checkpoint:** the agent's folder structure and summary match what you see: `README.txt`, `bin`, `logs`, `notes.tmp`, `old_backup_DO_NOT_USE.log` and `scripts`, and Jordan's three leads.

---

## Step 2: Clean Up the Workspace

*The same cleanup as Demo 2, but this time the agent does the work, and asks before deleting anything.*

### Goal 2.1: Let the agent change files

The agent needs to *act* here, so we use interactive mode:

```bash
agy
```

Type this prompt:

```text
Create a folder called archive, move old_backup_DO_NOT_USE.log into it, then show me what's in notes.tmp and delete it.
```

Watch what happens:

- `mkdir` and `mv` run straight away, because they're on the `allow` list.
- `rm notes.tmp` stops and **asks for your approval**, because `rm` is on the `ask` list from Demo 0.

💬 **Discuss:** would you approve `rm notes.tmp` if you didn't know what `rm` does? This is why Demo 2 matters.

Approve it, then type `/quit`.

### Goal 2.2: Check it with Demo 2 commands

```bash
ls -la && ls archive/
```

✅ **Checkpoint:** there's an `archive` folder containing `old_backup_DO_NOT_USE.log`, and no `notes.tmp`.

---

## Step 3: Read the Evidence

*Three thousand lines of logs. In Demo 2, we used `wc`, `head` and `tail`. Now let's ask for a summary.*

### Goal 3.1: Summarise a large log file

```bash
agy -p "How many lines are in logs/checkout.log? What are the first and last timestamps? Is there anything in it other than INFO lines?"
```

### Goal 3.2: Check it with Demo 2 commands

```bash
wc -l logs/checkout.log
head -1 logs/checkout.log
tail -1 logs/checkout.log
grep -vc "INFO" logs/checkout.log
```

- `grep -v` = in**v**ert the match: lines that do **not** contain `INFO`. `-c` counts them.

✅ **Checkpoint:** `2950` lines, starting at `02:00:01` and ending at `02:49:10`, and `0` lines that aren't `INFO`. Did the agent get all four right?

💬 **Discuss:** the checkout log is a red herring: it's all routine `INFO` lines. It also stops at 02:49:10, more than 20 minutes before the outage. Did the agent mention that gap? In this practice environment, the log was **generated by a script** that ran out of lines at 02:49:10, so the gap means nothing. AI tools are good at spotting patterns, including patterns in noise.

---

## Step 4: Find the Smoking Gun

*Let's search every log file for trouble.*

### Goal 4.1: Search across files in plain English

```bash
agy -p "Find every log file under this folder and show me all ERROR and FATAL lines, grouped by file."
```

### Goal 4.2: Check it with Demo 2 commands

```bash
find . -name "*.log"
grep -i "fatal" logs/*.log
grep -ic "error" logs/*.log
```

✅ **Checkpoint:**

- `find` lists **three** files: `./archive/old_backup_DO_NOT_USE.log`, `./logs/checkout.log` and `./logs/payment-worker.log`.
- One FATAL line: `03:12:04 FATAL payment-worker: connection pool exhausted, shutting down`.
- Error counts: `logs/checkout.log:0` and `logs/payment-worker.log:47`.

❓ **Check your understanding:** in Demo 2, `find` listed only two log files. Why three here?

<details><summary>Answer</summary>

In Demo 2, we ran `find` from inside the `logs` folder. Here we're one level up, in `checkout-incident`, so `find .` also searches the `archive` folder created in Step 2.

</details>

---

## Step 5: Spot the Pattern

*In Demo 2, this took five stages of `sed`, `sort` and `uniq`. Now let's hand the same evidence to the AI, and use the shell to feed it in and save what comes out.*

### Goal 5.1: Give the error lines to the agent

```bash
agy -p "Group these log lines by error type, count each type, and describe the order in which the failure happened: $(grep -i "error" logs/*.log)"
```

- `$( )` = **command substitution**, from Demo 2, Step 8. The shell runs `grep` first and pastes its output into the prompt, so the agent receives the exact lines we chose.

> ⚠️ **Why not `grep ... | agy -p "..."`?** It looks natural, but `agy` doesn't read text piped into it: it simply never sees it. If the agent still gives a good answer, that's because it went and read the log files itself, not because it used your pipe. Command substitution is the reliable way to hand an agent your data.

This is still the Unix philosophy from Demo 2: the shell joins small tools together, and the agent is one more tool in the chain.

### Goal 5.2: Check it with the Demo 2 pipeline

```bash
grep -i "error" logs/*.log | sed 's/[^ ]* //' | sort | uniq -c | sort -rn
```

✅ **Checkpoint:** this gives exactly the same result every time:

```
     20 ERROR payment-worker: connection timeout (payment-gateway:5432)
     18 ERROR payment-worker: connection refused (payment-gateway:5432)
      9 ERROR payment-worker: request queued but gateway unresponsive
```

Did the agent's counts match? The classic pipeline is **deterministic**: same input, same output, every time. The agent's answer may change from run to run. **Use one to check the other.**

### Goal 5.3: Redirect the agent's output into a file

`>` works on `agy` output too, just like any other command:

```bash
agy -p "Write a two-sentence incident summary in Markdown for this log line. Reply with only the two sentences, nothing else: $(grep -i "fatal" logs/*.log)" > incident-report.md
```

```bash
cat incident-report.md
```

✅ **Checkpoint:** `incident-report.md` contains just a two-sentence summary of the FATAL line at `03:12:04`.

💡 Notice "Reply with only the two sentences, nothing else". Without it, AI agents tend to add friendly extras ("Let me know if you'd like changes!"), and those would end up in your file too. When an agent's output goes into a file or another program, tell it exactly what format you want.

---

## Step 6: Get Help

*In Demo 2, we used `--help` and `man`. Now let's ask a tutor that explains things in context.*

### Goal 6.1: Ask which option you need

```bash
agy -p "Which uniq option shows only lines that are repeated? Give me the option and one example."
```

### Goal 6.2: Ask it to explain the hardest command from Demo 2

```bash
agy -p 'Explain this command piece by piece for a beginner: export PATH=$(dirname $(find $(pwd) -name novastack-diag)):$PATH'
```

💡 We use **single quotes** around this prompt so the shell doesn't run the `$( )` parts before `agy` sees them.

### Goal 6.3: Check it with Demo 2 commands

```bash
uniq --help | grep -- "-d"
```

✅ **Checkpoint:** `-d, --repeated        only print duplicate lines, one for each group`. Did the agent give `-d`?

💬 **Discuss:** `man` and `--help` are always right for the exact version installed on *this* machine. The AI explains far better, but it can invent options that don't exist. When would you use each?

---

## Step 7: The Locked Door

*The restart script won't run. Let's see whether the agent can work out why.*

### Goal 7.1: Diagnose and fix

The agent needs to act, so we use interactive mode:

```bash
agy
```

```text
Jordan mentioned a restart script. Find it, try to run it, explain why it fails, fix it, and run it again.
```

Watch the agent hit `Permission denied`, run `ls -l`, then `chmod +x`. Those are exactly the steps from Demo 2, chosen by the agent itself.

💡 You can check its work without leaving `agy`: press `!` to switch to shell mode and run `ls -l scripts/`. Press `Esc` to go back. Then type `/quit`.

### Goal 7.2: Check it with Demo 2 commands

```bash
ls -l scripts/
./scripts/restart-service.sh
```

✅ **Checkpoint:** the permissions read `-rwxr-xr-x`, and the script prints `Restarting checkout service...` and `Service restarted. Uptime reset.`

---

## Step 8: The Missing Tool

*`novastack-diag` isn't on the `PATH`. Let's ask the agent to fix it, then check whether the fix really reached us.*

### Goal 8.1: Ask the agent to make the tool available

```bash
agy
```

```text
Find novastack-diag and make it runnable from anywhere in my shell. Then run it. Tell me exactly what you changed.
```

The agent will find `bin/novastack-diag`, change something, and show the tool working. Type `/quit` when it's done.

### Goal 8.2: The trap: check in **your** shell

```bash
which novastack-diag
```

What you see depends on **how** the agent fixed it. Compare with what it told you it changed:

| What the agent did | What `which` shows | Why |
|---|---|---|
| Ran `export PATH=...` | **Nothing**: the tool still isn't found | The agent ran `export` in its **own child shell**, which has now exited. Environment variables pass from parent to child, never back. This is the "temporary" warning from Demo 2, Step 8. |
| Created a symlink in `/usr/local/bin` | `/usr/local/bin/novastack-diag` | The shortcut is a file in the container, so every shell can see it, until the container stops. This is what the Demo 1 plan suggested. |
| Added a line to `~/.bashrc` | Nothing yet | `~/.bashrc` is only read when a **new** shell starts. Run `source ~/.bashrc` to load it now. |

💡 To see for yourself what changed, run `ls -l /usr/local/bin/novastack-diag` (shows a symlink, if there is one) and `tail -3 ~/.bashrc`.

❓ **Check your understanding:** the agent said "Done, `novastack-diag` now works", and in *its* shell, that was true. Why might it still fail in yours?

<details><summary>Answer</summary>

Each program gets its own copy of the environment from its parent. The agent's shell is a **child** of the agent, which is a child of your shell. Changes made in a child's environment never flow back up to the parent, so a `PATH` change made by the agent disappears when its shell exits.

</details>

### Goal 8.3: Make it work yourself

If `which` found nothing, use the command from Demo 2:

```bash
export PATH=/workspace/checkout-incident/bin:$PATH
which novastack-diag && novastack-diag
```

✅ **Checkpoint:** `which` shows the tool's location, and `novastack-diag` reports `FOUND: orphaned leak-simulator process still running`.

---

## Step 9: The Rogue Process

*Something is still running in the background. Let's ask the agent to investigate before it acts.*

### Goal 9.1: Investigate first, act second

```bash
agy
```

```text
Is anything suspicious running in the background? Explain what it is and why it's suspicious before you stop it.
```

Watch the agent run `ps aux` (or similar) and find `leak-simulator.py`. When it tries to stop the process, it **must ask your approval**, because `kill` and `pkill` are on the `ask` list from Demo 0.

💬 **Discuss:** before you approve, read the exact command. Is it `kill` with a PID, or `pkill -f` with a name? Could it stop anything else by mistake? **You** are responsible for what you approve.

Approve it, then type `/quit`.

### Goal 9.2: Check it with Demo 2 commands

```bash
pgrep -f leak-simulator || echo "No leak-simulator process running"
/workspace/checkout-incident/bin/novastack-diag
```

- `|| echo "..."` = if `pgrep` finds nothing (and so "fails"), print the message instead.
- We run `novastack-diag` by its **full path**, so this works whatever happened in Step 8.

✅ **Checkpoint:** `No leak-simulator process running`, then `No process leaks detected.`

---

## Step 10: Case Closed

*Let's have the agent write the report, and then question its conclusion.*

### Goal 10.1: Write the incident report

```bash
agy -p "Look at the logs and the files in this folder, then rewrite incident-report.md with: a timeline from the logs, the evidence, the root cause, the actions taken, and follow-up tasks."
```

```bash
cat incident-report.md
```

✅ **Checkpoint:** `incident-report.md` contains all five sections. Check one fact against the logs, for example the time of the FATAL line (`03:12:04`).

### Goal 10.2: Challenge the conclusion

```bash
agy -c -p "What evidence in the logs actually proves that leak-simulator caused the connection pool exhaustion? Be strict."
```

- `-c` = **c**ontinue the most recent conversation, so the agent remembers the report it just wrote.

**The honest answer is: none.** `leak-simulator.py` only sleeps in a loop, and nothing in the logs mentions it or links it to `payment-gateway:5432`.

💬 **Discuss: three conclusions, one incident.** We now have three answers to "what caused the outage?":

1. **Demo 1 (the AI's plan):** the payment gateway failed, which exhausted the connection pool.
2. **Demo 2 (us, by hand):** the orphaned `leak-simulator.py` process.
3. **Demo 3 (just now):** what did your agent say when challenged?

- If the agent **pushed back**, it checked the evidence better than we did in Demo 2.
- If it **agreed** with a weak conclusion, it told us what we wanted to hear.

**Both humans and AI can jump to conclusions. Always ask: what's the evidence?**

---

## Key Takeaways

1. **AI CLIs speak plain English, but run real commands.** Everything the agent did was a Demo 2 command.
2. **The shell and the agent work together.** `$( )` feeds the agent your data, and `>` saves its answer (`agy -p "...: $(grep ...)" > report.md`). The Unix philosophy still applies.
3. **Permissions are your responsibility.** Approving `rm` or `kill` without understanding it is like running a stranger's script.
4. **Child processes can't change your shell.** The `PATH` trap shows why understanding processes and environment variables still matters.
5. **Verify with deterministic tools.** `sort | uniq -c` gives the same answer every time; the AI might not.
6. **Ask for evidence.** Both humans and AI jump to conclusions.

| | Demo 1: one prompt, plan mode | Demo 2: classic CLI | Demo 3: step by step with AI |
|---|---|---|---|
| You type | 1 prompt | About 40 commands | 10+ prompts, plus checks |
| Same answer every time? | No | **Yes** | No |
| Explains itself? | Yes | No | Yes |
| Can be confidently wrong? | Yes | Only if *you* are | Yes |
| Needs CLI knowledge? | **Yes, to review the plan** | Yes | **Yes, to approve and verify** |

---

## What's Next

That's the end of the Lecture 1 demos. In the lab, work through any demo you missed, then try the **Try It Yourself** challenges in Demos 1, 2 and 3.

---

## Try It Yourself (Lab)

Reset the incident first (see [Demo 0, Step 6](Lecture-1-Demo-0-Setup.md#step-6-reset-the-incident-between-demos)). For each challenge, **ask the agent first, then check its answer** with Demo 2 commands.

### Challenge 1: Count requests in a time window

```bash
agy -p "How many checkout requests were processed between 02:10 and 02:19 in logs/checkout.log?"
```

<details><summary>Check it</summary>

```bash
grep -c "^02:1" logs/checkout.log
```

The correct answer is **600**. Did the agent agree? If not, ask it how it counted.

</details>

### Challenge 2: Ask for a command, not an answer

```bash
agy -p "Give me one shell command that lists the error messages in logs/ with a count for each, most common first. Don't run it, just explain each part."
```

Run the command it gives you.

<details><summary>Check it</summary>

Compare its output with Step 5's pipeline: `20`, `18` and `9`. Is its command the same as ours? If it's different, is it still correct? If it skips `sort` before `uniq -c`, review the ❓ question in Demo 2, Step 5.

</details>

### Challenge 3: Give the process list to the agent

Start a fresh container (or reset) so the leak simulator is running, then:

```bash
agy -p "Which of these processes looks out of place on a server, and why? $(ps aux)"
```

<details><summary>Check it</summary>

```bash
ps aux | grep [p]ython
```

The odd one out is `python3 /opt/demo-assets/leak-simulator.py`. Did the agent spot it? Did it flag anything that's actually normal?

</details>

### Challenge 4: Make the fix last

```bash
agy
```

```text
Make novastack-diag available in every new shell in this container, not just yours. Tell me exactly what you changed.
```

<details><summary>Check it</summary>

```bash
ls -l /usr/local/bin/novastack-diag
tail -3 ~/.bashrc
```

The agent probably created a symlink, or added a line to `~/.bashrc`. 💬 Which approach is better, and what happens to each when the container stops?

</details>

---

## Troubleshooting

For problems with Docker, sign-in or permissions, see **[Demo 0: Troubleshooting](Lecture-1-Demo-0-Setup.md#troubleshooting)**.

| Problem | Likely cause | Fix |
|---|---|---|
| The agent says there's nothing to fix (the script already runs, no rogue process) | You didn't reset after Demo 2 | Do a full reset (Demo 0, Goal 6.1). |
| `agy -p` says a command was *auto-denied* because headless mode can't prompt for it | Print mode can't stop to ask for approval, so anything on the `ask` list (such as `rm` or `kill`) is refused automatically | Use interactive `agy` for any step where the agent needs to delete or stop something. |
| The agent ignores data you piped to it (`... \| agy -p "..."`) | `agy` doesn't read piped input | Put the data inside the prompt with command substitution: `agy -p "...: $(command)"` (see Goal 5.1). |
| `incident-report.md` contains extra chatty text | The agent added comments around its answer | Tell it the exact format, e.g. *"Reply with only the two sentences, nothing else"* (see Goal 5.3), or delete the extra lines. |
| The agent says it fixed `PATH`, but `which novastack-diag` finds nothing | Expected: see the table in Goal 8.2 | Run the `export` command in Goal 8.3 yourself. |
| `agy -c` continues the wrong conversation | `-c` resumes the **most recent** conversation | Run Goal 10.1 again just before 10.2, so it's the most recent. |
| The agent's numbers differ from the checkpoints | AI answers vary and can be wrong | Trust the Demo 2 command. That's the point of checking. |
| The agent edits or deletes something you didn't ask for | Agents can be over-eager | Reset the incident, and make the prompt more specific (for example "Don't change anything else"). |
