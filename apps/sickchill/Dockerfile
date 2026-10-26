
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# set python to use utf-8 rather than ascii
ENV PYTHONIOENCODING="UTF-8"
ENV HOME=/config

RUN \
  echo "**** install build packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cargo \
    git \
    libffi-dev \
    libxslt-dev \
    libssl-dev && \
  echo "**** install packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    libmediainfo0v5 \
    libxslt1.1 && \
  echo "**** install sickchill ****" && \
  python3 -m venv /app/venv && \
  /app/venv/bin/pip install -U --no-cache-dir \
    pip \
    setuptools \
    wheel && \
  /app/venv/bin/pip install -U --no-cache-dir \
    certifi \
    "sickchill @ https://github.com/SickChill/SickChill/archive/refs/tags/${VERSION}.tar.gz" && \
  echo "**** clean up ****" && \
  apt-get autoremove -y && \
  rm -rf \
    /tmp/* \
    $HOME/.cache \
    $HOME/.cargo

# copy local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 8081
VOLUME /config

WORKDIR /config
