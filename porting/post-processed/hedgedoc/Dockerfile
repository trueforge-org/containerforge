FROM ghcr.io/trueforge-org/node:rolling@sha256:70adf71e6e9d204219ace16d177a96c7b06cc3d881c413eaaa312ed27d13479a

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# environment settings
ENV NODE_ENV=production \
  PUPPETEER_SKIP_DOWNLOAD=true \
  YARN_CACHE_FOLDER=/tmp/.yarn

RUN \
    echo "**** install build packages ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        fonts-noto \
        icu-data-full && \
    apt-get install -y --no-install-recommends --no-install-suggests \
        build-essential \
        libssl-dev \
        python3-dev \
        libsqlite3-dev && \
  echo "**** install hedgedoc ****" && \
  curl -o \
    /tmp/hedgedoc.tar.gz -L \
    "https://github.com/hedgedoc/hedgedoc/releases/download/${VERSION}/hedgedoc-${VERSION}.tar.gz" && \
  mkdir -p \
    /app/hedgedoc && \
  tar xf /tmp/hedgedoc.tar.gz -C \
    /app/hedgedoc --strip-components=1 && \
  cd /app/hedgedoc && \
  yarn install --immutable && \
  yarn run build && \
  yarn workspaces focus --production && \
  echo "**** cleanup ****" && \
  yarn cache clean && \
  apt-get autoremove -y && \
  rm -rf \
    $HOME/.npm \
    $HOME/.yarn \
    /tmp/*

# add local files
USER apps
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 3000
VOLUME /config

WORKDIR /config
