
# syntax=docker/dockerfile:1

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:e0f946b03dc12bbfa4f72629bd61690502df47c59b4105bc37fe346dc5d489b8

ENV NGINX_ENTRYPOINT_WORKER_PROCESSES_AUTOTUNE=1

# NGINX version explicitly set
ARG VERSION

USER root

# Install NGINX and required tools
RUN set -eux; \
    apt-get update; \
    apt-get install --no-install-recommends -y \
        nginx=$VERSION; \
    rm -rf /var/lib/apt/lists/*

# Copy configuration files into container
COPY --chmod=755 ./ /

# Ensure NGINX directories are writable
RUN set -eux; \
    mkdir -p /tmp/nginx-temp /tmp/nginx-cache; \
    chmod -R 777 /tmp; \
    ln -sf /dev/stdout /var/log/nginx/access.log; \
    ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 8080
STOPSIGNAL SIGQUIT

USER nobody:nogroup

CMD ["nginx", "-c","/config/nginx.conf", "-g", "daemon off;"]
