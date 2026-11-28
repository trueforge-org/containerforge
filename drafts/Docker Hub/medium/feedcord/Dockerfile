FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS build

ARG VERSION
ARG TARGETARCH
ARG DOTNET_CHANNEL=9.0
USER root

ENV \
  DOTNET_CLI_HOME=/tmp \
  NUGET_PACKAGES=/tmp/nuget \
  DOTNET_CLI_TELEMETRY_OPTOUT=1 \
  DOTNET_NOLOGO=1

# UNVERIFIED: v3.1.0 targets net7.0 (EOL). This build retargets to net9.0 with
# -p:TargetFramework. If the build fails, pin master commit c9568b96 instead.
RUN echo "*** Installing .NET SDK ${DOTNET_CHANNEL} ***" && \
  curl -fsSL -o /tmp/dotnet-install.sh https://dot.net/v1/dotnet-install.sh && \
  bash /tmp/dotnet-install.sh --channel "${DOTNET_CHANNEL}" --install-dir /tmp/dotnet-sdk && \
  echo "*** Fetching FeedCord ${VERSION} ***" && \
  mkdir -p /tmp/src && \
  curl -fsSL -o /tmp/feedcord.tar.gz \
    "https://github.com/Qolors/FeedCord/archive/refs/tags/v${VERSION}.tar.gz" && \
  tar xzf /tmp/feedcord.tar.gz -C /tmp/src --strip-components=1 && \
  echo "*** Building FeedCord ***" && \
  cd /tmp/src/FeedCord && \
  /tmp/dotnet-sdk/dotnet publish FeedCord.csproj -c Release \
    -p:TargetFramework=net9.0 -o /tmp/publish

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG DOTNET_CHANNEL=9.0
USER root

ENV \
  DOTNET_ROOT=/app/dotnet \
  DOTNET_BUNDLE_EXTRACT_BASE_DIR=/tmp \
  DOTNET_CLI_HOME=/tmp \
  DOTNET_gcServer=0 \
  DOTNET_EnableDiagnostics=0 \
  DOTNET_NOLOGO=1

RUN echo "*** Installing .NET runtime ${DOTNET_CHANNEL} ***" && \
  curl -fsSL -o /tmp/dotnet-install.sh https://dot.net/v1/dotnet-install.sh && \
  bash /tmp/dotnet-install.sh --channel "${DOTNET_CHANNEL}" --runtime dotnet --install-dir /app/dotnet && \
  mkdir -p /app/feedcord /usr/share/licenses/feedcord && \
  ln -s /config/feed_dump.csv /app/feedcord/feed_dump.csv && \
  echo "*** Cleaning Up ***" && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -rf /tmp/*

COPY --from=build /tmp/publish/ /app/feedcord/
COPY --from=build /tmp/src/LICENSE /usr/share/licenses/feedcord/LICENSE
RUN chown -R apps:apps /app/feedcord && chmod -R 755 /app/feedcord

USER apps
COPY --chmod=0755 . /

VOLUME /config
WORKDIR /config
