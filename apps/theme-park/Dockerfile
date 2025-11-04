# syntax=docker/dockerfile:1

# Builder stage
FROM ghcr.io/trueforge-org/python:3.13.7@sha256:462920f87d68208b7203ce499c21a3848dbf1ff90e726538027b40c414bd7ff9 AS builder
ARG VERSION

USER root
WORKDIR /tmp

# Install dependencies, download, and build Theme.Park
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        sed \
    && rm -rf /var/lib/apt/lists/*; \
    \
    curl -fsSL "https://github.com/themepark-dev/theme.park/archive/${VERSION}.tar.gz" \
        | tar xzf - --strip-components=1; \
    python3 themes.py; \
    grep -rl 'https://theme-park.dev' . | xargs sed -i 's|https\://theme-park.dev||g'

# Nginx stage
FROM ghcr.io/trueforge-org/nginx:1.24.0@sha256:695d6912a50d5aaf8a1b3e7610874c1672c7a2f35fa9c1cda17d22790ad7eafb
ENV NGINX_ENTRYPOINT_WORKER_PROCESSES_AUTOTUNE=1

USER root

# Copy built files from builder
COPY --from=builder --chown=nobody:nogroup /tmp/index.html /usr/share/nginx/html/
COPY --from=builder --chown=nobody:nogroup /tmp/css /usr/share/nginx/html/css/
COPY --from=builder --chown=nobody:nogroup /tmp/resources /usr/share/nginx/html/resources/

USER nobody:nogroup
WORKDIR /usr/share/nginx/html
