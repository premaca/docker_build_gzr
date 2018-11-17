#!/bin/sh

# in Docker, the USER variable is unset by default
# but some programs (like jack toolchain) rely on it
export USER="$(whoami)"

# Launch screen session
screen -s /bin/bash
