#!/usr/bin/env bash

show_header() {
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
}

run_main() {
    local background=${1:-false}
    shift

    if [ -x /start.sh ]; then
        echo "[entrypoint] Info: Executing /start.sh"
        if [ "$background" = true ]; then
            echo "[entrypoint] Info: Executing /start.sh in background"
            /start.sh "$@" &
            MAIN_PID=$!
        else
            exec /start.sh "$@"
        fi
    elif [ -e /start.sh ]; then
        echo "[entrypoint] Error: /start.sh exists but is not executable" >&2
        exit 1
    elif [ "$#" -gt 0 ]; then
        echo "[entrypoint] Info: Executing passed command: $*"
        if [ "$background" = true ]; then
            echo "[entrypoint] Info: Executing passed command in background"
            "$@" &
            MAIN_PID=$!
        else
            exec "$@"
        fi
    else
        echo "[entrypoint] Error: No /start.sh and no command provided" >&2
        exit 1
    fi
}

run_scripts() {
    local runtime=${1:-false}
    shift
    [ "$runtime" = true ] && scriptname="runtime" || scriptname="init"

# Process /docker-entrypoint.d/init/ if it exists and is not empty
if [ -d "/docker-entrypoint.d/${scriptname}" ] && /usr/bin/find "/docker-entrypoint.d/${scriptname}" -mindepth 1 -maxdepth 1 -type f -print -quit 2>/dev/null | read -r v; then
    if [ "$runtime" = true ]; then
      run_main true -- "$@"
    fi

    echo "[entrypoint] Processing ${scriptname} scripts..."

    find "/docker-entrypoint.d/${scriptname}" -follow -type f -print | sort -V | while read -r f; do
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

    echo "[entrypoint] Execution of ${scriptname} scripts completed..."
else
    echo "[entrypoint] No files found in /docker-entrypoint.d/${scriptname}/, skipping"

    if [ "$runtime" = true ]; then
      run_main false -- "$@"
    fi
fi

if [ "$runtime" = true ] && [ -n "$MAIN_PID" ]; then
    wait "$MAIN_PID"
fi
}

show_header

# Ensure target directory exists
mkdir -p /docker-entrypoint.d/init /docker-entrypoint.d/runtime

# Copy scripts without overwriting
cp -rn /customscripts/* /docker-entrypoint.d/

run_scripts false
