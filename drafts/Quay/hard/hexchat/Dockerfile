FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
USER root

# hexchat is pinned to the Ubuntu 26.04 package for VERSION (2.16.2-1build6).
# UNVERIFIED: the amd64 build of this package version; check that apt resolves it.
# UNVERIFIED: the GUI package set and the noVNC stack (check in the build test).
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        hexchat=${VERSION}-1build6 \
        xvfb \
        x11vnc \
        novnc \
        websockify \
        openbox \
        dbus-x11 \
        xauth && \
    install -D /usr/share/doc/hexchat/copyright /usr/share/licenses/hexchat/copyright && \
    rm -rf /var/lib/apt/lists/*

ENV HOME=/config \
    DISPLAY=:1 \
    XDG_RUNTIME_DIR=/tmp/xdg

USER apps
COPY --chmod=0755 . /

EXPOSE 6080

VOLUME /config
