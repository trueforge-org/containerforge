FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
USER root

ENV \
  HOME=/tmp \
  FLASK_APP=emby-sync.py \
  DATABASE_URL=sqlite:////config/app.db

# UNVERIFIED: upstream pins Python 3.7 era packages (Flask 1.1.2, SQLAlchemy 1.3.18,
# MarkupSafe 1.1.1). If requirements.txt does not resolve on Python 3.15, fall back to
# unpinned names with major-version constraints and fix the code the run test exposes.
RUN echo "*** Installing emby-sync ***" && \
  mkdir -p /app/emby-sync /usr/share/licenses/emby-sync && \
  curl -o \
    /tmp/emby-sync.tar.gz -L \
    "https://github.com/cameronurnes/emby-sync/archive/${VERSION}.tar.gz" && \
  tar xzf \
    /tmp/emby-sync.tar.gz -C \
    /app/emby-sync --strip-components=1 && \
  /app/venv/bin/pip install --no-cache-dir \
    -r /app/emby-sync/requirements.txt gunicorn && \
  cp /app/emby-sync/LICENSE /usr/share/licenses/emby-sync/LICENSE && \
  echo "*** Cleaning Up ***" && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

WORKDIR /app/emby-sync

EXPOSE 5000

VOLUME /config
