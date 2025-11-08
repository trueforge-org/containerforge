#!/usr/bin/env bash

echo "
Welcome to a TrueForge ContainerForge container,
You are entering the vicinity of an area adjacent to a location.
The kind of place where there might be a monster, or some kind of weird mirror.
These are just examples; it could also be something much better.
* Repository: https://github.com/trueforge-org/containerforge
* Docs: https://trueforge.org
* Bugs or feature requests should be opened in an GH issue
* Questions should be discussed in Discord
"

# Ensure target entrypoint scriptfolder exist
mkdir -p /docker-entrypoint.d

echo "[entrypoint] Merging custom scripts provided by user..."
shopt -s dotglob
cp -rn /customscripts/* /docker-entrypoint.d/

if [ -d "/customoverlay" ]; then
  echo "[entrypoint] Merging Custom Overlay provided by user..."

  # Copy overlay files without overwriting existing ones, including hidden files
  cp -rn /customoverlay/* /overlay/
fi

# Merge overlay into root (or /app if desired)
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
