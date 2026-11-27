FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ENV NODE_ENV=production \
  HOME=/tmp \
  NPM_CONFIG_CACHE=/tmp/.npm

# UNVERIFIED: the plan's Express `app.js` launch and engines.node 14 must be checked against the v3.39.1 package.json
# (the upstream README describes a Next.js app). Chromium is not installed, so PDF export is off.
RUN echo "**** install dillinger ****" && \
  mkdir -p /app/dillinger && \
  curl -fL "https://github.com/joemccann/dillinger/archive/refs/tags/v${VERSION}.tar.gz" | \
    tar xz -C /app/dillinger --strip-components=1 && \
  echo "**** stage default configs for seeding ****" && \
  mkdir -p /usr/share/dillinger-defaults && \
  mv /app/dillinger/configs /usr/share/dillinger-defaults/configs && \
  ln -s /config/configs /app/dillinger/configs && \
  cd /app/dillinger && \
  PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true npm install --omit=dev && \
  npm cache clean --force && \
  mkdir -p /usr/share/licenses/dillinger && \
  install -D /app/dillinger/LICENSE /usr/share/licenses/dillinger/LICENSE && \
  chown -R apps:apps /app/dillinger && \
  chmod -R 755 /app/dillinger && \
  rm -rf /tmp/* /tmp/.npm

USER apps
COPY --chmod=0755 . /

ENV PORT=8080 \
  BIND_ADDRESS=0.0.0.0

EXPOSE 8080
VOLUME /config
WORKDIR /app/dillinger
