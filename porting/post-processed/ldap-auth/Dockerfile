
FROM ghcr.io/trueforge-org/python:3.13.7@sha256:8a2c1da075925eac6d7e3a405035b60a68e1f82cf61b7807a7e87d9ca4f8c999

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    build-base \
    openldap-dev \
    python3-dev && \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    libffi \
    libldap \
    python3 && \
  python3 -m venv /config/venv && \
  pip install -U --no-cache-dir \
    pip \
    wheel && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/alpine-3.21/ \
    cryptography \
    legacy-cgi \
    python-ldap=="${VERSION}" && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /tmp/* \
    $HOME/.cache

# copy local files
USER apps
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 8888 9000
