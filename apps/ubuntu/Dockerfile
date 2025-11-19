


FROM docker.io/library/ubuntu:24.04@sha256:c35e29c9450151419d9448b0fd75374fec4fff364a27f176fb458d472dfc9e54

ARG VERSION
ARG TARGETARCH
ARG VENDOR

ENV DEBIAN_FRONTEND="noninteractive" \
    NVIDIA_DRIVER_CAPABILITIES="compute,video,utility" \
     # Enable detection of dotnet running in a container
    DOTNET_RUNNING_IN_CONTAINER=true \
    XDG_CONFIG_HOME=/config \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

USER root

# Config directory (persistent volume)
VOLUME ["/config", "/data"]

WORKDIR /app

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Create group and user "apps" with UID and GID 568
RUN groupadd -g 568 apps && \
    useradd -m -u 568 -g 568 -s /bin/bash apps; \
    usermod -aG 10,20,29,44,39,101,107,129 568; \
    mkdir -p /home/apps; \
    chown -R apps:apps /home/apps

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
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && apt-get autoremove -y \
    && apt-get clean \
    && update-ca-certificates \
    && locale-gen en_US.UTF-8 C.UTF-8 \
    && update-locale LANG=en_US.UTF-8
    && mkdir /cache /docker-entrypoint.d \
    && chown -R apps:apps /app /config /data /cache /docker-entrypoint.d && chmod -R 755 /app /config /data /cache /docker-entrypoint.d \
    && chmod 777 /cache \
    && wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${TARGETARCH} -O /usr/local/bin/yq && \
    chmod +x /usr/local/bin/yq \
    && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/

# Use a safe non-root user
# Note: nobody:nogroup does not map to the same uid:gid on every (host/share) distro!
USER apps:apps

# Copy unrar binary from LinuxServer image
COPY --from=ghcr.io/linuxserver/unrar:latest@sha256:92b4d32099ca9c9290bed83b4ba7cad5b0f563fd3e3bc63ca6a924b6f8a9245b /usr/bin/unrar-ubuntu /usr/bin/unrar

#Copy root files
COPY --chmod=0775 . /

WORKDIR /config

# PID 1 with tini, handoff to entrypoint
ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]
