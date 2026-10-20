# Lab 1 (Beginner): Navigation and Files

**Time:** about 25 minutes · **Work:** individually · **Setup:** see the [README](README.md) first

## Scenario

You have joined the platform team at a small software company. Your first task is to set up a workspace on your own machine and organise some project files. Every step uses a command you will use again on real servers.

## Learning outcomes

By the end of this lab you can:

- Navigate the filesystem and read a directory listing.
- Create, copy, move, rename and delete files and folders.
- Use wildcards to act on many files at once, and check a pattern before deleting with it.

## Before you start

Complete the setup in the [README](README.md): `~/linux-lab` must contain `deploy.sh`, `server.log` and `team.txt`. Try each task first, opening **Hint** if you are stuck, then open **Solution** to check.

---

## Step 1: Navigation and files

### Task 1.1: Print your current location, then move into `~/linux-lab` and list its contents

<details><summary>Hint</summary>

`pwd`, `cd`, `ls`. `~` means your home folder.

</details>

<details><summary>Solution</summary>

```bash
pwd
cd ~/linux-lab
ls
```

Expected from `ls`: `deploy.sh  server.log  team.txt`

- `pwd` = print working directory: the full path of the folder you are in.
- `cd` = change directory.
- `ls` = list the contents of a folder.

</details>

### Task 1.2: Create a folder `workspace` inside `linux-lab`, move into it and create an empty file `notes.txt`

<details><summary>Hint</summary>

`mkdir`, `cd`, `touch`.

</details>

<details><summary>Solution</summary>

```bash
mkdir workspace && cd workspace
touch notes.txt
```

- `mkdir` = make directory. `&&` runs the second command only if the first succeeded.
- `touch` creates an empty file (or updates the date of an existing one).

</details>

### Task 1.3: List the folder four ways: plain, long, with hidden files, and long with hidden files

<details><summary>Hint</summary>

Run `ls --help` to see the available options. `-l` (long listing) and `-a` (all, including hidden files) are the ones you need here. Try each on its own first.

</details>

<details><summary>Solution</summary>

```bash
ls
ls -l
ls -a
ls -la
```

- `-l` = long format: permissions, owner, size and date.
- `-a` = all files, including hidden ones whose names start with `.`
- Single-letter options combine under one dash: `-la` is `-l -a`.
- `ls -a` and `ls -la` show two extra entries: `.` ("this folder") and `..` ("the folder above").

</details>

### Task 1.4: Show the contents of `notes.txt`. Why is nothing printed?

<details><summary>Hint</summary>

`cat`.

</details>

<details><summary>Solution</summary>

```bash
cat notes.txt
```

`cat` prints a file's contents. Nothing appears because `touch` created the file empty.

</details>

### Task 1.5: Read through `../server.log` one screen at a time, then quit

<details><summary>Hint</summary>

`less`. Once inside, press `h` to list its keys; `q` quits.

</details>

<details><summary>Solution</summary>

```bash
less ../server.log
```

- `Space` = next page, `b` = back a page, `q` = quit.
- `/word` then **Enter** searches for "word"; `n` jumps to the next match.
- `..` is the folder above, so `../server.log` is the log file in `linux-lab`.

</details>

---

## Step 2: Wildcards and bulk operations

*The shell expands wildcards **before** the command runs, so the command sees the full list of matching names.*

### Task 2.1: In `workspace`, create `a.txt`, `b.txt` and `c.log`, then list only the `.txt` files

<details><summary>Hint</summary>

`touch` accepts several names. `*` matches any characters.

</details>

<details><summary>Solution</summary>

```bash
touch a.txt b.txt c.log
ls *.txt
```

Expected: `a.txt  b.txt` (and `notes.txt`, which is also a `.txt` file).

</details>

### Task 2.2: Create `file1.txt`, `file2.txt` and `file10.txt`. List only the names made of `file`, exactly **one** character, then `.txt`

<details><summary>Hint</summary>

`?` matches exactly one character.

</details>

<details><summary>Solution</summary>

```bash
touch file1.txt file2.txt file10.txt
ls file?.txt
```

Expected: `file1.txt  file2.txt`. `file10.txt` is not listed because `?` matches exactly one character, whereas `*` would match any number.

</details>

### Task 2.3: Create a folder `backup` and copy every `.txt` file into it. List `backup` to check

<details><summary>Hint</summary>

Run `cp --help` to see how it is used: `cp <sources> <destination>`.

</details>

<details><summary>Solution</summary>

```bash
mkdir backup && cp *.txt backup/
ls backup/
```

Expected: `a.txt  b.txt  file1.txt  file10.txt  file2.txt  notes.txt`

`cp` copies files and leaves the originals in place.

</details>

### Task 2.4: Rename `notes.txt` to `todo.txt`, then move `todo.txt` into `backup`

<details><summary>Hint</summary>

Run `mv --help`: `mv` both renames and moves, depending on whether the destination is a folder.

</details>

<details><summary>Solution</summary>

```bash
mv notes.txt todo.txt
mv todo.txt backup/
ls
ls backup/
```

`mv <source> <destination>`: if the destination is a folder, the file moves into it; otherwise the file is renamed. `backup` now holds both `notes.txt` (the copy from Task 2.3) and `todo.txt`.

</details>

### Task 2.5: Delete every `.log` file. Check what the pattern matches **before** deleting

<details><summary>Hint</summary>

run `ls` with the pattern first, then `rm` with the same pattern.

</details>

<details><summary>Solution</summary>

```bash
ls *.log
rm *.log
ls
```

`ls *.log` shows only `c.log`, so `rm *.log` removes only that.

> ⚠️ `rm` is permanent: there is no Trash on the command line, and a wrong wildcard can delete far more than intended. Always list the pattern before you delete with it.

</details>

### Task 2.6: Delete the `backup` folder and everything in it

<details><summary>Hint</summary>

Run `rm --help` and look for the option that removes directories and their contents recursively (`-r`). `rmdir` only removes **empty** folders.

</details>

<details><summary>Solution</summary>

```bash
rmdir backup
rm -r backup
ls
```

`rmdir backup` fails with `Directory not empty`, which is a safety feature. `rm -r` removes the folder and everything inside it, again with no undo, so double-check the name.

</details>


---

## Reflection

1. Why list a wildcard pattern with `ls` before using it with `rm`?
2. What is the difference between `*` and `?` in a pattern?

<details><summary>Notes</summary>

1. `ls` shows exactly which files the pattern matches, and `rm` has no undo.
2. `*` matches any number of characters (including none); `?` matches exactly one.

</details>

---

## Troubleshooting

| Problem | Likely cause | Fix |
|---|---|---|
| `No such file or directory` | You are in a different folder from the one the step expects | Run `pwd`, then `cd` to the folder the task names. |
| `mkdir: cannot create directory 'workspace': File exists` | You already did Task 1.2 | Carry on with `cd workspace`. |
| Screen stuck after `less` | Still inside the pager | Press `q`. |
| `file?.txt` lists nothing | The `file` files from Task 2.2 do not exist | Run Task 2.2 again in `workspace`. |
| `rmdir: Directory not empty` | Expected: `rmdir` only removes empty folders | Use `rm -r` (carefully). |

