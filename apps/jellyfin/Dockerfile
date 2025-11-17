FROM ghcr.io/trueforge-org/ubuntu:24.4

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# environment settings
ENV NVIDIA_DRIVER_CAPABILITIES="compute,video,utility"
# https://github.com/dlemstra/Magick.NET/issues/707#issuecomment-785351620
ENV MALLOC_TRIM_THRESHOLD_=131072

RUN \
  echo "**** install dependencies *****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    curl \
    gpg \
    at \
    libjemalloc2 \
    mesa-va-drivers \
    xmlstarlet \
    gdebi-core && \
  \
  echo "**** download and install Jellyfin *****" && \
  curl -L -o /tmp/jellyfin_server.deb \
    "https://repo.jellyfin.org/files/server/ubuntu/latest-stable/${TARGETARCH}/jellyfin_server_${VERSION}+ubu2404_${TARGETARCH}.deb" && \
  gdebi -n /tmp/jellyfin_server.deb && \
  curl -L -o /tmp/jellyfin_web.deb \
    "https://repo.jellyfin.org/files/server/ubuntu/latest-stable/${TARGETARCH}/jellyfin_web_${VERSION}+ubu2404_${TARGETARCH}.deb" && \
  gdebi -n /tmp/jellyfin_web.deb && \
  curl -L -o /tmp/jellyfin.deb \
    "https://repo.jellyfin.org/files/server/ubuntu/latest-stable/${TARGETARCH}/jellyfin_${VERSION}+ubu2404_${TARGETARCH}.deb" && \
  gdebi -n /tmp/jellyfin.deb && \
  \
  echo "**** cleanup ****" && \
  rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# add local files
USER apps
COPY ./root/ /

# ports and volumes
EXPOSE 8096 8920
VOLUME /config
