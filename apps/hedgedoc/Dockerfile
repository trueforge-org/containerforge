FROM ghcr.io/trueforge-org/python-node:3.14.8@sha256:feb6e44439ea272f47b46a1511960f58af5df8056811c83973e2edec9b18afca

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
