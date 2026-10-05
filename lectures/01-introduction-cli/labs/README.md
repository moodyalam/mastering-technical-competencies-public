# Lab 1: Linux Command Line

Three self-paced labs share one scenario and one set of files. Each lab stands alone, but they are written to be done in order.

| Lab | Topics | Time | Needs |
|---|---|---|---|
| [Beginner](lab1-beginner.md) | Navigation, files and folders, wildcards | about 25 min | Any terminal |
| [Intermediate](lab1-intermediate.md) | Redirection, pipes, permissions, `chmod` | about 35 min | Any terminal |
| [Advanced](lab1-advanced.md) | `sudo`, `chown`, `apt`, `systemd` | about 30 min | `sudo` on your own machine |

## Platform

Use WSL2 (Ubuntu), macOS Terminal or a Linux machine of your own. linux.bath works for the Beginner and Intermediate labs, but it is a shared system and probably gives you no `sudo`.

- Advanced labs need `sudo`. `apt` also needs a Debian-based system (WSL Ubuntu or Linux), and Step 4 needs systemd. Where you cannot run a task, read its solution.
- macOS has no `apt`.

## Setup

The lab files are in the `linux-lab` folder next to this README. You may move `linux-lab` to your home folder (`~/linux-lab`) for ease; the solutions assume that location.

## How to use the labs

Each task states a goal. Try it first, opening **Hint** if you are stuck. Hints point you to the built-in help: `<command> --help` gives a short summary of a command's options and `man <command>` the full manual (`q` quits). On macOS most commands have no `--help`, so use `man` instead. Then open **Solution** to check your command and output. Type commands rather than pasting them.

> ⚠️ Run each command in your own terminal. If something looks wrong, run `pwd` to check where you are.

## The files

| File | Used for |
|---|---|
| `server.log` | A 120-line server log (date, time, level, service, message), searched in the Intermediate lab |
| `team.txt` | An unsorted list of names, used for sorting |
| `deploy.sh` | A deployment script that is not yet executable, used in the permissions tasks |

## Clean up

```bash
cd ~
rm -r ~/linux-lab
```

If you installed `tree` and want it gone: `sudo apt remove tree`.
