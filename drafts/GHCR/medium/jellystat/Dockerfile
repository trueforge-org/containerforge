FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS build

# build variables
ARG VERSION
# UNVERIFIED: sha256 of the 1.1.12 source tarball is not recorded yet. Record it here and verify the download.
USER root
ENV NPM_CONFIG_CACHE=/tmp/npm-cache

RUN \
  echo "**** fetch source code ****" && \
  mkdir -p /tmp/src && \
  curl -fL -o /tmp/jellystat-src.tar.gz \
    "https://github.com/CyferShepard/Jellystat/archive/refs/tags/${VERSION}.tar.gz" && \
  tar xzf /tmp/jellystat-src.tar.gz -C /tmp/src --strip-components=1

RUN \
  echo "**** build jellystat ****" && \
  cd /tmp/src && \
  npm install && \
  npm run build && \
  npm cache clean --force && \
  rm -rf /tmp/jellystat-src.tar.gz

############## runtime stage ##############
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

USER root

ENV TZ=Etc/UTC

# add jellystat
COPY --from=build /tmp/src /app

RUN \
  echo "**** prepare backup path ****" && \
  mkdir -p /app/backend && \
  rm -rf /app/backend/backup-data && \
  ln -s /config/backup-data /app/backend/backup-data

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 3000

WORKDIR /config
VOLUME /config
