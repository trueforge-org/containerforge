
FROM ghcr.io/trueforge-org/ubuntu:24.4

# set version label
ARG VERSION
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
  download_url="https://download.foldingathome.org/releases/public/fah-client/"$(curl -s https://download.foldingathome.org/releases/public/fah-client/meta.json | jq -r '.[] | select((.package | contains("debian")) and (.package | contains("release"))) | .package' | grep -v "$TARGETARCH" | grep "tar.bz2") && \
  curl -o \
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
