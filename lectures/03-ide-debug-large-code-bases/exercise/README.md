# Lecture 3 · Exercise: ORD-318

**Mastering Computer Science Technical Competencies** · Lecture 3: The Monday After the 3 AM Page

**Time:** 10 minutes · **In pairs:** one **driver** (types), one **navigator**
(reads this sheet, suggests, watches). **Swap at the 5-minute mark.**

💡 If there's no time in the lecture, do this as the warm-up for the labs.
It practises exactly what [Demo 3](../demo/Lecture-3-Demo-3-Debugging.md) showed.

---

## The Ticket

> **ORD-318: Student discount not applied on Fridays** · P2 · area: pricing
>
> Students say the 10% student discount disappears on Fridays. Mondays to
> Thursdays are fine. Riley Chen (a verified student) bought a jacket potato,
> a side salad and a sparkling water on Friday 9 October and wasn't given the
> discount. The discount runs **Monday to Friday**.

The bug is on the branch **`exercise/ORD-318`** in your fork. Don't fix it with
`print()`: use the Testing panel and the debugger.

---

## Steps

| Minutes | Do this | ✅ You're done when |
|---|---|---|
| **0–2** | Switch to the branch: click the branch name in the status bar → **`origin/exercise/ORD-318`**. Then find the function that decides which days get the discount: `Ctrl+T` · `Cmd+T`, type `student_discount`. | `utils/dates.py` is open at `is_student_discount_day` |
| **2–4** | In the **Testing** panel, run **only** `tests/unit/pricing/discounts/test_student.py`. Click the red test and read the failure. | You've found the red test, and you know which day it's about |
| **4–8** | Set a breakpoint (`F9`) on the `return` line of `is_student_discount_day`. Right-click the red test's ▷ → **Debug Test**. When it pauses, look at `day` in **Variables**, then type `day.weekday()` and `STUDENT_DISCOUNT_END` in the **Debug Console**. | You can say: "Friday is ___, the condition is ___" |
| **8–10** | Fix the line, stop the debugger (`Shift+F5`), run the test file again, then **answer on Mentimeter** (code on the slide). | Green tests, answers submitted |

**Swap driver and navigator at minute 5.**

To copy, for minutes 4–8 (type each in the Debug Console, one at a time):

```python
day.weekday()
```

```python
STUDENT_DISCOUNT_END
```


---

## The Mentimeter Questions

1. When the debugger paused on Friday's test, what was `day.weekday()`?
2. What's your fixed line of code?
3. Which panel told you the most: **Variables**, **Watch**, **Debug Console** or **Call Stack**?

---

## Finished Early?

- Use **GitLens** inline blame on the buggy line. Who changed it, in which
  ticket, and what was the change *meant* to do?
- Run the whole suite (`uv run pytest`). Is there another red test caused by
  the same bug?
- Write the regression test you'd want: a student, Friday lunchtime, the
  ticket's basket. What should the total be? (Check with
  `uv run novastack quote data/samples/student_lunch.json --at 2026-10-09T12:30`.)

<details><summary>Answer (for after the exercise)</summary>

`date.weekday()` numbers Monday as **0**, so Friday is **4**. The code says
`day.weekday() < STUDENT_DISCOUNT_END` and `STUDENT_DISCOUNT_END` is `FRIDAY`,
which is also 4. `4 < 4` is `False`, so Friday is excluded.

Fix: `return day.weekday() <= STUDENT_DISCOUNT_END`.

GitLens shows Mei Lin's commit *"refactor(dates): clearer name for the
student discount cut-off (ORD-312)"*: a "rename" that also changed `<=` to
`<`. A refactor is supposed to change names, not behaviour; this one did both,
and that's exactly why reviewers read diffs line by line.

The same bug also fails `tests/unit/utils/test_dates.py::test_student_discount_days[day2-True]`
(the Friday case). Total for the ticket's basket on Friday after the fix:
£7.30 → meal deal £6.50 → student 10% (£0.65) → **£5.85**.
</details>
