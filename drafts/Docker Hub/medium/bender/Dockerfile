FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

# set version label
ARG VERSION
USER root

# UNVERIFIED: upstream publishes no checksum for the tag tarball; integrity relies on package-lock.json and npm ci.
# UNVERIFIED: whether npm ci needs native build tools (none added yet).
# UNVERIFIED: whether nuxt start needs --openssl-legacy-provider at runtime (only the build sets it here).
RUN \
  echo "**** install bender ****" && \
  mkdir -p /app && \
  curl -fsSL "https://github.com/jez500/bender/archive/refs/tags/${VERSION}.tar.gz" | tar xz -C /app --strip-components=1 && \
  cd /app && \
  npm_config_cache=/tmp/.npm npm ci && \
  NODE_OPTIONS=--openssl-legacy-provider npm run build && \
  npm prune --omit=dev && \
  echo "**** move default assets aside, persistent static goes to /config ****" && \
  mv /app/static /app/static-default && \
  ln -s /config/static /app/static && \
  echo "**** license ****" && \
  mkdir -p /usr/share/licenses/bender && \
  cp /app/LICENSE /usr/share/licenses/bender/ && \
  echo "**** cleanup ****" && \
  chown -R apps:apps /app && \
  rm -rf /tmp/*

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 8080
VOLUME /config
WORKDIR /app
