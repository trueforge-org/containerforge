
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV HOME=/config \
  WINEPREFIX=/config/wineprefix \
  WINEARCH=win64 \
  WINEDEBUG=-all \
  XDG_DATA_HOME=/config \
  XDG_CACHE_HOME=/tmp/.cache

# VERSION is the Ubuntu wine package version (not the game version). Keep in sync with docker-bake.hcl.
# UNVERIFIED: wine, wine64 and winetricks package names and versions on ubuntu 26.04 were not checked.
# The steamcmd setup follows apps/steamcmd.
RUN echo "*** Installing SteamCMD, Wine and helpers ***" && \
  if [ "${TARGETARCH}" != "amd64" ]; then echo "Space Engineers server is amd64 only"; exit 1; fi && \
  dpkg --add-architecture i386 && \
  apt-get update && \
  add-apt-repository -y multiverse && \
  apt-get update && \
  echo steamcmd steam/question select "I AGREE" | debconf-set-selections && \
  echo steamcmd steam/license note '' | debconf-set-selections && \
  apt-get install -y --no-install-recommends \
    steamcmd:i386 \
    "wine=${VERSION}*" \
    "wine64=${VERSION}*" \
    xvfb \
    winbind \
    cabextract \
    winetricks \
    iproute2 && \
  ln -sf /usr/games/steamcmd /usr/local/bin/steamcmd && \
  echo "*** Installing license ***" && \
  mkdir -p /usr/share/licenses/spaceengineers && \
  cp /usr/share/doc/wine/copyright /usr/share/licenses/spaceengineers/wine-copyright && \
  echo "*** Cleaning Up ***" && \
  mkdir -p /config && \
  chown apps:apps /config && \
  rm -rf /var/lib/apt/lists/* /tmp/*

USER apps
COPY --chmod=0755 . /


EXPOSE 27016/udp

VOLUME /config

WORKDIR /config
CMD ["/start.sh"]
