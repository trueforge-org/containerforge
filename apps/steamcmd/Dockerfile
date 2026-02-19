FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:3209530ed3169bb7c62c9010745abf292a4bcbe5b8757787aebcce488c09d520

ARG VERSION
ARG VENDOR
ARG STEAMCMD_SHA256

USER root

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl lib32gcc-s1 lib32stdc++6 && \
    mkdir -p /usr/local/share/steamcmd && \
    curl -fsSL https://media.steampowered.com/client/steamcmd_linux.tar.gz -o /tmp/steamcmd_linux.tar.gz && \
    echo "${STEAMCMD_SHA256}  /tmp/steamcmd_linux.tar.gz" | sha256sum -c - && \
    tar -xzf /tmp/steamcmd_linux.tar.gz -C /usr/local/share/steamcmd && \
    printf '%s\n' \
        '#!/usr/bin/env bash' \
        'set -euo pipefail' \
        '' \
        'export HOME=/tmp/steamcmd' \
        'mkdir -p "${HOME}"' \
        '' \
        'exec /usr/local/share/steamcmd/steamcmd.sh "$@"' \
        > /usr/local/bin/steamcmd && \
    chmod 0755 /usr/local/bin/steamcmd && \
    chown -R apps:apps /usr/local/share/steamcmd /usr/local/bin/steamcmd && \
    rm -f /tmp/steamcmd_linux.tar.gz && \
    rm -rf /var/lib/apt/lists/*

USER apps
COPY container-test.yaml /container-test.yaml
