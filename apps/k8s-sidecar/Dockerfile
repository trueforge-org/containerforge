

FROM ghcr.io/trueforge-org/python:3.13.12@sha256:0c2ff68fa63566e2fcbe025b58c229a612b4eba0377a0dc77b4b820a7d0c2ffd AS builder
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

FROM ghcr.io/trueforge-org/python:3.13.12@sha256:0c2ff68fa63566e2fcbe025b58c229a612b4eba0377a0dc77b4b820a7d0c2ffd

USER apps

WORKDIR /app

# Copy built app from builder
COPY --from=builder /app /app
COPY --from=builder /app/venv /app/venv

ENV PATH="/app/venv/bin:$PATH"

CMD [ "python", "-u", "/app/sidecar.py" ]
