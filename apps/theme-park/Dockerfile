

# Builder stage
FROM ghcr.io/trueforge-org/python:3.13.13@sha256:d90e00c1ba6abf16c8d68d5e898657109371cd601270e3a3ae5b32782fe1cc15 AS builder
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
FROM ghcr.io/trueforge-org/nginx:1.24.0@sha256:db8a17d268c9008c3fdc6dc977de004fbf152950abaf4c52ddc207b1cdb85a61
ENV NGINX_ENTRYPOINT_WORKER_PROCESSES_AUTOTUNE=1

USER root

# Copy built files from builder
COPY --from=builder --chown=568:568 /tmp/index.html /usr/share/nginx/html/
COPY --from=builder --chown=568:568 /tmp/css /usr/share/nginx/html/css/
COPY --from=builder --chown=568:568 /tmp/resources /usr/share/nginx/html/resources/

USER apps
COPY --chmod=0755 . /
WORKDIR /usr/share/nginx/html
