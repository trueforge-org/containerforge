FROM ghcr.io/trueforge-org/python:3.13.7@sha256:436649ee533b748645c1e3ad8e4a1fc3fd2d9d4f0b1cc937bf742a5c3a7f32e5

ARG VERSION
ARG TARGETARCH
USER root

ENV HOME="/config" \
    PYTHONIOENCODING=utf-8

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        libffi-dev \
        libxml2-dev \
        libxslt1-dev \
        libzen-dev \
        libjpeg-dev && \
    mkdir -p /app/kometa && \
    curl -L -o /tmp/kometa.tar.gz \
        "https://github.com/Kometa-Team/Kometa/archive/v${VERSION}.tar.gz" && \
    tar xf /tmp/kometa.tar.gz -C /app/kometa --strip-components=1 && \
    cd /app/kometa && \
    python3 -m venv /config/venv && \
    /config/venv/bin/pip install -U pip wheel && \
    /config/venv/bin/pip install -U --no-cache-dir -r /app/kometa/requirements.txt && \
    \
    apt-get remove -y --purge build-essential libzen-dev && \
    apt-get autoremove -y && \
    \
    apt-get install -y --no-install-recommends \
        libffi8 \
        libxml2 \
        libxslt1.1 \
        libjpeg62-turbo && \
    \
    chown -R apps:apps /app && chmod -R 755 /app && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* $HOME/.cache


USER apps
COPY . /

VOLUME /config
