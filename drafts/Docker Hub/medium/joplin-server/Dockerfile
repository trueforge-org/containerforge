FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS build

ARG VERSION
USER root

# Native build packages for node-canvas, from the upstream Dockerfile.server builder stage.
RUN echo "*** Installing build packages ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    python3 \
    libcairo2-dev \
    libpango1.0-dev \
    libjpeg-dev \
    libgif-dev \
    librsvg2-dev && \
  rm -rf /var/lib/apt/lists/*

RUN echo "*** Fetching Joplin Server ${VERSION} source ***" && \
  mkdir -p /tmp/joplin && \
  curl -fsSL "https://github.com/laurent22/joplin/archive/refs/tags/v${VERSION}.tar.gz" \
    | tar xz -C /tmp/joplin --strip-components=1 && \
  sed -i '/onenote-converter/d' /tmp/joplin/packages/lib/package.json && \
  sed -i 's/"postinstall": ".*"/"postinstall": ""/' /tmp/joplin/package.json /tmp/joplin/packages/*/package.json

# UNVERIFIED: the upstream TypeScript build step before pruning was not captured; copy it from Dockerfile.server.
# UNVERIFIED: a full monorepo install is large; upstream installs only the server workspaces.
RUN echo "*** Installing dependencies ***" && \
  cd /tmp/joplin && \
  corepack enable && \
  yarn config set cacheFolder /tmp/yarn-cache && \
  yarn install --inline-builds && \
  yarn workspaces focus --production --all

RUN echo "*** Staging runtime tree ***" && \
  mkdir -p /app/joplin && \
  cp -a /tmp/joplin/. /app/joplin/ && \
  install -D -m 0644 /tmp/joplin/LICENSE /usr/share/licenses/joplin-server/LICENSE && \
  rm -rf /tmp/joplin /tmp/yarn-cache

FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION
USER root

# Runtime libraries for node-canvas. UNVERIFIED: package names on this base.
RUN echo "*** Installing runtime libraries ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    libcairo2 \
    libpango-1.0-0 \
    libjpeg-turbo8 \
    libgif7 \
    librsvg2-2 && \
  rm -rf /var/lib/apt/lists/*

COPY --from=build --chown=apps:apps /app/joplin /app/joplin
COPY --from=build /usr/share/licenses/joplin-server /usr/share/licenses/joplin-server

ENV NODE_ENV=production

USER apps
COPY --chmod=0755 . /

EXPOSE 22300

VOLUME /config

WORKDIR /app/joplin/packages/server
