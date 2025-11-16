
FROM ghcr.io/trueforge-org/ubuntu:24.4

# set version label
ARG VERSION

ENV PYTHONUNBUFFERED=1

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    build-base \
    cargo \
    curl-dev \
    jpeg-dev \
    libffi-dev \
    mariadb-dev \
    musl-dev \
    postgresql-dev \
    python3-dev \
    zlib-dev && \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    grep \
    mariadb-client \
    postgresql-client \
    python3 \
    uwsgi \
    uwsgi-python \
    mariadb-connector-c && \
  echo "**** install healthchecks ****" && \
  mkdir -p /app/healthchecks && \
  if [ -z ${VERSION+x} ]; then \
    VERSION=$(curl -sX GET "https://api.github.com/repos/healthchecks/healthchecks/releases/latest" \
      | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  curl -o \
    /tmp/healthchecks.tar.gz -L \
    "https://github.com/healthchecks/healthchecks/archive/v${VERSION}.tar.gz" && \
  tar xf \
    /tmp/healthchecks.tar.gz -C \
    /app/healthchecks/ --strip-components=1 && \
  echo "**** install pip packages ****" && \
  cd /app/healthchecks && \
  python3 -m venv /lsiopy && \
  pip install -U --no-cache-dir \
    pip \
    wheel && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/alpine-3.22/ \
    apprise \
    minio \
    mysqlclient && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/alpine-3.22/ -r requirements.txt && \
  cd /app/healthchecks && \
  DEBUG=False python3 ./manage.py collectstatic --noinput && \
  DEBUG=False python3 ./manage.py compress && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    $HOME/.cache \
    $HOME/.cargo \
    /tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 8000

VOLUME /config
