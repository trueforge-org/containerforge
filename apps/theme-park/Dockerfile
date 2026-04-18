

# Builder stage
FROM ghcr.io/trueforge-org/python:3.14.4@sha256:ad4dde9774b3433fdfd16a118973b00ebf41d716d9f8e666cc34c8e30c168c56 AS builder
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
FROM ghcr.io/trueforge-org/nginx:1.24.0@sha256:a48804e1c6f6c84bbc1302031569a3cfe3cf9860d44503f028e9d22d8624420f
ENV NGINX_ENTRYPOINT_WORKER_PROCESSES_AUTOTUNE=1

USER root

# Copy built files from builder
COPY --from=builder --chown=568:568 /tmp/index.html /usr/share/nginx/html/
COPY --from=builder --chown=568:568 /tmp/css /usr/share/nginx/html/css/
COPY --from=builder --chown=568:568 /tmp/resources /usr/share/nginx/html/resources/

USER apps
COPY --chmod=0755 . /
WORKDIR /usr/share/nginx/html
