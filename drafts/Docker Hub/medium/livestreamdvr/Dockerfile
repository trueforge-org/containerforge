# UNVERIFIED: the Pipfile python_version is not checked. If a dependency rejects 3.15, fall back to python-node:3.14.8 as apps/changedetection does.
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS build

ARG VERSION
ARG TARGETARCH
# No upstream checksum is published. Compute sha256 of the release zip once and pin it in docker-bake.hcl. Until then the build fails.
ARG LIVESTREAMDVR_SHA256
ARG TD_VERSION
USER root

ENV \
  HOME=/tmp \
  YARN_CACHE_FOLDER=/tmp/yarn \
  npm_config_cache=/tmp/npm \
  TMPDIR=/tmp

RUN echo "*** Installing build packages ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    unzip && \
  rm -rf /var/lib/apt/lists/*

# UNVERIFIED: the zip layout (built or source). The paths below assume a /tmp/src tree with the Pipfile and server sources.
RUN echo "*** Downloading LiveStreamDVR ${VERSION} ***" && \
  curl -fsSL -o \
    /tmp/ldvr.zip \
    "https://github.com/MrBrax/LiveStreamDVR/releases/download/${VERSION}/${VERSION}.zip" && \
  echo "${LIVESTREAMDVR_SHA256}  /tmp/ldvr.zip" | sha256sum -c - && \
  unzip -q /tmp/ldvr.zip -d /tmp/src && \
  rm /tmp/ldvr.zip

# Python dependencies go into the base /app/venv, at build time only.
RUN echo "*** Installing Python dependencies ***" && \
  /app/venv/bin/pip install --no-cache-dir pipenv && \
  cd /tmp/src && \
  /app/venv/bin/pipenv requirements --dev=false > /tmp/requirements.txt && \
  /app/venv/bin/pip install --no-cache-dir -r /tmp/requirements.txt

# TwitchDownloaderCLI, as docker/fetch-tdl.sh does it. No checksum is published in that script.
RUN echo "*** Installing TwitchDownloaderCLI ${TD_VERSION} ***" && \
  case "${TARGETARCH}" in \
    amd64) TD_ARCH=Linux-x64 ;; \
    arm64) TD_ARCH=LinuxArm64 ;; \
    *) echo "unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
  esac && \
  curl -fsSL -o \
    /tmp/tdl.zip \
    "https://github.com/lay295/TwitchDownloader/releases/download/${TD_VERSION}/TwitchDownloaderCLI-${TD_VERSION}-${TD_ARCH}.zip" && \
  unzip -q /tmp/tdl.zip -d /tmp/tdl && \
  install -m 0755 /tmp/tdl/TwitchDownloaderCLI /usr/local/bin/TwitchDownloaderCLI && \
  rm -rf /tmp/tdl /tmp/tdl.zip

# TODO: the ttv-lol Streamlink plugin (docker/fetch-ttv-lol.sh) is not added. It downloads an unpinned "latest" with no checksum.
# TODO: the Node/Yarn builds of server and client-vue are not written yet. Add them once the zip layout is confirmed.

FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

USER root

ENV \
  HOME=/config \
  TCD_BIN_DIR=/usr/local/bin \
  TCD_FFMPEG_PATH=/usr/bin/ffmpeg \
  TCD_MEDIAINFO_PATH=/usr/bin/mediainfo \
  TCD_BIN_PATH_PYTHON3=/app/venv/bin/python \
  TCD_NODE_PATH=/usr/local/bin/node \
  TCD_TWITCHDOWNLOADER_PATH=/usr/local/bin/TwitchDownloaderCLI \
  TCD_DOCKER=1 \
  TCD_WEBSOCKET_ENABLED=1 \
  TCD_SERVER_PORT=8080 \
  TCD_PYTHON_ENABLE_PIPENV=0 \
  TMPDIR=/tmp

RUN echo "*** Installing runtime packages ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ffmpeg \
    mediainfo && \
  rm -rf /var/lib/apt/lists/* /tmp/*

COPY --from=build /app/venv /app/venv
COPY --from=build /tmp/src/ /app/livestreamdvr/
COPY --from=build /usr/local/bin/TwitchDownloaderCLI /usr/local/bin/TwitchDownloaderCLI
# UNVERIFIED: the zip ships a LICENSE. If it does not, use the repo LICENSE (MIT).
COPY --from=build /tmp/src/LICENSE /usr/share/licenses/livestreamdvr/LICENSE

RUN echo "*** Redirecting data to /config ***" && \
  rm -rf /app/livestreamdvr/data && \
  ln -s /config/data /app/livestreamdvr/data && \
  echo "*** Setting permissions ***" && \
  chown -R root:root /app && chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

WORKDIR /app/livestreamdvr/server

EXPOSE 8080

VOLUME /config
