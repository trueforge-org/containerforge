
FROM ghcr.io/trueforge-org/python-node:3.13.12

ARG VERSION
ARG TARGETARCH
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
  /app/venv/bin/pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ -r /app/changedetection/requirements.txt && \
  PLAYWRIGHT_PY_RELEASE=$(curl -sX GET "https://api.github.com/repos/microsoft/playwright-python/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  if [ -n "${PLAYWRIGHT_PY_RELEASE}" ]; then git clone --depth 1 --branch "${PLAYWRIGHT_PY_RELEASE}" https://github.com/microsoft/playwright-python /tmp/playwright-python; else git clone --depth 1 https://github.com/microsoft/playwright-python /tmp/playwright-python; fi && \
  cd /tmp/playwright-python && \
  /app/venv/bin/pip install -U --no-cache-dir . && \
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
COPY . /


EXPOSE 5000

VOLUME /config

WORKDIR /config
