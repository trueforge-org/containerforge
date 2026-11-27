FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION
ARG TARGETARCH
USER root

# /app is read-only at runtime. Puppeteer's Chrome is installed into /app/puppeteer at build time.
# HOME, the npm cache and Chrome profiles go to /tmp.
ENV HOME=/tmp \
    NPM_CONFIG_CACHE=/tmp/.npm \
    PUPPETEER_CACHE_DIR=/app/puppeteer

# UNVERIFIED: the Chrome shared-library list is a candidate set for Ubuntu 26.04. Confirm with ldd on the
# downloaded chrome binary and drop any package the base already provides.
# mosquitto-clients and jq are tools, not the tagged software, so they are not pinned to VERSION.
RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ca-certificates \
    jq \
    mosquitto-clients \
    libnss3 \
    libatk1.0-0t64 \
    libatk-bridge2.0-0t64 \
    libcups2t64 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libasound2t64 \
    libpango-1.0-0 \
    libcairo2 \
    libx11-xcb1 \
    libxss1 \
    fonts-liberation

RUN \
  echo "**** install fast-cli ${VERSION} ****" && \
  mkdir -p /app/fastcom /usr/share/licenses/fastcom-mqtt /config && \
  cd /app/fastcom && \
  npm install --omit=dev --no-audit --no-fund "fast-cli@${VERSION}" && \
  cp node_modules/fast-cli/license /usr/share/licenses/fastcom-mqtt/LICENSE && \
  cp node_modules/puppeteer/LICENSE /usr/share/licenses/fastcom-mqtt/puppeteer-LICENSE && \
  echo "**** cleanup ****" && \
  npm cache clean --force && \
  chown -R apps:apps /app /config && \
  chmod -R 755 /app && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/*

USER apps
COPY --chmod=0755 . /

WORKDIR /app/fastcom

VOLUME /config
