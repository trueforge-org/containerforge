
# UNVERIFIED: the Terraria dedicated server licence and download route (plan section 10). This draft assumes the TShock zip carries what is needed.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
ARG TERRARIA_VERSION
ARG TARGETARCH
# UNVERIFIED: .NET runtime route. Left empty on purpose. Set a pinned Microsoft runtime URL and its SHA-512 from releases.json before the first build.
ARG DOTNET_RUNTIME_URL=""
ARG DOTNET_RUNTIME_SHA512=""
USER root

ENV HOME=/config \
    DOTNET_ROOT=/usr/local/dotnet \
    DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    PATH=/usr/local/dotnet:${PATH}

RUN \
  echo "**** install runtime tools ****" && \
  (command -v unzip >/dev/null 2>&1 || ( \
    apt-get update && \
    apt-get install -y --no-install-recommends unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*)) && \
  echo "**** install dotnet runtime (if pinned) ****" && \
  if [ -n "${DOTNET_RUNTIME_URL}" ]; then \
    curl -fL -o /tmp/dotnet-runtime.tar.gz "${DOTNET_RUNTIME_URL}" && \
    echo "${DOTNET_RUNTIME_SHA512}  /tmp/dotnet-runtime.tar.gz" | sha512sum -c - && \
    mkdir -p /usr/local/dotnet && \
    tar xzf /tmp/dotnet-runtime.tar.gz -C /usr/local/dotnet; \
  else \
    echo "DOTNET_RUNTIME_URL not set: TShock needs a .NET 9 runtime unless the zip is self-contained"; \
  fi && \
  echo "**** fetch tshock ${VERSION} for Terraria ${TERRARIA_VERSION} ****" && \
  case "${TARGETARCH}" in \
    amd64) TS_ARCH=x64; TS_SHA256=deb9189acbdbd2ee0f0a06fffe15358033859a4ba842b22f79a84bda68600105 ;; \
    arm64) TS_ARCH=arm64; TS_SHA256=bc97babbff40e4291757b000486a82f9bbc2a0bc1360ec2a4213a84b1b772b98 ;; \
    *) echo "unsupported arch ${TARGETARCH}" && exit 1 ;; \
  esac && \
  mkdir -p /tmp/tshock-src && \
  curl -fL -o \
    /tmp/tshock.zip \
    "https://github.com/Pryaxis/TShock/releases/download/v${VERSION}/TShock-${VERSION}-for-Terraria-${TERRARIA_VERSION}-linux-${TS_ARCH}-Release.zip" && \
  echo "${TS_SHA256}  /tmp/tshock.zip" | sha256sum -c - && \
  unzip -q /tmp/tshock.zip -d /tmp/tshock-src && \
  echo "**** install licence ****" && \
  install -D -m 0644 \
    /tmp/tshock-src/LICENSE \
    /usr/share/licenses/terraria-tshock/LICENSE && \
  echo "**** move server files into place ****" && \
  mv /tmp/tshock-src /app/tshock && \
  chown -R apps:apps /app/tshock && \
  chmod -R 755 /app/tshock && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/*

# add local files
USER apps
COPY --chmod=0755 . /


# ports and volumes
EXPOSE 7777
VOLUME /config

WORKDIR /config
