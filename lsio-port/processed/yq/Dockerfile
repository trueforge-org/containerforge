
FROM ghcr.io/linuxserver/baseimage-alpine:3.22

# set version label
ARG VERSION
ARG YQ_VERSION

RUN \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    python3 && \
  echo "**** install app ****" && \
  if [ -z ${YQ_VERSION+x} ]; then \
    YQ_VERSION=$(curl -sL  https://pypi.python.org/pypi/yq/json |jq -r '. | .info.version'); \
  fi && \
  python3 -m venv /lsiopy && \
  pip install -U --no-cache-dir \
    pip \
    wheel && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/alpine-3.22/ \
    yq=="${YQ_VERSION}"
