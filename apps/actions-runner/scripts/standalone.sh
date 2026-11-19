#!/usr/bin/env bash
# Opt-in standalone mode (docker compose / plain `docker run`).
#
# Not used by Kubernetes / ARC, which passes its own command (e.g. run.sh) and
# runs through the inherited /start.sh unchanged. Enable it with:
#   command: /scripts/standalone.sh
set -euo pipefail

log() { echo "[standalone] $*"; }
warn() { echo "[standalone] WARNING: $*" >&2; }

RUNNER_HOME=/home/runner
STATE_DIR=/config/runner
STATE_FILES=(.runner .credentials .credentials_rsaparams)

: "${RUNNER_REPOSITORY_URL:?RUNNER_REPOSITORY_URL is required (repository or organisation URL)}"

# ---------------------------
# Docker access
# ---------------------------
setup_docker() {
    local host="${DOCKER_HOST:-unix:///var/run/docker.sock}"
    case "$host" in
        tcp://*|ssh://*)
            log "DOCKER_HOST=$host, using remote Docker daemon"
            return 0
            ;;
    esac
    local sock="${host#unix://}"

    if [ ! -S "$sock" ]; then
        if [ "${RUNNER_DIND:-auto}" = "false" ]; then
            warn "no Docker socket at $sock and RUNNER_DIND=false, docker-based steps will fail"
            return 0
        fi
        log "no Docker socket at $sock, trying to start dockerd"
        sudo -n sh -c 'nohup dockerd >/tmp/dockerd.log 2>&1 &' || true
        for _ in $(seq 1 30); do
            [ -S "$sock" ] && break
            sleep 1
        done
        if [ ! -S "$sock" ]; then
            warn "dockerd did not start (container is probably not privileged), docker-based steps will fail. See /tmp/dockerd.log"
            return 0
        fi
    fi

    if [ -w "$sock" ]; then
        return 0
    fi

    if [ -n "${STANDALONE_REEXEC:-}" ]; then
        warn "no write access to $sock after group fix, docker-based steps will fail"
        return 0
    fi

    local gid group
    gid=$(stat -c '%g' "$sock")
    group=$(getent group "$gid" | cut -d: -f1 || true)
    if [ -z "$group" ]; then
        group=dockerhost
        sudo -n groupadd -g "$gid" "$group" 2>/dev/null || true
    fi
    if sudo -n usermod -aG "$group" "$(id -un)" 2>/dev/null; then
        log "added $(id -un) to group $group (GID $gid), re-executing"
        # A running process never picks up new groups, so start a fresh one.
        export STANDALONE_REEXEC=1
        exec sudo -n -E -u "$(id -un)" "$0" "$@"
    fi
    warn "could not grant access to $sock, docker-based steps will fail"
}

# ---------------------------
# Registration
# ---------------------------
restore_state() {
    local f
    for f in "${STATE_FILES[@]}"; do
        if [ -f "$STATE_DIR/$f" ]; then
            cp -p "$STATE_DIR/$f" "$RUNNER_HOME/$f"
        fi
    done
}

save_state() {
    local f
    mkdir -p "$STATE_DIR"
    for f in "${STATE_FILES[@]}"; do
        if [ -f "$RUNNER_HOME/$f" ]; then
            cp -p "$RUNNER_HOME/$f" "$STATE_DIR/$f"
        fi
    done
}

register() {
    : "${RUNNER_TOKEN:?RUNNER_TOKEN is required for the initial registration}"

    local args=(
        --unattended --replace
        --url "$RUNNER_REPOSITORY_URL"
        --token "$RUNNER_TOKEN"
        --name "${RUNNER_NAME:-$(hostname)}"
        --work "${RUNNER_WORKDIR:-/tmp/runner/work}"
    )
    [ -n "${RUNNER_LABELS:-}" ] && args+=(--labels "$RUNNER_LABELS")
    [ -n "${RUNNER_GROUP:-}" ] && args+=(--runnergroup "$RUNNER_GROUP")
    [ "${RUNNER_EPHEMERAL:-false}" = "true" ] && args+=(--ephemeral)
    [ "${RUNNER_DISABLE_UPDATE:-false}" = "true" ] && args+=(--disableupdate)

    ./config.sh "${args[@]}"
    save_state
}

cleanup() {
    trap - INT TERM
    if [ -n "${RUN_PID:-}" ]; then
        kill -TERM "$RUN_PID" 2>/dev/null || true
        wait "$RUN_PID" 2>/dev/null || true
    fi
    if [ "${RUNNER_REMOVE_ON_EXIT:-false}" = "true" ] && [ -f "$RUNNER_HOME/.runner" ]; then
        log "removing runner registration"
        ./config.sh remove --token "${RUNNER_TOKEN:-}" || warn "could not remove runner"
        rm -rf "$STATE_DIR"
    fi
}

setup_docker "$@"

cd "$RUNNER_HOME"
mkdir -p "${RUNNER_WORKDIR:-/tmp/runner/work}"
restore_state

if [ -f .runner ]; then
    log "existing runner configuration found, skipping registration"
else
    register
fi

trap 'cleanup; exit 143' INT TERM
./run.sh &
RUN_PID=$!
rc=0
wait "$RUN_PID" || rc=$?
exit "$rc"
