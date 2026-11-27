FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION

# UNVERIFIED: the chromium profile and crash-report location under HOME (upstream used /app).
ENV \
    HOME=/config \
    PIP_CACHE_DIR=/tmp/pip \
    PYTHONDONTWRITEBYTECODE=1

USER root

# UNVERIFIED: chromium and chromium-driver from the base's apt archive. Upstream uses Debian's packages,
# and Ubuntu ships chromium as a snap. Check `apt-cache policy chromium chromium-driver` before building.
# xvfb and xauth are needed by xvfbwrapper when HEADLESS is false (UNVERIFIED need).
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        chromium \
        chromium-driver \
        dumb-init \
        procps \
        xauth \
        xvfb; \
    rm -rf /var/lib/apt/lists/*

# Source build from the release tag. Upstream publishes no arm64 asset, so both arches build from source.
# UNVERIFIED: archive URL pattern and extracted directory name for the v-prefixed tag.
RUN set -eux; \
    mkdir -p /app; \
    curl -fsSL -o /tmp/flaresolverr.tar.gz \
      "https://github.com/FlareSolverr/FlareSolverr/archive/refs/tags/v${VERSION}.tar.gz"; \
    tar -xzf /tmp/flaresolverr.tar.gz -C /tmp; \
    mv "/tmp/FlareSolverr-${VERSION}" /app/flaresolverr; \
    rm -f /tmp/flaresolverr.tar.gz

# Build-time venv inside /app (not the base's /app/venv). Runtime only reads it.
# UNVERIFIED: Python 3.15 (upstream uses 3.11). selenium and undetected-chromedriver compatibility is untested.
RUN set -eux; \
    /usr/local/bin/python -m venv /app/flaresolverr/venv; \
    /app/flaresolverr/venv/bin/pip install --no-cache-dir -r /app/flaresolverr/requirements.txt; \
    mkdir -p /usr/share/licenses/flaresolverr; \
    cp /app/flaresolverr/LICENSE /usr/share/licenses/flaresolverr/LICENSE; \
    mkdir -p /config; \
    chown apps:apps /config; \
    chown -R apps:apps /app; \
    chmod -R 755 /app; \
    rm -rf /tmp/* /root/.cache

USER apps
COPY --chmod=0755 . /

WORKDIR /app/flaresolverr
EXPOSE 8191
VOLUME /config

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/start.sh"]
