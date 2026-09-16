FROM ghcr.io/trueforge-org/python-node:3.14.7@sha256:bcb745058d68c9c4fffa62a99351a81fe00516c29efdedc6e70acbe297e4cd06

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
        fonts-noto && \
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
COPY --chmod=0755 . /


# ports and volumes
EXPOSE 3000
VOLUME /config

WORKDIR /config
