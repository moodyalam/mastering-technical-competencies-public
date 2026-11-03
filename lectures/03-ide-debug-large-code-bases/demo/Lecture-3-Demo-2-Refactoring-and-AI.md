# Lecture 3 · Demo 2: Refactor, Then Pair With an AI

**Mastering Computer Science Technical Competencies** · Lecture 3: The Monday After the 3 AM Page

---

## The Scenario So Far

You've set up the team's way, reproduced ORD-317 (Sam paid £5.95, the loyalty
discount appears three times) and found a suspicious loop in
`PriceCalculator.calculate`, added by Priya in ORD-301
([Demo 1](Lecture-3-Demo-1-Setup-and-Navigation.md)).

Before you change pricing code, a message arrives from Mei:

> **Mei:** While you're in there, *please* rename `calc`. It's used all over the
> place and nobody knows what it calculates. Leave it better than you found it! 🙏

And Jordan suggests you get some help: *"Copilot's free for students. Use it.
But check it."*

---

## About This Demo

**Time:** about 11 minutes.

| Step | Act | Title | You'll use |
|---|---|---|---|
| 1 | 4 | What Refactoring Is | (slide) |
| 2 | 4 | Rename Across the Codebase | Rename Symbol (`F2`), the rename preview |
| 3 | 4 | Extract Variable and Extract Method | Code actions (`Ctrl+.` · `Cmd+.`) |
| 4 | 4 | Tidy and Check | Ruff on save, the smoke tests |
| 5 | 5 | Three Ways to Work With AI | Autocomplete, inline chat, chat |
| 6 | 5 | Give the AI the Team's Rules | `AGENTS.md` |
| 7 | 5 | "Great. Now Prove It." | Asking the AI about ORD-317 |

| Icon | Meaning |
|---|---|
| ✅ | **Checkpoint** |
| ❓ | **Check your understanding** (click *Answer*) |
| 💬 | **Discuss** |
| ⚠️ | **Warning** |
| 💡 | **Tip** |

---

## Step 1: What Refactoring Is (Act 4)

*Refactoring changes the **structure** of code without changing its **behaviour**.*

- **Why teams care:** names and structure are how other people read your code. A
  clear name saves every future reader time.
- **Why tools:** a refactoring tool understands the code (through the language
  server), so it changes exactly the right things. Find & Replace only
  understands text.
- **The evidence:** a large study of developers found that almost **90%** of
  refactorings are done by hand, without the tools that make them safe
  (Murphy-Hill, Parnin & Black, *IEEE TSE*, 2012).

---

## Step 2: Rename Across the Codebase (Act 4)

### Goal 2.1: Rename `calc` safely

1. Open `src/novastack_orders/domain/basket.py` and find `def calc(line: BasketLine) -> Money:`.
2. Put the cursor on `calc` and press **`F2`** (`Fn+F2` on most Mac laptops),
   or right-click → **Rename Symbol**.
3. Type the new name and press **`Shift+Enter`** to **preview** instead of applying straight away:

```text
calculate_line_total
```

✅ **Checkpoint:** the Refactor Preview lists **five files**: `basket.py`,
`calculator.py`, `receipts.py`, `order_service.py` and `test_basket.py`,
including the `import` lines.

4. Click **Apply**.

❓ **Check your understanding:** why not use Find and Replace (`Ctrl+Shift+H` · `Cmd+Shift+H`) to change `calc` to `calculate_line_total`?

<details><summary>Answer</summary>

Text replacement doesn't know what the code means. It would also change `calc`
inside other words (`calculator`, `calculate`!), in comments and in strings, and
it can't tell two different things called `calc` apart. Rename Symbol asks the
language server which `calc` you mean and changes only its definition, its
imports and its uses, with a preview first.
</details>

---

## Step 3: Extract Variable and Extract Method (Act 4)

### Goal 3.1: Give an expression a name

1. In `pricing/calculator.py`, in `calculate`, select the expression
   `total([calculate_line_total(line) for line in lines])`.
2. Press **`Ctrl+.`** · **`Cmd+.`** (Quick Fix / code actions) → **Extract variable**.
3. VS Code creates a variable and asks for a name. Type:

   ```text
   lines_total
   ```

### Goal 3.2: Turn a block into a function

1. In `services/receipts.py`, in `render_receipt`, select the three lines that build `header = [ ... ]`.
2. **`Ctrl+.`** · **`Cmd+.`** → **Extract method**, and name it:

   ```text
   receipt_header
   ```

✅ **Checkpoint:** a new function `receipt_header(order)` returns the header
lines, and `render_receipt` calls it.

💡 These code actions come from **Pylance**. It also offers *Move Symbol*
(move a function to another file and fix every import). Ruff's
*organise imports* runs every time you save.

---

## Step 4: Tidy and Check (Act 4)

Refactoring must not change behaviour. The team has a fast set of tests for
exactly this moment (testing is next week's topic; today we just run them):

```bash
uv run pytest -m smoke
```

- `uv run` = run inside the project's `.venv`.
- `pytest` = Python's most widely used test runner; it finds and runs the tests in `tests/`.
- `-m smoke` = only tests **m**arked `@pytest.mark.smoke`: the team's ~17 fastest,
  most important tests (see `docs/adr/0004-test-tiers.md`). Seconds, not minutes.

✅ **Checkpoint:** `17 passed, 200 deselected, 1 xfailed`. *Deselected* means
not in the smoke tier. (The "xfailed" is
Dan's test for ORD-317: a known bug. We'll meet it again in Demo 3.)

💬 **Discuss:** Mei is happy. Are customers? (No. Refactoring made the code
clearer, but Sam is still undercharged. Clear code first, then fix the bug.)

---

## Step 5: Three Ways to Work With AI (Act 5)

*Since GitHub Copilot launched in 2021, AI assistants have become a normal part of
programming. In the IDE they come in three shapes.*

| Mode | How | Good for |
|---|---|---|
| **Autocomplete** | Just type; grey text appears; `Tab` accepts | Finishing code you've started |
| **Inline chat** | Select code, `Ctrl+I` · `Cmd+I`, describe a change | Changing a specific piece of code |
| **Chat / agent** | The Chat view (Goal 5.3): Ask, Plan or Agent | Questions about the codebase; multi-file tasks |

### Goal 5.1: Autocomplete, steered by a good name and docstring

1. At the end of `services/receipts.py`, type:

```python
def discount_summary(order: Order) -> str:
    """One line per discount, e.g. "LOYALTY -£0.81", in the order applied."""
```

2. Press `Enter` and wait for the grey suggestion. `Tab` accepts it
   (`Alt+]` · `Opt+]` shows alternatives).

✅ **Checkpoint:** a function body that uses `format_price`. **Read it** before keeping it.

💡 A precise name, type hints and a docstring steer the AI much better than
throwaway comments, and they're worth keeping in the code anyway.

⚠️ **Check what you accepted.** AI suggestions differ every time, and some are
wrong. A real example from rehearsing this demo: Copilot added
`if d.amount > 0`, and Pylance immediately underlined it in red:
*Operator ">" not supported for types "Money" and "Literal[0]"*. The team's
`Money` type can't be compared with a plain number (see
`docs/adr/0002-money-as-decimal.md`). **The type checker caught the AI's
mistake**, which is exactly why the team's settings turn it on.

<details><summary>If the suggestion is wrong or missing: a correct version</summary>

Replace the function with:

```python
def discount_summary(order: Order) -> str:
    """One line per discount, e.g. "LOYALTY -£0.81", in the order applied."""
    return "\n".join(f"{d.code} {format_price(-d.amount)}" for d in order.discounts)
```

For Sam's order this gives `MEALDEAL -£2.60` and `LOYALTY -£0.81`, one per line.
(`Order` and `format_price` are already imported at the top of `receipts.py`.)
</details>

### Goal 5.2: Inline chat on a selection

1. Select the whole `discount_summary` function.
2. Press `Ctrl+I` · `Cmd+I`. A small chat box opens above the selection. Type:

```text
Handle an order with no discounts by returning 'No discounts'.
```

3. Read the **diff** (red is removed, green is added), then **Keep** or **Undo**.

<details><summary>What a correct result looks like</summary>

```python
def discount_summary(order: Order) -> str:
    """One line per discount, e.g. "LOYALTY -£0.81", in the order applied."""
    if not order.discounts:
        return "No discounts"
    return "\n".join(f"{d.code} {format_price(-d.amount)}" for d in order.discounts)
```
</details>

### Goal 5.3: Ask about the codebase

1. **Open the Chat view**, any of these ways:
   - click the **chat icon** at the top of the window, next to the search box
     (it may offer **Open Chat**);
   - press `Ctrl+Alt+I` (Windows/Linux) · `Ctrl+Cmd+I` (macOS);
   - menu **View → Chat**.

   It opens on the right. If it asks you to sign in, use your GitHub account
   (Copilot Free or Student).
2. **Choose Ask mode.** Under the box where you type, a drop-down shows the
   current mode (often **Agent**). Click it and choose **Ask**: Ask mode answers
   questions without changing your files.
3. Type:

```text
Where is the loyalty discount applied in this project, and why could a
loyalty customer be undercharged when their basket has several categories?
```

💬 **Discuss:** is the answer right? How would you know? (Hold that thought: Step 7.)

---

## Step 6: Give the AI the Team's Rules (Act 5)

An AI assistant knows nothing about your team's conventions unless you tell it.
Open **`AGENTS.md`** at the root of the repo: the commands to run, and rules such
as *money is `Money`, never `float`*, *type hints everywhere* and *never edit a
test to make it pass*.

In `.vscode/settings.json`, `"chat.useAgentsMdFile": true` makes sure Copilot
reads it, for everyone on the team.

⚠️ **Privacy:** your code and prompts go to the provider's servers. Check the
Copilot settings on GitHub (including whether your data may be used for
training), and **never paste secrets** (passwords, keys, tokens).

---

## Step 7: "Great. Now Prove It." (Act 5)

In the Chat view, switch the mode to **Agent** (so it can edit files) and ask
Copilot to *fix* ORD-317:

```text
Fix ORD-317: loyalty customers are undercharged when their basket has
several categories. Explain the cause before changing anything.
```

It will probably sound confident, and it may even be right. But:

> **Jordan:** Great. Now prove it.

| Developers and AI (evidence) | |
|---|---|
| Stack Overflow 2025 | 84% use or plan to use AI tools; **46% don't trust** their accuracy; the top frustration (66%) is answers that are "almost right, but not quite" |
| METR randomised trial, 2025 (preprint) | Experienced developers were **19% slower** with AI on their own projects, but *believed* they were 20% faster |
| Cui et al., *Management Science*, 2026 | Across 4,867 developers, AI assistants increased completed tasks by about 26%, most for juniors |

**Undo** any change the AI made (`Ctrl+Z` · `Cmd+Z`, or **Undo** in the chat).
Demo 3 finds the real cause, with evidence.

💬 **Discuss:** which is worse: an AI that says "I don't know", or one that's
confidently, plausibly wrong?

---

## Try It Yourself (lab practice)

1. Rename the variable `running` in `PriceCalculator.calculate` to `running_total`.
   Why doesn't the `running` parameter of `_apply` change?
2. Use inline chat to add Google-style docstrings to `loyalty/tiers.py`. Check
   every claim against the code.
3. Ask the chat: *"Which functions call `format_price`?"* Then check with Find All
   References. Do they agree?

<details><summary>What to look for</summary>

1. Rename Symbol renames one **symbol**: the local variable in `calculate`. The
   parameter in `_apply` is a different variable that happens to share the name.
2. Look for invented behaviour, e.g. claims about rounding or errors that the
   code doesn't have.
3. Find All References is exact; the chat may miss or invent call sites. Use the
   chat to *explore*, and the language server to *confirm*.
</details>
