

FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d
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
