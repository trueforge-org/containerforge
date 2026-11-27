
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

# set version label
ARG VERSION
# UNVERIFIED: Python 3.15 compatibility of legacy-cgi, gitpython and pyotp (fallback base: python:3.14.8)
# Pinned checksum of the PyPI sdist, update together with VERSION (not renovated)
ARG SHA256=1a73aa09eb1ee1ed7acdc4c55dc9147fedadf7a7a3947fd63e6ed832b082e44c
USER root

ENV \
  HOME=/config \
  PYTHONUNBUFFERED=1

RUN \
  echo "**** download hass-configurator ****" && \
  mkdir -p /tmp/hc /usr/share/licenses/hass-configurator && \
  curl -fsSL -o /tmp/hc/hc.tar.gz \
    "https://files.pythonhosted.org/packages/source/h/hass-configurator/hass_configurator-${VERSION}.tar.gz" && \
  echo "${SHA256}  /tmp/hc/hc.tar.gz" | sha256sum -c - && \
  tar xzf /tmp/hc/hc.tar.gz -C /tmp/hc --strip-components=1 && \
  cp /tmp/hc/LICENSE.txt /usr/share/licenses/hass-configurator/ && \
  echo "**** install pip packages ****" && \
  /app/venv/bin/pip install --no-cache-dir /tmp/hc/hc.tar.gz && \
  echo "**** cleanup ****" && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  install -d -o apps -g apps /hass-config && \
  rm -rf /tmp/hc /root/.cache

# copy local files
USER apps
COPY --chmod=0755 . /

EXPOSE 3218

VOLUME /config
VOLUME /hass-config

WORKDIR /config
