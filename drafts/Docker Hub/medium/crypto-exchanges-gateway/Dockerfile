FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION
USER root

# UNVERIFIED: upstream README says the build needs Node 14.x; the Node version in this base is not checked.
# UNVERIFIED: the git+https dependency (bittrex-signalr-client) and the native sqlite3 build are not tested.
ENV HOME=/tmp NPM_CONFIG_CACHE=/tmp/npm-cache

RUN echo "*** Fetching source and installing dependencies ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends build-essential git python3 sqlite3 && \
  mkdir -p /app/crypto-exchanges-gateway && \
  curl -fsSL "https://github.com/aloysius-pgast/crypto-exchanges-gateway/archive/refs/tags/${VERSION}.tar.gz" \
    | tar xz -C /app/crypto-exchanges-gateway --strip-components=1 && \
  cd /app/crypto-exchanges-gateway && \
  npm install && \
  (cd ui && npm install && npm run build && rm -rf node_modules) && \
  npm prune --omit=dev && \
  cp docker/config.docker.json config/config.json && \
  apt-get purge -y --auto-remove build-essential && \
  rm -rf /var/lib/apt/lists/* /tmp/*

# UNVERIFIED: the license file name in the tarball; ISC per package.json on master.
RUN install -D -m 0644 /app/crypto-exchanges-gateway/LICENSE \
    /usr/share/licenses/crypto-exchanges-gateway/LICENSE && \
  cd /app/crypto-exchanges-gateway && \
  rm -rf storage/db custom_config ssl && \
  mkdir -p storage && \
  ln -s /config/storage/db storage/db && \
  ln -s /config/custom_config custom_config && \
  ln -s /config/ssl ssl && \
  chown -R apps:apps /app/crypto-exchanges-gateway && \
  chmod -R 755 /app/crypto-exchanges-gateway

USER apps
COPY --chmod=0755 . /

ENV HOME=/config

EXPOSE 8000 8001

VOLUME /config

WORKDIR /config
