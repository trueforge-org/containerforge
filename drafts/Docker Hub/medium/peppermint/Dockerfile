# UNVERIFIED: base is python-node per the draft; the porter table maps Node to ubuntu. Reviewer decides.
# UNVERIFIED: runtime env vars, listen addresses and cache paths are not yet read from upstream source.

FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS build

ARG VERSION
USER root

ENV NPM_CONFIG_CACHE=/tmp/npm \
    YARN_CACHE_FOLDER=/tmp/yarn \
    NEXT_TELEMETRY_DISABLED=1

RUN \
  echo "**** install build packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    python3 && \
  echo "**** download source ****" && \
  mkdir -p /app/peppermint && \
  curl -fL -o /tmp/peppermint.tar.gz \
    "https://github.com/Peppermint-Lab/peppermint/archive/${VERSION}.tar.gz" && \
  tar xzf /tmp/peppermint.tar.gz -C /app/peppermint --strip-components=1 && \
  echo "**** build api ****" && \
  cd /app/peppermint/apps/api && \
  npm install && \
  npx prisma generate && \
  npm run build && \
  echo "**** build client ****" && \
  cd /app/peppermint/apps/client && \
  yarn install --ignore-scripts && \
  yarn build && \
  echo "**** cleanup ****" && \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    build-essential && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/*

FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ENV NPM_CONFIG_CACHE=/tmp/npm \
    PM2_HOME=/tmp/.pm2 \
    NEXT_TELEMETRY_DISABLED=1 \
    TZ=Etc/UTC

RUN \
  echo "**** install pm2 ****" && \
  npm install -g pm2 && \
  npm cache clean --force && \
  rm -rf /tmp/*

# application tree from the build stage, read-only for apps
COPY --from=build /app/peppermint /app/peppermint
# UNVERIFIED: LICENSE file name in the upstream repo
COPY --from=build /app/peppermint/LICENSE /usr/share/licenses/peppermint/LICENSE

# add local files
USER apps
COPY --chmod=0755 . /

# ports
WORKDIR /app/peppermint
EXPOSE 3000 5003

CMD ["/start.sh"]
