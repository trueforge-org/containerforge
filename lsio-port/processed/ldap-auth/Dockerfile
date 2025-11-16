
FROM ghcr.io/linuxserver/baseimage-alpine:3.21

# set version label
ARG VERSION
ARG LDAP_VERSION

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
  if [ -z ${LDAP_VERSION+x} ]; then \
    LDAP_VERSION=$(curl -sL  https://pypi.python.org/pypi/python-ldap/json |jq -r '. | .info.version'); \
  fi && \
  python3 -m venv /lsiopy && \
  pip install -U --no-cache-dir \
    pip \
    wheel && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/alpine-3.21/ \
    cryptography \
    legacy-cgi \
    python-ldap=="${LDAP_VERSION}" && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /tmp/* \
    $HOME/.cache

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 8888 9000
