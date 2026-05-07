


FROM ghcr.io/trueforge-org/python:3.14.4@sha256:622c7c1053c59c31674e5c31b88b1a7cfa61b0f5fbabebb38dd9a4ab5e2f6ee1

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install build packages ****" && \
  apt-get update && \
  apt-get install -y \
    libjpeg-turbo8-dev \
    zlib1g-dev && \
  echo "**** install runtime packages ****" && \
  apt-get install -y \
    ghostscript \
    libjpeg-turbo8 \
    libmagic1 \
    python3-venv \
    zlib1g && \
  echo "**** install app ****" && \
  mkdir -p \
    /app/lazylibrarian && \
  echo "Installing from commit ${VERSION}" && \
  mkdir -p /defaults && \
  echo "${VERSION}" > /defaults/version.txt && \
  curl -o \
    /tmp/lazylibrarian.tar.gz -L \
    "https://gitlab.com/LazyLibrarian/LazyLibrarian/-/archive/{$VERSION}/LazyLibrarian-{$VERSION}.tar.gz" && \
  tar xf \
    /tmp/lazylibrarian.tar.gz -C \
    /app/lazylibrarian --strip-components=1 && \
  cd /app/lazylibrarian && \
  python3 -m venv /app/venv && \
  pip install -U --no-cache-dir \
    pip \
    wheel && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ . && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ Levenshtein && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  echo "**** cleanup ****" && \
  apt-get -y purge \
    libjpeg-turbo8-dev \
    zlib1g-dev && \
  apt-get -y autoremove && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
USER apps
COPY --chmod=0755 . /


# ports and volumes
EXPOSE 5299
VOLUME /config
