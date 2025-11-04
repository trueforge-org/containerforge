
# syntax=docker/dockerfile:1

FROM ghcr.io/trueforge-org/ubuntu:24.04.0@sha256:665ed0fd948cf3c093cb8e3fbf7f3add2a14915814322a302bb6bb3f4e25726a

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
