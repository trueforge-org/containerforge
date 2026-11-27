FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
USER root

# UNVERIFIED: package names on ubuntu 26.04 (check with apt-cache policy in a scratch build).
# Option A from the plan: distro Avidemux instead of compiling 2.8.1 from source.
# Desktop layer (Xvfb + x11vnc + noVNC via websockify) is the plan's open Blocker 1.
RUN \
    echo "**** install avidemux and desktop ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        avidemux3-plugins-qt5 \
        avidemux3-qt5 \
        fonts-noto-core \
        novnc \
        websockify \
        x11vnc \
        xvfb && \
    echo "**** license (UNVERIFIED path, Debian-style copyright file) ****" && \
    mkdir -p /usr/share/licenses/avidemux && \
    cp /usr/share/doc/avidemux3-core/copyright /usr/share/licenses/avidemux/LICENSE && \
    echo "**** filesystem setup ****" && \
    mkdir -p /config /storage && \
    chown apps:apps /config /storage && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV HOME=/config \
    XDG_CONFIG_HOME=/config/xdg/config \
    XDG_DATA_HOME=/config/xdg/data \
    XDG_CACHE_HOME=/tmp/xdg/cache \
    DISPLAY=:1

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 5800 5900
VOLUME /config

WORKDIR /config
