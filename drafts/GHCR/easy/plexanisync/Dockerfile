FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
USER root

ENV PYTHONUNBUFFERED=1 \
    INTERVAL=3600 \
    PLEX_SECTION=Anime

# Pure Python, so one tag archive serves every architecture.
# UNVERIFIED: the tag archive URL is the standard GitHub form and was not fetched.
# UNVERIFIED: the LICENSE path at the tag. Upstream publishes no checksum for the
# archive, so it is not verified. Pinning the tag commit SHA is an open question.
# Dependencies go into the base image's /app/venv at build time, never at runtime.
RUN set -eux; \
    src=/tmp/plexanisync-src; \
    mkdir -p "${src}" /app/plexanisync /usr/share/licenses/plexanisync; \
    curl -fsSL -o /tmp/plexanisync.tar.gz "https://github.com/RickDB/PlexAniSync/archive/refs/tags/v${VERSION}.tar.gz"; \
    tar -xzf /tmp/plexanisync.tar.gz -C "${src}" --strip-components=1; \
    /app/venv/bin/pip install --no-cache-dir -r "${src}/requirements.txt"; \
    cp "${src}/PlexAniSync.py" "${src}/custom_mappings_schema.json" /app/plexanisync/; \
    cp -r "${src}/plexanisync" /app/plexanisync/; \
    cp "${src}/LICENSE" /usr/share/licenses/plexanisync/LICENSE; \
    chown -R apps:apps /app; \
    chmod -R 755 /app; \
    rm -rf /tmp/plexanisync.tar.gz "${src}"

USER apps
COPY --chmod=0755 . /

VOLUME /config
