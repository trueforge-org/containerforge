# UNVERIFIED (plan sections 1, 3, 4): tarball layout (extracted with --strip-components=1 into /app),
# whether the tarball already contains the built frontend, and the jbig2enc package (not added yet).

ARG VERSION=3.5.1
# Pin the SHA-256 of the release tarball (self-computed, no checksum is published). Empty on purpose:
# the build fails until the value is pinned.
ARG SOURCE_SHA256=""

# Source stage: download the release tarball once and verify it.
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS source

ARG VERSION
ARG SOURCE_SHA256

USER root

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends xz-utils; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    mkdir -p /src; \
    curl -fsSL -o /tmp/paperless.tar.xz \
      "https://github.com/paperless-ngx/paperless-ngx/releases/download/v${VERSION}/paperless-ngx-v${VERSION}.tar.xz"; \
    echo "${SOURCE_SHA256}  /tmp/paperless.tar.xz" | sha256sum -c -; \
    tar -xJf /tmp/paperless.tar.xz --strip-components=1 -C /src; \
    rm -f /tmp/paperless.tar.xz

# Frontend stage: Angular build (upstream compile-frontend). Output is copied into the runtime stage.
# UNVERIFIED: output path of `ng build` (plan expects documents/static/frontend under src/).
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS frontend

USER root

COPY --from=source /src /src

ENV HOME=/tmp \
    PNPM_HOME=/tmp/pnpm

RUN set -eux; \
    corepack enable; \
    cd /src/src-ui; \
    pnpm install --frozen-lockfile; \
    ./node_modules/.bin/ng build --configuration production; \
    rm -rf /tmp/*

# Runtime stage.
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION

ENV \
    PNGX_CONTAINERIZED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_LINK_MODE=copy \
    UV_CACHE_DIR=/tmp/uv \
    PAPERLESS_DATA_DIR=/config/data \
    PAPERLESS_MEDIA_ROOT=/config/media \
    PAPERLESS_CONSUMPTION_DIR=/config/consume \
    PAPERLESS_EXPORT_DIR=/config/export \
    PAPERLESS_BIND_ADDR=0.0.0.0 \
    PAPERLESS_PORT=8000

USER root

# Runtime packages from upstream, minus gosu (USER apps replaces the s6 drop).
# UNVERIFIED: the jbig2enc .deb from paperless-ngx/builder is not installed yet (asset name and checksum not fetched).
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        curl \
        tzdata \
        fonts-liberation \
        gettext \
        ghostscript \
        gnupg \
        icc-profiles-free \
        postgresql-client \
        mariadb-client \
        tesseract-ocr \
        tesseract-ocr-eng \
        tesseract-ocr-deu \
        tesseract-ocr-fra \
        tesseract-ocr-ita \
        tesseract-ocr-spa \
        unpaper \
        pngquant \
        jbig2dec \
        libxml2 \
        libxslt1.1 \
        qpdf \
        file \
        libmagic1 \
        media-types \
        zlib1g \
        poppler-utils; \
    rm -rf /var/lib/apt/lists/*

COPY --from=source /src /app
COPY --from=frontend /src/src/documents/static/frontend /app/src/documents/static/frontend

# Python dependencies from the tarball's uv.lock (mirrors upstream). uv is removed again afterwards.
RUN set -eux; \
    pip install --no-cache-dir uv; \
    cd /app; \
    uv export --no-dev --no-hashes --no-emit-project > /tmp/requirements.txt; \
    uv pip install --system --no-cache --requirement /tmp/requirements.txt; \
    pip uninstall --yes uv; \
    rm -rf /tmp/*

# collectstatic and compilemessages need settings at build time only. Data goes to /tmp and is removed.
RUN set -eux; \
    mkdir -p /tmp/build-data /tmp/build-media; \
    cd /app/src; \
    PAPERLESS_SECRET_KEY=build-only \
    PAPERLESS_DATA_DIR=/tmp/build-data \
    PAPERLESS_MEDIA_ROOT=/tmp/build-media \
      python manage.py collectstatic --no-input; \
    PAPERLESS_SECRET_KEY=build-only \
    PAPERLESS_DATA_DIR=/tmp/build-data \
    PAPERLESS_MEDIA_ROOT=/tmp/build-media \
      python manage.py compilemessages; \
    rm -rf /tmp/*

# UNVERIFIED: LICENSE at the tarball root.
RUN set -eux; \
    mkdir -p /usr/share/licenses/paperless-ngx; \
    cp /app/LICENSE /usr/share/licenses/paperless-ngx/LICENSE; \
    chown -R root:root /app; \
    chmod -R 755 /app; \
    mkdir -p /config; \
    chown apps:apps /config

USER apps
COPY --chmod=0755 . /

EXPOSE 8000
VOLUME /config

CMD ["/start.sh"]
