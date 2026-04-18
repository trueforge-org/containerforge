

FROM ghcr.io/trueforge-org/python:3.14.4@sha256:ad4dde9774b3433fdfd16a118973b00ebf41d716d9f8e666cc34c8e30c168c56
ARG VERSION

ENV PLEXAPI_CONFIG_PATH="/config/config.ini" \
    JBOPS__SCRIPT_PATH="fun/plexapi_haiku.py"

USER root
WORKDIR /app

# Install build dependencies, clone JBOPS, install Python requirements
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        build-essential \
        libffi-dev \
        libssl-dev \
        git \
    && rm -rf /var/lib/apt/lists/*; \
    rm -rf /app/venv; \
    git clone --single-branch --branch "${VERSION}" https://github.com/blacktwin/JBOPS.git .; \
    pip install --upgrade --requirement requirements.txt; \
    chown -R root:root /app && chmod -R 755 /app; \
    \
    # Remove build dependencies to reduce image size
    apt-get purge -y --auto-remove build-essential libffi-dev libssl-dev git; \
    rm -rf /root/.cache /tmp/* /app/maps

# Copy local files

USER apps
COPY --chmod=0755 . /
