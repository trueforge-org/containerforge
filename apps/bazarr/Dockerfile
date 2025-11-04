# syntax=docker/dockerfile:1

FROM ghcr.io/trueforge-org/python:3.13.7@sha256:462920f87d68208b7203ce499c21a3848dbf1ff90e726538027b40c414bd7ff9
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
    && chown -R root:root /app && chmod -R 755 /app \
    && pip uninstall --yes uv \
    && rm -rf /root/.cache /root/.cargo /tmp/* /app/bin/bin

# Copy local files
COPY . /

# Copy unrar binary from LinuxServer image
COPY --from=ghcr.io/linuxserver/unrar:latest /usr/bin/unrar-alpine /usr/bin/unrar

USER nobody:nogroup
WORKDIR /config
