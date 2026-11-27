
# renovate-tracked via docker-bake.hcl VERSION (tag form 26.11, sha256 pinned below)
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

# set version label
ARG VERSION
ARG TARGETARCH
# sha256 of the tarball seen on 2026-11-24 for 26.11.1.8831. The vendor URL is not versioned, so bump with VERSION.
ARG FILEFLOWS_SHA256=44d76c2da29d6705b35953a46109deaca74d615b036deea1afdc5ad898134f42
USER root

RUN \
  echo "**** install dotnet runtime and ffmpeg ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    aspnetcore-runtime-10.0 \
    dotnet-runtime-10.0 \
    ffmpeg \
    xz-utils && \
  echo "**** fetch fileflows ****" && \
  curl -fL -o /tmp/fileflows.tar.xz https://fileflows.com/downloads/tarxz && \
  echo "${FILEFLOWS_SHA256}  /tmp/fileflows.tar.xz" | sha256sum -c - && \
  mkdir -p /app/fileflows && \
  tar -xJf /tmp/fileflows.tar.xz -C /app/fileflows && \
  grep -q "FileFlows.Server/${VERSION}\." /app/fileflows/Server/FileFlows.Server.deps.json && \
  echo "**** remap writable paths to /config and /tmp ****" && \
  ln -s /config/Data /app/fileflows/Data && \
  ln -s /config/Logs /app/fileflows/Logs && \
  ln -s /config/DockerMods /app/DockerMods && \
  ln -s /config/common /app/common && \
  ln -s /tmp/startup.log /app/startup.log && \
  echo "**** install licenses ****" && \
  mkdir -p /usr/share/licenses/fileflows && \
  cp /app/fileflows/Server/third-party.txt /usr/share/licenses/fileflows/ && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/*

ENV HOME=/config \
    DOTNET_BUNDLE_EXTRACT_BASE_DIR=/tmp/dotnet \
    DOTNET_CLI_HOME=/tmp \
    NUGET_PACKAGES=/tmp/nuget \
    DOTNET_EnableDiagnostics=0 \
    ASPNETCORE_URLS=http://0.0.0.0:5000

# /app stays root-owned and read-only for the runtime user
USER apps
# copy local files
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 5000
VOLUME /config

WORKDIR /app/fileflows/Server
