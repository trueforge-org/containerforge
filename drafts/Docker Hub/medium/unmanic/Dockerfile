FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
USER root

# UNVERIFIED: python base Ubuntu release and whether ffmpeg is in its apt index. Upstream uses Jellyfin ffmpeg (not used here).
ENV \
  HOME_DIR=/config \
  PYTHONUNBUFFERED=1 \
  PIP_CACHE_DIR=/tmp/pip-cache

RUN echo "*** Installing runtime tools ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ffmpeg \
    libimage-exiftool-perl \
    sqlite3 && \
  rm -rf /var/lib/apt/lists/*

# UNVERIFIED: the checksums below are the PyPI digests for 0.4.1. Renovate bumps must update VERSION and both sha256 lines together.
RUN echo "*** Installing Unmanic ${VERSION} ***" && \
  mkdir -p /tmp/unmanic-dist/wheel /tmp/unmanic-dist/sdist && \
  /app/venv/bin/pip download --no-deps --only-binary :all: --dest /tmp/unmanic-dist/wheel "unmanic==${VERSION}" && \
  /app/venv/bin/pip download --no-deps --no-binary :all: --dest /tmp/unmanic-dist/sdist "unmanic==${VERSION}" && \
  cd /tmp/unmanic-dist && \
  echo "4237de63f9896a68097128baf399ee903a9fc24bb6b489d0c573317261d12e53  wheel/unmanic-0.4.1-py3-none-any.whl" | sha256sum -c && \
  echo "4c55a38c639da1d112ff45e97529e0b21e8da8ac80078408a1680e73794b0e47  sdist/unmanic-0.4.1.tar.gz" | sha256sum -c && \
  /app/venv/bin/pip install --no-cache-dir wheel/unmanic-0.4.1-py3-none-any.whl && \
  mkdir -p /usr/share/licenses/unmanic && \
  tar xzf sdist/unmanic-0.4.1.tar.gz -C /tmp/unmanic-dist --wildcards '*/LICENSE' --strip-components=1 && \
  cp /tmp/unmanic-dist/LICENSE /usr/share/licenses/unmanic/LICENSE && \
  echo "*** Cleaning Up ***" && \
  rm -rf /tmp/unmanic-dist /tmp/pip-cache && \
  chown -R root:root /app && chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

EXPOSE 8888

VOLUME /config

WORKDIR /config
