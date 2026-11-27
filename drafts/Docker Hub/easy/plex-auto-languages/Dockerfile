FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

# set version label
ARG VERSION
USER root

ENV CONTAINERIZED=True \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    HOME=/config

# No upstream checksum for the source archive (HTTPS only).
# UNVERIFIED: Python 3.15 wheels for every requirement; if one fails, fall back to the 3.14 base.
RUN \
  echo "**** install plex-auto-languages ****" && \
  mkdir -p /app/plex-auto-languages /usr/share/licenses/plex-auto-languages && \
  curl -fsSL -o /tmp/pal.tar.gz "https://github.com/RemiRigal/Plex-Auto-Languages/archive/refs/tags/v${VERSION}.tar.gz" && \
  tar xzf /tmp/pal.tar.gz -C /app/plex-auto-languages --strip-components=1 && \
  pip install --no-cache-dir -r /app/plex-auto-languages/requirements.txt && \
  cp /app/plex-auto-languages/LICENSE /usr/share/licenses/plex-auto-languages/ && \
  rm -rf /tmp/* && \
  chown -R root:root /app/plex-auto-languages && \
  chmod -R a+rX,go-w /app/plex-auto-languages

COPY --chmod=0755 . /

EXPOSE 9880
WORKDIR /config
VOLUME /config

USER apps
