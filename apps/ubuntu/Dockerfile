

ARG VERSION
FROM docker.io/library/ubuntu:24.04@sha256:c35e29c9450151419d9448b0fd75374fec4fff364a27f176fb458d472dfc9e54

ARG TARGETARCH
ARG VENDOR

ENV DEBIAN_FRONTEND="noninteractive" \
    NVIDIA_DRIVER_CAPABILITIES="compute,video,utility" \
     # Enable detection of dotnet running in a container
    DOTNET_RUNNING_IN_CONTAINER=true \
    XDG_CONFIG_HOME=/config

USER root
WORKDIR /app

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Create group and user "www-data" with UID and GID 33
RUN groupadd -g 33 www-data && \
    useradd -m -u 568 -g 33 -s /bin/bash www-data; \
    mkdir -p /home/www-data; \
    chown -R www-data:www-data /home/www-data

# Create group and user "nginx" with UID and GID 101
RUN groupadd -g 101 nginx && \
    useradd -m -u 101 -g 101 -s /bin/bash nginx; \
    mkdir -p /home/nginx; \
    chown -R nginx:nginx /home/nginx

# Create group and user "apps" with UID and GID 568
RUN groupadd -g 568 apps && \
    useradd -m -u 568 -g 568 -s /bin/bash apps; \
    usermod -aG 10,20,29,44,39,101,107,129 568; \
    mkdir -p /home/apps; \
    chown -R apps:apps /home/apps

# Create group and user "nonroot" with UID and GID 65532
RUN groupadd -g 65532 nonroot && \
    useradd -m -u 65532 -g 65532 -s /bin/bash nonroot; \
    mkdir -p /home/nonroot; \
    chown -R nonroot:nonroot /home/nonroot

# Install packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests \
        bash \
        ca-certificates \
        tini \
        coreutils \
        curl \
        git \
        jq \
        nano \
        tzdata \
        uuid-runtime \
        xmlstarlet \
        libicu-dev \
        gettext-base \
        grep \
        tar \
        wget \
        libssl3 \
        sed \
        software-properties-common \
        sudo \
        gnupg \
        dirmngr \
        xz-utils \
        locales \
        fontconfig \
        p11-kit \
        unzip \
        locales-all \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && apt-get autoremove -y \
    && apt-get clean \
    && update-ca-certificates \
    && mkdir /cache /docker-entrypoint.d \
    && chown -R apps:apps /app /cache /docker-entrypoint.d && chmod -R 755 /app /cache /docker-entrypoint.d \
    && chmod 777 /cache \
    && wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq && \
    chmod +x /usr/local/bin/yq \
    && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/

# Copy unrar binary from LinuxServer image
COPY --from=ghcr.io/linuxserver/unrar:latest@sha256:92b4d32099ca9c9290bed83b4ba7cad5b0f563fd3e3bc63ca6a924b6f8a9245b /usr/bin/unrar-ubuntu /usr/bin/unrar

# Use a safe non-root user
# Note: nobody:nogroup does not map to the same uid:gid on every (host/share) distro!
USER apps:apps

COPY --chmod=0775 . /

RUN echo "show app and root folder content...";\
    ls -l / \
    && \
    ls -l /app

# Config directory (persistent volume)
VOLUME ["/config", "/data"]
WORKDIR /config

# PID 1 with tini, handoff to entrypoint
ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]
