
# Frontend build (Node) and source fetch. Node comes from the python-node base, which is only used in this stage.
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS frontend

ARG VERSION
USER root

ENV \
  HOME=/tmp \
  NPM_CONFIG_CACHE=/tmp/npm

RUN echo "*** Fetching linkding ${VERSION} ***" && \
  curl -fsL -o /tmp/linkding.tar.gz \
    "https://github.com/sissbruecker/linkding/archive/refs/tags/v${VERSION}.tar.gz" && \
  mkdir -p /build/linkding && \
  tar xzf /tmp/linkding.tar.gz -C /build/linkding --strip-components=1 && \
  rm /tmp/linkding.tar.gz

WORKDIR /build/linkding
RUN npm ci && \
  npm run build && \
  rm -rf node_modules

# Python dependencies in a project venv inside /app/linkding (the base /app/venv is never touched).
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d AS builder

USER root

ENV \
  HOME=/tmp \
  UV_CACHE_DIR=/tmp/uv

# UNVERIFIED: base may already ship uv. Version is upstream's installer pin (uv 0.8.13).
RUN pip install --no-cache-dir uv==0.8.13

COPY --from=frontend /build/linkding /app/linkding

WORKDIR /app/linkding
# UNVERIFIED: upstream also syncs the postgres group, which is not built here. Python 3.15 support is unverified.
RUN uv sync --frozen --no-dev && \
  mkdir -p data && \
  ./.venv/bin/python manage.py collectstatic --noinput && \
  rm -rf data && \
  ln -s /config/data data && \
  rm -rf /tmp/uv

# UNVERIFIED: upstream compiles libicu.so for SQLite ICU collation (compile-icu stage). Not ported yet.

FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
USER root

ENV \
  HOME=/config \
  VIRTUAL_ENV=/app/linkding/.venv \
  PATH=/app/linkding/.venv/bin:$PATH \
  UWSGI_MAX_FD=4096

COPY --from=builder /app/linkding /app/linkding

RUN mkdir -p /usr/share/licenses/linkding && \
  cp /app/linkding/LICENSE /usr/share/licenses/linkding/LICENSE && \
  chown -R apps:apps /app/linkding && \
  chmod -R 755 /app/linkding

USER apps
COPY --chmod=0755 . /

WORKDIR /app/linkding

EXPOSE 9090

VOLUME /config
