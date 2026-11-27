FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG VENDOR

USER root

# Same SteamCMD install as apps/steamcmd, plus the 32-bit libs the upstream wrapper installs.
# UNVERIFIED: the lib32 packages may already come with steamcmd:i386; check on build.
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    add-apt-repository -y multiverse && \
    apt-get update && \
    echo steamcmd steam/question select "I AGREE" | debconf-set-selections && \
    echo steamcmd steam/license note '' | debconf-set-selections && \
    apt-get install -y --no-install-recommends \
        steamcmd:i386=0~${VERSION} \
        lib32gcc-s1 \
        lib32stdc++6 \
        lib32z1 && \
    mkdir -p /usr/local/share/steamcmd && \
    ln -sf /usr/games/steamcmd /usr/local/share/steamcmd/steamcmd.sh && \
    mkdir -p /config && \
    chown -R apps:apps /config && \
    rm -rf /var/lib/apt/lists/*

COPY --chmod=0755 start.sh /start.sh

USER apps
COPY --chmod=0755 . /

ENV HOME=/config \
    TMPDIR=/tmp

ENTRYPOINT ["/start.sh"]

EXPOSE 27015/tcp 27015/udp

VOLUME /config
