
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# No arm64 server build is published upstream, so fail early instead of shipping a broken image.
RUN \
  echo "**** check architecture ****" && \
  if [ "$TARGETARCH" != "amd64" ]; then \
    echo "no arm64 LunaMultiplayer server build is published" && exit 1; \
  fi

ENV \
  HOME=/config \
  DOTNET_CLI_HOME=/tmp \
  DOTNET_CLI_TELEMETRY_OPTOUT=1 \
  DOTNET_NOLOGO=1 \
  DOTNET_BUNDLE_EXTRACT_BASE_DIR=/tmp

# UNVERIFIED: the .NET version. 10.0 is the Ubuntu 26.04 package; the upstream wrapper uses 6.0.
# Confirm the target framework of LMP 0.29.2 (runtimeconfig.json in the zip) and pin to it.
RUN \
  echo "**** install packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    aspnetcore-runtime-10.0 \
    unzip && \
  rm -rf /var/lib/apt/lists/*

# No checksum is published for the release zip (UNVERIFIED), so the download is pinned by VERSION only.
RUN \
  echo "**** install lmp server ****" && \
  mkdir -p /app/lmp && \
  curl -fsSL -o /tmp/lmp.zip \
    "https://github.com/LunaMultiplayer/LunaMultiplayer/releases/download/${VERSION}/LunaMultiplayer-Server-linux-x64-Release.zip" && \
  unzip -q /tmp/lmp.zip -d /app/lmp && \
  chmod -R 755 /app/lmp && \
  echo "**** cleanup ****" && \
  rm -f /tmp/lmp.zip
# UNVERIFIED: the server's write folders under /app/lmp are not known yet. Build-time symlinks to /config/<dir> go here once confirmed.
# UNVERIFIED: the licence file in the zip. Upstream is MIT; copy it to /usr/share/licenses/kerbalspaceprogram-lmp/ once confirmed.

USER apps
COPY --chmod=0755 . /


EXPOSE 8800/udp

VOLUME /config

WORKDIR /config
