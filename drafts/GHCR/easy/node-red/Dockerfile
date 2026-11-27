FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION
USER root

# npm cache goes to /tmp, also for palette installs at runtime (never /config or /app).
ENV HOME=/config \
  NPM_CONFIG_CACHE=/tmp/npm-cache

RUN echo "*** Installing Node-RED ***" && \
  npm install --prefix /app --omit=dev --no-audit --no-fund "node-red@${VERSION}" && \
  echo "*** Installing license ***" && \
  mkdir -p /usr/share/licenses/node-red && \
  cp /app/node_modules/node-red/LICENSE /usr/share/licenses/node-red/LICENSE && \
  echo "*** Cleaning Up ***" && \
  npm cache clean --force && \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 1880

VOLUME /config

CMD ["/start.sh"]
