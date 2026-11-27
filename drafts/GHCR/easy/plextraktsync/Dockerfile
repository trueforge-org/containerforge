FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

# set version label
ARG VERSION
ARG VENDOR
USER root

ENV \
    PTS_IN_DOCKER=1 \
    PTS_CONFIG_DIR=/config \
    PTS_LOG_DIR=/config \
    PTS_CACHE_DIR=/tmp/plextraktsync \
    PYTHONUNBUFFERED=1 \
    HOME=/config

# Pure-Python wheel from PyPI, installed into the base /app/venv at build time only.
# UNVERIFIED: the wheel digest should be checked against the PyPI JSON before merge.
RUN \
  echo "**** install plextraktsync ****" && \
  PIP_CACHE_DIR=/tmp/pip-cache /app/venv/bin/pip install --no-cache-dir "plextraktsync==${VERSION}" && \
  /app/venv/bin/pip show plextraktsync | grep -qx "Version: ${VERSION}" && \
  echo "**** licence ****" && \
  lic="$(find /app/venv/lib -path '*plextraktsync-*.dist-info/*' -iname 'LICENSE*' | head -n 1)" && \
  test -n "${lic}" && \
  install -D -m 0644 "${lic}" /usr/share/licenses/plextraktsync/LICENSE && \
  echo "**** permissions and config dir ****" && \
  chown -R root:root /app && \
  chmod -R 755 /app && \
  install -d -o apps -g apps /config && \
  echo "**** cleanup ****" && \
  rm -rf \
    /root/.cache \
    /tmp/*

# copy local files
USER apps
COPY --chmod=0755 . /

# no ports: the sync only makes outbound calls to Plex and Trakt
VOLUME /config

WORKDIR /config

ENTRYPOINT ["/start.sh"]
