#!/usr/bin/env bash

# Server files, configs and user-supplied pak files live in /config (fs_homepath).
# Game data is not shipped: copy legitimately owned pak files into /config/baseq3.
mkdir -p /config/baseq3

# Split GAME_PARAMS into words without globbing, so special characters do not break the command.
read -r -a game_params <<< "${GAME_PARAMS:-}"

# UNVERIFIED: fs_homepath is the ioquake3 cvar for the writable home directory; confirm on the probe run.
# UNVERIFIED: the dedicated server binary name ioq3ded from the apt package; confirm with dpkg -L ioquake3.
# The server listens on all interfaces by default; UNVERIFIED, check the probe log.
exec /usr/games/ioq3ded \
    +set fs_homepath /config \
    +set dedicated 2 \
    +set net_port "${Q3_PORT:-27960}" \
    +map "${Q3_MAP:-q3dm0}" \
    "${game_params[@]}"
