FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

# set version label
ARG VERSION
USER root

# apps/python-node was removed from this repo (apps/budge still pulls this image).
# UNVERIFIED: Node major in this image; the upstream image uses Node 24.
ENV NODE_ENV=production \
    npm_config_cache=/tmp/.npm

# No upstream checksum for the source archive (HTTPS only).
RUN \
  echo "**** install posterr ****" && \
  mkdir -p /app/posterr /usr/share/licenses/posterr && \
  curl -fsSL -o /tmp/posterr.tar.gz "https://github.com/petersem/posterr/archive/refs/tags/v${VERSION}.tar.gz" && \
  tar xzf /tmp/posterr.tar.gz -C /app/posterr --strip-components=1 && \
  grep -q "\"version\": \"${VERSION}\"" /app/posterr/package.json && \
  cd /app/posterr && \
  npm ci --omit=dev && \
  if [ -d public/custom ]; then mv public/custom /app/posterr-custom.default; else mkdir -p /app/posterr-custom.default; fi && \
  rm -rf config saved && \
  ln -s /config/config config && \
  ln -s /tmp/saved saved && \
  ln -s /config/custom public/custom && \
  cp LICENSE /usr/share/licenses/posterr/ && \
  npm cache clean --force && \
  rm -rf /tmp/* /root/.npm && \
  chown -R root:root /app/posterr && \
  chmod -R a+rX,go-w /app/posterr

COPY --chmod=0755 . /

EXPOSE 3000
WORKDIR /app/posterr
VOLUME /config

USER apps
