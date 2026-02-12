FROM ghcr.io/trueforge-org/python:3.13.7@sha256:708f480d444e56c1b20c0966b9fa08ce0aaba16ed5e2ef3469f5f6a161549e87

ARG VERSION
ARG TARGETARCH
USER root

ENV HOME="/app" \
    PYTHONIOENCODING=utf-8

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        libffi-dev \
        libxml2-dev \
        libzen-dev \
        libjpeg-dev \
        libxslt1-dev && \
    mkdir -p /app/kometa && \
    curl -L -o /tmp/kometa.tar.gz \
        "https://github.com/Kometa-Team/Kometa/archive/v${VERSION}.tar.gz" && \
    tar xf /tmp/kometa.tar.gz -C /app/kometa --strip-components=1 && \
    cd /app/kometa && \
    python3 -m venv /config/venv && \
    /config/venv/bin/pip install -U pip wheel && \
    /config/venv/bin/pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ -r /app/kometa/requirements.txt && \
    apt-get remove -y --purge build-essential libffi-dev libxml2-dev libzen-dev && \
    apt-get autoremove -y && \
    chown -R apps:apps /app && chmod -R 755 /app && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* $HOME/.cache

USER apps
COPY . /

VOLUME /app
