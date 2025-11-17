
FROM ghcr.io/trueforge-org/ubuntu:24.4

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ARG SPECIAL=${TARGETARCH/amd64/10-64bit}
ARG SPECIAL=${TARGETARCH/arm64/stable-arm64}

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
  download_url="https://download.foldingathome.org/releases/public/fah-client/debian-${SPECIAL}/release/fah-client_8.4.9_${TARGETARCH}.deb" \
  && curl -o \
    /tmp/fah.tar.bz2 -L \
    ${download_url} && \
  tar xf /tmp/fah.tar.bz2 -C /app --strip-components=1 && \
  echo "**** cleanup ****" && \
  apt-get clean && \
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
