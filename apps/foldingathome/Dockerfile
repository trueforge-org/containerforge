
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:a42a7b2fe3c044339769eca34c011337ec5ecdbb7ff3c2af30bc9105afb035b8

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
  useradd --system --home /var/lib/fah-client --shell /bin/false fah-client && \
  apt-get update && \
  apt-get install -y \
    bzip2 \
    libexpat1 \
    polkitd-pkla \
    ocl-icd-libopencl1 \
    policykit-1 && \
  if [ "$TARGETARCH" = "amd64" ]; then \
    apt-get install -y \
      intel-opencl-icd; \
  fi && \
  echo "**** install foldingathome ****" && \
  download_url="https://download.foldingathome.org/releases/public/fah-client/debian-10-64bit/release/fah-client_8.4.9_${TARGETARCH}.deb" && \
  if [ "$TARGETARCH" = "arm64" ]; then \
    download_url="https://download.foldingathome.org/releases/public/fah-client/debian-stable-arm64/release/fah-client_8.4.9_${TARGETARCH}.deb"; \
  fi && \
  curl -o \
    /tmp/fah-client.deb -L \
    ${download_url} && \
  apt install -y /tmp/fah-client.deb && \
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
COPY ./ /

# ports and volumes
EXPOSE 7396

VOLUME /config
