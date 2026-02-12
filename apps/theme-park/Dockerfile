

# Builder stage
FROM ghcr.io/trueforge-org/python:3.13.7@sha256:708f480d444e56c1b20c0966b9fa08ce0aaba16ed5e2ef3469f5f6a161549e87 AS builder
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
FROM ghcr.io/trueforge-org/nginx:1.24.0@sha256:48cf43659d6b401c805c2b873d1027e5539fc91bba0dc746eee4e920db5eebb5
ENV NGINX_ENTRYPOINT_WORKER_PROCESSES_AUTOTUNE=1

USER root

# Copy built files from builder
COPY --from=builder --chown=568:568 /tmp/index.html /usr/share/nginx/html/
COPY --from=builder --chown=568:568 /tmp/css /usr/share/nginx/html/css/
COPY --from=builder --chown=568:568 /tmp/resources /usr/share/nginx/html/resources/

USER apps:apps
WORKDIR /usr/share/nginx/html
