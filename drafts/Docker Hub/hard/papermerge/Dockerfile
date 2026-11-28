# UNVERIFIED throughout: the 3.5.3 tag layout (docker/standard/bundles/nginx/nginx.default.conf, the
# auth-server extras -E pg, the roco-free runtime config format) and Python 3.15 compatibility of poetry.lock
# (resolved for 3.13) must be confirmed on the first build.

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS ui

ARG VERSION
ARG AUTH_SERVER_VERSION
USER root
ENV HOME=/tmp

# Node 26 comes with the ubuntu base (upstream uses Node 20/25); yarn is pinned through corepack.
RUN echo "*** Fetching papermerge-core ${VERSION} ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends ca-certificates curl && \
  rm -rf /var/lib/apt/lists/* && \
  mkdir -p /src/core /src/auth && \
  curl -fsSL -o /tmp/core.tar.gz "https://github.com/papermerge/papermerge-core/archive/refs/tags/${VERSION}.tar.gz" && \
  tar xzf /tmp/core.tar.gz -C /src/core --strip-components=1 && \
  curl -fsSL -o /tmp/auth.tar.gz "https://github.com/papermerge/auth-server/archive/refs/tags/${AUTH_SERVER_VERSION}.tar.gz" && \
  tar xzf /tmp/auth.tar.gz -C /src/auth --strip-components=1 && \
  rm -f /tmp/core.tar.gz /tmp/auth.tar.gz

RUN echo "*** Building core UI ***" && \
  cd /src/core/frontend && \
  corepack enable && \
  yarn set version 4.9.2 && \
  yarn install --immutable && \
  yarn workspace ui build

RUN echo "*** Building auth-server UI ***" && \
  cd /src/auth/ui2 && \
  corepack enable && \
  yarn install && \
  yarn build

FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
ARG AUTH_SERVER_VERSION
USER root

ENV \
  HOME=/tmp \
  TMPDIR=/tmp \
  PYTHONDONTWRITEBYTECODE=1 \
  POETRY_CACHE_DIR=/tmp/poetry \
  PIP_CACHE_DIR=/tmp/pip \
  PAPERMERGE__DATABASE__URL=sqlite:////config/db/db.sqlite3 \
  PAPERMERGE__MAIN__MEDIA_ROOT=/config/media \
  PAPERMERGE__MAIN__API_PREFIX="" \
  PAPERMERGE__OCR__LANG_CODES=deu,eng,ron \
  PAPERMERGE__OCR__DEFAULT_LANG_CODE=deu \
  PAPERMERGE__OCR__AUTOMATIC=false

RUN echo "*** Installing runtime dependencies ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    imagemagick \
    libmagic1 \
    libpq5 \
    nginx \
    poppler-utils && \
  rm -rf /var/lib/apt/lists/*

# Copy the built sources. The core tree comes from the UI stage, which already downloaded it.
COPY --from=ui /src/core /app/papermerge-core
COPY --from=ui /src/auth /app/auth_server_app
COPY --from=ui /src/core/frontend/apps/ui/dist /usr/share/nginx/html/ui
COPY --from=ui /src/auth/ui2/dist /usr/share/nginx/html/auth_server

# Core and auth-server each get their own venv. The base venv is read-only at runtime, so install at build time only.
# --no-root is not used for core, because paper-cli comes from the root project itself.
RUN echo "*** Installing Python dependencies ***" && \
  python3 -m venv /tmp/poetry-venv && \
  /tmp/poetry-venv/bin/pip install --no-cache-dir poetry==2.0.1 && \
  cd /app/papermerge-core && \
  VIRTUAL_ENV=/app/venv POETRY_VIRTUALENVS_CREATE=false \
    /tmp/poetry-venv/bin/poetry install -E pg -E cloud && \
  python3 -m venv /app/auth-venv && \
  cd /app/auth_server_app && \
  VIRTUAL_ENV=/app/auth-venv POETRY_VIRTUALENVS_CREATE=false \
    /tmp/poetry-venv/bin/poetry install -E pg && \
  rm -rf /tmp/poetry-venv /tmp/poetry /tmp/pip

# nginx runs as apps, so drop the user directive and move every temp and pid path into /tmp.
# The patterns depend on the upstream file, so grep fails the build if they are missing.
RUN echo "*** Configuring nginx ***" && \
  NGINX_SRC=/app/papermerge-core/docker/standard/bundles/nginx/nginx.default.conf && \
  grep -q '^http {' "${NGINX_SRC}" && \
  mkdir -p /app/nginx && \
  sed \
    -e '/^user /d' \
    -e '1i pid /tmp/nginx/nginx.pid; error_log stderr;' \
    -e '/^http {/a client_body_temp_path /tmp/nginx/client; proxy_temp_path /tmp/nginx/proxy; fastcgi_temp_path /tmp/nginx/fastcgi; uwsgi_temp_path /tmp/nginx/uwsgi; scgi_temp_path /tmp/nginx/scgi;' \
    -e 's/listen 80;/listen 8080;/' \
    -e 's/listen \[::\]:80;/listen [::]:8080;/' \
    -e '/listen 8080;/a location = /papermerge-runtime-config.js { alias /tmp/runtime/papermerge-runtime-config.js; }' \
    "${NGINX_SRC}" > /app/nginx/nginx.conf && \
  sed -i 's#</head>#<script type="module" src="/papermerge-runtime-config.js"></script></head>#' \
    /usr/share/nginx/html/ui/index.html \
    /usr/share/nginx/html/auth_server/index.html

RUN echo "*** Collecting licenses ***" && \
  mkdir -p /usr/share/licenses/papermerge && \
  cp /app/papermerge-core/LICENSE /usr/share/licenses/papermerge/LICENSE && \
  cp /app/auth_server_app/LICENSE /usr/share/licenses/papermerge/LICENSE-auth-server && \
  chown -R root:root /app /usr/share/nginx && chmod -R a+rX /app /usr/share/nginx

USER apps
COPY --chmod=0755 . /

WORKDIR /app/papermerge-core
EXPOSE 8080
VOLUME /config

CMD [""]
