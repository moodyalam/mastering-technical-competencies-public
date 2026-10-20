# Interactive checker for Lab 1 (Beginner). The lab container loads it from ~/.bashrc.
#
# Type `lab` for the current task, `lab hint`, `lab solution`, `lab fix`, `lab score`.
# Your commands run in your normal shell; after each one, the current task is checked.
# Command-based checks read bash history, so the image sets HISTCONTROL= (record every command).

LAB_DIR="${LAB_DIR:-$HOME/linux-lab}"
LAB_W="$LAB_DIR/workspace"
LAB_STATE="$HOME/.lab-progress-beginner"
LAB_RESULTS="$HOME/beginner-results.txt"
LAB_TOTAL=11

# ---------- colours (only on a terminal)
if [ -t 1 ]; then _G=$'\033[32m'; _R=$'\033[31m'; _Y=$'\033[33m'; _B=$'\033[1m'; _N=$'\033[0m'
else _G=; _R=; _Y=; _B=; _N=; fi

# ---------- tasks: id, text, hint, solution, check, fix
_lab_id() { case $1 in 1)echo 1.1;;2)echo 1.2;;3)echo 1.3;;4)echo 1.4;;5)echo 1.5;;6)echo 2.1;;7)echo 2.2;;8)echo 2.3;;9)echo 2.4;;10)echo 2.5;;11)echo 2.6;; esac; }

_lab_text() { case $1 in
  1) echo "Print your current location, then move into the linux-lab folder and list its contents." ;;
  2) echo "Create a folder 'workspace' inside linux-lab, move into it and create an empty file 'notes.txt'." ;;
  3) echo "List the folder four ways: plain, long, with hidden files, and long with hidden files." ;;
  4) echo "Show the contents of 'notes.txt'. (Why is nothing printed?)" ;;
  5) echo "Read through '../server.log' one screen at a time, then quit." ;;
  6) echo "In workspace, create 'a.txt', 'b.txt' and 'c.log', then list only the .txt files." ;;
  7) echo "Create 'file1.txt', 'file2.txt' and 'file10.txt'. List only the names made of 'file', exactly ONE character, then '.txt'." ;;
  8) echo "Create a folder 'backup' and copy every .txt file into it. List 'backup' to check." ;;
  9) echo "Rename 'notes.txt' to 'todo.txt', then move 'todo.txt' into 'backup'." ;;
  10) echo "Delete every .log file. Check what the pattern matches BEFORE deleting." ;;
  11) echo "Delete the 'backup' folder and everything in it." ;;
esac; }

_lab_hint() { case $1 in
  1) echo "pwd, cd, ls. ~ means your home folder." ;;
  2) echo "mkdir, cd, touch." ;;
  3) echo "Run 'ls --help' to see the available options. -l (long listing) and -a (all, including hidden files) are the ones you need. Try each on its own first." ;;
  4) echo "cat." ;;
  5) echo "less. Once inside, press h to list its keys; q quits." ;;
  6) echo "touch accepts several names. * matches any characters." ;;
  7) echo "? matches exactly one character." ;;
  8) echo "Run 'cp --help' to see how it is used: cp <sources> <destination>." ;;
  9) echo "Run 'mv --help': mv both renames and moves, depending on whether the destination is a folder." ;;
  10) echo "Run ls with the pattern first, then rm with the same pattern." ;;
  11) echo "Run 'rm --help' and look for the option that removes directories and their contents recursively (-r). rmdir only removes EMPTY folders." ;;
esac; }

_lab_solution() { case $1 in
  1) printf '  pwd\n  cd ~/linux-lab\n  ls\n' ;;
  2) printf '  mkdir workspace && cd workspace\n  touch notes.txt\n' ;;
  3) printf '  ls\n  ls -l\n  ls -a\n  ls -la\n' ;;
  4) printf '  cat notes.txt\n  (nothing appears: touch created the file empty)\n' ;;
  5) printf '  less ../server.log\n  (Space = next page, b = back, /word = search, q = quit)\n' ;;
  6) printf '  touch a.txt b.txt c.log\n  ls *.txt\n' ;;
  7) printf '  touch file1.txt file2.txt file10.txt\n  ls file?.txt\n' ;;
  8) printf '  mkdir backup && cp *.txt backup/\n  ls backup/\n' ;;
  9) printf '  mv notes.txt todo.txt\n  mv todo.txt backup/\n' ;;
  10) printf '  ls *.log\n  rm *.log\n' ;;
  11) printf '  rmdir backup     (fails: Directory not empty)\n  rm -r backup\n' ;;
esac; }

_lab_has() { [ -e "$LAB_W/$1" ]; }
_lab_away() { [ "$LAB_N" -ge 3 ] && [ "$(pwd -P)" != "$LAB_W" ]; }   # tasks 1.3+ happen in workspace
_lab_ran() { printf '%s\n' "$LAB_CMD" | grep -Eq "$1"; }   # did the last command match this regex?

# Return 0 = passed, 1 = not yet, 2 = done but counted as missed (with a message).
_lab_check() { case $1 in
  1) [ "$(pwd -P)" = "$LAB_DIR" ] && _lab_ran '^ls( |$)' ;;
  2) [ "$(pwd -P)" = "$LAB_W" ] && _lab_has notes.txt ;;
  3) _lab_ran '^ls( |$)' || return 1
     case "$LAB_CMD" in
       ls) LAB_LS="${LAB_LS}p" ;;
       *-l*a*|*-a*l*) LAB_LS="${LAB_LS}b" ;;
       *-l*) LAB_LS="${LAB_LS}l" ;;
       *-a*) LAB_LS="${LAB_LS}a" ;;
     esac
     case "$LAB_LS" in *p*) ;; *) return 1;; esac
     case "$LAB_LS" in *l*) ;; *) return 1;; esac
     case "$LAB_LS" in *a*) ;; *) return 1;; esac
     case "$LAB_LS" in *b*) ;; *) return 1;; esac ;;
  4) _lab_ran '^cat .*notes\.txt' ;;
  5) _lab_ran '^less .*server\.log' ;;
  6) _lab_has a.txt && _lab_has b.txt && _lab_has c.log && _lab_ran '^ls .*\*\.txt' ;;
  7) _lab_has file1.txt && _lab_has file2.txt && _lab_has file10.txt && _lab_ran '^ls .*file\?\.txt' ;;
  8) for f in a.txt b.txt notes.txt file1.txt file2.txt file10.txt; do _lab_has "backup/$f" || return 1; done ;;
  9) _lab_has backup/todo.txt && ! _lab_has notes.txt && ! _lab_has todo.txt ;;
  10) _lab_ran '^ls .*\*\.log' && LAB_SAWLS=1
      [ -n "$(find "$LAB_W" -maxdepth 1 -name '*.log' 2>/dev/null)" ] && return 1
      [ -n "$LAB_SAWLS" ] && return 0
      echo "${_Y}You deleted the .log files without listing the pattern first. Always run 'ls <pattern>' before 'rm <pattern>'.${_N}"
      return 2 ;;
  11) ! [ -e "$LAB_W/backup" ] && _lab_has a.txt ;;
esac; }

_lab_fix() { case $1 in
  1) cd "$LAB_DIR" || return ;;
  2) mkdir -p "$LAB_W" && touch "$LAB_W/notes.txt" && cd "$LAB_W" || return ;;
  3|4|5) LAB_FORCE=1 ;;
  6) mkdir -p "$LAB_W" && touch "$LAB_W/a.txt" "$LAB_W/b.txt" "$LAB_W/c.log"; LAB_FORCE=1 ;;
  7) touch "$LAB_W/file1.txt" "$LAB_W/file2.txt" "$LAB_W/file10.txt"; LAB_FORCE=1 ;;
  8) mkdir -p "$LAB_W/backup" && cp "$LAB_W"/a.txt "$LAB_W"/b.txt "$LAB_W"/notes.txt "$LAB_W"/file1.txt "$LAB_W"/file2.txt "$LAB_W"/file10.txt "$LAB_W/backup/" ;;
  9) mv "$LAB_W/notes.txt" "$LAB_W/backup/todo.txt" ;;
  10) rm -f "$LAB_W/c.log"; LAB_SAWLS=1 ;;
  11) echo "This is the last task: run 'lab solution' and type it yourself."; return 1 ;;
esac; }

# ---------- progress: task number + one letter per finished task (P = passed, M = missed)
_lab_save() { printf '%s\n%s\n' "$LAB_N" "$LAB_RES" > "$LAB_STATE"; }
_lab_load() {
  if [ -f "$LAB_STATE" ]; then
    LAB_N="$(sed -n 1p "$LAB_STATE")"; LAB_RES="$(sed -n 2p "$LAB_STATE")"
  else
    LAB_N=1; LAB_RES=
  fi
  LAB_HELPED=; LAB_FORCE=; LAB_LS=; LAB_SAWLS=
}

_lab_show() {
  if [ "$LAB_N" -gt "$LAB_TOTAL" ]; then _lab_finish; return; fi
  printf '\n%sTask %s%s  %s\n' "$_B" "$(_lab_id "$LAB_N")" "$_N" "$(_lab_text "$LAB_N")"
  _lab_away && printf '%sThis task is done in ~/linux-lab/workspace; you are in %s.%s\n' "$_Y" "${PWD/#$HOME/\~}" "$_N"
  printf '%s(lab hint | lab solution | lab fix | lab score)%s\n\n' "$_Y" "$_N"
}

_lab_score_line() {
  _p="$(printf '%s' "$LAB_RES" | tr -cd P | wc -c | tr -d ' ')"
  printf 'Score: %s/%s' "$_p" "$LAB_TOTAL"
}

_lab_finish() {
  {
    echo "Lab 1 (Beginner) results, $(date '+%Y-%m-%d %H:%M')"
    _i=1
    while [ "$_i" -le "$LAB_TOTAL" ]; do
      _r="$(printf '%s' "$LAB_RES" | cut -c"$_i")"
      [ "$_r" = P ] && _m="passed" || _m="missed"
      echo "Task $(_lab_id "$_i"): $_m"
      _i=$((_i + 1))
    done
    _lab_score_line; echo
  } > "$LAB_RESULTS"
  printf '\n%sBeginner lab complete. %s%s\n' "$_G$_B" "$(_lab_score_line)" "$_N"
  printf 'Results saved to %s\n\n' "$LAB_RESULTS"
}

_lab_advance() {   # $1 = P or M
  LAB_RES="$LAB_RES$1"; LAB_N=$((LAB_N + 1))
  LAB_HELPED=; LAB_FORCE=; LAB_LS=; LAB_SAWLS=
  _lab_save; _lab_show
}

# ---------- runs after every command
_lab_hook() {
  [ "$LAB_N" -gt "$LAB_TOTAL" ] && return
  # Read the last history entry, once per new entry (Enter on an empty line adds none).
  if [ "$HISTCMD" != "$LAB_HISTNO" ]; then
    LAB_HISTNO="$HISTCMD"; LAB_CMD="$(HISTTIMEFORMAT='' history 1 | sed 's/^ *[0-9]*\*\{0,1\} *//')"
  else LAB_CMD=; fi
  case "$LAB_CMD" in lab|lab\ *) LAB_CMD=; return ;; esac
  if [ -n "$LAB_FORCE" ]; then
    printf '%s✓ Task %s skipped with lab fix (counted as missed)%s\n' "$_Y" "$(_lab_id "$LAB_N")" "$_N"
    LAB_CMD=; _lab_advance M; return
  fi
  _lab_check "$LAB_N"; _rc=$?
  LAB_CMD=
  if [ "$_rc" = 0 ]; then
    if [ -n "$LAB_HELPED" ]; then
      printf '%s✓ Task %s done (help was used: counted as missed)%s\n' "$_Y" "$(_lab_id "$LAB_N")" "$_N"; _lab_advance M
    else
      printf '%s✓ Task %s passed%s\n' "$_G" "$(_lab_id "$LAB_N")" "$_N"; _lab_advance P
    fi
  elif [ "$_rc" = 2 ]; then
    printf '%s✗ Task %s counted as missed%s\n' "$_R" "$(_lab_id "$LAB_N")" "$_N"; _lab_advance M
  fi
}

# ---------- the `lab` command
lab() {
  case "$1" in
    ""|task) _lab_show ;;
    hint) [ "$LAB_N" -le "$LAB_TOTAL" ] && printf '%sHint:%s %s\n' "$_Y" "$_N" "$(_lab_hint "$LAB_N")" ;;
    solution)
      [ "$LAB_N" -le "$LAB_TOTAL" ] || return
      LAB_HELPED=1
      printf '%sSolution (type it yourself; this task now counts as missed):%s\n' "$_Y" "$_N"
      _lab_away && printf '  cd ~/linux-lab/workspace\n'
      _lab_solution "$LAB_N" ;;
    fix)
      [ "$LAB_N" -le "$LAB_TOTAL" ] || return
      _lab_fix "$LAB_N" || return
      LAB_HELPED=1
      echo "Set up the result of this task for you (counted as missed). Run any command (e.g. ls) to continue." ;;
    score) _lab_score_line; printf ' (%s of %s tasks finished)\n' "${#LAB_RES}" "$LAB_TOTAL" ;;
    reset)
      printf 'This deletes %s and your progress. Continue? [y/N] ' "$LAB_W"; read -r _a
      [ "$_a" = y ] || return
      cd ~ && rm -rf "$LAB_W" "$LAB_STATE" "$LAB_RESULTS"
      _lab_load; _lab_show ;;
    stop)
      PROMPT_COMMAND="${PROMPT_COMMAND//_lab_hook;/}"
      echo "Lab checking stopped. Progress is saved: run 'source /opt/lab/lab.sh' to resume." ;;
    *) echo "Usage: lab [task|hint|solution|fix|score|reset|stop]" ;;
  esac
}

# ---------- install the hook and tab completion (once)
case "$PROMPT_COMMAND" in *_lab_hook*) ;; *) PROMPT_COMMAND="_lab_hook;${PROMPT_COMMAND}" ;; esac
complete -W "task hint solution fix score reset stop" lab
LAB_HISTNO="$HISTCMD"

_lab_load
printf '%sLinux Lab 1 (Beginner)%s: %s tasks. Your commands are checked as you go.\n' "$_B" "$_N" "$LAB_TOTAL"
_lab_show
