FROM ghcr.io/trueforge-org/python:3.14.5@sha256:c1237b4ee242c9d67a1bae2611ab92f45e8c39da8835a974e4dd49d43077c353

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
COPY --chmod=0755 . /

VOLUME /app
