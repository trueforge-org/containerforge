
FROM ghcr.io/trueforge-org/python:3.14.6@sha256:dc837e172315d2788cac52caaa312815a494090d6630a619d844a1146539d75b

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
