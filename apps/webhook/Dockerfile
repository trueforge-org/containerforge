

FROM ghcr.io/trueforge-org/python:3.13.12@sha256:1ffd2f78f3f65ac2e2e6011bc70d7647114e05e690f3a2684ec2223a2f322125
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
