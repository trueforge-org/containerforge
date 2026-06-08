
FROM ghcr.io/trueforge-org/python:3.14.5@sha256:b87e7b85aa5b5451e8b38f0f2b67e8045cdec9ee76f8eeab4227fe8dbcb2eefa

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
    sickchill=="${VERSION}" && \
  /app/venv/bin/pip install -U --no-cache-dir 'stevedore<5' && \
  /app/venv/bin/pip install -U --no-cache-dir 'setuptools<81' && \
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
