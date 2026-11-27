
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
ARG COMMIT
USER root

ENV \
  HOME=/config \
  PYTHONDONTWRITEBYTECODE=1

# No upstream releases or tags exist, so the source is pinned to a full commit SHA (COMMIT).
# UNVERIFIED: Python 3.15 wheels for Chameleon, zope.interface and MarkupSafe.
RUN set -eux; \
  echo "*** Installing webNUT ***"; \
  mkdir -p /app/webNUT /usr/share/licenses/webnut; \
  curl -fsSL -o /tmp/webnut.tar.gz "https://github.com/rshipp/webNUT/archive/${COMMIT}.tar.gz"; \
  tar xzf /tmp/webnut.tar.gz -C /app/webNUT --strip-components=1; \
  rm -f /tmp/webnut.tar.gz; \
  sed -i "s/    'nut2',/    'nut2-notl',/" /app/webNUT/setup.py; \
  grep -q "'nut2-notl'" /app/webNUT/setup.py; \
  /app/venv/bin/pip install --no-cache-dir -e /app/webNUT; \
  cp /app/webNUT/LICENSE /usr/share/licenses/webnut/LICENSE; \
  chown -R apps:apps /app; \
  chmod -R 755 /app; \
  rm -rf /tmp/* /root/.cache

# Replaces the upstream config.py with one that reads UPS_* from the environment at import time.
# Placed after the RUN above because the source tree does not exist until then.
COPY --chmod=0644 defaults/config.py /app/webNUT/webnut/config.py

USER apps
COPY --chmod=0755 . /

EXPOSE 6543

VOLUME /config
WORKDIR /config
