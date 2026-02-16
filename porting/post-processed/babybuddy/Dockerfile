
FROM ghcr.io/trueforge-org/python:3.13.12

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ENV S6_STAGE2_HOOK="/init-hook"

RUN \
  echo "**** install build packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    libjpeg-dev \
    libffi-dev \
    libxml2-dev \
    libxslt1-dev \
    libmariadb-dev \
    zlib1g-dev && \
  echo "**** install runtime packages ****" && \
  apt-get install -y --no-install-recommends \
    libjpeg-turbo8 \
    libffi8 \
    libpq5 \
    libxml2 \
    libxslt1.1 \
    libmariadb3 && \
  echo "**** install babybuddy ****" && \
  curl -o /tmp/babybuddy.tar.gz -L "https://github.com/babybuddy/babybuddy/archive/refs/tags/v${VERSION}.tar.gz" && \
  mkdir -p /app/www/public && \
  tar xf /tmp/babybuddy.tar.gz -C /app/www/public --strip-components=1 && \
  cd /app/www/public && \
  python3 -m venv /config/venv && \
  pip install -U --no-cache-dir pip wheel && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ -r requirements.txt && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ mysqlclient && \
  ln -s /config/data /app/www/public/data && \
  ln -s /config/media /app/www/public/media && \
  echo "**** cleanup ****" && \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    build-essential libjpeg-dev libffi-dev libxml2-dev libxslt1-dev libmariadb-dev python3-dev zlib1g-dev && \
  apt-get autoremove -y && \
  apt-get clean && \
  rm -rf /tmp/* $HOME/.cache $HOME/.cargo /var/lib/apt/lists/*

# copy local files
USER apps
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 8000
VOLUME /config

WORKDIR /config
