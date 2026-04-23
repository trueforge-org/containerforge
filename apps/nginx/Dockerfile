


FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:01cc09f895d289305f12087ced3d9b01ad74ec5e958384d3274a7caa87a94c37

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

USER apps
COPY --chmod=0755 . /

CMD ["nginx", "-c","/config/nginx.conf", "-g", "daemon off;"]
