FROM ghcr.io/trueforge-org/node:rolling@sha256:bc0b3758205bf09f45751164affb9028ddcd246e852a1611b0468a03a2244ea9 AS dependencies

USER root

ARG VERSION

ENV WORKDIR=/app
ENV WUD_LOG_FORMAT=text
ENV VERSION=$VERSION

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /app

USER root

RUN mkdir -p /app/src && \
    curl -fsSL "https://github.com/getwud/wud/archive/refs/tags/${VERSION}.tar.gz" \
        | tar xzf - -C /app/src --strip-components=1 && \
    cd src \
    && cd /app/src/app && npm ci \
    && cd /app/src/e2e && npm ci \
    && cd /app/src/ui && npm ci && npm run build \
    && cp /app/src/app/package* /app/src && \
    cd /app/src/ && npm ci --omit=dev --omit=optional --no-audit --no-fund && \
    chown -R apps:apps /app && chmod -R 755 /app && \
    rm -rf /var/lib/apt/lists/* /tmp/*

FROM ghcr.io/trueforge-org/node:rolling@sha256:bc0b3758205bf09f45751164affb9028ddcd246e852a1611b0468a03a2244ea9

ARG VERSION

ENV WORKDIR=/app
ENV WUD_LOG_FORMAT=text
ENV VERSION=$VERSION

USER root

RUN mkdir -p /store && \
    chown -R apps:apps /app /store && chmod -R 755 /app /store

USER apps:apps

# Copy app
COPY --from=dependencies  /app/src/app/ /app

## Copy node_modules
COPY --from=dependencies /app/src/node_modules /app/node_modules

# Copy ui
COPY --from=dependencies  /app/src/ui/dist/ /app/ui

COPY --chmod=0775 . /

USER root
WORKDIR /app
