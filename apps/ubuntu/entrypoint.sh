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
