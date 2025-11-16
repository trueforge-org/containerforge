FROM ghcr.io/trueforge-org/ubuntu:24.4

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# environment settings
ENV HOME="/config"

RUN \
  apt-get update && \
  apt-get install -y \
    libicu74 && \
  echo "**** install kavita ****" && \
  mkdir -p \
    /app/kavita && \
  curl -o \
    /tmp/kavita.tar.gz -fL \
    "https://github.com/Kareadita/Kavita/releases/download/v${VERSION}/kavita-linux-$TARGETARCH.tar.gz" && \
  tar xf \
    /tmp/kavita.tar.gz -C \
    /app/kavita --strip-components=1 \
    --no-same-owner && \
  chmod +x /app/kavita/Kavita && \
  cp /app/kavita/config/appsettings-init.json /defaults/ && \
  rm -rf /app/kavita/config && \
  ln -s /config /app/kavita/config && \
  echo "**** clean up ****" && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
COPY . /
# ports and volumes
EXPOSE 5000
