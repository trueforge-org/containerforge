
FROM ghcr.io/linuxserver/unrar:latest AS unrar

FROM ghcr.io/trueforge-org/ubuntu:24.4

# set version label
ARG VERSION

# set python to use utf-8 rather than ascii
ENV PYTHONIOENCODING="UTF-8"
ENV HOME=/config

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    build-base \
    cargo \
    git \
    libffi-dev \
    libxslt-dev \
    openssl-dev \
    python3-dev && \
  echo "**** install packages ****" && \
  apk add --no-cache \
    libmediainfo \
    libxslt \
    python3 && \
  echo "**** install sickchill ****" && \
  if [ -z ${VERSION+x} ]; then \
    VERSION=$(curl -sL  https://pypi.python.org/pypi/sickchill/json |jq -r '. | .info.version'); \
  fi && \
  python3 -m venv /lsiopy && \
  pip install -U --no-cache-dir \
    pip \
    setuptools \
    wheel && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/alpine-3.20/ \
    certifi \
    sickchill=="${VERSION}" && \
  echo "**** clean up ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /tmp/* \
    $HOME/.cache \
    $HOME/.cargo

# copy local files
COPY root/ /

# add unrar
COPY --from=unrar /usr/bin/unrar-alpine /usr/bin/unrar

# ports and volumes
EXPOSE 8081
VOLUME /config
