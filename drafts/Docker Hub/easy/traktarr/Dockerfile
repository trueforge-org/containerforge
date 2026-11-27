FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    HOME=/tmp \
    TRAKTARR_CONFIG=/config/config.json \
    TRAKTARR_CACHEFILE=/config/cache.db \
    TRAKTARR_LOGFILE=/config/traktarr.log

USER root

# Tagged source archive (pure Python, GitHub publishes no checksum, so the tag is the pin).
# UNVERIFIED on Python 3.15: the pins date from 2018-2020. attrdict 2.0.x imports collections.Mapping,
# which was removed in Python 3.10, so it is swapped for attrdict3 (same module name, maintained).
# If the build or --help fails, relax the other pins one at a time and comment each change here.
RUN mkdir -p /app/traktarr /usr/share/licenses/traktarr && \
    curl -fsSL -o /tmp/traktarr.tar.gz "https://github.com/l3uddz/traktarr/archive/refs/tags/${VERSION}.tar.gz" && \
    tar xzf /tmp/traktarr.tar.gz -C /app/traktarr --strip-components=1 && \
    cp /app/traktarr/LICENSE.md /usr/share/licenses/traktarr/LICENSE.md && \
    sed -i 's/^attrdict==.*/attrdict3/' /app/traktarr/requirements.txt && \
    /app/venv/bin/pip install --no-cache-dir -r /app/traktarr/requirements.txt && \
    chown -R root:root /app/traktarr && chmod -R a+rX /app/traktarr && \
    rm -rf /root/.cache /tmp/*

USER apps
COPY --chmod=0755 . /

WORKDIR /config

VOLUME /config
