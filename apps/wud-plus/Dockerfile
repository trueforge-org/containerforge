FROM ghcr.io/trueforge-org/node:rolling

USER root

ARG VERSION

ENV WORKDIR=/app
ENV WUD_LOG_FORMAT=text
ENV VERSION=$VERSION

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

HEALTHCHECK --interval=30s --timeout=5s CMD if [[ -z ${WUD_SERVER_ENABLED} || ${WUD_SERVER_ENABLED} == 'true' ]]; then curl --fail http://localhost:${WUD_SERVER_PORT:-3000}/health || exit 1; else exit 0; fi;

WORKDIR /app

RUN mkdir -p /app/bin && \
    curl -fsSL "https://github.com/trueforge-org/wud-plus/archive/refs/tags/${VERSION}.tar.gz" \
        | tar xzf - -C /app --strip-components=1 && \
    chown -R apps:apps /app && chmod -R 755 /app && \
    rm -rf /var/lib/apt/lists/* /tmp/*

# Install dependencies
RUN cd /app/app && npm ci --omit=dev --omit=devoptional --no-audit --no-fund

USER apps:apps

COPY --chmod=0775 . /

WORKDIR /config
