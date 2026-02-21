

FROM ghcr.io/trueforge-org/python:3.13.12@sha256:32f90bc0c1f522ce2b2ffdef58e2a781e5fb71b9c7c90c0de92b516f493f7518 AS builder
WORKDIR /app
ARG VERSION

USER root

# Install system dependencies needed for building Python packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc && \
    rm -rf /var/lib/apt/lists/*

# Create virtual environment and upgrade pip/setuptools
RUN python -m venv /app/venv && /app/venv/bin/pip install --no-cache-dir -U pip setuptools

# Download and extract only the src/ folder from the release
ENV RELEASE_URL="https://github.com/kiwigrid/k8s-sidecar/archive/refs/tags/${VERSION}.tar.gz"
RUN curl -L https://github.com/kiwigrid/k8s-sidecar/archive/refs/tags/${VERSION}.tar.gz -o release.tar.gz && \
    mkdir src_temp && \
    tar -xzf release.tar.gz -C src_temp k8s-sidecar-${VERSION}/src && \
    cp -r src_temp/k8s-sidecar-${VERSION}/src/* /app/ && \
    rm -rf release.tar.gz src_temp

# Install Python dependencies
RUN /app/venv/bin/pip install --no-cache-dir -r requirements.txt && \
    rm requirements.txt && \
    # Remove tests and compiled Python files
    find /app/venv \( -type d -name test -o -name tests \) -o \( -type f -name '*.pyc' -o -name '*.pyo' \) -exec rm -rf '{}' +

FROM ghcr.io/trueforge-org/python:3.13.12@sha256:32f90bc0c1f522ce2b2ffdef58e2a781e5fb71b9c7c90c0de92b516f493f7518

USER apps
COPY --chmod=0755 . /

WORKDIR /app

# Copy built app from builder
COPY --from=builder /app /app

ENV PATH="/app/venv/bin:$PATH"

CMD [ "python", "-u", "/app/sidecar.py" ]
