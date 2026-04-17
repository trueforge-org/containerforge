

FROM ghcr.io/trueforge-org/python:3.13.12@sha256:43a10c572aef8f97ad3c8cb4e0eff77fbc9068de95e1abecad0c4c0a8a843dbf AS builder
WORKDIR /app
ARG VERSION

USER root

# Install system dependencies needed for building Python packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc && \
    rm -rf /var/lib/apt/lists/*

# Create virtual environment and upgrade pip/setuptools
RUN python -m venv /app/venv && /app/venv/bin/pip install --no-cache-dir -U pip setuptools

# Download and extract the release. Upstream moved dependency metadata from
# src/requirements.txt to a top-level pyproject.toml starting at 2.5.5, so we
# stage the whole project for pip and copy the source files into /app for the
# existing CMD to find.
ENV RELEASE_URL="https://github.com/kiwigrid/k8s-sidecar/archive/refs/tags/${VERSION}.tar.gz"
RUN curl -L https://github.com/kiwigrid/k8s-sidecar/archive/refs/tags/${VERSION}.tar.gz -o /tmp/release.tar.gz && \
    mkdir -p /tmp/src_temp && \
    tar -xzf /tmp/release.tar.gz -C /tmp/src_temp \
        k8s-sidecar-${VERSION}/pyproject.toml \
        k8s-sidecar-${VERSION}/src && \
    /app/venv/bin/pip install --no-cache-dir /tmp/src_temp/k8s-sidecar-${VERSION} && \
    cp -r /tmp/src_temp/k8s-sidecar-${VERSION}/src/* /app/ && \
    rm -rf /tmp/release.tar.gz /tmp/src_temp && \
    # Remove tests and compiled Python files
    find /app/venv \( -type d -name test -o -name tests \) -o \( -type f -name '*.pyc' -o -name '*.pyo' \) -exec rm -rf '{}' +

FROM ghcr.io/trueforge-org/python:3.13.12@sha256:43a10c572aef8f97ad3c8cb4e0eff77fbc9068de95e1abecad0c4c0a8a843dbf

USER apps
COPY --chmod=0755 . /

WORKDIR /app

# Copy built app from builder
COPY --from=builder /app /app

ENV PATH="/app/venv/bin:$PATH"

CMD [ "python", "-u", "/app/sidecar.py" ]
