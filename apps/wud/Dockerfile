FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:1e4ce94f2d255834fe7557fd2de50f2c021834c8eff14e43b84b70a768cd8348 AS dependencies

USER root

ARG VERSION

ENV WORKDIR=/app
ENV WUD_LOG_FORMAT=text
ENV VERSION=$VERSION

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /app

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential python3 && \
    mkdir -p /app/src && \
    curl -fsSL "https://github.com/getwud/wud/archive/refs/tags/${VERSION}.tar.gz" \
        | tar xzf - -C /app/src --strip-components=1 && \
    cd /app/src/app && \
    npm ci --include=dev --omit=optional --no-audit --no-fund && \
    npm run build && \
    npm prune --omit=dev && \
    cd /app/src/ui && \
    npm ci --include=dev --omit=optional --no-audit --no-fund && \
    npm run build && \
    chown -R apps:apps /app && chmod -R 755 /app && \
    rm -rf /var/lib/apt/lists/* /tmp/*

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:1e4ce94f2d255834fe7557fd2de50f2c021834c8eff14e43b84b70a768cd8348

ARG VERSION



USER root

RUN mkdir -p /store && \
    chown -R apps:apps /app /store && chmod -R 755 /app /store

USER apps

# Copy app runtime artifacts
COPY --from=dependencies /app/src/app/node_modules /app/node_modules
COPY --from=dependencies /app/src/app/dist /app/dist
COPY --from=dependencies /app/src/app/package.json /app/package.json
COPY --from=dependencies /app/src/app/.pino-prettyrc.json /app/.pino-prettyrc.json

# Copy ui
COPY --from=dependencies  /app/src/ui/dist/ /app/ui

COPY --chmod=0775 . /

USER root
COPY --chmod=0755 . /

ENV WORKDIR=/app \
    WUD_LOG_FORMAT=text \
    WUD_REGISTRY_CUSTOM_TRUEFORGE_URL=https://oci.trueforge.org \
    WUD_WATCHER_local_WATCHBYDEFAULT=false

WORKDIR /app

