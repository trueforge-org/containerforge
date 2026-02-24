
FROM ghcr.io/trueforge-org/python:3.13.12@sha256:ec0d5db35e9cb896aa56dba7cacc1a97dede19debe52c217ed044e7a32f27536

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
