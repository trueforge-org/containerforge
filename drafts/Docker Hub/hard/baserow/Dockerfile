
# Build stage: Python backend venv and Nuxt web frontend. Python 3.15 is a risk (upstream targets 3.14), see the PR notes.
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS build

ARG VERSION
ENV \
  UV_CACHE_DIR=/tmp/baserow_uv_cache \
  YARN_CACHE_FOLDER=/tmp/yarn \
  NODE_OPTIONS=--max-old-space-size=4096 \
  HOME=/tmp

# UNVERIFIED: the install commands below are a sketch. Check deploy/all-in-one and backend/docker at the tag for the exact
# uv and yarn steps. Also UNVERIFIED that uv is preinstalled in python-node.
RUN echo "*** Building Baserow ${VERSION} ***" && \
  mkdir -p /src /app/baserow && \
  curl -fsSL "https://github.com/baserow/baserow/archive/refs/tags/${VERSION}.tar.gz" | tar xz --strip-components=1 -C /src && \
  cd /src/backend && \
  uv venv /app/baserow/venv && \
  VIRTUAL_ENV=/app/baserow/venv uv sync --active --frozen --no-dev && \
  cp -a /src/backend /app/baserow/backend && \
  cd /src/web-frontend && \
  yarn install --frozen-lockfile && \
  yarn build && \
  cp -a /src/web-frontend /app/baserow/web-frontend && \
  mkdir -p /usr/share/licenses/baserow && \
  cp /src/LICENSE /usr/share/licenses/baserow/LICENSE && \
  rm -rf /tmp/yarn /tmp/baserow_uv_cache

# Runtime stage. Caddy comes from the sibling caddy image (binary at /app/caddy there).
# UNVERIFIED: no digest pinned for the caddy image. Pin it before merging.
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION
USER root

ENV \
  HOME=/config \
  DATA_DIR=/config \
  BASEROW_PLUGIN_DIR=/config/plugins \
  UV_CACHE_DIR=/tmp/baserow_uv_cache \
  PYTHONUNBUFFERED=1 \
  PYTHONPYCACHEPREFIX=/tmp/pycache \
  DJANGO_SETTINGS_MODULE=baserow.config.settings.base \
  XDG_DATA_HOME=/config/caddy \
  XDG_CONFIG_HOME=/tmp \
  PATH=/app/baserow/venv/bin:${PATH}

# UNVERIFIED: the apt package set is inferred from the upstream all-in-one image. Confirm the postgresql-client version matches the server.
RUN echo "*** Installing runtime packages ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    gettext \
    libpq5 \
    postgresql-client \
    supervisor \
    xmlsec1 && \
  rm -rf /var/lib/apt/lists/*

COPY --from=ghcr.io/trueforge-org/caddy:2.11.9@sha256:975fd93fee9719d4f9519c6f4640ed98144cbebde8cb2dd60ca6bb506428be4a /app/caddy /usr/local/bin/caddy
COPY --from=build /app/baserow /app/baserow
COPY --from=build /usr/share/licenses/baserow /usr/share/licenses/baserow

# Premium and enterprise code is not shipped in this image (see the bake LICENSE note).
USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config
