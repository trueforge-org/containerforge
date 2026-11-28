FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV HOME=/tmp

# UNVERIFIED: apt versions are not pinned yet. Pin to the 26.04 archive versions at build time.
RUN echo "*** Installing nginx and PHP ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    nginx \
    php-fpm \
    php-curl \
    php-xml \
    php-mbstring \
    php-sqlite3 && \
  rm -rf /var/lib/apt/lists/*

# No upstream checksum is published. The archive is pinned by tag over HTTPS.
RUN echo "*** Installing Organizr ${VERSION} ***" && \
  mkdir -p /app/organizr /tmp/php-sessions && \
  curl -fsSL -o /tmp/organizr.tar.gz \
    "https://github.com/causefx/Organizr/archive/refs/tags/${VERSION}.tar.gz" && \
  tar xzf /tmp/organizr.tar.gz -C /app/organizr --strip-components=1 && \
  chmod -R 755 /app && \
  echo "*** Cleaning Up ***" && \
  rm -f /tmp/organizr.tar.gz
# UNVERIFIED: writable Organizr paths (config, sqlite database, logs) are not yet traced.
# Point them at /config with build-time symlinks, not in start.sh, because /app is read-only at runtime.
# UNVERIFIED: Organizr license is not confirmed, so no license file is shipped yet.

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config
