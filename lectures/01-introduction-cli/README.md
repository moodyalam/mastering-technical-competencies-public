# Lecture 1: Introduction to the Command Line

**Mastering Computer Science Technical Competencies** · Lecture 1

---

## Welcome

Welcome to the first lecture of **Mastering Computer Science Technical Competencies**. This module is about the practical skills you'll use from your first day in a software job, and we start with the most fundamental one: the **command line**.

You might wonder why we're learning to type commands when AI agents can now run the terminal for us. That's exactly the point of this lecture. AI agents work **in** the terminal: they read files, run commands and change things on your behalf. To use them safely, you need to understand what they're doing, decide whether to approve it, and check whether they got it right. **We're learning the command line to supervise AI tools, not instead of them.**

Throughout the lecture, we'll investigate one realistic problem: a production outage at a company called NovaStack, which we call **"The 3 AM Page"**. We'll solve it three different ways, by hand and with an AI agent, and compare the results.

---

## What You'll Learn

By the end of this lecture, you'll be able to:

- **Navigate** a Linux system and **manage files** from the command line.
- **Search and analyse** large log files by chaining small commands together with **pipes**.
- **Fix common problems** with file **permissions**, the **`PATH`** and running **processes**.
- **Run** a ready-made lab environment with **Docker**.
- **Use an AI command-line agent** in plan mode, print mode and interactive mode, with **permission rules** that keep you in control.
- **Critically review** an AI agent's work, and verify its claims with commands whose answers you can trust.

---

## Before the Lecture

Please do these before you arrive, so we can start straight away:

1. **Have a Google account ready.** You'll use it to sign in to the AI agent. If your university account doesn't work, a personal one is fine.
2. **Create a GitHub account**, and register for **[GitHub Education](https://education.github.com/students)** to get free access to professional developer tools as a student.
3. **Get the course materials** from the programme's GitHub repository: use **Code → Download ZIP**, or clone it with Git.
4. **Install Docker Desktop** from [docker.com](https://www.docker.com/products/docker-desktop/), and check it runs.
5. **Download the lecture image** (about 730 MB), so you're not waiting during the lecture:

```bash
docker pull moodyalam/mastering-cs:lecture01
```

✅ **Checkpoint:** the command finishes with `docker.io/moodyalam/mastering-cs:lecture01`.

---

## How This Lecture Works

| Part | What happens |
|---|---|
| **Framing** | Why command-line skills still matter when AI agents can drive the terminal |
| **Live demos** | We investigate the 3 AM Page together, three different ways |
| **In-class exercise** | You practise the core commands yourself, without AI |
| **Lab** | You work through the demos and challenges at your own pace |

You don't need to type along during the live demos; watch, ask questions and join the discussions. Every demo is written as a step-by-step guide, so you can repeat it all in the lab.

---

## The Demos

Work through them in this order. Each one starts with a short recap of the scenario, so you can also come back to any of them on its own.

| Guide | Approach | What it shows | Time |
|---|---|---|---|
| [Demo 0: Setup](demo/Lecture-1-Demo-0-Setup.md) | Preparing your environment | Docker, the incident files and the AI agent, set up once | ~10 min |
| [Demo 1: Planned by an AI Agent](demo/Lecture-1-Demo-1-Script-AI-Plan.md) | One prompt to an AI agent in **plan mode** | How an AI agent reasons about a problem before acting | ~10 min |
| [Demo 2: Solved by Hand With the CLI](demo/Lecture-1-Demo-2-Script-Linux-CLI.md) | Classic CLI commands, typed by hand | The skills you need to do the work, and to check the AI's work | ~25 min |
| [Demo 3: Step by Step With an AI Agent](demo/Lecture-1-Demo-3-Script-AI-Individual-Commands.md) | The same steps as Demo 2, as plain-English requests to the AI agent | How each command maps to a natural-language request | ~20 min |

> ⚠️ **Reset the incident between demos.** Each demo changes the incident files. Demo 2, for example, fixes everything Demo 3 needs to solve. [Demo 0, Step 6](demo/Lecture-1-Demo-0-Setup.md#step-6-reset-the-incident-between-demos) shows you how to reset.

Every demo ends with **Try It Yourself** challenges for the lab, with hidden answers so you can check your work.

💬 **Discuss:** as you go, keep one question in mind: *which of the three approaches would you trust most at 3 AM, and why?*

### How to read the demos

| Icon | Meaning |
|---|---|
| ✅ | **Checkpoint:** what you should see if everything worked |
| ❓ | **Check your understanding:** a quick question. Click *Answer* to reveal it. |
| 💬 | **Discuss:** a question to talk through with the class or your lab partner |
| ⚠️ | **Warning:** something that can go wrong or cause damage |
| 💡 | **Tip:** a useful extra |

---

## Slides

The lecture slides will appear in the [`slides/`](slides/) folder after the lecture.

| Slides | Status |
|---|---|
| Lecture 1: Introduction to the Command Line | Coming soon |

---

## In-Class Exercise and Labs

| Activity | Description | Status |
|---|---|---|
| [In-class exercise](exercise/README.md) | A short, hands-on exercise with the core commands, without AI | Coming soon |
| [Beginner lab](labs/lab1-beginner.md) | Navigation, files and folders, wildcards (about 25 min, any terminal) | Available |
| [Intermediate lab](labs/lab1-intermediate.md) | Redirection, pipes, permissions and `chmod` (about 35 min, any terminal) | Available |
| [Advanced lab](labs/lab1-advanced.md) | `sudo`, `chown`, `apt` and `systemd` (about 30 min; needs `sudo` on your own machine) | Available |

The three labs share one scenario and one set of files. Start with the **[labs overview](labs/README.md)**: it explains which terminal to use and where the lab files are.

💡 The **Try It Yourself** challenges at the end of Demos 1, 2 and 3 are more practice.

---

## The Lecture Environment

Everything in this lecture runs inside a **Docker container**: a small, isolated Linux computer on your laptop. That means everyone has exactly the same setup, whatever laptop you use. Nothing you do in the container can affect your own files, except in the one folder you choose to share with it (`incident-output`, in Demo 0).

The image contains:

- A Linux system with the command-line tools we use (`grep`, `find`, `less`, `man`, `tree` and more).
- The **3 AM Page** incident files: Jordan's note, the logs, the restart script, the diagnostic tool and a rogue background process.
- **Git** and the **GitHub CLI** (`gh`).
- The **Antigravity CLI** (`agy`), Google's AI command-line agent.

The image is built from the [`Dockerfile`](Dockerfile) in this folder. Open it to see exactly what's inside; reading other people's Dockerfiles is a great way to learn. You can also build the image yourself:

```bash
docker build -t mastering-cs-lecture01 .
```

- Run this from inside this lecture folder, where the `Dockerfile` is.
- `-t mastering-cs-lecture01` = **t**ag (name) your image. Use that name instead of `moodyalam/mastering-cs:lecture01` in the `docker run` command.

💡 You don't need to build it: `docker pull moodyalam/mastering-cs:lecture01` gets the same image, ready-made.

---

## Folder Contents

```
01-introduction-cli/
├── README.md        ← you are here
├── Dockerfile       ← builds the lecture's Docker image
├── demo/            ← the step-by-step demo guides (Demos 0–3)
├── exercise/        ← the in-class exercise
├── labs/            ← beginner, intermediate and advanced labs, and their files (linux-lab/)
└── slides/          ← lecture slides (added after the lecture)
```

---

## Getting Help

- **Something not working?** Every demo ends with a **Troubleshooting** table. Setup problems (Docker, sign-in, permissions) are covered in [Demo 0: Troubleshooting](demo/Lecture-1-Demo-0-Setup.md#troubleshooting).
- **Still stuck?** Bring it to the lab session. Getting things working is part of the learning, and you won't be the only one.

> 💡 When you ask for help, include **the exact command you typed** and **the exact error message**. That's how professionals ask for help too, and it's what you'd give an AI agent as well.
