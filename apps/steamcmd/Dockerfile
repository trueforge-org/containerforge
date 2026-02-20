FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:3209530ed3169bb7c62c9010745abf292a4bcbe5b8757787aebcce488c09d520

ARG VERSION
ARG VENDOR

USER root

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    add-apt-repository multiverse && \
    apt-get update && \
    echo steamcmd steam/question select "I AGREE" | debconf-set-selections && \
    echo steamcmd steam/license note '' | debconf-set-selections && \
    apt-get install -y --no-install-recommends steamcmd:i386=0~${VERSION} && \
    mkdir -p /usr/local/share/steamcmd && \
    ln -sf /usr/games/steamcmd /usr/local/share/steamcmd/steamcmd.sh && \
    printf '%s' "0~${VERSION}" > /usr/local/share/steamcmd/.package-version && \
    printf '%s\n' \
        '#!/usr/bin/env bash' \
        'set -euo pipefail' \
        '' \
        'exec /start.sh "$@"' \
        > /usr/local/bin/steamcmd && \
    chmod 0755 /usr/local/bin/steamcmd && \
    chown -R apps:apps /usr/local/share/steamcmd /usr/local/bin/steamcmd && \
    rm -rf /var/lib/apt/lists/*

COPY --chmod=0755 start.sh /start.sh
USER apps
COPY container-test.yaml /container-test.yaml
