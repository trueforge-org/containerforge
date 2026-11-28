# UNVERIFIED: pin a digest once ghcr.io/trueforge-org/steamcmd is published.
ARG VERSION=20180105-5build1
FROM ghcr.io/trueforge-org/steamcmd:${VERSION}

ARG VERSION

ENV HOME=/config \
    XDG_DATA_HOME=/config

COPY --chmod=0755 . /

EXPOSE 27015/udp 27015/tcp
VOLUME /config

USER apps
