
# UNVERIFIED: the ubuntu:26.04 digest comes from plan.md section 3; confirm it on ghcr.io before the first build.
# Source stage: fetch and extract the tagged source once, for both build stages.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS source

ARG VERSION
ARG REAPARR_SHA256
USER root

# REAPARR_SHA256 has no published value yet (see docker-bake.hcl). The build fails until it is set.
RUN echo "*** Fetching Reaparr v${VERSION} ***" && \
  curl -fL -o /tmp/reaparr.tar.gz \
    "https://github.com/Reaparr/Reaparr/archive/refs/tags/v${VERSION}.tar.gz" && \
  echo "${REAPARR_SHA256}  /tmp/reaparr.tar.gz" | sha256sum -c - && \
  mkdir -p /src && \
  tar -xzf /tmp/reaparr.tar.gz -C /src --strip-components=1 && \
  rm -f /tmp/reaparr.tar.gz

# UNVERIFIED: the Debian-based bun 1.4.0 tag (upstream uses the alpine variant); pin the digest at port time.
FROM oven/bun:1.4.0@sha256:5ff609364c049b54eb0ff560ec96319729a972078ef2c755d758f0c6ef89c2d6 AS client

ARG VERSION
COPY --from=source /src/src/AppHost/ClientApp /build/ClientApp
WORKDIR /build/ClientApp

RUN bun install --frozen-lockfile && \
  NUXT_PUBLIC_PLATFORM=docker \
  NUXT_PUBLIC_VERSION="${VERSION}" \
  bun run generate --fail-on-error

# UNVERIFIED: the sdk tag 10.0 (upstream); pin the digest at port time.
FROM mcr.microsoft.com/dotnet/sdk:10.0@sha256:8c6edfb26c85153f236d26efebd9ad349aec403583f343f201ee67838b23658d AS server

ARG VERSION
ARG TARGETARCH
COPY --from=source /src /src
WORKDIR /src

RUN case "${TARGETARCH}" in \
    amd64) RID=linux-x64 ;; \
    arm64) RID=linux-arm64 ;; \
    *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  dotnet restore src/AppHost/AppHost.csproj --locked-mode && \
  dotnet publish src/AppHost/AppHost.csproj -c Release -o /app/publish --no-restore \
    -p:ReaparrRuntimeMode=docker \
    -p:ReaparrRuntimeIdentifier="${RID}" \
    -p:Version="${VERSION}" \
    -p:InformationalVersion="${VERSION}"

# Runtime stage: ubuntu (glibc).
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
USER root

# UNVERIFIED: the upstream aspnet image is Alpine (musl), so its runtime cannot be copied onto this glibc image. The .NET runtime comes from apt instead.
# UNVERIFIED: package names on 26.04 (aspnetcore-runtime-10.0, libicu-dev, libssl3t64, libkrb5-3, gpac, mkvtoolnix); check with apt-cache.
RUN echo "*** Installing runtime packages ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    aspnetcore-runtime-10.0 \
    ffmpeg \
    gpac \
    libicu-dev \
    libkrb5-3 \
    libssl3t64 \
    mkvtoolnix && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

COPY --from=server /app/publish /app
COPY --from=client /build/ClientApp/.output/public /app/wwwroot
COPY --from=source /src/LICENSE* /usr/share/licenses/reaparr/

# /Config is a compatibility link for the capitalised path of the upstream image.
# UNVERIFIED: that the app honours the link (plan.md section 9). The media paths are mount points.
RUN echo "*** Finalising filesystem layout ***" && \
  chmod -R a+rX /app && \
  ln -s /config /Config && \
  install -d -o apps -g apps /Downloads /Movies /TvShows

ENV DOTNET_ENVIRONMENT=Production \
    REAPARR_PLATFORM=docker \
    DOTNET_URLS=http://+:7000 \
    DOTNET_BUNDLE_EXTRACT_BASE_DIR=/tmp/dotnet \
    DOTNET_CLI_HOME=/tmp \
    DOTNET_gcServer=0 \
    HOME=/config

USER apps
COPY --chmod=0755 . /

EXPOSE 7000

VOLUME /config

WORKDIR /app

CMD ["/start.sh"]
