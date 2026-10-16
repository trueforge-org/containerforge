
FROM ghcr.io/trueforge-org/python:3.15.0@sha256:cc77b726944ed790a1b47a8dfc52868391e2558d09193e1524f5ca74e0ccad5d

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
