# Static stage: npm builds the web assets; only app/static is kept.
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS static

ARG VERSION
USER root

ENV npm_config_cache=/tmp/npm-cache

RUN \
  echo "**** fetch source code ****" && \
  mkdir -p /tmp/src && \
  curl -fL -o /tmp/wizarr.tar.gz \
    "https://github.com/Wizarrrr/wizarr/archive/refs/tags/v${VERSION}.tar.gz" && \
  tar xzf /tmp/wizarr.tar.gz -C /tmp/src --strip-components=1 && \
  echo "**** build static assets ****" && \
  npm --prefix /tmp/src/app/static/ ci && \
  DOCKER_BUILD=true npm --prefix /tmp/src/app/static/ run build && \
  rm -rf /tmp/src/app/static/node_modules /tmp/wizarr.tar.gz /tmp/npm-cache

# Backend stage: Python venv, translations and source, built on the python base.
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d AS backend

ARG VERSION
USER root

# uv pinned to the same version and digest as apps/flexget
COPY --from=ghcr.io/astral-sh/uv:0.13.10@sha256:a3ea1357342c1a4bf9a0c53a3deb1b55379aefa037338d8113d5771efa01774f /uv /usr/local/bin/uv

ENV UV_LINK_MODE=copy \
    UV_COMPILE_BYTECODE=1 \
    UV_CACHE_DIR=/tmp/uv-cache \
    UV_PYTHON_DOWNLOADS=never \
    UV_PROJECT_ENVIRONMENT=/app/wizarr/.venv

RUN \
  echo "**** fetch source code ****" && \
  # UNVERIFIED: requires-python at this tag vs the 3.15 base (upstream builds on 3.13)
  mkdir -p /app/wizarr && \
  curl -fL -o /tmp/wizarr.tar.gz \
    "https://github.com/Wizarrrr/wizarr/archive/refs/tags/v${VERSION}.tar.gz" && \
  tar xzf /tmp/wizarr.tar.gz -C /app/wizarr --strip-components=1 && \
  echo "**** install python dependencies ****" && \
  cd /app/wizarr && \
  uv sync --frozen --no-dev --no-install-project && \
  uv sync --frozen --no-dev && \
  echo "**** compile translations ****" && \
  uv run --frozen --no-dev pybabel compile --use-fuzzy -d app/translations && \
  echo "**** license and default wizard steps ****" && \
  install -D /app/wizarr/LICENSE /usr/share/licenses/wizarr/LICENSE && \
  mkdir -p /opt/default_wizard_steps && \
  cp -r /app/wizarr/wizard_steps/. /opt/default_wizard_steps/ && \
  echo "**** cleanup ****" && \
  rm -rf /tmp/*

# bring in the built static assets from the static stage
COPY --from=static /tmp/src/app/static/ /app/wizarr/app/static/

# Final stage: runtime only.
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ENV HOST=0.0.0.0 \
    PORT=5690 \
    FLASK_ENV=production \
    APP_VERSION=${VERSION} \
    PYTHONDONTWRITEBYTECODE=1 \
    XDG_CACHE_HOME=/tmp

# add wizarr, default wizard steps and license
COPY --from=backend /app/wizarr /app/wizarr
COPY --from=backend /opt/default_wizard_steps /opt/default_wizard_steps
COPY --from=backend /usr/share/licenses/wizarr /usr/share/licenses/wizarr

# upstream writes the SQLite database under /data/database; point /data at /config/data
# UNVERIFIED: the app's database path (plan section 10); confirm before merging
RUN \
  ln -s /config/data /data

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 5690
VOLUME /config

WORKDIR /config
