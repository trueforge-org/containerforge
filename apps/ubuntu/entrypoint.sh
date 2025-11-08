#!/usr/bin/env bash

echo "
Welcome to a TrueForge ContainerForge container,
You are entering the vicinity of an area adjacent to a location.
The kind of place where there might be a monster, or some kind of weird mirror.
These are just examples; it could also be something much better.
* Repository: https://github.com/trueforge-org/containerforge
* Docs: https://truecharts.org
* Bugs or feature requests should be opened in an GH issue
* Questions should be discussed in Discord
"

# Ensure target directory exists
mkdir -p /docker-entrypoint.d/init /docker-entrypoint.d/runtime

# Copy scripts without overwriting
cp -rn /customscripts/* /docker-entrypoint.d/

# Process /docker-entrypoint.d/init/ if it exists and is not empty
if [ -d "/docker-entrypoint.d/init" ] && /usr/bin/find "/docker-entrypoint.d/init" -mindepth 1 -maxdepth 1 -type f -print -quit 2>/dev/null | read -r v; then
    echo "[entrypoint] Processing init scripts..."

    find "/docker-entrypoint.d/init" -follow -type f -print | sort -V | while read -r f; do
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
    echo "[entrypoint] No files found in /docker-entrypoint.d/init/, skipping"
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

# Process /docker-entrypoint.d/runtime/ if it exists and is not empty
if [ -d "/docker-entrypoint.d/runtime" ] && /usr/bin/find "/docker-entrypoint.d/runtime" -mindepth 1 -maxdepth 1 -type f -print -quit 2>/dev/null | read -r v; then
    echo "[entrypoint] Processing runtime scripts..."

    find "/docker-entrypoint.d/runtime" -follow -type f -print | sort -V | while read -r f; do
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
    echo "[entrypoint] No files found in /docker-entrypoint.d/runtime/, skipping"
fi
