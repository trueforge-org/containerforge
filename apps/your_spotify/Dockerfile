
FROM ghcr.io/trueforge-org/python-node:3.13.13@sha256:c636840e852b6d2be7a303bf85c88bfdbb4477932eeff7becabca1f50cf8cdf2 AS buildbase

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
  echo "*** install pnpm ***" && \
  npm install -g pnpm && \
  echo "*** install your_spotify ***" && \
  (curl -fL -o \
    /tmp/your_spotify.tar.gz \
    "https://github.com/Yooooomi/your_spotify/archive/refs/tags/${VERSION}.tar.gz" || curl -fL -o \
    /tmp/your_spotify.tar.gz \
    "https://github.com/Yooooomi/your_spotify/archive/refs/tags/v${VERSION}.tar.gz") && \
  mkdir -p /app/www && \
  tar xzf \
    /tmp/your_spotify.tar.gz -C \
    /app/www/ --strip-components=1 && \
  echo "*** install workspace dependencies ***" && \
  cd /app/www && \
  pnpm install --frozen-lockfile

FROM buildbase AS buildclient

RUN \
  echo "*** build your_spotify client ***" && \
  cd /app/www/apps/client && \
  pnpm build

FROM buildbase AS buildserver

RUN \
  echo "*** build your_spotify server ***" && \
  cd /app/www/apps/server && \
  pnpm build

FROM ghcr.io/trueforge-org/python-node:3.13.13@sha256:c636840e852b6d2be7a303bf85c88bfdbb4477932eeff7becabca1f50cf8cdf2

ARG VERSION
ARG TARGETARCH


ENV HOME=/app

COPY --from=buildclient /app/www/apps/client/build/ /app/www/apps/client/build/
COPY --from=buildserver /app/www/apps/server/build/ /app/www/apps/server/build/
COPY --from=buildbase /app/www/pnpm-lock.yaml /app/www/pnpm-lock.yaml
COPY --from=buildbase /app/www/package.json /app/www/package.json
COPY --from=buildbase /app/www/pnpm-workspace.yaml /app/www/pnpm-workspace.yaml
COPY --from=buildbase /app/www/apps/dev/package.json /app/www/apps/dev/package.json
COPY --from=buildbase /app/www/apps/server/package.json /app/www/apps/server/package.json
USER root
RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates && \
  echo "**** install pnpm and serve ****" && \
  npm install -g pnpm serve && \
  echo "**** install production dependencies ****" && \
  cd /app/www && \
  pnpm install --production --frozen-lockfile && \
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
