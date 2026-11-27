# syntax=docker/dockerfile:1@sha256:572cebbc2b15e6f84c077742952674889cb63cd5e9b80abdffcbe587b6f19183

# Source stage: the upstream server tree from the official image, same version as VERSION.
# UNVERIFIED: pin this stage by digest (docker buildx imagetools inspect seafileltd/seafile-mc:14.0.9).
# renovate: datasource=docker depName=seafileltd/seafile-mc versioning=semver
FROM docker.io/seafileltd/seafile-mc:14.0.11@sha256:7b809052450067bb5c508600409db261d3d498971b77c8ecd647ccaf079323f3 AS source

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
USER root

# UNVERIFIED: package names and which of these the ubuntu base already has. Build tools are purged after pip.
RUN echo "*** Installing system and Python build dependencies ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    nginx \
    python3 \
    python3-venv \
    python3-dev \
    build-essential \
    pkg-config \
    libmariadb-dev \
    libmemcached11t64 \
    libldap2-dev \
    libsasl2-dev \
    poppler-utils \
    libimage-exiftool-perl \
    openssl \
    ca-certificates \
    curl && \
  python3 -m venv /app/venv && \
  /app/venv/bin/pip install --no-cache-dir \
    click \
    termcolor \
    colorlog \
    pytz \
    sqlalchemy \
    pymysql \
    jinja2 \
    django-pylibmc \
    pylibmc \
    psd-tools \
    lxml \
    django \
    cffi \
    future \
    mysqlclient \
    captcha \
    django_simple_captcha \
    pyjwt \
    djangosaml2 \
    pysaml2 \
    pycryptodome \
    python-ldap \
    pillow \
    pillow-heif \
    cairosvg \
    cryptography \
    gunicorn && \
  apt-get purge -y build-essential pkg-config python3-dev && \
  rm -rf /var/lib/apt/lists/*
# UNVERIFIED: the pip list is taken from the upstream image. Pin versions to the v14.0.9-server requirements.

COPY --from=source /opt/seafile/seafile-server-${VERSION} /app/seafile-server

# UNVERIFIED: license file names in the upstream tree.
RUN mkdir -p /usr/share/licenses/seafile && \
  (cp /app/seafile-server/LICENSE* /usr/share/licenses/seafile/ 2>/dev/null || true)

ENV \
  HOME=/config \
  PATH=/app/venv/bin:${PATH} \
  TIME_ZONE=UTC \
  XDG_CACHE_HOME=/tmp/.cache

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config
WORKDIR /config
