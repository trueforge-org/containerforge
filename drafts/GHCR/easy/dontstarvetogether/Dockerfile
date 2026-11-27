# UNVERIFIED digest: read the steamcmd base manifest digest from the registry at build time.
FROM ghcr.io/trueforge-org/steamcmd:20180105-5build1

ARG VERSION
ARG VENDOR

ENV HOME=/config \
    XDG_DATA_HOME=/config \
    TMPDIR=/tmp \
    GAME_ID=343050

RUN mkdir -p /config && chown -R apps:apps /config

COPY --chmod=0755 . /

USER apps

VOLUME /config
WORKDIR /config

ENTRYPOINT ["/start.sh"]
