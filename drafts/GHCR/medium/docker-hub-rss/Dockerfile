FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS build

# build variables
ARG VERSION
USER root

ENV YARN_CACHE_FOLDER=/tmp/yarn \
    npm_config_cache=/tmp/npm

RUN \
  echo "**** install build packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    git && \
  npm install -g yarn@1 && \
  echo "**** fetch source code ****" && \
  mkdir -p /tmp/src && \
  curl -fL \
    "https://github.com/TheConnMan/docker-hub-rss/archive/${VERSION}.tar.gz" | tar xz -C \
    /tmp/src --strip-components=1 && \
  echo "**** install dependencies ****" && \
  cd /tmp/src && \
  yarn install --frozen-lockfile --production && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf \
    /tmp/yarn \
    /tmp/npm \
    /var/lib/apt/lists/*

############## runtime stage ##############
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

# set version label
ARG VERSION
USER root

COPY --from=build --chmod=0755 /tmp/src/ /app/docker-hub-rss/
# UNVERIFIED: the repo is assumed to ship a file named LICENSE (plan section 4, step 7)
COPY --from=build /tmp/src/LICENSE /usr/share/licenses/docker-hub-rss/LICENSE

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 3000
VOLUME /config

WORKDIR /app/docker-hub-rss
