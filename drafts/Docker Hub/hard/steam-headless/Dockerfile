FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH

USER root

ENV HOME=/config \
    DISPLAY=:55 \
    XDG_RUNTIME_DIR=/tmp/runtime \
    PULSE_SERVER=unix:/tmp/pulse/pulse-socket

# Valve ships Steam for x86-64 only, so this image is amd64 only.
RUN test "${TARGETARCH}" = "amd64" || { echo "steam-headless: amd64 only" >&2; exit 1; }

# UNVERIFIED: package names and the desktop set. Upstream pins noVNC and websockify 0.11.0. Compare with apps/xvfb and apps/kasmvnc before the PR.
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        xvfb \
        x11vnc \
        novnc \
        websockify \
        xfce4 \
        supervisor \
        pulseaudio \
        dbus-x11 \
        mesa-vulkan-drivers \
        libgl1:i386 \
        libvulkan1:i386

# Valve publishes no checksum for steam_latest.deb. This is an unpinned, rolling package.
# UNVERIFIED: the wrapper LICENSE path at the tag. The Steam Subscriber Agreement path is also UNVERIFIED (TODO: ship it from /usr/share/doc/steam-launcher/).
RUN curl -fsSL -o /tmp/steam_latest.deb "https://repo.steampowered.com/steam/archive/stable/steam_latest.deb" && \
    apt-get install -y --no-install-recommends /tmp/steam_latest.deb && \
    rm -f /tmp/steam_latest.deb && \
    mkdir -p /usr/share/licenses/steam-headless && \
    curl -fsSL -o /usr/share/licenses/steam-headless/LICENSE "https://raw.githubusercontent.com/Steam-Headless/docker-steam-headless/${VERSION}/LICENSE" && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 8083
VOLUME /config
WORKDIR /config
CMD ["/start.sh"]
