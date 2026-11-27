FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS build

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  DOTNET_CLI_HOME=/tmp \
  DOTNET_CLI_TELEMETRY_OPTOUT=1 \
  NUGET_PACKAGES=/tmp/nuget

# UNVERIFIED: dotnet-sdk-9.0, nodejs and npm in the 26.04 archive for amd64 and arm64.
RUN apt-get update && \
  apt-get install -y --no-install-recommends dotnet-sdk-9.0 nodejs npm curl ca-certificates && \
  rm -rf /var/lib/apt/lists/*

# No upstream checksum is published. The source is pinned by tag over HTTPS.
RUN curl -fsSL -o /tmp/src.tar.gz \
    "https://github.com/carlreid/StreamMaster/archive/refs/tags/${VERSION}.tar.gz" && \
  mkdir -p /tmp/src && \
  tar xzf /tmp/src.tar.gz -C /tmp/src --strip-components=1 && \
  rm -f /tmp/src.tar.gz

# UNVERIFIED: project paths for the web UI and the API project. The upstream template does not show them.
# Upstream publishes -c Debug. Release is used here and is a deviation to note in the PR.
# dotnet takes x64 or arm64, so TARGETARCH is mapped.
RUN case "${TARGETARCH}" in amd64) DOTNET_ARCH=x64 ;; arm64) DOTNET_ARCH=arm64 ;; *) exit 1 ;; esac && \
  cd /tmp/src/src/StreamMaster.WebUI && npm install && npm run build && \
  mkdir -p /tmp/src/src/StreamMaster.API/wwwroot && \
  cp -r dist/. /tmp/src/src/StreamMaster.API/wwwroot/ && \
  cd /tmp/src && \
  dotnet restore src/StreamMaster.API -a "${DOTNET_ARCH}" && \
  dotnet publish src/StreamMaster.API -c Release -o /tmp/publish /p:UseAppHost=false -a "${DOTNET_ARCH}" --no-restore && \
  install -Dm644 /tmp/src/LICENSE /tmp/publish-licenses/LICENSE

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  DOTNET_RUNNING_IN_CONTAINER=true \
  ASPNETCORE_URLS=http://0.0.0.0:7095 \
  HOME=/tmp

# UNVERIFIED: aspnetcore-runtime-9.0 and ffmpeg in the 26.04 archive. Upstream uses a static BtbN ffmpeg, which may be needed for codecs.
RUN apt-get update && \
  apt-get install -y --no-install-recommends aspnetcore-runtime-9.0 ffmpeg && \
  rm -rf /var/lib/apt/lists/*

COPY --from=build /tmp/publish /app
COPY --from=build /tmp/publish-licenses/LICENSE /usr/share/licenses/streammaster/LICENSE
RUN chmod -R 755 /app

WORKDIR /app

USER apps
COPY --chmod=0755 . /

EXPOSE 7095

VOLUME /config

STOPSIGNAL SIGINT
