FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
ARG VENDOR

USER root

# Install the release wheel into the base venv at /app/venv.
# UNVERIFIED: no checksum asset is published upstream; this gap is recorded in the PR.
# UNVERIFIED: the wheel's Requires-Python against Python 3.15.2 is not checked.
RUN set -eux; \
    curl -fsSL -o /tmp/gphotos_sync.whl \
        "https://github.com/gilesknap/gphotos-sync/releases/download/${VERSION}/gphotos_sync-${VERSION}-py3-none-any.whl"; \
    /app/venv/bin/pip install --no-cache-dir /tmp/gphotos_sync.whl; \
    DIST_INFO="$(find /app/venv/lib -maxdepth 4 -type d -name 'gphotos_sync-*.dist-info' | head -n 1)"; \
    mkdir -p /usr/share/licenses/googlephotossync; \
    find "${DIST_INFO}" -maxdepth 2 -type f -iname 'LICENSE*' -exec cp {} /usr/share/licenses/googlephotossync/ \; ; \
    chown -R apps:apps /app/venv; \
    chmod -R 755 /app/venv; \
    rm -f /tmp/gphotos_sync.whl

USER apps
COPY --chmod=0755 . /

ENV PATH=/app/venv/bin:$PATH \
    HOME=/config

ENTRYPOINT ["/start.sh"]
CMD ["--version"]

VOLUME /config
