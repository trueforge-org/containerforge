
FROM ghcr.io/trueforge-org/python:3.13.7@sha256:8a2c1da075925eac6d7e3a405035b60a68e1f82cf61b7807a7e87d9ca4f8c999

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# environment settings
ENV PYTHONIOENCODING=utf-8 \
    PYTHONUNBUFFERED=1

RUN echo "**** install feed2toot ****" && \
  python3 -m venv /config/venv && \
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
