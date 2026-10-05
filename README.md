# Mastering Computer Science Technical Competencies

**The "3rd Semester"**: a hands-on, evidence-based programme that helps you build the technical skills employers expect from a Computer Science graduate.

Dr Moody Alam · Department of Computer Science, University of Bath

---

## Welcome

Congratulations on taking the first step. By being here, you're already doing what the best engineers do: taking charge of your own development.

Think of this programme as a **"3rd Semester"** that runs alongside your degree. Your modules teach you the theory of Computer Science. This programme is about **practice**: the tools, habits and hands-on skills you'll use from your first day in a software job. There's minimal theory here, and plenty of doing.

---

## Why This Programme Exists

Computer Science is changing faster than ever, and employers want graduates who are ready to contribute with **industry-standard tools** from day one.

The gap between graduates' skills and employers' expectations is well known, and it's widely acknowledged that academia and industry don't always share the same priorities. It shows up on both sides:

- **Employers** report that graduates often lack practical technical skills.
- **Graduates** report that the technical skills they were taught weren't always the ones that helped them find work, and that hands-on experience was often more valuable than the course itself.

New graduates tend to struggle with the same things: working with **large codebases**, **CI/CD** pipelines and GitHub workflows, **testing** and maintenance, **debugging tools**, and the **command line**. Many arrive fluent in IDEs and graphical tools, but uncomfortable in a terminal, with production logs or with build pipelines.

> **This isn't a curriculum problem; it's a practice problem.** Universities know what to teach. What students need is authentic, hands-on practice with the real tools industry uses.

That's what this programme gives you.

---

## Our Approach: Evidence-Based and Tools-First

Every topic in this programme is chosen because the evidence says it matters, not because it's fashionable. We draw on:

- **Curriculum frameworks:** the ACM/IEEE **CS2023** and **CC2020** curriculum guidelines, and **ABET** accreditation criteria.
- **Industry skills frameworks:** **SFIA** (Skills Framework for the Information Age) and **NACE** career-readiness competencies.
- **Industry data:** developer surveys such as the **Stack Overflow Developer Survey**, and job-market analysis from **Lightcast** and **LinkedIn**.

For example, here's why we start with the command line:

- **Around 93%** of developers use **Git**, and mastering Git means using the command line (Stack Overflow Developer Survey, 2023).
- **Almost half** of professional developers use **Bash/shell scripting** (Stack Overflow Developer Survey, 2025).
- High-demand roles in **DevOps**, **site reliability engineering**, **back-end** and **cloud engineering** all expect shell skills.

Industry builds skills through **practical application**: competence is measured by hands-on proficiency and experience with tools, often guided by **skills roadmaps**. We follow the same approach: **bite-sized** and **tools-first**.

### Where AI fits in

AI tools are transforming software careers, and you'll use them throughout this programme. But you'll learn them the way a professional should: **understanding what the AI does, deciding whether to trust it, and checking its work.** In Lecture 1, for example, you'll solve the same problem by hand and with an AI agent, and compare the two.

---

## What You'll Get

- **Awareness** of the technical competencies expected from a Computer Science graduate.
- **A bite-sized, tools-first path** towards gaining those competencies.
- **In-class lectures, step-by-step demos, hands-on exercises and self-study labs** to practise with.
- **An introduction to the AI tools** that are changing how software is built, and how to use them responsibly.
- **A way to "supercharge" your independent learning**, structured and informed by evidence.

---

## How Each Lecture Works

Each lecture has its own folder in this repository. Where a lecture needs a controlled environment, it has its own **Docker image** (or Dev Container), so everyone works in exactly the same environment, whatever laptop you use.

| Part | What it involves |
|---|---|
| **Before the lecture** | A few setup steps, such as installing tools or creating accounts |
| **In-class demo** | We solve a realistic problem together, first with traditional tools, then with AI and automation tools |
| **In-class exercise** | You practise the core skills yourself |
| **Self-study labs** | Beginner, medium and advanced tasks to complete at your own pace |
| **Further resources** | Extra reading and practice, on Moodle and from external sites |

Every lecture states its **competency area** and the **level** it's aimed at (for example, Beginner and Intermediate), so you can see where it fits in your development.

---

## Lectures

| # | Lecture | Competency area | Level | What you'll practise | Docker image |
|---|---|---|---|---|---|
| 1 | [Introduction to the Command Line](lectures/01-introduction-cli/README.md) | Foundational | Beginner & Intermediate | The Linux command line, and supervising an AI command-line agent | `moodyalam/mastering-cs:lecture01` |

💡 New lectures appear here as they're released.

---

## Getting Started

1. **Create a Google account** (if you don't have one). You'll use it to sign in to the AI tools.
2. **Create a GitHub account**, and register for **[GitHub Education](https://education.github.com/students)** to get free access to professional developer tools as a student.
3. **Install Docker Desktop** from [docker.com](https://www.docker.com/products/docker-desktop/), and check it runs.
4. **Get this repository**: use **Code → Download ZIP** on this page, or clone it with Git.
5. **Open the lecture folder** for this week, starting with **[Lecture 1](lectures/01-introduction-cli/README.md)**, and follow its **Demo 0 (Setup)** guide.

✅ **Checkpoint:** you can open `lectures/01-introduction-cli/README.md` on your laptop, and `docker --version` prints a version number in your terminal.

---

## Getting the Latest Materials

This repository is updated as each lecture is released. To get the latest version, either:

- **Download the ZIP again** from this page, or
- If you cloned it, update your copy with these commands:

```bash
git fetch origin
git reset --hard origin/main
```

> ⚠️ `git pull` on its own may fail after an update, because each release replaces the repository's contents. The two commands above make your copy match the latest release exactly. They **discard any changes you made** inside this folder, so keep your own work somewhere else.

---

## A Pilot, Built Together

This is a **pilot programme**, and its success depends on how you use it.

- **It's run voluntarily.** Hundreds of hours have gone into building it so far. My commitment is to put real effort into helping you develop; your commitment is to make the most of it.
- **It improves continuously**, like a CI/CD pipeline. Your feedback shapes what comes next, and volunteers who help improve it will be contacted with details.
- **Pay it forward.** Helping your fellow students is one of the best ways to deepen your own skills.
- **Places matter.** If you can't make the sessions, please let me know, so your place can go to another student.

💬 **Discuss:** which technical skill do you think will matter most in your first job, and how confident are you in it today?

---

## Getting Help

- **Something not working?** Each lecture's demos end with a **Troubleshooting** table, starting with [Lecture 1, Demo 0](lectures/01-introduction-cli/demo/Lecture-1-Demo-0-Setup.md#troubleshooting).
- **Still stuck?** Bring it to the next session, or ask on the programme's Moodle page.

> 💡 When you ask for help, include **the exact command you typed** and **the exact error message**. That's how professionals ask for help, and it's what you'd give an AI tool as well.
