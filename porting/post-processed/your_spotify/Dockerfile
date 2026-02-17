
FROM ghcr.io/trueforge-org/python:3.13.12 AS buildbase

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install buildstage packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    npm \
    python3-dev \
    yarnpkg && \
  echo "*** install your_spotify ***" && \
  (curl -fL -o \
    /tmp/your_spotify.tar.gz \
    "https://github.com/Yooooomi/your_spotify/archive/refs/tags/${VERSION}.tar.gz" || curl -fL -o \
    /tmp/your_spotify.tar.gz \
    "https://github.com/Yooooomi/your_spotify/archive/refs/tags/v${VERSION}.tar.gz") && \
  mkdir -p /app/www && \
  tar xzf \
    /tmp/your_spotify.tar.gz -C \
    /app/www/ --strip-components=1

FROM buildbase AS buildclient

RUN \
  echo "*** install your_spotify client ***" && \
  cd /app/www && \
  rm -rf /app/www/apps/server && \
  yarnpkg --frozen-lockfile && \
  cd /app/www/apps/client && \
  yarnpkg build && \
  rm -rf /app/www/node_modules && \
  yarnpkg cache clean

FROM buildbase AS buildserver

RUN \
  echo "*** install your_spotify server ***" && \
  cd /app/www && \
  rm -rf /app/www/apps/client && \
  yarnpkg --frozen-lockfile && \
  cd /app/www/apps/server && \
  yarnpkg build && \
  rm -rf /app/www/node_modules && \
  yarnpkg cache clean

FROM ghcr.io/trueforge-org/python:3.13.12

ARG VERSION
ARG TARGETARCH


ENV HOME=/app

COPY --from=buildclient /app/www/apps/client/build/ /app/www/apps/client/build/
COPY --from=buildbase /app/www/package.json /app/www/package.json
COPY --from=buildbase /app/www/yarn.lock /app/www/yarn.lock
COPY --from=buildserver /app/www/apps/server/lib/ /app/www/apps/server/lib/
COPY --from=buildserver /app/www/apps/server/package.json /app/www/apps/server/package.json
USER root
RUN \
  echo "**** install build packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    python3-dev && \
  echo "**** install runtime packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    nodejs \
    npm \
    yarnpkg && \
  echo "**** install your_spotify ****" && \
  cd /app/www/apps/server && \
  yarnpkg --production --frozen-lockfile && \
  yarnpkg cache clean && \
  npm install -g serve && \
  echo "**** cleanup ****" && \
  apt-get autoremove -y && \
  rm -rf \
    /tmp/* \
    $HOME/.cache \
    $HOME/.npm

USER apps
COPY . /
COPY ./root /

EXPOSE 80 443

WORKDIR /config
VOLUME /config
