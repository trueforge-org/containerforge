FROM ghcr.io/trueforge-org/python:3.13.7@sha256:8a2c1da075925eac6d7e3a405035b60a68e1f82cf61b7807a7e87d9ca4f8c999

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    autoconf \
    automake \
    build-base \
    cargo \
    freetype-dev \
    jpeg-dev \
    lcms2-dev \
    libffi-dev \
    libpng-dev \
    libwebp-dev \
    libxml2-dev \
    libxslt-dev \
    linux-headers \
    openjpeg-dev \
    openssl-dev \
    tiff-dev \
    zlib-dev && \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    vnstat && \
  echo "**** install app ****" && \
  mkdir -p /app/htpcmanager && \
  curl -s -o \
    /tmp/htpc.tar.gz -L \
    "https://github.com/HTPC-Manager/HTPC-Manager/archive/${VERSION}.tar.gz" && \
  tar xf \
    /tmp/htpc.tar.gz -C \
    /app/htpcmanager --strip-components=1 && \
  echo "**** install pip packages ****" && \
  sed -i -e '/psutil\|pyopenssl\|pySMART/d' /app/htpcmanager/requirements.txt && \
  python3 -m venv /config/venv && \
  pip install -U --no-cache-dir \
    pip \
    wheel && \
  pip install --no-cache-dir --find-links https://wheel-index.linuxserver.io/alpine-3.20/ -r /app/htpcmanager/requirements.txt && \
  echo ${VERSION} > /app/htpcmanager/VERSION.txt && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    $HOME/.cache \
    /tmp/*

# add local files
USER apps
COPY . /


# ports and volumes
EXPOSE 8085
VOLUME /config
