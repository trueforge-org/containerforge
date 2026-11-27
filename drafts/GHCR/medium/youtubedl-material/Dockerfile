FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config \
  XDG_CACHE_HOME=/tmp \
  npm_config_cache=/tmp/npm \
  NO_UPDATE_NOTIFIER=true \
  PATH="/app/venv/bin:${PATH}"

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  # UNVERIFIED: check which of these the python-node base already provides before keeping them.
  apt-get install -y --no-install-recommends \
    atomicparsley \
    ffmpeg \
    unzip && \
  echo "**** fetch youtubedl-material ****" && \
  curl -fL -o \
    /tmp/ytdl.zip \
    "https://github.com/Tzahi12345/YoutubeDL-Material/releases/download/v${VERSION}/youtubedl-material-v${VERSION}.zip" && \
  # TODO: the release publishes no checksum; compute the sha256 of this zip at first build and verify it here.
  mkdir -p \
    /tmp/ytdl \
    /app && \
  unzip -q \
    /tmp/ytdl.zip -d \
    /tmp/ytdl && \
  # UNVERIFIED: zip layout not inspected; this assumes the app root sits at the top of the archive.
  cp -a \
    /tmp/ytdl/. \
    /app/ && \
  echo "**** install python packages (yt-dlp, pycryptodomex) ****" && \
  python3 -m venv /app/venv && \
  /app/venv/bin/pip install -U --no-cache-dir \
    pip \
    wheel && \
  /app/venv/bin/pip install -U --no-cache-dir \
    yt-dlp \
    pycryptodomex && \
  echo "**** install node dependencies ****" && \
  # UNVERIFIED: skip if the release zip already ships node_modules and public/.
  cd /app && \
  npm install --omit=dev && \
  echo "**** link data paths into /config (targets are created in start.sh) ****" && \
  for d in appdata users subscriptions audio video; do \
    rm -rf /app/$d && \
    ln -s /config/$d /app/$d; \
  done && \
  echo "**** install license ****" && \
  # UNVERIFIED: license path inside the zip; upstream backend/package.json declares MIT.
  if [ -f /tmp/ytdl/LICENSE ]; then \
    install -D -m 0644 /tmp/ytdl/LICENSE /usr/share/licenses/youtubedl-material/LICENSE; \
  fi && \
  echo "**** cleanup ****" && \
  npm cache clean --force && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    $HOME/.cache \
    /var/lib/apt/lists/*

# copy local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 17442
VOLUME /config

WORKDIR /config
