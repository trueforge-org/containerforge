
FROM ghcr.io/trueforge-org/python:3.13.12@sha256:32f90bc0c1f522ce2b2ffdef58e2a781e5fb71b9c7c90c0de92b516f493f7518

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
COPY --chmod=0755 . /

EXPOSE 8000
HEALTHCHECK CMD ["/healthcheck.sh"]
