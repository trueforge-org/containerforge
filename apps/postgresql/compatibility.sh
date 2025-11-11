#!/usr/bin/env bash
set -euo pipefail

PGDATA_PARENT="/data"

error_wrong_mount() {
    echo "Wrong mount point set, please mount your database data to /data"
    exit 1
}

move_pgdata() {
    local src_dir="$1"
    local pgversion_file="$src_dir/PGVERSION"

    if [[ ! -f "$pgversion_file" ]]; then
        echo "PGVERSION file not found in $src_dir"
        exit 1
    fi

    PGVERSION_CONTENT=$(<"$pgversion_file")
    DEST_DIR="$PGDATA_PARENT/$PGVERSION_CONTENT"

    echo "Moving contents of $src_dir to $DEST_DIR"
    mkdir -p "$DEST_DIR"
    mv "$src_dir"/* "$DEST_DIR"/
}

# Case detection
if [[ -f "$PGDATA_PARENT/PGVERSION" ]]; then
    # Case A: /data/PGVERSION exists
    if compgen -G "$PGDATA_PARENT/[0-9][0-9]" > /dev/null; then
        echo "Folders with 2-digit names exist in /data, cannot proceed"
        exit 1
    fi
    move_pgdata "$PGDATA_PARENT"

elif [[ -f "$PGDATA_PARENT/data/PGVERSION" ]]; then
    # Case B
    move_pgdata "$PGDATA_PARENT/data"

elif [[ -f "$PGDATA_PARENT/docker/PGVERSION" ]]; then
    # Case C
    move_pgdata "$PGDATA_PARENT/docker"

elif [[ -f "/var/lib/postgresql/data/PGVERSION" ]] || \
     [[ -f "/var/lib/postgresql/docker/PGVERSION" ]] || \
     compgen -G "/var/lib/postgresql/*/docker/PGVERSION" > /dev/null || \
     compgen -G "/var/lib/postgresql/*/data/PGVERSION" > /dev/null; then
    # Case D, E, F, G
    error_wrong_mount
fi
