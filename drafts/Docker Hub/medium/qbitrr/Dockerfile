# Stage 1: build the web UI (upstream stage "webui-build")
# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS webui

ARG VERSION

WORKDIR /src
# UNVERIFIED: the source archive has no published checksum. Pin the tag's commit SHA at review.
RUN curl -fsSL -o /tmp/qbitrr.tar.gz "https://github.com/Feramance/qBitrr/archive/refs/tags/v${VERSION}.tar.gz" \
    && tar -xzf /tmp/qbitrr.tar.gz --strip-components=1 -C /src \
    && rm -f /tmp/qbitrr.tar.gz \
    && cd /src/webui \
    && npm ci \
    && npm run build \
    && rm -rf /root/.npm /tmp/*

# Stage 2: runtime
# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION

ENV QBITRR_DOCKER_RUNNING=69420 \
    QBITRR_SOURCE_BUILD=0 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONOPTIMIZE=1

USER root
WORKDIR /src

# Build and install the package into the base venv (/app/venv) at build time. Runtime never writes to /app.
COPY --from=webui /src /src
RUN cd /src \
    && /app/venv/bin/pip install --no-cache-dir ".[fast]" \
    && cd / \
    && rm -rf /src /tmp/* /root/.cache

COPY --chmod=0755 start.sh /start.sh

USER apps
COPY --chmod=0755 . /
WORKDIR /config

EXPOSE 6969
VOLUME /config

CMD ["/start.sh"]
