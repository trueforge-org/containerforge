

FROM ghcr.io/trueforge-org/python:3.13.7@sha256:87a0f5a9d93409b66626a7de1e66fe7c4d9e1fd037cd4c86e91cc293ebfde78a
ARG VERSION

ENV TAUTULLI_DOCKER="True"

USER root
WORKDIR /app

# Install build dependencies, Python packages, and Tautulli
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        build-essential \
        cargo \
        libffi-dev \
        libssl-dev \
    && rm -rf /var/lib/apt/lists/*; \
    \
    # Install Python packages
    pip install --no-cache-dir uv; \
    uv pip install --requirement "https://raw.githubusercontent.com/Tautulli/tautulli-baseimage/python3/requirements.txt"; \
    \
    # Download and extract Tautulli
    mkdir -p /app; \
    curl -fsSL "https://github.com/Tautulli/Tautulli/archive/v${VERSION}.tar.gz" \
        | tar xzf - -C /app --strip-components=1; \
    echo "v${VERSION}" > /app/version.txt; \
    echo "master" > /app/branch.txt; \
    \
    # Set permissions
    chown -R root:root /app && chmod -R 755 /app; \
    \
    # Cleanup
    pip uninstall --yes uv; \
    apt-get purge -y --auto-remove build-essential cargo libffi-dev libssl-dev; \
    rm -rf /root/.cache /root/.cargo /tmp/*

# Copy local files
COPY . /

USER apps:apps
WORKDIR /config
