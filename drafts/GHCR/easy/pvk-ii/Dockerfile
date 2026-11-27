# UNVERIFIED: the steamcmd base digest is not in this repo. Pin it from the published image before merge.
ARG VERSION
FROM ghcr.io/trueforge-org/steamcmd:${VERSION}

# set version label
ARG VENDOR
USER root

ENV HOME=/config

# The base /start.sh is replaced: this image runs srcds_run directly.
COPY --chmod=0755 start.sh /start.sh

# copy local files
USER apps
COPY --chmod=0755 . /

# ports: 27015 udp (game), 27015 tcp (RCON)
EXPOSE 27015/udp 27015/tcp

VOLUME /config

WORKDIR /config
