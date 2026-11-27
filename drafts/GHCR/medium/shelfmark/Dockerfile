# Frontend stage: Node builds the static UI; only the dist folder is kept.
# UNVERIFIED: frontend source path (src/frontend) and dist output at this tag.
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS frontend

ARG VERSION
USER root

ENV NPM_CONFIG_CACHE=/tmp/npm

RUN \
  echo "**** fetch source code ****" && \
  mkdir -p /tmp/src && \
  curl -fL -o /tmp/shelfmark.tar.gz \
    "https://github.com/calibrain/shelfmark/archive/refs/tags/${VERSION}.tar.gz" && \
  tar xzf /tmp/shelfmark.tar.gz -C /tmp/src --strip-components=1 && \
  echo "**** build frontend ****" && \
  cd /tmp/src/src/frontend && \
  npm ci --no-audit && \
  npm run build && \
  mv dist /tmp/frontend-dist && \
  rm -rf /tmp/src /tmp/shelfmark.tar.gz /tmp/npm

# Backend stage: Python dependencies in a uv-managed venv under the source tree.
# UNVERIFIED: the Python package is at the repo root (not under src/) at this tag.
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d AS backend

ARG VERSION
USER root

# uv pinned to the same version and digest as apps/flexget
COPY --from=ghcr.io/astral-sh/uv:0.13.10@sha256:a3ea1357342c1a4bf9a0c53a3deb1b55379aefa037338d8113d5771efa01774f /uv /usr/local/bin/uv

ENV UV_LINK_MODE=copy \
    UV_CACHE_DIR=/tmp/uv-cache \
    UV_PYTHON_DOWNLOADS=never

RUN \
  echo "**** fetch source code ****" && \
  mkdir -p /app/shelfmark && \
  curl -fL -o /tmp/shelfmark.tar.gz \
    "https://github.com/calibrain/shelfmark/archive/refs/tags/${VERSION}.tar.gz" && \
  tar xzf /tmp/shelfmark.tar.gz -C /app/shelfmark --strip-components=1 && \
  echo "**** install python dependencies (lite: no browser extra) ****" && \
  # UNVERIFIED: requires-python at this tag vs the 3.15 base (plan R1)
  cd /app/shelfmark && \
  uv sync --locked --no-default-groups && \
  echo "**** license ****" && \
  install -D /app/shelfmark/LICENSE /usr/share/licenses/shelfmark/LICENSE && \
  echo "**** cleanup ****" && \
  # upstream removes src/ after the frontend build; the frontend is copied in the final stage
  rm -rf \
    /app/shelfmark/src \
    /tmp/* \
    /tmp/uv-cache

# Final stage: runtime only, no compilers and no Node.
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ENV PATH=/app/shelfmark/.venv/bin:$PATH \
    PYTHONPATH=/app/shelfmark \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONIOENCODING=UTF-8 \
    DOCKERMODE=true \
    FLASK_PORT=8084 \
    INGEST_DIR=/books \
    XDG_CACHE_HOME=/tmp

# add shelfmark, venv, frontend and license
COPY --from=backend /app/shelfmark /app/shelfmark
COPY --from=frontend /tmp/frontend-dist /app/shelfmark/frontend-dist
COPY --from=backend /usr/share/licenses/shelfmark /usr/share/licenses/shelfmark

RUN \
  echo "**** create runtime folders ****" && \
  mkdir -p /books /var/log/shelfmark && \
  chown apps:apps /books /var/log/shelfmark

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 8084
VOLUME /config

WORKDIR /config
