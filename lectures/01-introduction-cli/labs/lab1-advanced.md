# Lab 1 (Advanced): `sudo`, Packages and Services

**Time:** about 30 minutes · **Work:** individually · **Setup:** see the [README](README.md) first

> 🔑 **This lab needs `sudo` on a machine of your own** (WSL Ubuntu or Linux). linux.bath probably gives you no `sudo`, and macOS has no `apt`. If that is you, read the solutions only. Step 4 also needs systemd and is optional.

## Scenario

Before the release you must install a tool, hand over ownership of the deployment script, and check that a background service is healthy. All of these need elevated privileges.

## Learning outcomes

By the end of this lab you can:

- Use `sudo` to run a single command with elevated privileges, and explain the risks.
- Change file ownership with `chown`.
- Install, search for and remove software with `apt`.
- Inspect and control a service with `systemctl`, and query its logs with `journalctl`.

## Before you start

Complete the setup in the [README](README.md). Try each task first, opening **Hint** if you are stuck, then open **Solution** to check.

---

## Step 1: `sudo`

### Task 1.1: Print your username, then print it again as the superuser

<details><summary>Hint</summary>

`whoami`, then the same command prefixed with `sudo`.

</details>

<details><summary>Solution</summary>

```bash
whoami
sudo whoami
```

Expected: your username, then `root`. `sudo` ("superuser do") runs **one** command with root privileges. It asks for **your** password, not root's, and works only if your account is in the `sudo` group.

> ⚠️ Root bypasses the safety checks that normally protect the system. A mistyped `sudo rm -rf` can destroy the whole system with no warning. Prefix only the command that needs it, and re-read it before pressing Enter.

</details>


---

## Step 2: Changing ownership

### Task 2.1: Hand `~/linux-lab/deploy.sh` to root, check the owner, then take it back

<details><summary>Hint</summary>

Run `chown --help` to see the syntax: `chown OWNER[:GROUP] FILE`. Changing the owner needs `sudo`. Your username is in `$USER`; your main group is shown by `id -gn`.

</details>

<details><summary>Solution</summary>

```bash
cd ~/linux-lab
sudo chown root deploy.sh
ls -l deploy.sh
sudo chown $USER:$(id -gn) deploy.sh
ls -l deploy.sh
```

After the first command the owner column reads `root`; after the second it shows your username and group again. `chown` changes **who owns** a file, while `chmod` changes **what the permissions allow**. Changing ownership normally needs `sudo`.

</details>


---

## Step 3: Installing software with `apt`

*Needs `sudo` on a Debian-based system (WSL Ubuntu, Linux). macOS has no `apt` and linux.bath probably gives no `sudo`: read the solutions only.*

### Task 3.1: Refresh the package list

<details><summary>Hint</summary>

needs `sudo`.

</details>

<details><summary>Solution</summary>

```bash
sudo apt update
```

`apt update` downloads the current list of available packages. It does not upgrade anything.

</details>

### Task 3.2: Search for a package called `tree`

<details><summary>Solution</summary>

```bash
apt search tree
```

This lists many packages whose name or description contains "tree". The one you want is `tree`: "displays directory tree, in color".

</details>

### Task 3.3: Install `tree` and run it in `~/linux-lab`

<details><summary>Solution</summary>

```bash
sudo apt install tree
cd ~/linux-lab
tree
```

`tree` shows the folder structure: `deploy.sh`, `server.log`, `team.txt` and the `workspace` folder with its files.

</details>

### Task 3.4: Check that `tree` appears in the list of installed packages

<details><summary>Hint</summary>

Run `apt --help` to see its commands. `apt list --installed` lists every installed package; pipe it into `grep`.

</details>

<details><summary>Solution</summary>

```bash
apt list --installed | grep tree
```

Expected: a line starting `tree/...` ending with `[installed]`. (A harmless warning about `apt` not having a stable CLI interface may appear.)

</details>

### Task 3.5: Remove `tree`

<details><summary>Solution</summary>

```bash
sudo apt remove tree
```

Keeping installed software current, and removing what is not needed, is routine security practice on any managed Linux host.

</details>

---

## Step 4: Services and logs with `systemd` 🛠️ (optional)

*Needs `sudo` and a systemd machine. On WSL, run it only if `systemctl` works. On macOS and linux.bath, read the solutions only.*

We use `cron`, the scheduler, because it is enabled by default on Ubuntu and safe to stop and start.

> ⚠️ Never stop or disable `sshd` while connected over SSH: it ends your own session.

### Task 4.1: List running services and check the status of `cron`

<details><summary>Solution</summary>

```bash
systemctl list-units --type=service --state=running
systemctl status cron
```

Expected: `cron.service` appears in the list, and the status shows `active (running)`. Press `q` to leave the status pager.

</details>

### Task 4.2: Stop `cron`, confirm it stopped, then start it again

<details><summary>Hint</summary>

Run `systemctl --help` to see its commands. `stop` and `start` take a service name and need `sudo`.

</details>

<details><summary>Solution</summary>

```bash
sudo systemctl stop cron
systemctl status cron
sudo systemctl start cron
systemctl status cron
```

Status reads `inactive (dead)` after the stop and `active (running)` after the start.

</details>

### Task 4.3: Disable `cron`, then enable it again. What is the difference from stop and start?

<details><summary>Solution</summary>

```bash
sudo systemctl disable cron
sudo systemctl enable cron
```

`start` and `stop` act on the **current boot** only. `enable` and `disable` control whether the service starts automatically at the **next boot**.

</details>

### Task 4.4: Show the log entries for `cron` from the last hour

<details><summary>Hint</summary>

Run `journalctl --help`. `-u <service>` filters by service, and `--since "1 hour ago"` filters by time.

</details>

<details><summary>Solution</summary>

```bash
journalctl -u cron --since "1 hour ago"
```

`journalctl` gives one searchable, filterable interface to service logs, instead of hunting through files in `/var/log`. You may need `sudo` on some systems. Press `q` to quit.

</details>


---

## Reflection

1. Why use `sudo` on a single command rather than for a whole session?
2. What is the difference between `systemctl stop` and `systemctl disable`?

<details><summary>Notes</summary>

1. Root privileges disable the checks that normally prevent damage, so elevation should cover only the command that needs it.
2. `stop` and `start` act on the current boot only; `disable` and `enable` control whether the service starts automatically at the next boot.

</details>

---

## Troubleshooting

| Problem | Likely cause | Fix |
|---|---|---|
| `sudo: command not found` / not in sudoers | Your account cannot use `sudo` (for example on linux.bath) | Read the solutions only. |
| `chown: invalid group` | You used `$USER:$USER` on macOS or a system whose group name differs | Use `$USER:$(id -gn)`. |
| `apt: command not found` | macOS or a non-Debian system | Read the solutions only. |
| Screen stuck after `systemctl status` | Still inside the pager | Press `q`. |
| `System has not been booted with systemd` | WSL without systemd enabled | Enable systemd in WSL, or read the solutions only. |

