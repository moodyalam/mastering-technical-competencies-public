# Lecture 1 · Demo 1: The 3 AM Page, Planned by an AI Agent

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
| **Demo 1 (this one)** | One prompt to an AI agent in **plan mode** | How an AI agent reasons about a problem before acting |
| [Demo 2](Lecture-1-Demo-2-Script-Linux-CLI.md) | Classic CLI commands, typed by hand | The skills you need to do the work, and to check the AI's work |
| [Demo 3](Lecture-1-Demo-3-Script-AI-Individual-Commands.md) | The same steps as Demo 2, as plain-English requests to the AI agent | How each command maps to a natural-language request |

> **AI doesn't replace learning the terminal; it complements it.** An AI agent can plan this whole investigation in a couple of minutes, but **your own command-line knowledge is what lets you check its work.** You read the commands it plans to run, you approve the risky ones, and you verify its claims.

**Time:** about 10 minutes.

### What you'll learn

- How to use an AI command-line tool in **plan mode**, where it proposes changes before making any.
- How **permission rules** keep a human in control of risky actions.
- How to **critically review** an AI agent's plan: its deletions, its commands and its conclusions.

### Before you start

- Complete **[Demo 0: Setup](Lecture-1-Demo-0-Setup.md)**: the container is running, you're signed in to `agy`, and the permissions are set.
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

> ⚠️ **AI output changes from run to run.** The prompts in this script are fixed, but the agent's answers are not. Expect different wording each time, and occasionally a wrong answer. That's part of the lesson.

---

## Step 1: Ask the Agent for a Plan

### Goal 1.1: Start `agy` in plan mode

In **plan mode**, the agent investigates and writes a plan, but it **doesn't change anything** until you approve. That's exactly how you'd want a new colleague to work: "tell me what you're going to do before you do it."

```bash
cd /workspace/checkout-incident && agy --mode plan
```

- `cd /workspace/checkout-incident` = move into the incident folder first, so the agent works there.
- `&&` = run the second command only if the first one succeeded.
- `agy --mode plan` = start the Antigravity agent in plan mode.

### Goal 1.2: Give it the whole incident in one prompt

Type this prompt into `agy`:

```text
I'm on call. Read README.txt and investigate the checkout outage. Clean up junk files, get the restart script and novastack-diag working, find any rogue process, and write the root cause to incident-report.md. Ask me before deleting or killing anything.

Save a copy of your plan in this folder as agy-plan.md.
```

While it works, watch the screen. You'll see the agent reading files and running investigative commands, such as `ls`, `cat` and `grep`. These are the same commands you'll type yourself in Demo 2.

When the agent shows its plan and asks you to approve it, **don't approve it yet.** In this demo, we only want the plan.

✅ **Checkpoint:** the agent says it has saved `agy-plan.md` and is waiting for your approval.

❓ **Check your understanding:** our prompt says "Ask me before deleting or killing anything". If the agent ignored that sentence, would it still have to ask before running `rm`?

<details><summary>Answer</summary>

Yes. The permission rules from Demo 0 put `rm`, `kill` and the other destructive commands on the `ask` list. The prompt is a request; the permission rules are enforced by the tool. Relying on both is a good habit.

</details>

---

## Step 2: Read the Plan

### Goal 2.1: Open the plan in the terminal

Type `/quit` to leave `agy`, then let's read what it wrote:

```bash
cat agy-plan.md
```

Long file? Use `less agy-plan.md` instead: press `Space` for the next page and `q` to quit.

### Goal 2.2: Open the plan on your laptop

Thanks to the bind mount from Demo 0, the plan is **also on your laptop**, at `incident-output/checkout-incident/agy-plan.md`. Open it in VS Code and press `Cmd+Shift+V` (macOS) or `Ctrl+Shift+V` (Windows) to see it nicely formatted.

✅ **Checkpoint:** you can read a plan with sections such as *findings*, *proposed changes* and *approvals required*.

---

## Step 3: Review the Plan Together

Below is the plan the agent produced on the lecturer's machine. **Your plan will be different:** AI output changes from run to run, even with the same prompt. Let's read it first, then go through it section by section.

> ### 📄 Example plan: `agy-plan.md`
>
> #### Implementation Plan: Checkout Outage Investigation & Remediation
>
> Investigate the checkout service outage that occurred around 3:00 AM, restore operational readiness by cleaning obsolete/junk files, ensuring scripts and diagnostic tools are executable and accessible in `PATH`, identify and terminate rogue processes, and produce a formal root cause analysis in `/workspace/checkout-incident/incident-report.md`.
>
> #### User Review Required
>
> **Action Approvals Required Before Execution:**
> 1. **File Deletions**: We propose to delete the following junk/scratch files identified in `/workspace/checkout-incident`:
>    - `notes.tmp` (`"scratch notes, ignore"`)
>    - `old_backup_DO_NOT_USE.log` (`"old backup, superseded"`)
> 2. **Process Termination**: We propose to kill the rogue orphaned background process:
>    - Process PID: `9` (`python3 /opt/demo-assets/leak-simulator.py`)
>
> #### Findings & Root Cause Analysis Summary
> - **Outage Cause**: At `02:49:10`, checkout traffic abruptly ceased logging. At `03:11:11`, `payment-worker` encountered repeated `connection refused (payment-gateway:5432)` and timeout errors. By `03:12:04`, the connection pool was completely exhausted, resulting in a fatal shutdown of `payment-worker`.
> - **Rogue Process**: An orphaned leak simulator process (`python3 /opt/demo-assets/leak-simulator.py`, PID `9`) was found actively running in the background.
> - **Diagnostic Tool**: `novastack-diag` was located in `./bin/`, but `./bin` is not in system `$PATH`, causing `novastack-diag` command to not be found. Additionally, while the rogue process is running, `novastack-diag` detects and flags this process.
> - **Restart Script**: `scripts/restart-service.sh` exists in `./scripts/` but lacked executable permissions (`chmod +x`).
>
> #### Proposed Changes
>
> **1. File Cleanup**
> - Obtain user approval, then delete:
>   - `notes.tmp`
>   - `old_backup_DO_NOT_USE.log`
>
> **2. Process Termination**
> - Obtain user approval, then terminate rogue process PID `9` (`kill 9` or `pkill -f leak-simulator.py`).
>
> **3. Operational Tooling Fixes**
> - **Restart Script**:
>   - Add execution permissions: `chmod +x /workspace/checkout-incident/scripts/restart-service.sh`.
>   - Validate execution by running `./scripts/restart-service.sh`.
> - **Diagnostics Tool**:
>   - Create a symlink in `/usr/local/bin/novastack-diag` pointing to `/workspace/checkout-incident/bin/novastack-diag` (or add `/workspace/checkout-incident/bin` to `PATH`) so `novastack-diag` is directly invocable.
>   - Verify that running `novastack-diag` reports `"No process leaks detected."` once the rogue process is terminated.
>
> **4. Incident Report Documentation**
> - Create `incident-report.md` with sections:
>   - **Summary**: Incident description, timeline, and impact.
>   - **Root Cause Analysis**: Downstream payment gateway connection failure (`payment-gateway:5432`), repeated connection timeouts, and connection pool exhaustion leading to fatal worker termination.
>   - **Diagnostic Findings**: Rogue orphan process (`leak-simulator.py`), tool accessibility issues (`novastack-diag` missing from `PATH`, unexecutable restart script).
>   - **Remediation & Action Items**: Process cleanup, tooling permissions and path fixes, gateway connectivity and retry/pool configuration hardening.

### Goal 3.1: "User Review Required": notice that the agent asks before acting

The agent grouped every risky action at the top and asked for approval, exactly as our prompt and permission rules told it to. Good agents make the risky parts easy to spot.

💬 **Discuss:** would you approve deleting `old_backup_DO_NOT_USE.log`?

"Do not use" isn't the same as "delete". A backup that's superseded today might be the only copy of something tomorrow. A more cautious engineer would **move it to an archive folder** instead, which is exactly what we'll do by hand in Demo 2. AI agents can be confidently over-eager; *you* make the decision.

### Goal 3.2: "Process Termination": read commands carefully

The plan suggests `kill 9`. This means *"stop the process whose ID is 9"*. It's **not** the same as `kill -9`, which sends a *signal* meaning "force-stop immediately". One dash changes the meaning completely.

> ⚠️ **Process IDs differ on every machine.** On your laptop, the leak simulator will probably have a different process ID (PID). Never copy a PID from someone else's output; look it up yourself. Demo 2, Step 9 shows how, with `ps aux`.

### Goal 3.3: "Findings": check the evidence behind each claim

The agent says checkout "abruptly ceased logging" at 02:49:10, about 20 minutes before the payment errors. Is that really a clue? In this practice environment, the checkout log was **generated by a script** that simply ran out of lines at 02:49:10. The agent spotted a pattern and treated it as meaningful.

💬 **Discuss:** AI tools are very good at finding patterns, including patterns in noise. A real engineer would ask: *what else could explain this gap?*

### Goal 3.4: "Root Cause": compare two conclusions

The agent concludes that the outage was caused by the **payment gateway failing**: refused connections, then timeouts, then the connection pool running out. It lists the leak simulator as a *separate* finding, not as the cause.

💬 **Discuss (keep this in mind for Demo 2):** in Demo 2, we'll reach a *different* conclusion by hand: that the orphaned `leak-simulator.py` process caused the outage. Which conclusion is better supported by the evidence in the logs? Is there anything in the logs that directly links `leak-simulator.py` to `payment-gateway:5432`? **Both humans and AI can jump to conclusions. Always ask: what's the evidence?**

### Goal 3.5: "Operational Tooling Fixes": more than one right answer

For `novastack-diag`, the agent offers two fixes:

- A **symlink** (a shortcut) in `/usr/local/bin`, a folder that's already on `PATH`. It lasts until the container stops.
- **Adding `bin/` to `PATH`** with `export`. It only lasts for your current shell session.

Both work. We'll explore `PATH` properly in Demo 2, Step 8.

✅ **Checkpoint:** you can explain, in your own words, one thing in the plan you would approve and one thing you would question.

---

## Key Takeaways

1. **Plan mode lets you review before anything changes.** Use it whenever the stakes are high.
2. **Permissions are your safety net.** Decide in advance what the agent may do freely and what it must ask about.
3. **A plan is a proposal, not the truth.** Check deletions, process IDs and root-cause claims against the evidence.
4. **You can only review what you understand.** That's why Demo 2 teaches the commands themselves.

---

## What's Next

In **[Demo 2](Lecture-1-Demo-2-Script-Linux-CLI.md)**, we'll solve the same incident by hand with classic CLI commands, and see how many of the agent's findings we can confirm ourselves.

---

## Try It Yourself (Lab)

### Challenge 1: Let the agent carry out its plan

Try this **after** you've worked through Demo 2 by hand.

> ⚠️ **This changes your incident files.** The agent will delete files, change permissions and stop a process. Afterwards, reset the incident before any other demo (see [Demo 0, Step 6](Lecture-1-Demo-0-Setup.md#step-6-reset-the-incident-between-demos)).

```bash
cd /workspace/checkout-incident && agy
```

Give it the same prompt as Goal 1.2. This time, the agent carries out the work.

- Watch which commands it runs (`grep`, `chmod +x`, `export` and so on). Can you say what each one does?
- When it asks to run `rm` or `kill`, stop and think before approving. Do you agree with each action?

When it finishes, type `/quit`, then check its work yourself:

```bash
ls -la
ls -l scripts/
pgrep -f leak-simulator || echo "No leak-simulator process running"
cat incident-report.md
```

- `pgrep -f leak-simulator` = print the ID of any process whose command line contains `leak-simulator`.
- `|| echo "..."` = if `pgrep` finds nothing (and so "fails"), print the message instead.

✅ **Checkpoint:** the junk files are gone (or archived), `restart-service.sh` shows an `x` in its permissions, no leak-simulator process is running, and `incident-report.md` exists.

### Challenge 2: Compare plans

Reset the incident, then run Goal 1.2 again, or compare with a lab partner's plan.

💬 **Discuss:** what changed between the two plans? Did the root cause change? What does that tell you about trusting a single AI answer?

---

## Troubleshooting

For problems with Docker, sign-in or permissions, see **[Demo 0: Troubleshooting](Lecture-1-Demo-0-Setup.md#troubleshooting)**.

| Problem | Likely cause | Fix |
|---|---|---|
| `agy-plan.md` was never created | The agent described the plan but didn't save it | Ask again: *"Save your plan as agy-plan.md in this folder."* Or find the agent's own copy: `find /root/.gemini -name "*.md"`. |
| `agy-plan.md` isn't on your laptop | The container was started without the `incident-output` mount, from a different folder, or more than one container is open | See Demo 0, Step 7. Run `docker ps` on your laptop and keep only one container open. |
| The agent started changing files | You approved the plan, or started `agy` without `--mode plan` | Reset the incident (Demo 0, Step 6) and start again with `agy --mode plan`. |
| The plan mentions a different PID, or no rogue process | The process ID differs on every machine, or the process was stopped earlier | Normal for a different PID. If there's no process at all, reset the incident. |
| The plan looks very different from the example | AI output varies from run to run | Expected. Compare the main points: cleanup, permissions, PATH, rogue process, root cause. |
