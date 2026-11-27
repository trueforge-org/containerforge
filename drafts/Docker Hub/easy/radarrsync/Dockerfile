FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

# VERSION is the upstream commit SHA (the fork has no tags). SHA256 is the archive digest.
ARG VERSION
ARG SHA256
USER root

ENV \
  PYTHONUNBUFFERED=1 \
  PYTHONIOENCODING=utf-8

RUN echo "**** install radarrsync ****" && \
  mkdir -p /app/radarrsync && \
  curl -fsSL -o /tmp/radarrsync.tar.gz \
    "https://github.com/dairefinn/RadarrSync/archive/${VERSION}.tar.gz" && \
  echo "${SHA256}  /tmp/radarrsync.tar.gz" | sha256sum -c - && \
  tar xzf /tmp/radarrsync.tar.gz -C /app/radarrsync --strip-components=1 && \
  sed -i 's/==/>=/' /app/radarrsync/requirements.txt && \
  /app/venv/bin/pip install --no-cache-dir -r /app/radarrsync/requirements.txt && \
  /app/venv/bin/python -c 'import requests' && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

VOLUME /config

WORKDIR /config
