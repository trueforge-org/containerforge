

FROM ghcr.io/trueforge-org/python:3.13.12@sha256:d5ee44265ccc73d87135ab858d4cf4e793603f0efe7180d8b44acfe3af54db42
ARG VENDOR
ARG VERSION

ENV \
    BAZARR__PORT=6767 \
    BAZARR_PACKAGE_AUTHOR=${VENDOR} \
    BAZARR_PACKAGE_VERSION=${VERSION} \
    BAZARR_VERSION=${VERSION}
USER root
WORKDIR /app

# Install runtime and build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        ffmpeg \
        libxml2 \
        libpq5 \
        libxslt1.1 \
        mediainfo \
        unzip \
        build-essential \
        cargo \
        libffi-dev \
        libpq-dev \
        libxml2-dev \
        libxslt1-dev \
    && rm -rf /var/lib/apt/lists/*

# Download Bazarr release and install Python dependencies
RUN curl -fsSL -o /tmp/app.zip "https://github.com/morpheus65535/bazarr/releases/download/${VERSION}/bazarr.zip" \
    && unzip -q /tmp/app.zip -d /app/bin \
    && sed -i '/Pillow>/s/ --only-binary=Pillow//; /Pillow>/a --only-binary=Pillow' /app/bin/requirements.txt \
    && pip install uv \
    && uv pip install \
        --requirement /app/bin/requirements.txt \
        --requirement /app/bin/postgres-requirements.txt \
    && cp /etc/ssl/certs/ca-certificates.crt /etc/ca-certificates.crt \
    && chmod 644 /etc/ca-certificates.crt \
    && chown -R root:root /app && chmod -R 755 /app \
    && pip uninstall --yes uv \
    && rm -rf /root/.cache /root/.cargo /tmp/* /app/bin/bin

# Copy local files
COPY . /

# Copy unrar binary from LinuxServer image
COPY --from=ghcr.io/linuxserver/unrar:latest@sha256:22e6e76f2f2372a7cd6e046b10025e8bde8a04a2b2b2c6072fca6821da5747f7 /usr/bin/unrar-ubuntu /usr/bin/unrar

USER apps
WORKDIR /config

CMD [""]

HEALTHCHECK CMD curl --request GET --silent --output /dev/null --show-error --fail http://127.0.0.1:${BAZARR__PORT}/api/system/ping
