FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:654a659958d368fa2e5f1aca4a24347c3e58f2c9c5194e1d07e3abaeb539ac32

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ARG TARGETARCH=${TARGETARCH/amd64/x64}

# environment settings
ENV HOME="/config" \
  COMPlus_EnableDiagnostics=0

RUN echo "**** install kavita ****" && \
  curl -o \
    /tmp/kavita.tar.gz -fL \
    "https://github.com/Kareadita/Kavita/releases/download/v${VERSION}/kavita-linux-$TARGETARCH.tar.gz" && \
  tar xf \
    /tmp/kavita.tar.gz -C \
    /app --strip-components=1 \
    --no-same-owner && \
  chmod +x /app/Kavita && \
  mkdir -p /defaults/ && \
  cp /app/config/appsettings-init.json /defaults/ && \
  rm -rf /app/config && \
  ln -s /config /app/config && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  chown -R apps:apps /config && chmod -R 755 /config && \
  chown -R apps:apps /defaults && chmod -R 755 /defaults && \
  echo "**** clean up ****" && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 5000
