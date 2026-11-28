# Upstream: dani-garcia/vaultwarden docker/Dockerfile.debian @ 6ed6921 (Rust build, xx cross helper, web-vault).
# Adapted: Ubuntu final stage, USER apps, port 8080, data in /config.

FROM --platform=$BUILDPLATFORM docker.io/tonistiigi/xx@sha256:40fe21f44bb8cddf1eb1226db190d0a984118f62ee02a91b77d99448d28264a6 AS xx
FROM --platform=$BUILDPLATFORM docker.io/vaultwarden/web-vault@sha256:7baaa7d5349742548b6c44e557c1512157b22010cdf314ccc399ffdcacb5eb52 AS vault
FROM --platform=$BUILDPLATFORM docker.io/library/rust:1.99.1-slim-trixie@sha256:f6c4a35d21dbb3c89d7a8d056c193e94fc09037f2b58dd858b09c39a47dd02d7 AS build

ARG VERSION
ARG TARGETPLATFORM
ARG CARGO_PROFILE=release
ARG DB=sqlite,mysql,postgresql
ARG VW_VERSION=${VERSION}

ENV DEBIAN_FRONTEND=noninteractive \
  CARGO_HOME=/tmp/cargo

COPY --from=xx / /

RUN apt-get update && \
  apt-get install -y --no-install-recommends clang && \
  xx-apt-get install -y --no-install-recommends \
    libpq-dev \
    libpq5 \
    libssl-dev \
    libmariadb-dev \
    pkg-config \
    zlib1g-dev \
    xx-c-essentials && \
  rm -rf /var/lib/apt/lists/*

# Source is pinned by git tag (no release assets or checksum published upstream).
RUN mkdir -p /app && \
  curl -fsSL -o /tmp/vaultwarden.tar.gz \
    "https://github.com/dani-garcia/vaultwarden/archive/refs/tags/${VERSION}.tar.gz" && \
  tar xf /tmp/vaultwarden.tar.gz -C /app --strip-components=1 && \
  rm /tmp/vaultwarden.tar.gz

WORKDIR /app

# UNVERIFIED: the target-triple output path. The upstream Dockerfile copies the binary
# to /app/target/final/vaultwarden; confirm the cp source on the first build.
RUN if [ "$(xx-info arch)" = "arm64" ]; then \
    export RUSTFLAGS="-Clink-arg=-Wl,--fix-cortex-a53-843419"; \
  fi && \
  xx-cargo build --features "${DB}" --profile "${CARGO_PROFILE}" && \
  mkdir -p /app/target/final && \
  cp "/app/target/$(xx-cargo --print-target-triple)/${CARGO_PROFILE}/vaultwarden" /app/target/final/vaultwarden

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
USER root

# UNVERIFIED: DATA_FOLDER name for vaultwarden 1.37.5 (upstream image does not set it).
ENV ROCKET_PROFILE=release \
  ROCKET_ADDRESS=0.0.0.0 \
  ROCKET_PORT=8080 \
  DATA_FOLDER=/config \
  HOME=/config

# Check the base first: ca-certificates and openssl may already be present.
RUN echo "*** Installing runtime libraries ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ca-certificates \
    libmariadb3 \
    libpq5 \
    openssl && \
  rm -rf /var/lib/apt/lists/*

# web-vault is resolved relative to the working directory, so start.sh runs from /app.
COPY --from=vault /web-vault /app/web-vault
COPY --from=build /app/target/final/vaultwarden /app/vaultwarden

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config
