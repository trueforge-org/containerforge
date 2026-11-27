FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS build

ARG VERSION
ARG TARGETARCH
# UNVERIFIED: the uv release version and its checksum are not pinned yet. Pin both before the first build.
ARG UV_VERSION=UNVERIFIED
USER root

# Open WebUI 0.13.5 needs Python >=3.11,<3.13. The python base is 3.15, so uv installs a managed Python 3.12.
# This is the plan's option (a) and needs maintainer sign-off.
ENV UV_PYTHON_INSTALL_DIR=/opt/python \
    UV_CACHE_DIR=/tmp/uv-cache \
    UV_LINK_MODE=copy \
    PIP_NO_CACHE_DIR=1 \
    HOME=/tmp

# hadolint ignore=DL3008
RUN test "${UV_VERSION}" != "UNVERIFIED" && \
    case "${TARGETARCH}" in \
        amd64) uvarch=x86_64 ;; \
        arm64) uvarch=aarch64 ;; \
        *) echo "unsupported ${TARGETARCH}"; exit 1 ;; \
    esac && \
    curl -fL "https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/uv-${uvarch}-unknown-linux-gnu.tar.gz" | \
        tar xz -C /usr/local/bin --strip-components=1 "uv-${uvarch}-unknown-linux-gnu/uv" && \
    uv --version

# UNVERIFIED: the wheel's dist-info licence file names and any system libraries open-webui needs at runtime.
RUN uv venv --python 3.12 /app/venv && \
    uv pip install --python /app/venv/bin/python "open-webui==${VERSION}" && \
    find /app/venv -depth -name __pycache__ -exec rm -rf {} + && \
    mkdir -p /usr/share/licenses/ollama && \
    find /app/venv/lib -path '*open_webui*.dist-info*' -iname 'LICENSE*' -exec cp {} /usr/share/licenses/ollama/ \; && \
    rm -rf /tmp/* /var/tmp/*

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
USER root

# The venv's python links into /opt/python, so both trees are copied together.
# UNVERIFIED: the venv symlinks are relative to /opt/python; confirm in the probe run.
COPY --from=build /opt/python /opt/python
COPY --from=build /app/venv /app/venv
COPY --from=build /usr/share/licenses/ollama /usr/share/licenses/ollama

RUN mkdir -p /config && \
    chown -R apps:apps /app /config && \
    chmod -R 755 /app

ENV PORT=8080 \
    PYTHONUNBUFFERED=1 \
    DOCKER=true \
    ENV=prod \
    SCARF_NO_ANALYTICS=true \
    DO_NOT_TRACK=true \
    ANONYMIZED_TELEMETRY=false \
    HOME=/config \
    PATH=/app/venv/bin:/opt/python/bin:$PATH

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config
