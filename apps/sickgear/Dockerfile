
FROM ghcr.io/trueforge-org/python:3.14.6@sha256:1470b61147b07e36671bd6765c908f0d582088e2cb946c8029836fe06d20c84c

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# set python to use utf-8 rather than ascii.
ENV PYTHONIOENCODING="UTF-8"

RUN \
  echo "**** install build packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    build-essential && \
  echo "**** install app ****" && \
  mkdir -p \
    /app/sickgear/ && \
  (curl -fL -o \
    /tmp/sickgear.tar.gz \
    "https://github.com/sickgear/sickgear/archive/refs/tags/${VERSION}.tar.gz" || curl -fL -o \
    /tmp/sickgear.tar.gz \
    "https://github.com/sickgear/sickgear/archive/refs/tags/v${VERSION}.tar.gz") && \
  tar xf \
    /tmp/sickgear.tar.gz -C \
    /app/sickgear/ --strip-components=1 && \
  cd /app/sickgear && \
  python3 -m venv /app/venv && \
  /app/venv/bin/pip install -U --no-cache-dir \
    pip \
    wheel && \
  /app/venv/bin/pip install --no-cache-dir -r requirements.txt && \
  /app/venv/bin/pip install --no-cache-dir -r recommended.txt && \
  echo "**** cleanup ****" && \
  apt-get autoremove -y && \
  rm -rf \
    /tmp/*

# copy local files
USER apps
COPY --chmod=0755 . /





# ports and volumes
EXPOSE 8081

VOLUME /config

WORKDIR /config
