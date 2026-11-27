FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
# UNVERIFIED: no upstream checksum. Record the SHA-256 of the v${VERSION} tag archive here.
# Left without a default on purpose so the build fails until it is recorded.
ARG CALENDARR_SHA256

USER root

# Source comes from the tag archive. The footer templates are copied from ./calendarr/custom_footers
# in the archive (upstream Dockerfile path), so start.sh can seed /config on first run.
RUN set -eux; \
    mkdir -p /tmp/calendarr-src /defaults/custom_footers; \
    curl -fsSL -o /tmp/calendarr.tar.gz \
      "https://github.com/jordanlambrecht/calendarr/archive/refs/tags/v${VERSION}.tar.gz"; \
    echo "${CALENDARR_SHA256}  /tmp/calendarr.tar.gz" | sha256sum -c -; \
    tar xf /tmp/calendarr.tar.gz -C /tmp/calendarr-src --strip-components=1; \
    PIP_CACHE_DIR=/tmp/pip-cache /app/venv/bin/pip install --no-cache-dir -r /tmp/calendarr-src/requirements.txt; \
    mkdir -p /app/src; \
    cp -r /tmp/calendarr-src/src/. /app/src/; \
    cp /tmp/calendarr-src/calendarr/custom_footers/*.md /defaults/custom_footers/; \
    ln -s /config/custom_footers /app/custom_footers; \
    chown -R root:root /app/src /defaults; \
    chmod -R 755 /app/src /defaults; \
    rm -rf /tmp/calendarr.tar.gz /tmp/calendarr-src /tmp/pip-cache

ENV PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app/src \
    LOG_DIR=/config/logs \
    LOG_FILE=calendarr.log

COPY --chmod=0755 start.sh /start.sh

USER apps
COPY --chmod=0755 . /

WORKDIR /app
EXPOSE 5000
VOLUME /config

CMD ["/start.sh"]
