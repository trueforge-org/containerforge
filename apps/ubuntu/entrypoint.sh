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

check_devices() {
    local WARNINGS=0
    local BAD_DEVICES=()
    local MISSING_GROUPS_MAP=()  # store missing GIDs per device as "device:gid1,gid2"
    local TOTAL_MISSING_GROUPS=() # all missing GIDs
    local USER_UID=${1:-$(id -u)}
    local USER_GIDS
    local DEVICE_TYPE=$2   # "video" or "sound"

    echo "[Entrypoint] Checking Device permissions for $DEVICE_TYPE devices..."

    # Get all groups the user belongs to
    USER_GIDS=$(id -G "$USER_UID")

    # Gather devices based on type
    local FILES=()
    if [ "$DEVICE_TYPE" = "video" ]; then
        while IFS= read -r f; do FILES+=("$f"); done < <(find /dev/dri /dev/dvb /dev/vchiq /dev/vc-mem /dev/kfd -type c 2>/dev/null)
        while IFS= read -r f; do FILES+=("$f"); done < <(find /dev -maxdepth 1 -name 'video[0-9]' -type c 2>/dev/null)
    elif [ "$DEVICE_TYPE" = "sound" ]; then
        while IFS= read -r f; do FILES+=("$f"); done < <(find /dev/snd -type c 2>/dev/null)
    else
        echo "Unknown device type: $DEVICE_TYPE"
        return 1
    fi

    for i in "${FILES[@]}"; do
        local DEV_GID DEV_UID MODE GROUP_PERM MISSING_GIDS=()
        DEV_GID=$(stat -c '%g' "$i")
        DEV_UID=$(stat -c '%u' "$i")
        MODE=$(stat -c '%a' "$i")
        GROUP_PERM=$(( (MODE / 10) % 10 ))

        if [ "$USER_UID" -eq "$DEV_UID" ]; then
            continue
        elif echo "$USER_GIDS" | tr ' ' '\n' | grep -qx "$DEV_GID" && [ "$GROUP_PERM" -ge 6 ]; then
            continue
        else
            WARNINGS=$((WARNINGS + 1))
            BAD_DEVICES+=("$i")
            # check if user is missing the group
            if ! echo "$USER_GIDS" | tr ' ' '\n' | grep -qx "$DEV_GID"; then
                MISSING_GIDS+=("$DEV_GID")
                TOTAL_MISSING_GROUPS+=("$DEV_GID")
            fi
            if [ "${#MISSING_GIDS[@]}" -gt 0 ]; then
                MISSING_GROUPS_MAP+=("$i:${MISSING_GIDS[*]}")
            fi
        fi
    done

    if [ "$WARNINGS" -eq 0 ]; then
        echo "**** $DEVICE_TYPE permissions are good ****"
    else
        echo "**** Warning: some $DEVICE_TYPE devices may not have correct permissions ****"
        echo "Affected devices:"
        for d in "${BAD_DEVICES[@]}"; do
            local entry missing_gids=""
            for entry in "${MISSING_GROUPS_MAP[@]}"; do
                if [[ $entry == "$d:"* ]]; then
                    missing_gids=${entry#*:}
                fi
            done
            if [ -n "$missing_gids" ]; then
                echo "  - $d (missing GID(s): $missing_gids)"
            else
                echo "  - $d"
            fi
        done
        # Print total list of missing groups
        if [ "${#TOTAL_MISSING_GROUPS[@]}" -gt 0 ]; then
            # Remove duplicates
            local UNIQUE_GROUPS
            UNIQUE_GROUPS=($(echo "${TOTAL_MISSING_GROUPS[@]}" | tr ' ' '\n' | sort -nu))
            echo ""
            echo "Total list of missing GIDs for $DEVICE_TYPE: ${UNIQUE_GROUPS[*]}"
        fi
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

check_devices "$UID" video
check_devices "$UID" sound

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
