

FROM ghcr.io/trueforge-org/python:3.13.12@sha256:32f90bc0c1f522ce2b2ffdef58e2a781e5fb71b9c7c90c0de92b516f493f7518
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
    UV_EXTRA_INDEX_URL="https://pypi.org/simple" uv pip install "setuptools<81" --requirement "https://raw.githubusercontent.com/Tautulli/tautulli-baseimage/python3/requirements.txt"; \
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

USER apps
COPY --chmod=0755 . /
WORKDIR /config
