FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS buildstage

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install npm package ****" && \
  mkdir -p /app/meshcentral && \
  cd /app/meshcentral && \
  npm install --omit=dev --no-audit --no-fund "meshcentral@${VERSION}" && \
  npm cache clean --force && \
  rm -rf /tmp/npm

############## runtime stage ##############
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ENV NODE_ENV=production \
    CONFIG_FILE=/config/meshcentral-data/config.json \
    PORT=8443 \
    REDIR_PORT=8080

# add meshcentral
COPY --from=buildstage /app/meshcentral /app/meshcentral

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    jq && \
  echo "**** point data folders at /config (read-only /app) ****" && \
  mkdir -p /usr/share/licenses/meshcentral && \
  cp /app/meshcentral/node_modules/meshcentral/LICENSE /usr/share/licenses/meshcentral/LICENSE && \
  ln -s /config/meshcentral-data /app/meshcentral/meshcentral-data && \
  ln -s /config/meshcentral-files /app/meshcentral/meshcentral-files && \
  ln -s /config/meshcentral-web /app/meshcentral/meshcentral-web && \
  ln -s /config/meshcentral-backups /app/meshcentral/meshcentral-backups && \
  mkdir -p /config && \
  chown -R apps:apps /config && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*
# UNVERIFIED: the package ships a LICENSE file at node_modules/meshcentral/LICENSE; confirm in the build.

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 8443 8080

VOLUME /config
WORKDIR /app/meshcentral
ENTRYPOINT ["/start.sh"]
