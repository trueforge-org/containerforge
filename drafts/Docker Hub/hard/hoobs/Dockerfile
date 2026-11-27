# UNVERIFIED throughout: no upstream Dockerfile exists. The data dir, web port, CLI subcommand and Node compatibility
# of @hoobs/hoobs 3.x must be checked by running hoobs/hoobs and the package before this build is trusted.
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config \
  npm_config_cache=/tmp/npm \
  npm_config_update_notifier=false

# Install without scripts so upstream's postinstall (hoobs upgrade) does not write outside /tmp and /config,
# then build node-pty (native) on purpose.
RUN echo "*** Installing HOOBS ${VERSION} ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends build-essential && \
  mkdir -p /app/hoobs && \
  npm install --prefix /app/hoobs --omit=dev --ignore-scripts "@hoobs/hoobs@${VERSION}" && \
  npm rebuild --prefix /app/hoobs node-pty && \
  apt-get purge -y build-essential && \
  apt-get autoremove -y && \
  rm -rf /var/lib/apt/lists/* && \
  ln -s /app/hoobs/node_modules/.bin/hoobs /usr/local/bin/hoobs

# UNVERIFIED: the package LICENSE path under node_modules.
RUN echo "*** Collecting licenses ***" && \
  mkdir -p /usr/share/licenses/hoobs && \
  cp /app/hoobs/node_modules/@hoobs/hoobs/LICENSE /usr/share/licenses/hoobs/LICENSE && \
  rm -rf /tmp/npm /root/.npm && \
  chown -R root:root /app && chmod -R a+rX /app

USER apps
COPY --chmod=0755 . /

# UNVERIFIED: web UI port (draft 8581; TrueCharts maps the main service to container port 80).
EXPOSE 8581

VOLUME /config
WORKDIR /config
