#!/usr/bin/env bash

show_header() {
cat <<EOF
Welcome to a TrueForge ContainerForge container!

You are entering the vicinity of an area adjacent to a location.
The kind of place where there might be a monster, or some kind of weird mirror.
These are just examples; it could also be something much better.

Container Info:
  * Running as: $(id -un) (UID: $(id -u), GID: $(id -g))
  * Additional Groups: $(id -Gn)
  * Number of CPUs available: $(nproc)
  * Memory limits (if cgroup available):
    $(awk '/MemTotal/ {print "    Total: "$2/1024 " MB"}' /proc/meminfo)

Important Directories:
  * /customscripts exists: $( [ -d /customscripts ] && echo "yes" || echo "no" )
  * /customoverlay exists: $( [ -d /customoverlay ] && echo "yes" || echo "no" )

Useful Links:
  * Repository: https://github.com/trueforge-org/containerforge
  * Docs: https://trueforge.org
  * Discord: https://discord.gg/tVsPTHWTtr
  * Bugs or feature requests: open a GH issue
  * Questions: discuss in Discord
EOF
}

## TODO: do the same for /dev/snd sound devices
check_video() {
    local WARNINGS=0
    local BAD_DEVICES=()
    local USER_UID=${1:-$(id -u)}
    local USER_GIDS

    # Get all groups the user belongs to
    USER_GIDS=$(id -G "$USER_UID")

    # Gather all video/graphics devices
    local FILES=()
    while IFS= read -r f; do FILES+=("$f"); done < <(find /dev/dri /dev/dvb /dev/vchiq /dev/vc-mem /dev/kfd -type c 2>/dev/null)
    while IFS= read -r f; do FILES+=("$f"); done < <(find /dev -maxdepth 1 -name 'video[0-9]' -type c 2>/dev/null)

    for i in "${FILES[@]}"; do
        local VIDEO_GID VIDEO_UID MODE GROUP_PERM
        VIDEO_GID=$(stat -c '%g' "$i")
        VIDEO_UID=$(stat -c '%u' "$i")
        MODE=$(stat -c '%a' "$i")
        GROUP_PERM=$(( (MODE / 10) % 10 ))

        if [ "$USER_UID" -eq "$VIDEO_UID" ]; then
            continue
        elif echo "$USER_GIDS" | tr ' ' '\n' | grep -qx "$VIDEO_GID" && [ "$GROUP_PERM" -ge 6 ]; then
            continue
        else
            WARNINGS=$((WARNINGS + 1))
            BAD_DEVICES+=("$i")
        fi
    done

    if [ "$WARNINGS" -eq 0 ]; then
        echo "**** Video permissions are good ****"
    else
        echo "**** Warning: some video devices may not have correct permissions ****"
        echo "Affected devices:"
        for d in "${BAD_DEVICES[@]}"; do
            echo "  - $d"
        done
    fi
}



check_uid_gid() {
    local TARGET_UID=568
    local TARGET_GID=568

    local CURRENT_UID=$(id -u)
    local CURRENT_GID=$(id -g)

    if [[ "$CURRENT_UID" -ne "$TARGET_UID" ]]; then
        echo "[entrypoint] WARNING: Set User-ID (UID) ($CURRENT_UID) does not match the guaranteed-default: $TARGET_UID"
    fi

    if [[ "$CURRENT_GID" -ne "$TARGET_GID" ]]; then
        echo "[entrypoint] WARNING: Set Group-ID (GID) ($CURRENT_GID) does not match the guaranteed-default: $TARGET_GID"
    fi
}



### START MAIN

check_uid_gid

show_header

# Ensure target entrypoint scriptfolder exist
mkdir -p /docker-entrypoint.d


shopt -s dotglob
if [ -d "/customscripts" ]; then
  echo "[entrypoint] Merging custom scripts provided by user..."
  cp -rn /customscripts/* /docker-entrypoint.d/
fi

if [ -d "/customoverlay" ]; then
  echo "[entrypoint] Merging Custom Overlay provided by user..."

  # Copy overlay files without overwriting existing ones, including hidden files
  cp -rn /customoverlay/* /overlay/
fi

# Merge overlay into root
if [ -d "/overlay" ]; then
    echo "[entrypoint] Applying overlay..."
    cp -aT /overlay/* /
fi
shopt -u dotglob

# Process /docker-entrypoint.d/ if it exists and is not empty
if [ -d "/docker-entrypoint.d" ] && /usr/bin/find "/docker-entrypoint.d" -mindepth 1 -maxdepth 1 -type f -print -quit 2>/dev/null | read -r v; then
    echo "[entrypoint] Processing /docker-entrypoint.d/ scripts..."

    find "/docker-entrypoint.d" -follow -type f -print | sort -V | while read -r f; do
        case "$f" in
            *.envsh)
                if [ -x "$f" ]; then
                    echo "[entrypoint] Sourcing $f"
                    . "$f"
                else
                    echo "[entrypoint] Ignoring $f, not executable"
                fi
                ;;
            *.sh)
                if [ -x "$f" ]; then
                    echo "[entrypoint] Running $f"
                    "$f"
                else
                    echo "[entrypoint] Ignoring $f, not executable"
                fi
                ;;
            *) echo "[entrypoint] Ignoring $f";;
        esac
    done

    echo "[entrypoint] Configuration complete"
else
    echo "[entrypoint] No files found in /docker-entrypoint.d/, skipping"
fi

if [ "$EXP_VID" = "true" ]; then
    echo "[entrypoint] Checking video device permissions..."
    check_video
fi

# Run main application
if [ -x /start.sh ]; then
    echo "[entrypoint] Info: Executing /start.sh"
    exec /start.sh "$@"
elif [ -e /start.sh ]; then
    echo "[entrypoint] Error: /start.sh exists but is not executable" >&2
    exit 1
elif [ "$#" -gt 0 ]; then
    echo "[entrypoint] Info: Executing passed command: $*"
    exec "$@"
else
    echo "[entrypoint] Error: No /start.sh and no command provided" >&2
    exit 1
fi
