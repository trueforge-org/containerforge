
FROM ghcr.io/trueforge-org/python-node:3.15.1@sha256:3ae479227e69d69b2ddb0f94bf12ef785f8f88d2bbde3032ca02f701b336064f

ARG VERSION
ARG TARGETARCH
# renovate: datasource=pypi depName=playwright
ARG PLAYWRIGHT_VERSION=1.64.1
USER root

ENV PYTHONUNBUFFERED=1

RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    cargo \
    libjpeg-dev \
    libffi-dev \
    libxslt1-dev \
    libssl-dev \
    zip \
    python3-venv \
    zlib1g-dev \
    file \
    libjpeg-turbo8 \
    libxslt1.1 \
    poppler-utils && \
  echo "**** install changedetection.io ****" && \
  mkdir -p /app/changedetection && \
  (curl -fsL -o \
    /tmp/changedetection.tar.gz \
    "https://github.com/dgtlmoon/changedetection.io/archive/refs/tags/${VERSION}.tar.gz" || curl -fsL -o \
    /tmp/changedetection.tar.gz \
    "https://github.com/dgtlmoon/changedetection.io/archive/refs/tags/v${VERSION#v}.tar.gz") && \
  tar xf \
    /tmp/changedetection.tar.gz -C \
    /app/changedetection/ --strip-components=1 && \
  rm /tmp/changedetection.tar.gz && \
  /app/venv/bin/pip install -U --no-cache-dir \
    pip \
    setuptools \
    wheel && \
  PYO3_USE_ABI3_FORWARD_COMPATIBILITY=1 /app/venv/bin/pip install -U --no-cache-dir -r /app/changedetection/requirements.txt && \
  /app/venv/bin/pip install -U --no-cache-dir "playwright==${PLAYWRIGHT_VERSION}" && \
  PLAYWRIGHT_NODE=$(find /app/venv/lib -path '*/site-packages/playwright/driver/node' | head -n1) && \
  if [ -n "${PLAYWRIGHT_NODE}" ]; then rm -f "${PLAYWRIGHT_NODE}" && ln -s /usr/bin/node "${PLAYWRIGHT_NODE}"; fi && \
  # Force UTF-8 encoding for browser steps to prevent exception
  if [ -f /app/changedetection/changedetectionio/blueprint/browser_steps/browser_steps.py ]; then sed -i "s|xpath_element_js = importlib.resources.files(\\\"changedetectionio.content_fetchers.res\\\").joinpath('xpath_element_scraper.js').read_text()|xpath_element_js = importlib.resources.files(\\\"changedetectionio.content_fetchers.res\\\").joinpath('xpath_element_scraper.js').read_text(encoding='utf-8')|" /app/changedetection/changedetectionio/blueprint/browser_steps/browser_steps.py; fi && \
  echo "**** cleanup ****" && \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    build-essential cargo libjpeg-dev libffi-dev libxslt1-dev libssl-dev zip zlib1g-dev && \
  apt-get autoremove -y && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    $HOME/.cache \
    $HOME/.npm \
    /var/lib/apt/lists/*

USER apps
COPY --chmod=0755 . /


EXPOSE 5000

VOLUME /config

WORKDIR /config
