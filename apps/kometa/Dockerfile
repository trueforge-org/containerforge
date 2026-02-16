FROM ghcr.io/trueforge-org/python:3.14.3@sha256:ce429d498a8b592f7495c3cd2ac98d31c56d4ffaf00cacbb49e418494e25c626

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
    pip3 install -U pip wheel && \
    pip3 install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ -r /app/kometa/requirements.txt && \
    cp /etc/ssl/certs/ca-certificates.crt /etc/ca-certificates.crt && \
    chmod 644 /etc/ca-certificates.crt && \
    apt-get remove -y --purge build-essential libffi-dev libxml2-dev libzen-dev && \
    apt-get autoremove -y && \
    chown -R apps:apps /app && chmod -R 755 /app && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* $HOME/.cache

USER apps
COPY . /

VOLUME /app
