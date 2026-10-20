# Lab 1: Linux Command Line

Three self-paced labs share one scenario and one set of files. Each lab stands alone, but they are written to be done in order.

| Lab | Topics | Time |
|---|---|---|
| [Beginner](lab1-beginner.md) | Navigation, files and folders, wildcards | about 25 min |
| [Intermediate](lab1-intermediate.md) | Redirection, pipes, permissions, `chmod` | about 35 min |
| [Advanced](lab1-advanced.md) | `sudo`, `chown`, `apt`, `systemd` | about 30 min |

You can do the labs in either of two ways:

- **Option A: on your own machine.** Use your own terminal and the files in `linux-lab`.
- **Option B: in the lab container.** Use an Ubuntu environment with the files ready and `sudo` available. The Beginner lab also checks your work as you go and gives you a score.

## Option A: on your own machine

Use WSL2 (Ubuntu), macOS Terminal or a Linux machine of your own. linux.bath works for the Beginner and Intermediate labs, but it is a shared system and probably gives you no `sudo`.

- Advanced labs need `sudo`. `apt` also needs a Debian-based system (WSL Ubuntu or Linux), and Step 4 needs systemd. Where you cannot run a task, read its solution.
- macOS has no `apt`.

The lab files are in the `linux-lab` folder next to this README. You may move `linux-lab` to your home folder (`~/linux-lab`) for ease; the solutions assume that location.

## Option B: in the lab container

Install [Docker](https://docs.docker.com/get-started/get-docker/), then download the lab image (about 150 MB, so do this before the lab):

```bash
docker pull <image>
```

Start the lab container. You are now the user `student` in `/home/student`, with the lab files in `~/linux-lab`:

```bash
docker run -it --name linux-lab <image>
```

| To | Run |
|---|---|
| Leave the lab | `exit` |
| Carry on later, where you left off | `docker start -ai linux-lab` |
| Start again from scratch | `docker rm linux-lab`, then the `docker run` command above |
| Copy your Beginner results out of the container | `docker cp linux-lab:/home/student/beginner-results.txt .` |

- The password for `student`, which `sudo` asks for, is `student`.
- The platform notes in the lab sheets (macOS, WSL, linux.bath) do not apply in the container.
- Advanced Step 4 (`systemd`) cannot run in a container: read its solutions.

In the Beginner lab, the container shows each task, marks it ✓ as soon as you complete it, and gives your score at the end:

| Command | What it does |
|---|---|
| `lab` | Shows the current task |
| `lab hint` | Shows the hint |
| `lab solution` | Prints the solution for you to type; the task counts as missed |
| `lab fix` | Sets up the task's result so you can carry on; the task counts as missed |
| `lab score` | Shows your score so far |
| `lab reset` | Deletes `workspace` and your progress, and starts the lab again |

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

On your own machine:

```bash
cd ~
rm -r ~/linux-lab
```

If you installed `tree` and want it gone: `sudo apt remove tree`.

In the lab container, when you have finished all three labs:

```bash
docker rm linux-lab
docker rmi <image>
```
