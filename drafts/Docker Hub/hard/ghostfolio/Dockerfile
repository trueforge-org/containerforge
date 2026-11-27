# Build stage: Node with python3 and a compiler for native modules.
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS builder

ARG VERSION

ENV HOME=/tmp \
    NX_DAEMON=false \
    npm_config_cache=/tmp/npm

USER root

# hadolint ignore=DL3008,DL3015
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl g++ git make openssl && \
    rm -rf /var/lib/apt/lists/*

# Upstream publishes no checksum for the tag archive. The tag pins the content.
RUN curl -fsSL "https://github.com/ghostfolio/ghostfolio/archive/refs/tags/${VERSION}.tar.gz" -o /tmp/ghostfolio.tar.gz && \
    mkdir -p /src && \
    tar xzf /tmp/ghostfolio.tar.gz -C /src --strip-components=1 && \
    rm -f /tmp/ghostfolio.tar.gz

WORKDIR /src

# Mirrors the upstream build: production build, then the API dependencies and Prisma typings.
RUN npm ci && \
    npm run build:production && \
    cp /src/package.json /src/package-lock.json /src/dist/apps/api/ && \
    cp -a /src/.config /src/prisma /src/dist/apps/api/

WORKDIR /src/dist/apps/api

RUN npm ci && \
    npm run database:generate-typings

# Final stage: the ContainerForge Ubuntu base (read-only runtime, no build tools).
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION

ENV NODE_ENV=production \
    HOME=/tmp \
    npm_config_cache=/tmp/npm \
    PRISMA_HIDE_UPDATE_MESSAGE=1

USER root

# UNVERIFIED: remove curl and openssl if the base already ships them.
# hadolint ignore=DL3008,DL3015
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl openssl && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /src/dist/apps /app/ghostfolio/apps/
COPY --from=builder /src/LICENSE /usr/share/licenses/ghostfolio/LICENSE

# Prisma engines must load from the copied node_modules.
RUN cd /app/ghostfolio/apps/api && node -e "require('@prisma/client')"

USER apps
COPY --chmod=0755 . /

WORKDIR /app/ghostfolio/apps/api

VOLUME /config

EXPOSE 3333

CMD ["/start.sh"]
