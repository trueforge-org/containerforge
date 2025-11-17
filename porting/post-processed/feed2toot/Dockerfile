
FROM ghcr.io/trueforge-org/ubuntu:24.4

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# environment settings
ENV PYTHONIOENCODING=utf-8 \
    PYTHONUNBUFFERED=1

RUN \
  echo "**** install packages ****" && \
  apk add  -U --update --no-cache \
    python3 && \
  echo "**** install feed2toot ****" && \  
  python3 -m venv /lsiopy && \
  pip install -U --no-cache-dir \
    pip \
    wheel && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/alpine-3.19/ \
    feed2toot=="${VERSION}" && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    $HOME/.cache

# add local files
USER apps
COPY . /
COPY ./root /

# ports and volumes
VOLUME /config
