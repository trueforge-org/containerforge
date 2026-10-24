
FROM ghcr.io/trueforge-org/python:3.15.1@sha256:fcc611b0d03ab808bdce505d2d2524c941ec5d2314ef3eb0b63c43d22bd6a2b2

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# set python to use utf-8 rather than ascii.
ENV PYTHONIOENCODING="UTF-8"
# skip SickGear's exact-patch Python version gate (rejects e.g. 3.15.1)
ENV PYT=1

RUN \
  echo "**** install build packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    build-essential && \
  echo "**** install app ****" && \
  mkdir -p \
    /app/sickgear/ && \
  curl -fL -o \
    /tmp/sickgear.tar.gz \
    "https://github.com/sickgear/sickgear/archive/refs/tags/release_${VERSION}.tar.gz" && \
  tar xf \
    /tmp/sickgear.tar.gz -C \
    /app/sickgear/ --strip-components=1 && \
  cd /app/sickgear && \
  python3 -m venv /app/venv && \
  /app/venv/bin/pip install -U --no-cache-dir \
    pip \
    wheel && \
  # PIP_PREFER_BINARY would otherwise pick the CT3 0.0.0 shim (old Cheetah3, imports cgi) when no wheel exists
  /app/venv/bin/pip install --no-cache-dir -r requirements.txt "CT3>=3.4" && \
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
