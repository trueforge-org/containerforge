

# Builder stage
FROM ghcr.io/trueforge-org/python:3.13.7@sha256:7c54cb2dc135ee909b5ac1c874a894442eff453e1409db837c8cd3af933a0527 AS builder
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
FROM ghcr.io/trueforge-org/nginx:1.24.0@sha256:8f8eca958a6442bb760182401cb8921640b6b72c8f5fabb0c07b5dc1c13e3cb4
ENV NGINX_ENTRYPOINT_WORKER_PROCESSES_AUTOTUNE=1

USER root

# Copy built files from builder
COPY --from=builder --chown=568:568 /tmp/index.html /usr/share/nginx/html/
COPY --from=builder --chown=568:568 /tmp/css /usr/share/nginx/html/css/
COPY --from=builder --chown=568:568 /tmp/resources /usr/share/nginx/html/resources/

USER apps:apps
WORKDIR /usr/share/nginx/html
