
FROM ghcr.io/trueforge-org/python:3.14.5@sha256:c1237b4ee242c9d67a1bae2611ab92f45e8c39da8835a974e4dd49d43077c353

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install build packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cargo \
    libjpeg-dev \
    libffi-dev \
    libxslt-dev \
    libxml2-dev \
    libldap2-dev \
    libsasl2-dev \
    libssl-dev \
    libpq-dev \
    zlib1g-dev && \
  echo "**** install runtime packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    libldap2 \
    postgresql-client \
    libtiff6 \
    uwsgi \
    uwsgi-plugin-python3 && \
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
  python3 -m venv /app/venv && \
  /app/venv/bin/pip install -U --no-cache-dir \
    pip \
    wheel && \
  /app/venv/bin/pip install --no-cache-dir -r requirements.txt && \
  /app/venv/bin/pip install --no-cache-dir django-auth-ldap && \
  mkdir -p /config/{scripts,media,static} && \
  chown -R apps:apps /config && \
  rm -rf /app/netbox/netbox/{media,static} /app/netbox/netbox/netbox/{configuration.py,ldap_config.py} && \
  ln -s /config/media /app/netbox/netbox/media && \
  ln -s /config/static /app/netbox/netbox/static && \
  ln -s /config/configuration.py /app/netbox/netbox/netbox/configuration.py && \
  ln -s /config/ldap_config.py /app/netbox/netbox/netbox/ldap_config.py && \
  echo "**** cleanup ****" && \
  apt-get autoremove -y && \
  rm -rf \
    /tmp/* \
    ${HOME}/.cargo \
    ${HOME}/.cache

# copy local files
USER apps
COPY --chmod=0755 . /


# ports and volumes
EXPOSE 8000

VOLUME /config

WORKDIR /config
