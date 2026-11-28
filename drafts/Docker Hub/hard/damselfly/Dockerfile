
# UNVERIFIED: no digest pinned for the .NET SDK image yet. Resolve it and pin it before merging.
FROM mcr.microsoft.com/dotnet/sdk:10.0@sha256:8c6edfb26c85153f236d26efebd9ad349aec403583f343f201ee67838b23658d AS build

ARG VERSION
ARG TARGETARCH
ENV \
  DOTNET_CLI_HOME=/tmp \
  NUGET_PACKAGES=/tmp/nuget

# arm64 only: amd64 uses the upstream prebuilt zip, so /out stays empty there.
# UNVERIFIED: the source archive layout (one top-level folder) and the wasm-tools workload step, copied from the upstream CI.
RUN mkdir -p /out && \
  if [ "${TARGETARCH}" = "arm64" ]; then \
    mkdir -p /src && \
    curl -fsSL "https://github.com/Webreaper/Damselfly/archive/refs/tags/${VERSION}.tar.gz" | tar xz --strip-components=1 -C /src && \
    cd /src && \
    dotnet workload install wasm-tools && \
    dotnet publish Damselfly.Web.Server -r linux-arm64 -f net10.0 -c Release --self-contained true /p:Version=${VERSION} /p:PublishTrimmed=false -o /out && \
    rm -f /out/onnxruntime_providers*.dll; \
  fi

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config \
  ASPNETCORE_URLS=http://0.0.0.0:6363 \
  DOTNET_BUNDLE_EXTRACT_BASE_DIR=/tmp/dotnet \
  DOTNET_TieredPGO=1 \
  COMPlus_EnableWriteXorExecute=0

# UNVERIFIED: libgdiplus may not exist in ubuntu 26.04. Drop it if apt cannot find it and the server runs without it.
RUN echo "*** Installing runtime dependencies ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    exiftool \
    fontconfig \
    fonts-liberation \
    libgdiplus \
    libgomp1 \
    procps \
    unzip && \
  rm -rf /var/lib/apt/lists/*

COPY --from=build /out/ /app/

# UNVERIFIED: the zip layout (server binary at the root of the zip). No checksum is published upstream. Pin the zip sha256 once it is computed.
RUN echo "*** Installing Damselfly ${VERSION} ***" && \
  mkdir -p /app && \
  if [ "${TARGETARCH}" = "amd64" ]; then \
    curl -fsSL -o /tmp/damselfly.zip "https://github.com/Webreaper/Damselfly/releases/download/${VERSION}/Server-Dist-linux.zip" && \
    unzip -q /tmp/damselfly.zip -d /app && \
    rm -f /tmp/damselfly.zip; \
  fi && \
  chmod +x /app/Damselfly.Web.Server && \
  mkdir -p /usr/share/licenses/damselfly && \
  curl -fsSL -o /usr/share/licenses/damselfly/LICENSE "https://raw.githubusercontent.com/Webreaper/Damselfly/${VERSION}/LICENSE" && \
  mkdir -p /config /thumbs /pictures && \
  chown -R apps:apps /app /config /thumbs /pictures

USER apps
COPY --chmod=0755 . /

WORKDIR /config

EXPOSE 6363

VOLUME /config
VOLUME /thumbs
