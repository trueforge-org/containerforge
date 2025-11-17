FROM ghcr.io/trueforge-org/ubuntu:24.4

ARG VERSION
ARG TARGETARCH
USER root

USER apps
COPY . /
COPY ./root /

RUN \
  echo "**** install packages ****" && \
  apk add  -U --update --no-cache \
    python3 && \
  cd /app && \
  python3 -m venv /config/venv && \
  pip install -U --no-cache-dir \
    pip && \
  pip install -U --no-cache-dir -r /tmp/requirements.txt && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    $HOME/.cache

USER apps
COPY . /
COPY ./root /

EXPVERSIONE 8000
VOLUME /config
