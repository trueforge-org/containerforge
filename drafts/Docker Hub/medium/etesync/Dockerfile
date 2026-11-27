FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION

ENV HOME=/tmp \
    DJANGO_STATIC_ROOT=/app/static \
    DJANGO_MEDIA_ROOT=/config/media \
    ETEBASE_DB_PATH=/config/db.sqlite3 \
    ETEBASE_EASY_CONFIG_PATH=/tmp/etebase-server.ini

USER root

# Build tools are installed only to compile wheels that have no Python 3.15 build (UNVERIFIED), and purged in the same layer.
# The source is the upstream tag archive; the requirements are the pinned requirements.txt.
RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential libffi-dev libssl-dev \
    && mkdir -p /app/etesync /usr/share/licenses/etesync \
    && curl -fsSL -o /tmp/etesync.tar.gz "https://github.com/etesync/server/archive/refs/tags/v${VERSION}.tar.gz" \
    && tar -xzf /tmp/etesync.tar.gz -C /app/etesync --strip-components=1 \
    && rm -f /tmp/etesync.tar.gz \
    && /app/venv/bin/pip install --no-cache-dir -r /app/etesync/requirements.txt psycopg2-binary \
    && DJANGO_STATIC_ROOT=/app/static /app/venv/bin/python /app/etesync/manage.py collectstatic --no-input \
    && rm -f /app/etesync/secret.txt \
    && cp /app/etesync/LICENSE /usr/share/licenses/etesync/LICENSE \
    && apt-get purge -y --auto-remove build-essential libffi-dev libssl-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && chown -R root:root /app /usr/share/licenses/etesync \
    && chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

WORKDIR /app/etesync
EXPOSE 8000
VOLUME /config
