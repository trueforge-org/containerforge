# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION

ENV HOME=/tmp \
    npm_config_cache=/tmp/npm \
    NPM_CONFIG_UPDATE_NOTIFIER=false \
    NODE_ENV=production \
    ACTUAL_DATA_DIR=/config/data

USER root

# Install the sync server from npm (the GitHub release assets are the desktop app). The npm tarball is verified by npm.
RUN npm install --omit=dev --no-audit --no-fund \
        --prefix /app/actual-server \
        "@actual-app/sync-server@${VERSION}" \
    && node -e 'process.exit(Number(process.versions.node.split(".")[0]) >= 22 ? 0 : 1)' \
    && mkdir -p /usr/share/licenses/actualserver \
    && cp /app/actual-server/node_modules/@actual-app/sync-server/LICENSE /usr/share/licenses/actualserver/LICENSE \
    && chown -R root:root /app \
    && chmod -R a+rX /app \
    && rm -rf /tmp/npm /tmp/* /var/tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 5006

VOLUME /config

CMD ["/start.sh"]
