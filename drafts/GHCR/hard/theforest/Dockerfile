# VERSION selects the apps/steamcmd base tag (plan section 3). UNVERIFIED: the published
# ghcr.io/trueforge-org/steamcmd tag and digest have not been checked.
ARG VERSION
FROM ghcr.io/trueforge-org/steamcmd:${VERSION}

ARG VERSION
USER root

# UNVERIFIED: package names on ubuntu 26.04 (wine64 may be transitional; check with apt-cache policy).
# The game server is a Windows binary, so it runs under Wine with Xvfb as the display.
RUN \
    echo "**** install wine and xvfb ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        wine64 \
        xvfb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV HOME=/config

# add local files (replaces /start.sh of the base image, see start.sh)
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 27015/udp 27016/udp 8766/udp
VOLUME /config
