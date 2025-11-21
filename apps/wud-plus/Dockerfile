FROM ghcr.io/trueforge-org/node:rolling AS dependencies

USER root

ARG VERSION

ENV WORKDIR=/app
ENV WUD_LOG_FORMAT=text
ENV VERSION=$VERSION

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /app

USER root

RUN mkdir -p /app/src && \
    curl -fsSL "https://github.com/trueforge-org/wud-plus/archive/refs/tags/${VERSION}.tar.gz" \
        | tar xzf - -C /app/src --strip-components=1 && \
    cd src \
    && cd app && npm ci \
    && cd ../e2e && npm ci \
    && cd ../ui && npm ci && npm run build \
    && cd ../ && \
    cp ./app/package*. ./ && \
    npm ci --omit=dev --omit=devoptional --no-audit --no-fund && \
    chown -R apps:apps /app && chmod -R 755 /app && \
    rm -rf /var/lib/apt/lists/* /tmp/*

FROM ghcr.io/trueforge-org/node:rolling

ARG VERSION

ENV WORKDIR=/app
ENV WUD_LOG_FORMAT=text
ENV VERSION=$VERSION

USER apps:apps

## Copy node_modules
COPY --from=dependencies /app/node_modules /app/node_modules

# Copy app
COPY --from=dependencies  /app/src/app/ ./

# Copy ui
COPY --from=dependencies  /app/src/ui/dist/ ./ui

COPY --chmod=0775 . /

