
# Draft from plan.md sections 2 to 4. UNVERIFIED and BLOCKER items are marked inline.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS build

ARG VERSION
ARG TARGETARCH
# Pin on first download (plan section 1 and 4). The build fails until these are set.
ARG SHOKO_SHA256
# BLOCKER: Shoko-WebUI is not pinned yet (repo, asset name and license unverified). Set WEBUI_URL, WEBUI_SHA256 before building.
ARG WEBUI_URL
ARG WEBUI_SHA256
USER root

# amd64 only for now (plan section 4: release binary is linux-x64; arm64 is a follow-up).
RUN if [ "$TARGETARCH" != "amd64" ]; then echo "Shoko CLI release zip is amd64 only" >&2; exit 1; fi

RUN echo "*** Installing Shoko CLI ***" && \
  curl -fL -o /tmp/shoko.zip \
    "https://github.com/ShokoAnime/ShokoServer/releases/download/v${VERSION}/Shoko.CLI_Framework_any-x64.zip" && \
  echo "${SHOKO_SHA256}  /tmp/shoko.zip" | sha256sum -c - && \
  mkdir -p /output/app/shoko-server && \
  unzip -q /tmp/shoko.zip -d /output/app/shoko-server && \
  test -f /output/app/shoko-server/Shoko.CLI && \
  chmod +x /output/app/shoko-server/Shoko.CLI && \
  rm /tmp/shoko.zip

RUN echo "*** Installing Shoko-WebUI ***" && \
  curl -fL -o /tmp/webui.zip "${WEBUI_URL}" && \
  echo "${WEBUI_SHA256}  /tmp/webui.zip" | sha256sum -c - && \
  mkdir -p /output/app/shoko-server/webui && \
  unzip -q /tmp/webui.zip -d /output/app/shoko-server/webui && \
  rm /tmp/webui.zip

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config \
  SHOKO_HOME=/config/Shoko.CLI \
  LANG=C.UTF-8 \
  LC_CTYPE=C.UTF-8 \
  LC_ALL=C.UTF-8 \
  DOTNET_ROOT=/app/dotnet \
  DOTNET_CLI_HOME=/tmp \
  DOTNET_CLI_TELEMETRY_OPTOUT=1 \
  DOTNET_EnableDiagnostics=0 \
  PATH=/app/dotnet:${PATH}

# UNVERIFIED: librhash0 is needed at runtime only if the CLI loads librhash (upstream installs librhash-dev).
RUN echo "*** Installing runtime dependencies ***" && \
  apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    librhash0 \
    mediainfo && \
  rm -rf /var/lib/apt/lists/*

# .NET 8 runtime, same pattern as apps/webgrabplus. No checksum is published with dotnet-install.sh (plan section 10 risk).
RUN echo "*** Installing .NET 8 runtime ***" && \
  mkdir -p /app/dotnet && \
  curl -fL -o /tmp/dotnet-install.sh https://dot.net/v1/dotnet-install.sh && \
  chmod +x /tmp/dotnet-install.sh && \
  /tmp/dotnet-install.sh -c 8.0 --install-dir /app/dotnet --runtime dotnet && \
  rm /tmp/dotnet-install.sh

COPY --from=build /output/ /

RUN echo "*** Installing license ***" && \
  mkdir -p /usr/share/licenses/shoko-server && \
  curl -fL -o /usr/share/licenses/shoko-server/LICENSE \
    "https://raw.githubusercontent.com/ShokoAnime/ShokoServer/v${VERSION}/LICENSE" && \
  chown -R apps:apps /app/shoko-server /app/dotnet && \
  chmod -R 755 /app/shoko-server /app/dotnet && \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 8111

VOLUME /config
WORKDIR /app/shoko-server
