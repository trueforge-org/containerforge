FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
ARG COMMIT
USER root

ENV \
  HOME=/config \
  TZ=Etc/UTC \
  PYTHONUNBUFFERED=1

# mediainfo is needed by pymediainfo. ffmpeg from the draft is not used by the code.
RUN echo "**** install mediainfo ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    mediainfo && \
  rm -rf /var/lib/apt/lists/*

# Upstream is pinned by commit (its 23.02.02 version file). Requirements are unpinned upstream.
# UNVERIFIED: tmdbv3api 1.10.0 from PyPI is assumed API-identical to the git HEAD the upstream image installs.
RUN echo "**** install plex-utills ****" && \
  mkdir -p /app/plex-utills && \
  curl -fsSL -o /tmp/plex-utills.tar.gz \
    "https://github.com/jkirkcaldy/plex-utills/archive/${COMMIT}.tar.gz" && \
  tar xzf /tmp/plex-utills.tar.gz -C /app/plex-utills --strip-components=1 && \
  grep -qx "${VERSION}" /app/plex-utills/version && \
  pip install --no-cache-dir \
    -r /app/plex-utills/requirements.txt \
    tmdbv3api==1.10.0 \
    tzlocal && \
  cd /app/plex-utills && \
  sed -i 's#"poster.png"#"/tmp/poster.png"#; s#app/support\.zip#/tmp/support.zip#g' app/api.py && \
  sed -i "s#'tmdb_poster_restore\.png'#'/tmp/tmdb_poster_restore.png'#g" app/scripts.py && \
  grep -q '"/tmp/poster.png"' app/api.py && \
  grep -q "'/tmp/tmdb_poster_restore.png'" app/scripts.py && \
  rm -rf app/static/img/tmp && \
  ln -s /tmp/pu-img-tmp app/static/img/tmp && \
  ln -s /config/logs /logs && \
  mkdir -p /usr/share/licenses/plex-utills && \
  cp /app/plex-utills/LICENSE /usr/share/licenses/plex-utills/LICENSE && \
  chown -R root:root /app/plex-utills && \
  chmod -R a+rX,go-w /app/plex-utills && \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

WORKDIR /app/plex-utills

EXPOSE 5000

VOLUME /config
