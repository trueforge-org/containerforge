
FROM ghcr.io/trueforge-org/python:3.13.7

# set version label
ARG VERSION
ARG TARGETARCH
USER root

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
    postgresql-dev \
    zlib-dev && \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    grep \
    mariadb-client \
    postgresql-client \
    uwsgi \
    uwsgi-python \
    mariadb-connector-c && \
  echo "**** install healthchecks ****" && \
  mkdir -p /app/healthchecks && \
  curl -o \
    /tmp/healthchecks.tar.gz -L \
    "https://github.com/healthchecks/healthchecks/archive/v${VERSION}.tar.gz" && \
  tar xf \
    /tmp/healthchecks.tar.gz -C \
    /app/healthchecks/ --strip-components=1 && \
  echo "**** install pip packages ****" && \
  cd /app/healthchecks && \
  python3 -m venv /config/venv && \
  pip install -U --no-cache-dir \
    pip \
    wheel && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ \
    apprise \
    minio \
    mysqlclient && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ -r requirements.txt && \
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
USER apps
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 8000

VOLUME /config
