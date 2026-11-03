---
marp: true
theme: default
paginate: true
size: 16:9
lang: en-GB
title: "Lecture 4: The Monday After the 3 AM Page, Continued"
description: "AI in the IDE (three ways to work with it) and debugging ORD-317 with logs and the VS Code debugger"
author: Mastering CS Technical Competencies
footer: "Lecture 4 · The Monday After the 3 AM Page, Continued"
style: |
  /* Accessibility: every text/background pair below meets WCAG 2.2 AA
     (4.5:1 for normal text, 3:1 for large text); checked with
     instructor/check_contrast.py. Smallest text on a slide is 24px of 1280. */
  :root {
    --navy: #14213d;
    --teal: #0b6668;
    --amber: #f2a541;
    --paper: #fbfaf7;
    --ink: #1f2933;
    --muted: #4a5563;
  }
  section {
    background: var(--paper);
    color: var(--ink);
    font-family: "Atkinson Hyperlegible", "Inter", "Segoe UI", "Helvetica Neue", Arial, sans-serif;
    font-size: 30px;
    line-height: 1.4;
    letter-spacing: 0.01em;
    text-align: left;
    padding: 52px 64px;
  }
  h1 { color: var(--navy); font-size: 1.5em; margin-bottom: 0.3em; }
  h2 { color: var(--teal); font-size: 1.05em; margin-top: 0; }
  strong { color: var(--navy); }
  em { font-style: normal; text-decoration: underline; text-decoration-thickness: 2px; }
  a { color: var(--teal); text-decoration: underline; }
  code { background: #e9edf1; color: var(--navy); border-radius: 4px; padding: 0 0.2em; }
  pre { background: #1e2633; border-radius: 8px; font-size: 0.8em; line-height: 1.35; }
  pre code { background: transparent; color: #f0f4f8; }
  pre .hljs-string { color: #f6c177; }
  pre .hljs-comment { color: #b4bfcc; font-style: normal; }
  pre .hljs-built_in, pre .hljs-keyword { color: #8fdcf0; }
  pre .hljs-number, pre .hljs-literal { color: #c3e88d; }
  pre .hljs-title, pre .hljs-function { color: #ffd59e; }
  pre .hljs-meta, pre .hljs-params, pre .hljs-variable, pre .hljs-attr { color: #f0f4f8; }
  pre .hljs-variable.language_, pre .hljs-type { color: #ffb4a8; }
  table { font-size: 0.82em; border-collapse: collapse; }
  th { background: var(--navy); color: #ffffff; text-align: left; }
  td, th { padding: 6px 14px; border: 1px solid #c9d1da; }
  tr:nth-child(even) td { background: #f1f3f5; }
  blockquote {
    border-left: 8px solid var(--amber);
    background: #fff4de;
    padding: 0.45em 1em;
    margin: 0.5em 0;
    font-style: normal;
    color: var(--ink);
  }
  footer { color: var(--muted); font-size: 0.8em; }
  section::after { color: var(--muted); font-size: 0.8em; }
  section.lead { background: var(--navy); color: #ffffff; justify-content: center; }
  section.lead h1 { color: #ffffff; font-size: 2em; }
  section.lead h2 { color: var(--amber); }
  section.lead strong { color: var(--amber); }
  section.lead code { background: #2b3a5c; color: #ffe3b0; }
  section.lead footer, section.lead::after, section.lead .small { color: #c3cede; }
  section.act { background: var(--teal); color: #ffffff; justify-content: center; }
  section.act h1 { color: #ffffff; font-size: 1.9em; }
  section.act h2 { color: #ffe3b0; }
  section.act strong { color: #ffe3b0; }
  section.act footer, section.act::after { color: #e6f2f2; }
  section.demo { background: #eaf4f4; }
  section.menti { background: #fff4de; }
  section.menti h1 { color: var(--navy); }
  section.menti ol { font-size: 0.95em; }
  section.menti li { margin: 0.25em 0; }
  .menti-grid { display: grid; grid-template-columns: 1fr 250px; gap: 1.4em; align-items: start; }
  .menti-grid img { width: 230px; height: 230px; }
  .join { font-size: 0.8em; text-align: center; margin-top: 0.2em; }
  .label { display: inline-block; font-size: 0.8em; font-weight: 700; color: #ffffff; background: var(--navy); border-radius: 6px; padding: 0.05em 0.5em; margin-bottom: 0.3em; }
  .small { font-size: 0.8em; color: var(--muted); }
  .cols { display: grid; grid-template-columns: 1fr 1fr; gap: 1.5em; }
---

<!-- _class: lead -->
<!-- _paginate: false -->

# The Monday After the 3 AM Page, Continued

## Lecture 4 · An AI pair programmer, then the debugger

**GitHub Copilot · logs · breakpoints · the Debug Console**

<span class="small">Slides, demos and labs: `lectures/04-ai-debugging-continued/` (links to Lecture 3)</span>

<!--
Welcome back. Last week was too big for one session (like Lecture 1), so today we finish it: Act 5 (AI in the IDE) and Act 6 (debugging ORD-317). No profiling today: Demo 4 is written up for you to do yourselves.
Accessibility: these slides are also on Moodle/GitHub as HTML (screen-reader friendly, zoomable) and PDF.
-->

---

# Today

| Time | What | Where to find it |
|---|---|---|
| 3 min | Where we left ORD-317 | |
| 10 min | **Act 5:** three ways to work with AI | Lecture 3 · Demo 2, Step 5 |
| 20 min | **Act 6:** debugging ORD-317 | Lecture 3 · Demo 3 |
| 7 min | **Three Mentimeter questions** during the demos | menti.com · code 6357 2204 |
| 8 min | **Attendance form** and **anonymous feedback** | QR codes at the end |

Everything I type today is written up, step by step, in the Lecture 3 demo guides. Follow along on your laptop, or just watch.

<!--
Set expectations: 35 minutes of teaching, 15 minutes of Mentimeter and forms.
-->

---

# Previously, on Mastering CS…

- **ORD-317:** Sam Patel (Silver card) paid **£5.95**. Grace in Finance says **£7.29**.
- You reproduced it: the loyalty discount appears **three times**.
- You found a suspicious loop (Priya, ORD-301) and renamed `calc` for Mei (`F2`).
- Smoke tests: `17 passed, 200 deselected, 1 xfailed`.

> **Mei** is happy. **Sam** is still being undercharged.
> Clear code first. Now: fix the bug.

<!--
30-60 seconds. Ask: hands up if you opened the team repo since last week.
-->

---

# By the end of today you can…

1. Choose between **autocomplete**, **inline chat** and **chat** for a task
2. Explain why you must **check** what an AI produces, and how
3. Follow a **debugging routine**: reproduce, hypothesise, observe, fix, verify
4. Use **logs**, a **conditional breakpoint**, **Variables**, **Watch** and the **Debug Console** to find a bug
5. Know your options when there's **no IDE** (`pdb`)

---

<!-- _class: act -->

# Act 5
## "Get a pair programmer"
Three ways to work with AI in the IDE

<!--
Jordan last week: "Copilot's free for students. Use it. But check it."
-->

---

# Three ways to work with AI

| Mode | How (Windows/Linux · macOS) | Good for |
|---|---|---|
| **Autocomplete** | Just type; grey text appears; `Tab` accepts | Finishing code you've started |
| **Inline chat** | Select code, then `Ctrl+I` · `Cmd+I` | Changing **one specific piece** of code; you review a **diff** |
| **Chat** | Chat view: `Ctrl+Alt+I` · `Ctrl+Cmd+I` | **Ask:** questions, no edits · **Agent:** multi-file tasks |

Since Copilot launched in 2021, AI assistants have become a normal part of programming: **84%** of developers use or plan to use them (Stack Overflow, 2025).

<!--
Copilot Free, or Copilot Student via GitHub Education. Same three shapes in Cursor, JetBrains AI, etc.
-->

---

<!-- _class: demo -->

# Demo: 1. Autocomplete, steered by a name and a docstring

At the end of `services/receipts.py`, type, then press `Enter` and wait:

```python
def discount_summary(order: Order) -> str:
    """One line per discount, e.g. "LOYALTY -£0.81", in the order applied."""
```

- `Tab` accepts · `Alt+]` · `Opt+]` shows other suggestions
- A precise **name**, **type hints** and a **docstring** steer the AI better than throwaway comments
- **Read it before you keep it**

<!--
Demo 2, Step 5, Goal 5.1. If Copilot is slow: the correct version is in the guide (details box).
-->

---

# When the AI gets it wrong, the tools notice

In rehearsal, Copilot suggested:

```python
if d.amount > 0
```

Pylance underlined it at once:

> Operator ">" not supported for types "Money" and "Literal[0]"

The team's `Money` type can't be compared with a plain number (ADR 0002).
**The type checker caught the AI's mistake.** That's why the team turns it on.

<!--
Point: the guard rails you set up in Lecture 3 (Pylance, Ruff, tests) are what make AI safe to use.
-->

---

<!-- _class: demo -->

# Demo: 2. Inline chat, then 3. Ask about the codebase

**Inline chat:** select `discount_summary`, press `Ctrl+I` · `Cmd+I`, type:

```text
Handle an order with no discounts by returning 'No discounts'.
```

Read the **diff** (removed and added lines), then **Keep** or **Undo**.

**Chat, in Ask mode** (Ask answers questions without editing files):

```text
Where is the loyalty discount applied in this project, and why could a
loyalty customer be undercharged when their basket has several categories?
```

<!--
Goals 5.2 and 5.3. Show the mode drop-down under the chat box (Ask / Plan / Agent). Ask: is the answer right? How would you know? Hold that thought.
-->

---

<!-- _class: menti -->

# Mentimeter question 1 of 3
<div class="menti-grid">
<div>


You want Copilot to change **one function you have selected**, so that it returns `'No discounts'` for an empty order. Which way of working with AI fits best?

1. Autocomplete
2. Inline chat
3. Chat in **Ask** mode
4. Chat in **Agent** mode

</div>
<div>

![QR code to join the Lecture 4 Mentimeter](images/qr-menti.svg)

<p class="join"><strong>menti.com</strong><br>code <strong>6357 2204</strong></p>

</div>
</div>


<!--
Give 60-90 seconds. Answer on the next slide.
-->

---

# Question 1: the answer is 2, inline chat

| Option | Why |
|---|---|
| Autocomplete | Finishes what you're typing; you can't describe a change |
| **2. Inline chat (correct)** | **One selected piece of code; you review a diff** |
| Chat, Ask mode | Answers questions; doesn't edit your files |
| Chat, Agent mode | Works across many files: too much power for a two-line change |

> Rule of thumb: the **smallest** AI tool that does the job is the easiest one to check.

---

# AI is a lead, not an oracle

| Study | Finding |
|---|---|
| Stack Overflow, 2025 | **46%** don't trust AI accuracy; top frustration (66%): "almost right, but not quite" |
| METR randomised trial, 2025 (preprint) | Experienced developers were **19% slower** with AI, but *felt* **20% faster** |
| Cui et al., *Management Science*, 2026 (4,867 developers) | **+26%** tasks completed; juniors gained most |

> Felt 20% faster, was 19% slower. Like me at the gym.

`AGENTS.md` = the team's rules for the AI · **never paste secrets** · **Jordan:** "Great. Now **prove it**."

<!--
Demo 2 Steps 6-7 in one slide. Optional: show AGENTS.md for 20 seconds. Skip the "fix ORD-317 in Agent mode" step: we prove it with the debugger instead.
-->

---

<!-- _class: act -->

# Act 6
## "Why are loyalty customers undercharged?"
Debugging

---

# The five stages of print debugging

```python
print("here")
print("here 2")
print("HERE??")
print(running)           # Money(amount=Decimal('9.50'), currency='GBP') ...ok?
print("why is this happening")
```

> "The most effective debugging tool is still careful thought, coupled with judiciously placed print statements." (Brian Kernighan)

**Today:** what comes after the print statements.

<!--
Hands up: who has written print("here")? Who has used a conditional breakpoint? Beller et al. (ICSE 2018): professionals under-use debuggers and rarely know the advanced features.
-->

---

# A routine, not luck

| Stage | Question | ORD-317 |
|---|---|---|
| **1. Reproduce** | Can I make it happen on demand? | The CLI quote shows £5.95 |
| **2. Hypothesise** | What could cause exactly this? | Loyalty runs once per category |
| **3. Observe** | What is the program *actually* doing? | Logs, then the debugger |
| **4. Fix** | The smallest change that removes the cause | Move loyalty out of the loop |
| **5. Verify** | Fixed, and nothing else broken? | The CLI says £7.29 |

Novices are better at **fixing** bugs than **finding** them (Fitzgerald et al., 2008). Today is about finding.

---

<!-- _class: demo -->

# Demo: ask the logs first

macOS / Linux (PowerShell version in the Demo 3 guide):

```bash
NOVASTACK_LOG_LEVEL=DEBUG uv run novastack quote \
    data/samples/meal_deal_plus_drink.json --at 2026-10-07T12:30
```

```text
applied LOYALTY: -0.52 (running total 5.20 -> 4.68)
applied LOYALTY: -0.68 (running total 6.78 -> 6.10)
applied LOYALTY: -0.95 (running total 9.50 -> 8.55)
applied MEALDEAL: -2.60 (running total 8.55 -> 5.95)
```

**Discuss:** two things are wrong. What are they?

<!--
Answer: loyalty applied three times, and before the meal deal. docs/architecture.md: promotions first, then loyalty once.
Tip: when a print() helps, turn it into a log line before deleting it.
-->

---

<!-- _class: demo -->

# Demo: stop at exactly the right moment

1. In `pricing/calculator.py`, right-click the margin by `if self._loyalty.applies(ctx):`
2. **Add Conditional Breakpoint…** → Expression:

```python
category == "drink"
```

3. **Run and Debug** (`Ctrl+Shift+D` · `Cmd+Shift+D`) → **CLI: quote the sample meal deal** → `F5` (Mac: `Fn+F5`)

**Variables:** `running` = **£9.50** · `applied` = **2** discounts, both `LOYALTY`

<!--
Demo 3 Step 3. Never cut this one. Also add Watch: running.amount, len(applied); click cmd_quote in Call Stack, then back to calculate.
-->

---

<!-- _class: menti -->

# Mentimeter question 2 of 3
<div class="menti-grid">
<div>


We're paused at the breakpoint `category == "drink"` (the **third** category). `running` is £9.50 and `applied` already holds **2** `LOYALTY` discounts. What does this tell us?

1. The meal deal discount was applied twice
2. The loyalty discount is applied once **per category**, inside the loop
3. The breakpoint condition is wrong
4. Nothing yet: we need more print statements

</div>
<div>

![QR code to join the Lecture 4 Mentimeter](images/qr-menti.svg)

<p class="join"><strong>menti.com</strong><br>code <strong>6357 2204</strong></p>

</div>
</div>

---

# Question 2: the answer is 2, once per category

- We are on the **third** category and loyalty has **already** been applied **twice**
- When we continue, it is applied a **third** time
- That's our hypothesis, now **confirmed with evidence**, not a guess

> The meal deal hasn't been applied at all yet, which is the second bug: the architecture says **promotions first, then loyalty once**.

---

<!-- _class: demo -->

# Demo: ask questions while paused

**Debug Console** (`Ctrl+Shift+Y` · `Cmd+Shift+Y`): Python **inside the paused program**. One line at a time:

| Type | Answer |
|---|---|
| `len(applied)` | `2` |
| `[d.code for d in applied]` | `['LOYALTY', 'LOYALTY']` |
| `[str(d.amount.amount) for d in applied]` | `['0.52', '0.68']` |

**Step:** `F10` over · `F11` into · `Shift+F11` out · `F5` continue · `Shift+F5` stop
Mac laptops: hold **`Fn`** (`Fn+F10`), or use the debug toolbar.

<!--
Step 4. Press F10 twice: running drops £9.50 -> £8.55, applied has 3 items. Then Shift+F5.
-->

---

<!-- _class: demo -->

# Demo: no pausing, no editing, no IDE

| Tool | When | Example |
|---|---|---|
| **Logpoint** | See every pass, without stopping or editing code | `{category}: running £{running.amount}` |
| **`breakpoint()` + pdb** | On a server over SSH, no VS Code | `p category` · `n` · `c` · `q` |
| **AI, given evidence** | Explain logs, stack traces, cryptic errors | Paste the 4 DEBUG lines, ask why |

**Never commit `breakpoint()`:** production would freeze, waiting at a `(Pdb)` prompt.

> AI is **very good at finding** bugs from evidence and **less good at fixing** them. Give it evidence, not "it's broken".

<!--
Steps 5-7. If behind, show the logpoint only and talk through the rest. Logpoint output: main £5.20, 0 / side £6.78, 1 / drink £9.50, 2.
-->

---

<!-- _class: menti -->

# Mentimeter question 3 of 3
<div class="menti-grid">
<div>


You want to see the running total on **every pass** of the loop, **without pausing** the program and **without changing** the code. Which tool?

1. `print()`
2. A conditional breakpoint
3. A logpoint
4. `breakpoint()` with pdb

</div>
<div>

![QR code to join the Lecture 4 Mentimeter](images/qr-menti.svg)

<p class="join"><strong>menti.com</strong><br>code <strong>6357 2204</strong></p>

</div>
</div>

---

# Question 3: the answer is 3, a logpoint

| Option | Pauses? | Edits the code? |
|---|---|---|
| `print()` | No | **Yes**, and you must remember to delete it |
| Conditional breakpoint | **Yes**, when the condition is true | No |
| **3. Logpoint (correct)** | **No** | **No** |
| `breakpoint()` with pdb | **Yes** | **Yes** |

> A logpoint is a print statement you never have to delete, because it was never in the code.

---

<!-- _class: demo -->

# Fix it, then verify with the same evidence

Move the loyalty discount **out of the loop**, after promotions:

```python
        for rule in self._promotions:
            if rule.applies(ctx):
                running = self._apply(rule, ctx, running, applied)

        # Loyalty applies once, to the whole promoted total (ORD-317).
        if self._loyalty.applies(ctx):
            running = self._apply(self._loyalty, ctx, running, applied)
```

Same command again: meal deal **−£2.60**, loyalty **−£0.81**, total **£7.29**. Grace agrees.

<!--
Demo 3 Step 8 (full code in the guide, Goal 8.1).
-->

---

# Fixed! …and a test failed?

```text
$ uv run pytest -m smoke
FAILED tests/unit/pricing/test_calculator.py::test_loyalty_discount_applied_once
[XPASS(strict)] ORD-317: remove when fixed
1 failed, 17 passed
```

> We fixed the bug and a test failed. Welcome to software engineering.

Dan wrote a test that **expected** the bug (`xfail`, `strict=True`), so it fails loudly the moment someone fixes it. Why teams do this: **Lecture 5**.

---

# Friday, 16:30

> **From:** Jordan
>
> Brilliant first week: ORD-317 fixed, `calc` finally has a name.
>
> One thing: all of it is still **on your laptop**. On this team, nothing reaches customers without **tests**, a **review** and **CI**. Dan's question stands: how do we make sure nobody breaks it again?

**Lecture 5: CI/CD**: tests, Git and pull requests, code review, GitHub Actions.

---

# Before next week

- **Exercise ORD-318:** the student discount vanishes on Fridays. Debugger only, no `print()`!
- **Lecture 3 labs**, each with a self-check: **Beginner** (do the lecture yourself) · **Intermediate** (new bugs, fewer hints) · **Advanced** (the auditors are coming)
- **Profiling (Demo 4)**, not covered live: Grace's slow month-end report, `cProfile` and flame graphs
- Every step is written up in `lectures/03-ide-debug-large-code-bases/demo/`

---

# Two short forms, please (about 8 minutes)

<div class="cols">
<div>

**1. Attendance and survey**
University sign-in · about 5 minutes

![w:220 QR code for the Lecture 4 attendance and survey form](images/qr-attendance.svg)

</div>
<div>

**2. Anonymous feedback**
No names recorded · about 2 minutes

![w:220 QR code for the Lecture 4 anonymous feedback form](images/qr-feedback.svg)

</div>
</div>

Can't scan? Both links are on Moodle. Taking part in the research is **voluntary** and doesn't affect your place on the programme. Every question has an **N/A** option.

<!--
QR codes point at the two Microsoft Forms (links in INSTRUCTOR-NOTES.md). Post both links on Moodle / in the chat for students who can't scan. Attendance form is open 27 Oct, 17:30-18:00 only.
-->

---

<!-- _class: lead -->
<!-- _paginate: false -->

# Thank you

## Questions?

<span class="small">Remember: `print("here")` is a cry for help. Use a breakpoint.</span>
