
# UNVERIFIED: the Node major in the python-node base; check `node --version` in the build
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS build

ARG VERSION
USER root

ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0 \
    YARN_CACHE_FOLDER=/tmp/yarn

RUN \
  echo "**** download source ****" && \
  mkdir -p /tmp/src && \
  curl -fL -o /tmp/wifi-card.tar.gz \
    "https://github.com/bndw/wifi-card/archive/${VERSION}.tar.gz" && \
  tar xzf /tmp/wifi-card.tar.gz -C /tmp/src --strip-components=1 && \
  echo "**** build frontend ****" && \
  cd /tmp/src && \
  corepack enable && \
  yarn install --immutable && \
  yarn prettier --check ./src && \
  yarn build && \
  echo "**** cleanup ****" && \
  yarn cache clean || true && \
  rm -rf \
    /tmp/wifi-card.tar.gz

FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:3a862278083a33d9ff969e987ee3a6ab24d2b928c35df07b2e69fa6f5d4e6cc1

# set version label
ARG VERSION
USER root

# static build output, read-only for apps
COPY --from=build /tmp/src/dist/ /usr/share/nginx/html/
COPY --from=build /tmp/src/LICENSE /usr/share/licenses/wifi-card/LICENSE

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
WORKDIR /usr/share/nginx/html
EXPOSE 8080
VOLUME /config
