
FROM ghcr.io/trueforge-org/python:3.13.12@sha256:43a10c572aef8f97ad3c8cb4e0eff77fbc9068de95e1abecad0c4c0a8a843dbf

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# environment settings
ENV PYTHONIOENCODING=utf-8 \
    PYTHONUNBUFFERED=1

RUN echo "**** install feed2toot ****" && \
  python3 -m venv /app/venv && \
  /app/venv/bin/pip install -U --no-cache-dir \
    pip \
    wheel && \
  /app/venv/bin/pip install -U --no-cache-dir \
    feed2toot=="${VERSION}" && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    $HOME/.cache

# add local files
USER apps
COPY --chmod=0755 . /


# ports and volumes
VOLUME /config

WORKDIR /config
