
FROM ghcr.io/trueforge-org/python:3.13.7

# set version label
ARG VERSION
ARG TARGETARCH
USER root

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
    openssl-dev && \
  echo "**** install packages ****" && \
  apk add --no-cache \
    libmediainfo \
    libxslt && \
  echo "**** install sickchill ****" && \
  python3 -m venv /config/venv && \
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
USER apps
COPY . /

# ports and volumes
EXPOSE 8081
VOLUME /config
