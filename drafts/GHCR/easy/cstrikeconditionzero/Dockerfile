FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION

USER root

# SteamCMD is 32-bit, so i386 is needed. The steamcmd package comes from multiverse.
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    add-apt-repository -y multiverse && \
    apt-get update && \
    echo steamcmd steam/question select "I AGREE" | debconf-set-selections && \
    echo steamcmd steam/license note '' | debconf-set-selections && \
    apt-get install -y --no-install-recommends steamcmd:i386=0~${VERSION} && \
    mkdir -p /usr/local/share/steamcmd && \
    ln -sf /usr/games/steamcmd /usr/local/share/steamcmd/steamcmd.sh && \
    mkdir -p /config && \
    chown -R apps:apps /config && \
    rm -rf /var/lib/apt/lists/*

USER apps
COPY --chmod=0755 . /

EXPOSE 27015/tcp 27015/udp

ENTRYPOINT ["/start.sh"]
