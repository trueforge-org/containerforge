FROM ghcr.io/trueforge-org/steamcmd:20180105-5build1

ARG VERSION
ARG VENDOR

USER root

# 32/64-bit runtime libs the CS2 server needs on top of the steamcmd base.
# Exact list to be confirmed with ldd on the downloaded binary during the build test.
# UNVERIFIED: libicu (upstream libicu67 is Debian bullseye only; Ubuntu package name not confirmed).
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        lib32gcc-s1 \
        lib32stdc++6 \
        lib32z1 \
        lsof && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /config/serverfiles /config/steamcmd /config/.steam/sdk64 && \
    chown -R apps:apps /config

ENV HOME=/config \
    XDG_DATA_HOME=/config \
    TMPDIR=/tmp \
    UMASK=002 \
    GAME_ID=730 \
    GAME_PORT=27015 \
    GAME_PARAMS="" \
    VALIDATE="" \
    STEAMCMD_DIR=/config/steamcmd \
    SERVER_DIR=/config/serverfiles

COPY --chmod=0755 . /

USER apps

EXPOSE 27015/udp
EXPOSE 27020/tcp

VOLUME /config
WORKDIR /config

ENTRYPOINT ["/start.sh"]
