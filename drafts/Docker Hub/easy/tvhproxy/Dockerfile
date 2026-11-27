FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
ARG TVHPROXY_COMMIT=08096e664aca5b59059de7f609bd9e0aaba95191
USER root

ENV \
  PYTHONUNBUFFERED=1 \
  PYTHONDONTWRITEBYTECODE=1 \
  HOME=/tmp

# Upstream is archived and publishes no releases, so the files are fetched from one pinned commit.
# UNVERIFIED: gevent/flask/requests are unpinned upstream. Wheels for cp315 are expected but not checked.
RUN set -eux; \
  echo "*** Installing tvhProxy ***"; \
  mkdir -p /app/tvhproxy/templates /usr/share/licenses/tvhproxy; \
  curl -fsSL -o /app/tvhproxy/tvhProxy.py \
    "https://raw.githubusercontent.com/jkaberg/tvhProxy/${TVHPROXY_COMMIT}/tvhProxy.py"; \
  curl -fsSL -o /app/tvhproxy/templates/device.xml \
    "https://raw.githubusercontent.com/jkaberg/tvhProxy/${TVHPROXY_COMMIT}/templates/device.xml"; \
  curl -fsSL -o /usr/share/licenses/tvhproxy/LICENSE \
    "https://raw.githubusercontent.com/jkaberg/tvhProxy/${TVHPROXY_COMMIT}/LICENSE"; \
  /app/venv/bin/pip install --no-cache-dir flask requests gevent; \
  chown -R root:root /app/tvhproxy; \
  chmod -R a+rX /app/tvhproxy; \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 5004
VOLUME /config
WORKDIR /app/tvhproxy
