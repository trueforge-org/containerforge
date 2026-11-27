# UNVERIFIED (initial draft): the Wine and Xvfb package names on ubuntu 26.04, the Steam build pin and
# the start path have not been run. The V Rising server is Windows-only, so Wine runs it on Linux.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
USER root

# Same SteamCMD install as apps/steamcmd (i386 and multiverse), plus Wine and Xvfb for the Windows server.
RUN \
  echo "*** Installing SteamCMD, Wine and Xvfb ***" && \
  dpkg --add-architecture i386 && \
  apt-get update && \
  apt-get install -y --no-install-recommends software-properties-common && \
  add-apt-repository -y multiverse && \
  apt-get update && \
  echo steamcmd steam/question select "I AGREE" | debconf-set-selections && \
  echo steamcmd steam/license note '' | debconf-set-selections && \
  apt-get install -y --no-install-recommends \
    steamcmd:i386 \
    wine64 \
    xvfb \
    xauth && \
  rm -rf /var/lib/apt/lists/*

ENV HOME=/config \
    WINEPREFIX=/tmp/wine \
    WINEDEBUG=-all

LABEL org.opencontainers.image.version="${VERSION}"

RUN mkdir -p /config && chown apps:apps /config

USER apps
COPY --chmod=0755 . /

EXPOSE 27015/udp 27016/udp
VOLUME /config
