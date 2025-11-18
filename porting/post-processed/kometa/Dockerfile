
FROM ghcr.io/trueforge-org/python:3.13.7@sha256:436649ee533b748645c1e3ad8e4a1fc3fd2d9d4f0b1cc937bf742a5c3a7f32e5

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# environment settings
ENV S6_STAGE2_HOOK=/init-hook
ENV HOME="/config" \
PYTHONIOENCODING=utf-8

RUN \
    echo "**** install packages ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        libffi-dev \
        libxml2-dev \
        libzen-dev \
        python3-dev \
        libjpeg-dev \
        libxslt1-dev \
        python3-venv \
        python3-pip && \
    mkdir -p /app/kometa && \
    python3 - <<'PY'
import os, urllib.request, tarfile, io
url = "https://github.com/Kometa-Team/Kometa/archive/v${VERSION}.tar.gz"
data = urllib.request.urlopen(url).read()
tf = tarfile.open(fileobj=io.BytesIO(data), mode="r:gz")
for m in tf.getmembers():
        parts = m.name.split("/")[1:]
        if not parts:
                continue
        m.name = "/".join(parts)
        tf.extract(m, path="/app/kometa")
PY && \
    cd /app/kometa && \
    python3 -m venv /config/venv && \
    /config/venv/bin/pip install -U --no-cache-dir \
        pip \
        wheel && \
    /config/venv/bin/pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ -r requirements.txt && \
    echo "**** cleanup ****" && \
    apt-get remove -y --purge \
        build-essential \
        libffi-dev \
        libxml2-dev \
        libzen-dev \
        python3-dev && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* $HOME/.cache

# add local files
USER apps
COPY . /
COPY ./root /

# ports and volumes
VOLUME /config

ENTRYPOINT ["/init-kometa"]
