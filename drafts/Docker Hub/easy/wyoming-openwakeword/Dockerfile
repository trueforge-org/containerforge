# UNVERIFIED: cp315 wheels for numpy and the pyopen-wakeword dependencies on both arches.
# If any are missing, switch to ghcr.io/trueforge-org/python:3.14.8@sha256:f099b700b824b7760cb846418f84a2c14c2f04992320506ab3ca5b79d3ac1232
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
USER root

ENV \
  HOME=/config \
  PIP_NO_CACHE_DIR=1 \
  PYTHONDONTWRITEBYTECODE=1

# Install from the GitHub tag tarball, not PyPI (the PyPI package is stale).
# Upstream publishes no checksum, so integrity rests on the pinned tag over HTTPS.
RUN set -eux; \
  echo "*** Installing wyoming-openwakeword ***"; \
  mkdir -p /tmp/oww /usr/share/licenses/wyoming-openwakeword; \
  curl -fsSL -o /tmp/oww.tar.gz \
    "https://github.com/rhasspy/wyoming-openwakeword/archive/refs/tags/v${VERSION}.tar.gz"; \
  tar xzf /tmp/oww.tar.gz -C /tmp/oww --strip-components=1; \
  /app/venv/bin/pip install --no-cache-dir /tmp/oww; \
  cp /tmp/oww/LICENSE /usr/share/licenses/wyoming-openwakeword/LICENSE; \
  chown -R apps:apps /app; \
  chmod -R 755 /app; \
  rm -rf /tmp/* /root/.cache

USER apps
COPY --chmod=0755 . /

EXPOSE 10400
VOLUME /config
WORKDIR /config
