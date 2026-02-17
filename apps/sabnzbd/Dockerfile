

FROM ghcr.io/trueforge-org/python:3.13.12@sha256:d9b5d12c8e22d9b84df211da15c73e7e2b36441675f00bba2c706f93526c602b
ARG TARGETARCH
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
        unzip \
        build-essential \
        cargo \
        libffi-dev \
        libssl-dev \
    && rm -rf /var/lib/apt/lists/*; \
    \
    ln -sf /usr/bin/7z /usr/bin/7za; \
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

# download, install, and verify par2-turbo
RUN set -eux; \
    PAR2_VERSION="1.3.0"; \
    PAR2_FILE="par2cmdline-turbo-${PAR2_VERSION}-linux-${TARGETARCH}"; \
    curl -fsSL -o "/tmp/${PAR2_FILE}.zip" \
      "https://github.com/animetosho/par2cmdline-turbo/releases/download/v${PAR2_VERSION}/${PAR2_FILE}.zip"; \
    unzip -q "/tmp/${PAR2_FILE}.zip" -d /usr/local/bin/; \
    chmod +x /usr/local/bin/par2; \
    par2 --version

# Copy local files
COPY . /

# Copy unrar binary from LinuxServer image
COPY --from=ghcr.io/linuxserver/unrar:latest@sha256:92b4d32099ca9c9290bed83b4ba7cad5b0f563fd3e3bc63ca6a924b6f8a9245b /usr/bin/unrar-ubuntu /usr/bin/unrar

USER apps
WORKDIR /config
