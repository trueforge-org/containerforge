FROM ghcr.io/trueforge-org/ubuntu:24.4

# set version label
ARG VERSION

# environment settings
ENV HOME="/config" \
  COMPlus_EnableDiagnostics=0 \
  DEBIAN_FRONTEND="noninteractive" \
  TMPDIR=/run/ombi-temp

RUN \
  apt-get update && \
  apt-get install -y \
    libicu74 && \
  echo "**** install ombi ****" && \
  mkdir -p \
    /app/ombi && \
  if [ -z ${VERSION+x} ]; then \
    VERSION=$(curl -sX GET "https://api.github.com/repos/Ombi-app/Ombi/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
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
COPY /root /

# ports and volumes
EXPOSE 3579
