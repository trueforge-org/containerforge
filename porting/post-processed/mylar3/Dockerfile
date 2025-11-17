


FROM ghcr.io/trueforge-org/ubuntu:24.4

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install build dependencies ****" && \
  apk add --no-cache --virtual=build-dependencies \
    build-base \
    jpeg-dev \
    libffi-dev \
    libwebp-dev \
    python3-dev \
    zlib-dev && \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    jpeg \
    libwebp-tools \
    nodejs \
    python3 \
    zlib && \
  echo "**** install mylar3 ****" && \
  mkdir /app/mylar3 && \
  curl -o \
    /tmp/mylar3.tar.gz -L \
    "https://github.com/mylar3/mylar3/archive/v${VERSION}.tar.gz" && \
  tar xf /tmp/mylar3.tar.gz -C \
    /app/mylar3/ --strip-components=1 && \
  cd /app/mylar3 && \
  python3 -m venv /config/venv && \
  pip install -U --no-cache-dir \
    pip \
    wheel && \
  pip install --no-cache-dir --find-links https://wheel-index.linuxserver.io/alpine-3.19/ -r requirements.txt && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /root/.cache \
    /tmp/*

# add local files
USER apps
COPY . /



COPY --from=unrar /usr/bin/unrar-alpine /usr/bin/unrar

# ports and volumes
VOLUME /config
EXPOSE 8090
