# Draft from plan.md (wallos). Not built or tested. UNVERIFIED items are marked.
# Upstream is PHP 8.3 on Alpine. Ubuntu 26.04 ships PHP 8.5 and has no php8.3-fpm (plan section 10).

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS build

ARG VERSION
# Record the sha256 of the release source archive at build time. No upstream checksum is published.
ARG SOURCE_SHA256=""

USER root
RUN echo "*** Fetching Wallos source ***" && \
  curl -fL -o /tmp/wallos.tar.gz \
    "https://github.com/ellite/Wallos/archive/refs/tags/v${VERSION}.tar.gz" && \
  if [ -n "${SOURCE_SHA256}" ]; then \
    echo "${SOURCE_SHA256}  /tmp/wallos.tar.gz" | sha256sum -c -; \
  fi && \
  mkdir -p /tmp/src && \
  tar -xzf /tmp/wallos.tar.gz -C /tmp/src --strip-components=1 && \
  rm -f /tmp/wallos.tar.gz


FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

USER root
# UNVERIFIED: package names on 26.04 (php8.5-*). Upstream uses PHP 8.3.
RUN echo "*** Installing nginx and PHP ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    nginx \
    php8.5-fpm php8.5-cli php8.5-sqlite3 php8.5-curl php8.5-gd \
    php8.5-xml php8.5-mbstring php8.5-zip php8.5-intl && \
  rm -rf /var/lib/apt/lists/*

COPY --from=build /tmp/src /app/wallos

# Wire data paths to /config. /app stays read-only at runtime.
# Only the database file is linked, because db/ also holds upstream scripts.
# UNVERIFIED: the database file name and whether the app resolves these paths relative to its own dir.
RUN echo "*** Wiring Wallos data paths to /config ***" && \
  mkdir -p /app/wallos/db /app/wallos/images/uploads && \
  rm -rf /app/wallos/db/wallos.db /app/wallos/images/uploads/logos && \
  ln -s /config/db/wallos.db /app/wallos/db/wallos.db && \
  ln -s /config/uploads/logos /app/wallos/images/uploads/logos && \
  mkdir -p /usr/share/licenses/wallos && \
  cp /app/wallos/LICENSE /usr/share/licenses/wallos/LICENSE && \
  chmod -R a=rX /app/wallos

ENV HOME=/tmp

USER apps
COPY --chmod=0755 . /

# Non-root cannot bind port 80, so nginx listens on 8080 (plan section 9).
EXPOSE 8080
VOLUME /config
