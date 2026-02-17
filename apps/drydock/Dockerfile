# Base stage - install system dependencies
FROM ghcr.io/trueforge-org/node:rolling@sha256:b003160352643fa8b3341f2550c484d1ec754078df700f7a87948584e0a5939c AS base

USER root

ARG VERSION
ARG TARGETARCH

ENV WORKDIR=/app
ENV DD_LOG_FORMAT=text
ENV DD_VERSION=$VERSION

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /app

# Install additional system packages (bash, curl, git, jq, openssl, tini, tzdata already in base)
# hadolint ignore=DL3008
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gosu \
    && rm -rf /var/lib/apt/lists/*

# Install trivy and cosign
RUN ARCH=${TARGETARCH:-amd64} && \
    TRIVY_ARCH=$([ "$ARCH" = "arm64" ] && echo "ARM64" || echo "64bit") && \
    curl -fsSL "https://github.com/aquasecurity/trivy/releases/download/v0.69.1/trivy_0.69.1_Linux-${TRIVY_ARCH}.tar.gz" \
        | tar xz -C /usr/local/bin trivy && \
    curl -fsSL "https://github.com/sigstore/cosign/releases/download/v2.4.1/cosign-linux-${ARCH}" -o /usr/local/bin/cosign && \
    chmod +x /usr/local/bin/cosign && \
    mkdir -p /config && \
    chown -R apps:apps /app /config && chmod -R 755 /app /config && \
    rm -rf /tmp/*

# Build stage for backend app
FROM base AS app-build

USER root

RUN mkdir -p /app/src && \
    curl -fsSL "https://github.com/trueforge-org/drydock/archive/refs/tags/${VERSION}.tar.gz" \
        | tar xzf - -C /app/src --strip-components=1

WORKDIR /app/src/app

# Install dependencies (including dev)
RUN npm ci --include=dev --omit=optional --no-audit --no-fund --no-update-notifier

# Build and remove dev dependencies
RUN npm run build && \
    npm prune --omit=dev

# Build stage for frontend UI
FROM base AS ui-build

USER root

RUN mkdir -p /app/src && \
    curl -fsSL "https://github.com/trueforge-org/drydock/archive/refs/tags/${VERSION}.tar.gz" \
        | tar xzf - -C /app/src --strip-components=1

WORKDIR /app/src/ui

# Install ui dependencies
RUN npm ci --no-audit --no-fund --no-update-notifier

# Build static assets
RUN npm run build

# Release stage
FROM base AS release

ARG VERSION

USER root

# Copy startup script
COPY --chmod=0775 start.sh /

# Copy node_modules from app-build
COPY --from=app-build /app/src/app/node_modules /app/node_modules

# Copy app (dist)
COPY --from=app-build /app/src/app/dist /app/dist
COPY --from=app-build /app/src/app/package.json /app/package.json

# Copy ui
COPY --from=ui-build /app/src/ui/dist /app/ui

USER apps

ENV WORKDIR=/app \
    DD_LOG_FORMAT=text \
    DD_VERSION=$VERSION \
    DD_WATCHER_local_WATCHBYDEFAULT=false \
    DD_STORE_PATH=/config

WORKDIR /app

HEALTHCHECK --interval=30s --timeout=5s CMD sh -c 'if [ -z "$DD_SERVER_ENABLED" ] || [ "$DD_SERVER_ENABLED" = "true" ]; then curl --fail http://localhost:${DD_SERVER_PORT:-3000}/health || exit 1; else exit 0; fi'

CMD ["node", "dist/index.js"]
