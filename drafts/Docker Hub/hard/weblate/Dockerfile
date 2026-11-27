# hadolint ignore=DL3007
# UNVERIFIED: the Python 3.15 wheels for lxml, xmlsec, pycairo, PyGObject and psycopg. This is the biggest blocker risk.
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d AS build

ARG VERSION

USER root
WORKDIR /tmp

# UNVERIFIED: development package names for ubuntu 26.04. build-essential comes with the python base.
# hadolint ignore=DL3008,DL3015
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        git \
        libacl1-dev \
        libcairo2-dev \
        libffi-dev \
        libgirepository-2.0-dev \
        libjpeg-dev \
        libldap2-dev \
        libpango1.0-dev \
        libpq-dev \
        libsasl2-dev \
        libxml2-dev \
        libxmlsec1-dev \
        libxslt1-dev \
        pkg-config \
    && rm -rf /var/lib/apt/lists/*

ENV PIP_NO_CACHE_DIR=1 \
    TMPDIR=/tmp \
    HOME=/tmp

# UNVERIFIED: upstream installs from scripts/requirements.txt (pinned deps). That file was not fetched, so the
# Weblate extras are installed directly here. Vendor the upstream pins before merge.
RUN /app/venv/bin/pip install --no-binary xmlsec --no-binary lxml \
      "Weblate[all,zxcvbn,saml,wsgi,wllegal,oidc]==${VERSION}" && \
    /app/venv/bin/python -c 'from phply.phpparse import make_parser; make_parser()' && \
    rm -rf /tmp/*

# UNVERIFIED: the license is fetched from the tag. It is the repo LICENSE, which is GPLv3.
RUN mkdir -p /out/usr/share/licenses/weblate && \
    curl -fsSL "https://raw.githubusercontent.com/WeblateOrg/weblate/${VERSION}/LICENSE" \
      -o /out/usr/share/licenses/weblate/LICENSE

# ---------------------------------------------------------------------------
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION

USER root

# UNVERIFIED: runtime package list. It was reconstructed, not copied from upstream weblate/base. Missing libraries show up as import errors at start.
# hadolint ignore=DL3008,DL3015
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gettext-base \
        gir1.2-pango-1.0 \
        git \
        git-lfs \
        libcairo2 \
        libgirepository-2.0-0 \
        libjpeg-turbo8 \
        libldap2 \
        libpango-1.0-0 \
        libpangocairo-1.0-0 \
        libpq5 \
        libsasl2-2 \
        libxml2 \
        libxmlsec1-openssl \
        libxslt1.1 \
        nginx \
        openssh-client \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=build /app/venv /app/venv
COPY --from=build /out/ /

ENV DJANGO_SETTINGS_MODULE=weblate.settings_docker \
    WEBLATE_DOCKER_CONTAINER=1 \
    WEBLATE_DATA_DIR=/config/data \
    WEBLATE_CACHE_DIR=/tmp/cache \
    PYTHONUNBUFFERED=1 \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    HOME=/config

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config
WORKDIR /config

CMD ["/start.sh"]
