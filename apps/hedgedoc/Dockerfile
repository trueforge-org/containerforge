FROM ghcr.io/trueforge-org/python-node:3.13.12@sha256:dc1c0357b31b14aa1661ad6a5f54fb666d27e586152efd9d85b514bdca995b50

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
