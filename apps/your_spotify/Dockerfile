
FROM ghcr.io/trueforge-org/python-node:3.13.12 AS buildbase

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install buildstage packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    python3-dev && \
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
  cd /app/www/apps/client && \
  npm install && \
  npm run build && \
  npm cache clean --force

FROM buildbase AS buildserver

RUN \
  echo "*** install your_spotify server ***" && \
  cd /app/www/apps/server && \
  npm install && \
  npm run build && \
  npm cache clean --force

FROM ghcr.io/trueforge-org/python-node:3.13.12

ARG VERSION
ARG TARGETARCH


ENV HOME=/app

COPY --from=buildclient /app/www/apps/client/build/ /app/www/apps/client/build/
COPY --from=buildserver /app/www/apps/server/build/ /app/www/apps/server/build/
COPY --from=buildserver /app/www/apps/server/package.json /app/www/apps/server/package.json
COPY --from=buildserver /app/www/apps/server/package-lock.json /app/www/apps/server/package-lock.json
USER root
RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates && \
  echo "**** install your_spotify ****" && \
  cd /app/www/apps/server && \
  npm install --omit=dev && \
  npm cache clean --force && \
  npm install -g serve && \
  echo "**** cleanup ****" && \
  apt-get autoremove -y && \
  rm -rf \
    /tmp/* \
    $HOME/.cache \
    $HOME/.npm

USER apps
COPY --chmod=0755 . /


EXPOSE 80 443

WORKDIR /config
VOLUME /config
