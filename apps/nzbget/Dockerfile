

FROM ghcr.io/trueforge-org/python:3.14.8@sha256:f099b700b824b7760cb846418f84a2c14c2f04992320506ab3ca5b79d3ac1232
ARG VERSION

ENV NZBGET__PORT=6789

USER root
WORKDIR /app

# Install dependencies and NZBGet
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        p7zip-full \
        lscpu \
    && rm -rf /var/lib/apt/lists/*; \
    \
    curl -fsSL -o /tmp/nzbget.run \
        "https://github.com/nzbgetcom/nzbget/releases/download/v${VERSION}/nzbget-${VERSION}-bin-linux.run"; \
    sh /tmp/nzbget.run --destdir /app; \
    rm -rf /app/7za /app/unrar /app/unrar7; \
    \
    pip install uv; \
    uv pip install apprise pynzb requests; \
    chown -R root:root /app && chmod -R 755 /app; \
    pip uninstall --yes uv; \
    rm -rf /root/.cache /root/.cargo /tmp/*

# Copy local files

# Copy unrar binary from LinuxServer image
COPY --from=ghcr.io/linuxserver/unrar:latest@sha256:48c0ce2609bb3c35764956bbd9395e95b177421e3c74b3628c3676029f24f2e0 /usr/bin/unrar-ubuntu /usr/bin/unrar

USER apps
COPY --chmod=0755 . /
WORKDIR /config
