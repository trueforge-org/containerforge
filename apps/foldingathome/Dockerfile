
FROM ghcr.io/trueforge-org/ubuntu:24.4

# set version label
ARG VERSION
ARG TARGETARCH
USER root

#Add needed nvidia environment variables for container toolkit
ENV NVIDIA_DRIVER_CAPABILITIES="compute,video,utility"

# global environment settings
ENV DEBIAN_FRONTEND="noninteractive"

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y \
    bzip2 \
    intel-opencl-icd \
    libexpat1 && \
  echo "**** install foldingathome ****" && \
  download_url="https://download.foldingathome.org/releases/public/fah-client/debian-10-64bit/release/fah-client_8.4.9_${TARGETARCH}.deb" && \
  if [ "$TARGETARCH" = "arm64" ]; then \
    download_url="https://download.foldingathome.org/releases/public/fah-client/debian-stable-arm64/release/fah-client_8.4.9_${TARGETARCH}.deb"; \
  fi && \
  curl -o \
    /tmp/fah.tar.bz2 -L \
    ${download_url} && \
  dpkg -i /tmp/fah-client_8.4.9_${TARGETARCH}.deb && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /var/log/*

# add local files
USER apps
COPY ./root/ /

# ports and volumes
EXPOSE 7396

VOLUME /config
