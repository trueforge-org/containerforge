
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
# Upstream publishes no checksum. This value was computed locally from Kitana.zip (plan section 1). Bump it with VERSION.
ARG KITANA_SHA256=9cfb39683df31dca1d3d1718f898177f6000c342986ac2d9c73adfd56d086325
USER root

# UNVERIFIED: Python 3.15 compatibility. The pins in requirements.txt do not build here, so the pins are relaxed below.
# distutils was removed in Python 3.12, so the two import lines are replaced.
RUN set -eux && \
  echo "*** Installing Kitana ${VERSION} ***" && \
  curl -fsSL -o /tmp/Kitana.zip \
    "https://github.com/pannal/Kitana/releases/download/${VERSION}/Kitana.zip" && \
  echo "${KITANA_SHA256}  /tmp/Kitana.zip" | sha256sum -c - && \
  mkdir -p /tmp/kitana-src && \
  unzip -q /tmp/Kitana.zip -d /tmp/kitana-src && \
  mv /tmp/kitana-src/Kitana /app/kitana && \
  sed -E 's/[<>=!~].*$//' /app/kitana/requirements.txt \
    | grep -viE '^(ndg-httpsclient|cffi|cryptography)$' > /tmp/requirements.txt && \
  echo packaging >> /tmp/requirements.txt && \
  /app/venv/bin/pip install --no-cache-dir -r /tmp/requirements.txt && \
  sed -i 's/^from distutils.util import strtobool$/strtobool = lambda v: str(v).strip().lower() in ("y", "yes", "t", "true", "on", "1")/' /app/kitana/kitana.py && \
  sed -i 's/^from distutils.version import LooseVersion$/from packaging.version import Version as LooseVersion/' /app/kitana/util/update.py && \
  cd /app/kitana && \
  /app/venv/bin/python -c "import cherrypy, sass, jinja2, furl, github, requests, xmltodict, packaging; import util.update" && \
  mkdir -p /usr/share/licenses/kitana && \
  cp /app/kitana/LICENSE /usr/share/licenses/kitana/LICENSE && \
  chown -R apps:apps /app/kitana && \
  chmod -R 755 /app/kitana && \
  rm -f /tmp/Kitana.zip /tmp/requirements.txt && \
  rm -rf /tmp/kitana-src

USER apps
COPY --chmod=0755 . /

EXPOSE 31337

VOLUME /config

WORKDIR /config
