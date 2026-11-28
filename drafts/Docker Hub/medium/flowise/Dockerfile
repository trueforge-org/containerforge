
# Draft from plan.md section 4. Not built.
# BLOCKER (plan section 10): upstream installs Chromium with apk for Puppeteer. No working Chromium package on
# ubuntu 26.04 is confirmed (a snap wrapper does not run in a container). This draft installs no browser.
# Decide how to provide it before building.
# UNVERIFIED: the base ships Node 26.13.1 and upstream uses Node 24. Native module compatibility is not checked.

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ENV NPM_CONFIG_CACHE=/tmp/npm-cache \
    PUPPETEER_SKIP_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# UNVERIFIED: the npm package may not ship LICENSE.md. The install step fails in that case, so the gap shows.
RUN \
  echo "**** install flowise ****" && \
  mkdir -p /app/flowise && \
  npm install --prefix /app/flowise flowise@${VERSION} && \
  echo "**** install license ****" && \
  install -D /app/flowise/node_modules/flowise/LICENSE.md /usr/share/licenses/flowise/LICENSE.md && \
  echo "**** cleanup ****" && \
  npm cache clean --force && \
  chown -R root:root /app/flowise && \
  chmod -R 755 /app/flowise && \
  rm -rf /tmp/* /root/.cache /var/lib/apt/lists/*

# add local files (start.sh)
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 3000
VOLUME /config
