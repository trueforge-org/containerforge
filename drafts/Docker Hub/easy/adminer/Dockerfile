FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
USER root

# UNVERIFIED: php8.5-mbstring may not exist on this release; drop it if apt cannot find it (Adminer works without it).
RUN \
  echo "**** install php ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    php8.5-cli \
    php8.5-mysql \
    php8.5-pgsql \
    php8.5-sqlite3 \
    php8.5-mbstring && \
  rm -rf /var/lib/apt/lists/*

# upstream publishes no checksum for the release file; the @version check guards the download
RUN \
  echo "**** install adminer ****" && \
  V="${VERSION#v}" && \
  mkdir -p /app/www /usr/share/licenses/adminer && \
  curl -fsSL -o /app/www/index.php "https://github.com/vrana/adminer/releases/download/v${V}/adminer-${V}.php" && \
  grep -q "@version ${V}" /app/www/index.php && \
  curl -fsSL -o /usr/share/licenses/adminer/LICENSE "https://raw.githubusercontent.com/vrana/adminer/v${V}/LICENSE" && \
  chown -R root:root /app && \
  chmod -R a+rX /app

ENV MEMORY_LIMIT=1G \
    UPLOAD_LIMIT=128M \
    MAX_EXECUTION_TIME=600

COPY --chmod=0755 . /

EXPOSE 8080
WORKDIR /config
VOLUME /config

USER apps
