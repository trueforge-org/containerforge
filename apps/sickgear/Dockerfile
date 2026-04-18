
FROM ghcr.io/trueforge-org/python:3.14.4@sha256:ad4dde9774b3433fdfd16a118973b00ebf41d716d9f8e666cc34c8e30c168c56

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
