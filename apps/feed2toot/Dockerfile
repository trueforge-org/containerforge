
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# environment settings
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

# add local files
USER apps
COPY --chmod=0755 . /


# ports and volumes
VOLUME /config

WORKDIR /config
