#!/usr/bin/env bash
# Sourced by start.sh: do not set shell options here, the caller's apply.

error_wrong_mount() {
    echo "Wrong mount point set, please mount your database data to /config"
    exit 1
}

move_pgdata() {
    local src_dir="$1"
    local pgversion_file="$src_dir/PG_VERSION"

    if [[ ! -f "$pgversion_file" ]]; then
        echo "PG_VERSION file not found in $src_dir"
        exit 1
    fi

    local pg_version
    pg_version=$(<"$pgversion_file")
    pg_version="${pg_version%%.*}"
    local dest_dir="$PGDATA_PARENT/$pg_version"

    if [[ -e "$dest_dir/PG_VERSION" ]]; then
        echo "$dest_dir already contains a database, cannot move $src_dir into it"
        exit 1
    fi

    echo "Moving contents of $src_dir to $dest_dir"
    mkdir -p "$dest_dir"
    # Case A has src == parent, so the destination must be skipped
    local entry
    for entry in "$src_dir"/* "$src_dir"/.[!.]*; do
        [[ -e "$entry" ]] || continue
        [[ "$(realpath "$entry")" == "$(realpath "$dest_dir")" ]] && continue
        # ...and leave other major-version directories alone
        [[ -d "$entry" && "$(basename "$entry")" =~ ^[0-9]+$ ]] && continue
        mv "$entry" "$dest_dir"/
    done
    chmod 700 "$dest_dir"
}

# Case detection
if [[ -f "$PGDATA_PARENT/PG_VERSION" ]]; then
    # Case A: /config/PG_VERSION exists
    move_pgdata "$PGDATA_PARENT"

elif [[ -f "$PGDATA_PARENT/data/PG_VERSION" ]]; then
    # Case B
    move_pgdata "$PGDATA_PARENT/data"

elif [[ -f "$PGDATA_PARENT/docker/PG_VERSION" ]]; then
    # Case C
    move_pgdata "$PGDATA_PARENT/docker"

elif [[ -f "/var/lib/postgresql/data/PG_VERSION" ]] || \
     [[ -f "/var/lib/postgresql/docker/PG_VERSION" ]] || \
     compgen -G "/var/lib/postgresql/*/docker/PG_VERSION" > /dev/null || \
     compgen -G "/var/lib/postgresql/*/data/PG_VERSION" > /dev/null; then
    # Case D, E, F, G
    error_wrong_mount
fi
