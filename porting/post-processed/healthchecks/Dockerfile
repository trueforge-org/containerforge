
FROM ghcr.io/trueforge-org/python:3.13.7@sha256:8a2c1da075925eac6d7e3a405035b60a68e1f82cf61b7807a7e87d9ca4f8c999

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
    apt-get purge -y --auto-remove \
        build-essential \
        cargo \
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
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 8000

VOLUME /config
