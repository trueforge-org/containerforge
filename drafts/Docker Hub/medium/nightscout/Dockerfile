
# Draft from plan.md section 4. Not built.
# Base is python-node, which sibling budge builds on and which ships Node 24 (meets the >=20 engines
# requirement). The upstream node:22-alpine (musl) image is not copied.

FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ENV HOME=/config \
    NODE_ENV=production

# UNVERIFIED: the source tarball SHA-256 is not pinned yet. Fetch it once, record it in the PR, and add
# `echo "<sha256>  /tmp/ns.tar.gz" | sha256sum -c -` after the download.
RUN \
  echo "**** fetch source ****" && \
  mkdir -p /app/nightscout && \
  curl -fL -o /tmp/ns.tar.gz \
    "https://github.com/nightscout/cgm-remote-monitor/archive/refs/tags/v${VERSION}.tar.gz" && \
  tar xzf /tmp/ns.tar.gz -C /app/nightscout --strip-components=1 && \
  echo "**** install dependencies (postinstall runs webpack at build time) ****" && \
  cd /app/nightscout && \
  npm_config_cache=/tmp/npm npm ci --omit=optional --force && \
  npm prune --omit=dev --omit=optional && \
  echo "**** install license ****" && \
  install -D /app/nightscout/LICENSE /usr/share/licenses/nightscout/LICENSE && \
  echo "**** cleanup ****" && \
  chown -R root:root /app/nightscout && \
  chmod -R 755 /app/nightscout && \
  rm -rf /tmp/* /root/.cache

# add local files (start.sh)
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 1337
VOLUME /config

WORKDIR /app/nightscout
