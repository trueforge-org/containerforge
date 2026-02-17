
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:7f4b4dfea9fcd818103c5d1f64cd5135785977fc90927aab58d25a155f27be4a

# set version label
ARG VERSION
ARG TARGETARCH
USER root

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
  echo "**** install code-server ****" && \
  mkdir -p /app/code-server && \
  curl -o \
    /tmp/code-server.tar.gz -L \
    "https://github.com/coder/code-server/releases/download/v${VERSION}/code-server-${VERSION}-linux-$TARGETARCH.tar.gz" && \
  tar xf /tmp/code-server.tar.gz -C \
    /app/code-server --strip-components=1 && \
  echo "**** clean up ****" && \
  apt-get clean && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -rf \
    /config/* \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
COPY /root /
COPY . /

# ports and volumes
EXPOSE 8443
