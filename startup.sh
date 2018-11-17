#!/bin/sh

# in Docker, the USER variable is unset by default
# but some programs (like jack toolchain) rely on it
export USER="$(whoami)"

# copy our bashrc stuff
BASHRC="/home/build/.bashrc"
BASHRC_MODS="/home/build/bashrc"
cat "$BASHRC_MODS" >> "$BASHRC"
rm -f $BASHRC_MODS

# Launch screen session
screen -s /bin/bash
