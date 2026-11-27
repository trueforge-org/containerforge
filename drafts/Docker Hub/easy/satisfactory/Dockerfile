FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
# steamcmd package version, pinned as in apps/steamcmd
ARG STEAMCMD_VERSION=20180105-5build1
USER root

# the server writes saves and Epic config under HOME; caches and scratch go to /tmp
ENV HOME=/config \
    XDG_CONFIG_HOME=/config/.config \
    XDG_DATA_HOME=/config/.local/share

# UNVERIFIED: the game is downloaded by SteamCMD at first start, not at build time;
# the game's runtime libraries on Ubuntu 26.04 are not checked yet
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    add-apt-repository -y multiverse && \
    apt-get update && \
    echo steamcmd steam/question select "I AGREE" | debconf-set-selections && \
    echo steamcmd steam/license note '' | debconf-set-selections && \
    apt-get install -y --no-install-recommends steamcmd:i386=0~${STEAMCMD_VERSION} && \
    mkdir -p /usr/local/share/steamcmd && \
    ln -sf /usr/games/steamcmd /usr/local/share/steamcmd/steamcmd.sh && \
    rm -rf /var/lib/apt/lists/*

# add local files (start.sh is copied to /start.sh)
USER apps
COPY --chmod=0755 . /

EXPOSE 7777/tcp 7777/udp 8888/tcp

# SIGINT lets the server save before it exits
STOPSIGNAL SIGINT

VOLUME /config
