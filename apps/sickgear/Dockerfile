
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

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
