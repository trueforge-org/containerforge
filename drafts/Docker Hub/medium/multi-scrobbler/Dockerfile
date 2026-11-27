# UNVERIFIED: the python-node base must provide Node >=24.14.0 (upstream engine). Check before build.
# UNVERIFIED: upstream paths below follow the Dockerfile at d164f568; re-check at tag ${VERSION}.

FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS build

ARG VERSION
USER root

ENV npm_config_cache=/tmp/npm \
    CI=true

RUN \
  echo "**** download source ****" && \
  mkdir -p /tmp/src && \
  curl -fL -o /tmp/multi-scrobbler.tar.gz \
    "https://github.com/FoxxMD/multi-scrobbler/archive/refs/tags/${VERSION}.tar.gz" && \
  tar xzf /tmp/multi-scrobbler.tar.gz -C /tmp/src --strip-components=1 && \
  echo "**** install and build ****" && \
  cd /tmp/src && \
  npm run install:parallel && \
  NODE_ENV=production npm run build:parallel && \
  echo "**** install production dependencies ****" && \
  npm ci --omit=dev && \
  npm cache clean --force

FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ENV CONFIG_DIR=/config \
    LOGS_DIR=/config/logs \
    DATA_DIR=/config \
    NODE_ENV=production \
    IS_DOCKER=true \
    COLORED_STD=true \
    PORT=9078 \
    TZ=Etc/UTC \
    APP_VERSION=${VERSION}

RUN \
  echo "**** create writable config directory ****" && \
  mkdir -p /config && \
  chown apps:apps /config

# runtime files copied from the build stage, owned by root and read-only for apps
COPY --from=build /tmp/src/package.json /app/package.json
COPY --from=build /tmp/src/index.html /app/index.html
COPY --from=build /tmp/src/src/backend /app/src/backend
COPY --from=build /tmp/src/src/core /app/src/core
COPY --from=build /tmp/src/dist /app/dist
COPY --from=build /tmp/src/docsite/build /app/docsite/build
COPY --from=build /tmp/src/node_modules /app/node_modules
COPY --from=build /tmp/src/LICENSE /usr/share/licenses/multi-scrobbler/LICENSE

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
WORKDIR /app
EXPOSE 9078
VOLUME /config

CMD ["/start.sh"]
