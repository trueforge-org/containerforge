FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:6064d5af956ed39456b8c643d6434d9d5331f4d77c08230a413f6a1b253a1408

# set version label
ARG VERSION
ARG TARGETARCH
USER root


ARG TARGETARCH=${TARGETARCH/amd64/x64}

# environment settings
ENV HOME="/config" \
  COMPlus_EnableDiagnostics=0

RUN echo "**** install ombi ****" && \
  mkdir -p \
    /app/ombi && \
  curl -o \
  /tmp/ombi-src.tar.gz -L \
    "https://github.com/Ombi-app/Ombi/releases/download/v${VERSION}/linux-$TARGETARCH.tar.gz" && \
  tar xzf /tmp/ombi-src.tar.gz -C \
    /app/ && \
  chmod +x /app/Ombi && \
  echo "**** clean up ****" && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
USER apps
COPY . /
# ports and volumes
EXPOSE 3579
