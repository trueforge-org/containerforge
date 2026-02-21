FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:1c874769d7dc656030d189c30532396d444ab56a283f2828480b4c8a06359ee8

ARG VERSION
ARG VENDOR

USER root

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    add-apt-repository -y multiverse && \
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
    mkdir -p /config && \
    chmod 0755 /usr/local/bin/steamcmd && \
    chown -R apps:apps /usr/local/share/steamcmd /usr/local/bin/steamcmd /config && \
    rm -rf /var/lib/apt/lists/*

COPY --chmod=0755 start.sh /start.sh
USER apps
COPY --chmod=0755 . /
