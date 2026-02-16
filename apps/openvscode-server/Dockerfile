FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:128e24cac8026983dcd46413896d467cc1ffae9d933164f758866e7519eae606

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ARG TARGETARCH=${TARGETARCH/amd64/x64}
# environment settings

ENV HOME="/config"

RUN \
  echo "**** install runtime dependencies ****" && \
  apt-get update && \
  apt-get install -y \
    git \
    libatomic1 \
    net-tools \
    sudo && \
  echo "**** install openvscode-server ****" && \
  mkdir -p /app/openvscode-server && \
  curl -o \
    /tmp/openvscode-server.tar.gz -L \
    "https://github.com/gitpod-io/openvscode-server/releases/download/openvscode-server-v${VERSION}/openvscode-server-v${VERSION}-linux-$TARGETARCH.tar.gz" && \
  tar xf \
    /tmp/openvscode-server.tar.gz -C \
    /app/openvscode-server/ --strip-components=1 && \
  echo "**** clean up ****" && \
  apt-get clean && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
COPY /root /
COPY . /
# ports and volumes
EXPOSE 3000

USER apps
