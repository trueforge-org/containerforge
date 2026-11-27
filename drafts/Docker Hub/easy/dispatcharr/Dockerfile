# frontend build stage: upstream builds the frontend with node 24
# UNVERIFIED: the python-node base must ship a Node version compatible with frontend/package.json.
FROM ghcr.io/trueforge-org/python-node:3.14.8@sha256:feb6e44439ea272f47b46a1511960f58af5df8056811c83973e2edec9b18afca AS frontend

ARG VERSION
USER root

RUN \
  echo "**** fetch source for the frontend build ****" && \
  mkdir -p /tmp/src && \
  curl -fsSL "https://github.com/Dispatcharr/Dispatcharr/archive/refs/tags/${VERSION}.tar.gz" | \
    tar xz -C /tmp/src --strip-components=1

RUN \
  echo "**** build frontend ****" && \
  cd /tmp/src/frontend && \
  node --version && \
  npm_config_cache=/tmp/.npm npm install --no-audit --progress=false && \
  npm_config_cache=/tmp/.npm npm run build && \
  rm -rf /tmp/.npm

############## runtime stage ##############
FROM ghcr.io/trueforge-org/python:3.14.8@sha256:f099b700b824b7760cb846418f84a2c14c2f04992320506ab3ca5b79d3ac1232

# set version label
ARG VERSION
USER root

# UNVERIFIED: check the base PATH before relying on this override.
# DISPATCHARR_ENV is baked to modular because the aio mode needs root and writes /etc.
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    DISPATCHARR_ENV=modular \
    DJANGO_SETTINGS_MODULE=dispatcharr.settings \
    PATH=/app/venv/bin:$PATH

RUN \
  echo "**** install runtime and build packages ****" && \
  apt-get update && \
  # UNVERIFIED: ffmpeg from Ubuntu replaces the upstream ghcr.io/dispatcharr/ffmpeg build; no version pins.
  apt-get install -y --no-install-recommends \
    nginx \
    libpcre2-8-0 \
    libopenblas0 \
    procps \
    jq \
    ffmpeg \
    vlc-bin \
    vlc-plugin-base \
    postgresql-client \
    build-essential \
    libpcre2-dev \
    libpq-dev \
    libxml2-dev \
    libxslt1-dev \
    libjpeg-dev \
    zlib1g-dev \
    gfortran \
    libopenblas-dev \
    ninja-build

RUN \
  echo "**** fetch dispatcharr source into /app ****" && \
  curl -fsSL "https://github.com/Dispatcharr/Dispatcharr/archive/refs/tags/${VERSION}.tar.gz" | \
    tar xz -C /app --strip-components=1 && \
  rm -rf /app/frontend && \
  mkdir -p /app/frontend

COPY --from=frontend /tmp/src/frontend/dist /app/frontend/dist

RUN \
  echo "**** install python dependencies into /app/venv ****" && \
  cd /app && \
  /app/venv/bin/pip install --no-cache-dir uv && \
  UV_CACHE_DIR=/tmp/uv-cache \
  UV_PROJECT_ENVIRONMENT=/app/venv \
    /app/venv/bin/uv sync --no-install-project --no-dev --python /app/venv/bin/python && \
  /app/venv/bin/pip uninstall -y uv

RUN \
  echo "**** rootless path changes ****" && \
  sed -i \
    -e 's|^socket = /app/uwsgi.sock|socket = /tmp/uwsgi.sock|' \
    -e 's|^virtualenv = /dispatcharrpy|virtualenv = /app/venv|' \
    /app/docker/uwsgi.modular.ini && \
  grep -q '^socket = /tmp/uwsgi.sock' /app/docker/uwsgi.modular.ini && \
  grep -q '^virtualenv = /app/venv' /app/docker/uwsgi.modular.ini && \
  sed -i 's|unix:/app/uwsgi.sock|unix:/tmp/uwsgi.sock|g' /app/docker/nginx.conf && \
  grep -q 'unix:/tmp/uwsgi.sock' /app/docker/nginx.conf
# UNVERIFIED: check `grep -rn "/dispatcharrpy\|/app/uwsgi.sock" /app` for any other references.

RUN \
  echo "**** point /data at persistent /config ****" && \
  rm -rf /data && \
  ln -s /config /data

RUN \
  echo "**** collect static files at build time ****" && \
  cd /app && \
  DJANGO_SECRET_KEY=build /app/venv/bin/python manage.py collectstatic --noinput
# UNVERIFIED: collectstatic is assumed to need no database or Redis. If it does, move it to start.sh.

RUN \
  echo "**** add license and fix permissions ****" && \
  mkdir -p /usr/share/licenses/dispatcharr && \
  cp /app/LICENSE /usr/share/licenses/dispatcharr/ && \
  mkdir -p /app/media && \
  chown -R apps:apps /app && \
  chmod -R 755 /app && \
  echo "**** cleanup ****" && \
  apt-get purge -y --auto-remove \
    build-essential \
    libpcre2-dev \
    libpq-dev \
    libxml2-dev \
    libxslt1-dev \
    libjpeg-dev \
    zlib1g-dev \
    gfortran \
    libopenblas-dev \
    ninja-build && \
  apt-get autoremove -y && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /root/.cache

# add local files
USER apps
COPY --chmod=0755 . /

WORKDIR /app

# ports and volumes
EXPOSE 9191

VOLUME /config
