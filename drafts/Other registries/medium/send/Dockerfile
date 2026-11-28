
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# caches and tool config go to /tmp, never /config or /app
ENV npm_config_cache=/tmp/npm-cache \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    XDG_CONFIG_HOME=/tmp/config

# UNVERIFIED: VERSION must be a pinned commit SHA on gitlab.com/timvisee/send, not a branch name.
# UNVERIFIED: the archive URL form is not fetched, and no checksum is published, so verify it when pinned.
# UNVERIFIED: the Node version in the python-node base must be compatible with the upstream build (Node 26 in upstream).
RUN \
  echo "**** fetch send ${VERSION} ****" && \
  mkdir -p /app/send && \
  curl -fL -o /tmp/send.tar.gz \
    "https://gitlab.com/timvisee/send/-/archive/${VERSION}/send-${VERSION}.tar.gz" && \
  tar xzf /tmp/send.tar.gz -C /app/send --strip-components=1 && \
  echo "**** build send ****" && \
  cd /app/send && \
  npm ci && \
  npm run build && \
  npm prune --omit=dev && \
  ln -fs dist/version.json /app/send/version.json && \
  install -Dm0644 /app/send/LICENSE /usr/share/licenses/send/LICENSE && \
  npm cache clean --force && \
  rm -rf \
    /tmp/* \
    $HOME/.cache

# add local files
USER apps
COPY --chmod=0755 . /

ENV PORT=1443 \
    NODE_ENV=production

EXPOSE 1443
VOLUME /config
WORKDIR /app/send
