
FROM ghcr.io/trueforge-org/python-node:3.13.12

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
    php-sqlite3 \
    php-fpm \
    python3-pip \
    python3 \
    python3-venv && \
  echo "**** configure php-fpm to pass env vars ****" && \
  if [ -f /etc/php83/php-fpm.d/www.conf ]; then sed -E -i 's/^;?clear_env ?=.*$/clear_env = no/g' /etc/php83/php-fpm.d/www.conf && grep -qxF 'clear_env = no' /etc/php83/php-fpm.d/www.conf || echo 'clear_env = no' >> /etc/php83/php-fpm.d/www.conf && echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /etc/php83/php-fpm.conf; fi && \
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
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 80 443
VOLUME /config

WORKDIR /config
