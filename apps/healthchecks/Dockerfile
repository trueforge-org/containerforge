
FROM ghcr.io/trueforge-org/python:3.15.1@sha256:fcc611b0d03ab808bdce505d2d2524c941ec5d2314ef3eb0b63c43d22bd6a2b2

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ENV PYTHONUNBUFFERED=1

RUN \
    echo "**** install build packages ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        cargo \
        libcurl4-openssl-dev \
        libjpeg-dev \
        libffi-dev \
        default-libmysqlclient-dev \
        libpq-dev \
        zlib1g-dev && \
    echo "**** install runtime packages ****" && \
    apt-get install -y --no-install-recommends \
        mariadb-client \
        postgresql-client \
        uwsgi \
        uwsgi-plugin-python3 \
        libmariadb3 && \
    echo "**** install healthchecks ****" && \
    mkdir -p /app/healthchecks && \
    (curl -fL -o \
        /tmp/healthchecks.tar.gz \
        "https://github.com/healthchecks/healthchecks/archive/refs/tags/v${VERSION}.tar.gz" || curl -fL -o \
        /tmp/healthchecks.tar.gz \
        "https://github.com/healthchecks/healthchecks/archive/refs/tags/${VERSION}.tar.gz") && \
    tar xf \
        /tmp/healthchecks.tar.gz -C \
        /app/healthchecks/ --strip-components=1 && \
    echo "**** install pip packages ****" && \
    cd /app/healthchecks && \
    python3 -m venv /app/venv && \
    /app/venv/bin/pip install -U --no-cache-dir \
        pip \
        wheel && \
    /app/venv/bin/pip install -U --no-cache-dir \
        apprise \
        minio \
        mysqlclient && \
    /app/venv/bin/pip install -U --no-cache-dir -r requirements.txt && \
    cd /app/healthchecks && \
    DEBUG=False /app/venv/bin/python ./manage.py collectstatic --noinput && \
    DEBUG=False /app/venv/bin/python ./manage.py compress && \
    echo "**** cleanup ****" && \
    apt-get purge -y --auto-remove \
        build-essential \
        cargo \
        libcurl4-openssl-dev \
        libjpeg-dev \
        libffi-dev \
        default-libmysqlclient-dev \
        libpq-dev \
        zlib1g-dev && \
    apt-get clean && \
    rm -rf \
        $HOME/.cache \
        $HOME/.cargo \
        /tmp/* \
        /var/lib/apt/lists/*

# copy local files
USER apps
COPY --chmod=0755 . /


# ports and volumes
EXPOSE 8000

VOLUME /config

WORKDIR /config
