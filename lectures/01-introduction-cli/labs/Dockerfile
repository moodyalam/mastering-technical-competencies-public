# Linux Lab 1: an Ubuntu sandbox with a non-root `student` user who can use sudo.
#
#   docker build -t linux-lab .
#   docker run -it --name linux-lab linux-lab
FROM ubuntu:24.04

# The base image strips man pages; unminimize restores them so `man <command>` works.
# tree is left out on purpose: the Advanced lab installs it with apt.
RUN apt-get update \
 && apt-get install -y --no-install-recommends unminimize \
 && yes | unminimize \
 && apt-get install -y --no-install-recommends sudo less man-db bash-completion \
 && rm -rf /var/lib/apt/lists/*

# Replace the image's default `ubuntu` user with `student` (password: student) in the sudo group.
RUN userdel -r ubuntu \
 && useradd -m -s /bin/bash -G sudo student \
 && echo 'student:student' | chpasswd

COPY --chown=student:student linux-lab/deploy.sh linux-lab/server.log linux-lab/team.txt /home/student/linux-lab/
RUN chmod 644 /home/student/linux-lab/deploy.sh

COPY lab.sh /opt/lab/lab.sh
# HISTCONTROL= records every command, which the checker reads; the Ubuntu default skips repeats.
RUN printf '\nHISTCONTROL=\nsource /opt/lab/lab.sh\n' >> /home/student/.bashrc

# Docker sets HOME for the user but not USER, which the chown task uses.
ENV USER=student
USER student
WORKDIR /home/student
CMD ["bash"]
