FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION

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
    mkdir -p /config && \
    chown -R apps:apps /usr/local/share/steamcmd /config && \
    rm -rf /var/lib/apt/lists/*

COPY --chmod=0755 start.sh /start.sh
USER apps
COPY --chmod=0755 . /

VOLUME /config
# UNVERIFIED: 27015/udp is the upstream GAME_PORT default; confirm Core Keeper binds it.
EXPOSE 27015/udp
ENTRYPOINT ["/start.sh"]
