# syntax=docker/dockerfile:1

# Start with the official Python 3.12 lightweight image
FROM python:3.12-slim

# Install core utilities, git, and file/process utilities the CLI demo needs:
# tree/findutils for navigation & search, less for paging, nano for editing,
# procps for `ps`/`kill` (Step 8), which for PATH resolution (Step 9)
RUN apt-get update && apt-get install -y \
  curl \
  git \
  gnupg \
  tree \
  findutils \
  less \
  nano \
  procps \
  which \
  && rm -rf /var/lib/apt/lists/*

# Debian's slim images exclude man pages by default to save space, which
# breaks `man grep` / `man uniq` (Step 6). Remove that exclusion and
# reinstall the affected packages so their man pages actually get installed.
RUN rm -f /etc/dpkg/dpkg.cfg.d/docker \
  && apt-get update \
  && apt-get install -y --reinstall coreutils grep man-db \
  && rm -rf /var/lib/apt/lists/*

# Install GitHub CLI (gh) via its official Debian repository
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
  dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
  && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
  tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && apt-get update \
  && apt-get install -y gh \
  && rm -rf /var/lib/apt/lists/*

# Install Google Antigravity CLI.
# The server may send the installer gzip-compressed, so --compressed is needed
# for curl to decode it. Downloading to a file first (instead of piping into
# bash) makes the build fail clearly if the download itself fails.
RUN curl -fsSL --compressed https://antigravity.google/cli/install.sh -o /tmp/agy-install.sh \
  && bash /tmp/agy-install.sh \
  && rm /tmp/agy-install.sh

# Antigravity installs to ~/.local/bin by default, so we add it to the PATH
ENV PATH="/root/.local/bin:${PATH}"

# Demo git identity so `git commit` works out of the box in class
RUN git config --global user.name "Course Student" \
  && git config --global user.email "student@example.com" \
  && git config --global init.defaultBranch main

# ---------------------------------------------------------------------------
# Lecture 1, Part A demo content: "The 3 AM Page"
# Built at image-build time so the image is fully self-contained -- no
# manual setup before class. Stored under /opt/demo-assets/ (not
# /workspace/) because a `-v ...:/workspace` bind mount at runtime would
# otherwise hide it; the entrypoint below copies it into /workspace fresh
# on every container start, whether or not a volume is mounted.
# ---------------------------------------------------------------------------
RUN <<'EOF'
#!/bin/bash
set -euo pipefail

ASSETS=/opt/demo-assets/checkout-incident
mkdir -p "$ASSETS/logs" "$ASSETS/scripts" "$ASSETS/bin"

cat > "$ASSETS/README.txt" << 'NOTE'
Hey, whoever's on call today.
Checkout died around 3AM. I patched it enough to limp along but didn't have time to dig into the actual cause. Logs are in logs/.
I know there was a script to restart the service but I can't find it for the life of me, in this new repo.
Also, novastack-diag stopped working (don't know why or where it is) so diagnostics are out of whack.
Good luck.
— Jordan
NOTE

echo "scratch notes, ignore" > "$ASSETS/notes.tmp"
echo "old backup, superseded" > "$ASSETS/old_backup_DO_NOT_USE.log"

# checkout.log: ~2950 lines of INFO noise (Steps 3-4: wc/head/tail/grep)
for i in $(seq 1 2950); do
  m=$(printf "%02d" $(( (i / 60) % 60 )))
  s=$(printf "%02d" $(( i % 60 )))
  oid=$(printf "%05d" $(( (i * 37) % 99999 )))
  echo "02:${m}:${s} INFO checkout: request processed successfully (order_id=${oid})"
done > "$ASSETS/logs/checkout.log"

# payment-worker.log: the real clue -- 3 different error types, then one FATAL
{
  echo "02:58:01 INFO payment-worker: worker started"
  echo "02:58:02 INFO payment-worker: connected to payment-gateway:5432"

  # Error type 1: connection refused (18 times)
  for i in $(seq 1 18); do
    ss=$(printf "%02d" $(( 10 + i )))
    echo "03:11:${ss} ERROR payment-worker: connection refused (payment-gateway:5432)"
  done

  # Error type 2: connection timeout (20 times)
  for i in $(seq 19 38); do
    ss=$(printf "%02d" $(( 10 + i )))
    echo "03:11:${ss} ERROR payment-worker: connection timeout (payment-gateway:5432)"
  done

  # Error type 3: request queued but gateway unresponsive (9 times)
  for i in $(seq 39 47); do
    ss=$(printf "%02d" $(( 10 + i )))
    echo "03:11:${ss} ERROR payment-worker: request queued but gateway unresponsive"
  done

  echo "03:12:04 FATAL payment-worker: connection pool exhausted, shutting down"
} > "$ASSETS/logs/payment-worker.log"

# Step 7: exists, deliberately NOT executable
cat > "$ASSETS/scripts/restart-service.sh" << 'SCRIPT'
#!/bin/bash
echo "Restarting checkout service..."
echo "Service restarted. Uptime reset."
SCRIPT

# Step 9: exists and IS executable -- just not on PATH
cat > "$ASSETS/bin/novastack-diag" << 'SCRIPT'
#!/bin/bash
echo "NovaStack diagnostic tool v1"
echo "Checking known process leaks..."
if pgrep -f "leak-simulator" > /dev/null; then
    echo "FOUND: orphaned leak-simulator process still running"
else
    echo "No process leaks detected."
fi
SCRIPT
chmod +x "$ASSETS/bin/novastack-diag"

# Step 8: the planted background process, started by the entrypoint below
cat > /opt/demo-assets/leak-simulator.py << 'PYEOF'
import time
while True:
    time.sleep(1)
PYEOF
EOF

# Entrypoint: seed fresh demo content into /workspace and start the planted
# background process on every container start, then hand off to the normal
# interactive shell -- students and lecturer never run a setup step.
RUN <<'EOF'
#!/bin/bash
cat > /usr/local/bin/entrypoint.sh << 'ENTRY'
#!/bin/bash
mkdir -p /workspace
cp -r /opt/demo-assets/checkout-incident /workspace/ 2>/dev/null || true
nohup python3 /opt/demo-assets/leak-simulator.py > /dev/null 2>&1 &
exec "$@"
ENTRY
chmod +x /usr/local/bin/entrypoint.sh
EOF

WORKDIR /workspace
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash"]
