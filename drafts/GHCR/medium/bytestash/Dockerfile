FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS buildstage

# set version label
ARG VERSION
USER root

ENV NPM_CONFIG_CACHE=/tmp/npm

RUN \
  echo "**** install build packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    python3 && \
  echo "**** fetch source code ****" && \
  mkdir -p /tmp/src && \
  curl -fL -o /tmp/bytestash.tar.gz \
    "https://github.com/jordan-dalby/ByteStash/archive/refs/tags/${VERSION}.tar.gz" && \
  # sha256 of the tag tarball, taken from the draft plan; re-check at build time
  echo "a132760975163fcbb46be9c4f293aa77935cae937e61d0397d529cdc461d183c  /tmp/bytestash.tar.gz" | sha256sum -c - && \
  tar xzf /tmp/bytestash.tar.gz -C /tmp/src --strip-components=1 && \
  echo "**** build client ****" && \
  cd /tmp/src/client && \
  # UNVERIFIED: client/package-lock.json at this tag
  npm ci && \
  VITE_APP_VERSION="${VERSION}" npm run build && \
  echo "**** install server ****" && \
  mkdir -p /app/bytestash /app/client && \
  cp -r /tmp/src/server/src /tmp/src/server/docs /tmp/src/server/package.json /app/bytestash/ && \
  cp -r /tmp/src/client/build /app/client/build && \
  cd /app/bytestash && \
  # native modules (better-sqlite3, bcrypt) compile here; build tools stay in this stage
  npm install --omit=dev && \
  echo "**** license ****" && \
  install -D /tmp/src/LICENSE /usr/share/licenses/bytestash/LICENSE && \
  echo "**** cleanup ****" && \
  npm cache clean --force && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/*

FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# add bytestash server, client build and license
COPY --from=buildstage /app/bytestash /app/bytestash
COPY --from=buildstage /app/client /app/client
COPY --from=buildstage /usr/share/licenses/bytestash /usr/share/licenses/bytestash

# upstream resolves ../../../data/snippets from src/config, which is /app/data;
# point it at /config so the database and JWT secret persist and /app stays read-only
RUN \
  ln -s /config/data /app/data

ENV HOME=/config \
    NODE_ENV=production \
    NPM_CONFIG_CACHE=/tmp/npm

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 5000
VOLUME /config

WORKDIR /app/bytestash
