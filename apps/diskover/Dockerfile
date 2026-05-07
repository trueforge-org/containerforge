
FROM ghcr.io/trueforge-org/python-node:3.14.4@sha256:dc445cf37c8cd8b0ce597153c195d8366ca78b07b4754fc7618e4fe086c21436

# set version label
ARG VERSION
ARG TARGETARCH
USER root
ARG DISKOVER_RELEASE

# environment settings
ENV DISKOVERDIR=/config/diskover.conf.d/diskover/
ENV DATABASE=/config/diskoverdb.sqlite3
ENV ES_HOST=elasticsearch

RUN \
  echo "**** install build packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    cargo \
    python3-dev && \
  echo "**** install runtime packages ****" && \
  apt-get install -y --no-install-recommends \
    ncurses-bin \
    php-cli \
    php-sqlite3 \
    php-fpm \
    python3-pip \
    python3 \
    python3-venv && \
  echo "**** configure php-fpm to pass env vars ****" && \
  for f in /etc/php/*/fpm/pool.d/www.conf; do \
    [ -f "$f" ] || continue; \
    sed -E -i 's/^;?clear_env ?=.*$/clear_env = no/g' "$f"; \
    grep -qxF 'clear_env = no' "$f" || echo 'clear_env = no' >> "$f"; \
    fpmconf="$(dirname "$(dirname "$f")")/php-fpm.conf"; \
    [ -f "$fpmconf" ] && echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> "$fpmconf"; \
  done && \
  echo "**** install diskover ****" && \
  if [ -z ${DISKOVER_RELEASE+x} ]; then \
    DISKOVER_RELEASE=$(curl -sX GET "https://api.github.com/repos/diskoverdata/diskover-community/releases" \
    | jq -r '.[0] | .tag_name' || true); \
    if [ -z "${DISKOVER_RELEASE}" ] || [ "${DISKOVER_RELEASE}" = "null" ]; then DISKOVER_RELEASE="${VERSION}"; fi; \
  fi && \
  curl -fL -o \
    /tmp/diskover.tar.gz \
    "https://github.com/diskoverdata/diskover-community/archive/refs/tags/${DISKOVER_RELEASE}.tar.gz" || curl -fL -o \
    /tmp/diskover.tar.gz \
    "https://github.com/diskoverdata/diskover-community/archive/refs/tags/v${DISKOVER_RELEASE}.tar.gz" && \
  tar xf \
    /tmp/diskover.tar.gz -C \
    /app/ --strip-components=1 && \
  cd /app/diskover && \
  python3 -m venv /app/venv && \
  /app/venv/bin/pip install -U --no-cache-dir \
    pip \
    setuptools \
    wheel && \
  /app/venv/bin/pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/alpine-3.20/ \
    -r requirements.txt && \
  echo "**** cleanup ****" && \
  apt-get purge -y --auto-remove \
    build-essential \
    cargo \
    python3-dev && \
  rm -rf \
    /tmp/* \
    $HOME/.cache \
    $HOME/.cargo && \
  rm -rf /var/lib/apt/lists/*

# add local files
USER apps
COPY --chmod=0755 . /


# ports and volumes
EXPOSE 80 443
VOLUME /config

WORKDIR /config
