FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# build variables
ARG VERSION
ARG STEAMCMD_VERSION
ARG VENDOR
USER root

# SteamCMD from apt, same approach as apps/steamcmd. Wine and Xvfb are needed
# for the Windows-only server; package names are UNVERIFIED for this base release.
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    add-apt-repository -y multiverse && \
    apt-get update && \
    echo steamcmd steam/question select "I AGREE" | debconf-set-selections && \
    echo steamcmd steam/license note '' | debconf-set-selections && \
    apt-get install -y --no-install-recommends \
        steamcmd:i386=0~${STEAMCMD_VERSION} \
        wine64 \
        xvfb && \
    mkdir -p /config && \
    chown -R apps:apps /config && \
    rm -rf /var/lib/apt/lists/*

# add local files
COPY --chmod=0755 start.sh /start.sh
USER apps
COPY --chmod=0755 . /

# ports and volumes
# UDP only: game, query and cube ports, per the TrueCharts chart
EXPOSE 27015/udp 27016/udp 27018/udp

WORKDIR /config
VOLUME /config
