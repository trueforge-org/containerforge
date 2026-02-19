

FROM ghcr.io/trueforge-org/python:3.13.12@sha256:8b4bc444de4cf6adfc309c1d748674d60f2c849924b456cbdc93650f8566bca7
ARG TARGETARCH
ARG VERSION

ENV \
    WEBHOOK__PORT="9000" \
    WEBHOOK__URLPREFIX="hooks"

USER root
WORKDIR /app

# Install dependencies and webhook binary
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        jo \
    && rm -rf /var/lib/apt/lists/*; \
    \
    mkdir -p /app/bin; \
    curl -fsSL "https://github.com/adnanh/webhook/releases/download/${VERSION}/webhook-linux-${TARGETARCH}.tar.gz" \
        | tar xzf - -C /app/bin --strip-components=1; \
    \
    # Install Python dependencies
    pip install --no-cache-dir uv; \
    uv pip install "apprise>=1,<2"; \
    \
    # Set permissions and cleanup
    chown -R root:root /app && chmod -R 755 /app; \
    pip uninstall --yes uv; \
    rm -rf /tmp/*

# Copy local files
COPY . /
COPY --chmod=755 healthcheck.sh /healthcheck.sh

USER apps
COPY container-test.yaml /container-test.yaml
WORKDIR /config
HEALTHCHECK CMD ["/healthcheck.sh"]
