FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION

ENV HOME=/config

USER root
WORKDIR /app

# UNVERIFIED: dependency compatibility with Python 3.15 (requirements are lower bounds only).
RUN set -eux; \
  curl -fsSL -o /tmp/pps.tar.gz "https://github.com/rnagabhyrava/plex-playlist-sync/archive/refs/tags/v${VERSION}.tar.gz"; \
  mkdir -p /app/plex-playlist-sync; \
  tar xzf /tmp/pps.tar.gz -C /app/plex-playlist-sync --strip-components=1; \
  pip install --no-cache-dir -r /app/plex-playlist-sync/requirements.txt; \
  rm -rf /data; ln -s /config/data /data; \
  mkdir -p /usr/share/licenses/plex-playlist-sync; \
  cp /app/plex-playlist-sync/LICENSE.md /usr/share/licenses/plex-playlist-sync/LICENSE.md; \
  chown -R root:root /app/plex-playlist-sync; chmod -R a+rX,go-w /app/plex-playlist-sync; \
  rm -rf /tmp/* /root/.cache

USER apps
COPY --chmod=0755 . /

WORKDIR /config
VOLUME /config
