
FROM ghcr.io/trueforge-org/python:3.13.7@sha256:8a2c1da075925eac6d7e3a405035b60a68e1f82cf61b7807a7e87d9ca4f8c999

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --upgrade --virtual=build-dependencies \
    build-base \
    cargo \
    jpeg-dev \
    libffi-dev \
    libxslt-dev \
    libxml2-dev \
    openldap-dev \
    openssl-dev \
    postgresql-dev \
    zlib-dev && \
  echo "**** install runtime packages ****" && \
  apk add --no-cache --upgrade \
    libldap \
    postgresql-client \
    tiff \
    uwsgi \
    uwsgi-python && \
  echo "**** install netbox ****" && \
  mkdir -p /app/netbox && \
  curl -o \
  /tmp/netbox.tar.gz -L \
    "https://github.com/netbox-community/netbox/archive/v${VERSION}.tar.gz" && \
  tar xf \
  /tmp/netbox.tar.gz -C \
    /app/netbox/ --strip-components=1 && \
    echo "**** install pip packages ****" && \
  cd /app/netbox && \
  python3 -m venv /config/venv && \
  pip install -U --no-cache-dir \
    pip \
    wheel && \
  pip install --no-cache-dir --find-links https://wheel-index.linuxserver.io/alpine-3.20/ -r requirements.txt && \
  pip install --no-cache-dir  django-auth-ldap && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /tmp/* \
    ${HOME}/.cargo \
    ${HOME}/.cache

# copy local files
USER apps
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 8000

VOLUME /config
