

FROM ghcr.io/trueforge-org/python:3.14.6@sha256:05f202826a9a6c79df728a9e9e7ad325a0abd9c0430fb22d30583ef55e459329
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

USER apps
COPY --chmod=0755 . /
WORKDIR /config
HEALTHCHECK CMD ["/healthcheck.sh"]
