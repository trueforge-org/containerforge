# syntax=docker/dockerfile:1

FROM ghcr.io/trueforge-org/python:3.13.7@sha256:462920f87d68208b7203ce499c21a3848dbf1ff90e726538027b40c414bd7ff9
ARG VERSION

ENV SABNZBD__ADDRESS="[::]" \
    SABNZBD__PORT="8080"

USER root
WORKDIR /app

# Install runtime and build dependencies
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        p7zip-full \
        par2cmdline \
        build-essential \
        cargo \
        libffi-dev \
        libssl-dev \
    && rm -rf /var/lib/apt/lists/*; \
    \
    mkdir -p /app; \
    curl -fsSL "https://github.com/sabnzbd/sabnzbd/releases/download/${VERSION}/SABnzbd-${VERSION}-src.tar.gz" \
        | tar xzf - -C /app --strip-components=1; \
    python3 tools/make_mo.py; \
    \
    # Install Python dependencies
    pip install --no-cache-dir uv; \
    uv pip install --requirement /app/requirements.txt; \
    \
    # Set permissions
    chown -R root:root /app && chmod -R 755 /app; \
    \
    # Cleanup build tools and caches
    pip uninstall --yes uv; \
    apt-get purge -y --auto-remove build-essential cargo libffi-dev libssl-dev; \
    rm -rf /root/.cache /root/.cargo /tmp/*

# Copy local files
COPY . /

# Copy unrar binary from LinuxServer image
COPY --from=ghcr.io/linuxserver/unrar:latest /usr/bin/unrar-alpine /usr/bin/unrar

USER nobody:nogroup
WORKDIR /config
