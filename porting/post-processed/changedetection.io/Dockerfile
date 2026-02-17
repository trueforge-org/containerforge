
FROM ghcr.io/trueforge-org/python:3.13.12

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
    zlib1g-dev \
    file \
    libjpeg-turbo8 \
    libxslt1.1 \
    nodejs \
    poppler-utils && \
  echo "**** install changedetection.io ****" && \
  mkdir -p /app/changedetection && \
  if [ -z ${CHANGEDETECTON_RELEASE+x} ]; then \
    CHANGEDETECTON_RELEASE=$(curl -sX GET "https://api.github.com/repos/dgtlmoon/changedetection.io/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  (curl -fsL -o \
    /tmp/changedetection.tar.gz \
    "https://github.com/dgtlmoon/changedetection.io/archive/refs/tags/${CHANGEDETECTON_RELEASE}.tar.gz" || curl -fsL -o \
    /tmp/changedetection.tar.gz \
    "https://github.com/dgtlmoon/changedetection.io/archive/refs/tags/v${CHANGEDETECTON_RELEASE#v}.tar.gz") && \
  tar xf \
    /tmp/changedetection.tar.gz -C \
    /app/changedetection/ --strip-components=1 && \
  rm /tmp/changedetection.tar.gz && \
  python3 -m venv /config/venv && \
  /config/venv/bin/pip install -U --no-cache-dir \
    pip \
    setuptools \
    wheel && \
  /config/venv/bin/pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ -r /app/changedetection/requirements.txt && \
  PLAYWRIGHT_PY_RELEASE=$(curl -sX GET "https://api.github.com/repos/microsoft/playwright-python/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  if [ -n "${PLAYWRIGHT_PY_RELEASE}" ]; then git clone --depth 1 --branch "${PLAYWRIGHT_PY_RELEASE}" https://github.com/microsoft/playwright-python /tmp/playwright-python; else git clone --depth 1 https://github.com/microsoft/playwright-python /tmp/playwright-python; fi && \
  cd /tmp/playwright-python && \
  /config/venv/bin/pip install -U --no-cache-dir . && \
  rm -f /config/venv/lib/python3.12/site-packages/playwright/driver/node && \
  ln -s /usr/bin/node /config/venv/lib/python3.12/site-packages/playwright/driver/node && \
  # Force UTF-8 encoding for browser steps to prevent exception
  sed -i "s|xpath_element_js = importlib.resources.files(\"changedetectionio.content_fetchers.res\").joinpath('xpath_element_scraper.js').read_text()|xpath_element_js = importlib.resources.files(\"changedetectionio.content_fetchers.res\").joinpath('xpath_element_scraper.js').read_text(encoding='utf-8')|" /app/changedetection/changedetectionio/blueprint/browser_steps/browser_steps.py && \
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
