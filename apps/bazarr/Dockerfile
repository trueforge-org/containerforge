

FROM ghcr.io/trueforge-org/python:3.14.6@sha256:ec53f98750c3acd589a038d00430d6554f2530c9888dce3b3651a943a62d43b4
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
    libxml2-16 \
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

# Copy unrar binary from LinuxServer image
COPY --from=ghcr.io/linuxserver/unrar:latest@sha256:5e150efdebbcb4e313b30bd17e40fc386f538a0a9baa4c9b1a5368a9a9a57e39 /usr/bin/unrar-ubuntu /usr/bin/unrar

USER apps
COPY --chmod=0755 . /
WORKDIR /config

CMD [""]

