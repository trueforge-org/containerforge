FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION

USER root

# Same SteamCMD install as apps/steamcmd (amd64 only, 32-bit SteamCMD binary).
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
    mkdir -p /config && \
    chown -R apps:apps /config && \
    rm -rf /var/lib/apt/lists/*

ENV \
  HOME=/config \
  XDG_DATA_HOME=/config \
  STEAM_INSTALL_DIR=/config/serverfiles

USER apps
COPY --chmod=0755 . /

EXPOSE 7777/udp 15000/udp 27015/udp

VOLUME /config
