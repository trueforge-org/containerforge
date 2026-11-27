FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

# set version label (commit SHA of vertex-app/vertex)
ARG VERSION
USER root

# environment settings
ENV HOME="/config" \
  TZ="Etc/UTC"

# UNVERIFIED: redis-server and build-essential package names and versions on this base; pin after checking the archive.
# UNVERIFIED: build-essential is needed only if npm ci compiles native modules; purged again in this RUN.
RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    redis-server && \
  echo "**** install vertex ${VERSION} ****" && \
  mkdir -p /app/vertex && \
  curl -fL -o /tmp/vertex.tar.gz \
    "https://github.com/vertex-app/vertex/archive/${VERSION}.tar.gz" && \
  tar xzf /tmp/vertex.tar.gz -C /app/vertex --strip-components=1 && \
  cd /app/vertex && \
  PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true npm_config_cache=/tmp/npm-cache \
    npm ci --omit=dev --no-audit --no-fund && \
  echo "**** point upstream data paths at /config ****" && \
  mv app/config app/config_backup && \
  ln -s /config/data app/data && \
  ln -s /config/db app/db && \
  ln -s /config/config app/config && \
  ln -s /config/logs logs && \
  ln -s /config/torrents torrents && \
  echo "**** license ****" && \
  install -D /app/vertex/LICENSE /usr/share/licenses/vertex/LICENSE && \
  echo "**** cleanup ****" && \
  apt-get purge -y build-essential && \
  apt-get autoremove -y && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* && \
  chown -R apps:apps /app/vertex && \
  chmod -R 755 /app/vertex

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 3000
VOLUME /config
WORKDIR /config
