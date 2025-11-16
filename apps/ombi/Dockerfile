FROM ghcr.io/trueforge-org/ubuntu:24.4

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# environment settings
ENV HOME="/config" \
  COMPlus_EnableDiagnostics=0 \
   TMPDIR=/run/ombi-temp

RUN \
  apt-get update && \
  apt-get install -y \
    libicu74 && \
  echo "**** install ombi ****" && \
  mkdir -p \
    /app/ombi && \
  curl -o \
  /tmp/ombi-src.tar.gz -L \
    "https://github.com/Ombi-app/Ombi/releases/download/v${VERSION}/linux-$TARGETARCH.tar.gz" && \
  tar xzf /tmp/ombi-src.tar.gz -C \
    /app/ombi/ && \
  chmod +x /app/ombi/Ombi && \
  echo "**** clean up ****" && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
USER apps
COPY . /
# ports and volumes
EXPOSE 3579
