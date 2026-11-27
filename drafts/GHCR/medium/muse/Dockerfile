FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS buildstage

# build variables
ARG VERSION
ARG YT_DLP_VERSION
USER root

# UNVERIFIED: Node in python-node must be >= 22.12.0 (muse engines); check with node --version at build
RUN \
  echo "**** install build packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    python-is-python3

RUN \
  echo "**** fetch source code ****" && \
  npm install -g yarn@1.22.22 && \
  mkdir -p /tmp/src && \
  curl -fL -o /tmp/muse-src.tar.gz \
    "https://github.com/museofficial/muse/archive/refs/tags/${VERSION}.tar.gz" && \
  tar xf /tmp/muse-src.tar.gz -C /tmp/src --strip-components=1

RUN \
  echo "**** build muse ****" && \
  cd /tmp/src && \
  yarn install --frozen-lockfile --production && \
  mv node_modules /tmp/prod_node_modules && \
  yarn install --frozen-lockfile && \
  yarn prisma generate && \
  yarn build && \
  echo "**** assemble runtime tree ****" && \
  mkdir -p /tmp/out/muse /tmp/licenses/muse && \
  cp -r dist package.json prisma /tmp/out/muse/ && \
  cp -r /tmp/prod_node_modules /tmp/out/muse/node_modules && \
  cp -r node_modules/.prisma /tmp/out/muse/node_modules/ && \
  # UNVERIFIED: LICENSE file at the v2.12.0 tag
  install -D -m 0644 LICENSE /tmp/licenses/muse/LICENSE

############## runtime stage ##############
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

# set version label
ARG VERSION
ARG YT_DLP_VERSION
USER root

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ffmpeg \
    openssl \
    python3-venv \
    tini && \
  echo "**** install yt-dlp ****" && \
  python3 -m venv /opt/yt-dlp && \
  /opt/yt-dlp/bin/pip install --no-cache-dir "yt-dlp[default]${YT_DLP_VERSION:+==${YT_DLP_VERSION}}" && \
  ln -sf /opt/yt-dlp/bin/yt-dlp /usr/local/bin/yt-dlp && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    $HOME/.cache \
    /var/lib/apt/lists/*

COPY --from=buildstage /tmp/out/muse/ /app/muse/
COPY --from=buildstage /tmp/licenses/ /usr/share/licenses/

# UNVERIFIED: ENV_FILE is a file path upstream (default /config); moved to a file inside the /config volume
ENV NODE_ENV=production \
    DATA_DIR=/config \
    ENV_FILE=/config/muse.env \
    MUSE_BUNDLED_YT_DLP_PATH=/opt/yt-dlp/bin/yt-dlp \
    YT_DLP_AUTO_UPDATE=false \
    HOME=/tmp \
    npm_config_cache=/tmp/npm \
    YARN_CACHE_FOLDER=/tmp/yarn

# add local files
USER apps
COPY --chmod=0755 . /


# volumes
VOLUME /config

WORKDIR /app/muse
