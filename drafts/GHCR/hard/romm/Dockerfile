
# Frontend build. Upstream builds the frontend on node alpine. This stage uses the glibc python-node base instead.
# UNVERIFIED: the frontend source path (frontend/) and the build output folder (dist/).
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS frontend-build

ARG VERSION
USER root

# No upstream checksum is published on the release.
# UNVERIFIED: the sha256 of this tarball must be self-computed and pinned before merge.
RUN echo "*** Fetching romm ${VERSION} source for the frontend ***" && \
  mkdir -p /src && \
  curl -fsSL -o /tmp/romm.tar.gz \
    "https://github.com/rommapp/romm/archive/refs/tags/${VERSION}.tar.gz" && \
  tar xzf /tmp/romm.tar.gz -C /src --strip-components=1 && \
  rm /tmp/romm.tar.gz && \
  cd /src/frontend && \
  npm ci --ignore-scripts --no-audit --no-fund && \
  npm run build && \
  mv dist /front-dist

# Backend build: the Python dependencies go into /app/venv, outside the runtime path that is read-only at runtime.
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d AS build

ARG VERSION
ARG UV_VERSION=0.13.4
USER root

# UNVERIFIED: build headers for the Python wheels that need them (check the uv sync output and the python base).
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# UNVERIFIED: the uv project sits at the source root (pyproject.toml and uv.lock). Confirm the layout at the tag.
RUN echo "*** Fetching romm ${VERSION} source ***" && \
  mkdir -p /src /app && \
  curl -fsSL -o /tmp/romm.tar.gz \
    "https://github.com/rommapp/romm/archive/refs/tags/${VERSION}.tar.gz" && \
  tar xzf /tmp/romm.tar.gz -C /src --strip-components=1 && \
  rm /tmp/romm.tar.gz

RUN echo "*** Installing Python dependencies with uv ***" && \
  pip install --no-cache-dir "uv==${UV_VERSION}" && \
  cd /src && \
  UV_PROJECT_ENVIRONMENT=/app/venv uv sync --frozen --no-cache && \
  cp -a /src/backend /app/backend && \
  install -Dm644 /src/LICENSE /usr/share/licenses/romm/LICENSE

# Runtime stage. The python base already runs as apps.
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
USER root

# UNVERIFIED: the apt package set (taken from the upstream Alpine runtime) and whether the python base already ships any of it.
# Valkey is not installed here. The chart uses the apps/valkey sibling instead.
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    libarchive-tools \
    libmagic1 \
    libpq5 \
    p7zip-full \
    tzdata && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

COPY --from=build /app /app
COPY --from=build /usr/share/licenses/romm /usr/share/licenses/romm
COPY --from=frontend-build /front-dist /app/frontend

RUN chown -R apps:apps /app && chmod -R 755 /app

ENV \
  HOME=/config \
  PYTHONDONTWRITEBYTECODE=1 \
  PYTHONUNBUFFERED=1 \
  PYTHONPATH=/app/backend \
  PATH=/app/venv/bin:${PATH}

USER apps
COPY --chmod=0755 . /

EXPOSE 10680

VOLUME /config
