# build stage
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS build

ARG VERSION
ARG TARGETARCH
USER root

ENV DOTNET_CLI_HOME=/tmp \
    DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    DOTNET_NOLOGO=1 \
    NUGET_PACKAGES=/tmp/nuget

# UNVERIFIED: upstream setversion.sh stamps Globals.cs (VersionNumber, BuildNumber); not replicated yet
RUN \
  echo "**** install dotnet sdk ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    dotnet-sdk-10.0 && \
  echo "**** fetch source ****" && \
  mkdir -p /tmp/src && \
  curl -fL -o \
    /tmp/fenrus.tar.gz \
    "https://github.com/revenz/Fenrus/archive/${VERSION}.tar.gz" && \
  tar xzf \
    /tmp/fenrus.tar.gz -C \
    /tmp/src --strip-components=1 && \
  echo "**** compile fenrus ****" && \
  cd /tmp/src && \
  dotnet restore && \
  dotnet publish Fenrus.csproj -c Release -o /tmp/build && \
  rm -rf \
    /tmp/build/runtimes/win* \
    /tmp/build/runtimes/osx* && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/fenrus.tar.gz \
    /tmp/nuget \
    /var/lib/apt/lists/*

############## runtime stage ##############
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV Docker=1 \
    DOTNET_BUNDLE_EXTRACT_BASE_DIR=/tmp \
    DOTNET_EnableDiagnostics=0 \
    HOME=/config \
    PORT=3000 \
    PROTOCOL=http

# UNVERIFIED: libicu78 may be needed by aspnetcore (webgrabplus installs it); base may already provide ICU
RUN \
  echo "**** install dotnet runtime ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    aspnetcore-runtime-10.0 && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

COPY --from=build /tmp/build/ /app/fenrus/
COPY --from=build /tmp/src/Apps /app/fenrus/Apps
COPY --from=build /tmp/src/reset.sh /app/fenrus/reset.sh
COPY --from=build /tmp/src/license /usr/share/licenses/fenrus/LICENSE

RUN \
  echo "**** prepare app ****" && \
  chmod +x /app/fenrus/reset.sh && \
  ln -s /config/data /app/fenrus/data && \
  chmod -R 755 /app/fenrus

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 3000
VOLUME /config
WORKDIR /app/fenrus
