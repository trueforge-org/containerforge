
# stay on python 3.14, matching apps/changedetection (upstream targets 3.14)
FROM ghcr.io/trueforge-org/python-node:3.14.8@sha256:feb6e44439ea272f47b46a1511960f58af5df8056811c83973e2edec9b18afca

ARG VERSION
ARG TARGETARCH
USER root

ENV PYTHONUNBUFFERED=1 \
    PIP_CACHE_DIR=/tmp/pip \
    npm_config_cache=/tmp/npm

RUN \
  echo "**** install runtime and build packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    ffmpeg \
    libffi-dev \
    libssl-dev \
    libvulkan1 \
    mesa-vulkan-drivers \
    nginx-extras && \
  echo "**** fetch fireshare ${VERSION} ****" && \
  mkdir -p /tmp/src && \
  curl -fL "https://github.com/fireshare-app/fireshare/archive/refs/tags/v${VERSION}.tar.gz" -o /tmp/fireshare.tar.gz && \
  tar xzf /tmp/fireshare.tar.gz -C /tmp/src --strip-components=1 && \
  echo "**** build client ****" && \
  cd /tmp/src/app/client && \
  npm ci --silent && \
  npm run build && \
  mkdir -p /app && \
  cp -r build /app/build && \
  cp package.json /app/package.json && \
  cd /tmp && \
  echo "**** install server ****" && \
  cp -r /tmp/src/app/server /app/server && \
  cp -r /tmp/src/migrations /app/migrations && \
  /app/venv/bin/pip install -U --no-cache-dir pip setuptools wheel && \
  /app/venv/bin/pip install --no-cache-dir /app/server && \
  echo "**** install licenses ****" && \
  mkdir -p /usr/share/licenses/fireshare && \
  cp /tmp/src/LICENSE /usr/share/licenses/fireshare/ && \
  echo "**** cleanup ****" && \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    build-essential \
    libffi-dev \
    libssl-dev && \
  apt-get clean && \
  rm -rf \
    /root/.npm \
    /tmp/* \
    /var/lib/apt/lists/*

ENV HOME=/config \
    TMPDIR=/tmp \
    FLASK_APP=/app/server/fireshare:create_app() \
    ENVIRONMENT=production \
    DATA_DIRECTORY=/config/data \
    PROCESSED_DIRECTORY=/config/processed \
    VIDEO_DIRECTORY=/videos \
    IMAGE_DIRECTORY=/images \
    TEMPLATE_PATH=/app/server/fireshare/templates \
    TRANSCODE_GPU=false \
    FIRESHARE_LITE=true \
    FIRESHARE_PORT=8080

USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
