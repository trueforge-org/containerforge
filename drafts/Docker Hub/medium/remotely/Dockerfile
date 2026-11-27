FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS buildstage

ARG VERSION
ARG TARGETARCH
USER root

# amd64: prebuilt release zip. arm64: no release asset, so build from source at the same tag.
# UNVERIFIED: dotnet-sdk-8.0 and aspnetcore-runtime-8.0 availability on ubuntu 26.04 (apt-cache policy)
RUN echo "*** Installing build packages ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    unzip \
    git && \
  if [ "$TARGETARCH" = "arm64" ]; then \
    apt-get install -y --no-install-recommends dotnet-sdk-8.0; \
  fi

RUN echo "*** Installing Remotely ***" && \
  if [ "$TARGETARCH" = "amd64" ]; then \
    curl -fL -o \
      /tmp/remotely.zip \
      "https://github.com/immense/Remotely/releases/download/${VERSION}/Remotely_Server_Linux-x64.zip" && \
    mkdir -p /app && \
    unzip -q /tmp/remotely.zip -d /app && \
    rm /tmp/remotely.zip; \
  else \
    git clone --depth 1 --branch "${VERSION}" https://github.com/immense/Remotely /tmp/remotely-src && \
    # UNVERIFIED: project path and output layout for the arm64 publish
    dotnet publish /tmp/remotely-src/Server/Server.csproj \
      -c Release -r linux-arm64 --self-contained false -o /app && \
    rm -rf /tmp/remotely-src; \
  fi

# UNVERIFIED: LICENSE is not confirmed in the release zip; fetch it from the tag if missing
RUN mkdir -p /usr/share/licenses/remotely && \
  (test -f /app/LICENSE && cp /app/LICENSE /usr/share/licenses/remotely/LICENSE || \
    curl -fL -o /usr/share/licenses/remotely/LICENSE \
      "https://raw.githubusercontent.com/immense/Remotely/${VERSION}/LICENSE") && \
  chown -R apps:apps /app && \
  chmod -R 755 /app && \
  echo "*** Cleaning Up ***" && \
  rm -rf /tmp/* /var/lib/apt/lists/*

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
USER root

# UNVERIFIED: needed only if the release zip is framework-dependent. Check
# Remotely_Server.runtimeconfig.json for includedFrameworks and drop this if self-contained.
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    aspnetcore-runtime-8.0 && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

ENV \
  ASPNETCORE_ENVIRONMENT=Production \
  ASPNETCORE_HTTP_PORTS=5000 \
  HOME=/config \
  DOTNET_CLI_TELEMETRY_OPTOUT=1

COPY --from=buildstage /app /app
COPY --from=buildstage /usr/share/licenses/remotely /usr/share/licenses/remotely

USER apps
COPY --chmod=0755 . /

EXPOSE 5000

VOLUME /config

WORKDIR /app
