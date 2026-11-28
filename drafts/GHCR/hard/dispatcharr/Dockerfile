# Unresolved (see plan.md "Fix attempt"): not built or run; the upstream log collector, comskip,
# the custom Dispatcharr ffmpeg build and the USE_LEGACY_NUMPY switch are not carried over.
FROM ghcr.io/trueforge-org/python-node:3.13.13@sha256:c636840e852b6d2be7a303bf85c88bfdbb4477932eeff7becabca1f50cf8cdf2

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config \
  PYTHONUNBUFFERED=1 \
  PYTHONDONTWRITEBYTECODE=1 \
  DJANGO_SETTINGS_MODULE=dispatcharr.settings \
  PATH=/app/venv/bin:$PATH \
  XDG_CACHE_HOME=/tmp/.cache \
  HF_HOME=/tmp/huggingface

RUN echo "*** Installing runtime dependencies ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ffmpeg \
    nginx \
    libpcre2-8-0 \
    procps \
    jq \
    vlc-bin \
    vlc-plugin-base && \
  echo "*** Installing Dispatcharr ***" && \
  curl -fL -o /tmp/dispatcharr.tar.gz \
    "https://github.com/Dispatcharr/Dispatcharr/archive/refs/tags/v${VERSION}.tar.gz" && \
  tar xzf /tmp/dispatcharr.tar.gz -C /app --strip-components=1 && \
  rm -f /tmp/dispatcharr.tar.gz && \
  echo "*** Installing Python dependencies ***" && \
  apt-get install -y --no-install-recommends build-essential libpcre2-dev && \
  python -c "import tomllib; print('\n'.join(tomllib.load(open('/app/pyproject.toml','rb'))['project']['dependencies']))" > /tmp/requirements.txt && \
  /app/venv/bin/pip install --no-cache-dir \
    --extra-index-url https://download.pytorch.org/whl/cpu \
    -r /tmp/requirements.txt && \
  echo "*** Building frontend ***" && \
  cd /app/frontend && \
  npm install --no-audit --progress=false && \
  npm run build && \
  rm -rf node_modules .cache /root/.npm && \
  echo "*** Collecting static files ***" && \
  mkdir -p /app/media /app/static && \
  cd /app && \
  DJANGO_SECRET_KEY=build-time-only python manage.py collectstatic --noinput && \
  echo "*** Preparing nginx and uwsgi config ***" && \
  mkdir -p /etc/dispatcharr /usr/share/licenses/dispatcharr && \
  sed \
    -e 's#unix:/app/uwsgi.sock#unix:/tmp/uwsgi.sock#g' \
    -e 's#include uwsgi_params;#include /etc/nginx/uwsgi_params;#g' \
    /app/docker/nginx.conf > /etc/dispatcharr/site.conf && \
  sed \
    -e '/^attach-daemon = redis-server/d' \
    -e 's#/app/uwsgi.sock#/tmp/uwsgi.sock#g' \
    -e 's#^virtualenv = /dispatcharrpy#virtualenv = /app/venv#' \
    /app/docker/uwsgi.ini > /etc/dispatcharr/uwsgi.ini && \
  cp /app/LICENSE /usr/share/licenses/dispatcharr/LICENSE && \
  mkdir -p /data /config && \
  chown -R apps:apps /app /data /config && \
  echo "*** Cleaning Up ***" && \
  apt-get purge -y --auto-remove build-essential libpcre2-dev && \
  apt-get clean && \
  rm -rf /tmp/* /var/lib/apt/lists/* /root/.cache /root/.npm

USER apps
COPY --chmod=0755 . /

EXPOSE 9191

# /data is hardcoded in the upstream code (uploads, logos, recordings, plugins), so it is the data volume.
VOLUME /data
VOLUME /config
