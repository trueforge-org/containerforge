# syntax=docker/dockerfile:1

FROM ghcr.io/trueforge-org/python:3.13.7@sha256:eb8c395317bd3e807501ef61f4d16a9582b11db2e28c46e74d1dd6c9762002a4 AS builder
WORKDIR /app
ARG VERSION

USER root

# Install system dependencies needed for building Python packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc && \
    rm -rf /var/lib/apt/lists/*

# Create virtual environment and upgrade pip/setuptools
RUN python -m venv .venv && .venv/bin/pip install --no-cache-dir -U pip setuptools

# Download and extract only the src/ folder from the release
ENV RELEASE_URL="https://github.com/kiwigrid/k8s-sidecar/archive/refs/tags/${VERSION}.tar.gz"
RUN curl -L https://github.com/kiwigrid/k8s-sidecar/archive/refs/tags/${VERSION}.tar.gz -o release.tar.gz && \
    mkdir src_temp && \
    tar -xzf release.tar.gz -C src_temp k8s-sidecar-1.30.10/src && \
    cp -r src_temp/k8s-sidecar-1.30.10/src/* /app/ && \
    rm -rf release.tar.gz src_temp

# Install Python dependencies
RUN .venv/bin/pip install --no-cache-dir -r requirements.txt && \
    rm requirements.txt && \
    # Remove tests and compiled Python files
    find /app/.venv \( -type d -a -name test -o -name tests \) -o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) -exec rm -rf '{}' +

FROM ghcr.io/trueforge-org/python:3.13.7@sha256:eb8c395317bd3e807501ef61f4d16a9582b11db2e28c46e74d1dd6c9762002a4

USER nobody:nogroup

WORKDIR /app

# Copy built app from builder
COPY --from=builder /app /app

ENV PATH="/app/.venv/bin:$PATH"

CMD [ "python", "-u", "/app/sidecar.py" ]
