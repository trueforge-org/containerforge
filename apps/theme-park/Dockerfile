

# Builder stage
FROM ghcr.io/trueforge-org/python:3.14.6@sha256:ded45532b707cd6a04d07ec3be3feb9a128b6ee053eb6eb349c8c85eeeefbc9b AS builder
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
FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:f5096c09d4a2b634b481c3ab7f7bfb576b264c63821f21ef6fe26cdb7f679f72
ENV NGINX_ENTRYPOINT_WORKER_PROCESSES_AUTOTUNE=1

USER root

# Copy built files from builder
COPY --from=builder --chown=568:568 /tmp/index.html /usr/share/nginx/html/
COPY --from=builder --chown=568:568 /tmp/css /usr/share/nginx/html/css/
COPY --from=builder --chown=568:568 /tmp/resources /usr/share/nginx/html/resources/

USER apps
COPY --chmod=0755 . /
WORKDIR /usr/share/nginx/html
