# Build stage: upstream builds a static musl binary with Crystal on Alpine (see upstream docker/Dockerfile).
# UNVERIFIED: the Crystal image digest must be pinned before merge.
FROM 84codes/crystal:1.22.3-alpine@sha256:c565a3f1c92bfcf9960bd500cb45021aa6851be6e9a3c7f90eafaf1a580a1b87 AS build

ARG VERSION
# UNVERIFIED: OpenSSL is built from source in upstream. Version 3.6.5 is from the pinned upstream
# Dockerfile. The full SHA-256 is NOT recorded here, so the build fails until it is supplied.
ARG OPENSSL_VERSION=3.6.5
ARG OPENSSL_SHA256=

RUN apk add --no-cache curl perl linux-headers sqlite-static yaml-static libxml2-static xz-static

RUN set -eux; \
    : "${OPENSSL_SHA256:?OPENSSL_SHA256 must be set from upstream docker/Dockerfile (UNVERIFIED)}"; \
    curl -fL -o /tmp/openssl.tar.gz "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz"; \
    echo "${OPENSSL_SHA256}  /tmp/openssl.tar.gz" | sha256sum -c -; \
    tar xzf /tmp/openssl.tar.gz -C /tmp; \
    cd "/tmp/openssl-${OPENSSL_VERSION}"; \
    ./Configure --prefix=/usr/local --openssldir=/etc/ssl no-apps no-shared; \
    make -j"$(nproc)" build_libs; \
    make install_dev; \
    rm -rf /tmp/openssl*

# Source for the release tag. UNVERIFIED: upstream needs a .git directory for version info,
# and the tag tarball does not include one.
RUN set -eux; \
    mkdir -p /src; \
    curl -fL -o /tmp/invidious.tar.gz "https://github.com/iv-org/invidious/archive/refs/tags/${VERSION}.tar.gz"; \
    tar xzf /tmp/invidious.tar.gz -C /src --strip-components=1; \
    rm /tmp/invidious.tar.gz

WORKDIR /src
RUN shards install --production

# UNVERIFIED: the exact build line against the pinned upstream Dockerfile (release flags, link flags).
RUN mkdir -p /out && \
    crystal build ./src/invidious.cr --static --release --link-flags "-lxml2 -llzma -no-pie" -o /out/invidious

# Final stage
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
USER root

# UNVERIFIED: package names on Ubuntu 26.04 (Alpine names in upstream: rsvg-convert, ttf-opensans, tzdata).
# tini is not installed: the base image already runs tini as PID 1.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        librsvg2-bin \
        fonts-open-sans && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build --chmod=0755 /out/invidious /app/invidious/invidious
COPY --from=build /src/assets /app/invidious/assets
COPY --from=build /src/locales /app/invidious/locales
COPY --from=build /src/config/sql /app/invidious/config/sql
# Seed config. Upstream renames config.example.yml to config.yml. start.sh copies it into /config.
COPY --from=build /src/config/config.example.yml /defaults/config.yml
COPY --from=build /src/LICENSE /usr/share/licenses/invidious/LICENSE

ENV HOME=/config

USER apps
COPY --chmod=0755 . /

EXPOSE 3000

VOLUME /config
