
FROM ghcr.io/trueforge-org/python:3.13.12@sha256:cac0b51ee72888e75bf2ff4ae1a46be0b5310663584fc54d621d0476e573f5b8

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ENV APPRISE_CONFIG_DIR=/config \
  APPRISE_ATTACH_DIR=/attachments \
  APPRISE_ATTACH_SIZE=0

RUN \
  echo "**** install build packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    cargo \
    build-essential \
    libffi-dev \
    libssl-dev && \
  mkdir -p /app && \
  curl -o /tmp/apprise-api.tar.gz -L "https://github.com/caronc/apprise-api/archive/v${VERSION}.tar.gz" && \
  tar xf /tmp/apprise-api.tar.gz -C /app/ --strip-components=1 && \
  echo "**** install pip packages ****" && \
  cd /app && \
  python3 -m venv /app/venv && \
  /app/venv/bin/pip install -U --no-cache-dir pip wheel && \
  /app/venv/bin/pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ -r requirements.txt && \
  /app/venv/bin/pip install -U --no-cache-dir uwsgi && \
  echo "**** cleanup ****" && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    cargo build-essential python3-dev libssl-dev libffi-dev && \
  apt-get autoremove -y && \
  apt-get clean && \
  rm -rf $HOME/.cache $HOME/.cargo /tmp/* /var/lib/apt/lists/*

# copy local files
USER apps
COPY container-test.yaml /container-test.yaml
COPY . /
COPY --chmod=755 healthcheck.sh /healthcheck.sh

EXPOSE 8000
HEALTHCHECK CMD ["/healthcheck.sh"]
