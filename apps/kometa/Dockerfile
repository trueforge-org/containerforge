FROM ghcr.io/trueforge-org/python:3.13.7@sha256:9a1dfe6b3eee6522edf77799d5468374d33f85e46305177c062bf72210b61767

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
    python3 -m venv /app/venv && \
    /app/venv/bin/pip install -U pip wheel && \
    /app/venv/bin/pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ -r /app/kometa/requirements.txt && \
    apt-get remove -y --purge build-essential libffi-dev libxml2-dev libzen-dev && \
    apt-get autoremove -y && \
   chown -R apps:apps /app && chmod -R 755 /app && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* $HOME/.cache

USER apps
COPY . /

VOLUME /app
