


FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:654a659958d368fa2e5f1aca4a24347c3e58f2c9c5194e1d07e3abaeb539ac32

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
