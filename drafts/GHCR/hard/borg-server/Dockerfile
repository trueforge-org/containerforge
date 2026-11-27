FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
USER root

# Rootless rewrite of AnotherStranger/docker-borg-backup (Apache-2.0, Alpine, root).
# sshd listens on 2222 (non-root cannot bind 22). Host keys and backups live in /config.
# Borg is installed into the base's /app/venv at build time. Nothing is written to /app at runtime.
ENV HOME=/config \
    PATH=/app/venv/bin:$PATH

# Build-only packages are purged in the same layer. The runtime libs stay.
# UNVERIFIED: Ubuntu package names on 26.04, and whether borgbackup needs a source build
# (wheel or source is not checked here).
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        build-essential \
        pkg-config \
        libacl1-dev \
        libzstd-dev \
        liblz4-dev \
        libxxhash-dev \
        libssl-dev \
        libacl1 \
        libzstd1 \
        liblz4-1 \
        libxxhash0 \
        openssh-server; \
    /app/venv/bin/pip install --no-cache-dir "borgbackup==${VERSION}"; \
    apt-get purge -y --auto-remove \
        build-essential \
        pkg-config \
        libacl1-dev \
        libzstd-dev \
        liblz4-dev \
        libxxhash-dev \
        libssl-dev; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/*

# sshd privilege-separation directory, and the Borg licence from the installed dist-info.
# UNVERIFIED: the dist-info LICENSE path (python3.15 site-packages glob).
RUN set -eux; \
    mkdir -p /run/sshd; \
    /app/venv/bin/borg --version; \
    install -D -m 0644 /app/venv/lib/python3*/site-packages/borgbackup-*.dist-info/LICENSE \
        /usr/share/licenses/borg-server/LICENSE; \
    chmod -R a+rX /app/venv

USER apps
COPY --chmod=0755 . /

EXPOSE 2222
VOLUME /config
WORKDIR /config
